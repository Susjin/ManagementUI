
----------------------------------------------------------------------------------------------
--- ManagementUI
--- @author: peteR_pg
--- Steam profile: https://steamcommunity.com/id/peter_pg/
--- GitHub Repository: https://github.com/Susjin/ManagementUI

--- Main file with all functions related to a object on the ManagementUI
--- @class ISManagementObject : ISPanelJoypad
--- @field id number ID of this object on the manager
--- @field isoObject IsoObject The IsoObject that is being targeted by this object
--- @field objectType String Instance of the object being used. e.g. IsoThumpable
--- @field texture Texture The Texture of the IsoObject to be rendered
--- @field name string Name of this object (can use RichText tags)
--- @field description string Description of this object (can use RichText tags)
--- @field numButtons number Number of buttons this object has. (max 6)
--- @field buttons ISButton[] Ordered table with each position being a ISButton
--- @field buttonNames string[] Ordered table with each position being a button's name respectively
--- @field onClickButton function Function that will trigger on every clicked button (Use 'if' and 'elseif' with the button names)
--- @field character IsoPlayer Object of the player that is interacting with the UI Panel
--- @field descriptionPanel ISRichTextPanel The RichText panel that is placed after the texture
--- @field manager ISUIManager
local ISManagementObject = {}
----------------------------------------------------------------------------------------------
-- ------ Inherent from ISPanelJoypad -- ------
ISManagementObject = ISPanelJoypad:derive("ISManagementObject")

-- - Setting up Locals
local ObjectButtons = require("ISManagementObjectButtons")



-- ------ Fixing the vanilla 'setOnClick' ISButton function -- ------
local _ = ISButton.setOnClick
function ISButton:setOnClick(func, arg1, arg2, arg3, arg4)
    self.onclick = func
    self.onClickArgs = { arg1, arg2, arg3, arg4 }
end

-- ------ Setting up locals -- ------
local function checkButtonPosXByID(id)
    if id >= 5 then
        return 245
    elseif id >= 3 then
        return 165
    else
        return 85
    end
end

local function checkButtonPosYByID(id)
    if id%2 == 1 then
        return 15
    else
        return 55
    end
end

local function checkDescPanelWidth(numButtons)
    if numButtons > 4 then
        return 255
    elseif numButtons > 2 then
        return 175
    else
        return 95
    end
end



--[[**********************************************************************************]]--

------------------ Functions related to buttons ------------------

function ISManagementObject:createButton(id)
    if self.buttons[id] ~= nil then return end
    local posX = checkButtonPosXByID(id)
    local posY = checkButtonPosYByID(id)

    self.buttons[id] = ISButton:new(self.width - posX, posY, 70, 30, self.buttonNames[id], self.isoObject, function(target, but) print(target:getObjectName());print(but.internal); end)
    self.buttons[id]:initialise()
    self.buttons[id]:instantiate()
    self.buttons[id].borderColor = {r=1, g=1, b=1, a=0.1}
    self.buttons[id].internal = self.buttonNames[id]
    self:updateButtonOnClick(id, self.manager.panel.character)
end

function ISManagementObject:setButtonNameByID(name, id)
    self.buttons[id].title = name
    self.buttons[id].internal = name
end

function ISManagementObject:updateButtonOnClick(id, player)
    if self.onClickButton == nil then return end
    ---@param target IsoObject
    ---@param but ISButton
    ---@param character IsoPlayer
    ---@param managementObject ISManagementObject
    local function tempOnClick(target, but, character, managementObject, arg3, arg4)
        if managementObject.isoObject then
            managementObject.onClickButton(target, but, character, managementObject, arg3, arg4)
        else
            but.onclick(but.target, but, but.onClickArgs[1], but.onClickArgs[2], but.onClickArgs[3], but.onClickArgs[4])
        end
        managementObject:updateObjectTexture()
    end
    self.buttons[id]:setOnClick(tempOnClick, player, self)
end

--[[**********************************************************************************]]--

------------------ Functions related to the RichTextPanel ------------------

function ISManagementObject:setObjectName(name)
    self.name = name

    self.descriptionPanel.text = " <H2> " .. self.name .. " <LINE><TEXT><RGB:1,1,1> "
    self.descriptionPanel.text = self.descriptionPanel.text .. self.description
    self.descriptionPanel:paginate()
end

function ISManagementObject:setObjectDescription(description)
    self.description = description

    self.descriptionPanel.text = " <H2> " .. self.name .. " <LINE><TEXT><RGB:1,1,1> "
    self.descriptionPanel.text = self.descriptionPanel.text .. self.description
    self.descriptionPanel:paginate()
end

--[[**********************************************************************************]]--

------------------ Functions related to Object Properties ------------------

function ISManagementObject:getObjectNumButtons()
    if ObjectButtons[self.objectType] then
        return #ObjectButtons[self.objectType].buttonNames
    end
    return 0
end

function ISManagementObject:getObjectButtonNames()
    if ObjectButtons[self.objectType] then
        return ObjectButtons[self.objectType].buttonNames
    end
    return {"", "", "", "", "", ""}
end

function ISManagementObject:getObjectOnClickFunction()
    if ObjectButtons[self.objectType] then
        return ObjectButtons[self.objectType].func
    end
    return function(target, button, player) print(string.format("Function not found!\nPlayer: %s\nObject: %s\nButton: %s\n", player:getUsername(), target:getObjectName(), button.title)) end
end

--[[**********************************************************************************]]--

------------------ Functions related to the Object UIElement ------------------

function ISManagementObject:updateObjectTexture()
    if self.isoObject and self.isoObject:getSquare() then
        local textureName = self.isoObject:getTextureName()
        self.texture = getTexture(textureName)
        self.manager.objects[self.id].textureName = textureName
    end
end

function ISManagementObject:createChildren()
    --TODO: Setup all verifications for the function, button names, onClickButton and params
    --Getting all current object properties from the other file
    self.numButtons = self:getObjectNumButtons()
    self.buttonNames = self:getObjectButtonNames()
    self.onClickButton = self:getObjectOnClickFunction()

    --Buttons creation
    for i=1, self.numButtons do
        self:createButton(i)
        self:addChild(self.buttons[i])
    end
    self:insertNewLineOfButtons(self.buttons[5], self.buttons[3], self.buttons[1])
    self:insertNewLineOfButtons(self.buttons[6], self.buttons[4], self.buttons[2])

    --Creating and adding TextPanel as a child
    self.descriptionPanel = ISRichTextPanel:new(56, 0, (self.width) - (50 - 4) - (checkDescPanelWidth(self.numButtons)), 100)
    self.descriptionPanel:initialise();
    self.descriptionPanel:noBackground()
    self.descriptionPanel.backgroundColor = {r=1,g=0,b=0,a=0.5}
    self.descriptionPanel.autosetheight = false
    self.descriptionPanel:setMargins(0,12,0,0)
    self:addChild(self.descriptionPanel)
    self.descriptionPanel.text = " <H2> " .. self.name .. " <LINE><TEXT><RGB:1,1,1> "
    self.descriptionPanel.text = self.descriptionPanel.text .. self.description
    self.descriptionPanel:paginate()

end

function ISManagementObject:prerender()
    ISPanelJoypad.prerender(self)

    --Outline. Maybe?
    --self:drawTextureScaledAspect2(text, 4+1, 2-1, 50-4, 100-4, 1, 0, 0, 0)
    --self:drawTextureScaledAspect2(text, 4-1, 2-1, 50-4, 100-4, 1, 0, 0, 0)
    --self:drawTextureScaledAspect2(text, 4+1, 2+1, 50-4, 100-4, 1, 0, 0, 0)
    --self:drawTextureScaledAspect2(text, 4-1, 2+1, 50-4, 100-4, 1, 0, 0, 0)

    --Rendering Texture
    self:drawTextureScaledAspect2(self.texture, 4, 2, 50-4, 100-4, 1, 1, 1, 1)
end


---Creates a new ManagementObject to be added to a page
---@param y number the Y of this object (is always (index-1)*100)
---@param width number Width of the object (must be the same of the window)
---@param id number ID of this object on the manager
---@param isoObject IsoObject The IsoObject that is being targeted by this object
---@param objectType string Instance of the object being used. e.g. IsoThumpable
---@param name string Name of this object (can use RichText tags)
---@param description string Description of this object (can use RichText tags)
---@param manager ISUIManager
function ISManagementObject:new(y, width, id, isoObject, objectType, name, description, manager)
    ---@type ISManagementObject
    local o = ISPanelJoypad:new(0, y, width, 100)
    setmetatable(o, self)
    self.__index = self
    o.borderColor = {r=1, g=1, b=1, a=0.1}

    o.id = id
    o.isoObject = isoObject
    o.objectType = objectType
    o.texture = isoObject and getTexture(isoObject:getTextureName()) or getTexture(manager.objects[id].textureName)
    o.name = name or ""
    o.description = description or ""
    o.numButtons = 0
    o.buttonNames = {"", "", "", "", "", ""}
    o.onClickButton = nil
    o.character = manager.panel.character
    o.manager = manager

    o.buttons = {}
    o.descriptionPanel = nil

    return o
end

------------------ Returning file for 'require' ------------------
return ISManagementObject