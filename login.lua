local component = require("component")
local sides = require("sides")
local sz = require("serialization")
local term = require("term")
local event = require("event")
local rs = component.redstone

local wait = 4 -- How long to hold the door open
local side = sides.west --What side the door is on
local rsOutput = {max=15, min=0}
local users = {Brodur=true, crassclown=true, fatso12321=true, Ouhai_ruby=true}
local watching = true

--- OpenClose
-- Open and close the door
function openClose()
  wait = wait or 5
  rs.setOutput(side, rsOutput.max)
  os.sleep(wait)
  rs.setOutput(side, rsOutput.min)
end

function welcome()
  term.setCursor(1,1)
  term.clear()
  print("Press any key to enter!")
end

function program_loaded()
  print("Loaded!")
  while watching do
    welcome()
    _,_,_,key,user = event.pull("key_down")
    if users[user] then
      if key == 41 then 
        watching = false
      end
      print("Welcome", user)
      openClose()
    else
      print("Not welcome", user)
    end
  end
end

program_loaded()