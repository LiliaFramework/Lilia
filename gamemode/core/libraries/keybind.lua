lia.keybind = lia.keybind or {}
lia.keybind.stored = lia.keybind.stored or {}
local KeybindKeys = {
    ["first"] = KEY_FIRST,
    ["none"] = KEY_NONE,
    ["0"] = KEY_0,
    ["1"] = KEY_1,
    ["2"] = KEY_2,
    ["3"] = KEY_3,
    ["4"] = KEY_4,
    ["5"] = KEY_5,
    ["6"] = KEY_6,
    ["7"] = KEY_7,
    ["8"] = KEY_8,
    ["9"] = KEY_9,
    ["a"] = KEY_A,
    ["b"] = KEY_B,
    ["c"] = KEY_C,
    ["d"] = KEY_D,
    ["e"] = KEY_E,
    ["f"] = KEY_F,
    ["g"] = KEY_G,
    ["h"] = KEY_H,
    ["i"] = KEY_I,
    ["j"] = KEY_J,
    ["k"] = KEY_K,
    ["l"] = KEY_L,
    ["m"] = KEY_M,
    ["n"] = KEY_N,
    ["o"] = KEY_O,
    ["p"] = KEY_P,
    ["q"] = KEY_Q,
    ["r"] = KEY_R,
    ["s"] = KEY_S,
    ["t"] = KEY_T,
    ["u"] = KEY_U,
    ["v"] = KEY_V,
    ["w"] = KEY_W,
    ["x"] = KEY_X,
    ["y"] = KEY_Y,
    ["z"] = KEY_Z,
    ["kp_0"] = KEY_PAD_0,
    ["kp_1"] = KEY_PAD_1,
    ["kp_2"] = KEY_PAD_2,
    ["kp_3"] = KEY_PAD_3,
    ["kp_4"] = KEY_PAD_4,
    ["kp_5"] = KEY_PAD_5,
    ["kp_6"] = KEY_PAD_6,
    ["kp_7"] = KEY_PAD_7,
    ["kp_8"] = KEY_PAD_8,
    ["kp_9"] = KEY_PAD_9,
    ["kp_divide"] = KEY_PAD_DIVIDE,
    ["kp_multiply"] = KEY_PAD_MULTIPLY,
    ["kp_minus"] = KEY_PAD_MINUS,
    ["kp_plus"] = KEY_PAD_PLUS,
    ["kp_enter"] = KEY_PAD_ENTER,
    ["kp_decimal"] = KEY_PAD_DECIMAL,
    ["lbracket"] = KEY_LBRACKET,
    ["rbracket"] = KEY_RBRACKET,
    ["semicolon"] = KEY_SEMICOLON,
    ["apostrophe"] = KEY_APOSTROPHE,
    ["backquote"] = KEY_BACKQUOTE,
    ["comma"] = KEY_COMMA,
    ["period"] = KEY_PERIOD,
    ["slash"] = KEY_SLASH,
    ["backslash"] = KEY_BACKSLASH,
    ["minus"] = KEY_MINUS,
    ["equal"] = KEY_EQUAL,
    ["enter"] = KEY_ENTER,
    ["space"] = KEY_SPACE,
    ["backspace"] = KEY_BACKSPACE,
    ["tab"] = KEY_TAB,
    ["capslock"] = KEY_CAPSLOCK,
    ["numlock"] = KEY_NUMLOCK,
    ["escape"] = KEY_ESCAPE,
    ["scrolllock"] = KEY_SCROLLLOCK,
    ["insert"] = KEY_INSERT,
    ["delete"] = KEY_DELETE,
    ["home"] = KEY_HOME,
    ["end"] = KEY_END,
    ["pageup"] = KEY_PAGEUP,
    ["pagedown"] = KEY_PAGEDOWN,
    ["break"] = KEY_BREAK,
    ["lshift"] = KEY_LSHIFT,
    ["rshift"] = KEY_RSHIFT,
    ["lalt"] = KEY_LALT,
    ["ralt"] = KEY_RALT,
    ["lctrl"] = KEY_LCONTROL,
    ["rctrl"] = KEY_RCONTROL,
    ["lwin"] = KEY_LWIN,
    ["rwin"] = KEY_RWIN,
    ["app"] = KEY_APP,
    ["up"] = KEY_UP,
    ["left"] = KEY_LEFT,
    ["down"] = KEY_DOWN,
    ["right"] = KEY_RIGHT,
    ["f1"] = KEY_F1,
    ["f2"] = KEY_F2,
    ["f3"] = KEY_F3,
    ["f4"] = KEY_F4,
    ["f5"] = KEY_F5,
    ["f6"] = KEY_F6,
    ["f7"] = KEY_F7,
    ["f8"] = KEY_F8,
    ["f9"] = KEY_F9,
    ["f10"] = KEY_F10,
    ["f11"] = KEY_F11,
    ["f12"] = KEY_F12,
    ["capslocktoggle"] = KEY_CAPSLOCKTOGGLE,
    ["numlocktoggle"] = KEY_NUMLOCKTOGGLE,
    ["scrolllocktoggle"] = KEY_SCROLLLOCKTOGGLE,
    ["last"] = KEY_LAST
}
function lia.keybind.add(k, d, cb)
    local c = isstring(k) and KeybindKeys[string.lower(k)] or k
    d = isstring(d) and L(d) or d
    if not c then return end
    if not istable(cb) or not cb.onPress then
        lia.error(L("keybindAddInvalidCallbackFormat") .. " '" .. tostring(d) .. "'. Must use table with 'onPress' function. (Function: lia.keybind.add)")
        return
    end
    lia.keybind.stored[d] = lia.keybind.stored[d] or {}
    if not lia.keybind.stored[d].value then lia.keybind.stored[d].value = c end
    lia.keybind.stored[d].default = c
    lia.keybind.stored[d].callback = cb.onPress
    lia.keybind.stored[d].release = cb.onRelease
    lia.keybind.stored[d].shouldRun = cb.shouldRun
    lia.keybind.stored[d].serverOnly = cb.serverOnly or false
    lia.keybind.stored[c] = d
end
lia.keybind.add(KEY_NONE, "openInventory", {
    onPress = function()
        local f1Menu = vgui.Create("liaMenu")
        f1Menu:setActiveTab(L("inv"))
    end
})
lia.keybind.add(KEY_NONE, "adminMode", {
    serverOnly = true,
    onPress = function(client)
        if not IsValid(client) then return end
        local steamID = client:SteamID()
        client:ChatPrint(L("adminModeToggle"))
        if client:isStaffOnDuty() then
            local oldCharID = client:getNetVar("OldCharID", 0)
            if oldCharID > 0 then
                local originalPos = client:getNetVar("OriginalPosition")
                if originalPos then
                    client:SetPos(originalPos)
                    client:setNetVar("OriginalPosition", nil)
                end
                net.Start("liaAdminModeSwapCharacter")
                net.WriteInt(oldCharID, 32)
                net.Send(client)
                client:setNetVar("OldCharID", nil)
                lia.log.add(client, "adminMode", oldCharID, L("adminModeLogBack"))
            else
                client:notifyErrorLocalized("noPrevChar")
            end
        else
            local currentChar = client:getChar()
            if currentChar and currentChar:getFaction() ~= "staff" then client:setNetVar("OriginalPosition", client:GetPos()) end
            lia.db.query(string.format("SELECT * FROM lia_characters WHERE steamID = \"%s\"", lia.db.escape(steamID)), function(data)
                for _, row in ipairs(data) do
                    local id = tonumber(row.id)
                    if row.faction == "staff" then
                        client:setNetVar("OldCharID", client:getChar():getID())
                        net.Start("liaAdminModeSwapCharacter")
                        net.WriteInt(id, 32)
                        net.Send(client)
                        lia.log.add(client, "adminMode", id, L("adminModeLogStaff"))
                        return
                    end
                end
                if client:hasPrivilege("createStaffCharacter") then
                    local staffCharData = {
                        steamID = steamID,
                        name = client:steamName(),
                        desc = "",
                        faction = "staff",
                        model = lia.faction.indices["staff"] and lia.faction.indices["staff"].models[1] or "models/Humans/Group02/male_07.mdl"
                    }
                    lia.char.create(staffCharData, function(charID)
                        if IsValid(client) and charID then
                            client:setNetVar("OldCharID", client:getChar():getID())
                            net.Start("liaAdminModeSwapCharacter")
                            net.WriteInt(charID, 32)
                            net.Send(client)
                            lia.log.add(client, "adminMode", charID, L("adminModeLogStaff"))
                            client:notifySuccessLocalized("staffCharCreated")
                        end
                    end)
                else
                    client:notifyErrorLocalized("noStaffChar")
                end
            end)
        end
    end
})
lia.keybind.add(KEY_NONE, "quickTakeItem", {
    serverOnly = true,
    onPress = function(client)
        if not client:getChar() then return end
        local entity = client:getTracedEntity()
        if IsValid(entity) and entity:isItem() then
            if entity:GetPos():Distance(client:GetPos()) > 96 then return end
            local item = entity:getItemTable()
            if item and item.functions and item.functions.take then item:interact("take", client, entity) end
        end
    end
})
lia.keybind.add(KEY_NONE, "convertEntity", {
    onPress = function(client)
        if not IsValid(client) or not client:getChar() then return end
        local trace = client:GetEyeTrace()
        local targetEntity = trace.Entity
        if not IsValid(targetEntity) or targetEntity == client then return end
        if trace.HitPos:Distance(client:GetPos()) > 200 then
            client:notifyErrorLocalized("entityTooFar")
            return
        end
        if targetEntity:IsPlayer() or targetEntity:isItem() or targetEntity:GetClass() == "lia_money" then
            client:notifyErrorLocalized("cannotConvertEntity")
            return
        end
        local hasItemDefinition = false
        local itemUniqueID = ""
        local targetEntityID = targetEntity:GetClass()
        for uniqueID, entityData in pairs(lia.item.itemEntities or {}) do
            if entityData[1] == targetEntityID then
                hasItemDefinition = true
                itemUniqueID = uniqueID
                break
            end
        end
        if not hasItemDefinition then
            client:notifyErrorLocalized("entityNotConvertible")
            return
        end
        local entityData = extractEntityData(targetEntity)
        lia.item.instance(0, itemUniqueID, {}, 1, 1, function(item)
            if not item then return end
            if SERVER then
                item:getEntity():setNetVar("entityData", entityData)
                item:setData("entityClass", targetEntity:GetClass())
                item:setData("entityModel", targetEntity:GetModel())
            end
            local inventory = client:getChar():getInv()
            if inventory then
                inventory:add(item):next(function()
                    if IsValid(targetEntity) then SafeRemoveEntity(targetEntity) end
                    client:notifySuccessLocalized("entityConverted", item:getName())
                end):catch(function(err)
                    if err == "noFit" then
                        item:spawn(client:getItemDropPos())
                        if IsValid(targetEntity) then SafeRemoveEntity(targetEntity) end
                        client:notifySuccessLocalized("entityConvertedGround", item:getName())
                    else
                        client:notifyErrorLocalized("inventoryError")
                    end
                end)
            else
                item:spawn(client:getItemDropPos())
                if IsValid(targetEntity) then SafeRemoveEntity(targetEntity) end
                client:notifySuccessLocalized("entityConvertedGround", item:getName())
            end
        end)
    end,
    shouldRun = function(client) return client:getChar() ~= nil end,
    serverOnly = true
})
if CLIENT then
    hook.Add("PlayerButtonDown", "liaKeybindPress", function(p, b)
        local action = lia.keybind.stored[b]
        if not IsFirstTimePredicted() then return end
        if action and lia.keybind.stored[action] and lia.keybind.stored[action].callback then
            local data = lia.keybind.stored[action]
            if not data.shouldRun or data.shouldRun(p) then
                if data.serverOnly then
                    net.Start("liaKeybindServer")
                    net.WriteString(action)
                    net.WriteEntity(p)
                    net.SendToServer()
                else
                    data.callback(p)
                end
            end
        end
    end)
    hook.Add("PlayerButtonUp", "liaKeybindRelease", function(p, b)
        local action = lia.keybind.stored[b]
        if not IsFirstTimePredicted() then return end
        if action and lia.keybind.stored[action] and lia.keybind.stored[action].release then
            local data = lia.keybind.stored[action]
            if not data.shouldRun or data.shouldRun(p) then
                if data.serverOnly then
                    net.Start("liaKeybindServer")
                    net.WriteString(action .. "_release")
                    net.WriteEntity(p)
                    net.SendToServer()
                else
                    data.release(p)
                end
            end
        end
    end)
    function lia.keybind.get(a, df)
        local act = lia.keybind.stored[a]
        if act then return act.value or act.default or df end
        return df
    end
    function lia.keybind.save()
        local path = "lilia/keybinds.json"
        local d = {}
        for k, v in pairs(lia.keybind.stored) do
            if istable(v) and v.value then d[k] = v.value end
        end
        local j = util.TableToJSON(d, true)
        if j then file.Write(path, j) end
    end
    function lia.keybind.load()
        local path = "lilia/keybinds.json"
        local d = file.Read(path, "DATA")
        if d then
            local s = util.JSONToTable(d)
            for k, v in pairs(s) do
                if lia.keybind.stored[k] then lia.keybind.stored[k].value = v end
            end
        else
            for _, v in pairs(lia.keybind.stored) do
                if istable(v) and v.default then v.value = v.default end
            end
            local out = {}
            for k, v in pairs(lia.keybind.stored) do
                if istable(v) and v.value then out[k] = v.value end
            end
            local json = util.TableToJSON(out, true)
            if json then file.Write(path, json) end
        end
        for k in pairs(lia.keybind.stored) do
            if isnumber(k) then lia.keybind.stored[k] = nil end
        end
        for action, data in pairs(lia.keybind.stored) do
            if istable(data) and data.value then lia.keybind.stored[data.value] = action end
        end
        hook.Run("InitializedKeybinds")
    end
    hook.Add("PopulateConfigurationButtons", "PopulateKeybinds", function(pages)
        local function buildKeybinds(parent)
            parent:Clear()
            local allowEdit = lia.config.get("AllowKeybindEditing", true)
            local sheet = parent:Add("liaSheet")
            sheet:Dock(FILL)
            sheet:SetPlaceholderText(L("searchKeybinds"))
            sheet:SetSpacing(4)
            sheet:SetPadding(4)
            local taken = {}
            for action, data in pairs(lia.keybind.stored) do
                if istable(data) and data.value then taken[data.value] = action end
            end
            local sortedActions = {}
            for action, data in pairs(lia.keybind.stored) do
                if istable(data) then sortedActions[#sortedActions + 1] = action end
            end
            table.sort(sortedActions, function(a, b)
                local la, lb = #tostring(a), #tostring(b)
                if la == lb then return tostring(a) < tostring(b) end
                return la < lb
            end)
            for _, action in ipairs(sortedActions) do
                local data = lia.keybind.stored[action]
                local rowPanel = vgui.Create("SemiTransparentDPanel")
                rowPanel:SetTall(70)
                rowPanel:DockPadding(4, 4, 4, 4)
                rowPanel.Paint = function(_, w, h) lia.derma.rect(0, 0, w, h):Rad(16):Color(Color(0, 0, 0, 200)):Shape(lia.derma.SHAPE_IOS):Shadow(3, 10):Draw() end
                local lbl = rowPanel:Add("DLabel")
                lbl:Dock(FILL)
                lbl:DockMargin(10, 10, 10, 10)
                lbl:SetFont("liaBigFont")
                lbl:SetText("")
                lbl.Paint = function(_, w, h) draw.SimpleText(L(action), "liaBigFont", w / 2, h / 2, lia.color.theme.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) end
                local currentKey = lia.keybind.get(action, KEY_NONE)
                if allowEdit then
                    local combo = rowPanel:Add("liaComboBox")
                    combo:Dock(RIGHT)
                    combo:DockMargin(10, 10, 10, 10)
                    combo:SetWide(200)
                    combo:SetFont("LiliaFont.18")
                    combo:SetValue(input.GetKeyName(currentKey) or "NONE")
                    local choices = {}
                    for name, code in pairs(KeybindKeys) do
                        if not taken[code] or code == currentKey then
                            choices[#choices + 1] = {
                                txt = input.GetKeyName(code) or name,
                                keycode = code
                            }
                        end
                    end
                    table.sort(choices, function(a, b) return a.txt < b.txt end)
                    for _, c in ipairs(choices) do
                        combo:AddChoice(c.txt, c.keycode)
                    end
                    combo.OnSelect = function(_, _, _, newKey)
                        if not newKey then return end
                        for tk, tv in pairs(taken) do
                            if tk == newKey and tv ~= action then
                                combo:SetValue(input.GetKeyName(currentKey) or "NONE")
                                return
                            end
                        end
                        taken[currentKey] = nil
                        if lia.keybind.stored[currentKey] == action then lia.keybind.stored[currentKey] = nil end
                        data.value = newKey
                        lia.keybind.stored[newKey] = action
                        taken[newKey] = action
                        lia.keybind.save()
                        currentKey = newKey
                    end
                    combo:PostInit()
                    local unbindButton = rowPanel:Add("liaButton")
                    unbindButton:Dock(RIGHT)
                    unbindButton:DockMargin(10, 10, 10, 10)
                    unbindButton:SetWide(100)
                    unbindButton:SetFont("liaMediumFont")
                    unbindButton:SetTxt(L("unbind"):upper())
                    unbindButton.DoClick = function()
                        taken[currentKey] = nil
                        if lia.keybind.stored[currentKey] == action then lia.keybind.stored[currentKey] = nil end
                        data.value = KEY_NONE
                        lia.keybind.stored[KEY_NONE] = action
                        lia.keybind.save()
                        combo:SetValue(input.GetKeyName(KEY_NONE) or "NONE")
                        currentKey = KEY_NONE
                    end
                else
                    local textLabel = rowPanel:Add("DLabel")
                    textLabel:Dock(RIGHT)
                    textLabel:DockMargin(10, 10, 10, 10)
                    textLabel:SetFont("liaBigFont")
                    textLabel:SetText("")
                    textLabel.Paint = function(_, w, h) draw.SimpleText(input.GetKeyName(currentKey) or "NONE", "liaBigFont", w / 2, h / 2, lia.color.theme.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) end
                end
                sheet:AddPanelRow(rowPanel, {
                    height = 70,
                    filterText = tostring(action):lower()
                })
            end
            if allowEdit then
                local resetAllBtn = vgui.Create("liaMediumButton")
                resetAllBtn:SetTall(40)
                resetAllBtn:SetText(L("resetAllKeybinds"))
                resetAllBtn.DoClick = function()
                    for action, data in pairs(lia.keybind.stored) do
                        if istable(data) and data.default then
                            if data.value and lia.keybind.stored[data.value] == action then lia.keybind.stored[data.value] = nil end
                            data.value = data.default
                            lia.keybind.stored[data.default] = action
                        end
                    end
                    lia.keybind.save()
                    buildKeybinds(parent)
                end
                sheet:AddPanelRow(resetAllBtn, {
                    height = 40
                })
            end
        end
        pages[#pages + 1] = {
            name = "keybinds",
            drawFunc = buildKeybinds
        }
    end)
end