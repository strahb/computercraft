--[[
    Mystical Agriculture Essence Auto-Crafter
    --------------------------------------------------------------
    This program automatically crafts higher-tier Essences from a lower-tier source
    until the higher-tier essence reaches a threshold of 12,000 items.
    The program automatically ignores inferium essence and continues exporting
    from the lower tier while under the threshold. Once the threshold is reached,
    or if the essence is inferium, the program stops exporting from the lower tier.

    It keeps exporting the second highest tier until the highest tier is fully crafted
    and then it stops exporting the second highest. ALL ESSENCE IS EXPORTED BY DEFAULT
    The recipe is:  4x Lower Tier = 1x Higher Tier
        Supremium
        │
        └──Imperium
            │
            └──Tertium
                │
                └──Prudentium
                    │
                    └──Inferium
]]

local monitor = peripheral.find("monitor")
if monitor == nil then
    -- Find, wrap, and configure the monitor, if monitor not found the code output will remain the main terminal
    print("Monitor not found")
    print("Dashboard will not work but program will continue")
else
    monitor.setTextScale(0.75)
    monitor.setCursorPos(1, 1)
    monitor.clear()
end

local bridge = peripheral.find("meBridge")
if bridge == nil then
    print("[Critical] ME Bridge Not Found! Now exiting...")
    error()
elseif bridge.isConnected() == false then
    for i = 1, 5 do
        print(string.format("[Attmpt %s] ME Network Offline!", math.floor(i)))
        if bridge.isConnected() == true then
            break
        end
        os.sleep(1)
    end
    print("[Critical] ME Bridge Disconnected! Now exiting...")
    error()
else
    local TotalStorage = bridge.getTotalItemStorage() / (1024 * 1024 * 1024)
    print("ME Bridge Connected")
    print(string.format("Total Item Storage: %.2f GB", TotalStorage))
end

local function GetItem(ItemID)
    -- Function to fetch item information from the bridge
    local item = bridge.getItem({ name = ItemID })
    if type(item) == "table" then
        return item
    elseif type(item) == "number" then
        return { amount = item }
    else
        return { amount = 0 }
    end
end

local function ExportItem(ItemID, Amount)
    -- Function to export item to the upper side of the bridge
    local FormattedQuery = { name = ItemID, count = Amount } --[[ Format the Query
        name: string	The registry name of the item
        fingerprint: string?	A unique fingerprint which identifies the item to craft
        amount: number	The amount of the item in the system
        displayName: string	The display name for the item
        isCraftable: boolean	Whether the item has a crafting pattern or not
        nbt: string?	NBT to match the item on
        tags: table	A list of all of the item tags ]]
    bridge.exportItem(FormattedQuery, "left")
end

local function CraftEssence(ItemToCraft, Amount)
    -- Core function that does the crafting
    for i, essence in ipairs(Essences) do
        if essence.QuickLookup == ItemToCraft then
            local foundIndex = i
            ExportItem(Essences[(foundIndex - 1)].ID, Amount * 4)
            break -- Exit the loop once the value is found.
        end
    end
end

-- Dashboard function that updates the monitor with current essence amounts - THIS IS AI
local function drawDashboard()
    -- Make sure we're writing to the monitor
    if monitor then
        monitor.clear()
        monitor.setCursorPos(1, 1)
        monitor.write("Essence Dashboard   | Day " .. os.day())
        -- Write the essence names and threshold information, all static information
        monitor.setCursorPos(1, 10)
        monitor.write(string.format("Threshold: %d    | Limit: %3d", Threshold, ExportUpperLimit))
        for i, essence in ipairs(Essences) do
            monitor.setCursorPos(1, 2 + i)
            monitor.write(string.format("%-20s:", essence.displayName))
        end
        -- Display the essence counts, this is the only part that cycles giving the annoying monitor refresh
        for i, essence in ipairs(Essences) do
            local item = GetItem(essence.ID)
            local amount = item.amount or 0
            local line = string.format(amount)
            monitor.setCursorPos(23, 2 + i)
            monitor.write(line)
        end
    end
end

-- Helper function: Processes a conversion from a lower-tier essence to a higher-tier essence.
-- It calculates how many batches (of 4) can be converted without exceeding the threshold. - THIS IS AI
local function processConversion(lowerEssence, higherEssence)
    local lowerItem = GetItem(lowerEssence.ID)
    local higherItem = GetItem(higherEssence.ID)

    local lowerAmount = lowerItem.amount or 0
    local higherAmount = higherItem.amount or 0

    local possibleConversions = math.floor(lowerAmount / 4)
    local neededConversions = Threshold - higherAmount
    local conversions = math.min(possibleConversions, neededConversions)

    local conversionsSanitized = math.min(conversions, ExportUpperLimit / 4)

    if conversionsSanitized > 0 then
        -- Call CraftEssence with the target (higher tier) QuickLookup
        CraftEssence(higherEssence.QuickLookup, conversionsSanitized)
        term.setTextColor(colors.green)
        print(string.format(
            "%03d %s -> %03d %s",
            conversionsSanitized * 4,
            lowerEssence.QuickLookup,
            conversionsSanitized,
            higherEssence.QuickLookup
        ))
        term.setTextColor(colors.white)
    elseif conversions < 0 then
        term.setTextColor(colors.yellow)
        print(string.format("[000] %s over threshold", higherEssence.QuickLookup))
        term.setTextColor(colors.white)
    end
end

Args = { ... }

local function ArgumentParser(args)
    local config = {
        Threshold = 12288,
        ExportUpperLimit = 512
    }
    for _, arg in ipairs(args) do
        local key, val = arg:match("^%-%-(%w+)=?(.*)$")
        if key and tonumber(val) then
            config[key] = tonumber(val)
        end
    end
    return config
end

-- Essence objects declaration, all are grouped in an Essences array. Kinda like how forge groups them all under the mysticalagriculture:Essences tag
Inferium = { ID = "mysticalagriculture:inferium_essence", tier = 1, displayName = "Inferium Essence", QuickLookup =
"Inferium" }
Prudentium = { ID = "mysticalagriculture:prudentium_essence", tier = 2, displayName = "Prudentium Essence", QuickLookup =
"Prudentium" }
Tertium = { ID = "mysticalagriculture:tertium_essence", tier = 3, displayName = "Tertium Essence", QuickLookup =
"Tertium" }
Imperium = { ID = "mysticalagriculture:imperium_essence", tier = 4, displayName = "Imperium Essence", QuickLookup =
"Imperium" }
Supremium = { ID = "mysticalagriculture:supremium_essence", tier = 5, displayName = "Supremium Essence", QuickLookup =
"Supremium" }
Insanium = { ID = "mysticalagradditions:insanium_essence", tier = 6, displayName = "Insanium Essence", QuickLookup =
"Insanium" }

Essences = { Inferium, Prudentium, Tertium, Imperium, Supremium, Insanium }

Threshold = ArgumentParser(Args).Threshold
ExportUpperLimit = ArgumentParser(Args).Threshold

while true do
    -- Main loop: Continuously run the recipe conversion chain.
    -- Convert Inferium -> Prudentium
    processConversion(Inferium, Prudentium)
    -- Convert Prudentium -> Tertium
    processConversion(Prudentium, Tertium)
    -- Convert Tertium -> Imperium
    processConversion(Tertium, Imperium)
    -- Convert Imperium -> Supremium
    processConversion(Imperium, Supremium)
    -- Convert Supremium -> Insanium
    processConversion(Supremium, Insanium)

    drawDashboard()
end
