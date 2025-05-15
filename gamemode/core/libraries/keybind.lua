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

   Description:
      Registers a new keybind for a given action.
      Converts the provided key identifier to its corresponding key constant (if it's a string),
      and stores the keybind settings including the default key, press callback, and release callback.
      Also maps the key code back to the action identifier for reverse lookup.

   Parameters:
      k (string or number) - The key identifier, either as a string (to be converted) or as a key code.
      d (string) - The unique identifier for the keybind action.
      cb (function) - The callback function to be executed when the key is pressed.
      rcb (function) - The callback function to be executed when the key is released.

   Returns:
      nil

   Realm:
      Client

   Example Usage:
      lia.keybind.add("space", "jump", function() print("Jump pressed!") end, function() print("Jump released!") end)
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

   Description:
      Retrieves the current key code for a specified keybind action.
      If the keybind has a set value, that value is returned; otherwise, it falls back to the default key
      or an optionally provided fallback value.

   Parameters:
      a (string) - The unique identifier for the keybind action.
      df (number) - An optional default key code to return if the keybind is not set.

   Returns:
      number - The key code associated with the keybind action, or the default/fallback value if not set.

   Realm:
      Client

   Example Usage:
      local jumpKey = lia.keybind.get("jump", KEY_SPACE)
]]
function lia.keybind.get(a, df)
    local act = lia.keybind.stored[a]
    if act then return act.value or act.default or df end
    return df
end

--[[
   lia.keybind.save

   Description:
      Saves the current keybind settings to a file.
      The function creates a directory specific to the active gamemode, constructs a filename based on the server's IP address,
      and writes the keybind mapping (action identifiers to key codes) in JSON format.

   Parameters:
      None

   Returns:
      nil

   Realm:
      Client

   Internal Function:
      true

   Example Usage:
      lia.keybind.save()
]]
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

--[[
   lia.keybind.load

   Description:
      Loads keybind settings from a file.
      The function reads a JSON file from a gamemode-specific directory, applies the saved keybind values to the stored keybinds,
      and if no saved file is found, it resets the keybinds to their default values and saves them.
      It also sets up a reverse mapping from key codes to keybind action identifiers.
      Finally, it triggers the "InitializedKeybinds" hook.

   Parameters:
      None

   Returns:
      nil

   Realm:
      Client

   Internal Function:
      true

   Example Usage:
      lia.keybind.load()
]]
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
        local container = parent:Add("DPanel")
        container:Dock(FILL)
        local allowEdit = lia.config.get("AllowKeybindEditing", true)
        local searchEntry, scroll
        local function populateRows(filter)
            scroll:Clear()
            if not istable(lia.keybind.stored) then return end
            local taken = {}
            for action, data in pairs(lia.keybind.stored) do
                if istable(data) and data.value then taken[data.value] = action end
            end

            local sortedActions = {}
            for action, data in pairs(lia.keybind.stored) do
                if istable(data) and (filter == "" or tostring(action):lower():find(filter, 1, true)) then sortedActions[#sortedActions + 1] = action end
            end

            table.sort(sortedActions, function(a, b) return tostring(a) < tostring(b) end)
            for _, action in ipairs(sortedActions) do
                local data = lia.keybind.stored[action]
                local row = scroll:Add("DPanel")
                row:Dock(TOP)
                row:DockMargin(4, 4, 4, 4)
                row:SetTall(50)
                local lbl = row:Add("DLabel")
                lbl:Dock(LEFT)
                lbl:SetWide(300)
                lbl:SetFont("liaBigFont")
                lbl:SetText(action)
                local currentKey = lia.keybind.get(action, KEY_NONE)
                if allowEdit then
                    local combo = row:Add("DComboBox")
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
                        if lia.keybind.stored[currentKey] then lia.keybind.stored[currentKey] = nil end
                        data.value = newKey
                        lia.keybind.stored[newKey] = action
                        taken[newKey] = action
                        lia.keybind.save()
                        currentKey = newKey
                    end
                else
                    local textLabel = row:Add("DLabel")
                    textLabel:Dock(LEFT)
                    textLabel:SetWide(300)
                    textLabel:SetFont("liaBigFont")
                    textLabel:SetText(input.GetKeyName(currentKey) or "NONE")
                end
            end
        end

        if allowEdit then
            local resetAllBtn = container:Add("DButton")
            resetAllBtn:Dock(TOP)
            resetAllBtn:SetTall(30)
            resetAllBtn:SetText(L("resetAllKeybinds"))
            resetAllBtn.DoClick = function()
                for action, data in pairs(lia.keybind.stored) do
                    if istable(data) and data.default then
                        if lia.keybind.stored[data.value] then lia.keybind.stored[data.value] = nil end
                        data.value = data.default
                        lia.keybind.stored[data.default] = action
                    end
                end

                lia.keybind.save()
                populateRows(searchEntry:GetValue():lower())
            end
        end

        searchEntry = container:Add("DTextEntry")
        searchEntry:Dock(TOP)
        searchEntry:SetTall(30)
        searchEntry:SetPlaceholderText("Search keybinds...")
        searchEntry.OnTextChanged = function() populateRows(searchEntry:GetValue():lower()) end
        scroll = container:Add("DScrollPanel")
        scroll:Dock(FILL)
        populateRows("")
    end

    pages[#pages + 1] = {
        name = L("keybinds"),
        drawFunc = buildKeybinds
    }
end)

lia.keybind.add(KEY_I, "Open Inventory", function()
    local f1Menu = vgui.Create("liaMenu")
    f1Menu:setActiveTab("inv")
end)

lia.keybind.add(KEY_T, "Quick Take Item", function()
    local client = LocalPlayer()
    if not client:getChar() or vgui.CursorVisible() then return end
    local ent = client:getTracedEntity()
    if IsValid(ent) and ent:isItem() then netstream.Start("invAct", "take", ent) end
end)

lia.keybind.add(KEY_NONE, "Admin Mode", function() lia.command.send("adminmode") end)
