local sz = require("serialization")
local io = require("io")

local serialutils = {}

--- Save
-- Save the contents of given table to a file.
-- @param tbl  The table to save.
-- @param dir  Where to save the table.
function serialutils.save(tbl, dir)
    file = io.open(dir, "w")
    file:write(sz.serialize(tbl))
    file:close()
end
  
  --- Load 
  -- Loads the serialized database from file.
  -- @param dir  The directory where the database is located.
  -- @return The parsed serial table.
function serialutils.load(dir)
    str = ""
    for line in io.lines(dir) do str = str .. line end
    return sz.unserialize(str)
end
  
return serialutils