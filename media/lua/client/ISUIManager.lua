----------------------------------------------------------------------------------------------
--- ManagementUI
--- @author: peteR_pg
--- Steam profile: https://steamcommunity.com/id/peter_pg/
--- GitHub Repository: https://github.com/Susjin/ManagementUI

--- Main file with all functions related to creating the ManagementPanel
--- @class ISUIManager
--- @field character IsoPlayer
--- @field playerNum number
--- @field maxButtons number
--- @field numPages number
--- @field maxObjects number
--- @field ignoreScreenWidth boolean
--- @field objects PreUIObject[]
--- @field validatedObjects PreUIObject[]
--- @field numObjects number
--- @field x number
--- @field y number
--- @field width number
--- @field height number
--- @field panel ISManagementPanel
--- @field
local ISUIManager = {}
----------------------------------------------------------------------------------------------
-- ------ Declaring Classes ------ --
--- @class PreUIObject
--- @field id number Index of this object
--- @field isoObject IsoObject The object that is in that square
--- @field name string Name of this object (can use RichText tags)
--- @field description string Description of this object (can use RichText tags)
--- @field squarePos table<string,number> Square XYZ of the object (table must have x, y and z indexes)
--- @field objectType string Instance of the object being used. e.g. IsoThumpable
--- @field numButtons number Number of buttons this object has. (min 2, max 6)
--- @field buttonNames string[] Ordered table with each position being a button's name respectively
--- @field onClickButton function Function that will trigger on every clicked button (Use 'if' and 'elseif' with the button names)
--- @field param1 any Can be any extra parameters used with the 'onClickButton' function
--- @field param2 any Can be any extra parameters used with the 'onClickButton' function
--- @field param3 any Can be any extra parameters used with the 'onClickButton' function
--- @field param4 any Can be any extra parameters used with the 'onClickButton' function

-- ------ Setting up Locals ------ --
local ISManagementPanel = require "ISManagementPanel"

local maxButtonsSheet = {320, 320, 400, 400, 480, 480}
local maxObjectsSheet = { 444, 444, 444, 444, 544, 644, 744, 844}

local pairs = pairs
local getCell = getCell

--[[**********************************************************************************]]--

------------------ Functions related to creation of the UI ------------------

function ISUIManager:setupDimensions()
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

function ISUIManager:validateObjects()
    local newObjects = {}

    ---@param obj PreUIObject
    for _, obj in pairs(self.objects) do
        local objectSquare = getCell():getGridSquare(obj.squarePos.x, obj.squarePos.y, obj.squarePos.z)
        if objectSquare then
            local squareObjects = objectSquare:getObjects()
            for i=0, squareObjects:size()-1 do
                if instanceof(squareObjects:get(i), obj.objectType) then
                    obj.isoObject = squareObjects:get(i)
                end
            end
        end
        if obj.isoObject ~= nil then
            table.insert(newObjects, obj)
        end
    end

    self.validatedObjects = newObjects
end

--[[**********************************************************************************]]--

------------------ Functions related to managing objects ------------------

function ISUIManager:calculatePages()
    local pages = self.numObjects/self.maxObjects
    pages = pages > 0 and math.ceil(pages) or 0
    self.numPages = pages
end

---Allocates a object before being added to the UI
---@param name string Name of this object (can use RichText tags)
---@param description string Description of this object (can use RichText tags)
---@param squarePos table<string,number> Square XYZ of the object (table must have x, y and z indexes)
---@param objectType string Instance of the object being used. e.g. IsoThumpable
---@param numButtons number Number of buttons this object has. (min 2, max 6)
---@param buttonNames string[] Ordered table with each position being a button's name respectively
---@param onClickButton function Function that will trigger on every clicked button (Use 'if' and 'elseif' with the button names)
---@param param1 any Can be any extra parameters used with the 'onClickButton' function
---@param param2 any Can be any extra parameters used with the 'onClickButton' function
---@param param3 any Can be any extra parameters used with the 'onClickButton' function
---@param param4 any Can be any extra parameters used with the 'onClickButton' function
---@return PreUIObject
function ISUIManager:allocObject(name, description, squarePos, objectType, numButtons, buttonNames, onClickButton, param1, param2, param3, param4)
    ---@type PreUIObject
    local object = {}
    object.isoObject = nil
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

    return object
end

---Adds a object to the list before being added to the UI
---@param name string Name of this object (can use RichText tags)
---@param description string Description of this object (can use RichText tags)
---@param squarePos table<string,number> Square XYZ of the object (table must have x, y and z indexes)
---@param objectType string Instance of the object being used. e.g. IsoThumpable
---@param numButtons number Number of buttons this object has. (min 2, max 6)
---@param buttonNames string[] Ordered table with each position being a button's name respectively
---@param onClickButton function Function that will trigger on every clicked button (Use 'if' and 'elseif' with the button names)
---@param param1 any Can be any extra parameters used with the 'onClickButton' function
---@param param2 any Can be any extra parameters used with the 'onClickButton' function
---@param param3 any Can be any extra parameters used with the 'onClickButton' function
---@param param4 any Can be any extra parameters used with the 'onClickButton' function
---@return PreUIObject
function ISUIManager:addObject(name, description, squarePos, objectType, numButtons, buttonNames, onClickButton, param1, param2, param3, param4)
    local object = self:allocObject(name, description, squarePos, objectType, numButtons, buttonNames, onClickButton, param1, param2, param3, param4);

    self.objects[self.numObjects] = object;
    self.numObjects = self.numObjects + 1;
    self:calculatePages()

    return object;
end

---Adds a object on top of the list before being added to the UI
---@param name string Name of this object (can use RichText tags)
---@param description string Description of this object (can use RichText tags)
---@param squarePos table<string,number> Square XYZ of the object (table must have x, y and z indexes)
---@param objectType string Instance of the object being used. e.g. IsoThumpable
---@param numButtons number Number of buttons this object has. (min 2, max 6)
---@param buttonNames string[] Ordered table with each position being a button's name respectively
---@param onClickButton function Function that will trigger on every clicked button (Use 'if' and 'elseif' with the button names)
---@param param1 any Can be any extra parameters used with the 'onClickButton' function
---@param param2 any Can be any extra parameters used with the 'onClickButton' function
---@param param3 any Can be any extra parameters used with the 'onClickButton' function
---@param param4 any Can be any extra parameters used with the 'onClickButton' function
---@return PreUIObject
function ISUIManager:addObjectOnTop(name, description, squarePos, objectType, numButtons, buttonNames, onClickButton, param1, param2, param3, param4)
    local newObjects = {};
    for _, object in pairs(self.objects) do
        object.id = object.id + 1;
        newObjects[object.id] = object;
    end

    self.objects = newObjects;
    local object = self:allocObject(name, description, squarePos, objectType, numButtons, buttonNames, onClickButton, param1, param2, param3, param4);
    object.id = 1;
    self.objects[1] = object;
    self.numObjects = self.numObjects + 1;
    self:calculatePages()
    return object;
end

---Gets a object by it's given name. If object don't exist, return nil
---@param name string Object name
---@return PreUIObject
function ISUIManager:getObjectByName(name)
    for _, object in pairs(self.objects) do
        if object.name == name then
            return object
        end
    end
    return nil
end

---Gets a object by it's given name. If object don't exist, return nil
---@param index number Object's index on the list
---@return PreUIObject
function ISUIManager:getObjectByIndex(index)
    for _, object in pairs(self.objects) do
        if object.id == index then
            return object
        end
    end
    return nil
end

---Adds a object after another object on the list before being added to the UI
---@param previousName string Name of the object that will be placed before this (can use RichText tags)
---@param name string Name of this object (can use RichText tags)
---@param description string Description of this object (can use RichText tags)
---@param squarePos table<string,number> Square XYZ of the object (table must have x, y and z indexes)
---@param objectType string Instance of the object being used. e.g. IsoThumpable
---@param numButtons number Number of buttons this object has. (min 2, max 6)
---@param buttonNames string[] Ordered table with each position being a button's name respectively
---@param onClickButton function Function that will trigger on every clicked button (Use 'if' and 'elseif' with the button names)
---@param param1 any Can be any extra parameters used with the 'onClickButton' function
---@param param2 any Can be any extra parameters used with the 'onClickButton' function
---@param param3 any Can be any extra parameters used with the 'onClickButton' function
---@param param4 any Can be any extra parameters used with the 'onClickButton' function
---@return PreUIObject
function ISUIManager:addObjectAfter(previousName, name, description, squarePos, objectType, numButtons, buttonNames, onClickButton, param1, param2, param3, param4)
    local previousObject = self:getObjectByName(previousName)
    if not previousObject then
        print("ManagementUI: Previous object not found: " .. previousName)
        return self:addObject(name, description, squarePos, objectType, numButtons, buttonNames, onClickButton, param1, param2, param3, param4)
    end


    local index = previousObject.id
    for i = #self.objects, index+1, -1 do
        self.objects[i+1] = self.objects[i]
    end

    local object = self:allocObject(name, description, squarePos, objectType, numButtons, buttonNames, onClickButton, param1, param2, param3, param4);
    object.id = index+1;
    self.objects[index+1] = object;
    self.numObjects = self.numObjects + 1;

    for i, obj in pairs(self.objects) do
        obj.id = i
    end

    self:calculatePages()
    return object
end

---Adds a object before another object on the list before being added to the UI
---@param nextName string Name of the object that will be placed after this (can use RichText tags)
---@param name string Name of this object (can use RichText tags)
---@param description string Description of this object (can use RichText tags)
---@param squarePos table<string,number> Square XYZ of the object (table must have x, y and z indexes)
---@param objectType string Instance of the object being used. e.g. IsoThumpable
---@param numButtons number Number of buttons this object has. (min 2, max 6)
---@param buttonNames string[] Ordered table with each position being a button's name respectively
---@param onClickButton function Function that will trigger on every clicked button (Use 'if' and 'elseif' with the button names)
---@param param1 any Can be any extra parameters used with the 'onClickButton' function
---@param param2 any Can be any extra parameters used with the 'onClickButton' function
---@param param3 any Can be any extra parameters used with the 'onClickButton' function
---@param param4 any Can be any extra parameters used with the 'onClickButton' function
---@return PreUIObject
function ISUIManager:addObjectBefore(nextName, name, description, squarePos, objectType, numButtons, buttonNames, onClickButton, param1, param2, param3, param4)
    local nextObject = self:getObjectByName(nextName)
    if not nextObject then
        print("ManagementUI: Next object not found: " .. nextName)
        return self:addObject(name, description, squarePos, objectType, numButtons, buttonNames, onClickButton, param1, param2, param3, param4)
    end
    local index = nextObject.id


    if index == 1 then
        return self:addObjectOnTop(name, description, squarePos, objectType, numButtons, buttonNames, onClickButton, param1, param2, param3, param4)
    end

    for i = #self.objects, index, -1 do
        self.objects[i+1] = self.objects[i]
    end

    local object = self:allocObject(name, description, squarePos, objectType, numButtons, buttonNames, onClickButton, param1, param2, param3, param4);
    object.id = index;
    self.objects[index] = object;
    self.numObjects = self.numObjects + 1;

    for i, obj in pairs(self.objects) do
        obj.id = i
    end

    self:calculatePages()
    return object
end

function ISUIManager:addObjectAtIndex(index, name, description, squarePos, objectType, numButtons, buttonNames, onClickButton, param1, param2, param3, param4)
    if #self.objects < index then
        print("ManagementUI: Number of objects is smaller than: " .. index)
        return self:addObject(name, description, squarePos, objectType, numButtons, buttonNames, onClickButton, param1, param2, param3, param4)
    end

    if index == 1 then
        return self:addObjectOnTop(name, description, squarePos, objectType, numButtons, buttonNames, onClickButton, param1, param2, param3, param4)
    end

    for i = #self.objects, index, -1 do
        self.objects[i+1] = self.objects[i]
    end

    local object = self:allocObject(name, description, squarePos, objectType, numButtons, buttonNames, onClickButton, param1, param2, param3, param4);
    object.id = index;
    self.objects[index] = object;
    self.numObjects = self.numObjects + 1;

    for i, obj in pairs(self.objects) do
        obj.id = i
    end

    self:calculatePages()
    return object
end

---Removes a given object from the list by it's given name before being added to the UI
---@param removeName string Name of the object to be removed (can use RichText tags)
function ISUIManager:removeObjectByName(removeName)
    local removeObject = self:getObjectByName(removeName)
    if not removeObject then
        print("ManagementUI: Object to remove not found: " .. removeName)
        return false
    end

    local index = removeObject.id
    for i = index+1, #self.objects do
        self.objects[i-1] = self.objects[i]
        self.objects[i-1].id = i-1
    end
    self.objects[#self.objects] = nil
    self.numObjects = self.numObjects - 1
    self:calculatePages()
    return true
end

---Removes the last object on the list before being added to the UI
function ISUIManager:removeLastObject()
    self.objects[self.numObjects - 1] =  nil;
    self.numObjects = self.numObjects -1;
    self:calculatePages()
end

function ISUIManager:getAllObjectsNames()
    local names = {}
    for i, obj in pairs(self.objects) do
        names[i] = obj.name
    end
    return names
end

--[[**********************************************************************************]]--

---Initialize the ManagementUI Manager
---@param player IsoPlayer
---@param maxObjects number
---@param maxButtons number
---@param ignoreScreenWidth boolean
---@return PreUIObject
function ISUIManager:initialiseUIManager(player, maxObjects, maxButtons, ignoreScreenWidth)
    local o = {}
    o.x = 0
    o.y = 0
    o.width = 0
    o.maxButtons = maxButtons
    o.height = 0
    o.maxObjects = maxObjects
    o.numPages = 0
    o.objects = {}
    o.validatedObjects = {}
    o.numObjects = 1
    o.character = player
    o.playerNum = player:getPlayerNum()
    o.ignoreScreenWidth = ignoreScreenWidth

    o.panel = {}

    return o
end



------------------ Returning file for 'require' ------------------
return ISUIManager