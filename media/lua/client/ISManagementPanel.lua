
----------------------------------------------------------------------------------------------
--- ManagementUI
--- @author: peteR_pg
--- Steam profile: https://steamcommunity.com/id/peter_pg/
--- GitHub Repository: https://github.com/Susjin/ManagementUI

--- Main file with all functions related to the panel on the ManagementUI
--- @class ISManagementPanel : ISCollapsableWindow
--- @field character IsoPlayer
--- @field playerNum number
--- @field numObjects number
--- @field pages ISManagementPage[]
--- @field manager ISUIManager
local ISManagementPanel = {}
----------------------------------------------------------------------------------------------
-- ------ Inherent from ISCollapsableWindowJoypad
ISManagementPanel = ISCollapsableWindowJoypad:derive("ISManagementPanel")

-- ------ Setting up Locals ------ --
local ISManagementPage = require "ISManagementPage"


--[[**********************************************************************************]]--

------------------ Functions related to the Panel creation ------------------

function ISManagementPanel:createPages()
    if #self.pages ~= self.manager.numPages then
        if #self.pages < self.manager.numPages then
            for i = #self.pages + 1, self.manager.numPages do
                self.pages[i] = ISManagementPage:new(0, 0, self.tabs.width, self.tabs.height)
                self.tabs:addView(string.format("Page %d", i), self.pages[i])
                self.pages[i]:setAnchorRight(true)
                self.pages[i]:setAnchorBottom(true)
                self.pages[i]:noBackground()
            end
        else
            for i = #self.pages, self.manager.numPages + 1, -1 do
                self.pages[i]:clearAllObjects()
                self.tabs:removeView(self.pages[i])
            end
        end
    end
end

function ISManagementPanel:createObjects()
    --[[
    for i = 1, self.manager.numPages do
        local pos = 1
        local actualObjectPos = (self.manager.maxObjects*(i-1))
        for j = 1 + actualObjectPos, self.manager.maxObjects + actualObjectPos do
            if j > #self.manager.validatedObjects then
                break
            end
            self.pages[i]:addObjectToPage(self.manager.validatedObjects[j], pos, self.width)
            self.numObjects = self.numObjects + 1
            pos = pos + 1
        end
    end
    ]]--
    for i = 1, self.manager.numPages do
        for j = 1, self.manager.maxObjects do
            if self.numObjects >= #self.manager.validatedObjects then
                break
            end
            self.pages[i]:addObjectToPage(self.manager.validatedObjects[self.numObjects+1], j, self.width)
            self.numObjects = self.numObjects + 1
        end
    end
end

function ISManagementPanel:setVisibleFunction()
    self.visibleTarget = self.manager
    local function triggerSetVisible(_, panel)
        if not panel:isVisible() then
            for i = 1, #panel.pages do
                panel.pages[i]:clearAllObjects()
                panel.tabs:removeView(panel.pages[i])
            end
        else
            panel.manager:validateObjects()
            panel:createPages()
            panel:createObjects()
        end
    end
    self.visibleFunction = triggerSetVisible
end

--[[**********************************************************************************]]--

------------------ Functions related to the Panel UIElement ------------------

---Triggers when UI gets instantiated
function ISManagementPanel:createChildren()
    ISCollapsableWindowJoypad.createChildren(self)
    local th = self:titleBarHeight()

    --Create tab panel
    self.tabs = ISTabPanel:new(0, th, self.width, self.height-th)
    self.tabs:setAnchorRight(true)
    self.tabs:setAnchorBottom(true)
    self.tabs:setEqualTabWidth(false)
    self:addChild(self.tabs)


    self:createPages()
    self:createObjects()

    --[[
    --Creating pages
    self.pages[1] = ISManagementPage:new(0, 0, self.tabs.width, self.tabs.height)
    self.tabs:addView("1", self.pages[1])

    self:addObjectToPage(self.pages[1], "gate_yay_01_8", "Portail Automatiss", " <INDENT:8><RGB:0,1,0> Battery charge: 25/100 <LINE><RGB:1,1,1><INDENT:0>States: <LINE><INDENT:8><RGB:1,0,0> Closed <RGB:1,1,1> | <RGB:0,1,0> Unlocked", {"Use", "Lock", "Copy", "Disconnect"})
    self:addObjectToPage(self.pages[1], "appliances_cooking_01_4", "Base Oven", " <INDENT:8><RGB:0,1,0> Temperature: 300K <LINE><RGB:1,1,1>States: <LINE><INDENT:8><RGB:1,0,0> Off <RGB:1,1,1> | <RGB:0,1,0> Timer", {"Turn On", "Timer", "PlaceHolde", "PlaceHolde"})
    self:addObjectToPage(self.pages[1], getTexture("appliances_misc_01_0"), "Generator - ID 1457", " <INDENT:8> Branch Setting: <RGB:1,1,0> Split Power <LINE><RGB:1,1,1><INDENT:0>States: <LINE><INDENT:8><RGB:1,0,0> Off <RGB:1,1,1> | <RGB:0,1,0> Fuel: 65% <RGB:1,1,1> | <RGB:1,1,0> Condition: 96%", {"Turn On", "Split", "Focus", "Disable"})
    --]]

end

--[[ Temporary
---Triggers once when UI is created
function ISManagementPanel:prerender()
    ISCollapsableWindowJoypad.prerender(self)

end]]


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

---Sets if the window is resizable
function ISManagementPanel:setResizable(resizable)
    self.resizable = resizable
    if self.resizeWidget then
        self.resizeWidget:setVisible(resizable)
    end
    if self.resizeWidget2 then
        self.resizeWidget2:setVisible(resizable)
    end
end

---Triggers when UI is closed
function ISManagementPanel:close()
    self:setVisible(false)
end

---Creates a ManagementUI object
---@param x number X position on the screen
---@param y number Y position on the screen
---@param width number Width of the panel
---@param height number Height of the panel
---@param character IsoPlayer Player that's rendering the interface
---@param manager ISUIManager Manager of all the ManagementUI elements
---@return ISManagementPanel
function ISManagementPanel:new(title, x, y, width, height, character, manager)
    ---@type ISManagementPanel
    local o = ISCollapsableWindowJoypad.new(self, x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.manager = manager

    o:setTitle(title)
    o.character = character
    o.playerNum = character:getPlayerNum()
    o.numObjects = 0
    o.pages = {}
    return o
end


------------------ Returning file for 'require' ------------------
return ISManagementPanel