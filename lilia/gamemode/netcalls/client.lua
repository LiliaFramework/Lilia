net.Receive("liaNotifyL", function()
    local message = net.ReadString()
    local length = net.ReadUInt(8)
    if length == 0 then return lia.util.notifyLocalized(message) end
    local args = {}
    for i = 1, length do
        args[i] = net.ReadString()
    end

    lia.util.notifyLocalized(message, unpack(args))
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
net.Receive("RequestServerContent", function()
    local frame = vgui.Create("DFrame")
    frame:SetTitle("Server Content is Missing")
    frame:SetSize(400, 200)
    frame:Center()
    frame:MakePopup()
    local label = vgui.Create("DLabel", frame)
    label:SetTextColor(color_white)
    label:SetText("You do not have the server content mounted.\n\nThis may result in certain features missing.\n\nWould you like to open the Workshop page for the server content?")
    label:SizeToContents()
    label:SetPos(20, 40)
    local buttonYes = vgui.Create("DButton", frame)
    buttonYes:SetText("Yes")
    buttonYes:SetSize(100, 30)
    buttonYes:SetPos(60, 130)
    buttonYes.DoClick = function()
        gui.OpenURL("http://steamcommunity.com/sharedfiles/filedetails/?id=" .. lia.config.ServerWorkshopID)
        frame:Close()
    end

    local buttonNo = vgui.Create("DButton", frame)
    buttonNo:SetText("No")
    buttonNo:SetSize(100, 30)
    buttonNo:SetPos(240, 130)
    buttonNo.DoClick = function() frame:Close() end
end)

net.Receive("RequestLiliaContent", function()
    local isMounted = false
    for _, v in ipairs(engine.GetAddons()) do
        if v.wsid == "2959728255" and v.mounted then isMounted = true end
    end

    if not isMounted then
        local frame = vgui.Create("DFrame")
        frame:SetTitle("Lilia Content is Missing")
        frame:SetSize(400, 200)
        frame:Center()
        frame:MakePopup()
        local label = vgui.Create("DLabel", frame)
        label:SetTextColor(color_white)
        label:SetText("You do not have the Lilia content mounted.\n\nThis may result in certain features missing.\n\nWould you like to open the Workshop page for the Lilia content?")
        label:SizeToContents()
        label:SetPos(20, 40)
        local buttonYes = vgui.Create("DButton", frame)
        buttonYes:SetText("Yes")
        buttonYes:SetSize(100, 30)
        buttonYes:SetPos(60, 130)
        buttonYes.DoClick = function()
            gui.OpenURL("http://steamcommunity.com/sharedfiles/filedetails/?id=2959728255")
            frame:Close()
        end

        local buttonNo = vgui.Create("DButton", frame)
        buttonNo:SetText("No")
        buttonNo:SetSize(100, 30)
        buttonNo:SetPos(240, 130)
        buttonNo.DoClick = function() frame:Close() end
    end
end)

netstream.Hook("openBlacklistLog", function(client, target, blacklists, blacklistLog)
    if not client:HasPrivilege("Commands - Manage Permanent Flags") then return end
    local fr = vgui.Create("DFrame")
    fr:SetSize(700, 500)
    fr:Center()
    fr:MakePopup()
    fr:SetTitle(target:Name() .. " (" .. target:SteamID() .. ")'s Blacklists")
    local blText = "N/A"
    if blacklists and blacklists ~= "" then blText = blacklists end
    local label = vgui.Create("DLabel", fr)
    label:SetPos(5, 29)
    label:SetText("Current Blacklists: " .. blText)
    label:SizeToContents()
    label:SetFont("liaBigFont")
    label:SizeToContents()
    label = vgui.Create("DLabel", fr)
    label:SetPos(5, 29 + 16 * 3)
    label:SetText("!NOTE! Do not use /flagunblacklist for logged blacklists. Use Deactive-Blacklist instead!\nAll times are in your Local Timezone!")
    label:SizeToContents()
    label:SetTextColor(Color(255, 0, 0))
    local listView = vgui.Create("DListView", fr)
    listView:SetPos(5, 110)
    listView:SetSize(690, 335)
    listView:AddColumn("Timestamp (Local)")
    listView:AddColumn("Active?")
    listView:AddColumn("Unblacklist Time")
    listView:AddColumn("Blacklist Length")
    listView:AddColumn("Flags")
    listView:AddColumn("AdminSteam")
    listView:AddColumn("Admin")
    listView:AddColumn("Reason")
    local unbanButton = vgui.Create("DButton", fr)
    unbanButton:SetPos(5, 448)
    unbanButton:SetWidth(690)
    unbanButton:SetText("Deactive Selected Blacklist (Unblacklist)")
    unbanButton:SetSkin("Default")
    unbanButton.DoClick = function() if IsValid(listView:GetSelected()[1]) then netstream.Start("unflagblacklistRequest", target, listView:GetSelected()[1].bID) end end
    local printButton = vgui.Create("DButton", fr)
    printButton:SetPos(5, 473)
    printButton:SetWidth(690)
    printButton:SetText("Print Selected Blacklist To Console")
    printButton:SetSkin("Default")
    printButton.DoClick = function() if IsValid(listView:GetSelected()[1]) then print(listView:GetSelected()[1].printData) end end
    for k, v in pairs(blacklistLog) do
        v.bID = k
    end

    table.sort(blacklistLog, function(a, b) return a.starttime > b.starttime end)
    for _, v in pairs(blacklistLog) do
        local ln = listView:AddLine(os.date("%d/%m/%Y %H:%M:%S", v.starttime), v.active and "Yes" or "No", v.endtime ~= 0 and os.date("%d/%m/%Y %H:%M:%S", v.endtime) or "Never", v.time ~= 0 and string.NiceTime(v.time) or "Perm", v.flags, v.adminsteam, v.admin, v.reason)
        if v.active then
            ln.OldPaint = ln.Paint
            ln.Paint = function(pnl, w, h)
                pnl:OldPaint(w, h)
                surface.SetDrawColor(255, 0, 0, 100)
                surface.DrawRect(0, 0, w, h)
            end
        end

        ln.bID = v.bID
        ln.printData = target:Name() .. " [" .. target:SteamID() .. "] Blacklist ID " .. v.bID .. "\nStart: " .. os.date("%d/%m/%Y %H:%M:%S", v.starttime) .. "\n" .. "Active: " .. (v.active and "Yes" or "No") .. "\nEnd Time: " .. (v.endtime ~= 0 and os.date("%d/%m/%Y %H:%M:%S", v.endtime) or "Never") .. "\nLength: " .. (v.time ~= 0 and string.NiceTime(v.time) or "Perm") .. "\nFlags: " .. v.flags .. "\nAdminSteam: " .. v.adminsteam .. "\nAdmin: " .. v.admin .. "\nReason: " .. v.reason
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
    lia.util.notify(message)
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

net.Receive("OpenInformationMenu", function()
    local frame = vgui.Create("DFrame")
    frame:SetTitle("Classname viewer")
    frame:SetSize(600, 600)
    frame:Center()
    frame:MakePopup()
    local sheet = frame:Add("DPropertySheet")
    sheet:Dock(FILL)
    local factionsPanel = sheet:Add("DPanel")
    sheet:AddSheet("Factions", factionsPanel)
    local factionsList = factionsPanel:Add("DListView")
    factionsList:AddColumn("Print Name")
    factionsList:AddColumn("Class Name")
    for uniqueID, faction in pairs(lia.faction.teams) do
        factionsList:AddLine(faction.name, uniqueID)
    end

    factionsList:Dock(FILL)
    local classesPanel = sheet:Add("DPanel")
    sheet:AddSheet("Classes", classesPanel)
    local classesList = classesPanel:Add("DListView")
    classesList:AddColumn("Print Name")
    classesList:AddColumn("Class Name")
    for _, class in ipairs(lia.class.list) do
        classesList:AddLine(class.name, class.uniqueID)
    end

    classesList:Dock(FILL)
    local itemsPanel = sheet:Add("DPanel")
    sheet:AddSheet("Items", itemsPanel)
    local itemsList = itemsPanel:Add("DListView")
    itemsList:AddColumn("Print Name")
    itemsList:AddColumn("Class Name")
    for _, item in pairs(lia.item.list) do
        itemsList:AddLine(item.name, item.uniqueID)
    end

    itemsList:Dock(FILL)
end)

net.Receive("FlagList", function()
    local flags = net.ReadTable()
    local frame = vgui.Create("DFrame")
    frame:SetTitle("Flags List")
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

net.Receive("SendSound", function()
    surface.PlaySound(net.ReadString())
end)

netstream.Hook("idReq", function(text) SetClipboardText(text) end)
net.Receive("OpenPage", function() gui.OpenURL(net.ReadString()) end)
net.Receive("LiliaPlaySound", function() LocalPlayer():EmitSound(tostring(net.ReadString()), tonumber(net.ReadUInt(7)) or 100) end)
netstream.Hook("ChatPrint", function(data) chat.AddText(unpack(data)) end)
netstream.Hook("charInfo", function(data, id, client) lia.char.loaded[id] = lia.char.new(data, id, client == nil and LocalPlayer() or client) end)
net.Receive("ReloadLightMaps", function() render.RedownloadAllLightmaps(true) end)
netstream.Hook("charKick", function(id, isCurrentChar) hook.Run("KickedFromChar", id, isCurrentChar) end)
net.Receive("SendMessage", function() chat.AddText(Color(255, 255, 255), unpack(net.ReadTable())) end)
netstream.Hook("gVar", function(key, value) lia.net.globals[key] = value end)
net.Receive("SendPrint", function() print(unpack(net.ReadTable())) end)
net.Receive("SendPrintTable", function() PrintTable(net.ReadTable()) end)
netstream.Hook("nDel", function(index) lia.net[index] = nil end)
netstream.Hook("notifyQuery", lia.util.notifQuery)