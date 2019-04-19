--- Login
-- Authenticates users via username to access a door
-- @Author: Brodur
-- @Version: 2.0
-- @Requires: menu.lua, serialutils.lua

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
local configDir = "/home/users.lua"

local privs = {
  [1] = false, 
  [2] = true, 
  admin = true, 
  user = false 
}

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

--- Print Users
-- Print all of the users
function printUsers()
  print("Users:")
  for user,priv in pairs(users) do
    print(" - " .. user, priv and "[Admin]" or "[User]")
  end
  print("\nPress enter to continue...")
  term.read()
end

--- Add Trusted Player
-- Adds a trusted player to the door.
-- @param player	The player to add.
-- @param isAdmin Whether the player should be an admin or not
function addTrustedPlayer(player, isAdmin)
  if users[player] ~= nil then error("Cannot add a user that already exists!") end
  users[player] = isAdmin
end

--- Add trusted player menu
-- Dialog for adding a trusted player.
function addTrustedPlayerMenu()
  term.write("Add a trusted player: ")
  local player  = trim(term.read())
  local usrType = menu.dialog("User or Admin?", "User", "Admin")
  local confirm = menu.dialog("Add \'" .. player .. "\' as " .. usrType==1 and "User" or "Admin" .." to door?", "Confirm", "Cancel")
  if confirm == 1 then
    addTrustedPlayer(player, privs[usrType])
  end
end

--- Remove Trusted Player
-- Removes a user from the trusted players list.
-- @param player  The user to remove.
function removeTrustedPlayer(player)
  users[player] = nil
end

--- Remove trusted player menu
-- Dialog to remove a trusted user.
function removeTrustedPlayerMenu()
  local userList = {"Cancel"}
  for username,_ in pairs(users) do userList[#userList+1] = username end
  local select = -1
  while select ~= 1 do
    select = menu.list(userList, "Select a user")
    if select ~= 1 then
      local player = userList[select]
      local confirm = menu.dialog("Remove \'" .. player .. "\' from trusted users?", "Confirm", "Cancel")
      if confirm == 1 then 
        removeTrustedPlayer(player)
        table.remove(userList, select)
      end
    end
  end
end

--- manage
-- Menu for various management functions
function manage()
  local opt = -1
  while opt ~= #menuOpts do
    opt = menu.list(menuOpts, "Management Menu")
    if opt == #menuOpts then watching = false break end --Exit program
    if opt == #menuOpts - 1 then break end --Return to login
    if opt == 1 then 
      printUsers()
    end
    if opt == 2 then 
      addTrustedPlayerMenu()
    end
    if opt == 3 then
      removeTrustedPlayerMenu()
    end
  end
end

--- Load Config
-- Loads the configuration from file
function loadConfig()
  if not fs.exists(configDir) then
    noConfig()
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
    if users[user] ~= nil then
      if key == 184 or key == 29 and users[user] then --press R-ALT or UK R-Alt, which equates to L-Control
        computer.beep(200)
        manage()
        computer.beep(100)
      else
        computer.beep(600)
        print("Welcome", user)
        openClose()
        computer.beep(500, 0.5)
      end
    else
      print("Not welcome", user)
      computer.beep(400)
    end
  end
  computer.beep(1000)
  sz.save(users, configDir)
end

--- noConfig
-- First time or no config present wizard
-- Adds the user that hits the prompt as admin.
function noConfig()
  noConfigBeep()
  print("No config able to be loaded from: " .. configDir)
  print("Fisrt run wizard: Please press any key to register your username...")
  _,_,_,_,user = event.pull("key_down")
  print("Got: " .. user)
  addTrustedPlayer(user, privs.admin)
  printUsers()
  sz.save(users, configDir)
end

--- No config beep
-- Beep function for no config present.
function noConfigBeep()
  computer.beep(1000, 0.25)
  os.sleep(0.1)
  computer.beep(1000, 0.25)
  os.sleep(0.1)
  computer.beep(1000, 0.25)
end

program_loaded()