--[[
# Keybind Library

This page documents the functions for working with keybind management and input handling.

---

## Overview

The keybind library provides a system for managing keyboard bindings and input handling within the Lilia framework. It handles keybind registration, storage, and provides utilities for creating customizable keybind systems. The library supports various key types, keybind persistence, and provides a foundation for user-configurable input systems.
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
    lia.keybind.add

    Purpose:
        Registers a new keybind action with the system, associating a key, an action name, and optional callback functions
        for when the key is pressed or released. This allows custom actions to be triggered by user-defined keybinds.

    Parameters:
        k (string|number)      - The key to bind (as a string name or key code).
        d (string)             - The unique action name for this keybind.
        cb (function|none)      - The callback function to call when the key is pressed (optional).
        rcb (function|none)     - The callback function to call when the key is released (optional).

    Returns:
        None.

    Realm:
        Client.

    Example Usage:
        -- Register a keybind for opening a custom menu with F4
        lia.keybind.add("f4", "openCustomMenu", function(ply)
            if IsValid(ply) then
                MyCustomMenu:Open()
            end
        end)
]]
function lia.keybind.add(k, d, cb, rcb)
    local c = isstring(k) and KeybindKeys[string.lower(k)] or k
    if not c then return end
    lia.keybind.stored[d] = lia.keybind.stored[d] or {}
    if not lia.keybind.stored[d].value then lia.keybind.stored[d].value = c end
    lia.keybind.stored[d].default = c
    lia.keybind.stored[d].callback = cb
    lia.keybind.stored[d].release = rcb
    lia.keybind.stored[c] = d
end

--[[
    lia.keybind.get

    Purpose:
        Retrieves the key code currently bound to a given action. If the action is not found, returns the provided default value.

    Parameters:
        a (string)         - The action name to look up.
        df (number|none)    - The default key code to return if the action is not found (optional).

    Returns:
        keyCode (number|none) - The key code bound to the action, or the default value if not found.

    Realm:
        Client.

    Example Usage:
        -- Get the key code for the "openCustomMenu" action, defaulting to KEY_F4 if not set
        local key = lia.keybind.get("openCustomMenu", KEY_F4)
]]
function lia.keybind.get(a, df)
    local act = lia.keybind.stored[a]
    if act then return act.value or act.default or df end
    return df
end

--[[
    lia.keybind.save

    Purpose:
        Saves all current keybinds to a JSON file specific to the current gamemode and server IP.
        This persists user keybind preferences across sessions.

    Parameters:
        None.

    Returns:
        None.

    Realm:
        Client.

    Example Usage:
        -- Save the current keybind configuration after the user changes a keybind
        lia.keybind.save()
]]
function lia.keybind.save()
    local dp = "lilia/keybinds/" .. engine.ActiveGamemode()
    file.CreateDir(dp)
    local ip = string.Explode(":", game.GetIPAddress())[1]
    local f = ip:gsub("%.", "_")
    local s = dp .. "/" .. f .. ".json"
    local d = {}
    for k, v in pairs(lia.keybind.stored) do
        if istable(v) and v.value then d[k] = v.value end
    end

    local j = util.TableToJSON(d, true)
    if j then
        file.Write(s, j)
        local legacy = dp .. "/" .. f .. ".txt"
        if file.Exists(legacy, "DATA") then file.Delete(legacy) end
    end
end

--[[
    lia.keybind.load

    Purpose:
        Loads keybinds from the saved JSON file for the current gamemode and server IP.
        If a legacy text file exists, it migrates the data to JSON. If no saved keybinds are found,
        it resets all keybinds to their default values and saves them.

    Parameters:
        None.

    Returns:
        None.

    Realm:
        Client.

    Example Usage:
        -- Load keybinds when the client joins the server or when initializing the UI
        lia.keybind.load()
]]
function lia.keybind.load()
    local dp = "lilia/keybinds/" .. engine.ActiveGamemode()
    file.CreateDir(dp)
    local ip = string.Explode(":", game.GetIPAddress())[1]
    local f = ip:gsub("%.", "_")
    local jsonPath = dp .. "/" .. f .. ".json"
    local legacyPath = dp .. "/" .. f .. ".txt"
    local d = file.Read(jsonPath, "DATA")
    if not d and file.Exists(legacyPath, "DATA") then
        d = file.Read(legacyPath, "DATA")
        if d then
            file.Write(jsonPath, d)
            file.Delete(legacyPath)
        end
    end

    if d then
        local s = util.JSONToTable(d)
        for k, v in pairs(s) do
            if lia.keybind.stored[k] then lia.keybind.stored[k].value = v end
        end
    else
        for _, v in pairs(lia.keybind.stored) do
            if istable(v) and v.default then v.value = v.default end
        end

        lia.keybind.save()
    end

    for k in pairs(lia.keybind.stored) do
        if isnumber(k) then lia.keybind.stored[k] = nil end
    end

    for action, data in pairs(lia.keybind.stored) do
        if istable(data) and data.value then lia.keybind.stored[data.value] = action end
    end

    hook.Run("InitializedKeybinds")
end

hook.Add("PlayerButtonDown", "liaKeybindPress", function(p, b)
    local action = lia.keybind.stored[b]
    if not IsFirstTimePredicted() then return end
    if action and lia.keybind.stored[action] and lia.keybind.stored[action].callback then lia.keybind.stored[action].callback(p) end
end)

hook.Add("PlayerButtonUp", "liaKeybindRelease", function(p, b)
    local action = lia.keybind.stored[b]
    if not IsFirstTimePredicted() then return end
    if action and lia.keybind.stored[action] and lia.keybind.stored[action].release then lia.keybind.stored[action].release(p) end
end)

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
            local rowPanel = vgui.Create("DPanel")
            rowPanel:SetTall(50)
            rowPanel:DockPadding(4, 4, 4, 4)
            rowPanel.Paint = nil
            local lbl = rowPanel:Add("DLabel")
            lbl:Dock(FILL)
            lbl:SetFont("liaBigFont")
            lbl:SetText(L(action))
            local currentKey = lia.keybind.get(action, KEY_NONE)
            if allowEdit then
                local combo = rowPanel:Add("DComboBox")
                combo:Dock(RIGHT)
                combo:SetWide(200)
                combo:SetFont("liaMediumFont")
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

                local unbindButton = rowPanel:Add("DButton")
                unbindButton:Dock(RIGHT)
                unbindButton:SetWide(100)
                unbindButton:SetFont("liaMediumFont")
                unbindButton:SetText(L("unbind"):upper())
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
                textLabel:SetFont("liaBigFont")
                textLabel:SetText(input.GetKeyName(currentKey) or "NONE")
            end

            sheet:AddPanelRow(rowPanel, {
                height = 50,
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
        name = L("keybinds"),
        drawFunc = buildKeybinds
    }
end)

lia.keybind.add(KEY_NONE, L("openInventory"), function()
    local f1Menu = vgui.Create("liaMenu")
    f1Menu:setActiveTab(L("inv"))
end)

lia.keybind.add(KEY_NONE, L("adminMode"), function() lia.command.send("adminmode") end)
