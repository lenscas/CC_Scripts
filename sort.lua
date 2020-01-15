--This table is used to have the turtle know where stuff needs to go. The keys are the itemIds and the valye needs to be a function acepting the itemData which returns the direction
local itemList={}
itemList['arsmagica2:itemOre']=function(data) return "north" end
itemList['ProjRed|Core:projectred.core.part']=function(data) return "north" end
itemList['Thaumcraft:blockCustomOre']=function(data) return "north" end
itemList['arsmagica2:vinteumOre']=function(data) return "north" end
itemList['IC2:item.itemOreUran']=function(data) return "north" end
itemList['TConstruct:ore.berries.one']=function(data) return "north" end
itemList['minecraft:cobblestone']=function(data) return "west" end
itemList['minecraft:flint']=function(data) return "west" end
itemList['minecraft:gravel']=function(data) return "west" end
itemList['minecraft:dirt']=function(data) return "west" end
itemList['NuclearCraft:blockOre']=function(data)
   if data.damage==9 or data.damage==7 then
     return "north"
   else
     return "north"
   end
end
itemList['ThermalFoundation:Ore']=function(data)
   print(table.concat(data," "))
   if data.damage==4 or data.damage==3 or data.damage==5 then
     return "north"
   else
     return "south"
   end
end
--This function is used if the item can't be found in the itemList. The itemList has priority over this function.
--You can use this function for example to make a default route or to have more general rules like every item containing "ore"
local function fallBack(itemData)
   if string.find(itemData.name,"ore") or string.find(itemData.name,"Ore") then
     return "south"
   end
   return "north"
end
local compass=peripheral.wrap("left")
--this is used to make the turtle always aware of where it is.
local at=nil

--used to more easily get the turtle to turn
local function turn(way,amount)
   if not amount then
     amount=1
   end
   for times=1,amount do
     if way=="left" then
       turtle.turnLeft()
     elseif way=="right" then
       turtle.turnRight()
     end
   end
end
--called during startup
local function reset()
   at=compass.getFacing()
end
--this will have the turtle turn to the direction it needs to face in
function doTurn(need)
   print(need," ",at)
   if need == at then
     return true
   elseif(at=="north"     and   need=="west") then
     turn("left")
   elseif(at=="north"     and   need=="south") then
     turn("left",2)
   elseif at=="north"     and   need=="east" then
     turn("right")
   elseif at == "west"     and   need =="north" then
     turn("right")
   elseif at =="west"     and   need=="south" then
     turn("left")
   elseif at =="west"     and   need=="east" then
     turn("left",2)
   elseif at == "south"   and   need=="west" then
     turn("right")
   elseif at == "south"   and   need == "east" then
     turn("left")
   elseif at =="south"     and   need=="north" then
     turn("left",2)
   elseif at == "east"     and   need =="west" then
     turn("left",2)
   elseif at =="east"     and need == "south" then
     turn("right")
   elseif at == "east"     and need == "north" then
     turn("left")
   end
   at =need
end

local function putAway()
   local stacks=0
   local inventorySize
   peripheral.call("front","condenseItems")
   stacks = peripheral.call("front","getAllStacks")
   inventorySize=peripheral.call("front","getInventorySize")
   if(#stacks) < inventorySize then
     turtle.drop()
   end
end

local function checkWhere()
   local itemData=nil
   local direction=nil
   itemData=turtle.getItemDetail()
   if itemData then
     if itemList[itemData.name] then
       direction=itemList[itemData.name](itemData)
       doTurn(direction)
       putAway()
     else
       print("fallBack")
       direction=fallBack(itemData)
       doTurn(direction)
       putAway()
     end
   end
end
reset()
while true do
   local where=nil
   turtle.suckUp()
   for slot = 1,16 do
     turtle.select(slot)
     where=checkWhere()
     if where then
       doTurn(where)
       putAway()
     end
   end
   sleep(1)
end
