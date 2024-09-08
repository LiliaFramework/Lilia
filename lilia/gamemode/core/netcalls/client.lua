net.Receive("liaNotifyL", function()
    local message = net.ReadString()
    local length = net.ReadUInt(8)
    if length == 0 then return lia.notices.notifyLocalized(message) end
    local args = {}
    for i = 1, length do
        args[i] = net.ReadString()
    end

    lia.notices.notifyLocalized(message, unpack(args))
end)

net.Receive("DropdownRequest", function()
    local title = net.ReadString()
    local subTitle = net.ReadString()
    local options = net.ReadTable()
    local frame = vgui.Create("DFrame")
    frame:SetTitle(title)
    frame:SetSize(300, 150)
    frame:Center()
    frame:MakePopup()
    local dropdown = vgui.Create("DComboBox", frame)
    dropdown:SetPos(10, 40)
    dropdown:SetSize(280, 20)
    dropdown:SetValue(subTitle)
    for _, option in ipairs(options) do
        dropdown:AddChoice(option)
    end

    dropdown.OnSelect = function(_, _, value)
        net.Start("DropdownRequest")
        net.WriteString(value)
        net.SendToServer()
        frame:Close()
    end
end)

net.Receive("OptionsRequest", function()
    local title = net.ReadString()
    local subTitle = net.ReadString()
    local options = net.ReadTable()
    local limit = net.ReadUInt(32)
    local frame = vgui.Create("DFrame")
    frame:SetTitle(title)
    frame:SetSize(400, 300)
    frame:Center()
    frame:MakePopup()
    local label = vgui.Create("DLabel", frame)
    label:SetText(subTitle)
    label:SetPos(10, 30)
    label:SizeToContents()
    local list = vgui.Create("DPanelList", frame)
    list:SetPos(10, 50)
    list:SetSize(380, 200)
    list:EnableVerticalScrollbar(true)
    list:SetSpacing(5)
    local selected = {}
    local checkboxes = {}
    for _, option in ipairs(options) do
        local checkbox = vgui.Create("DCheckBoxLabel")
        checkbox:SetText(option)
        checkbox:SetValue(false)
        checkbox:SizeToContents()
        checkbox.OnChange = function(self, value)
            if value then
                if #selected < limit then
                    table.insert(selected, option)
                else
                    self:SetValue(false)
                end
            else
                for i, v in ipairs(selected) do
                    if v == option then
                        table.remove(selected, i)
                        break
                    end
                end
            end
        end

        list:AddItem(checkbox)
        table.insert(checkboxes, checkbox)
    end

    local button = vgui.Create("DButton", frame)
    button:SetText("Submit")
    button:SetPos(10, 260)
    button:SetSize(380, 30)
    button.DoClick = function()
        net.Start("OptionsRequest")
        net.WriteTable(selected)
        net.SendToServer()
        frame:Close()
    end
end)


net.Receive("StringRequest", function()
    local id = net.ReadUInt(32)
    local title = net.ReadString()
    local subTitle = net.ReadString()
    local default = net.ReadString()
    if title:sub(1, 1) == "@" then title = L(title:sub(2)) end
    if subTitle:sub(1, 1) == "@" then subTitle = L(subTitle:sub(2)) end
    Derma_StringRequest(title, subTitle, default, function(text)
        net.Start("StringRequest")
        net.WriteUInt(id, 32)
        net.WriteString(text)
        net.SendToServer()
    end)
end)

net.Receive("liaNotify", function()
    local message = net.ReadString()
    lia.notices.notify(message)
end)

net.Receive("liaInventoryData", function()
    local id = net.ReadType()
    local key = net.ReadString()
    local value = net.ReadType()
    local instance = lia.inventory.instances[id]
    if not instance then
        ErrorNoHalt("Got data " .. key .. " for non-existent instance " .. id)
        return
    end

    local oldValue = instance.data[key]
    instance.data[key] = value
    instance:onDataChanged(key, oldValue, value)
    hook.Run("InventoryDataChanged", instance, key, oldValue, value)
end)

net.Receive("liaInventoryInit", function()
    local id = net.ReadType()
    local typeID = net.ReadString()
    local data = net.ReadTable()
    local instance = lia.inventory.new(typeID)
    instance.id = id
    instance.data = data
    instance.items = {}
    local length = net.ReadUInt(32)
    local data2 = net.ReadData(length)
    local uncompressed_data = util.Decompress(data2)
    local items = util.JSONToTable(uncompressed_data)
    local function readItem(I)
        local c = items[I]
        return c.i, c.u, c.d, c.q
    end

    local datatable = items
    local expectedItems = #datatable
    for i = 1, expectedItems do
        local itemID, itemType, data, quantity = readItem(i)
        local item = lia.item.new(itemType, itemID)
        item.data = table.Merge(item.data, data)
        item.invID = instance.id
        item.quantity = quantity
        instance.items[itemID] = item
        hook.Run("ItemInitialized", item)
    end

    lia.inventory.instances[instance.id] = instance
    hook.Run("InventoryInitialized", instance)
    for _, character in pairs(lia.char.loaded) do
        for index, inventory in pairs(character.vars.inv) do
            if inventory:getID() == id then character.vars.inv[index] = instance end
        end
    end
end)

net.Receive("liaInventoryAdd", function()
    local itemID = net.ReadUInt(32)
    local invID = net.ReadType()
    local item = lia.item.instances[itemID]
    local inventory = lia.inventory.instances[invID]
    if item and inventory then
        inventory.items[itemID] = item
        hook.Run("InventoryItemAdded", inventory, item)
    end
end)

net.Receive("liaInventoryRemove", function()
    local itemID = net.ReadUInt(32)
    local invID = net.ReadType()
    local item = lia.item.instances[itemID]
    local inventory = lia.inventory.instances[invID]
    if item and inventory and inventory.items[itemID] then
        inventory.items[itemID] = nil
        item.invID = 0
        hook.Run("InventoryItemRemoved", inventory, item)
    end
end)

net.Receive("liaInventoryDelete", function()
    local invID = net.ReadType()
    local instance = lia.inventory.instances[invID]
    if instance then hook.Run("InventoryDeleted", instance) end
    if invID then lia.inventory.instances[invID] = nil end
end)

net.Receive("liaItemInstance", function()
    local itemID = net.ReadUInt(32)
    local itemType = net.ReadString()
    local data = net.ReadTable()
    local item = lia.item.new(itemType, itemID)
    local invID = net.ReadType()
    local quantity = net.ReadUInt(32)
    item.data = table.Merge(item.data or {}, data)
    item.invID = invID
    item.quantity = quantity
    lia.item.instances[itemID] = item
    hook.Run("ItemInitialized", item)
end)

net.Receive("liaCharacterInvList", function()
    local charID = net.ReadUInt(32)
    local length = net.ReadUInt(32)
    local inventories = {}
    for i = 1, length do
        inventories[i] = lia.inventory.instances[net.ReadType()]
    end

    local character = lia.char.loaded[charID]
    if character then character.vars.inv = inventories end
end)

net.Receive("liaItemDelete", function()
    local id = net.ReadUInt(32)
    local instance = lia.item.instances[id]
    if instance and instance.invID then
        local inventory = lia.inventory.instances[instance.invID]
        if not inventory or not inventory.items[id] then return end
        inventory.items[id] = nil
        instance.invID = 0
        hook.Run("InventoryItemRemoved", inventory, instance)
    end

    lia.item.instances[id] = nil
    hook.Run("ItemDeleted", instance)
end)

netstream.Hook("charSet", function(key, value, id)
    id = id or (LocalPlayer():getChar() and LocalPlayer():getChar().id)
    local character = lia.char.loaded[id]
    if character then
        local oldValue = character.vars[key]
        character.vars[key] = value
        hook.Run("OnCharVarChanged", character, key, oldValue, value)
    end
end)

netstream.Hook("charVar", function(key, value, id)
    id = id or (LocalPlayer():getChar() and LocalPlayer():getChar().id)
    local character = lia.char.loaded[id]
    if character then
        local oldVar = character:getVar()[key]
        character:getVar()[key] = value
        hook.Run("OnCharLocalVarChanged", character, key, oldVar, value)
    end
end)

netstream.Hook("charData", function(id, key, value)
    local character = lia.char.loaded[id]
    if character then
        character.vars.data = character.vars.data or {}
        character:getData()[key] = value
    end
end)

netstream.Hook("item", function(uniqueID, id, data, invID)
    local item = lia.item.new(uniqueID, id)
    item.data = {}
    if data then item.data = data end
    item.invID = invID or 0
    hook.Run("ItemInitialized", item)
end)

netstream.Hook("invData", function(id, key, value)
    local item = lia.item.instances[id]
    if item then
        item.data = item.data or {}
        local oldValue = item.data[key]
        item.data[key] = value
        hook.Run("ItemDataChanged", item, key, oldValue, value)
    end
end)

netstream.Hook("invQuantity", function(id, quantity)
    local item = lia.item.instances[id]
    if item then
        local oldValue = item:getQuantity()
        item.quantity = quantity
        hook.Run("ItemQuantityChanged", item, oldValue, quantity)
    end
end)

netstream.Hook("liaDataSync", function(data, first, last)
    lia.localData = data
    lia.firstJoin = first
    lia.lastJoin = last
end)

netstream.Hook("liaData", function(key, value)
    lia.localData = lia.localData or {}
    lia.localData[key] = value
end)

netstream.Hook("attrib", function(id, key, value)
    local character = lia.char.loaded[id]
    if character then character:getAttribs()[key] = value end
end)

netstream.Hook("nVar", function(index, key, value)
    lia.net[index] = lia.net[index] or {}
    lia.net[index][key] = value
end)

netstream.Hook("nLcl", function(key, value)
    lia.net[LocalPlayer():EntIndex()] = lia.net[LocalPlayer():EntIndex()] or {}
    lia.net[LocalPlayer():EntIndex()][key] = value
end)

netstream.Hook("actBar", function(start, finish, text)
    if not text then
        lia.bar.actionStart = 0
        lia.bar.actionEnd = 0
    else
        if text:sub(1, 1) == "@" then text = L(text:sub(2)) end
        lia.bar.actionStart = start
        lia.bar.actionEnd = finish
        lia.bar.actionText = text:upper()
    end
end)

net.Receive("ItemList", function()
    local frame = vgui.Create("DFrame")
    frame:SetTitle("Items List")
    frame:SetSize(800, 600)
    frame:Center()
    frame:MakePopup()
    local itemsPanel = vgui.Create("DPanel", frame)
    itemsPanel:Dock(FILL)
    local itemsList = vgui.Create("DListView", itemsPanel)
    itemsList:Dock(FILL)
    itemsList:AddColumn("Unique ID"):SetFixedWidth(150)
    itemsList:AddColumn("Print Name")
    itemsList:AddColumn("Description")
    itemsList:AddColumn("Category")
    itemsList:AddColumn("Price")
    for _, item in pairs(lia.item.list) do
        itemsList:AddLine(item.uniqueID or "N/A", item.name or "N/A", item.desc or "N/A", item.category or "Misc", item.price or "0")
    end
end)

net.Receive("EntityList", function()
    local entities = net.ReadTable()
    local frame = vgui.Create("DFrame")
    frame:SetTitle("Entity List")
    frame:SetSize(900, 600)
    frame:Center()
    frame:MakePopup()
    local entityList = vgui.Create("DListView", frame)
    entityList:Dock(FILL)
    entityList:AddColumn("Class"):SetFixedWidth(150)
    entityList:AddColumn("Creator"):SetFixedWidth(200)
    entityList:AddColumn("Position")
    entityList:AddColumn("Model"):SetFixedWidth(200)
    entityList:AddColumn("Health"):SetFixedWidth(100)
    for _, ent in pairs(entities) do
        entityList:AddLine(ent.class or "N/A", ent.creator or "N/A", ent.position or "N/A", ent.model or "N/A", ent.health or "N/A")
    end
end)

net.Receive("PlayerList", function()
    local players = net.ReadTable()
    local frame = vgui.Create("DFrame")
    frame:SetTitle("Player List")
    frame:SetSize(900, 600)
    frame:Center()
    frame:MakePopup()
    local playerList = vgui.Create("DListView", frame)
    playerList:Dock(FILL)
    playerList:AddColumn("Name"):SetFixedWidth(200)
    playerList:AddColumn("Class"):SetFixedWidth(150)
    playerList:AddColumn("Faction"):SetFixedWidth(150)
    playerList:AddColumn("Character ID"):SetFixedWidth(100)
    playerList:AddColumn("Usergroup"):SetFixedWidth(150)
    for _, player in pairs(players) do
        playerList:AddLine(player.name or "N/A", player.class or "N/A", player.faction or "N/A", player.characterID or "N/A", player.usergroup or "N/A")
    end
end)

net.Receive("ModuleList", function()
    local modules = net.ReadTable()
    local frame = vgui.Create("DFrame")
    frame:SetTitle("Modules List")
    frame:SetSize(900, 500)
    frame:Center()
    frame:MakePopup()
    local moduleList = vgui.Create("DListView", frame)
    moduleList:Dock(FILL)
    moduleList:AddColumn("Unique ID"):SetFixedWidth(150)
    moduleList:AddColumn("Name"):SetFixedWidth(150)
    moduleList:AddColumn("Description")
    moduleList:AddColumn("Author"):SetFixedWidth(100)
    moduleList:AddColumn("Discord"):SetFixedWidth(150)
    moduleList:AddColumn("Version"):SetFixedWidth(80)
    for _, module in pairs(modules) do
        moduleList:AddLine(module.uniqueID, module.name, module.desc, module.author, module.discord, module.version)
    end
end)

net.Receive("OpenInvMenu", function()
    if not LocalPlayer():HasPrivilege("Commands - Check Inventories") then return end
    local target = net.ReadEntity()
    local index = net.ReadType()
    local targetInv = lia.inventory.instances[index]
    local myInv = LocalPlayer():getChar():getInv()
    local inventoryDerma = targetInv:show()
    inventoryDerma:SetTitle(target:getChar():getName() .. "'s Inventory")
    inventoryDerma:MakePopup()
    inventoryDerma:ShowCloseButton(true)
    local myInventoryDerma = myInv:show()
    myInventoryDerma:MakePopup()
    myInventoryDerma:ShowCloseButton(true)
    myInventoryDerma:SetParent(inventoryDerma)
    myInventoryDerma:MoveLeftOf(inventoryDerma, 4)
end)

net.Receive("FlagList", function()
    local targetName = net.ReadString()
    local flags = net.ReadTable()
    local frame = vgui.Create("DFrame")
    frame:SetTitle(targetName ~= "" and targetName .. " Flags" or "Flag List")
    frame:SetSize(400, 300)
    frame:Center()
    frame:MakePopup()
    local flagList = vgui.Create("DListView", frame)
    flagList:Dock(FILL)
    flagList:AddColumn("Flag")
    flagList:AddColumn("Description")
    for _, flag in pairs(flags) do
        flagList:AddLine(flag.flag, flag.desc)
    end
end)

net.Receive("OpenVGUI", function()
    local panel = net.ReadString()
    LocalPlayer():OpenUI(panel)
end)

net.Receive("chatNotifyNet", function()
    local message = net.ReadString()
    chat.AddText(Color(255, 215, 0), message)
end)

net.Receive("SendSound", function() surface.PlaySound(net.ReadString()) end)
net.Receive("OpenPage", function() gui.OpenURL(net.ReadString()) end)
net.Receive("LiliaPlaySound", function() LocalPlayer():EmitSound(tostring(net.ReadString()), tonumber(net.ReadUInt(7)) or 100) end)
netstream.Hook("ChatPrint", function(data) chat.AddText(unpack(data)) end)
netstream.Hook("charInfo", function(data, id, client) lia.char.loaded[id] = lia.char.new(data, id, client == nil and LocalPlayer() or client) end)
netstream.Hook("charKick", function(id, isCurrentChar) hook.Run("KickedFromChar", id, isCurrentChar) end)
net.Receive("SendMessage", function() chat.AddText(Color(255, 255, 255), unpack(net.ReadTable())) end)
netstream.Hook("gVar", function(key, value) lia.net.globals[key] = value end)
net.Receive("SendPrint", function() print(unpack(net.ReadTable())) end)
net.Receive("SendPrintTable", function() PrintTable(net.ReadTable()) end)
netstream.Hook("nDel", function(index) lia.net[index] = nil end)
netstream.Hook("notifyQuery", lia.notices.notifQuery)