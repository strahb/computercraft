--[[ What does this program do?
Mystical Agriculture has 5+1 Essences (Custom Essence tier). This program should ensure that all the essences automatically get crafted into the highest tier, and after it reaches a specific threshold it stops crafting said tier and jumps to the lower tier. Effectively maintaining a stock of all tiers 
]]
-- 

local bridge = peripheral.find("meBridge")

if getMethods(bridge) == nil then
    print("ME Bridge Not Found! Now exiting...")
    os.exit()
else
    local TotalStorage = bridge.getTotalItemStorage() / (1024*1024)
    print("ME Bridge Connected")
    print(string.format("Total Item Storage: %.2f MB", totalStorage))
end

local function GetItemCount(lookup_value)
    
end