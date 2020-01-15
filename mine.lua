local chestName="EnderStorage:enderChest"
function editColors(become)
   --this contains the colors of your enderchests. Send are the colors it will use to send its ores from and fuel are the colors it uses to grab fuel from
   local colors={send={colors.lightBlue,colors.blue,colors.blue},fuel={colors.white,colors.blue,colors.blue}}
   peripheral.call("top","setColours",colors[become][1],colors[become][2],colors[become][3])
end  
function refuel()
   print(turtle.getFuelLevel())
   editColors("fuel")
   if turtle.getFuelLevel()<200 then
     turtle.select(15)
     turtle.suckUp()
     turtle.refuel()
     turtle.dropUp()
   end
  turtle.select(16)
   print(turtle.getFuelLevel())
  
end
function sendItems()
    peripheral.call("top","condenseItems")
   local items   = peripheral.call("top","getAllStacks",false)
   editColors("send")
   while #items> 0 do
     sleep(#items)
     peripheral.call("top","condenseItems")
     items   = peripheral.call("top","getAllStacks",false)
   end
   for slot=1,16 do
     turtle.select(slot)
     turtle.dropUp()
   end
end
function startup()
   local sucess, itemData=nil
   turtle.select(16)
   if turtle.getItemCount()>0 then
     itemData=turtle.getItemDetail()
     if itemData['name']==chestName then
       turtle.digUp()
       turtle.placeUp()
     end
   end
   sucess ,itemData=turtle.inspectUp()
   if sucess then
     if itemData['name']==chestName then
       sendItems()
       refuel()
       turtle.select(16)
       turtle.digUp()
       turtle.select(1)
     else
       return false
     end
   else
     return false
   end
   return true
end
function mine()
   while turtle.detectUp() do
     turtle.select(1)
     turtle.digUp()
     sleep(0.5)
   end
   while turtle.detect() do
     turtle.select(1)
     turtle.dig()
     sleep(0.5)
   end
   turtle.select(1)
   turtle.digDown()
end
function forward()
   local sucess=false
   local counter=0
   while not turtle.forward() do
     mine()
     turtle.attack()
     counter=counter+1
     if counter>2 then
       turtle.select(16)
       turtle.placeUp()
       refuel()
       turtle.digUp()
     elseif counter>4 then
       stop()
     end
   end
end
function stop()
   while true do
     turtle.sleep(100)
   end
end

if not startup() then
   block()
end
while true do
   for times=1,15 do
     mine()
     forward()
   end
   mine()
   turtle.select(16)
   turtle.placeUp()
   sendItems()
   refuel()
   turtle.digUp()
end
