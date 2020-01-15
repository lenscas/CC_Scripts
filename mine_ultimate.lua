--some config
local SEND = 1 --the slot with the enderchest to return items
local FUEL = 2 --the slot with the enderchest to get fuel from
local FIRST_SLOT = 3 --first slot that will be used as storage
local LAST_SLOT = 16 --last slot that will be used as storage
local SLEEP_TIME = 0.5 --prevetion loops getting killed
local BREAK_TIME = 100 --how long to wait if it gets stuck
local TIMES_UNTIL_TRY_REFUEL = 2 --how often to try to go forward before trying to get fuel
local TIMES_UNTIL_TRY_BREAK = 4 --how often to fail going forward before going into "stuck" mode
local WAIT_FOR_ROOM_TIME = 20 --how long to wait before trying to add items into the send chest if it was full

local turtle = turtle or {} --to make my editor shut up

--run func after selecting the correct chest and placing it at the top of the turtle
--it also gets the enderchest back and sets the selected itemslot back to what it was before this was called
local function useChest(slotId, func)
    turtle.select(slotId)
    --do whatever it takes to make place at the top
    while not turtle.placeUp() do
        turtle.select(FIRST_SLOT)
        turtle.digUp()
        turtle.attackUp()
        turtle.select(slotId)
        sleep(SLEEP_TIME)
    end
    func()
    --reset, make it look like this function was never called
    turtle.select(slotId)
    turtle.digUp()
    turtle.select(FIRST_SLOT)
end

--send every item back to the base
local function sendItems()
   useChest(SEND,function()
    for slot = FIRST_SLOT, LAST_SLOT do
        turtle.select(slot)
        if turtle.getItemCount(slot) > 0 then
            while not turtle.dropUp() do sleep(WAIT_FOR_ROOM_TIME) end
        end
    end
   end)
end

--refuel, if needed
local function refuel()
    print(turtle.getFuelLevel())
    if turtle.getFuelLevel() < 200 then
     sendItems()
     useChest(FUEL,function()
         turtle.select(LAST_SLOT)
         turtle.suckUp()
         turtle.refuel()
         if not turtle.dropUp() then
             turtle.drop()
         end
     end)
    end
    print(turtle.getFuelLevel())
 end

 --get the turtle in a known good state
local function startup()

   turtle.select(FIRST_SLOT)
   local hasSendChest = turtle.getItemCount(SEND) == 1
   local hasRefuelChest = turtle.getItemCount(FUEL) == 1

   if hasRefuelChest == false and hasSendChest == false then
        print("Missing fuel and send chest")
        --bad state :(
        return false
   end
   --reclaim fuel chest
   if not hasRefuelChest then
        turtle.select(FUEL)
        turtle.digUp()
   end
   --reclaim send chest
   if not hasSendChest then
        turtle.select(SEND)
        turtle.digUp()
   end
   --bring to known good state
   sendItems()
   refuel()
   turtle.select(FIRST_SLOT)
   --we are now in a known good state! HOORAY!
   return true
end


local function mine()
    while turtle.detectUp() do
     turtle.select(FIRST_SLOT)
     turtle.digUp()
     sleep(SLEEP_TIME)
   end
   while turtle.detect() do
     turtle.select(FIRST_SLOT)
     turtle.dig()
     sleep(SLEEP_TIME)
   end
   turtle.select(FIRST_SLOT)
   turtle.digDown()
end

--something caused the turtle to be unable to fullfill its task
--waiting may solve the problem, or at least gives you time to notice it and fix it while keeping CPU load to a minimum
local function takeBreak(reason)
    while true do
        turtle.sleep(BREAK_TIME)
        if reason then
            print("Taking a break because : ",reason)
        end
    end
 end

local function forward()
   local counter=0
   while not turtle.forward() do
     mine()
     turtle.attack()
     counter=counter+1
     if counter > TIMES_UNTIL_TRY_REFUEL then
        print("Something is blocking me. Maybe fuel is low?")
        refuel()
     elseif counter > TIMES_UNTIL_TRY_BREAK then
        takeBreak("Something is really blockig me.")
     end
   end
end

--here is the main part of the program
if not startup() then
   error("Failed discover last state :(")
end

--main loop. Forever, dig forward, if last_slot has items then send everything back
while true do
    while turtle.getItemCount(LAST_SLOT) == 0 do
        mine()
        forward()
   end
   sendItems()
   refuel()
end
