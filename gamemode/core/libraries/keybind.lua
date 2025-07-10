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

            table.sort(sortedActions, function(a, b)
                local la, lb = #tostring(a), #tostring(b)
                if la == lb then return tostring(a) < tostring(b) end
                return la < lb
            end)

            for _, action in ipairs(sortedActions) do
                local data = lia.keybind.stored[action]
                local row = scroll:Add("DPanel")
                row:Dock(TOP)
                row:DockMargin(4, 4, 4, 4)
                row:SetTall(50)
                local lbl = row:Add("DLabel")
                lbl:Dock(FILL)
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
                        data.value = newKey
                        lia.keybind.stored[newKey] = action
                        taken[newKey] = action
                        lia.keybind.save()
                        currentKey = newKey
                    end

                    local unbindButton = row:Add("DButton")
                    unbindButton:Dock(RIGHT)
                    unbindButton:SetWide(100)
                    unbindButton:SetFont("liaMediumFont")
                    unbindButton:SetText(L("unbind"):upper())
                    unbindButton.DoClick = function()
                        taken[currentKey] = nil
                        data.value = KEY_NONE
                        lia.keybind.stored[KEY_NONE] = action
                        lia.keybind.save()
                        combo:SetValue(input.GetKeyName(KEY_NONE) or "NONE")
                        currentKey = KEY_NONE
                    end
                else
                    local textLabel = row:Add("DLabel")
                    textLabel:Dock(FILL)
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
        searchEntry:SetPlaceholderText(L("searchKeybinds"))
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

lia.keybind.add(KEY_NONE, "Open Inventory", function()
    local f1Menu = vgui.Create("liaMenu")
    f1Menu:setActiveTab(L("inv"))
end)

lia.keybind.add(KEY_NONE, "Admin Mode", function() lia.command.send("adminmode") end)
lia.keybind.add(KEY_NONE, "Open Classes Menu", function()
    local client = LocalPlayer()
    if not client:getChar() or vgui.CursorVisible() then return end
    if IsValid(lia.gui.classesFrame) then
        lia.gui.classesFrame:Close()
        return
    end

    local frame = vgui.Create("DFrame")
    frame:SetSize(ScrW() * 0.9, ScrH() * 0.9)
    frame:Center()
    frame:SetTitle(L("classes"))
    frame:MakePopup()
    frame:SetDeleteOnClose(true)
    frame:DockPadding(0, 24, 0, 0)
    local sidebar = vgui.Create("DScrollPanel", frame)
    sidebar:Dock(LEFT)
    sidebar:SetWide(200)
    sidebar:DockMargin(20, 20, 0, 20)
    local mainContent = vgui.Create("DScrollPanel", frame)
    mainContent:Dock(FILL)
    mainContent:DockMargin(10, 10, 10, 10)
    local tabButtons = {}
    local function addJoinButton(parent, data, canBe)
        local char = client:getChar()
        local isCurrent = char and char:getClass() == data.index
        local btn = parent:Add("liaMediumButton")
        btn:SetText(isCurrent and L("alreadyInClass") or canBe and L("joinClass") or L("classRequirementsNotMet"))
        btn:SetTall(40)
        btn:SetTextColor(lia.color.ReturnMainAdjustedColors().text)
        btn:SetFont("liaMediumFont")
        btn:SetExpensiveShadow(1, Color(0, 0, 0, 100))
        btn:SetContentAlignment(5)
        btn:Dock(BOTTOM)
        btn:DockMargin(10, 10, 10, 10)
        btn:SetDisabled(isCurrent or not canBe)
        btn.DoClick = function()
            if canBe and not isCurrent then
                lia.command.send("beclass", data.index)
                frame:Close()
            end
        end
    end

    local function addClassDetails(parent, data)
        local maxH, maxA, maxJ = client:GetMaxHealth(), client:GetMaxArmor(), client:GetJumpPower()
        local runSpeed, walkSpeed = lia.config.get("RunSpeed"), lia.config.get("WalkSpeed")
        local function addLine(t)
            local lbl = parent:Add("DLabel")
            lbl:SetFont("liaMediumFont")
            lbl:SetText(t)
            lbl:SetTextColor(color_white)
            lbl:SetWrap(true)
            lbl:Dock(TOP)
            lbl:DockMargin(10, 10, 10, 10)
        end

        addLine(L("name") .. ": " .. (data.name or L("unnamed")))
        addLine(L("desc") .. ": " .. (data.desc or L("noDesc")))
        addLine(L("faction") .. ": " .. (team.GetName(data.faction) or L("none")))
        addLine(L("isDefaultLabel") .. ": " .. (data.isDefault and L("yes") or L("no")))
        addLine(L("baseHealth") .. ": " .. tostring(data.health or maxH))
        addLine(L("baseArmor") .. ": " .. tostring(data.armor or maxA))
        local weapons = data.weapons or {}
        addLine(L("weapons") .. ": " .. (#weapons > 0 and table.concat(weapons, ", ") or L("none")))
        addLine(L("modelScale") .. ": " .. tostring(data.scale or 1))
        local rs = data.runSpeedMultiplier and math.Round(runSpeed * data.runSpeed) or data.runSpeed or runSpeed
        addLine(L("runSpeed") .. ": " .. tostring(rs))
        local ws = data.walkSpeedMultiplier and math.Round(walkSpeed * data.walkSpeed) or data.walkSpeed or walkSpeed
        addLine(L("walkSpeed") .. ": " .. tostring(ws))
        local jp = data.jumpPowerMultiplier and math.Round(maxJ * data.jumpPower) or data.jumpPower or maxJ
        addLine(L("jumpPower") .. ": " .. tostring(jp))
        local bloodMap = {
            [-1] = L("bloodNo"),
            [0] = L("bloodRed"),
            [1] = L("bloodYellow"),
            [2] = L("bloodGreenRed"),
            [3] = L("bloodSparks"),
            [4] = L("bloodAntlion"),
            [5] = L("bloodZombie"),
            [6] = L("bloodAntlionBright")
        }

        addLine(L("bloodColor") .. ": " .. (bloodMap[data.bloodcolor] or L("bloodRed")))
        if data.requirements then
            local req = istable(data.requirements) and table.concat(data.requirements, ", ") or tostring(data.requirements)
            addLine(L("requirements") .. ": " .. req)
        end
    end

    local function createModelPanel(parent, data)
        local sizeX, sizeY = 300, 600
        local mdl = parent:Add("liaModelPanel")
        mdl:SetScaledSize(sizeX, sizeY)
        mdl:SetFOV(35)
        local path = istable(data.model) and data.model[math.random(#data.model)] or data.model or client:GetModel()
        mdl:SetModel(path)
        mdl.rotationAngle = 45
        local ent = mdl.Entity
        ent:SetSkin(data.skin or 0)
        for _, bg in ipairs(data.bodyGroups or {}) do
            ent:SetBodygroup(bg.id, bg.value or 0)
        end

        for i, mat in ipairs(data.subMaterials or {}) do
            ent:SetSubMaterial(i - 1, mat)
        end

        mdl.Think = function()
            if IsValid(ent) then
                mdl:SetPos(parent:GetWide() - sizeX - 10, 100)
                if input.IsKeyDown(KEY_A) then
                    mdl.rotationAngle = mdl.rotationAngle - 0.5
                elseif input.IsKeyDown(KEY_D) then
                    mdl.rotationAngle = mdl.rotationAngle + 0.5
                end

                ent:SetAngles(Angle(0, mdl.rotationAngle, 0))
            end
        end
    end

    local function loadClasses()
        sidebar:Clear()
        tabButtons = {}
        mainContent:Clear()
        local list = {}
        for _, c in pairs(lia.class.list) do
            if c.faction == client:Team() then list[#list + 1] = c end
        end

        table.sort(list, function(a, b) return a.name < b.name end)
        for _, data in ipairs(list) do
            local canBe = lia.class.canBe(client, data.index)
            local btn = sidebar:Add("liaMediumButton")
            btn:SetText(data.name or L("unnamed"))
            btn:SetTall(50)
            btn:Dock(TOP)
            btn:DockMargin(0, 0, 10, 20)
            btn.DoClick = function()
                for _, b in ipairs(tabButtons) do
                    b:SetSelected(b == btn)
                end

                mainContent:Clear()
                local container = mainContent:Add("DPanel")
                container:Dock(TOP)
                container:DockMargin(10, 10, 10, 10)
                container:SetTall(ScrH() * 0.8)
                if data.logo then
                    local img = container:Add("DImage")
                    img:SetImage(data.logo)
                    img:SetScaledSize(128, 128)
                    img.Think = function() img:SetPos(container:GetWide() - img:GetWide() - 10, 10) end
                end

                createModelPanel(container, data)
                addClassDetails(container, data)
                addJoinButton(container, data, canBe)
            end

            tabButtons[#tabButtons + 1] = btn
        end
    end

    lia.gui.classesFrame = frame
    loadClasses()
end)