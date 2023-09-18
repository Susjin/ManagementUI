
----------------------------------------------------------------------------------------------
--- ManagementUI
--- @author: peteR_pg
--- Steam profile: https://steamcommunity.com/id/peter_pg/
--- GitHub Repository: https://github.com/Susjin/ManagementUI

--- Main file with all functions related to the ManagementUI
--- @class ISManagementUI : ISCollapsableWindow
local ISManagementUI = {}
----------------------------------------------------------------------------------------------
-- ------ Inherent from ISCollapsableWindowJoypad
ISManagementUI = ISCollapsableWindowJoypad:derive("ISManagementUI")
-- ------ Setting up Locals ------ --
local ISManagementObject = require "ISManagementObject"

---Triggers when UI gets instantiated
function ISManagementUI:createChildren()
    ISCollapsableWindowJoypad.createChildren(self)
    local th = self:titleBarHeight()
    local rh = self:resizeWidgetHeight()

    --Get all the different objects before setting up tabs

    --Create tab panel
    self.tabs = ISTabPanel:new(0, th, self.width, self.height-th-rh)
    self.tabs:setAnchorRight(true)
    self.tabs:setAnchorBottom(true)
    self.tabs:setEqualTabWidth(false)
    self:addChild(self.tabs)

    self.panel = ISPanelJoypad:new(0, 0, self.tabs.width, 100)
    self.panel:initialise()
    self.panel:instantiate()
    self.panel.borderColor = {r=1, g=1, b=1, a=0.1}
    self.tabs:addView("TestJoypad", self.panel)

    local button1 = ISButton:new((self.panel:getWidth()/2) + 35, ((self.panel:getHeight()/2)-15) - 20, 70, 30, "Use")
    button1:initialise()
    button1:instantiate()
    button1.borderColor = {r=1, g=1, b=1, a=0.1}
    self.panel:addChild(button1)
    local button2 = ISButton:new((self.panel:getWidth()/2) + 115, ((self.panel:getHeight()/2)-15) - 20, 70, 30, "Split")
    button2:initialise();
    button2:instantiate();
    button2.borderColor = {r=1, g=1, b=1, a=0.1};
    self.panel:addChild(button2)
    local button3 = ISButton:new((self.panel:getWidth()/2) + 35, ((self.panel:getHeight()/2)-15) + 20, 70, 30, "Focus")
    button3:initialise();
    button3:instantiate();
    button3.borderColor = {r=1, g=1, b=1, a=0.1};
    self.panel:addChild(button3)
    local button4 = ISButton:new((self.panel:getWidth()/2) + 115, ((self.panel:getHeight()/2)-15) + 20, 70, 30, "Disconnect")
    button4:initialise();
    button4:instantiate();
    button4.borderColor = {r=1, g=1, b=1, a=0.1};
    self.panel:addChild(button4)
    print(tostring(self.panel.height))

    self.panel:insertNewLineOfButtons(button1, button2)
    self.panel:insertNewLineOfButtons(button3, button4)

    self.panel.richText = ISRichTextPanel:new((self.panel.height/2)+10, 0, (self.panel:getWidth()/2+5) - (self.panel.height/2)+10, self.panel.height)
    self.panel.richText:initialise();

    self.panel:addChild(self.panel.richText);
    self.panel.richText.background = false;
    self.panel.richText.text = "<H2> Portail Automatiss <LINE><TEXT><INDENT:8><RGB:0,1,0> Battery charge: 25/100 <LINE><RGB:1,1,1><INDENT:0>States: <LINE><INDENT:8><RGB:1,0,0> Closed <RGB:1,1,1> | <RGB:0,1,0> Unlocked";
    self.panel.richText.autosetheight = false
    self.panel.richText:setMargins(0,18,0,0)
    self.panel.richText:paginate();


end

---Triggers once when UI is created
function ISManagementUI:prerender()
    ISCollapsableWindowJoypad.prerender(self)
    --local text = getScriptManager():FindItem("Base.Screwdriver"):getNormalTexture()
    --local text = getTexture("gate_yay_01_8")
    local text = getTexture("appliances_cooking_01_4")

    --self.javaObject:DrawTextureTiled(text,6+(32-32)/2,self.tabs.tabHeight+self:titleBarHeight(),50,100,1,1,1,1)
    self:drawTextureScaledAspect2(text, 4, self.tabs.tabHeight+self:titleBarHeight()+2, (self.panel.height/2)-4, self.panel.height-4, 1, 1, 1, 1)

end


---Triggers when UI gains the Joypad Focus
---@param joypadData table
function ISManagementUI:onGainJoypadFocus(joypadData)
    ISCollapsableWindowJoypad.onGainJoypadFocus(self, joypadData)
    self.drawJoypadFocus = true
end

---Triggers when UI looses the Joypad Focus
---@param joypadData table
function ISManagementUI:onLoseJoypadFocus(joypadData)
    ISCollapsableWindowJoypad.onLoseJoypadFocus(self, joypadData)
    self.drawJoypadFocus = false
end

---Triggers when UI gains the Joypad Focus
---@param button number Joypad button that got pressed
function ISManagementUI:onJoypadDown(button)
    if button == Joypad.BButton then
        self:close()
        setJoypadFocus(self.playerNum, self.owner)
    end
    if button == Joypad.LBumper or button == Joypad.RBumper then
        if #self.tabs.viewList < 2 then return end
        local viewIndex = self.tabs:getActiveViewIndex()
        if button == Joypad.LBumper then
            if viewIndex == 1 then
                viewIndex = #self.tabs.viewList
            else
                viewIndex = viewIndex - 1
            end
        end
        if button == Joypad.RBumper then
            if viewIndex == #self.tabs.viewList then
                viewIndex = 1
            else
                viewIndex = viewIndex + 1
            end
        end
        self.tabs:activateView(self.tabs.viewList[viewIndex].name)
        --		setJoypadFocus(self.playerNum, self.tabs:getActiveView())
    end
end

---Triggers when the 'Up' Joypad button is pressed
---@param button number Joypad button that got pressed
function ISManagementUI:onJoypadDirUp(button)
    --Rewrite relating to what object holds the buttons
    --[[
    local listbox = self.tabs:getActiveView()
    local row = listbox:rowAt(5, 5 - listbox:getYScroll())
    row = row - math.floor((listbox.height / 2) / listbox.itemheight)
    row = math.max(row, 1)
    listbox:ensureVisible(row)
    --]]
end

---Triggers when the 'Down' Joypad button is pressed
---@param button number Joypad button that got pressed
function ISManagementUI:onJoypadDirDown(button)
    --Rewrite relating to what object holds the buttons
    --[[
    local listbox = self.tabs:getActiveView()
    local row = listbox:rowAt(5, listbox.height - 5 - listbox:getYScroll())
    row = row + math.floor((listbox.height / 2) / listbox.itemheight)
    row = math.min(row, listbox:size())
    listbox:ensureVisible(row)
    --]]
end

---Triggers when UI is closed
function ISManagementUI:close()
    self:removeFromUIManager()
end

---Creates a ManagementUI object
---@param x number X position on the screen
---@param y number Y position on the screen
---@param width number Width of the panel
---@param height number Height of the panel
---@param character IsoPlayer Player that's rendering the interface
function ISManagementUI:new(x, y, width, height, character)
    local o = ISCollapsableWindowJoypad.new(self, x, y, width, height)
    o:setTitle("ManagementUI")
    o.character = character
    o.playerNum = character:getPlayerNum()
    o.objects = {}
    o.pages = {}



    o.resizable = false
    return o
end


------------------ Returning file for 'require' ------------------
return ISManagementUI