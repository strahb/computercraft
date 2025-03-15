--[[ 
    Mystical Agriculture Essence Auto-Crafter
    --------------------------------------------------------------
    This program automatically crafts higher-tier essences from a lower-tier source 
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

monitor = peripheral.find("monitor") if peripheral.find("monitor") == nil then
    -- Find, wrap, and configure the monitor, if monitor not found the code output will remain the main terminal
        print("Monitor not found")
        print("Dashboard will not work but program will continue")
    else
        monitor.setTextScale(0.5)
        monitor.setCursorPos(1,1)
        monitor.clear()
end

bridge = peripheral.find("meBridge") if bridge == nil then
    print("ME Bridge Not Found! Now exiting...")
    error()
else
    local TotalStorage = bridge.getTotalItemStorage() / (1024*1024*1024)
    print("ME Bridge Connected")
    print(string.format("Total Item Storage: %.2f GB", TotalStorage))
end

function GetItem(ItemID)
    -- Function to fetch item information from the bridge
    local item = bridge.getItem({name = ItemID})
    if type(item) == "table" then
        return item
    elseif type(item) == "number" then
        return { amount = item }
    else
        return { amount = 0 }
    end
end

function ExportItem(ItemID, Amount)
    -- Function to export item to the upper side of the bridge
    local FormattedQuery = { name = ItemID, count = Amount } --[[ Format the Query
        name: string	The registry name of the item
        fingerprint: string?	A unique fingerprint which identifies the item to craft
        amount: number	The amount of the item in the system
        displayName: string	The display name for the item
        isCraftable: boolean	Whether the item has a crafting pattern or not
        nbt: string?	NBT to match the item on
        tags: table	A list of all of the item tags ]]
    bridge.exportItem(FormattedQuery, "up")
end

function CraftEssence(ItemToCraft, Amount)
    -- Core function that does the crafting
    for i, essence in ipairs(essences) do
        if essence.QuickLookup == ItemToCraft then
            local foundIndex = i
            ExportItem(essences[(foundIndex - 1)].ID, Amount * 4)
            break  -- Exit the loop once the value is found.
        end
    end
end

-- Dashboard function that updates the monitor with current essence amounts - THIS IS AI
function drawDashboard()
    -- Make sure we're writing to the monitor
    if monitor then
        monitor.clear()
        monitor.setCursorPos(1,1)
        monitor.write("=== Essence Dashboard ===")
        monitor.setCursorPos(1,3)
        for i, essence in ipairs(essences) do
            local item = GetItem(essence.ID)
            local amount = item.amount or 0
            local line = string.format("%-20s: %6d", essence.displayName, amount)
            monitor.write(line)
            monitor.setCursorPos(1, 3 + i)
        end
    end
end

-- Essence objects declaration, all are grouped in an essences array. Kinda like how forge groups them all under the mysticalagriculture:essences tag
Inferium = {ID = "mysticalagriculture:inferium_essence", tier = 1, displayName = "Inferium Essence", QuickLookup = "Inferium"}
Prudentium = {ID = "mysticalagriculture:prudentium_essence", tier = 2, displayName = "Prudentium Essence", QuickLookup = "Prudentium"}
Tertium = {ID = "mysticalagriculture:tertium_essence", tier = 3, displayName = "Tertium Essence", QuickLookup = "Tertium"}
Imperium = {ID = "mysticalagriculture:imperium_essence", tier = 4, displayName = "Imperium Essence", QuickLookup = "Imperium"}
Supremium = {ID = "mysticalagriculture:supremium_essence", tier = 5, displayName = "Supremium Essence", QuickLookup = "Supremium"}
Insanium = {ID = "mysticalagradditions:insanium_essence", tier = 6, displayName = "Insanium Essence", QuickLookup = "Insanium"}

essences = {Inferium, Prudentium, Tertium, Imperium, Supremium, Insanium}

-- Helper function: Processes a conversion from a lower-tier essence to a higher-tier essence.
-- It calculates how many batches (of 4) can be converted without exceeding the threshold. - THIS IS AI
function processConversion(lowerEssence, higherEssence)
    local threshold = 20  -- Define threshold for higher tier
    local lowerItem = GetItem(lowerEssence.ID)
    local higherItem = GetItem(higherEssence.ID)
    
    local lowerAmount = lowerItem.amount or 0
    local higherAmount = higherItem.amount or 0
    
    local possibleConversions = math.floor(lowerAmount / 4)
    local neededConversions = threshold - higherAmount
    local conversions = math.min(possibleConversions, neededConversions)
    
    if conversions > 0 then
        -- Call CraftEssence with the target (higher tier) QuickLookup
        CraftEssence(higherEssence.QuickLookup, conversions)
        print(string.format("Converted %d %s into %d %s", conversions*4, lowerEssence.displayName, conversions, higherEssence.displayName))
    elseif conversions < 0 then
        print(string.format("%s over threshold", higherEssence.displayName))
    end
end

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

    sleep(1)  -- Wait for 1 second before checking again
end
-- for _, essence in ipairs(essences) do
--     essence = GetItem(essence.ID)
--     if essence ~= 0 then -- Execute the block as long as GetItem does not return "0" (Refer to line 52)
--         print("index " .. _ .. ":" .. essence.amount .. " " .. essence.displayName)
--     end
-- end

-- ExportItem("mysticalagriculture:inferium_essence", 1024)
-- local essence = GetItem("mysticalagriculture:inferium_essence")
--     if essence ~= 0 then -- Execute the block as long as GetItem does not return "0" (Refer to line 52)
--         print(essence.displayName)
--         print(essence.amount)
--     end