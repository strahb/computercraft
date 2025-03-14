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

local monitor = peripheral.find("monitor") if peripheral.find("monitor") == nil then
    -- Find, wrap, and configure the monitor, if monitor not found the code output will remain the main terminal
        print("Monitor not found")
        print("Dashboard will not work but program will continue")
    else
        monitor.setTextScale(1)
        monitor.setCursorPos(1,1)
        monitor.clear()
        term.redirect(monitor)
        print("Monitor Ready")
end

local bridge = peripheral.find("meBridge") if bridge == nil then
    print("ME Bridge Not Found! Now exiting...")
    error()
else
    local TotalStorage = bridge.getTotalItemStorage() / (1024*1024*1024)
    print("ME Bridge Connected")
    print(string.format("Total Item Storage: %.2f GB", TotalStorage))
end

local function GetItem(ItemID)
    -- Function to fetch item information from the bridge
    local item = bridge.getItem({name = ItemID})
    if item then
        return item
    else
        print("Item not found: " .. ItemID)
        return 0 -- Return 0 if item is not found
    end
end

local function ExportItem(ItemID, Amount)
    -- Function to export item to the upper side of the bridge
    formatted_query = {item=ItemID, count=Amount} --[[ Properly form the request as the bridge cannot look up a simple string
    I could do it in a single line but it would make the code very hard to read ]] 
    bridge.exportItem({formatted_query, "up"})
    print(string.format("Exported %d %s", Amount, ItemID))
end

exportable_essences =   {"mysticalagriculture:inferium_essence",
                        "mysticalagriculture:prudentium_essence",
                        "mysticalagriculture:tertium_essence",
                        "mysticalagriculture:imperium_essence",
                        "mysticalagriculture:supremium_essence"}

for i, EssenceName in ipairs(exportable_essences) do
    essence = GetItem(EssenceName)
    if essence ~= 0 then -- Execute the block as long as GetItem does not return "0" (Refer to line 52)
        print(essence.displayName)
        print(essence.amount)
    end
end