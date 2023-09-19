----------------------------------------------------------------------------------------------
--- ManagementUI
--- @author: peteR_pg
--- Steam profile: https://steamcommunity.com/id/peter_pg/
--- GitHub Repository: https://github.com/Susjin/ManagementUI

--- Main file with all functions related to PLACEHOLDER
--- @class ISManagementPanel : ISPanelJoypad
--- @field objects ISManagementObject[]
local ISManagementPanel = {}
----------------------------------------------------------------------------------------------
-- ------ Inherent from ISPanelJoypad
ISManagementPanel = ISPanelJoypad:derive("ISManagementPanel")

---@return ISManagementPanel
function ISManagementPanel:new(x, y, width, height)
    local o = ISPanelJoypad:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self

    o.objects = {}

    return o
end


------------------ Returning file for 'require' ------------------
return ISManagementPanel