net.Receive("liaSetWaypoint", function()
    local name = net.ReadString()
    local pos = net.ReadVector()
    LocalPlayer():setWaypoint(name, pos)
end)

net.Receive("liaSetWaypointWithLogo", function()
    local name = net.ReadString()
    local pos = net.ReadVector()
    local logo = net.ReadString()
    LocalPlayer():setWaypointWithLogo(name, pos, logo)
end)

net.Receive("liaLoadingFailure", function()
    local reason = net.ReadString()
    local details = net.ReadString()
    local errorCount = net.ReadUInt(8)
    if IsValid(lia.loadingFailurePanel) then lia.loadingFailurePanel:Remove() end
    lia.loadingFailurePanel = vgui.Create("liaLoadingFailure")
    lia.loadingFailurePanel:SetFailureInfo(reason, details)
    for _ = 1, errorCount do
        local errorMessage = net.ReadString()
        local line = net.ReadString()
        local file = net.ReadString()
        lia.loadingFailurePanel:AddError(errorMessage, line, file)
    end
end)

net.Receive("liaServerChatAddText", function()
    local args = net.ReadTable()
    chat.AddText(unpack(args))
end)

net.Receive("liaSyncGesture", function()
    local entity = net.ReadEntity()
    local a = net.ReadUInt(8)
    local b = net.ReadUInt(8)
    local c = net.ReadBool()
    if IsValid(entity) then entity:AnimRestartGesture(a, b, c) end
end)

net.Receive("liaProvideServerPassword", function()
    local pw = net.ReadString()
    if not isstring(pw) or pw == "" then return end
    SetClipboardText(pw)
    chat.AddText(Color(0, 200, 0), L("serverPasswordCopied"))
end)

net.Receive("liaBlindTarget", function()
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

net.Receive("liaSeqSet", function()
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

    lia.char.getCharacter(charID, nil, function(character) if character then character.vars.inv = inventories end end)
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

net.Receive("liaCharSet", function()
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

net.Receive("liaCharVar", function()
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

net.Receive("liaItemData", function()
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

net.Receive("liaInvData", function()
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

net.Receive("liaInvQuantity", function()
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

net.Receive("liaDataSync", function()
    local key = net.ReadString()
    local value = net.ReadType()
    lia.localData = lia.localData or {}
    lia.localData[key] = value
end)

net.Receive("liaAttributeData", function()
    local id = net.ReadUInt(32)
    local key = net.ReadString()
    local value = net.ReadType()
    lia.char.getCharacter(id, nil, function(character) if character then character:getAttribs()[key] = value end end)
end)

net.Receive("liaNetVar", function()
    local index = net.ReadUInt(16)
    local key = net.ReadString()
    local value = net.ReadType()
    lia.net[index] = lia.net[index] or {}
    local oldValue = lia.net[index][key]
    lia.net[index][key] = value
    local entity = Entity(index)
    if IsValid(entity) then hook.Run("NetVarChanged", entity, key, oldValue, value) end
end)

net.Receive("liaNetLocal", function()
    local key = net.ReadString()
    local value = net.ReadType()
    local idx = LocalPlayer():EntIndex()
    lia.net[idx] = lia.net[idx] or {}
    local oldValue = lia.net[idx][key]
    lia.net[idx][key] = value
    hook.Run("LocalVarChanged", LocalPlayer(), key, oldValue, value)
end)

net.Receive("liaActBar", function()
    local hasData = net.ReadBool()
    if not hasData then
        hook.Remove("HUDPaint", "liaDrawAction")
        return
    end

    local text = net.ReadString()
    local time = net.ReadFloat()
    lia.bar.drawAction(text:sub(1, 1) == "@" and L(text:sub(2)) or text, time)
end)

net.Receive("liaOpenInvMenu", function()
    if not IsValid(LocalPlayer()) or not LocalPlayer():hasPrivilege("checkInventories") then return end
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

lia.net.readBigTable("liaSendTableUI", function(data) lia.util.CreateTableUI(data.title, data.columns, data.data, data.options, data.characterID) end)
net.Receive("liaOptionsRequest", function()
    local id = net.ReadUInt(32)
    local titleKey = net.ReadString()
    local _ = net.ReadString()
    local options = net.ReadTable()
    local limit = net.ReadUInt(32)
    lia.derma.requestOptions(L(titleKey), options, function(selectedOptions)
        if selectedOptions == false then
            net.Start("liaOptionsRequestCancel")
            net.WriteUInt(id, 32)
            net.SendToServer()
        else
            if limit > 0 and #selectedOptions > limit then
                local limited = {}
                for i = 1, limit do
                    if selectedOptions[i] then table.insert(limited, selectedOptions[i]) end
                end

                selectedOptions = limited
            end

            net.Start("liaOptionsRequest")
            net.WriteUInt(id, 32)
            net.WriteTable(selectedOptions)
            net.SendToServer()
        end
    end)
end)

net.Receive("liaProvideInteractOptions", function()
    local kind = net.ReadString()
    local count = net.ReadUInt(16)
    local temp = {}
    for _ = 1, count do
        local name = net.ReadString()
        local typ = net.ReadString()
        local serverOnly = net.ReadBool()
        local range = net.ReadUInt(16)
        local category = net.ReadString()
        local hasTarget = net.ReadBool()
        local target = hasTarget and net.ReadString() or nil
        local hasTime = net.ReadBool()
        local timeToComplete = hasTime and net.ReadFloat() or nil
        local hasActionText = net.ReadBool()
        local actionText = hasActionText and net.ReadString() or nil
        local hasTargetActionText = net.ReadBool()
        local targetActionText = hasTargetActionText and net.ReadString() or nil
        temp[name] = {
            type = typ,
            serverOnly = serverOnly,
            range = range,
            category = category,
            target = target,
            timeToComplete = timeToComplete,
            actionText = actionText,
            targetActionText = targetActionText
        }
    end

    local optionsMap = {}
    local optionCount = 0
    for name, opt in pairs(temp) do
        optionsMap[name] = opt
        optionCount = optionCount + 1
    end

    local isInteraction = kind == "interaction"
    if optionCount == 0 then return end
    lia.playerinteract.openMenu(optionsMap, isInteraction, isInteraction and "playerInteractions" or "actionsMenu", isInteraction and lia.keybind.get(L("interactionMenu"), KEY_TAB) or lia.keybind.get(L("personalActions"), KEY_G), "liaRunInteraction", true)
end)

net.Receive("liaRequestDropdown", function()
    local id = net.ReadUInt(32)
    local titleKey = net.ReadString()
    net.ReadString()
    local options = net.ReadTable()
    lia.derma.requestDropdown(L(titleKey), options, function(selectedText, selectedData)
        if selectedText == false then
            net.Start("liaRequestDropdownCancel")
            net.WriteUInt(id, 32)
            net.SendToServer()
        else
            net.Start("liaRequestDropdown")
            net.WriteUInt(id, 32)
            net.WriteString(selectedText)
            if selectedData ~= nil then
                net.WriteString(tostring(selectedData))
            else
                net.WriteString("")
            end

            net.SendToServer()
        end
    end)
end)

net.Receive("liaArgumentsRequest", function()
    local id = net.ReadUInt(32)
    local title = net.ReadString()
    local fields = net.ReadTable()
    lia.derma.requestArguments(title, fields, function(success, data)
        if success then
            net.Start("liaArgumentsRequest")
            net.WriteUInt(id, 32)
            net.WriteTable(data)
            net.SendToServer()
        else
            net.Start("liaArgumentsRequestCancel")
            net.WriteUInt(id, 32)
            net.SendToServer()
        end
    end)
end)

net.Receive("liaStringRequest", function()
    local id = net.ReadUInt(32)
    local title = net.ReadString()
    local subTitle = net.ReadString()
    local default = net.ReadString()
    if title:sub(1, 1) == "@" then title = L(title:sub(2)) end
    if subTitle:sub(1, 1) == "@" then subTitle = L(subTitle:sub(2)) end
    lia.derma.requestString(title, subTitle, function(value)
        if value == false then
            net.Start("liaStringRequestCancel")
            net.WriteUInt(id, 32)
            net.SendToServer()
        else
            net.Start("liaStringRequest")
            net.WriteUInt(id, 32)
            net.WriteString(value)
            net.SendToServer()
        end
    end, default)
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

net.Receive("liaBinaryQuestionRequest", function()
    local id = net.ReadUInt(32)
    local questionKey = net.ReadString()
    local option1Key = net.ReadString()
    local option2Key = net.ReadString()
    local manualDismiss = net.ReadBool()
    local notice = CreateNoticePanel(10, manualDismiss)
    table.insert(lia.notices, notice)
    notice.isQuery = true
    notice.text:SetText("")
    notice.text:SetText(L(questionKey))
    notice:SetPos(ScrW() / 2 - notice:GetWide() / 2, 4)
    notice:SetTall(36 * 2.3)
    notice:CalcWidth(120)
    if manualDismiss then notice.start = nil end
    notice.opt1 = notice:Add("DButton")
    notice.opt1:SetAlpha(0)
    notice.opt2 = notice:Add("DButton")
    notice.opt2:SetAlpha(0)
    notice.cancelBtn = notice:Add("DButton")
    notice.cancelBtn:SetAlpha(0)
    notice.oh = notice:GetTall()
    notice:SetTall(0)
    notice:SizeTo(notice:GetWide(), 36 * 2.3, 0.2, 0, -1, function()
        notice.text:Center()
        local function styleOpt(o)
            o.color = Color(0, 0, 0, 30)
            AccessorFunc(o, "color", "Color")
            function o:Paint(w, h)
                if self.left then
                    draw.RoundedBoxEx(4, 0, 0, w + 2, h, self.color, false, false, true, false)
                elseif self.right then
                    draw.RoundedBoxEx(4, 0, 0, w + 2, h, self.color, false, false, false, true)
                else
                    draw.RoundedBox(4, 0, 0, w, h, self.color)
                end
            end
        end

        if notice.opt1 and IsValid(notice.opt1) then
            notice.opt1:SetAlpha(255)
            notice.opt1:SetSize(notice:GetWide() / 3 - 5, 25)
            notice.opt1:SetText(L(option1Key, L("yes")) .. L("keyBind", "F7"))
            notice.opt1:SetPos(0, notice:GetTall() - notice.opt1:GetTall())
            notice.opt1:CenterHorizontal(0.166)
            notice.opt1:SetAlpha(0)
            notice.opt1:AlphaTo(255, 0.2)
            notice.opt1:SetTextColor(color_white)
            notice.opt1.left = true
            styleOpt(notice.opt1)
            function notice.opt1:keyThink()
                if input.IsKeyDown(KEY_F7) and CurTime() - notice.lastKey >= 0.5 then
                    self:ColorTo(Color(24, 215, 37), 0.2, 0)
                    notice.respondToKeys = false
                    net.Start("liaBinaryQuestionRequest")
                    net.WriteUInt(id, 32)
                    net.WriteUInt(0, 1)
                    net.SendToServer()
                    timer.Simple(1, function() if notice and IsValid(notice) then RemoveNotices(notice) end end)
                    notice.lastKey = CurTime()
                end
            end
        end

        if notice.opt2 and IsValid(notice.opt2) then
            notice.opt2:SetAlpha(255)
            notice.opt2:SetSize(notice:GetWide() / 3 - 5, 25)
            notice.opt2:SetText(L(option2Key, L("no")) .. L("keyBind", "F8"))
            notice.opt2:SetPos(0, notice:GetTall() - notice.opt2:GetTall())
            notice.opt2:CenterHorizontal(0.5)
            notice.opt2:SetAlpha(0)
            notice.opt2:AlphaTo(255, 0.2)
            notice.opt2:SetTextColor(color_white)
            styleOpt(notice.opt2)
            function notice.opt2:keyThink()
                if input.IsKeyDown(KEY_F8) and CurTime() - notice.lastKey >= 0.5 then
                    self:ColorTo(Color(24, 215, 37), 0.2, 0)
                    notice.respondToKeys = false
                    net.Start("liaBinaryQuestionRequest")
                    net.WriteUInt(id, 32)
                    net.WriteUInt(1, 1)
                    net.SendToServer()
                    timer.Simple(1, function() if notice and IsValid(notice) then RemoveNotices(notice) end end)
                    notice.lastKey = CurTime()
                end
            end
        end

        if notice.cancelBtn and IsValid(notice.cancelBtn) then
            notice.cancelBtn:SetAlpha(255)
            notice.cancelBtn:SetSize(notice:GetWide() / 3 - 5, 25)
            notice.cancelBtn:SetText(L("cancel") .. L("keyBind", "F9"))
            notice.cancelBtn:SetPos(0, notice:GetTall() - notice.cancelBtn:GetTall())
            notice.cancelBtn:CenterHorizontal(0.833)
            notice.cancelBtn:SetAlpha(0)
            notice.cancelBtn:AlphaTo(255, 0.2)
            notice.cancelBtn:SetTextColor(color_white)
            notice.cancelBtn.right = true
            styleOpt(notice.cancelBtn)
            function notice.cancelBtn:keyThink()
                if input.IsKeyDown(KEY_F9) and CurTime() - notice.lastKey >= 0.5 then
                    self:ColorTo(Color(215, 24, 37), 0.2, 0)
                    notice.respondToKeys = false
                    net.Start("liaBinaryQuestionRequestCancel")
                    net.WriteUInt(id, 32)
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
            if self.cancelBtn and IsValid(self.cancelBtn) then self.cancelBtn:keyThink() end
        end
    end)
end)

net.Receive("liaButtonRequest", function()
    local id = net.ReadUInt(32)
    local titleKey = net.ReadString()
    local count = net.ReadUInt(8)
    local options = {}
    for i = 1, count do
        options[i] = net.ReadString()
    end

    local buttons = {}
    for i, key in ipairs(options) do
        table.insert(buttons, {
            text = L(key),
            callback = function()
                net.Start("liaButtonRequest")
                net.WriteUInt(id, 32)
                net.WriteUInt(i, 8)
                net.SendToServer()
            end
        })
    end

    lia.derma.requestButtons(L(titleKey), buttons, function(selectedIndex) if selectedIndex and selectedIndex > 0 and selectedIndex <= #buttons then buttons[selectedIndex].callback() end end)
end)

net.Receive("liaAnimationStatus", function()
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

net.Receive("liaCharInfo", function()
    local data = net.ReadTable()
    local id = net.ReadUInt(32)
    local client = net.BytesLeft() > 0 and net.ReadEntity() or nil
    lia.char.addCharacter(id, lia.char.new(data, id, client == nil and LocalPlayer() or client))
end)

net.Receive("liaCharKick", function()
    local id = net.ReadUInt(32)
    local isCurrentChar = net.ReadBool()
    hook.Run("KickedFromChar", id, isCurrentChar)
end)

net.Receive("liaGlobalVar", function()
    local key = net.ReadString()
    local value = net.ReadType()
    local oldValue = lia.net.globals[key]
    lia.net.globals[key] = value
    hook.Run("NetVarChanged", nil, key, oldValue, value)
end)

net.Receive("liaNetDel", function()
    local index = net.ReadUInt(16)
    lia.net[index] = nil
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

net.Receive("liaEmitUrlSound", function()
    local ent = net.ReadEntity()
    local soundPath = net.ReadString()
    local volume = net.ReadFloat()
    local soundLevel = net.ReadFloat()
    local hasDelay = net.ReadBool()
    local startDelay = hasDelay and net.ReadFloat() or nil
    if not IsValid(ent) then return end
    if soundPath:find("^https?://") then
        local maxDistance = soundLevel * 13.33
        local ext = soundPath:match("%.([%w]+)$") or "mp3"
        local name = util.CRC(soundPath) .. "." .. ext
        local cachedPath = lia.websound.get(name)
        if cachedPath then
            ent:PlayFollowingSound(cachedPath, volume, true, maxDistance, startDelay)
        else
            lia.websound.register(name, soundPath, function(localPath) if localPath then ent:PlayFollowingSound(localPath, volume, true, maxDistance, startDelay) end end)
        end
    elseif soundPath:find("^lilia/websounds/") or soundPath:find("^websounds/") then
        local maxDistance = soundLevel * 13.33
        ent:PlayFollowingSound(soundPath, volume, true, maxDistance, startDelay)
    else
        ent:EmitSound(soundPath, soundLevel, nil, volume, nil, nil, nil)
    end
end)

net.Receive("liaNetMessage", function()
    local name = net.ReadString()
    local args = net.ReadTable()
    if lia.net.registry[name] then
        local success, err = pcall(lia.net.registry[name], LocalPlayer(), unpack(args))
        if not success then lia.error(L("netMessageCallbackError", name, tostring(err))) end
    else
        lia.error(L("unregisteredNetMessage", name))
    end
end)

net.Receive("liaAssureClientSideAssets", function()
    lia.webimage.allowDownloads = true
    local webimages = lia.webimage.stored
    local websounds = lia.websound.stored
    local downloadQueue = {}
    local activeDownloads = 0
    local maxConcurrent = 5
    local totalImages = table.Count(webimages)
    local totalSounds = table.Count(websounds)
    local completedImages = 0
    local completedSounds = 0
    local failedImages = 0
    local failedSounds = 0
    for name, data in pairs(webimages) do
        table.insert(downloadQueue, {
            type = "image",
            name = name,
            url = data.url,
            flags = data.flags
        })
    end

    for name, url in pairs(websounds) do
        table.insert(downloadQueue, {
            type = "sound",
            name = name,
            url = url
        })
    end

    lia.information(L("downloadQueueSize") .. ": " .. #downloadQueue)
    lia.information(L("processingWithMaxConcurrentDownloads") .. ": " .. maxConcurrent)
    local function processNextDownload()
        if #downloadQueue == 0 then return end
        local download = table.remove(downloadQueue, 1)
        activeDownloads = activeDownloads + 1
        if download.type == "image" then
            lia.webimage.download(download.name, download.url, function(material, fromCache, errorMsg)
                activeDownloads = activeDownloads - 1
                if material then
                    completedImages = completedImages + 1
                    if not fromCache then lia.information(L("imageDownloaded") .. ": " .. download.name) end
                else
                    failedImages = failedImages + 1
                    local errorMessage = errorMsg or L("unknownError")
                    lia.warning(L("imageFailed") .. ": " .. download.name .. " - " .. errorMessage)
                    chat.AddText(Color(255, 100, 100), L("imageDownload"), Color(255, 255, 255), L("failedToDownloadImage", download.name, errorMessage))
                end

                processNextDownload()
            end, download.flags)
        elseif download.type == "sound" then
            lia.websound.download(download.name, download.url, function(path, fromCache, errorMsg)
                activeDownloads = activeDownloads - 1
                if path then
                    completedSounds = completedSounds + 1
                    if not fromCache then print(L("soundDownloaded") .. ": " .. download.name) end
                else
                    failedSounds = failedSounds + 1
                    local errorMessage = errorMsg or L("unknownError")
                    chat.AddText(Color(255, 100, 100), "[Sound Download] ", Color(255, 255, 255), L("failedToDownloadSound", download.name, errorMessage))
                end

                processNextDownload()
            end)
        end
    end

    for _ = 1, math.min(maxConcurrent, #downloadQueue) do
        processNextDownload()
    end

    timer.Create("AssetDownloadProgress", 2, 0, function()
        if activeDownloads == 0 and #downloadQueue == 0 then
            timer.Remove("AssetDownloadProgress")
            lia.option.load()
            lia.keybind.load()
            lia.webimage.allowDownloads = false
            timer.Simple(1.0, function()
                local imageStats = lia.webimage.getStats()
                local soundStats = lia.websound.getStats()
                lia.bootstrap("AssetDownload", "===========================================")
                lia.bootstrap("AssetDownload", L("assetDownloadComplete"))
                lia.bootstrap("AssetDownload", L("downloadSummary"))
                lia.bootstrap("AssetDownload", string.format("Images: %d/%d completed (%d failed)", completedImages, totalImages, failedImages))
                lia.bootstrap("AssetDownload", string.format("Sounds: %d/%d completed (%d failed)", completedSounds, totalSounds, failedSounds))
                lia.bootstrap("AssetDownload", L("currentStatistics"))
                lia.bootstrap("AssetDownload", string.format("Images: %d downloaded | %d stored", imageStats.downloaded, imageStats.stored))
                lia.bootstrap("AssetDownload", string.format("Sounds: %d downloaded | %d stored", soundStats.downloaded, soundStats.stored))
                lia.bootstrap("AssetDownload", string.format("Combined: %d downloaded | %d stored", imageStats.downloaded + soundStats.downloaded, imageStats.stored + soundStats.stored))
                lia.bootstrap("AssetDownload", "===========================================")
                if failedImages > 0 or failedSounds > 0 then
                    lia.warning(L("warningAssetsFailedToDownload"))
                    if failedImages > 0 then chat.AddText(Color(255, 150, 100), "[Asset Download] ", Color(255, 255, 255), L("assetsDownloadWarning", failedImages, "image(s)")) end
                    if failedSounds > 0 then chat.AddText(Color(255, 150, 100), "[Asset Download] ", Color(255, 255, 255), L("assetsDownloadWarning", failedSounds, "sound(s)")) end
                else
                    chat.AddText(Color(100, 255, 100), "[Asset Download] ", Color(255, 255, 255), L("allAssetsDownloadedSuccessfully"))
                end
            end)
        end
    end)
end)
