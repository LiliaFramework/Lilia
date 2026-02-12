--[[
    Folder: Libraries
    File: keybind.md
]]
--[[
    Keybind

    Keyboard binding registration, storage, and execution system for the Lilia framework.
]]
--[[
    Overview:
        The keybind library provides comprehensive functionality for managing keyboard bindings in the Lilia framework. It handles registration, storage, and execution of custom keybinds that can be triggered by players. The library supports both client-side and server-side keybind execution, with automatic networking for server-only keybinds. It includes persistent storage of keybind configurations, user interface for keybind management, and validation to prevent key conflicts. The library operates on both client and server sides, with the client handling input detection and UI, while the server processes server-only keybind actions. It ensures proper key mapping, callback execution, and provides a complete keybind management system for the gamemode.
]]
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

--[[
    Purpose:
        Register a keybind action with callbacks and optional metadata.

    When Called:
        During initialization to expose actions to the keybind system/UI.

    Parameters:
        k (string|number)
            Key code or key name (or actionName when using table config form).
        d (string|table)
            Action name or config table when first arg is action name.
        desc (string|nil)
            Description when using legacy signature.
        cb (table|nil)
            Callback table {onPress, onRelease, shouldRun, serverOnly}.
    Realm:
        Shared

    Example Usage:
        ```lua
            -- Table-based registration with shouldRun and serverOnly.
            lia.keybind.add("toggleMap", {
                keyBind = KEY_M,
                desc = "Open the world map",
                serverOnly = false,
                shouldRun = function(client) return client:Alive() end,
                onPress = function(client)
                    if IsValid(client.mapPanel) then
                        client.mapPanel:Close()
                        client.mapPanel = nil
                    else
                        client.mapPanel = vgui.Create("liaWorldMap")
                    end
                end
            })
        ```
]]
function lia.keybind.add(k, d, desc, cb)
    local actionName, key, description, callbacks, category
    if isstring(k) and istable(d) and desc == nil and cb == nil then
        actionName = k
        local config = d
        key = config.keyBind
        description = config.desc
        category = config.category
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
    lia.keybind.stored[actionName].category = category
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
    shouldRun = function(client) return client:isStaff() end,
    onPress = function(client)
        if not IsValid(client) then return end
        local steamID = client:SteamID()
        client:ChatPrint(L("adminModeToggle"))
        if client:isStaffOnDuty() then
            local oldCharID = client.oldCharID or 0
            if oldCharID > 0 then
                local returnPos = client.ReturnPosition
                net.Start("liaAdminModeSwapCharacter")
                net.WriteInt(oldCharID, 32)
                net.Send(client)
                client.oldCharID = nil
                if returnPos then
                    local hookName = "liaAdminModeReturnPos_" .. client:SteamID64()
                    hook.Add("PostPlayerLoadedChar", hookName, function(ply, character)
                        if ply == client and IsValid(client) and client.ReturnPosition then
                            timer.Simple(0.2, function()
                                if IsValid(client) and client.ReturnPosition then
                                    client:SetPos(client.ReturnPosition)
                                    client.ReturnPosition = nil
                                end
                            end)

                            hook.Remove("PostPlayerLoadedChar", hookName)
                        end
                    end)

                    timer.Simple(5, function() if IsValid(client) then hook.Remove("PostPlayerLoadedChar", hookName) end end)
                end

                lia.log.add(client, "adminMode", oldCharID, L("adminModeLogBack"))
            else
                client:notifyErrorLocalized("noPrevChar")
            end
        else
            local currentChar = client:getChar()
            if currentChar and currentChar:getFaction() ~= "staff" then client.ReturnPosition = client:GetPos() end
            lia.db.query(string.format("SELECT * FROM lia_characters WHERE steamID = \"%s\"", lia.db.escape(steamID)), function(data)
                for _, row in ipairs(data) do
                    local id = tonumber(row.id)
                    if row.faction == "staff" then
                        client.oldCharID = client:getChar():getID()
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
                            client.oldCharID = client:getChar():getID()
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

        if hook.Run("CanTakeEntity", client, targetEntity, itemUniqueID) == false then return end
        local character = client:getChar()
        local inventory = character:getInv()
        if not inventory:canAdd(itemUniqueID) then
            client:notifyErrorLocalized("noSpaceForItem")
            return
        end

        inventory:add(itemUniqueID):next(function(item)
            client:notifyLocalized("entityConverted", item:getName())
            SafeRemoveEntity(targetEntity)
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

    --[[
    Purpose:
        Get the key code assigned to an action, with default fallback.

    When Called:
        When populating keybind UI or triggering actions manually.

    Parameters:
        a (string)
            Action name.
        df (number|nil)
            Default key code if not set.

    Returns:
        number|nil

    Realm:
        Client

    Example Usage:
        ```lua
            local key = lia.keybind.get("openInventory", KEY_I)
            print("Inventory key is:", input.GetKeyName(key))
        ```
    ]]
    function lia.keybind.get(a, df)
        local act = lia.keybind.stored[a]
        if act then return act.value or act.default or df end
        return df
    end

    --[[
    Purpose:
        Persist current keybind overrides to disk.

    When Called:
        After users change keybinds in the config UI.

    Parameters:
        None
    Realm:
        Client

    Example Usage:
        ```lua
            lia.keybind.save()
        ```
    ]]
    function lia.keybind.save()
        local path = "lilia/keybinds.json"
        local d = {}
        for k, v in pairs(lia.keybind.stored) do
            if istable(v) and v.value then d[k] = v.value end
        end

        local j = util.TableToJSON(d, true)
        if j then file.Write(path, j) end
    end

    --[[
    Purpose:
        Load keybind overrides from disk, falling back to defaults if missing.

    When Called:
        On client init/config load; rebuilds reverse lookup table for keys.

    Parameters:
        None
    Realm:
        Client

    Example Usage:
        ```lua
            hook.Add("Initialize", "LoadLiliaKeybinds", lia.keybind.load)
        ```
    ]]
    function lia.keybind.load()
        local path = "lilia/keybinds.json"
        local d = file.Read(path, "DATA")
        if d then
            local s = util.JSONToTable(d)
            for k, v in pairs(s) do
                if lia.keybind.stored[k] then
                    if isstring(v) then
                        local keyCode = KeybindKeys[string.lower(v)]
                        lia.keybind.stored[k].value = keyCode or KEY_NONE
                    else
                        lia.keybind.stored[k].value = v
                    end
                end
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
        local function AddHeader(scroll, text)
            local header = scroll:Add("DPanel")
            header:Dock(TOP)
            header:SetTall(35)
            header:DockMargin(0, 5, 0, 5)
            header.Paint = function(me, w, h)
                local accent = lia.color.theme.accent or lia.config.get("Color") or Color(0, 150, 255)
                surface.SetDrawColor(accent)
                surface.DrawRect(0, h - 2, w, 2)
            end

            local label = header:Add("DLabel")
            label:Dock(LEFT)
            label:SetText(L(text))
            label:SetFont("LiliaFont.22")
            label:SetTextColor(lia.color.theme.text or color_white)
            label:SizeToContents()
            label:DockMargin(5, 0, 0, 0)
        end

        local function AddKeybindField(scroll, action, data, allowEdit, taken, refreshFunc)
            local p = scroll:Add("DPanel")
            p:Dock(TOP)
            p:SetTall(45)
            p:DockMargin(0, 0, 0, 5)
            p.Paint = function(s, w, h) lia.derma.rect(0, 0, w, h):Rad(6):Color(Color(35, 38, 45, 180)):Shape(lia.derma.SHAPE_IOS):Draw() end
            local l = p:Add("DLabel")
            l:Dock(LEFT)
            l:DockMargin(15, 0, 0, 0)
            l:SetWidth(250)
            l:SetText(L(action))
            l:SetFont("LiliaFont.18")
            l:SetTextColor(lia.color.theme.text or color_white)
            l:SetContentAlignment(4)
            l:SetTooltip(data.description or "")
            local currentKey = lia.keybind.get(action, KEY_NONE)
            if allowEdit then
                local combo = p:Add("liaComboBox")
                combo:Dock(RIGHT)
                combo:SetWidth(200)
                combo:DockMargin(0, 8, 15, 8)
                combo:SetFont("LiliaFont.18")
                local currentKeyName = isnumber(currentKey) and (currentKey == KEY_NONE and "NONE" or input.GetKeyName(currentKey)) or "NONE"
                combo:SetValue(currentKeyName)
                local choices = {}
                for name, code in pairs(KeybindKeys) do
                    if not taken[code] or code == currentKey or code == KEY_NONE then
                        local displayName = input.GetKeyName(code) or name
                        if code == KEY_NONE then displayName = "NONE" end
                        table.insert(choices, {
                            txt = displayName,
                            keycode = code
                        })
                    end
                end

                table.sort(choices, function(a, b)
                    if a.txt == "NONE" then return true end
                    if b.txt == "NONE" then return false end
                    return tostring(a.txt or ""):lower() < tostring(b.txt or ""):lower()
                end)

                local hasNone = false
                for _, c in ipairs(choices) do
                    if c.keycode == KEY_NONE then
                        hasNone = true
                        break
                    end
                end

                if not hasNone then
                    table.insert(choices, 1, {
                        txt = "NONE",
                        keycode = KEY_NONE
                    })
                end

                for _, c in ipairs(choices) do
                    combo:AddChoice(c.txt, c.keycode)
                end

                combo.OnSelect = function(_, _, newKey)
                    if newKey == nil then return end
                    if isstring(newKey) then
                        local code = KeybindKeys[string.lower(newKey)]
                        newKey = code or KEY_NONE
                    end

                    if newKey ~= KEY_NONE then
                        for tk, tv in pairs(taken) do
                            if tk == newKey and tv ~= action then
                                combo:SetValue(currentKeyName)
                                return
                            end
                        end
                    end

                    local keybindData = lia.keybind.stored[action]
                    local oldKey = keybindData.value
                    if oldKey then if lia.keybind.stored[oldKey] == action then lia.keybind.stored[oldKey] = nil end end
                    keybindData.value = newKey
                    lia.keybind.save()
                    if refreshFunc then refreshFunc() end
                    local client = LocalPlayer()
                    if IsValid(client) then client:notifySuccess(L("keybindChanged", action, input.GetKeyName(newKey) or "NONE")) end
                end
            else
                local lKey = p:Add("DLabel")
                lKey:Dock(RIGHT)
                lKey:DockMargin(0, 0, 15, 0)
                lKey:SetWidth(200)
                lKey:SetText(isnumber(currentKey) and (currentKey == KEY_NONE and "NONE" or input.GetKeyName(currentKey)) or "NONE")
                lKey:SetFont("LiliaFont.18")
                lKey:SetTextColor(lia.color.theme.text)
                lKey:SetContentAlignment(6)
            end
        end

        pages[#pages + 1] = {
            name = "keybinds",
            drawFunc = function(parent)
                parent:Clear()
                local allowEdit = lia.config.get("AllowKeybindEditing", true)
                local searchEntry = parent:Add("liaEntry")
                searchEntry:Dock(TOP)
                searchEntry:SetTall(35)
                searchEntry:DockMargin(10, 10, 10, 10)
                searchEntry:SetPlaceholderText(L("searchKeybinds") or "Search keybinds...")
                searchEntry:SetFont("LiliaFont.18")
                local scroll = parent:Add("liaScrollPanel")
                scroll:Dock(FILL)
                scroll:GetCanvas():DockPadding(10, 10, 10, 10)
                local function populate(filter)
                    local taken = {}
                    for action, data in pairs(lia.keybind.stored) do
                        if istable(data) and data.value then taken[data.value] = action end
                    end

                    scroll:Clear()
                    filter = filter and filter:len() > 0 and filter:lower() or nil
                    local categories = {}
                    local keys = {}
                    for k in pairs(lia.keybind.stored) do
                        keys[#keys + 1] = k
                    end

                    table.sort(keys, function(a, b) return tostring(a) < tostring(b) end)
                    for _, k in ipairs(keys) do
                        local data = lia.keybind.stored[k]
                        if istable(data) then
                            local cat = data.category or "Misc"
                            categories[cat] = categories[cat] or {}
                            table.insert(categories[cat], {
                                key = k,
                                data = data
                            })
                        end
                    end

                    local sortedCategories = {}
                    for cat in pairs(categories) do
                        table.insert(sortedCategories, cat)
                    end

                    table.sort(sortedCategories)
                    for _, cat in ipairs(sortedCategories) do
                        local items = categories[cat]
                        table.sort(items, function(a, b) return tostring(a.key) < tostring(b.key) end)
                        local visibleItems = {}
                        for _, item in ipairs(items) do
                            local name = L(item.key) or item.key
                            local desc = item.data.description or ""
                            if not filter or name:lower():find(filter, 1, true) or desc:lower():find(filter, 1, true) or cat:lower():find(filter, 1, true) then table.insert(visibleItems, item) end
                        end

                        if #visibleItems > 0 then
                            AddHeader(scroll, cat)
                            for _, item in ipairs(visibleItems) do
                                AddKeybindField(scroll, item.key, item.data, allowEdit, taken, function() populate(filter) end)
                            end
                        end
                    end

                    if allowEdit then
                        local resetBtn = scroll:Add("liaButton")
                        resetBtn:Dock(TOP)
                        resetBtn:DockMargin(10, 20, 10, 10)
                        resetBtn:SetTall(40)
                        resetBtn:SetText(L("resetAllKeybinds"))
                        resetBtn.DoClick = function()
                            for action, data in pairs(lia.keybind.stored) do
                                if istable(data) and data.default then data.value = data.default end
                            end

                            lia.keybind.save()
                            populate(filter)
                        end
                    end
                end

                searchEntry:SetUpdateOnType(true)
                searchEntry.OnTextChanged = function(me, text) populate(text) end
                populate(nil)
            end
        }
    end)
end
