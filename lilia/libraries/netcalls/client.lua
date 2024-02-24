---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
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

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
netstream.Hook("openBlacklistLog", function(target, blacklists, blacklistLog)
    if not (CAMI.PlayerHasAccess(LocalPlayer(), "Commands - Manage Permanent Flags", nil) or LocalPlayer():IsSuperAdmin()) then return end
    local fr = vgui.Create("DFrame")
    fr:SetSize(700, 500)
    fr:Center()
    fr:MakePopup()
    fr:SetTitle(target:Nick() .. " (" .. target:SteamID() .. ")'s Blacklists")
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
    for k, v in pairs(blacklistLog) do
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
        ln.printData = target:Nick() .. " [" .. target:SteamID() .. "] Blacklist ID " .. v.bID .. "\nStart: " .. os.date("%d/%m/%Y %H:%M:%S", v.starttime) .. "\n" .. "Active: " .. (v.active and "Yes" or "No") .. "\nEnd Time: " .. (v.endtime ~= 0 and os.date("%d/%m/%Y %H:%M:%S", v.endtime) or "Never") .. "\nLength: " .. (v.time ~= 0 and string.NiceTime(v.time) or "Perm") .. "\nFlags: " .. v.flags .. "\nAdminSteam: " .. v.adminsteam .. "\nAdmin: " .. v.admin .. "\nReason: " .. v.reason
    end
end)

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
net.Receive("liaStringReq", function()
    local id = net.ReadUInt(32)
    local title = net.ReadString()
    local subTitle = net.ReadString()
    local default = net.ReadString()
    if title:sub(1, 1) == "@" then title = L(title:sub(2)) end
    if subTitle:sub(1, 1) == "@" then subTitle = L(subTitle:sub(2)) end
    Derma_StringRequest(title, subTitle, default, function(text)
        net.Start("liaStringReq")
        net.WriteUInt(id, 32)
        net.WriteString(text)
        net.SendToServer()
    end)
end)

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
net.Receive("liaNotify", function()
    local message = net.ReadString()
    lia.util.notify(message)
end)

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
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

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
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

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
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

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
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

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
net.Receive("liaInventoryDelete", function()
    local invID = net.ReadType()
    local instance = lia.inventory.instances[invID]
    if instance then hook.Run("InventoryDeleted", instance) end
    if invID then lia.inventory.instances[invID] = nil end
end)

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
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

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
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

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
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

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
netstream.Hook("charSet", function(key, value, id)
    id = id or (LocalPlayer():getChar() and LocalPlayer():getChar().id)
    local character = lia.char.loaded[id]
    if character then
        local oldValue = character.vars[key]
        character.vars[key] = value
        hook.Run("OnCharVarChanged", character, key, oldValue, value)
    end
end)

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
netstream.Hook("charVar", function(key, value, id)
    id = id or (LocalPlayer():getChar() and LocalPlayer():getChar().id)
    local character = lia.char.loaded[id]
    if character then
        local oldVar = character:getVar()[key]
        character:getVar()[key] = value
        hook.Run("OnCharLocalVarChanged", character, key, oldVar, value)
    end
end)

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
netstream.Hook("charData", function(id, key, value)
    local character = lia.char.loaded[id]
    if character then
        character.vars.data = character.vars.data or {}
        character:getData()[key] = value
    end
end)

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
netstream.Hook("item", function(uniqueID, id, data, invID)
    local item = lia.item.new(uniqueID, id)
    item.data = {}
    if data then item.data = data end
    item.invID = invID or 0
    hook.Run("ItemInitialized", item)
end)

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
netstream.Hook("invData", function(id, key, value)
    local item = lia.item.instances[id]
    if item then
        item.data = item.data or {}
        local oldValue = item.data[key]
        item.data[key] = value
        hook.Run("ItemDataChanged", item, key, oldValue, value)
    end
end)

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
netstream.Hook("invQuantity", function(id, quantity)
    local item = lia.item.instances[id]
    if item then
        local oldValue = item:getQuantity()
        item.quantity = quantity
        hook.Run("ItemQuantityChanged", item, oldValue, quantity)
    end
end)

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
netstream.Hook("liaDataSync", function(data, first, last)
    lia.localData = data
    lia.firstJoin = first
    lia.lastJoin = last
end)

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
netstream.Hook("liaData", function(key, value)
    lia.localData = lia.localData or {}
    lia.localData[key] = value
end)

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
netstream.Hook("attrib", function(id, key, value)
    local character = lia.char.loaded[id]
    if character then character:getAttribs()[key] = value end
end)

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
netstream.Hook("nVar", function(index, key, value)
    lia.net[index] = lia.net[index] or {}
    lia.net[index][key] = value
end)

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
netstream.Hook("nLcl", function(key, value)
    lia.net[LocalPlayer():EntIndex()] = lia.net[LocalPlayer():EntIndex()] or {}
    lia.net[LocalPlayer():EntIndex()][key] = value
end)

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
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

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
net.Receive("announcement_client", function()
    local message = net.ReadString()
    chat.AddText(Color(255, 56, 252), "[Admin Announcement]: ", Color(255, 255, 255), message)
end)

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
net.Receive("StringRequest", function()
    local time = net.ReadUInt(32)
    local title, subTitle = net.ReadString(), net.ReadString()
    local default = net.ReadString()
    if title:sub(1, 1) == "@" then title = L(title:sub(2)) end
    if subTitle:sub(1, 1) == "@" then subTitle = L(subTitle:sub(2)) end
    Derma_StringRequest(title, subTitle, default or "", function(text)
        net.Start("StringRequest")
        net.WriteUInt(time, 32)
        net.WriteString(text)
        net.SendToServer()
    end)
end)

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
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

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
net.Receive("OpenVGUI", function()
    local panel = net.ReadString()
    LocalPlayer():OpenUI(panel)
end)

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
net.Receive("OpenPage", function() gui.OpenURL(net.ReadString()) end)
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
net.Receive("LiliaPlaySound", function() LocalPlayer():EmitSound(tostring(net.ReadString()), tonumber(net.ReadUInt(7)) or 100) end)
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
netstream.Hook("ChatPrint", function(data) chat.AddText(unpack(data)) end)
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
netstream.Hook("charInfo", function(data, id, client) lia.char.loaded[id] = lia.char.new(data, id, client == nil and LocalPlayer() or client) end)
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
net.Receive("ReloadLightMaps", function() render.RedownloadAllLightmaps(true) end)
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
netstream.Hook("charKick", function(id, isCurrentChar) hook.Run("KickedFromCharacter", id, isCurrentChar) end)
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
net.Receive("SendMessage", function() chat.AddText(Color(255, 255, 255), unpack(net.ReadTable())) end)
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
netstream.Hook("gVar", function(key, value) lia.net.globals[key] = value end)
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
net.Receive("SendPrint", function() print(unpack(net.ReadTable())) end)
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
net.Receive("SendPrintTable", function() PrintTable(net.ReadTable()) end)
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
netstream.Hook("nDel", function(index) lia.net[index] = nil end)
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
netstream.Hook("notifyQuery", lia.util.notifQuery)
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------