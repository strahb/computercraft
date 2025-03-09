-- Define Mekanism Machine
local mek = peripheral.wrap("right")


-- Function to count items in said machine
local function countInput(machine)
    local TotalInput = 0
    for i=0,8 do
        TotalInput = TotalInput + mek.getInput(i)
    return TotalInput
end

-- Function to repeat until machine empty
local function EmptyRepeat(side)
    repeat countInput(mek)
    until countInput(mek) = 0
end



-- Machine starts at redstone flick, computer starts tracking at redstone flick too. Computer keeps checking until the machine is empty