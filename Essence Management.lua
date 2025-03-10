--[[ What does this program do?
Mystical Agriculture has 5+1 Essences (Custom Essence tier). This program should ensure that all the essences automatically get crafted into the highest tier, and after it reaches a specific threshold it stops crafting said tier and jumps to the lower tier. Effectively maintaining a stock of all tiers 
]]
-- 

local bridge = peripheral.find("meBridge")
-- Configure Monitor
local monitor = peripheral.find("monitor")
monitor.setTextScale(1) -- Adjust scale (1 to 5)
monitor.clear()
monitor.setCursorPos(1,1)


local itemData = 0
local essences = {
    "mysticalagriculture:inferium_essence", 
    "mysticalagriculture:prudentium_essence", 
    "mysticalagriculture:tertium_essence", 
    "mysticalagriculture:imperium_essence", 
    "mysticalagriculture:supremium_essence", 
    "mysticalagradditions:insanium_essence" 
}

if bridge == nil then
    print("ME Bridge Not Found!")
    error()
else
    local TotalStorage = bridge.getTotalItemStorage() / (1024*1024*1024)
    print("ME Bridge Connected!")
    print(string.format("Item Storage: %.2f GB", TotalStorage))
end

local function GetItem(lookup_value)
    local item = bridge.getItem({name = lookup_value})
    if item then
        return item
    else
        print("Item not found: " .. lookup_value)
        return 0 -- Return 0 if item is not found
    end
end



for i, essenceName in ipairs(essences) do
    print("index: " .. i)
    itemData = GetItem(essenceName)
    if itemData and itemData.amount ~= 0 then -- If item amount equals 0 then it errors out
        local count = itemData.amount  -- Extract item amount
        local displayName = itemData.displayName  -- Extract item display name

        print(displayName .. ": " .. count)
    else
        print(itemData.displayName .. " not found in ME system.")
    end
end
