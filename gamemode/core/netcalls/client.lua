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

net.Receive("setWaypoint", function()
    local name = net.ReadString()
    local pos = net.ReadVector()
    LocalPlayer():setWaypoint(name, pos)
end)

net.Receive("setWaypointWithLogo", function()
    local name = net.ReadString()
    local pos = net.ReadVector()
    local logo = net.ReadString()
    LocalPlayer():setWaypointWithLogo(name, pos, logo)
end)

net.Receive("liaNotify", function()
    local message = net.ReadString()
    lia.notices.notify(message)
end)

net.Receive("ServerChatAddText", function()
    local args = net.ReadTable()
    chat.AddText(unpack(args))
end)

net.Receive("blindTarget", function()
    local enabled = net.ReadBool()
    if enabled then
        hook.Add("HUDPaint", "blindTarget", function() draw.RoundedBox(0, 0, 0, ScrW(), ScrH(), Color(0, 0, 0, 255)) end)
    else
        hook.Remove("HUDPaint", "blindTarget")
    end
end)

net.Receive("liaInventoryData", function()
    local id = net.ReadType()
    local key = net.ReadString()
    local value = net.ReadType()
    local instance = lia.inventory.instances[id]
    if not instance then
        lia.error(L("invDataNoInstance", key, id))
        return
    end

    local oldValue = instance.data[key]
    instance.data[key] = value
    instance:onDataChanged(key, oldValue, value)
    hook.Run("InventoryDataChanged", instance, key, oldValue, value)
end)

net.Receive("seqSet", function()
    local entity = net.ReadEntity()
    if not IsValid(entity) then return end
    local hasSequence = net.ReadBool()
    if not hasSequence then
        entity.liaForceSeq = nil
        return
    end

    local seqId = net.ReadInt(16)
    entity:SetCycle(0)
    entity:SetPlaybackRate(1)
    entity.liaForceSeq = seqId
end)

net.Receive("liaInventoryInit", function()
    local id = net.ReadType()
    local typeID = net.ReadString()
    local invData = net.ReadTable()
    local instance = lia.inventory.new(typeID)
    instance.id = id
    instance.data = invData
    instance.items = {}
    local length = net.ReadUInt(32)
    local compressedData = net.ReadData(length)
    local uncompressedData = util.Decompress(compressedData)
    local itemsTable = util.JSONToTable(uncompressedData)
    local function readItem(index)
        local entry = itemsTable[index]
        return entry.i, entry.u, entry.d, entry.q
    end

    for i = 1, #itemsTable do
        local itemID, itemType, itemData, quantity = readItem(i)
        local item = lia.item.new(itemType, itemID)
        item.data = table.Merge(item.data, itemData)
        item.invID = id
        item.quantity = quantity
        instance.items[itemID] = item
        hook.Run("ItemInitialized", item)
    end

    lia.inventory.instances[id] = instance
    hook.Run("InventoryInitialized", instance)
    for _, character in pairs(lia.char.getAll()) do
        for idx, inventory in pairs(character.vars.inv) do
            if inventory:getID() == id then character.vars.inv[idx] = instance end
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

    lia.char.getCharacter(charID, nil, function(character)
        if character then character.vars.inv = inventories end
    end)
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

net.Receive("charSet", function()
    local key = net.ReadString()
    local value = net.ReadType()
    local id = net.ReadType()
    id = id or LocalPlayer():getChar() and LocalPlayer():getChar().id
    lia.char.getCharacter(id, nil, function(character)
        if character then
            local oldValue = character.vars[key]
            character.vars[key] = value
            hook.Run("OnCharVarChanged", character, key, oldValue, value)
        end
    end)
end)

net.Receive("charVar", function()
    local key = net.ReadString()
    local value = net.ReadType()
    local id = net.ReadType()
    id = id or LocalPlayer():getChar() and LocalPlayer():getChar().id
    lia.char.getCharacter(id, nil, function(character)
        if character then
            local oldVar = character:getVar()[key]
            character:getVar()[key] = value
            hook.Run("OnCharLocalVarChanged", character, key, oldVar, value)
        end
    end)
end)

net.Receive("item", function()
    local uniqueID = net.ReadString()
    local id = net.ReadUInt(32)
    local data = net.ReadTable()
    local invID = net.ReadType()
    local item = lia.item.new(uniqueID, id)
    item.data = {}
    if data then item.data = data end
    item.invID = invID or 0
    hook.Run("ItemInitialized", item)
end)

net.Receive("invData", function()
    local id = net.ReadUInt(32)
    local key = net.ReadString()
    local value = net.ReadType()
    local item = lia.item.instances[id]
    if item then
        item.data = item.data or {}
        local oldValue = item.data[key]
        item.data[key] = value
        hook.Run("ItemDataChanged", item, key, oldValue, value)
    end
end)

net.Receive("invQuantity", function()
    local id = net.ReadUInt(32)
    local quantity = net.ReadUInt(32)
    local item = lia.item.instances[id]
    if item then
        local oldValue = item:getQuantity()
        item.quantity = quantity
        hook.Run("ItemQuantityChanged", item, oldValue, quantity)
    end
end)

net.Receive("liaDataSync", function()
    local data = net.ReadTable()
    local first = net.ReadType()
    local last = net.ReadType()
    lia.localData = data
    lia.firstJoin = first
    lia.lastJoin = last
end)

net.Receive("liaData", function()
    local key = net.ReadString()
    local value = net.ReadType()
    lia.localData = lia.localData or {}
    lia.localData[key] = value
end)

net.Receive("attrib", function()
    local id = net.ReadUInt(32)
    local key = net.ReadString()
    local value = net.ReadType()
    lia.char.getCharacter(id, nil, function(character)
        if character then character:getAttribs()[key] = value end
    end)
end)

net.Receive("nVar", function()
    local index = net.ReadUInt(16)
    local key = net.ReadString()
    local value = net.ReadType()
    lia.net[index] = lia.net[index] or {}
    local oldValue = lia.net[index][key]
    lia.net[index][key] = value
    local entity = Entity(index)
    if IsValid(entity) then hook.Run("NetVarChanged", entity, key, oldValue, value) end
end)

net.Receive("nLcl", function()
    local key = net.ReadString()
    local value = net.ReadType()
    local idx = LocalPlayer():EntIndex()
    lia.net[idx] = lia.net[idx] or {}
    local oldValue = lia.net[idx][key]
    lia.net[idx][key] = value
    hook.Run("LocalVarChanged", LocalPlayer(), key, oldValue, value)
end)

net.Receive("actBar", function()
    local hasData = net.ReadBool()
    if not hasData then
        hook.Remove("HUDPaint", "liaDrawAction")
        return
    end

    local text = net.ReadString()
    local time = net.ReadFloat()
    lia.bar.drawAction(text:sub(1, 1) == "@" and L(text:sub(2)) or text, time)
end)

net.Receive("OpenInvMenu", function()
    if not LocalPlayer():hasPrivilege("checkInventories") then return end
    local target = net.ReadEntity()
    local index = net.ReadType()
    local targetInv = lia.inventory.instances[index]
    local myInv = LocalPlayer():getChar():getInv()
    local inventoryDerma = targetInv:show()
    inventoryDerma:SetTitle(L("inventoryTitle", target:getChar():getName()))
    inventoryDerma:MakePopup()
    inventoryDerma:ShowCloseButton(true)
    local myInventoryDerma = myInv:show()
    myInventoryDerma:MakePopup()
    myInventoryDerma:ShowCloseButton(true)
    myInventoryDerma:SetParent(inventoryDerma)
    myInventoryDerma:MoveLeftOf(inventoryDerma, 4)
end)

lia.net.readBigTable("SendTableUI", function(data)
    lia.util.CreateTableUI(data.title, data.columns, data.data, data.options, data.characterID)
end)

net.Receive("OptionsRequest", function()
    local titleKey = net.ReadString()
    local subTitleKey = net.ReadString()
    local options = net.ReadTable()
    local limit = net.ReadUInt(32)
    local frame = vgui.Create("DFrame")
    frame:SetTitle(L(titleKey))
    frame:SetSize(400, 300)
    frame:Center()
    frame:MakePopup()
    local label = vgui.Create("DLabel", frame)
    label:SetText(L(subTitleKey))
    label:SetPos(10, 30)
    label:SizeToContents()
    label:SetTextColor(Color(255, 255, 255))
    local list = vgui.Create("DPanelList", frame)
    list:SetPos(10, 50)
    list:SetSize(380, 200)
    list:EnableVerticalScrollbar(true)
    list:SetSpacing(5)
    local selected = {}
    local checkboxes = {}
    for _, option in ipairs(options) do
        local checkbox = vgui.Create("DCheckBoxLabel")
        checkbox:SetText(L(option))
        checkbox:SetValue(false)
        checkbox:SizeToContents()
        checkbox:SetTextColor(Color(255, 255, 255))
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
    button:SetText(L("submit"))
    button:SetPos(10, 260)
    button:SetSize(380, 30)
    button.DoClick = function()
        net.Start("OptionsRequest")
        net.WriteTable(selected)
        net.SendToServer()
        frame:Close()
    end
end)

net.Receive("RequestDropdown", function()
    local titleKey = net.ReadString()
    local subTitleKey = net.ReadString()
    local options = net.ReadTable()
    local frame = vgui.Create("DFrame")
    frame:SetTitle(L(titleKey))
    frame:SetSize(300, 150)
    frame:Center()
    frame:MakePopup()
    local dropdown = vgui.Create("DComboBox", frame)
    dropdown:SetPos(10, 40)
    dropdown:SetSize(280, 20)
    dropdown:SetValue(L(subTitleKey))
    for _, option in ipairs(options) do
        dropdown:AddChoice(L(option))
    end

    dropdown.OnSelect = function(_, _, value)
        net.Start("RequestDropdown")
        net.WriteString(value)
        net.SendToServer()
        frame:Close()
    end
end)

net.Receive("ArgumentsRequest", function()
    local id = net.ReadUInt(32)
    local title = net.ReadString()
    local fields = net.ReadTable()
    lia.util.requestArguments(title, fields, function(data)
        net.Start("ArgumentsRequest")
        net.WriteUInt(id, 32)
        net.WriteTable(data)
        net.SendToServer()
    end)
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

local function OrganizeNotices()
    local baseY = 10
    local list = {}
    for _, n in ipairs(lia.notices) do
        if IsValid(n) then list[#list + 1] = n end
    end

    while #list > 6 do
        local old = table.remove(list, 1)
        if IsValid(old) then old:Remove() end
    end

    local leftCount = #list > 3 and #list - 3 or 0
    for i, n in ipairs(list) do
        local h = n:GetTall()
        local x, y
        if i <= leftCount then
            x = 10
            y = baseY + (i - 1) * (h + 5)
        else
            local idx = i - leftCount
            x = ScrW() - n:GetWide() - 10
            y = baseY + (idx - 1) * (h + 5)
        end

        n:MoveTo(x, y, 0.15)
    end
end

local function RemoveNotices(notice)
    if not IsValid(notice) then return end
    for i, v in ipairs(lia.notices) do
        if v == notice then
            notice:SizeTo(notice:GetWide(), 0, 0.2, 0, -1, function() if IsValid(notice) then notice:Remove() end end)
            table.remove(lia.notices, i)
            timer.Simple(0.25, OrganizeNotices)
            break
        end
    end
end

local function CreateNoticePanel(length, notimer)
    if not notimer then notimer = false end
    local notice = vgui.Create("noticePanel")
    notice.start = CurTime() + 0.25
    notice.endTime = CurTime() + length
    notice.oh = notice:GetTall()
    function notice:Paint(w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(35, 35, 35, 200))
        if self.start then
            local progress = math.TimeFraction(self.start, self.endTime, CurTime()) * w
            draw.RoundedBox(4, 0, 0, progress, h, lia.config.get("Color"))
        end
    end

    if not notimer then timer.Simple(length, function() RemoveNotices(notice) end) end
    return notice
end

net.Receive("BinaryQuestionRequest", function()
    local questionKey = net.ReadString()
    local option1Key = net.ReadString()
    local option2Key = net.ReadString()
    local manualDismiss = net.ReadBool()
    local notice = CreateNoticePanel(10, manualDismiss)
    table.insert(lia.notices, notice)
    notice.isQuery = true
    notice.text:SetText(L(questionKey))
    notice:SetPos(ScrW() / 2 - notice:GetWide() / 2, 4)
    notice:SetTall(36 * 2.3)
    notice:CalcWidth(120)
    if manualDismiss then notice.start = nil end
    notice.opt1 = notice:Add("DButton")
    notice.opt1:SetAlpha(0)
    notice.opt2 = notice:Add("DButton")
    notice.opt2:SetAlpha(0)
    notice.oh = notice:GetTall()
    notice:SetTall(0)
    notice:SizeTo(notice:GetWide(), 36 * 2.3, 0.2, 0, -1, function()
        notice.text:SetPos(0, 0)
        local function styleOpt(o)
            o.color = Color(0, 0, 0, 30)
            AccessorFunc(o, "color", "Color")
            function o:Paint(w, h)
                if self.left then
                    draw.RoundedBoxEx(4, 0, 0, w + 2, h, self.color, false, false, true, false)
                else
                    draw.RoundedBoxEx(4, 0, 0, w + 2, h, self.color, false, false, false, true)
                end
            end
        end

        if notice.opt1 and IsValid(notice.opt1) then
            notice.opt1:SetAlpha(255)
            notice.opt1:SetSize(notice:GetWide() / 2, 25)
            notice.opt1:SetText(L(option1Key, L("yes")) .. L("keyBind", "F8"))
            notice.opt1:SetPos(0, notice:GetTall() - notice.opt1:GetTall())
            notice.opt1:CenterHorizontal(0.25)
            notice.opt1:SetAlpha(0)
            notice.opt1:AlphaTo(255, 0.2)
            notice.opt1:SetTextColor(color_white)
            notice.opt1.left = true
            styleOpt(notice.opt1)
            function notice.opt1:keyThink()
                if input.IsKeyDown(KEY_F8) and CurTime() - notice.lastKey >= 0.5 then
                    self:ColorTo(Color(24, 215, 37), 0.2, 0)
                    notice.respondToKeys = false
                    net.Start("BinaryQuestionRequest")
                    net.WriteUInt(0, 1)
                    net.SendToServer()
                    timer.Simple(1, function() if notice and IsValid(notice) then RemoveNotices(notice) end end)
                    notice.lastKey = CurTime()
                end
            end
        end

        if notice.opt2 and IsValid(notice.opt2) then
            notice.opt2:SetAlpha(255)
            notice.opt2:SetSize(notice:GetWide() / 2, 25)
            notice.opt2:SetText(L(option2Key, L("no")) .. L("keyBind", "F9"))
            notice.opt2:SetPos(0, notice:GetTall() - notice.opt2:GetTall())
            notice.opt2:CenterHorizontal(0.75)
            notice.opt2:SetAlpha(0)
            notice.opt2:AlphaTo(255, 0.2)
            notice.opt2:SetTextColor(color_white)
            styleOpt(notice.opt2)
            function notice.opt2:keyThink()
                if input.IsKeyDown(KEY_F9) and CurTime() - notice.lastKey >= 0.5 then
                    self:ColorTo(Color(24, 215, 37), 0.2, 0)
                    notice.respondToKeys = false
                    net.Start("BinaryQuestionRequest")
                    net.WriteUInt(1, 1)
                    net.SendToServer()
                    timer.Simple(1, function() if notice and IsValid(notice) then RemoveNotices(notice) end end)
                    notice.lastKey = CurTime()
                end
            end
        end

        notice.lastKey = CurTime()
        notice.respondToKeys = true
        function notice:Think()
            self:SetPos(ScrW() / 2 - self:GetWide() / 2, 4)
            if not self.respondToKeys then return end
            if self.opt1 and IsValid(self.opt1) then self.opt1:keyThink() end
            if self.opt2 and IsValid(self.opt2) then self.opt2:keyThink() end
        end
    end)
end)

net.Receive("ButtonRequest", function()
    local id = net.ReadUInt(32)
    local titleKey = net.ReadString()
    local count = net.ReadUInt(8)
    local options = {}
    for i = 1, count do
        options[i] = net.ReadString()
    end

    local frame = vgui.Create("DFrame")
    frame:SetTitle(L(titleKey))
    frame:SetSize(300, 60 + count * 30)
    frame:Center()
    frame:MakePopup()
    for i, key in ipairs(options) do
        local btn = frame:Add("DButton")
        btn:Dock(TOP)
        btn:DockMargin(10, 5, 10, 0)
        btn:SetText(L(key))
        btn.DoClick = function()
            net.Start("ButtonRequest")
            net.WriteUInt(id, 32)
            net.WriteUInt(i, 8)
            net.SendToServer()
            frame:Close()
        end
    end
end)

net.Receive("AnimationStatus", function()
    local ply = net.ReadEntity()
    local active = net.ReadBool()
    local boneData = net.ReadTable()
    if IsValid(ply) then ply:NetworkAnimation(active, boneData) end
end)

net.Receive("liaCmdArgPrompt", function()
    local cmd = net.ReadString()
    local fields = net.ReadTable()
    local prefix = net.ReadTable()
    lia.command.openArgumentPrompt(cmd, fields, prefix)
end)

net.Receive("charInfo", function()
    local data = net.ReadTable()
    local id = net.ReadUInt(32)
    local client = net.BytesLeft() > 0 and net.ReadEntity() or nil
    lia.char.addCharacter(id, lia.char.new(data, id, client == nil and LocalPlayer() or client))
end)

net.Receive("charKick", function()
    local id = net.ReadUInt(32)
    local isCurrentChar = net.ReadBool()
    hook.Run("KickedFromChar", id, isCurrentChar)
end)

net.Receive("prePlayerLoadedChar", function()
    local charID = net.ReadUInt(32)
    local currentID = net.ReadType()
    local char = lia.char.getCharacter(charID)
    local current = currentID and lia.char.getCharacter(currentID) or nil
    hook.Run("PrePlayerLoadedChar", LocalPlayer(), char, current)
end)

net.Receive("playerLoadedChar", function()
    local charID = net.ReadUInt(32)
    local currentID = net.ReadType()
    local char = lia.char.getCharacter(charID)
    local current = currentID and lia.char.getCharacter(currentID) or nil
    hook.Run("PlayerLoadedChar", LocalPlayer(), char, current)
end)

net.Receive("postPlayerLoadedChar", function()
    local charID = net.ReadUInt(32)
    local currentID = net.ReadType()
    local char = lia.char.getCharacter(charID)
    local current = currentID and lia.char.getCharacter(currentID) or nil
    hook.Run("PostPlayerLoadedChar", LocalPlayer(), char, current)
end)

net.Receive("gVar", function()
    local key = net.ReadString()
    local value = net.ReadType()
    local oldValue = lia.net.globals[key]
    lia.net.globals[key] = value
    hook.Run("NetVarChanged", nil, key, oldValue, value)
end)

net.Receive("nDel", function()
    local index = net.ReadUInt(16)
    lia.net[index] = nil
end)

net.Receive("liaItemInspect", function()
    local uniqueID = net.ReadString()
    local data = net.ReadTable()
    local item = lia.item.new(uniqueID, 0)
    item.data = data or {}
    if hook.Run("CanPlayerInspectItem", LocalPlayer(), item) == false then return end
    local overlay = vgui.Create("EditablePanel")
    overlay:SetSize(ScrW(), ScrH())
    overlay:MakePopup()
    overlay:SetKeyboardInputEnabled(true)
    local frame = vgui.Create("DFrame", overlay)
    local fw, fh = ScrW() * 0.45, ScrH() * 0.8
    frame:SetSize(fw, fh)
    frame:Center()
    frame:SetTitle(L("inspect"))
    frame:SetDraggable(false)
    frame:ShowCloseButton(true)
    frame:MakePopup()
    frame.OnClose = function() if IsValid(overlay) then overlay:Remove() end end
    local hint = vgui.Create("DLabel", frame)
    hint:Dock(TOP)
    hint:SetTall(40)
    hint:SetContentAlignment(5)
    hint:SetFont("liaBigText")
    hint:SetTextColor(color_white)
    hint:SetText(L("itemInspectHint"))
    local view = vgui.Create("EditablePanel", frame)
    view:Dock(TOP)
    view:SetTall(fh * 0.5)
    view.Paint = function(_, w, h)
        surface.SetDrawColor(color_black)
        surface.DrawOutlinedRect(0, 0, w, h, 2)
    end

    local model = vgui.Create("DModelPanel", view)
    model:Dock(FILL)
    model:SetModel(item.model or "models/props_junk/cardboard_box002b.mdl")
    model.LayoutEntity = function() end
    timer.Simple(0, function()
        if not IsValid(model) then return end
        local mn, mx = model.Entity:GetRenderBounds()
        local c = (mn + mx) * 0.5
        local r = (mx - mn):Length() * 0.5 + 4
        model:SetLookAt(c)
        local d = (model:GetCamPos() - c):Length()
        model:SetFOV(math.Clamp(math.deg(2 * math.asin(r / d)), 20, 80))
    end)

    model.OnMouseWheeled = function() end
    model.OnMousePressed = function() end
    model.OnMouseReleased = function() end
    model.Think = function(p)
        if input.IsKeyDown(KEY_A) or input.IsKeyDown(KEY_D) then
            local ang = p.Entity:GetAngles()
            ang.y = ang.y + FrameTime() * 150 * (input.IsKeyDown(KEY_A) and 1 or -1)
            p.Entity:SetAngles(ang)
        end
    end

    local scroll = vgui.Create("DScrollPanel", frame)
    scroll:Dock(FILL)
    local function drawLine(parent, title, val)
        local t = parent:Add("DLabel")
        t:Dock(TOP)
        t:SetFont("liaBigTitle")
        t:SetTextColor(color_white)
        t:SetText(title)
        t:SizeToContentsY()
        local v = parent:Add("DLabel")
        v:Dock(TOP)
        v:DockMargin(0, 2, 0, 10)
        v:SetFont("liaBigText")
        v:SetTextColor(color_white)
        v:SetWrap(true)
        v:SetText(val ~= "" and val or "—")
        timer.Simple(0, function()
            if IsValid(v) then
                v:SetWide(parent:GetWide() - 20)
                v:SizeToContentsY()
            end
        end)
    end

    drawLine(scroll, L("name"), item:getName() or "")
    local extra = {}
    hook.Run("DisplayItemRelevantInfo", extra, LocalPlayer(), item)
    for _, info in ipairs(extra) do
        if info.title and info.value then
            local v = isfunction(info.value) and info.value(LocalPlayer(), item) or tostring(info.value)
            drawLine(scroll, info.title, v)
        end
    end
end)

net.Receive("liaCharacterData", function()
    local charID = net.ReadUInt(32)
    local character = lia.char.getCharacter(charID)
    if not character then return end
    if not character.dataVars then character.dataVars = {} end
    local keyCount = net.ReadUInt(32)
    for _ = 1, keyCount do
        local key = net.ReadString()
        local value = net.ReadType()
        character.dataVars[key] = value
    end
end)