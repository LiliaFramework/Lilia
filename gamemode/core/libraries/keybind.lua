﻿lia.keybind = lia.keybind or {}
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
function lia.keybind.add(k, d, desc, cb)
    local actionName, key, description, callbacks
    if isstring(k) and istable(d) and desc == nil and cb == nil then
        actionName = k
        local config = d
        key = config.keyBind
        description = config.desc
        callbacks = {
            onPress = config.onPress,
            onRelease = config.onRelease,
            shouldRun = config.shouldRun,
            serverOnly = config.serverOnly
        }
    else
        key = k
        actionName = d
        description = desc
        callbacks = cb
    end
    local c = isstring(key) and KeybindKeys[string.lower(key)] or key
    description = isstring(description) and L(description) or description
    if not c then return end
    if not istable(callbacks) or not callbacks.onPress then
        lia.error(L("keybindAddInvalidCallbackFormat") .. " '" .. tostring(actionName) .. "'. Must use table with 'onPress' function. (Function: lia.keybind.add)")
        return
    end
    lia.keybind.stored[actionName] = lia.keybind.stored[actionName] or {}
    if not lia.keybind.stored[actionName].value then lia.keybind.stored[actionName].value = c end
    lia.keybind.stored[actionName].default = c
    lia.keybind.stored[actionName].description = description
    lia.keybind.stored[actionName].callback = callbacks.onPress
    lia.keybind.stored[actionName].release = callbacks.onRelease
    lia.keybind.stored[actionName].shouldRun = callbacks.shouldRun
    lia.keybind.stored[actionName].serverOnly = callbacks.serverOnly or false
    lia.keybind.stored[c] = actionName
end
lia.keybind.add("openInventory", {
    keyBind = KEY_NONE,
    desc = "openInventoryDesc",
    onPress = function()
        local f1Menu = vgui.Create("liaMenu")
        f1Menu:setActiveTab(L("inv"))
    end
})
lia.keybind.add("adminMode", {
    keyBind = KEY_NONE,
    desc = "adminModeDesc",
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
lia.keybind.add("quickTakeItem", {
    keyBind = KEY_NONE,
    desc = "quickTakeItemDesc",
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
lia.keybind.add("convertEntity", {
    keyBind = KEY_NONE,
    desc = "convertEntityDesc",
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
        local KeybindFormatting = {
            Keybind = function(action, data, parent, allowEdit, taken, buildKeybinds)
                local container = vgui.Create("DPanel", parent)
                container:SetTall(220)
                container:Dock(TOP)
                container:DockMargin(0, 60, 0, 10)
                container.Paint = function(_, w, h) lia.derma.rect(0, 0, w, h):Rad(16):Color(Color(40, 40, 50, 100)):Shape(lia.derma.SHAPE_IOS):Draw() end
                local panel = container:Add("DPanel")
                panel:Dock(FILL)
                panel:DockMargin(300, 5, 300, 5)
                panel.Paint = function(_, w, h) lia.derma.rect(0, 0, w, h):Rad(16):Color(Color(60, 60, 70, 80)):Shape(lia.derma.SHAPE_IOS):Draw() end
                local label = vgui.Create("DLabel", panel)
                label:Dock(TOP)
                label:SetTall(45)
                label:DockMargin(0, 20, 0, 0)
                label:SetText("")
                label.Paint = function(_, w, h) draw.SimpleText(L(action), "LiliaFont.36", w / 2, h / 2, lia.color.theme.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) end
                local description = vgui.Create("DLabel", panel)
                description:Dock(TOP)
                description:SetTall(35)
                description:DockMargin(0, 10, 0, 0)
                description:SetText("")
                description.Paint = function(_, w, h) draw.SimpleText(data.description or "", "LiliaFont.24", w / 2, h / 2, lia.color.theme.gray, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) end
                local currentKey = lia.keybind.get(action, KEY_NONE)
                if allowEdit then
                    local combo = panel:Add("liaComboBox")
                    combo:Dock(TOP)
                    combo:DockMargin(300, 25, 300, 15)
                    combo:SetTall(60)
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
                    combo.OnSelect = function(_, _, newKey)
                        if not newKey then return end
                        for tk, tv in pairs(taken) do
                            if tk == newKey and tv ~= action then
                                combo:SetValue(input.GetKeyName(currentKey) or "NONE")
                                return
                            end
                        end
                        taken[currentKey] = nil
                        if lia.keybind.stored[currentKey] == action then lia.keybind.stored[currentKey] = nil end
                        local keybindData = lia.keybind.stored[action]
                        keybindData.value = newKey
                        lia.keybind.stored[newKey] = action
                        taken[newKey] = action
                        lia.keybind.save()
                        buildKeybinds(parent)
                    end
                    combo:PostInit()
                else
                    local keyLabel = vgui.Create("DLabel", panel)
                    keyLabel:Dock(TOP)
                    keyLabel:DockMargin(10, 25, 10, 15)
                    keyLabel:SetTall(60)
                    keyLabel:SetText("")
                    keyLabel.Paint = function(_, w, h) draw.SimpleText(input.GetKeyName(currentKey) or "NONE", "LiliaFont.18", w / 2, h / 2, lia.color.theme.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) end
                end
                return container
            end
        }
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
                local keybindPanel = KeybindFormatting.Keybind(action, data, sheet.canvas, allowEdit, taken, buildKeybinds)
                keybindPanel:Dock(TOP)
                keybindPanel:DockMargin(10, 10, 10, 0)
                keybindPanel.Paint = function(_, w, h) lia.derma.rect(0, 0, w, h):Rad(16):Color(Color(50, 50, 60, 80)):Shape(lia.derma.SHAPE_IOS):Draw() end
                sheet:AddPanelRow(keybindPanel, {
                    height = 220,
                    filterText = tostring(action):lower()
                })
            end
            if allowEdit then
                local resetAllBtn = vgui.Create("liaMediumButton")
                resetAllBtn:Dock(TOP)
                resetAllBtn:DockMargin(10, 20, 10, 0)
                resetAllBtn:SetTall(60)
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
                    height = 60
                })
            end
        end
        pages[#pages + 1] = {
            name = "keybinds",
            drawFunc = buildKeybinds
        }
    end)
end