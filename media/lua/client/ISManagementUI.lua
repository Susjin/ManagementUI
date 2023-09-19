----------------------------------------------------------------------------------------------
--- ManagementUI
--- @author: peteR_pg
--- Steam profile: https://steamcommunity.com/id/peter_pg/
--- GitHub Repository: https://github.com/Susjin/ManagementUI

--- Main file with all functions related to creating the ManagementPanel
--- @class ISManagementUI
--- @field character IsoPlayer
--- @field playerNum number
--- @field maxButtons number
--- @field pages number
--- @field maxObjects number
--- @field ignoreScreenWidth boolean
--- @field objectList any[]
--- @field numObjects number
--- @field x number
--- @field y number
--- @field width number
--- @field height number
--- @field
local ISManagementUI = {}
----------------------------------------------------------------------------------------------
-- ------ Declaring Classes ------ --
--- @class PreUIObject
--- @field id number Index of this object
--- @field name string Name of this object (can use RichText tags)
--- @field description string Description of this object (can use RichText tags)
--- @field squarePos table<string,number> Square XYZ of the object (table have x, y and z indexes)
--- @field objectType string Instance of the object being used. e.g. IsoThumpable
--- @field numButtons number Number of buttons this object have. (min 2, max 6)
--- @field buttonNames string[] Ordered table with each position being a button's name respectively
--- @field onClickButton function Function that will trigger on every clicked button (Use 'if' and 'elseif' with the button names)
--- @field param1 any Can be any extra parameters used with the 'onClickButton' function
--- @field param2 any Can be any extra parameters used with the 'onClickButton' function
--- @field param3 any Can be any extra parameters used with the 'onClickButton' function
--- @field param4 any Can be any extra parameters used with the 'onClickButton' function
--- @field param5 any Can be any extra parameters used with the 'onClickButton' function
--- @field param6 any Can be any extra parameters used with the 'onClickButton' function

-- ------ Setting up Locals ------ --
local ISManagementPanel = require "ISManagementPanel"

local maxButtonsSheet = {320, 320, 400, 400, 480, 480}
local maxObjectsSheet = { 444, 444, 444, 444, 544, 644, 744, 844}


function ISManagementUI:setupDimensions()
    self.x = getPlayerScreenLeft(self.playerNum) + 100
    self.y = getPlayerScreenTop(self.playerNum) + 50

    local playerWidth = getPlayerScreenWidth(self.playerNum)
    local playerHeight = getPlayerScreenHeight(self.playerNum)
    local screenMaxButtons = 0
    local screenMaxObjects = 0

    --Width of the panel
    if self.maxButtons < 2 then
        self.maxButtons = 2
    elseif self.maxButtons > 6 then
        self.maxButtons = 6
    end
    if not self.ignoreScreenWidth then
        if playerWidth > 960 then
            screenMaxButtons = 6
        elseif playerWidth > 800 then
            screenMaxButtons = 4
        else
            screenMaxButtons = 2
        end
        if screenMaxButtons < self.maxButtons then
            self.maxButtons = screenMaxButtons
        end
    end
    self.width = maxButtonsSheet[self.maxButtons]

    --Height of the panel
    if self.maxObjects < 4 then
        self.maxObjects = 4
    elseif self.maxObjects > 8 then
        self.maxObjects = 8
    end
    if playerHeight > 1200 then
        screenMaxObjects = 8
    elseif playerHeight > 1000 then
        screenMaxObjects = 6
    else
        screenMaxObjects = 4
    end
    if screenMaxObjects < self.maxObjects then
        self.maxObjects = screenMaxObjects
    end
    self.height = maxObjectsSheet[self.maxObjects]

end

function ISManagementUI:calculatePages()
    local pages = self.numObjects/self.maxObjects
    pages = pages > 0 and math.ceil(pages) or 0
    self.pages = pages
end

---Allocates a object before being added to the UI
---@param name string Name of this object (can use RichText tags)
---@param description string Description of this object (can use RichText tags)
---@param squarePos table<string,number> Square XYZ of the object (table have x, y and z indexes)
---@param objectType string Instance of the object being used. e.g. IsoThumpable
---@param numButtons number Number of buttons this object have. (min 2, max 6)
---@param buttonNames string[] Ordered table with each position being a button's name respectively
---@param onClickButton function Function that will trigger on every clicked button (Use 'if' and 'elseif' with the button names)
---@param param1 any Can be any extra parameters used with the 'onClickButton' function
---@param param2 any Can be any extra parameters used with the 'onClickButton' function
---@param param3 any Can be any extra parameters used with the 'onClickButton' function
---@param param4 any Can be any extra parameters used with the 'onClickButton' function
---@param param5 any Can be any extra parameters used with the 'onClickButton' function
---@param param6 any Can be any extra parameters used with the 'onClickButton' function
---@return PreUIObject
function ISManagementUI:allocObject(name, description, squarePos, objectType, numButtons, buttonNames, onClickButton, param1, param2, param3, param4, param5, param6)
    ---@type PreUIObject
    local object = {}
    object.id = self.numObjects
    object.name = name
    object.description = description
    object.squarePos = squarePos
    object.objectType = objectType
    object.numButtons = numButtons
    object.buttonNames = buttonNames
    object.onClickButton = onClickButton
    object.param1 = param1
    object.param2 = param2
    object.param3 = param3
    object.param4 = param4
    object.param5 = param5
    object.param6 = param6

    return object
end

---Adds a object to the list before being added to the UI
---@param name string Name of this object (can use RichText tags)
---@param description string Description of this object (can use RichText tags)
---@param squarePos table<string,number> Square XYZ of the object (table have x, y and z indexes)
---@param objectType string Instance of the object being used. e.g. IsoThumpable
---@param numButtons number Number of buttons this object have. (min 2, max 6)
---@param buttonNames string[] Ordered table with each position being a button's name respectively
---@param onClickButton function Function that will trigger on every clicked button (Use 'if' and 'elseif' with the button names)
---@param param1 any Can be any extra parameters used with the 'onClickButton' function
---@param param2 any Can be any extra parameters used with the 'onClickButton' function
---@param param3 any Can be any extra parameters used with the 'onClickButton' function
---@param param4 any Can be any extra parameters used with the 'onClickButton' function
---@param param5 any Can be any extra parameters used with the 'onClickButton' function
---@param param6 any Can be any extra parameters used with the 'onClickButton' function
---@return PreUIObject
function ISManagementUI:addObject(name, description, squarePos, objectType, numButtons, buttonNames, onClickButton, param1, param2, param3, param4, param5, param6)
    ---@type PreUIObject
    local object = self:allocOption(name, description, squarePos, objectType, numButtons, buttonNames, onClickButton, param1, param2, param3, param4, param5, param6);

    self.objectList[self.numObjects] = object;
    self.numObjects = self.numObjects + 1;
    self:calculatePages()

    return object;
end

function ISManagementUI:addObjectOnTop()

end

function ISManagementUI:addObjectAfter()

end

function ISManagementUI:addObjectBefore()

end

function ISManagementUI:removeLastObject()

end

function ISManagementUI:removeObjectByName()

end

function ISManagementUI:getObjectByName()

end

---initialiseManagementUI
---@param player IsoPlayer
---@param maxObjects number
---@param maxButtons number
function ISManagementUI:initialiseManagementUI(player, maxObjects, maxButtons, ignoreScreenWidth)
    local o = {}
    o.character = player
    o.playerNum = player:getPlayerNum()

    o.objectList = {}
    o.numObjects = 1

    o.maxObjects = maxObjects
    o.maxButtons = maxButtons
    o.pages = 0

    o.ignoreScreenWidth = ignoreScreenWidth

end



------------------ Returning file for 'require' ------------------
return ISManagementUI