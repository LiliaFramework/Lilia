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

function lia.keybind.get(a, df)
    local act = lia.keybind.stored[a]
    if act then return act.value or act.default or df end
    return df
end

function lia.keybind.save()
    local dp = "lilia/keybinds/" .. engine.ActiveGamemode()
    file.CreateDir(dp)
    local ip = string.Explode(":", game.GetIPAddress())[1]
    local f = ip:gsub("%.", "_")
    local s = dp .. "/" .. f .. ".txt"
    local d = {}
    for k, v in pairs(lia.keybind.stored) do
        if istable(v) and v.value then d[k] = v.value end
    end

    local j = util.TableToJSON(d, true)
    if j then file.Write(s, j) end
end

function lia.keybind.load()
    local dp = "lilia/keybinds/" .. engine.ActiveGamemode()
    file.CreateDir(dp)
    local ip = string.Explode(":", game.GetIPAddress())[1]
    local f = ip:gsub("%.", "_")
    local l = dp .. "/" .. f .. ".txt"
    local d = file.Read(l, "DATA")
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

    for action, data in pairs(lia.keybind.stored) do
        if istable(data) and data.value then lia.keybind.stored[data.value] = action end
    end

    hook.Run("InitializedKeybinds")
end

hook.Add("PlayerButtonDown", "liaKeybindPress", function(p, b)
    local action = lia.keybind.stored[b]
    if action and lia.keybind.stored[action] and lia.keybind.stored[action].callback then lia.keybind.stored[action].callback(p) end
end)

hook.Add("PlayerButtonUp", "liaKeybindRelease", function(p, b)
    local action = lia.keybind.stored[b]
    if action and lia.keybind.stored[action] and lia.keybind.stored[action].release then lia.keybind.stored[action].release(p) end
end)

hook.Add("CreateMenuButtons", "KeybindMenuButtons", function(tabs)
    tabs["keybinds"] = function(panel)
        local container = panel:Add("DPanel")
        container:SetSize(panel:GetWide() * 0.5, panel:GetTall() * 0.5)
        container:CenterHorizontal()
        container:Center()
        local allowEdit = lia.config.get("AllowKeybindEditing", true)
        local resetAllBtn
        if allowEdit then
            resetAllBtn = container:Add("DButton")
            resetAllBtn:Dock(TOP)
            resetAllBtn:SetText("Reset All Keybinds")
            resetAllBtn:SetTall(30)
        end

        local scroll = container:Add("DScrollPanel")
        scroll:Dock(FILL)
        local function populateRows()
            scroll:Clear()
            local taken = {}
            for a, data in pairs(lia.keybind.stored) do
                if istable(data) and data.value then taken[data.value] = a end
            end

            local sortedActions = {}
            for a, data in pairs(lia.keybind.stored) do
                if istable(data) then table.insert(sortedActions, a) end
            end

            table.sort(sortedActions, function(a, b) return tostring(a) < tostring(b) end)
            for _, action in ipairs(sortedActions) do
                local row = scroll:Add("DPanel")
                row:Dock(TOP)
                row:DockMargin(4, 4, 4, 4)
                row:SetTall(30)
                local lbl = row:Add("DLabel")
                lbl:Dock(LEFT)
                lbl:SetWide(120)
                lbl:SetText(action)
                local currentKey = lia.keybind.get(action, KEY_NONE)
                if allowEdit then
                    local combo = row:Add("DComboBox")
                    combo:Dock(LEFT)
                    combo:SetWide(120)
                    combo:SetValue(input.GetKeyName(currentKey) or "NONE")
                    -- Build and sort the list of key choices alphabetically.
                    local choices = {}
                    for name, code in pairs(KeybindKeys) do
                        if not taken[code] or code == currentKey then
                            local disp = input.GetKeyName(code) or name
                            table.insert(choices, {
                                txt = disp,
                                keycode = code
                            })
                        end
                    end

                    table.sort(choices, function(a, b) return a.txt < b.txt end)
                    for _, c in ipairs(choices) do
                        combo:AddChoice(c.txt, c.keycode)
                    end

                    combo.OnSelect = function(_, _, _, newKeyCode)
                        if not newKeyCode then return end
                        for tk, tv in pairs(taken) do
                            if tk == newKeyCode and tv ~= action then
                                combo:SetValue(input.GetKeyName(currentKey) or "NONE")
                                return
                            end
                        end

                        if lia.keybind.stored[currentKey] then lia.keybind.stored[currentKey] = nil end
                        local oldData = lia.keybind.stored[action]
                        if oldData then lia.keybind.stored[newKeyCode] = action end
                        taken[currentKey] = nil
                        taken[newKeyCode] = action
                        lia.keybind.stored[action].value = newKeyCode
                        lia.keybind.save()
                        currentKey = newKeyCode
                    end

                    local resetBtn = row:Add("DButton")
                    resetBtn:Dock(RIGHT)
                    resetBtn:SetWide(60)
                    resetBtn:SetText("Reset")
                    resetBtn.DoClick = function()
                        local data = lia.keybind.stored[action]
                        if not data then return end
                        local defKey = data.default
                        if data.value == defKey then return end
                        if lia.keybind.stored[data.value] then lia.keybind.stored[data.value] = nil end
                        data.value = defKey
                        lia.keybind.stored[defKey] = action
                        taken[currentKey] = nil
                        taken[defKey] = action
                        combo:SetValue(input.GetKeyName(defKey) or "NONE")
                        currentKey = defKey
                        lia.keybind.save()
                    end
                else
                    local textLabel = row:Add("DLabel")
                    textLabel:Dock(LEFT)
                    textLabel:SetWide(120)
                    textLabel:SetText(input.GetKeyName(currentKey) or "NONE")
                end
            end
        end

        populateRows()
        if allowEdit then
            resetAllBtn.DoClick = function()
                for a, data in pairs(lia.keybind.stored) do
                    if istable(data) and data.default then
                        if lia.keybind.stored[data.value] then lia.keybind.stored[data.value] = nil end
                        data.value = data.default
                        lia.keybind.stored[data.default] = a
                    end
                end

                lia.keybind.save()
                populateRows()
            end
        end
    end
end)