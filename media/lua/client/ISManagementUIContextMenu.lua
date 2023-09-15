
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
local ISManagementUI = require "ISManagementUI"


-- ------ ContextMenu functions ------ --
function ISManagementUIContextMenu.onShowTestUI(player, playerNum)
    local playerInventory = getPlayerInventory(playerNum)

    local x = getPlayerScreenLeft(playerNum) + 100
    local y = getPlayerScreenTop(playerNum) + 50
    local w = 400
    local h = getPlayerScreenHeight(playerNum) - 250 * 2

    local ManagementUI = ISManagementUI:new(x, y, w, h, player, playerInventory)
    ManagementUI:initialise()
    ManagementUI:instantiate()
    if playerNum == 0 and player:getJoypadBind() == -1 then
        ISLayoutManager.RegisterWindow('managementui', ISManagementUI, ManagementUI)
    end
    ManagementUI:addToUIManager()

    if playerInventory.joyfocus then
        playerInventory.drawJoypadFocus = false
        setJoypadFocus(playerNum, ManagementUI)
    end
end

function ISManagementUIContextMenu.addToModData(object, button, player)
    local itemsUI = ModData.getOrCreate("ManagementUI")
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

function ISManagementUIContextMenu.textBoxRename(object, player)
    local textBox = ISTextBox:new(0, 0, 280, 180, "Specify entry name", "defaultTexture" , object, ISManagementUIContextMenu.addToModData, player:getPlayerNum(), player)
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

function ISManagementUIContextMenu.onCreateWorldContextMenu(playerNum, contextMenu, worldObjects)
    local player = getSpecificPlayer(playerNum)
    ---@type IsoThumpable
    local thumpable
    for i = 1, #worldObjects do
        if instanceof(worldObjects[i], "IsoThumpable") then
            thumpable = worldObjects[i]
        end
    end
    local itemsUI = ModData.getOrCreate("ManagementUI")

    if thumpable then
        local alreadyInData = false
        local textureName = thumpable:getTextureName()
        for i=0, #itemsUI do
            if type(itemsUI[i]) == "table" and itemsUI[i].texture == textureName then
                alreadyInData = true
                break
            end
        end
        if not alreadyInData then
            contextMenu:addOption("Add to ManagementUI", thumpable, ISManagementUIContextMenu.textBoxRename, player)
        else
            contextMenu:addOption("Remove from ManagementUI", thumpable, ISManagementUIContextMenu.removeFromModData, player)
        end
        contextMenu:addOption("Open ManagementUI", player, ISManagementUIContextMenu.onShowTestUI, playerNum)
    end
end
Events.OnFillWorldObjectContextMenu.Add(ISManagementUIContextMenu.onCreateWorldContextMenu)

function ISManagementUIContextMenu.onCreateInventoryContextMenu(playerNum, contextMenu, inventoryItems)
    local player = getSpecificPlayer(playerNum)
    local items = inventoryItems
    if not instanceof(inventoryItems[1], "InventoryItem") then
        items = inventoryItems[1].items
    end

    local itemsUI = ModData.getOrCreate("ManagementUI")

    for i=1, #items do
        local alreadyInData = false
        for j=1, #itemsUI do
            if type(itemsUI[j]) == "string" and items[i]:getFullType() == itemsUI[j] then
                alreadyInData = true
                break
            end
        end
        if not alreadyInData then
            contextMenu:addOption("Add to ManagementUI", items[i], ISManagementUIContextMenu.addToModData, nil, player)
        else
            contextMenu:addOption("Remove from ManagementUI", items[i], ISManagementUIContextMenu.removeFromModData, player)
        end
        contextMenu:addOption("Open ManagementUI", player, ISManagementUIContextMenu.onShowTestUI, playerNum)
        break
    end
end
Events.OnFillInventoryObjectContextMenu.Add(ISManagementUIContextMenu.onCreateInventoryContextMenu)


------------------ Returning file for 'require' ------------------
return ISManagementUIContextMenu