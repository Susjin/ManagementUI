
----------------------------------------------------------------------------------------------
--- ManagementUI
--- @author: peteR_pg
--- Steam profile: https://steamcommunity.com/id/peter_pg/
--- GitHub Repository: https://github.com/Susjin/ManagementUI

--- Main file with all functions related to a object on the ManagementUI
--- @class ISManagementObject : ISPanelJoypad
--- @field isoObject IsoObject The IsoObject that is being targeted by this object
--- @field texture Texture The Texture of the IsoObject to be rendered
--- @field name string Name of this object (can use RichText tags)
--- @field description string Description of this object (can use RichText tags)
--- @field numButtons number Number of buttons this object has. (max 6)
--- @field buttons ISButton[] Ordered table with each position being a ISButton
--- @field buttonNames string[] Ordered table with each position being a button's name respectively
--- @field onClickButton function Function that will trigger on every clicked button (Use 'if' and 'elseif' with the button names)
--- @field param1 any Can be any extra parameters used with the 'onClickButton' function
--- @field param2 any Can be any extra parameters used with the 'onClickButton' function
--- @field param3 any Can be any extra parameters used with the 'onClickButton' function
--- @field param4 any Can be any extra parameters used with the 'onClickButton' function
--- @field descriptionPanel ISRichTextPanel The RichText panel that is placed after the texture
local ISManagementObject = {}
----------------------------------------------------------------------------------------------
-- ------ Inherent from ISPanelJoypad -- ------
ISManagementObject = ISPanelJoypad:derive("ISManagementObject")

-- ------ Fixing the vanilla 'setOnClick' ISButton function -- ------
--[[local _ = ISButton.setOnClick
function ISButton:setOnClick(func, arg1, arg2, arg3, arg4)
    self.onclick = func
    self.onClickArgs = { arg1, arg2, arg3, arg4 }
end ]]

-- ------ Setting up locals -- ------
local function checkButtonPosByID(id)
    if id >= 5 then
        return 245
    elseif id >= 3 then
        return 165
    else
        return 85
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
    local posX = checkButtonPosByID(id)
    local posY = id%2 == 1 and 15 or 55

    self.buttons[id] = ISButton:new(self.width - posX, posY, 70, 30, self.buttonNames[id], self.isoObject, function(target, but) print(target:getTextureName());print(but.internal); end)
    self.buttons[id]:initialise()
    self.buttons[id]:instantiate()
    self.buttons[id].borderColor = {r=1, g=1, b=1, a=0.1}
    self.buttons[id].internal = self.buttonNames[id]
    --self:updateButtonOnClick(id, self.param1, self.param2, self.param3, self.param4)
end

function ISManagementObject:setButtonNameByID(name, id)
    self.buttons[id].title = name
    self.buttons[id].internal = name
end

function ISManagementObject:updateButtonOnClick(id, param1, param2, param3, param4)
    if self.onClickButton == nil then return end
    local function tempOnClick(object, but, prm1, prm2, prm3, prm4)
        self.onClickButton(object, but, prm1, prm2, prm3, prm4)
        self:updateObjectTexture()
    end
    self.buttons[id]:setOnClick(tempOnClick, param1, param2, param3, param4)
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

------------------ Functions related to the Object UIElement ------------------

function ISManagementObject:updateObjectTexture()
    if self.isoObject and self.isoObject:getSquare() then
        self.texture = getTexture(self.isoObject:getTextureName())
    end
end

function ISManagementObject:createChildren()
    --Buttons creation
    for i=1, self.numButtons do
        self:createButton(i)
        self:addChild(self.buttons[i])
    end
    self:insertNewLineOfButtons(self.buttons[5], self.buttons[3], self.buttons[1])
    self:insertNewLineOfButtons(self.buttons[6], self.buttons[4], self.buttons[2])

    --Adding TextPanel as a child
    self:addChild(self.descriptionPanel)
    self.descriptionPanel.text = " <H2> " .. self.name .. " <LINE><TEXT><RGB:1,1,1> "
    self.descriptionPanel.text = self.descriptionPanel.text .. self.description
    self.descriptionPanel:paginate()

    self.buttons1 = ISButton:new(self.width - 325, 15, 70, 30, self.buttonNames[1], self, function(target, but) print(target.name);print(but.internal); end)
    self.buttons1:initialise()
    self.buttons1:instantiate()
    self.buttons1.borderColor = {r=1, g=1, b=1, a=0.1}
    self.buttons1.internal = self.buttonNames[1]
    self:addChild(self.buttons1)

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
---@param isoObject IsoObject The IsoObject that is being targeted by this object
---@param name string Name of this object (can use RichText tags)
---@param description string Description of this object (can use RichText tags)
---@param numButtons number Number of buttons this object has. (max 6)
---@param buttonNames string[] Ordered table with each position being a button's name respectively
---@param onClickButton function Function that will trigger on every clicked button (Use 'if' and 'elseif' with the button names)
---@param param1 any Can be any extra parameters used with the 'onClickButton' function
---@param param2 any Can be any extra parameters used with the 'onClickButton' function
---@param param3 any Can be any extra parameters used with the 'onClickButton' function
---@param param4 any Can be any extra parameters used with the 'onClickButton' function
function ISManagementObject:new(y, width, isoObject, name, description, numButtons, buttonNames, onClickButton, param1, param2, param3, param4)
    ---@type ISManagementObject
    local o = ISPanelJoypad:new(0, y, width, 100)
    setmetatable(o, self)
    self.__index = self
    o.borderColor = {r=1, g=1, b=1, a=0.1}

    o.isoObject = isoObject
    o.texture = isoObject and getTexture(isoObject:getTextureName()) or nil
    o.name = name or ""
    o.description = description or ""
    o.numButtons = numButtons or 0
    o.buttonNames = buttonNames or {"nil", "nil", "nil", "nil"}
    o.onClickButton = onClickButton
    o.param1 = param1
    o.param2 = param2
    o.param3 = param3
    o.param4 = param4

    o.buttons = {}

    o.descriptionPanel = ISRichTextPanel:new(56, 0, (width) - (50 - 4) - (checkDescPanelWidth(numButtons)), 100)
    o.descriptionPanel:initialise();
    o.descriptionPanel:noBackground()
    o.descriptionPanel.backgroundColor = {r=1,g=0,b=0,a=0.5}
    o.descriptionPanel.autosetheight = false
    o.descriptionPanel:setMargins(0,12,0,0)

    return o
end

------------------ Returning file for 'require' ------------------
return ISManagementObject