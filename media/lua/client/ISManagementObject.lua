
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
--- @field numButtons number Number of buttons this object has. (min 2, max 6)
--- @field buttons ISButton[] Ordered table with each position being a ISButton
--- @field buttonNames string[] Ordered table with each position being a button's name respectively
--- @field onClickButton function Function that will trigger on every clicked button (Use 'if' and 'elseif' with the button names)
--- @field param1 any Can be any extra parameters used with the 'onClickButton' function
--- @field param2 any Can be any extra parameters used with the 'onClickButton' function
--- @field param3 any Can be any extra parameters used with the 'onClickButton' function
--- @field param4 any Can be any extra parameters used with the 'onClickButton' function
local ISManagementObject = {}
----------------------------------------------------------------------------------------------
-- ------ Inherent from ISPanelJoypad -- ------
ISManagementObject = ISPanelJoypad:derive("ISManagementObject")

-- ------ Fixing the vanilla 'setOnClick' ISButton function -- ------
local _ = ISButton.setOnClick
function ISButton:setOnClick(func, arg1, arg2, arg3, arg4)
    self.onclick = func
    self.onClickArgs = { arg1, arg2, arg3, arg4 }
end

-- ------ Setting up locals -- ------

local function checkPosByID(id)
    if id >= 5 then
        return 245
    elseif id >= 3 then
        return 165
    else
        return 85
    end
end





--[[**********************************************************************************]]--

------------------ Functions related to buttons ------------------

function ISManagementObject:createButton(id)
    if self.buttons[id] ~= nil then return false end
    local posX = checkPosByID(id)
    local posY = id%2 == 0 and 15 or 55

    local button = ISButton:new(self.width - posX, posY, 70, 30, self.buttonNames[id], self.isoObject)
    button:initialise()
    button:instantiate()
    button.borderColor = {r=1, g=1, b=1, a=0.1}
    button.internal = self.buttonNames[id]
    button:setOnClick(self.onClickButton, self.param1, self.param2, self.param3, self.param4)
    self.buttons[id] = button
    self:addChild(self.buttons[id])
    return true
end

--[[**********************************************************************************]]--

------------------ Functions related to the Object UIElement ------------------

function ISManagementObject:createChildren()

    for i=1, self.numButtons+1 do
       self:createButton(i)
    end

    self:insertNewLineOfButtons(self.buttons[1], self.buttons[3], self.buttons[5])
    self:insertNewLineOfButtons(self.buttons[2], self.buttons[4], self.buttons[6])


    local richText = ISRichTextPanel:new((self.height/2)+10, 0, (self:getWidth()/2+5) - (self.height/2)+10, self.height)
    richText:initialise();
    richText.background = false;
    richText.autosetheight = false
    richText:setMargins(0,10,0,0)
    self.richText = richText
    self:addChild(self.richText);

    self.richText.text = " <H2> " .. self.name .. " <LINE><TEXT><RGB:1,1,1> ";
    self.richText.text = self.richText.text .. self.description

    self.richText:paginate();
end

function ISManagementObject:prerender()
    ISPanelJoypad.prerender(self)
    --Remember function ISMoveableInfoWindow:setTexture if wanted to set all square textures
    --Outline. Maybe?
    --self:drawTextureScaledAspect2(text, 4+1, self.tabs.tabHeight+self:titleBarHeight()+2-1, (self.panel.height/2)-4, self.panel.height-4, 1, 0, 0, 0)
    --self:drawTextureScaledAspect2(text, 4-1, self.tabs.tabHeight+self:titleBarHeight()+2-1, (self.panel.height/2)-4, self.panel.height-4, 1, 0, 0, 0)
    --self:drawTextureScaledAspect2(text, 4+1, self.tabs.tabHeight+self:titleBarHeight()+2+1, (self.panel.height/2)-4, self.panel.height-4, 1, 0, 0, 0)
    --self:drawTextureScaledAspect2(text, 4-1, self.tabs.tabHeight+self:titleBarHeight()+2+1, (self.panel.height/2)-4, self.panel.height-4, 1, 0, 0, 0)
    --self:drawTextureScaledAspect2(self.texture, 4, self.tabs.tabHeight+self:titleBarHeight()+2, (self.panel.height/2)-4, self.panel.height-4, 1, 1, 1, 1)

    self:drawTextureScaledAspect2(self.texture, 4, 2, (self.height/2)-4, self.height-4, 1, 1, 1, 1)
end


---Creates a new ManagementObject to be added to a page
---@param y number the Y of this object (is always (index-1)*100)
---@param width number Width of the object (must be the same of the window)
---@param isoObject IsoObject The IsoObject that is being targeted by this object
---@param name string Name of this object (can use RichText tags)
---@param description string Description of this object (can use RichText tags)
---@param buttonNames string[] Ordered table with each position being a button's name respectively
---@param onClickButton function Function that will trigger on every clicked button (Use 'if' and 'elseif' with the button names)
---@param param1 any Can be any extra parameters used with the 'onClickButton' function
---@param param2 any Can be any extra parameters used with the 'onClickButton' function
---@param param3 any Can be any extra parameters used with the 'onClickButton' function
---@param param4 any Can be any extra parameters used with the 'onClickButton' function
function ISManagementObject:new(y, width, isoObject, name, description, buttonNames, onClickButton, param1, param2, param3, param4)
    local o = ISPanelJoypad:new(0, y, width, 100)
    setmetatable(o, self)
    self.__index = self
    o.borderColor = {r=1, g=1, b=1, a=0.1}

    o.isoObject = isoObject
    o.texture = getTexture(isoObject:getTextureName())
    o.name = name
    o.description = description or ""
    o.buttonNames = buttonNames or {"nil", "nil", "nil", "nil"}
    o.onClickButton = onClickButton
    o.param1 = param1
    o.param2 = param2
    o.param3 = param3
    o.param4 = param4

    o.buttons = {}

    return o
end

------------------ Returning file for 'require' ------------------
return ISManagementObject