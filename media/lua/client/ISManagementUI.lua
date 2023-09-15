
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

end

---Triggers once when UI is created
function ISManagementUI:prerender()
    ISCollapsableWindowJoypad.prerender(self)


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
    return o
end


------------------ Returning file for 'require' ------------------
return ISManagementUI