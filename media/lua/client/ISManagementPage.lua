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
-- ------ Inherent from ISPanelJoypad
ISManagementPage = ISPanelJoypad:derive("ISManagementPage")

local pairs = pairs

function ISManagementPage:clearAllObjects()
    for _, obj in pairs(self.objects) do
        obj:clearChildren()
        self:removeChild(obj)
    end
end

---@return ISManagementPage
function ISManagementPage:new(x, y, width, height)
    local o = ISPanelJoypad:new(x, y, width, height)
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