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
        term.redirect(monitor)
        print("Monitor Ready")
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
    if item then
        return item
    else
        print("Item not found: " .. ItemID)
        return 0 -- Return 0 if item is not found
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
            ExportItem(essences[(foundIndex - 1)].ID, Amount * 4) -- Need to figure out how to dynamically get the index
            print(string.format("Crafted %d %s", Amount, essence.displayName))
            break  -- Exit the loop once the value is found.
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

CraftEssence("Insanium", 64)


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