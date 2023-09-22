
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
local UIManager = {}

local pairs = pairs


function ISManagementUIContextMenu.getUIManagerFromModData()
    local managers = ModData.getOrCreate("ManagementUIManagers")
    if #managers > 0 then
        local found = false
        for _, manager in pairs(managers) do
            if manager.title == "TestManagementUI" then
                UIManager = manager
                found = true
                break
            end
        end
        if not found then
            UIManager = ISUIManager:initialiseUIManager("TestManagementUI", 8, 6, false)
            managers[#managers+1] = UIManager
        end
    else
        UIManager = ISUIManager:initialiseUIManager("TestManagementUI", 8, 6, false)
        managers[#managers+1] = UIManager
    end
end

function ISManagementUIContextMenu.saveUIManagerToModData()
    UIManager:nullifyEverythingForSaving()
    local managers = ModData.getOrCreate("ManagementUIManagers")
    for _, manager in pairs(managers) do
        if manager.title == "TestManagementUI" then
            manager = UIManager
        end
    end
    managers[#managers+1] = UIManager
end


-- ------ ContextMenu functions ------ --
function ISManagementUIContextMenu.onShowTestUI(player, playerNum)
    local playerInventory = getPlayerInventory(playerNum)

    local x = getPlayerScreenLeft(playerNum) + 100
    local y = getPlayerScreenTop(playerNum) + 50
    local w = 400
    local h = getPlayerScreenHeight(playerNum) - 250 * 2

    local ManagementUI = ISManagementPanel:new(x, y, w, h, player, playerInventory)
    ManagementUI:initialise()
    ManagementUI:instantiate()

    ManagementUI:addToUIManager()

    if playerInventory.joyfocus then
        playerInventory.drawJoypadFocus = false
        setJoypadFocus(playerNum, ManagementUI)
    end
end

function ISManagementUIContextMenu.addObject(object, button, player)
    local tempTable = {}
    tempTable.modData = itemsUI

    if instanceof(object, "InventoryItem") and not button then
        table.insert(tempTable.modData, object:getFullType())
    elseif instanceof(object, "IsoThumpable") and button then
        if button.internal == "OK" then
            local textBoxText = button.parent.entry:getText()
            table.insert(tempTable.modData, {name = textBoxText, texture = object:getTextureName()})
        end
    end

    for i, data in pairs(tempTable.modData) do
        itemsUI[i] = data
    end

    player:Say("Saved")
end

function ISManagementUIContextMenu.textBoxName(object, player)
    local textBox = ISTextBox:new(0, 0, 280, 180, "Specify entry name", "defaultTexture" , object, ISManagementUIContextMenu.addObject, player:getPlayerNum(), player)
    textBox:initialise()
    textBox:addToUIManager()
    textBox.entry:focus()
end


function ISManagementUIContextMenu.removeFromModData(object, player)
    local itemsUI = ModData.getOrCreate("ManagementUI")
    local tempTable = {}
    tempTable.modData = itemsUI

    for i, data in pairs(tempTable.modData) do
        if instanceof(object, "InventoryItem") then
            if data == object:getFullType() then
                table.remove(tempTable.modData, i)
                break
            end
        elseif instanceof(object, "IsoThumpable") then
            if data.texture == object:getTextureName() then
                table.remove(tempTable.modData, i)
                break
            end
        end
    end

    for i, data in pairs(tempTable.modData) do
        itemsUI[i] = data
    end

    player:Say("Deleted")
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
       contextMenu:addOption(string.format("Add '%s' to the UI", objSheet[i]), object, ISManagementUIContextMenu.textBoxName, player)



    end
end
Events.OnFillWorldObjectContextMenu.Add(ISManagementUIContextMenu.onCreateWorldContextMenu)


Events.OnInitGlobalModData.Add(ISManagementUIContextMenu.getUIManagerFromModData)
Events.OnPostSave.Add(ISManagementUIContextMenu.saveUIManagerToModData)


------------------ Returning file for 'require' ------------------
return ISManagementUIContextMenu