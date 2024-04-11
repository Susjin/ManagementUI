----------------------------------------------------------------------------------------------
--- ManagementUI
--- @author: peteR_pg
--- Steam profile: https://steamcommunity.com/id/peter_pg/
--- GitHub Repository: https://github.com/Susjin/ManagementUI

--- Main file with all functions related to the buttons of objects inside a Management Panel
--- @class ObjectButtons
local ObjectButtons = {}
----------------------------------------------------------------------------------------------
--- @class ManagementUIObjectProperties
--- @field buttonNames String[] A table containing the names (max 10 characters per name) for each button in a index. Also defines the amount of buttons
--- @field func function The function that is executed every time a button in clicked on

-- - In this file, you need to declare a function that will be executed
-- - when a button of a specific type of object is clicked.
-- -
-- - First, a table needs to be created on this Class where the index
-- - name is the same as the Object Type, and inside this table, two
-- - variables, one is a table named 'buttonNames' containing a name
-- - and count for/of all buttons, and the other named 'function',
-- - which is where the OnCLick function will be stored.
-- -
-- - Here's a Example:
-- - ObjectButtons.IsoThumpable = {}
-- - ObjectButtons.IsoThumpable.buttonNames = {"Open/Close", "Lock/Unlock"}
-- - ObjectButtons.IsoThumpable.func = function(thumpable, button, player)
-- -     if button.internal == ObjectButtons.IsoThumpable.buttonNames[1] then
-- -         thumpable:ToggleDoor(player)
-- -     elseif button.internal == ObjectButtons.IsoThumpable.buttonNames[2] then
-- -         if thumpable:isLockedByKey() then
-- -             thumpable:setLockedByKey(false)
-- -         else
-- -             thumpable:setLockedByKey(true)
-- -         end
-- -     end
-- - end
-- -
-- - Use and develop using the pattern above to each Object
-- - Type you want to use in your Management Panel












------------------ Returning file for 'require' ------------------
return ObjectButtons