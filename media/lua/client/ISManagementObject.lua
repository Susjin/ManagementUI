
----------------------------------------------------------------------------------------------
--- ManagementUI
--- @author: peteR_pg
--- Steam profile: https://steamcommunity.com/id/peter_pg/
--- GitHub Repository: https://github.com/Susjin/ManagementUI

--- Main file with all functions related to a object on the ManagementUI
--- @class ISManagementObject : ISPanelJoypad
--- @field texture string
--- @field name string
--- @field description string
--- @field buttonNames string[]
--- @field buttonFunctions function[]
--- @field buttonArgs any[]
local ISManagementObject = {}
----------------------------------------------------------------------------------------------
-- ------ Inherent from ISPanelJoypad
ISManagementObject = ISPanelJoypad:derive("ISManagementObject")


function ISManagementObject:createChildren()

    local button1 = ISButton:new((self:getWidth()/2) + 35, (self:getHeight()/2)-15 - 20, 70, 30, self.buttonNames[1], self.buttonArgs[1], self.buttonFunctions[1])
    button1:initialise()
    button1:instantiate()
    button1.borderColor = {r=1, g=1, b=1, a=0.1}
    self.button1 = button1
    self:addChild(button1)
    local button2 = ISButton:new((self:getWidth()/2) + 115, (self:getHeight()/2)-15 - 20, 70, 30, self.buttonNames[2], self.buttonArgs[2], self.buttonFunctions[2])
    button2:initialise();
    button2:instantiate();
    button2.borderColor = {r=1, g=1, b=1, a=0.1};
    self.button2 = button2
    self:addChild(button2)
    local button3 = ISButton:new((self:getWidth()/2) + 35, (self:getHeight()/2)-15 + 20, 70, 30, self.buttonNames[3], self.buttonArgs[3], self.buttonFunctions[3])
    button3:initialise();
    button3:instantiate();
    button3.borderColor = {r=1, g=1, b=1, a=0.1};
    self.button3 = button3
    self:addChild(button3)
    local button4 = ISButton:new((self:getWidth()/2) + 115, (self:getHeight()/2)-15 + 20, 70, 30, self.buttonNames[4], self.buttonArgs[4], self.buttonFunctions[4])
    button4:initialise()
    button4:instantiate()
    button4.borderColor = {r=1, g=1, b=1, a=0.1}
    self.button4 = button4
    self:addChild(button4)

    self:insertNewLineOfButtons(button1, button2)
    self:insertNewLineOfButtons(button3, button4)

    local richText = ISRichTextPanel:new((self.height/2)+10, 0, (self:getWidth()/2+5) - (self.height/2)+10, self.height)
    richText:initialise();
    richText.background = false;
    richText.autosetheight = false
    richText:setMargins(0,10,0,0)
    self.richText = richText
    self:addChild(self.richText);

    self.richText.text = "<H2> " .. self.name .. " <LINE><TEXT><RGB:1,1,1> ";
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

---@return ISManagementObject
function ISManagementObject:new(y, width, texture, name, description, buttonNames, buttonFunctions, buttonArgs)
    local o = ISPanelJoypad:new(0, y, width, 100)
    setmetatable(o, self)
    self.__index = self

    o.borderColor = {r=1, g=1, b=1, a=0.1}
    o.texture = instanceof(texture, "Texture") and texture or getTexture(texture)
    o.name = name or ""
    o.description = description or ""
    o.buttonNames = buttonNames or {}
    o.buttonFunctions = buttonFunctions or {}
    o.buttonArgs = buttonArgs or {}


    return o
end

------------------ Returning file for 'require' ------------------
return ISManagementObject