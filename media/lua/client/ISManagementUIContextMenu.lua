
----------------------------------------------------------------------------------------------
--- ManagementUI
--- @author: peteR_pg
--- Steam profile: https://steamcommunity.com/id/peter_pg/
--- GitHub Repository: https://github.com/Susjin/ManagementUI

--- Main file with all functions related to ContextMenu Options
--- @class ISManagementUIContextMenu
local ISManagementUIContextMenu = {}
----------------------------------------------------------------------------------------------
-- ------ Setting up locals ------ --
local ISUIManager = require "ISUIManager"
---@type ISUIManager
local UIManager
local pairs = pairs


function ISManagementUIContextMenu.getUIManagerFromModData()
    local managers = ModData.getOrCreate("ManagementUIManagers")
    if #managers > 0 then
        local found = false
        for _, manager in pairs(managers) do
            if manager.title == "TestManagementUI" then
                UIManager = ISUIManager:reloadFromTable(manager)
                found = true
                break
            end
        end
        if not found then
            UIManager = ISUIManager:new("TestManagementUI", 8, 6, false, false, false, "There are no objects now")
        end
    else
        UIManager = ISUIManager:new("TestManagementUI", 8, 6, false, false, false, "There are no objects now")
    end
end

function ISManagementUIContextMenu.saveUIManagerToModData()
    if UIManager ~= nil then
        UIManager:nullifyEverythingForSaving()
        ---@type ISUIManager[]
        local managers = ModData.getOrCreate("ManagementUIManagers")
        for _, manager in pairs(managers) do
            if manager.title == "TestManagementUI" then
                manager.title = UIManager.title
                manager.maxObjects = UIManager.maxObjects
                manager.maxButtons = UIManager.maxButtons
                manager.ignoreScreenWidth = UIManager.ignoreScreenWidth
                manager.showAllObjects = UIManager.showAllObjects
                manager.refreshOnChange = UIManager.refreshOnChange
                manager.noObjectsMessage = UIManager.noObjectsMessage
                manager.numPages = UIManager.numPages
                manager.objects = UIManager.objects
                manager.numObjects = UIManager.numObjects
                manager.x = UIManager.x
                manager.y = UIManager.y
                manager.width = UIManager.width
                manager.height = UIManager.height
                return
            end
        end
        --[[
        managers[#managers+1] = {}
        managers[#managers].title = UIManager.title
        managers[#managers].maxObjects = UIManager.maxObjects
        managers[#managers].maxButtons = UIManager.maxButtons
        managers[#managers].ignoreScreenWidth = UIManager.ignoreScreenWidth
        managers[#managers].numPages = UIManager.numPages
        managers[#managers].objects = UIManager.objects
        managers[#managers].numObjects = UIManager.numObjects
        managers[#managers].x = UIManager.x
        managers[#managers].y = UIManager.y
        managers[#managers].width = UIManager.width
        managers[#managers].height = UIManager.height--]]
    end
end


-- ------ ContextMenu functions ------ --
function ISManagementUIContextMenu.openUI(player)
    UIManager:createManagementPanel(player)
end

function ISManagementUIContextMenu.addObject(object, button, player)
    if button.internal == "OK" then
        UIManager:addObject(button.parent.entry:getText(), "", UIManager.getObjectSquarePos(object.object), object.type)

        player:Say("Saved")
    end
end

function ISManagementUIContextMenu.removeObject(player, button)
    if button.internal == "OK" then
        local done = UIManager:removeObjectByName(button.parent.entry:getText())
        if done then
            player:Say("Removed")
        else
            player:Say("Not Found")
        end
    end
end

function ISManagementUIContextMenu.textBoxAddObject(object, player)
    local textBox = ISTextBox:new(0, 0, 280, 180, "Insert object name to add", "DEBUG" , object, ISManagementUIContextMenu.addObject, player:getPlayerNum(), player)
    textBox:initialise()
    textBox:addToUIManager()
    textBox.entry:focus()
end

function ISManagementUIContextMenu.textBoxRemoveObject(player)
    local textBox = ISTextBox:new(0, 0, 280, 180, "Insert object name to remove", "DEBUG" , player, ISManagementUIContextMenu.removeObject, player:getPlayerNum())
    textBox:initialise()
    textBox:addToUIManager()
    textBox.entry:focus()
end

---onCreateWorldContextMenu
---@param playerNum number
---@param contextMenu ISContextMenu
---@param worldObjects IsoObject[]
function ISManagementUIContextMenu.onCreateWorldContextMenu(playerNum, contextMenu, worldObjects)
    local objSheet = {thumpable = "IsoThumpable", door = "IsoDoor", generator = "IsoGenerator", stove = "IsoStove", lightSwitch = "IsoLightSwitch"}

    local player = getSpecificPlayer(playerNum)
    ---@type IsoThumpable
    local objects = {}
    for i = 1, #worldObjects do
        if instanceof(worldObjects[i], "IsoThumpable") then
            objects.thumpable = worldObjects[i]
        end
        if instanceof(worldObjects[i], "IsoDoor") then
            objects.door = worldObjects[i]
        end
        if instanceof(worldObjects[i], "IsoGenerator") then
            objects.generator = worldObjects[i]
        end
        if instanceof(worldObjects[i], "IsoStove") then
            objects.stove = worldObjects[i]
        end
        if instanceof(worldObjects[i], "IsoLightSwitch") then
            objects.lightSwitch = worldObjects[i]
        end
    end

    for i, object in pairs(objects) do
       contextMenu:addOption(string.format("Add '%s' to the UI", objSheet[i]), {object = object, type = objSheet[i]}, ISManagementUIContextMenu.textBoxAddObject, player)
    end
    contextMenu:addOption("Remove Object from the UI", player, ISManagementUIContextMenu.textBoxRemoveObject)

    contextMenu:addOption("Open ManagementUI", player, ISManagementUIContextMenu.openUI)
end
Events.OnFillWorldObjectContextMenu.Add(ISManagementUIContextMenu.onCreateWorldContextMenu)


Events.OnInitGlobalModData.Add(ISManagementUIContextMenu.getUIManagerFromModData)
Events.OnSave.Add(ISManagementUIContextMenu.saveUIManagerToModData)


------------------ Returning file for 'require' ------------------
--return ISManagementUIContextMenu