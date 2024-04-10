----------------------------------------------------------------------------------------------
--- ManagementUI
--- @author: peteR_pg
--- Steam profile: https://steamcommunity.com/id/peter_pg/
--- GitHub Repository: https://github.com/Susjin/ManagementUI

--- Main file with all functions related to PLACEHOLDER
--- @class ISManagementPage : ISPanelJoypad
--- @field objects ISManagementObject[]
--- @field manager ISUIManager
local ISManagementPage = {}
----------------------------------------------------------------------------------------------
-- ------ Inherent from ISPanelJoypad -- ------
ISManagementPage = ISPanelJoypad:derive("ISManagementPage")

-- ------ Setting up locals -- ------
local ISManagementObject = require "ISManagementObject"

local pairs = pairs

---Clear all the objects from this page
function ISManagementPage:clearAllObjects()
    for _, obj in pairs(self.objects) do
        obj:clearChildren()
        self:removeChild(obj)
        obj = nil
    end
end

---Adds a object to the current page
---@param preUIObject PreUIObject Object created by the manager
---@param pos number Object position related to other objects on this page (starts with 1)
---@param width number Width of the object (same as the panel/page)
---@param id number ID of this object on the manager
function ISManagementPage:addObjectToPage(preUIObject, pos, width, id)
    local object = ISManagementObject:new(100*(pos-1), width, id, preUIObject.isoObject, preUIObject.name, preUIObject.description, self.manager)
    object:initialise()
    object:instantiate()
    self.objects[pos] = object
    self:addChild(self.objects[pos])
end


---Creates a new page for the ManagementPanel
---@param y number Starting y position (title bar + tabs bar)
---@param width number Width of the object (same as tabs)
---@param height number Height of the object (same as tabs)
function ISManagementPage:new(y, width, height, manager)
    local o = ISPanelJoypad:new(0, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.objects = {}
    o.manager = manager

    return o
end


------------------ Returning file for 'require' ------------------
return ISManagementPage