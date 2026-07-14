--[[
    Folder: Developer - Libraries
    File: lia.keybind.md
]]
--[[
    Keybind

    Keybind helpers for Lilia action registration, configurable key assignment, keybind persistence, reserved-key handling, and keybind configuration UI integration.
]]
--[[
    Overview:
        The keybind library centralizes shared and clientside keybind behavior under `lia.keybind`. It registers named actions with press and release callbacks, supports default and saved key codes, localizes action descriptions and categories, detects reserved Garry's Mod bind keys, saves and loads client keybind choices, and adds the keybind editor to the configuration menu.
]]
--[[
    Hooks:
        AddReservedKeybinds(table reserved)

    Purpose:
        Allows plugins or modules to add extra reserved key codes before keybind choices are displayed.

    Category:
        Keybinds

    Parameters:
        reserved (table)
            Lookup table keyed by numeric key code. Set reserved[keyCode] to true to reserve a key.

    Example Usage:
        ```lua
        hook.Add("AddReservedKeybinds", "liaExampleAddReservedKeybinds", function(reserved)
            print("[MyModule] handled AddReservedKeybinds")
        end)
        ```

    Realm:
        Client
]]
--[[
    Hooks:
        CanTakeEntity(Player client, Entity targetEntity, string itemUniqueID)

    Purpose:
        Determines whether the convert-entity keybind may turn a traced world entity into an inventory item.

    Category:
        Inventory

    Parameters:
        client (Player)
            The player attempting the conversion.

        targetEntity (Entity)
            The traced entity that would be removed and converted.

        itemUniqueID (string)
            The item unique ID mapped from the entity class.

    Returns:
        boolean|nil
            Return false to block the conversion. Returning nil allows the default behavior to continue.

    Example Usage:
        ```lua
        hook.Add("CanTakeEntity", "liaExampleCanTakeEntity", function(client, targetEntity, itemUniqueID)
            if targetEntity:IsOnFire() then
                return false
            end
        end)
        ```

    Realm:
        Server
]]
--[[
    Hooks:
        InitializedKeybinds()

    Purpose:
        Runs after saved keybinds are loaded, numeric key lookups are rebuilt, and reserved keys are generated.

    Category:
        Keybinds

    Example Usage:
        ```lua
        hook.Add("InitializedKeybinds", "liaExampleInitializedKeybinds", function()
            print("[MyModule] handled InitializedKeybinds")
        end)
        ```

    Realm:
        Client
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
    ["ins"] = KEY_INSERT,
    ["delete"] = KEY_DELETE,
    ["del"] = KEY_DELETE,
    ["home"] = KEY_HOME,
    ["end"] = KEY_END,
    ["pageup"] = KEY_PAGEUP,
    ["pgup"] = KEY_PAGEUP,
    ["pagedown"] = KEY_PAGEDOWN,
    ["pgdn"] = KEY_PAGEDOWN,
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

local KeybindNamesByCode = {}
for name, code in pairs(KeybindKeys) do
    if isnumber(code) and code ~= KEY_FIRST and code ~= KEY_LAST and KeybindNamesByCode[code] == nil then KeybindNamesByCode[code] = name end
end

local function localizeKeybindLabel(value, ...)
    if not isstring(value) then return value end
    local resolved = lia.lang.resolveToken(value, ...)
    if resolved ~= value then return resolved end
    return L(value, ...)
end

lia.keybind.localizeValue = localizeKeybindLabel
--[[
    Purpose:
        Registers a keybind action and stores its default key, localized display metadata, press/release callbacks, optional run condition, and server-only behavior.

    Parameters:
        k (string|number)
            The action name when using the configuration-table format, or the key code/key name when using the legacy argument format.
        d (table|string)
            The keybind configuration table when k is an action name, or the action name when using the legacy argument format.
        desc (string|nil)
            Optional description used by the legacy argument format.
        cb (table|nil)
            Optional callback table used by the legacy argument format. Must include onPress and may include onRelease, shouldRun, and serverOnly.

    Returns:
        nil

    Example Usage:
        ```lua
        lia.keybind.add("toggleExample", {
            keyBind = KEY_F6,
            desc = "@toggleExampleDesc",
            category = "misc",
            onPress = function(client)
                client:notify("Pressed example keybind.")
            end
        })
        ```

    Realm:
        Shared
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
    if not c then return end
    if not istable(callbacks) or not callbacks.onPress then
        lia.error(L("keybindAddInvalidCallbackFormat") .. " '" .. tostring(actionName) .. "'. Must use table with 'onPress' function. (Function: lia.keybind.add)")
        return
    end

    lia.keybind.stored[actionName] = lia.keybind.stored[actionName] or {}
    if not lia.keybind.stored[actionName].value then lia.keybind.stored[actionName].value = c end
    lia.keybind.stored[actionName].default = c
    lia.keybind.stored[actionName].rawDescription = description
    lia.keybind.stored[actionName].description = isstring(description) and localizeKeybindLabel(description) or description
    lia.keybind.stored[actionName].rawCategory = category
    lia.keybind.stored[actionName].category = isstring(category) and localizeKeybindLabel(category) or category
    lia.keybind.stored[actionName].callback = callbacks.onPress
    lia.keybind.stored[actionName].release = callbacks.onRelease
    lia.keybind.stored[actionName].shouldRun = callbacks.shouldRun
    lia.keybind.stored[actionName].serverOnly = callbacks.serverOnly or false
    lia.keybind.stored[c] = actionName
end

--[[
    Purpose:
        Gets the localized display description for a registered keybind action.

    Parameters:
        action (string)
            The keybind action identifier.

    Returns:
        string
            The localized action description, or an empty string if the action is not registered.

    Example Usage:
        ```lua
        local description = lia.keybind.getDisplayDescription("openInventory")
        ```

    Realm:
        Shared
]]
function lia.keybind.getDisplayDescription(action)
    local data = lia.keybind.stored[action]
    if not data then return "" end
    local value = data.rawDescription or data.description or ""
    return isstring(value) and localizeKeybindLabel(value) or value
end

--[[
    Purpose:
        Gets the localized display category for a registered keybind action.

    Parameters:
        action (string)
            The keybind action identifier.

    Returns:
        string
            The localized action category, or the localized miscellaneous category when no category is set.

    Example Usage:
        ```lua
        local category = lia.keybind.getDisplayCategory("openInventory")
        ```

    Realm:
        Shared
]]
function lia.keybind.getDisplayCategory(action)
    local data = lia.keybind.stored[action]
    if not data then return localizeKeybindLabel("misc") end
    local value = data.rawCategory or data.category or "misc"
    return isstring(value) and localizeKeybindLabel(value) or value
end

lia.keybind.add("openInventory", {
    keyBind = KEY_NONE,
    desc = "@openInventoryDesc",
    onPress = function()
        local f1Menu = vgui.Create("liaMenu")
        f1Menu:setActiveTab(L("inv"))
    end
})

lia.keybind.add("adminMode", {
    keyBind = KEY_NONE,
    desc = "@adminModeDesc",
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
            if currentChar and currentChar:getFaction() ~= FACTION_STAFF then client.ReturnPosition = client:GetPos() end
            lia.db.query(string.format("SELECT * FROM lia_characters WHERE steamID = \"%s\"", lia.db.escape(steamID)), function(data)
                for _, row in ipairs(data) do
                    local id = tonumber(row.id)
                    if row.faction == "staff" or tonumber(row.faction) == FACTION_STAFF then
                        client.oldCharID = client:getChar():getID()
                        net.Start("liaAdminModeSwapCharacter")
                        net.WriteInt(id, 32)
                        net.Send(client)
                        lia.log.add(client, "adminMode", id, L("adminModeLogStaff"))
                        return
                    end
                end

                local canCreateStaffCharacter = client:hasPrivilege("createStaffCharacter")
                if canCreateStaffCharacter then
                    local staffCharData = {
                        steamID = steamID,
                        name = client:steamName(),
                        desc = "",
                        faction = FACTION_STAFF,
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
    desc = "@quickTakeItemDesc",
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
    desc = "@convertEntityDesc",
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
    local GMODDefaultBindNames = {"+forward", "+back", "+moveleft", "+moveright", "+use", "+jump", "+duck", "+walk", "+speed", "+reload", "impulse 100", "+showscores", "messagemode", "messagemode2", "+menu_context", "+menu", "slot1", "slot2", "slot3", "slot4", "slot5", "slot6", "slot7", "slot8", "slot9", "slot0", "undo", "+zoom",}
    --[[
    Purpose:
        Builds the clientside reserved-key lookup from Garry's Mod default bindings and entries added through AddReservedKeybinds.

    Parameters:
        None

    Returns:
        nil

    Example Usage:
        ```lua
        lia.keybind.buildReservedKeys()
        ```

    Realm:
        Client
]]
    function lia.keybind.buildReservedKeys()
        local reserved = {}
        for _, bindName in ipairs(GMODDefaultBindNames) do
            local keyName = input.LookupBinding(bindName)
            if isstring(keyName) and keyName ~= "" then
                local code = KeybindKeys[string.lower(keyName)]
                if isnumber(code) and code ~= KEY_NONE then reserved[code] = true end
            end
        end

        hook.Run("AddReservedKeybinds", reserved)
        lia.keybind.reservedKeys = reserved
    end

    --[[
    Purpose:
        Checks whether a numeric key code is currently marked as reserved by the keybind system.

    Parameters:
        keyCode (number)
            The key code to check.

    Returns:
        boolean
            True if the key is reserved, otherwise false.

    Example Usage:
        ```lua
        if lia.keybind.isKeyReserved(KEY_F1) then return end
        ```

    Realm:
        Client
]]
    function lia.keybind.isKeyReserved(keyCode)
        if not lia.keybind.reservedKeys then return false end
        return lia.keybind.reservedKeys[keyCode] == true
    end

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
        Returns the selected key code for a registered keybind action, falling back to the action default or a provided fallback value.

    Parameters:
        a (string)
            The keybind action identifier.
        df (any)
            Fallback value returned when the action is not registered or has no stored/default key.

    Returns:
        any
            The selected key code, default key code, or fallback value.

    Example Usage:
        ```lua
        local keyCode = lia.keybind.get("openInventory", KEY_NONE)
        ```

    Realm:
        Client
]]
    function lia.keybind.get(a, df)
        local act = lia.keybind.stored[a]
        if act then return act.value or act.default or df end
        return df
    end

    --[[
    Purpose:
        Saves current clientside keybind values to `data/lilia/keybinds.json`.

    Parameters:
        None

    Returns:
        nil

    Example Usage:
        ```lua
        lia.keybind.save()
        ```

    Realm:
        Client
]]
    function lia.keybind.save()
        local path = "lilia/keybinds.json"
        local d = {}
        for k, v in pairs(lia.keybind.stored) do
            if istable(v) and v.value then d[k] = v.value end
        end

        local j = util.TableToJSON(d)
        if j then
            local ok = file.Write(path, j)
            MsgC(Color(255, 200, 0), "[Keybind Save] " .. path .. " | " .. tostring(ok) .. " | " .. j .. "\n")
        end
    end

    --[[
    Purpose:
        Loads clientside keybind values from `data/lilia/keybinds.json`, applies defaults when no save exists, rebuilds numeric key lookups, rebuilds reserved keys, and runs InitializedKeybinds.

    Parameters:
        None

    Returns:
        nil

    Example Usage:
        ```lua
        lia.keybind.load()
        ```

    Realm:
        Client
]]
    function lia.keybind.load()
        local path = "lilia/keybinds.json"
        local d = file.Read(path, "DATA")
        if d then
            local s = util.JSONToTable(d)
            if s then
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
            end
        else
            for _, v in pairs(lia.keybind.stored) do
                if istable(v) and v.default then v.value = v.default end
            end

            local out = {}
            for k, v in pairs(lia.keybind.stored) do
                if istable(v) and v.value then out[k] = v.value end
            end

            local json = util.TableToJSON(out)
            if json then file.Write(path, json) end
        end

        for k in pairs(lia.keybind.stored) do
            if isnumber(k) then lia.keybind.stored[k] = nil end
        end

        for action, data in pairs(lia.keybind.stored) do
            if istable(data) and data.value then lia.keybind.stored[data.value] = action end
        end

        lia.keybind.buildReservedKeys()
        hook.Run("InitializedKeybinds")
    end

    hook.Add("PopulateConfigurationButtons", "PopulateKeybinds", function(pages)
        local uiColors = {
            bg = Color(5, 18, 23, 220),
            bgSoft = Color(7, 20, 25, 237),
            row = Color(10, 25, 30, 232),
            rowHover = Color(16, 34, 40, 235),
            selected = Color(13, 30, 35, 225),
            border = Color(45, 190, 170, 78),
            text = Color(242, 247, 247),
            muted = Color(155, 178, 179),
            dim = Color(100, 120, 122),
            accent = Color(45, 190, 170),
            accentSoft = Color(45, 190, 170, 28)
        }

        local preferredCategories = {"Core", "Inventory", "Interaction", "Communication", "Admin", "UI / Menus", "Misc"}
        local categoryIcons = {}
        local function getAccent(alpha)
            local theme = lia.color and lia.color.theme or {}
            local color = theme.accent or theme.theme or lia.config and lia.config.get and lia.config.get("Color") or uiColors.accent
            if istable(color) and color.r and color.g and color.b then return Color(color.r, color.g, color.b, alpha or color.a or 255) end
            return Color(uiColors.accent.r, uiColors.accent.g, uiColors.accent.b, alpha or uiColors.accent.a or 255)
        end

        local function getTextColor(alpha)
            local theme = lia.color and lia.color.theme or {}
            local color = theme.text or uiColors.text
            if istable(color) and color.r and color.g and color.b then return Color(color.r, color.g, color.b, alpha or color.a or 255) end
            return Color(uiColors.text.r, uiColors.text.g, uiColors.text.b, alpha or uiColors.text.a or 255)
        end

        local function rounded(x, y, w, h, r, color)
            if lia.derma and lia.derma.rect and lia.derma.SHAPE_IOS then
                lia.derma.rect(x, y, w, h):Rad(r or 0):Color(color):Shape(lia.derma.SHAPE_IOS):Draw()
                return
            end

            draw.RoundedBox(r or 0, x, y, w, h, color)
        end

        local function outline(x, y, w, h, color)
            if lia.derma and lia.derma.rect and lia.derma.SHAPE_IOS then
                lia.derma.rect(x, y, w, h):Rad(6):Color(color):Shape(lia.derma.SHAPE_IOS):Outline(1):Draw()
                return
            end

            surface.SetDrawColor(color)
            surface.DrawOutlinedRect(x, y, w, h)
        end

        local function styleScroll(scroll)
            local bar = scroll:GetVBar()
            if not IsValid(bar) then return end
            bar:SetWide(6)
            bar.Paint = function(_, w, h) rounded(2, 0, w - 2, h, 4, Color(255, 255, 255, 4)) end
            bar.btnGrip.Paint = function(_, w, h) rounded(1, 0, w - 1, h, 4, Color(getAccent().r, getAccent().g, getAccent().b, 185)) end
            bar.btnUp.Paint = function() end
            bar.btnDown.Paint = function() end
        end

        local function SetStyledTooltip(panel, text)
            if not text or text == "" then return end
            panel:SetTooltip(text)
            local oldSetTooltip = panel.SetTooltip
            function panel:SetTooltip(tooltipText)
                oldSetTooltip(self, tooltipText)
                timer.Simple(0, function()
                    if not IsValid(self) then return end
                    local tooltip = vgui.GetTooltipPanel()
                    if IsValid(tooltip) and not tooltip.LiliaStyled then
                        tooltip.LiliaStyled = true
                        tooltip:SetTextColor(uiColors.text)
                        function tooltip:Paint(w, h)
                            rounded(0, 0, w, h, 8, uiColors.bg)
                            outline(0, 0, w, h, Color(getAccent().r, getAccent().g, getAccent().b, 135))
                        end
                    end
                end)
            end
        end

        local function getDisplayKeyName(keycode, fallbackName)
            if not isnumber(keycode) or keycode == KEY_NONE then return "NONE" end
            local keyName = input.GetKeyName(keycode)
            if isstring(keyName) and keyName ~= "" then return string.upper(tostring(keyName)) end
            local resolvedFallback = fallbackName or KeybindNamesByCode[keycode]
            if isstring(resolvedFallback) and resolvedFallback ~= "" then return string.upper(tostring(resolvedFallback)) end
            return tostring(keycode)
        end

        local function getKeyChoiceSortKey(displayName, keycode)
            local normalizedCode = isnumber(keycode) and keycode or KEY_NONE
            return string.format("%s:%s:%08d", normalizedCode == KEY_NONE and "0" or "1", tostring(displayName or ""):lower(), normalizedCode + 32768)
        end

        local function getRawCategory(data)
            return data.rawCategory or data.category or "Misc"
        end

        local function getVisualCategory(action, data)
            local raw = tostring(getRawCategory(data) or "Misc")
            local localized = tostring(localizeKeybindLabel(raw) or raw)
            local lowerAction = tostring(action or ""):lower()
            local lowerCategory = localized:lower()
            if lowerCategory:find("inventory", 1, true) then return "Inventory" end
            if lowerCategory:find("interact", 1, true) then return "Interaction" end
            if lowerCategory:find("commun", 1, true) or lowerCategory:find("chat", 1, true) then return "Communication" end
            if lowerCategory:find("admin", 1, true) or lowerCategory:find("staff", 1, true) then return "Admin" end
            if lowerCategory:find("menu", 1, true) or lowerCategory:find("ui", 1, true) then return "UI / Menus" end
            if lowerCategory:find("misc", 1, true) then return "Misc" end
            if lowerAction:find("inventory", 1, true) or lowerAction:find("item", 1, true) then return "Inventory" end
            if lowerAction:find("convert", 1, true) or lowerAction:find("interact", 1, true) or lowerAction:find("take", 1, true) then return "Interaction" end
            if lowerAction:find("admin", 1, true) or lowerAction:find("staff", 1, true) then return "Admin" end
            if lowerAction:find("menu", 1, true) or lowerAction:find("action", 1, true) then return "Core" end
            return localized ~= "" and localized or "Misc"
        end

        local function sortCategories(categories)
            local sorted = {}
            local exists = {}
            for _, category in ipairs(preferredCategories) do
                if categories[category] then
                    sorted[#sorted + 1] = category
                    exists[category] = true
                end
            end

            local remaining = {}
            for category in pairs(categories) do
                if not exists[category] then remaining[#remaining + 1] = category end
            end

            table.sort(remaining, function(a, b) return tostring(a):lower() < tostring(b):lower() end)
            for _, category in ipairs(remaining) do
                sorted[#sorted + 1] = category
            end
            return sorted
        end

        local function makeButton(parent, text, width, primary)
            local button = parent:Add("DButton")
            button:SetText("")
            button:SetWide(width or 140)
            button:SetCursor("hand")
            button.Paint = function(s, w, h)
                local accent = getAccent(primary and 205 or 105)
                local fill = primary and Color(accent.r, accent.g, accent.b, s:IsHovered() and 230 or 205) or s:IsHovered() and uiColors.rowHover or uiColors.bgSoft
                rounded(0, 0, w, h, 6, fill)
                outline(0, 0, w, h, Color(accent.r, accent.g, accent.b, s:IsHovered() and 185 or 105))
                draw.SimpleText(text, "LiliaFont.18", w * 0.5, h * 0.5, getTextColor(), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            return button
        end

        local function makeSection(parent, text, icon, count)
            local header = parent:Add("DPanel")
            header:Dock(TOP)
            header:SetTall(32)
            header:DockMargin(0, 8, 0, 0)
            header.Paint = function(_, w, h)
                local accent = getAccent()
                draw.SimpleText(string.upper(tostring(text or "")), "LiliaFont.18", 10, h * 0.52, Color(accent.r, accent.g, accent.b, 245), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                draw.SimpleText(tostring(count or 0) .. " keybinds", "LiliaFont.16", w - 10, h * 0.52, uiColors.muted, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
                surface.SetDrawColor(accent.r, accent.g, accent.b, 165)
                surface.DrawRect(0, h - 2, w, 1)
            end
            return header
        end

        local function buildTakenLookup()
            local taken = {}
            local total = 0
            for action, data in pairs(lia.keybind.stored) do
                if istable(data) then
                    total = total + 1
                    if isnumber(data.value) and data.value ~= KEY_NONE then taken[data.value] = action end
                end
            end
            return taken, total
        end

        local function countModified()
            local count = 0
            for _, data in pairs(lia.keybind.stored) do
                if istable(data) and data.default ~= nil and data.value ~= data.default then count = count + 1 end
            end
            return count
        end

        local function addKeybindField(scroll, action, data, allowEdit, taken, refreshFunc)
            local description = tostring(lia.keybind.getDisplayDescription(action) or "")
            local displayName = tostring(L(action) or action)
            local row = scroll:Add("DPanel")
            row:Dock(TOP)
            row:SetTall(52)
            row:DockMargin(0, 0, 0, 2)
            SetStyledTooltip(row, description)
            row.Paint = function(s, w, h)
                rounded(0, 0, w, h, 6, s:IsHovered() and uiColors.rowHover or uiColors.row)
                outline(0, 0, w, h, Color(getAccent().r, getAccent().g, getAccent().b, 78))
            end

            local labels = row:Add("DPanel")
            labels:Dock(FILL)
            labels:DockMargin(14, 5, 18, 5)
            labels.Paint = function() end
            local title = labels:Add("DLabel")
            title:Dock(TOP)
            title:SetTall(21)
            title:SetText(displayName)
            title:SetFont("LiliaFont.18")
            title:SetTextColor(getTextColor())
            title:SetContentAlignment(4)
            SetStyledTooltip(title, description)
            local desc = labels:Add("DLabel")
            desc:Dock(FILL)
            desc:SetText(description ~= "" and description or "Press a key to perform this action.")
            desc:SetFont("LiliaFont.16")
            desc:SetTextColor(uiColors.muted)
            desc:SetContentAlignment(4)
            desc:SetWrap(false)
            SetStyledTooltip(desc, description)
            local currentKey = lia.keybind.get(action, KEY_NONE)
            if allowEdit then
                local resetButton = row:Add("DButton")
                resetButton:Dock(RIGHT)
                resetButton:SetWide(34)
                resetButton:DockMargin(8, 8, 10, 8)
                resetButton:SetText("")
                resetButton:SetCursor("hand")
                resetButton.Paint = function(s, w, h)
                    rounded(0, 0, w, h, 5, s:IsHovered() and uiColors.rowHover or uiColors.bgSoft)
                    outline(0, 0, w, h, Color(getAccent().r, getAccent().g, getAccent().b, s:IsHovered() and 150 or 85))
                    draw.SimpleText("R", "LiliaFont.18", w * 0.5, h * 0.5, getTextColor(), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end

                resetButton.DoClick = function()
                    if isnumber(currentKey) and currentKey ~= KEY_NONE and lia.keybind.stored[currentKey] == action then lia.keybind.stored[currentKey] = nil end
                    data.value = data.default or KEY_NONE
                    local newKey = data.value
                    if isnumber(newKey) and newKey ~= KEY_NONE then lia.keybind.stored[newKey] = action end
                    lia.keybind.save()
                    if refreshFunc then refreshFunc() end
                end

                SetStyledTooltip(resetButton, "Reset this keybind to its default key.")
                local combo = row:Add("liaComboBox")
                combo:Dock(RIGHT)
                combo:SetWide(160)
                combo:DockMargin(0, 9, 0, 9)
                combo:SetFont("LiliaFont.18")
                SetStyledTooltip(combo, description)
                local currentKeyName = getDisplayKeyName(currentKey)
                combo:SetValue(currentKeyName)
                local choices = {}
                local seenCodes = {}
                for name, code in pairs(KeybindKeys) do
                    if code ~= KEY_FIRST and code ~= KEY_LAST and not seenCodes[code] and (not taken[code] or taken[code] == action or code == KEY_NONE) then
                        seenCodes[code] = true
                        local displayKey = getDisplayKeyName(code, name)
                        choices[#choices + 1] = {
                            txt = tostring(displayKey),
                            keycode = code,
                            sortKey = getKeyChoiceSortKey(displayKey, code)
                        }
                    end
                end

                table.sort(choices, function(a, b) return a.sortKey < b.sortKey end)
                local hasNone = false
                for _, choice in ipairs(choices) do
                    if choice.keycode == KEY_NONE then
                        hasNone = true
                        break
                    end
                end

                if not hasNone then
                    table.insert(choices, 1, {
                        txt = "NONE",
                        keycode = KEY_NONE,
                        sortKey = "0:none"
                    })
                end

                for _, choice in ipairs(choices) do
                    combo:AddChoice(choice.txt, choice.keycode)
                end

                combo.OnSelect = function(_, _, _, keyCode)
                    local newKey = isstring(keyCode) and KeybindKeys[string.lower(keyCode)] or keyCode
                    newKey = newKey or KEY_NONE
                    if newKey ~= KEY_NONE and taken[newKey] and taken[newKey] ~= action then
                        combo:SetValue(currentKeyName)
                        return
                    end

                    if isnumber(currentKey) and currentKey ~= KEY_NONE and lia.keybind.stored[currentKey] == action then lia.keybind.stored[currentKey] = nil end
                    data.value = newKey
                    if isnumber(newKey) and newKey ~= KEY_NONE then lia.keybind.stored[newKey] = action end
                    lia.keybind.save()
                    if refreshFunc then refreshFunc() end
                    local client = LocalPlayer()
                    if IsValid(client) then client:notifySuccess(L("keybindChanged", localizeKeybindLabel(action), getDisplayKeyName(newKey))) end
                end
            else
                local valueLabel = row:Add("DLabel")
                valueLabel:Dock(RIGHT)
                valueLabel:SetWide(160)
                valueLabel:DockMargin(0, 0, 12, 0)
                valueLabel:SetText(getDisplayKeyName(currentKey))
                valueLabel:SetFont("LiliaFont.18")
                valueLabel:SetTextColor(getTextColor())
                valueLabel:SetContentAlignment(6)
            end
        end

        local function collectItems()
            local categories = {}
            local total = 0
            for action, data in pairs(lia.keybind.stored) do
                if istable(data) then
                    local category = getVisualCategory(action, data)
                    categories[category] = categories[category] or {}
                    categories[category][#categories[category] + 1] = {
                        key = action,
                        name = tostring(L(action) or action),
                        desc = tostring(lia.keybind.getDisplayDescription(action) or ""),
                        data = data
                    }

                    total = total + 1
                end
            end

            for _, items in pairs(categories) do
                table.sort(items, function(a, b) return tostring(a.name or ""):lower() < tostring(b.name or ""):lower() end)
            end
            return categories, total
        end

        local function itemMatches(item, category, filter)
            if not filter or filter == "" then return true end
            local needle = filter:lower()
            return tostring(item.name or ""):lower():find(needle, 1, true) or tostring(item.desc or ""):lower():find(needle, 1, true) or tostring(item.key or ""):lower():find(needle, 1, true) or tostring(category or ""):lower():find(needle, 1, true)
        end

        pages[#pages + 1] = {
            name = "keybinds",
            shouldShow = function() return true end,
            drawFunc = function(parent)
                parent:Clear()
                parent:DockPadding(0, 0, 0, 0)
                local allowEdit = lia.config.get("AllowKeybindEditing", true)
                local categories, total = collectItems()
                local sortedCategories = sortCategories(categories)
                local selectedCategory = categories.Core and "Core" or sortedCategories[1]
                local filterText = ""
                local root = parent:Add("DPanel")
                root:Dock(FILL)
                root.Paint = function(_, w, h)
                    rounded(0, 0, w, h, 8, uiColors.bg)
                    outline(0, 0, w, h, Color(getAccent().r, getAccent().g, getAccent().b, 55))
                end

                local header = root:Add("DPanel")
                header:Dock(TOP)
                header:SetTall(72)
                header:DockMargin(14, 12, 14, 0)
                header.Paint = function() end
                local title = header:Add("DLabel")
                title:Dock(TOP)
                title:SetTall(32)
                title:SetText("Keybinds")
                title:SetFont("LiliaFont.22")
                title:SetTextColor(getTextColor())
                title:SetContentAlignment(4)
                local subtitle = header:Add("DLabel")
                subtitle:Dock(TOP)
                subtitle:SetTall(24)
                subtitle:SetText("Configure your action keybinds and reset them to defaults when needed.")
                subtitle:SetFont("LiliaFont.18")
                subtitle:SetTextColor(uiColors.muted)
                subtitle:SetContentAlignment(4)
                local toolbar = root:Add("DPanel")
                toolbar:Dock(TOP)
                toolbar:SetTall(42)
                toolbar:DockMargin(14, 0, 14, 10)
                toolbar.Paint = function() end
                local status = toolbar:Add("DPanel")
                status:Dock(RIGHT)
                status:SetWide(138)
                status:DockMargin(10, 3, 0, 3)
                status.Paint = function(_, w, h)
                    local accent = getAccent()
                    rounded(0, 0, w, h, 5, uiColors.bgSoft)
                    outline(0, 0, w, h, Color(accent.r, accent.g, accent.b, 80))
                    draw.SimpleText("Instant Save", "LiliaFont.18", w * 0.5, h * 0.5, getTextColor(), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end

                local categoryCombo = toolbar:Add("liaComboBox")
                categoryCombo:Dock(RIGHT)
                categoryCombo:SetWide(190)
                categoryCombo:DockMargin(0, 3, 0, 3)
                categoryCombo:SetFont("LiliaFont.18")
                categoryCombo:AddChoice("All Categories", "__all")
                for _, category in ipairs(sortedCategories) do
                    categoryCombo:AddChoice(category, category)
                end

                categoryCombo:SetValue(selectedCategory or "All Categories")
                local searchEntry = toolbar:Add("liaEntry")
                searchEntry:Dock(FILL)
                searchEntry:DockMargin(0, 3, 10, 3)
                searchEntry:SetPlaceholderText(L("searchKeybinds") or "Search keybinds...")
                searchEntry:SetFont("LiliaFont.18")
                local body = root:Add("DPanel")
                body:Dock(FILL)
                body:DockMargin(14, 0, 14, 0)
                body.Paint = function() end
                local rail = body:Add("DPanel")
                rail:Dock(LEFT)
                rail:SetWide(255)
                rail:DockMargin(0, 0, 12, 0)
                rail.Paint = function(_, w, h)
                    rounded(0, 0, w, h, 6, uiColors.bgSoft)
                    outline(0, 0, w, h, Color(getAccent().r, getAccent().g, getAccent().b, 78))
                end

                local railScroll = rail:Add("liaScrollPanel")
                railScroll:Dock(FILL)
                railScroll:DockMargin(8, 8, 8, 8)
                styleScroll(railScroll)
                local scroll = body:Add("liaScrollPanel")
                scroll:Dock(FILL)
                scroll:GetCanvas():DockPadding(0, 0, 0, 0)
                styleScroll(scroll)
                local footer = root:Add("DPanel")
                footer:Dock(BOTTOM)
                footer:SetTall(54)
                footer:DockMargin(14, 8, 14, 14)
                footer.Paint = function(_, w, h)
                    surface.SetDrawColor(Color(getAccent().r, getAccent().g, getAccent().b, 78))
                    surface.DrawRect(0, 0, w, 1)
                end

                local footerStatus = footer:Add("DLabel")
                footerStatus:Dock(LEFT)
                footerStatus:SetWide(520)
                footerStatus:SetFont("LiliaFont.18")
                footerStatus:SetTextColor(uiColors.muted)
                footerStatus:SetContentAlignment(4)
                local resetButton = makeButton(footer, "Reset All Keybinds", 180, false)
                resetButton:Dock(RIGHT)
                resetButton:DockMargin(8, 9, 0, 8)
                local function refreshFooter()
                    if not IsValid(footerStatus) then return end
                    footerStatus:SetText(total .. " keybinds    |    " .. countModified() .. " modified    |    Saved to data/lilia/keybinds.json")
                end

                local populate
                local rebuildRail
                rebuildRail = function()
                    railScroll:Clear()
                    local function addRailButton(label, value)
                        local button = railScroll:Add("DButton")
                        button:Dock(TOP)
                        button:SetTall(48)
                        button:DockMargin(0, 0, 0, 6)
                        button:SetText("")
                        button:SetCursor("hand")
                        button.Paint = function(s, w, h)
                            local active = selectedCategory == value or (not selectedCategory and value == nil)
                            local accent = getAccent()
                            rounded(0, 0, w, h, 5, active and uiColors.selected or s:IsHovered() and uiColors.rowHover or uiColors.bgSoft)
                            outline(0, 0, w, h, active and Color(accent.r, accent.g, accent.b, 170) or Color(getAccent().r, getAccent().g, getAccent().b, 78))
                            if active then
                                surface.SetDrawColor(accent.r, accent.g, accent.b, 235)
                                surface.DrawRect(0, 0, 3, h)
                            end

                            local count = value and categories[value] and #categories[value] or total
                            draw.SimpleText(label, "LiliaFont.18", 16, h * 0.38, active and getTextColor() or uiColors.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                            draw.SimpleText(count .. " keybinds", "LiliaFont.16", 16, h * 0.68, uiColors.muted, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                        end

                        button.DoClick = function()
                            selectedCategory = value
                            if IsValid(categoryCombo) then categoryCombo:SetValue(value or "All Categories") end
                            rebuildRail()
                            populate(filterText)
                        end
                    end

                    addRailButton("All Keybinds", nil)
                    for _, category in ipairs(sortedCategories) do
                        addRailButton(category, category)
                    end
                end

                populate = function(filter)
                    if not IsValid(scroll) then return end
                    local taken = buildTakenLookup()
                    filterText = filter or ""
                    scroll:Clear()
                    local hasAny = false
                    local categoriesToDraw = selectedCategory and {selectedCategory} or sortedCategories
                    for _, category in ipairs(categoriesToDraw) do
                        local items = categories[category]
                        local visible = {}
                        if items then
                            for _, item in ipairs(items) do
                                if itemMatches(item, category, filterText) then visible[#visible + 1] = item end
                            end
                        end

                        if #visible > 0 then
                            hasAny = true
                            makeSection(scroll, category, categoryIcons[category], #visible)
                            for _, item in ipairs(visible) do
                                addKeybindField(scroll, item.key, item.data, allowEdit, taken, function() populate(filterText) end)
                            end
                        end
                    end

                    if not hasAny then
                        local empty = scroll:Add("DPanel")
                        empty:Dock(TOP)
                        empty:SetTall(90)
                        empty.Paint = function(_, w, h)
                            rounded(0, 0, w, h, 6, uiColors.bgSoft)
                            outline(0, 0, w, h, Color(getAccent().r, getAccent().g, getAccent().b, 78))
                            draw.SimpleText("No keybinds match your search.", "LiliaFont.18", w * 0.5, h * 0.5, uiColors.muted, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                        end
                    end

                    refreshFooter()
                end

                resetButton.DoClick = function()
                    for action, data in pairs(lia.keybind.stored) do
                        if istable(data) then
                            local oldValue = data.value
                            if isnumber(oldValue) and oldValue ~= KEY_NONE and lia.keybind.stored[oldValue] == action then lia.keybind.stored[oldValue] = nil end
                            data.value = data.default or KEY_NONE
                        end
                    end

                    for action, data in pairs(lia.keybind.stored) do
                        if istable(data) and isnumber(data.value) and data.value ~= KEY_NONE then lia.keybind.stored[data.value] = action end
                    end

                    lia.keybind.save()
                    populate(filterText)
                end

                searchEntry:SetUpdateOnType(true)
                searchEntry.OnTextChanged = function(_, text) populate(text) end
                categoryCombo.OnSelect = function(_, _, _, value)
                    selectedCategory = value == "__all" and nil or value
                    rebuildRail()
                    populate(filterText)
                end

                rebuildRail()
                populate(nil)
                refreshFooter()
            end
        }
    end)
end