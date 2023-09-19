--Test UI for Master Controller

require "ISUI/ISCollapsableWindowJoypad"
require "ISUI/ISScrollingListBox"
require "ISUI/ISTabPanel"

local ISTestUI = ISCollapsableWindowJoypad:derive("ISTestUI")
local ISTestList = ISScrollingListBox:derive("ISTestList")

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)
local pairs = pairs
local heightItem = math.max(32, FONT_HGT_SMALL) + 2 * 2
local heightThumpable = math.max(96, FONT_HGT_SMALL) + 2 * 2
return nil
---------------------- ISTestList overrides ----------------------

function ISTestList:addItem(name, object)
	local i = {}
	i.name=name;
	i.object=object;
	i.tooltip = nil;
	i.itemindex = self.count + 1;
	i.height = self.itemheight
	table.insert(self.items, i);
	self.count = self.count + 1;
	self:setScrollHeight(self:getScrollHeight()+i.height);
	return i;
end

function ISTestList:doDrawItem(y, item, _)
	if y + self:getYScroll() >= self.height then return y + item.height end
	if y + item.height + self:getYScroll() <= 0 then return y + item.height end


	if self.itemheight == heightItem then
		--Item Borders
		self:drawRectBorder(0, y, self:getWidth(), item.height, 0.5, self.borderColor.r, self.borderColor.g, self.borderColor.b)
		--Render item icon
		local texture = item.object:getNormalTexture()
		if texture then
			local texWidth = texture:getWidthOrig()
			local texHeight = texture:getHeightOrig()

			self:drawTexture(texture,6+(32-texWidth)/2,y+(item.height-texHeight)/2,1,1,1,1)
		end
		--Draw item name
		local itemPadY = (item.height - self.fontHgt) / 2
		local r,g,b,a = 0.5,0.5,0.5,1.0
		r,g,b,a = 1.0,1.0,1.0,1.0
		self:drawText(item.name, 6 + 32 + 6, y+itemPadY, r, g, b, a, self.font)
	end

	if self.itemheight == heightThumpable then
		--Item Borders
		self:drawRectBorder(0, y, self:getWidth(), item.height, 0.5, self.borderColor.r, self.borderColor.g, self.borderColor.b)
		--Render item icon
		local texture = getTexture(item.object)
		if texture then
			local texWidth = texture:getWidthOrig()
			local texHeight = texture:getHeightOrig()

			self:drawTextureScaledUniform(texture, 6+(32-(texWidth*0.4))/2, y+(item.height-(texHeight*0.4))/2, 0.4, 1, 1, 1, 1)
		end
		--Draw item name
		local itemPadY = (item.height - self.fontHgt) / 2
		local r,g,b,a = 0.5,0.5,0.5,1.0
		r,g,b,a = 1.0,1.0,1.0,1.0
		self:drawText(item.name, 6 + 48 + 6, y+itemPadY-4, r, g, b, a, UIFont.Medium)

		--Buttons

	end

	y = y + item.height
	return y;
end

function ISTestList:onMouseDown(x, y)
	if #self.items == 0 then return end
	local row = self:rowAt(x, y)

	-- RJ: If you select the same item it unselect it (maybe?)

	getSoundManager():playUISound("UISelectListItem")
	self.selected = row;
	print(string.format("Row: %d| Height: %d | X: %d | Y: %d", row, self.items[row].height, x, y))

	if self.onmousedown then
		self.onmousedown(self.target, self.items[self.selected].item);
	end
end

function ISTestList:prerender()
	if self.items == nil then
		return;
	end

	local stencilX = 0
	local stencilY = 0
	local stencilX2 = self.width
	local stencilY2 = self.height

	if self.drawBorder then
		self:drawRectBorder(0, -self:getYScroll(), self.width, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b)
		stencilX = 1
		stencilY = 1
		stencilX2 = self.width - 1
		stencilY2 = self.height - 1
	end

	if self:isVScrollBarVisible() then
		stencilX2 = self.vscroll.x + 3 -- +3 because the scrollbar texture is narrower than the scrollbar width
	end

	-- This is to handle this listbox being inside a scrolling parent.
	if self.parent and self.parent:getScrollChildren() then
		stencilX = self.javaObject:clampToParentX(self:getAbsoluteX() + stencilX) - self:getAbsoluteX()
		stencilX2 = self.javaObject:clampToParentX(self:getAbsoluteX() + stencilX2) - self:getAbsoluteX()
		stencilY = self.javaObject:clampToParentY(self:getAbsoluteY() + stencilY) - self:getAbsoluteY()
		stencilY2 = self.javaObject:clampToParentY(self:getAbsoluteY() + stencilY2) - self:getAbsoluteY()
	end
	self:setStencilRect(stencilX, stencilY, stencilX2 - stencilX, stencilY2 - stencilY)--]]

	local y = 0;
	local alt = false;

	--	if self.selected ~= -1 and self.selected < 1 then
	--		self.selected = 1
	if self.selected ~= -1 and self.selected > #self.items then
		self.selected = #self.items
	end

	local altBg = self.altBgColor

	self.listHeight = 0;
	local i = 1;
	for k, v in ipairs(self.items) do
		if not v.height then v.height = self.itemheight end -- compatibililty

		if alt and altBg then
			self:drawRect(0, y, self:getWidth(), v.height-1, altBg.r, altBg.g, altBg.b, altBg.a);
		else

		end
		v.index = i;
		local y2 = self:doDrawItem(y, v, alt);
		self.listHeight = y2;
		v.height = y2 - y
		y = y2

		alt = not alt;
		i = i + 1;

	end

	self:setScrollHeight((y));
	self:clearStencilRect();
	if self.doRepaintStencil then
		self:repaintStencilRect(stencilX, stencilY, stencilX2 - stencilX, stencilY2 - stencilY)
	end

	local mouseY = self:getMouseY()
	self:updateSmoothScrolling()
	if mouseY ~= self:getMouseY() and self:isMouseOver() then
		self:onMouseMove(0, self:getMouseY() - mouseY)
	end
	self:updateTooltip()

	if #self.columns > 0 then
		--		print(self:getScrollHeight())
		self:drawRectBorderStatic(0, 0 - self.itemheight, self.width, self.itemheight - 1, 1, self.borderColor.r, self.borderColor.g, self.borderColor.b);
		self:drawRectStatic(0, 0 - self.itemheight - 1, self.width, self.itemheight-2,self.listHeaderColor.a,self.listHeaderColor.r, self.listHeaderColor.g, self.listHeaderColor.b);
		local dyText = (self.itemheight - FONT_HGT_SMALL) / 2
		for i,v in ipairs(self.columns) do
			self:drawRectStatic(v.size, 0 - self.itemheight, 1, self.itemheight + math.min(self.height, self.itemheight * #self.items - 1), 1, self.borderColor.r, self.borderColor.g, self.borderColor.b);
			if v.name then
				self:drawText(v.name, v.size + 10, 0 - self.itemheight - 1 + dyText - self:getYScroll(), 1,1,1,1,UIFont.Small);
			end
		end
	end
end

function ISTestList:new(x, y, width, height, character)
	local o = ISScrollingListBox.new(self, x, y, width, height)
	local items = {}
	o.items = items
	o.character = character
	return o
end

---------------------- ISTestUI overrides ----------------------

function ISTestUI:setLists()
	local ScriptManager = getScriptManager()
	local itemsUI = ModData.getOrCreate("TestUI")
	local itemStrings = {}
	local objectStrings = {}

	for i=1, #itemsUI do
		if type(itemsUI[i]) == "string" and	string.contains(itemsUI[i], ".") then
			local item = ScriptManager:FindItem(itemsUI[i])
			if item then
				table.insert(itemStrings, item)
			end
		end
	end
	local sortFunc = function(a,b)
		return not string.sort(a:getDisplayName(), b:getDisplayName())
	end
	table.sort(itemStrings, sortFunc)


	for i=1, #itemsUI do
		if type(itemsUI[i]) == "table" then
			table.insert(objectStrings, itemsUI[i])
		end
	end
	local sortFunc2 = function(a,b)
		return not string.sort(a.name, b.name)
	end
	table.sort(objectStrings, sortFunc2)

	--[[
	self.listbox1:clear()
	for _,item in pairs(itemStrings) do
		self.listbox1:addItem(item:getDisplayName(), item)
	end
	]]

	self.listBox:clear()
	for _, thumpable in pairs(objectStrings) do
		self.listBox:addItem(thumpable.name, thumpable.texture)
	end
end

function ISTestUI:createChildren()
	ISCollapsableWindowJoypad.createChildren(self)
	local th = self:titleBarHeight()
	local rh = self:resizeWidgetHeight()

	--[[
	self.tabs = ISTabPanel:new(0, th, self.width, self.height-th-rh)
	self.tabs:setAnchorRight(true)
	self.tabs:setAnchorBottom(true)
	self.tabs:setEqualTabWidth(true)
	self:addChild(self.tabs)
	--Item ListBox
	local listbox1 = ISTestList:new(0, 0, self.tabs.width, self.tabs.height - self.tabs.tabHeight, self.character)
	listbox1:setAnchorRight(true)
	listbox1:setAnchorBottom(true)
	listbox1:setFont(UIFont.Small, 2)
	listbox1.itemheight = heightItem
	self.tabs:addView("Items UI", listbox1)
	self.listbox1 = listbox1
	--Thumpable ListBox
	local listbox2 = ISTestList:new(0, 0, self.tabs.width, self.tabs.height - self.tabs.tabHeight, self.character)
	listbox2:setAnchorRight(true)
	listbox2:setAnchorBottom(true)
	listbox2:setFont(UIFont.Small, 2)
	listbox2.itemheight = heightThumpable
	self.tabs:addView("Thumpable UI", listbox2)
	self.listbox2 = listbox2
	--]]

	--self.resizeWidget2:bringToTop()
	--self.resizeWidget:bringToTop()



	self.listBox = ISTestList:new(0, th, self.width, self.height-th-rh, self.character)
	self.listBox:setAnchorRight(true)
	self.listBox:setAnchorBottom(true)
	self.listBox:setFont(UIFont.Small, 2)
	self.listBox.itemheight = heightThumpable
	self:addChild(self.listBox)
	self:setLists()


end

function ISTestUI:close()
	self:removeFromUIManager()
end

function ISTestUI:prerender()
	ISCollapsableWindowJoypad.prerender(self)

	local inventoryPane = getPlayerInventory(self.playerNum)
	if not inventoryPane or (self.owner ~= inventoryPane) then
		-- Player Inventory UI was destroyed
		self:removeFromUIManager()
	end
end

function ISTestUI:onGainJoypadFocus(joypadData)
	ISCollapsableWindowJoypad.onGainJoypadFocus(self, joypadData)
	self.drawJoypadFocus = true
end

function ISTestUI:onLoseJoypadFocus(joypadData)
	ISCollapsableWindowJoypad.onLoseJoypadFocus(self, joypadData)
	self.drawJoypadFocus = false
end

function ISTestUI:onJoypadDown(button)
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

function ISTestUI:onJoypadDirUp(button)
	local listbox = self.tabs:getActiveView()
	local row = listbox:rowAt(5, 5 - listbox:getYScroll())
	row = row - math.floor((listbox.height / 2) / listbox.itemheight)
	row = math.max(row, 1)
	listbox:ensureVisible(row)
end

function ISTestUI:onJoypadDirDown(button)
	local listbox = self.tabs:getActiveView()
	local row = listbox:rowAt(5, listbox.height - 5 - listbox:getYScroll())
	row = row + math.floor((listbox.height / 2) / listbox.itemheight)
	row = math.min(row, listbox:size())
	listbox:ensureVisible(row)
end

function ISTestUI:new(x, y, width, height, character, owner)
	local o = ISCollapsableWindowJoypad.new(self, x, y, width, height)
	o:setTitle("Testing a Scrolling List")
	o.character = character
	o.playerNum = character:getPlayerNum()
	o.owner = owner
	return o
end


---------------------- ContextOptions functions ----------------------

local function onShowTestUI(player, playerNum)
	local playerInventory = getPlayerInventory(playerNum)
	
	local x = getPlayerScreenLeft(playerNum) + 100
	local y = getPlayerScreenTop(playerNum) + 50
	local w = 400
	local h = getPlayerScreenHeight(playerNum) - 250 * 2
	
	local TestUI = ISTestUI:new(x, y, w, h, player, playerInventory)
	TestUI:initialise()
	TestUI:instantiate()
	if playerNum == 0 and player:getJoypadBind() == -1 then
		ISLayoutManager.RegisterWindow('TestUI', ISTestUI, TestUI) 
	end
	TestUI:addToUIManager()

	if playerInventory.joyfocus then
		playerInventory.drawJoypadFocus = false
		setJoypadFocus(playerNum, TestUI)
	end
end

local function addToModData(object, button, player)
	local itemsUI = ModData.getOrCreate("TestUI")
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

local function textBoxRename(object, player)
	local textBox = ISTextBox:new(0, 0, 280, 180, "Specify entry name", "defaultTexture" , object, addToModData, player:getPlayerNum(), player)
	textBox:initialise()
	textBox:addToUIManager()
	textBox.entry:focus()
end

local function removeFromModData(object, player)
	local itemsUI = ModData.getOrCreate("TestUI")
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

local function onCreateWorldContextMenu(playerNum, contextMenu, worldObjects)
	local player = getSpecificPlayer(playerNum)
	---@type IsoThumpable
	local thumpable
	for i = 1, #worldObjects do
		if instanceof(worldObjects[i], "IsoThumpable") then
			thumpable = worldObjects[i]
		end
	end
	local itemsUI = ModData.getOrCreate("TestUI")

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
			contextMenu:addOption("Add to TestUI", thumpable, textBoxRename, player)
		else
			contextMenu:addOption("Remove from TestUI", thumpable, removeFromModData, player)
		end
		contextMenu:addOption("Open TestUI", player, onShowTestUI, playerNum)
	end
end
Events.OnFillWorldObjectContextMenu.Add(onCreateWorldContextMenu)

local function onCreateInventoryContextMenu(playerNum, contextMenu, inventoryItems)
	local player = getSpecificPlayer(playerNum)
	local items = inventoryItems
	if not instanceof(inventoryItems[1], "InventoryItem") then
		items = inventoryItems[1].items
	end
	
	local itemsUI = ModData.getOrCreate("TestUI")

	for i=1, #items do
		local alreadyInData = false
		for j=1, #itemsUI do
			if type(itemsUI[j]) == "string" and items[i]:getFullType() == itemsUI[j] then
				alreadyInData = true 
				break
			end 
		end
		if not alreadyInData then
			contextMenu:addOption("Add to TestUI", items[i], addToModData, nil, player)
		else
			contextMenu:addOption("Remove from TestUI", items[i], removeFromModData, player)
		end
		contextMenu:addOption("Open TestUI", player, onShowTestUI, playerNum)
		break
	end
end
Events.OnFillInventoryObjectContextMenu.Add(onCreateInventoryContextMenu)