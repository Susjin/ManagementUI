----------------------------------------------------------------------------------------------
--- ManagementUI
--- @author: peteR_pg
--- Steam profile: https://steamcommunity.com/id/peter_pg/
--- GitHub Repository: https://github.com/Susjin/ManagementUI

--- Main file with all functions related to creating the ManagementPanel
--- @class ISUIManager
--- @field title string
--- @field maxButtons number
--- @field numPages number
--- @field maxObjects number
--- @field ignoreScreenWidth boolean
--- @field showAllObjects boolean If true, show all objects, even not validated ones
--- @field refreshOnChange boolean If true, the panel will refresh the objects upon adding or removing a object from to manager
--- @field noObjectsMessage string Message to be shown in the Tabs when there's no objects (320 character max)
--- @field objects PreUIObject[]
--- @field validatedObjects PreUIObject[]
--- @field numObjects number
--- @field x number
--- @field y number
--- @field width number
--- @field height number
--- @field panel ISManagementPanel
local ISUIManager = {}
----------------------------------------------------------------------------------------------
-- ------ Declaring Classes ------ --
--- @class PreUIObject
--- @field id number Index of this object
--- @field isoObject IsoObject The object that is in that square
--- @field name string Name of this object (can use RichText tags)
--- @field description string Description of this object (can use RichText tags)
--- @field textureName string Texture name of the object
--- @field squarePos table<string,number> Square XYZ of the object (table must have x, y and z indexes)
--- @field objectType string Instance of the object being used. e.g. IsoThumpable
--- @field numButtons number Number of buttons this object has. (min 2, max 6)
--- @field buttonNames string[] Ordered table with each position being a button's name respectively
--- @field onClickButton function Function that will trigger on every clicked button (Use 'if' and 'elseif' with the button names)
--- @field param1 any Can be any extra parameters used with the 'onClickButton' function
--- @field param2 any Can be any extra parameters used with the 'onClickButton' function
--- @field param3 any Can be any extra parameters used with the 'onClickButton' function
--- @field param4 any Can be any extra parameters used with the 'onClickButton' function

-- Testing ms lag:
--[[
During tests, using 60 objects at the same time, totalling 10 pages worth of objects,
including all 6 buttons each, totalling 360 buttons, 60 description boxes and 60 textures renderers.
The game needed 34ms to create everything said on my computer, the results may vary from each machine.
--]]
-- ------ Setting up Locals ------ --
local ISManagementPanel = require "ISManagementPanel"

local numButtonsSheet = { 320, 320, 400, 400, 480, 480}
local numObjectsSheet = { 436, 436, 436, 436, 536, 636, 736, 836}

local pairs = pairs
local getCell = getCell

--[[**********************************************************************************]]--

------------------ Functions related to saving/loading the manager ------------------

---Reloads all information of the ISUIManager from another manager table
---@param managerTable ISUIManager
---@return ISUIManager
function ISUIManager:reloadFromTable(managerTable)
    local o = self:initialiseUIManager(managerTable.title, managerTable.maxObjects, managerTable.maxButtons, managerTable.ignoreScreenWidth, managerTable.showAllObjects, managerTable.refreshOnChange, managerTable.noObjectsMessage)
    o.numPages = managerTable.numPages
    o.objects = managerTable.objects
    o.numObjects = managerTable.numObjects
    o.x = managerTable.x
    o.y = managerTable.y
    o.width = managerTable.width
    o.height = managerTable.height

    return o
end



--[[**********************************************************************************]]--

------------------ Functions related to creation of the UI ------------------

function ISUIManager:setupDimensions(player)
    local playerNum = player:getPlayerNum()

    local playerWidth = getPlayerScreenWidth(playerNum)
    local playerHeight = getPlayerScreenHeight(playerNum)
    local screenMaxButtons = 0
    local screenMaxObjects = 0

    --Width of the panel
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
    self.width = numButtonsSheet[self.maxButtons]

    --Height of the panel
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
    self.height = numObjectsSheet[self.maxObjects]

    if self.x == 0 then self.x = getPlayerScreenLeft(playerNum) + 100 end
    if self.y == 0 then self.y = getPlayerScreenHeight(playerNum) - self.height - 100 end
end

function ISUIManager:createManagementPanel(player, showAllObjects)
    self:setupDimensions(player)
    self:validateObjects()

    self.panel = ISManagementPanel:new(self.title, self.x, self.y, self.width, self.height, player, self, showAllObjects)
    self.panel:initialise()
    self.panel:instantiate()
    self.panel:setResizable(false)
    self.panel:addToUIManager()

end

function ISUIManager:nullifyEverythingForSaving()
    for _, data in pairs(self.objects) do
        data.isoObject = nil
    end
    for _, data in pairs(self.validatedObjects) do
        data.isoObject = nil
    end
    self.panel = nil
end

--[[**********************************************************************************]]--

------------------ Functions related to managing objects ------------------

---Calculates all necessary pages to fit all objects
function ISUIManager:calculatePages()
    local pages = #self.objects/self.maxObjects
    self.numPages = pages > 0 and math.ceil(pages) or 0
end

---Checks if all objects to be added to the UI are correctly loaded in the world, allowing them to show on the interface
function ISUIManager:validateObjects()
    local newObjects = {}
    ---@param obj PreUIObject
    for _, obj in pairs(self.objects) do
        obj.isoObject = nil
        local objectSquare = getCell():getGridSquare(obj.squarePos.x, obj.squarePos.y, obj.squarePos.z)
        if objectSquare then
            local squareObjects = objectSquare:getObjects()
            for i=0, squareObjects:size()-1 do
                if instanceof(squareObjects:get(i), obj.objectType) and obj.numButtons <= self.maxButtons then
                    obj.isoObject = squareObjects:get(i)
                    obj.textureName = obj.isoObject:getTextureName()
                end
            end
        end
        if obj.isoObject ~= nil then
            table.insert(newObjects, obj)
        end
    end

    self.validatedObjects = newObjects
    self:calculateValidatedPages()
end

---Calculates all necessary pages to fit all validated objects
function ISUIManager:calculateValidatedPages()
    local pages = #self.validatedObjects/self.maxObjects
    self.numPages = pages > 0 and math.ceil(pages) or 0
end

function ISUIManager:autoRefresh()
    if self.panel and self.panel:isVisible() then
        self.panel:refreshObjects()
    end
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
---@return PreUIObject A object ready to be added to the list
function ISUIManager:allocObject(name, description, squarePos, objectType, numButtons, buttonNames, onClickButton, param1, param2, param3, param4)
    ---@type PreUIObject
    local object = {}
    object.isoObject = nil
    object.id = self.numObjects
    object.name = name
    object.description = description
    object.textureName = nil
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
---@return PreUIObject A pointer to the object added
function ISUIManager:addObject(name, description, squarePos, objectType, numButtons, buttonNames, onClickButton, param1, param2, param3, param4)
    local object = self:allocObject(name, description, squarePos, objectType, numButtons, buttonNames, onClickButton, param1, param2, param3, param4);

    self.objects[self.numObjects] = object;
    self.numObjects = self.numObjects + 1;

    self:calculatePages()
    if self.refreshOnChange then self:autoRefresh() end
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
---@return PreUIObject A pointer to the object added
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
    if self.refreshOnChange then self:autoRefresh() end
    return object;
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
---@return PreUIObject A pointer to the object added
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
    if self.refreshOnChange then self:autoRefresh() end
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
---@return PreUIObject A pointer to the object added
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
    if self.refreshOnChange then self:autoRefresh() end
    return object
end
---Adds a object at a specified index position related to all other objects
---@param index number Index that this object will be added to (can use RichText tags)
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
---@return PreUIObject A pointer to the object added
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
    if self.refreshOnChange then self:autoRefresh() end
    return object
end

---Removes a given object from the list by it's given name before being added to the UI
---@param removeName string Name of the object to be removed (can use RichText tags)
---@return boolean Returns true if correctly removed, false if not
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
    if self.refreshOnChange then self:autoRefresh() end
    return true
end

---Removes the last object on the list before being added to the UI
function ISUIManager:removeLastObject()
    self.objects[self.numObjects - 1] =  nil;
    self.numObjects = self.numObjects -1;
    self:calculatePages()
end

---Gets a object by it's given name. If object don't exist, return nil
---@param name string Object's name
---@return PreUIObject A pointer to the object
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
---@return PreUIObject A pointer to the object
function ISUIManager:getObjectByIndex(index)
    for _, object in pairs(self.objects) do
        if object.id == index then
            return object
        end
    end
    return nil
end

---Gets a table containing all objects names
---@return string[] Table containing all names
function ISUIManager:getAllObjectsNames()
    local names = {}
    for i, obj in pairs(self.objects) do
        names[i] = obj.name
    end
    return names
end

--[[**********************************************************************************]]--

---Sets all values from max buttons and objects, so that it's always: (6 >= n >= 2)
function ISUIManager:correctMaximumValues()
    --Set minimum and maximum buttons
    if self.maxButtons < 2 then
        self.maxButtons = 2
    elseif self.maxButtons > 6 then
        self.maxButtons = 6
    end
    --Set minimum and maximum objects
    if self.maxObjects < 4 then
        self.maxObjects = 4
    elseif self.maxObjects > 8 then
        self.maxObjects = 8
    end
end

---Initialize the ManagementUI Manager
---@param title string The title of the UI that this manager will handle
---@param maxObjects number Maximum amount of objects per page (min 4, max 8)
---@param maxButtons number Maximum amount of buttons per object (min 2, max 6)
---@param ignoreScreenWidth boolean If true, width calculations will ignore the current resolution, if false, it may reduce the max amount of buttons if the screen is too small (only affects resolutions lower than 1024x768)
---@param showAllObjects boolean If true, show all objects, even not validated ones
---@param refreshOnChange boolean If true, the panel will refresh the objects upon adding or removing a object from to manager
---@param noObjectsMessage string Message to be shown in the Tabs when there's no objects (320 character max)
---@return ISUIManager
function ISUIManager:initialiseUIManager(title, maxObjects, maxButtons, ignoreScreenWidth, showAllObjects, refreshOnChange, noObjectsMessage)
    ---@type ISUIManager
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.title = title
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
    o.ignoreScreenWidth = ignoreScreenWidth or false
    o.showAllObjects = showAllObjects or false
    o.refreshOnChange = refreshOnChange or true
    o.noObjectsMessage = noObjectsMessage or "teteNo Objects"

    o.panel = nil

    o:correctMaximumValues()
    return o
end



------------------ Returning file for 'require' ------------------
return ISUIManager