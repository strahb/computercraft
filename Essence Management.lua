--[[ What does this program do?
Mystical Agriculture has 5+1 Essences (Custom Essence tier). This program should ensure that all the essences automatically get crafted into the highest tier, and after it reaches a specific threshold it stops crafting said tier and jumps to the lower tier. Effectively maintaining a stock of all tiers 
]]
-- 

local bridge = peripheral.find("meBridge")

if bridge == nil then
    print("ME Bridge Not Found! Now exiting...")
    error()
else
    local TotalStorage = bridge.getTotalItemStorage() / (1024*1024*1024)
    print("ME Bridge Connected")
    print(string.format("Total Item Storage: %.2f GB", TotalStorage))
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

local itemData = GetItem("mysticalagriculture:inferium_essence")

if itemData.amount ~= 0 then
    local count = itemData.amount  -- Extract item amount
    local displayName = itemData.displayName  -- Extract item display name

    print(displayName .. ": " .. count)
else
    print("Item not found in ME system.")
end