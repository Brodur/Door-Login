local component = require("component")
local sides = require("sides")
local sz = require("serialutils")
local fs = require("filesystem")
local term = require("term")
local event = require("event")
local menu = require("menu")
local computer = require("computer")

local rs = component.redstone

local wait = 4 -- How long to hold the door open
local side = sides.west --What side the door is on
local rsOutput = {max=15, min=0}
local users = {}
local menuOpts = {"User list", "Add User", "Remove User", "Return","End Program"}
local watching = true
local configDir = "users.lua"


--- Trims strings
-- Gets rid of trailing white space or special characters.
-- @param s The string to trim.
-- @return The trimmed string.
function trim(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

--- OpenClose
-- Open and close the door
function openClose()
  wait = wait or 5
  rs.setOutput(side, rsOutput.max)
  os.sleep(wait)
  rs.setOutput(side, rsOutput.min)
end

--- Welcome
-- Prints the welcome prompt
function welcome()
  term.setCursor(1,1)
  term.clear()
  print("Press any key to enter!")
end

--- Add Trusted Player
-- Adds a trusted player to the door.
-- @param player	The player to add.
function addTrustedPlayer(player)
  if users[player] ~= nil then error("Cannot add a user that already exists!") end
  users[player] = true
end

--- Remove Trusted Player
-- Removes a user from the trusted players list.
-- @param player  The user to remove.
function removeTrustedPlayer(player)
  users[player] = nil
end

function manage()
  local opt = -1
  while opt ~= #menuOpts do
    opt = menu.list(menuOpts, "Management Menu")
    if opt == #menuOpts then watching = false break end
    if opt == #menuOpts - 1 then break end
    if opt == 1 then
      for username,_ in pairs(users) do 
        print("Users:\n")
        print(username) 
      end
      print("Press enter to continue...")
      term.read()
    end
    if opt == 2 then 
      term.write("Add a trusted player: ")
      local player  = trim(term.read())
      local confirm = menu.dialog("Add \'" .. player .. "\' to door?", "Confirm", "Cancel")
      if confirm == 1 then
        addTrustedPlayer(player)
      end
    end
    if opt == 3 then
      local userList = {"Cancel"}
      for username,_ in pairs(users) do userList[#userList] = username end
      local select = -1
      while select ~= 1 do
        select = menu.list(users, "Select a user")
        if opt ~= 1 then
          local player = userList[select]
          local confirm = menu.dialog("Remove \'" .. player .. "\' from trusted users?", "Confirm", "Cancel")
          if confirm == 1 then 
            removeTrustedPlayer(player)
            table.remove(userList, select)
          end
        end
      end
    end
  end
end

function loadConfig()
  if not fs.exists(configDir) then
    tbl = {Brodur=true, crassclown=true, fatso12321=true, Ouhai_ruby=true}
    sz.save(tbl, configDir)
  end
  users = sz.load(configDir)
end

--- Program Loaded
-- The main program loop
function program_loaded()
  loadConfig()
  print("Loaded!")
  while watching do
    local match = false
    welcome()
    _,_,_,key,user = event.pull("key_down")
    if users[user] then
      if key == 184 then 
        computer.beep(200)
        manage()
      else
        computer.beep(600)
        print("Welcome", user)
        openClose()
      end
    else
      print("Not welcome", user)
      computer.beep(400)
    end
  end
  sz.save(users, configDir)
end

program_loaded()