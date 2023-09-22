----------------------------------------------------------------------------------------------
--- ManagementUI
--- @author: peteR_pg
--- Steam profile: https://steamcommunity.com/id/peter_pg/
--- GitHub Repository: https://github.com/Susjin/ManagementUI

--- Main file with all functions related to PLACEHOLDER
--- @class ISManagementPage : ISPanelJoypad
--- @field objects ISManagementObject[]
local ISManagementPage = {}
----------------------------------------------------------------------------------------------
-- ------ Inherent from ISPanelJoypad -- ------
ISManagementPage = ISPanelJoypad:derive("ISManagementPage")

-- ------ Setting up locals -- ------
local ISManagementObject = require "ISManagementObject"

local pairs = pairs

function ISManagementPage:clearAllObjects()
    for _, obj in pairs(self.objects) do
        obj:clearChildren()
        self:removeChild(obj)
    end
end

---addObjectToPage
---@param preUIObject PreUIObject
function ISManagementPage:addObjectToPage(preUIObject, pos, width)
    local object = ISManagementObject:new(100*(pos-1), width, preUIObject.isoObject, preUIObject.name, preUIObject.description, preUIObject.numButtons, preUIObject.buttonNames, preUIObject.onClickButton, preUIObject.param1, preUIObject.param2, preUIObject.param3, preUIObject.param4)
    object:initialise()
    object:instantiate()
    self.objects[pos] = object
    self:addChild(self.objects[pos])
end


---Creates a new page for the ManagementPanel
---@param y number
---@param width number
---@param height number
function ISManagementPage:new(y, width, height)
    local o = ISPanelJoypad:new(0, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.objects = {}

    o:setAnchorRight(true)
    o:setAnchorBottom(true)
    o:noBackground()
    return o
end


------------------ Returning file for 'require' ------------------
return ISManagementPage