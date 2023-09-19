
----------------------------------------------------------------------------------------------
--- ManagementUI
--- @author: peteR_pg
--- Steam profile: https://steamcommunity.com/id/peter_pg/
--- GitHub Repository: https://github.com/Susjin/ManagementUI

--- Main file with all functions related to the panel on the ManagementUI
--- @class ISManagementPanel : ISCollapsableWindow
--- @field character IsoPlayer
--- @field playerNum number
--- @field objects ISManagementObject[]
--- @field pages ISManagementPage[]
local ISManagementPanel = {}
----------------------------------------------------------------------------------------------
-- ------ Inherent from ISCollapsableWindowJoypad
ISManagementPanel = ISCollapsableWindowJoypad:derive("ISManagementPanel")

-- ------ Setting up Locals ------ --
local ISManagementPage = require "ISManagementPage"
local ISManagementObject = require "ISManagementObject"

---addObjectToPage
---@param page ISManagementPage
---@param texture string
---@param name string
---@param description string
---@param buttonNames string[]
---@param buttonFunctions function[]
---@param buttonArgs any[]
function ISManagementPanel:addObjectToPage(page, texture, name, description, buttonNames, buttonFunctions, buttonArgs)
    local ID = #page.objects+1
    --self.richText.text = "<H2> Portail Automatiss <LINE><TEXT><INDENT:8><RGB:0,1,0> Battery charge: 25/100 <LINE><RGB:1,1,1><INDENT:0>States: <LINE><INDENT:8><RGB:1,0,0> Closed <RGB:1,1,1> | <RGB:0,1,0> Unlocked";
    --local texture = getScriptManager():FindItem("Base.Screwdriver"):getNormalTexture()
    --local texture = getTexture("gate_yay_01_8")
    --local texture = getTexture("appliances_cooking_01_4")


    page.objects[ID] = ISManagementObject:new(100*(ID-1), page:getWidth(), texture, name, description, buttonNames, buttonFunctions, buttonArgs)
    page.objects[ID]:initialise()
    page.objects[ID]:instantiate()

    page:addChild(page.objects[ID])


end

---Triggers when UI gets instantiated
function ISManagementPanel:createChildren()
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

    self.pages[1] = ISManagementPage:new(0, 0, self.tabs.width, self.tabs.height)
    self.tabs:addView("1", self.pages[1])

    self:addObjectToPage(self.pages[1], "gate_yay_01_8", "Portail Automatiss", " <INDENT:8><RGB:0,1,0> Battery charge: 25/100 <LINE><RGB:1,1,1><INDENT:0>States: <LINE><INDENT:8><RGB:1,0,0> Closed <RGB:1,1,1> | <RGB:0,1,0> Unlocked", {"Use", "Lock", "Copy", "Disconnect"})
    self:addObjectToPage(self.pages[1], "appliances_cooking_01_4", "Base Oven", " <INDENT:8><RGB:0,1,0> Temperature: 300K <LINE><RGB:1,1,1>States: <LINE><INDENT:8><RGB:1,0,0> Off <RGB:1,1,1> | <RGB:0,1,0> Timer", {"Turn On", "Timer", "PlaceHolde", "PlaceHolde"})
    self:addObjectToPage(self.pages[1], getTexture("appliances_misc_01_0"), "Generator - ID 1457", " <INDENT:8> Branch Setting: <RGB:1,1,0> Split Power <LINE><RGB:1,1,1><INDENT:0>States: <LINE><INDENT:8><RGB:1,0,0> Off <RGB:1,1,1> | <RGB:0,1,0> Fuel: 65% <RGB:1,1,1> | <RGB:1,1,0> Condition: 96%", {"Turn On", "Split", "Focus", "Disable"})


end

---Triggers once when UI is created
function ISManagementPanel:prerender()
    ISCollapsableWindowJoypad.prerender(self)

end


---Triggers when UI gains the Joypad Focus
---@param joypadData table
function ISManagementPanel:onGainJoypadFocus(joypadData)
    ISCollapsableWindowJoypad.onGainJoypadFocus(self, joypadData)
    self.drawJoypadFocus = true
end

---Triggers when UI looses the Joypad Focus
---@param joypadData table
function ISManagementPanel:onLoseJoypadFocus(joypadData)
    ISCollapsableWindowJoypad.onLoseJoypadFocus(self, joypadData)
    self.drawJoypadFocus = false
end

---Triggers when UI gains the Joypad Focus
---@param button number Joypad button that got pressed
function ISManagementPanel:onJoypadDown(button)
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
function ISManagementPanel:onJoypadDirUp(button)
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
function ISManagementPanel:onJoypadDirDown(button)
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
function ISManagementPanel:close()
    self:removeFromUIManager()
end

---Creates a ManagementUI object
---@param x number X position on the screen
---@param y number Y position on the screen
---@param width number Width of the panel
---@param height number Height of the panel
---@param character IsoPlayer Player that's rendering the interface
---@return ISManagementPanel
function ISManagementPanel:new(x, y, width, height, character)
    local o = ISCollapsableWindowJoypad.new(self, x, y, width, height)
    setmetatable(o, self)
    self.__index = self

    o:setTitle("ManagementUI")
    o.character = character
    o.playerNum = character:getPlayerNum()
    o.objects = {}
    o.pages = {}
    o.resizable = false
    return o
end


------------------ Returning file for 'require' ------------------
return ISManagementPanel