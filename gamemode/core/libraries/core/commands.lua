lia.command = lia.command or {}
lia.command.list = lia.command.list or {}
function lia.command.buildSyntaxFromArguments(args)
    local tokens = {}
    for _, arg in ipairs(args) do
        local typ = arg.type or "string"
        if typ == "bool" or typ == "boolean" then
            typ = "bool"
        elseif typ == "player" then
            typ = "player"
        elseif typ == "table" then
            typ = "table"
        else
            typ = "string"
        end

        local name = lia.lang.resolve(arg.name or typ)
        local optional = arg.optional and " optional" or ""
        tokens[#tokens + 1] = string.format("[%s %s%s]", typ, name, optional)
    end
    return table.concat(tokens, " ")
end

function lia.command.add(command, data)
    data.arguments = data.arguments or {}
    data.syntax = data.syntax or lia.command.buildSyntaxFromArguments(data.arguments)
    data.syntax = isstring(data.syntax) and lia.lang.resolve(data.syntax) or data.syntax or ""
    data.desc = isstring(data.desc) and lia.lang.resolve(data.desc) or data.desc or ""
    if istable(data.AdminStick) then
        data.AdminStick.Name = isstring(data.AdminStick.Name) and lia.lang.resolve(data.AdminStick.Name) or data.AdminStick.Name
        data.AdminStick.ButtonText = isstring(data.AdminStick.ButtonText) and lia.lang.resolve(data.AdminStick.ButtonText) or data.AdminStick.ButtonText
        data.AdminStick.Category = isstring(data.AdminStick.Category) and lia.lang.resolve(data.AdminStick.Category) or data.AdminStick.Category
        data.AdminStick.SubCategory = isstring(data.AdminStick.SubCategory) and lia.lang.resolve(data.AdminStick.SubCategory) or data.AdminStick.SubCategory
    end

    if isstring(data.privilege) and data.privilege:sub(1, 1) == "@" then
        data.privilegeName = lia.lang.resolve(data.privilege)
        data.privilege = data.privilege:sub(2)
    else
        data.privilegeName = data.privilegeName or data.privilege
    end

    data.privilege = data.privilege or nil
    local superAdminOnly = data.superAdminOnly
    local adminOnly = data.adminOnly
    if not data.onRun then
        lia.error(string.format("Command '%s' does not have a callback, not adding!", command))
        return
    end

    if superAdminOnly or adminOnly then
        local privilegeName = data.privilegeName or string.format("Access to %s", command)
        local privilegeID = data.privilege or string.lower("command_" .. command)
        lia.admin.registerPrivilege({
            Name = privilegeName,
            ID = privilegeID,
            MinAccess = superAdminOnly and "superadmin" or "admin",
            Category = "Staff Permissions"
        })
    end

    for _, arg in ipairs(data.arguments) do
        if arg.type == "boolean" then
            arg.type = "bool"
        elseif arg.type ~= "player" and arg.type ~= "table" and arg.type ~= "bool" then
            arg.type = "string"
        end

        arg.description = isstring(arg.description) and lia.lang.resolve(arg.description) or arg.description
        arg.optional = arg.optional or false
    end

    local onRun = data.onRun
    local onCheckAccess = data.onCheckAccess
    data._onRun = data.onRun
    data.onRun = function(client, arguments)
        local accessResult
        if onCheckAccess then
            accessResult, privilegeName = onCheckAccess(client, command, data)
            if accessResult ~= nil then
                if accessResult then
                    return onRun(client, arguments)
                else
                    return "You are not allowed to do this."
                end
            end
        end

        if accessResult == nil then accessResult, privilegeName = lia.command.hasAccess(client, command, data) end
        if accessResult then
            return onRun(client, arguments)
        else
            return "You are not allowed to do this."
        end
    end

    local alias = data.alias
    if alias then
        if istable(alias) then
            for _, v in ipairs(alias) do
                local aliasData = table.Copy(data)
                aliasData.realCommand = command
                lia.command.list[v:lower()] = aliasData
                if superAdminOnly or adminOnly then
                    local aliasPrivilegeID = data.privilege or string.lower("command_" .. v)
                    lia.admin.registerPrivilege({
                        Name = data.privilegeName or string.format("Access to %s", v),
                        ID = aliasPrivilegeID,
                        MinAccess = superAdminOnly and "superadmin" or "admin",
                        Category = "Commands"
                    })
                end
            end
        elseif isstring(alias) then
            local aliasData = table.Copy(data)
            aliasData.realCommand = command
            lia.command.list[alias:lower()] = aliasData
            if superAdminOnly or adminOnly then
                local aliasPrivilegeID = data.privilege or string.lower("command_" .. alias)
                lia.admin.registerPrivilege({
                    Name = data.privilegeName or string.format("Access to %s", alias),
                    ID = aliasPrivilegeID,
                    MinAccess = superAdminOnly and "superadmin" or "admin",
                    Category = "Commands"
                })
            end
        end
    end

    if command == command:lower() then
        lia.command.list[command] = data
    else
        data.realCommand = command
        lia.command.list[command:lower()] = data
    end

    hook.Run("CommandAdded", command, data)
end

function lia.command.hasAccess(client, command, data)
    if not data then data = lia.command.list[command] end
    if not data then return false, "Unknown command." end
    local privilegeID = data.privilege or string.lower("command_" .. command)
    local superAdminOnly = data.superAdminOnly
    local adminOnly = data.adminOnly
    local accessLevels = superAdminOnly and "superadmin" or adminOnly and "admin" or "user"
    local privilegeName = data.privilegeName or accessLevels == "user" and "Global" or string.format("Access to %s", command)
    if data.onCheckAccess then
        local accessResult, customPrivilegeName = data.onCheckAccess(client, command, data)
        if accessResult ~= nil then return accessResult, customPrivilegeName or privilegeName end
    end

    local hasAccess = true
    if accessLevels ~= "user" then
        if not isstring(privilegeID) then
            lia.error("' has invalid privilege ID type: ")
            return false, privilegeName
        end

        hasAccess = client:hasPrivilege(privilegeID)
        lia.debug("[Permissions]", "Permission Check for function lia.command.hasAccess", "command=", tostring(command), "privilegeID=", tostring(privilegeID), "accessLevels=", tostring(accessLevels), "hasPrivilege=", tostring(hasAccess))
    end

    local hookResult = hook.Run("CanPlayerUseCommand", client, command)
    if hookResult ~= nil then return hookResult, privilegeName end
    local char = IsValid(client) and client.getChar and client:getChar()
    if char then
        local faction = lia.faction.indices[char:getFaction()]
        if faction and faction.commands and table.HasValue(faction.commands, command) then return true, privilegeName end
        local classData = lia.class.list[char:getClass()]
        if classData and classData.commands and table.HasValue(classData.commands, command) then return true, privilegeName end
    end

    lia.debug("[Permissions]", "Permission Check for function lia.command.hasAccess final", "command=", tostring(command), "privilegeID=", tostring(privilegeID), "finalResult=", tostring(hasAccess))
    return hasAccess, privilegeName
end

function lia.command.extractArgs(text)
    local skip = 0
    local arguments = {}
    local curString = ""
    for i = 1, #text do
        if i > skip then
            local c = text:sub(i, i)
            if c == "\"" or c == "'" then
                local match = text:sub(i):match("%b" .. c .. c)
                if match then
                    curString = ""
                    skip = i + #match
                    arguments[#arguments + 1] = match:sub(2, -2)
                else
                    curString = curString .. c
                end
            elseif c == " " and curString ~= "" then
                arguments[#arguments + 1] = curString
                curString = ""
            else
                if not (c == " " and curString == "") then curString = curString .. c end
            end
        end
    end

    if curString ~= "" then arguments[#arguments + 1] = curString end
    return arguments
end

local function combineBracketArgs(args)
    local result = {}
    local buffer
    for _, a in ipairs(args) do
        if buffer then
            buffer = buffer .. " " .. a
            if a:sub(-1) == "]" then
                result[#result + 1] = buffer
                buffer = nil
            end
        elseif a:sub(1, 1) == "[" and a:sub(-1) ~= "]" then
            buffer = a
            if a:sub(-1) == "]" then
                result[#result + 1] = buffer
                buffer = nil
            end
        else
            result[#result + 1] = a
        end
    end

    if buffer then result[#result + 1] = buffer end
    return result
end

local function isPlaceholder(arg)
    return isstring(arg) and arg:sub(1, 1) == "[" and arg:sub(-1) == "]"
end

if SERVER then
    function lia.command.run(client, command, arguments)
        local commandTbl = lia.command.list[command:lower()]
        if commandTbl then
            local results = {commandTbl.onRun(client, arguments or {})}
            hook.Run("CommandRan", client, command, arguments or {}, results)
            local result = results[1]
            if isstring(result) then
                if IsValid(client) then
                    if result:sub(1, 1) == "@" then
                        client:notifyInfo(L(result:sub(2), unpack(results, 2)))
                    else
                        client:notifyError(result)
                    end
                end
            end
        end
    end

    function lia.command.parse(client, text, realCommand, arguments)
        if realCommand or utf8.sub(text, 1, 1) == "/" then
            local match = realCommand or text:lower():match("/" .. "([_%w]+)")
            if not match then
                local post = string.Explode(" ", text)
                local len = string.len(post[1])
                match = utf8.sub(post[1], 2, len)
            end

            match = match:lower()
            local command = lia.command.list[match]
            if command then
                local hasAccess = lia.command.hasAccess(client, match, command)
                if not hasAccess then
                    if IsValid(client) then client:notifyError(string.format("No Access")) end
                    return true
                end

                if not arguments then arguments = lia.command.extractArgs(text:sub(#match + 3)) end
                local fields = command.arguments or {}
                if IsValid(client) and client:IsPlayer() and #fields > 0 then
                    local tokens = combineBracketArgs(arguments)
                    local missing = {}
                    local prefix = {}
                    for i, field in ipairs(fields) do
                        local arg = tokens[i]
                        local isMissing = not arg or isPlaceholder(arg)
                        if isMissing then
                            if not field.optional then missing[#missing + 1] = field.name end
                        else
                            prefix[#prefix + 1] = arg
                        end
                    end

                    if #missing > 0 then
                        net.Start("liaCmdArgPrompt")
                        net.WriteString(match)
                        net.WriteTable(missing)
                        net.WriteTable(prefix)
                        net.WriteTable(command.arguments or {})
                        net.Send(client)
                        return true
                    end
                end

                lia.command.run(client, match, arguments)
            else
                if IsValid(client) then
                    client:notifyError(string.format("Sorry, that command does not exist."))
                else
                    lia.information("Sorry, that command does not exist.")
                end
            end
            return true
        end
        return false
    end
else
    function lia.command.openArgumentPrompt(cmdKey, missing, prefix, definitions)
        local command = lia.command.list[cmdKey] or {
            arguments = definitions or {}
        }

        if not command then return end
        local fields = {}
        local lookup = {}
        for _, name in ipairs(missing or {}) do
            lookup[name] = true
        end

        for _, arg in ipairs(command.arguments or {}) do
            if lookup[arg.name] then fields[arg.name] = arg end
        end

        prefix = prefix or {}
        local numFields = table.Count(fields)
        local frameW, frameH = 600, math.min(450 + numFields * 135, ScrH() * 0.5)
        local frame = vgui.Create("liaFrame")
        frame:SetTitle("")
        frame:SetCenterTitle(tostring(cmdKey))
        frame:SetSize(frameW, frameH)
        frame:Center()
        frame:MakePopup()
        frame:ShowCloseButton(false)
        frame:SetZPos(1000)
        local scroll = vgui.Create("liaScrollPanel", frame)
        scroll:Dock(FILL)
        scroll:DockMargin(10, 40, 10, 10)
        surface.SetFont("LiliaFont.17")
        local controls = {}
        local watchers = {}
        local validate
        for _, arg in ipairs(command.arguments or {}) do
            local name = arg.name
            if fields[name] then
                local data = arg
                local fieldType = data.type
                local optional = data.optional
                local options = data.options
                local filter = data.filter
                local panel = vgui.Create("DPanel", scroll)
                panel:Dock(TOP)
                panel:DockMargin(0, 0, 0, 15)
                panel:SetTall(120)
                panel.Paint = nil
                surface.SetFont("LiliaFont.20")
                local textW = select(1, surface.GetTextSize(tostring(data.description or name)))
                local ctrl
                if fieldType == "player" then
                    ctrl = vgui.Create("liaComboBox", panel)
                    ctrl:SetValue("Select" .. " " .. "Player")
                    local players = {}
                    for _, plyObj in player.Iterator() do
                        if IsValid(plyObj) then players[#players + 1] = plyObj end
                    end

                    if isfunction(filter) then
                        local ok, res = pcall(filter, LocalPlayer(), players)
                        if ok and istable(res) then players = res end
                    end

                    for _, plyObj in ipairs(players) do
                        local identifier = plyObj:SteamID()
                        if identifier == "BOT" then identifier = plyObj:Name() end
                        ctrl:AddChoice(plyObj:Name(), identifier)
                    end

                    ctrl:FinishAddingOptions()
                    ctrl:PostInit()
                elseif fieldType == "table" then
                    ctrl = vgui.Create("liaComboBox", panel)
                    ctrl:SetValue("Select" .. " " .. tostring(name))
                    local opts = options
                    if isfunction(opts) then
                        local ok, res = pcall(opts, LocalPlayer(), prefix)
                        if ok then opts = res end
                    end

                    if istable(opts) then
                        for k, v in pairs(opts) do
                            if isnumber(k) then
                                ctrl:AddChoice(tostring(v), v)
                            else
                                ctrl:AddChoice(tostring(k), v)
                            end
                        end
                    end

                    ctrl:FinishAddingOptions()
                    ctrl:PostInit()
                elseif fieldType == "bool" then
                    ctrl = vgui.Create("liaCheckbox", panel)
                else
                    ctrl = vgui.Create("liaEntry", panel)
                    ctrl:SetFont("LiliaFont.17")
                end

                local label = vgui.Create("DLabel", panel)
                label:SetFont("LiliaFont.20")
                label:SetText(tostring(data.description or name))
                label:SizeToContents()
                local isBool = fieldType == "bool"
                panel.PerformLayout = function(_, w, h)
                    local ctrlH, ctrlW
                    if isBool then
                        ctrlH, ctrlW = 22, 60
                    else
                        ctrlH, ctrlW = 60, w * 0.85
                    end

                    local ctrlX = (w - ctrlW) / 2
                    ctrl:SetPos(ctrlX, (h - ctrlH) / 2 + 6)
                    ctrl:SetSize(ctrlW, ctrlH)
                    label:SetPos((w - textW) / 2, (h - ctrlH) / 2 - 25)
                end

                controls[name] = {
                    ctrl = ctrl,
                    type = fieldType,
                    optional = optional
                }

                watchers[#watchers + 1] = function()
                    local oldValue = ctrl.OnValueChange
                    function ctrl:OnValueChange(...)
                        if oldValue then oldValue(self, ...) end
                        validate()
                    end

                    local oldText = ctrl.OnTextChanged
                    function ctrl:OnTextChanged(...)
                        if oldText then oldText(self, ...) end
                        validate()
                    end

                    local oldChange = ctrl.OnChange
                    function ctrl:OnChange(...)
                        if oldChange then oldChange(self, ...) end
                        validate()
                    end

                    local oldSelect = ctrl.OnSelect
                    function ctrl:OnSelect(...)
                        if oldSelect then oldSelect(self, ...) end
                        validate()
                    end
                end
            end
        end

        local buttons = vgui.Create("DPanel", frame)
        buttons:Dock(BOTTOM)
        buttons:SetTall(90)
        buttons:DockPadding(15, 15, 15, 15)
        buttons.Paint = function() end
        local submit = vgui.Create("liaButton", buttons)
        submit:Dock(LEFT)
        submit:DockMargin(0, 0, 15, 0)
        submit:SetWide(270)
        submit:SetTxt("Submit")
        submit:SetEnabled(false)
        validate = function()
            if not IsValid(submit) then return end
            for _, data in pairs(controls) do
                if not data.optional then
                    local ctl = data.ctrl
                    if not IsValid(ctl) then continue end
                    local ftype = data.type
                    local filled
                    if ftype == "player" or ftype == "table" then
                        local txt = ctl:GetValue()
                        filled = txt ~= nil and txt ~= "" and txt ~= "nil"
                    elseif ftype == "bool" then
                        filled = true
                    elseif ftype == "number" then
                        local val = ctl:GetValue()
                        local numVal = tonumber(val)
                        filled = val ~= nil and val ~= "" and val ~= "nil" and numVal ~= nil
                    else
                        local val = ctl:GetValue()
                        filled = val ~= nil and val ~= "" and val ~= "nil"
                    end

                    if not filled then
                        submit:SetEnabled(false)
                        return
                    end
                end
            end

            submit:SetEnabled(true)
        end

        timer.Simple(0.1, function() if IsValid(submit) then validate() end end)
        for _, fn in ipairs(watchers) do
            fn()
        end

        local cancel = vgui.Create("liaButton", buttons)
        cancel:Dock(RIGHT)
        cancel:SetWide(270)
        cancel:SetTxt("Cancel")
        cancel.DoClick = function() frame:Remove() end
        submit.DoClick = function()
            local args = {}
            if prefix then table.Add(args, prefix) end
            for _, arg in ipairs(command.arguments or {}) do
                local name = arg.name
                if controls[name] then
                    local info = controls[name]
                    local ctl = info.ctrl
                    local typ = info.type
                    local val
                    if typ == "player" or typ == "table" then
                        local dataVal = ctl:GetSelectedData()
                        val = dataVal or ctl:GetValue()
                    elseif typ == "bool" then
                        val = ctl:GetChecked()
                    elseif typ == "number" then
                        local strVal = ctl:GetValue()
                        val = strVal ~= nil and strVal ~= "" and strVal ~= "nil" and tonumber(strVal) or nil
                    else
                        val = ctl:GetValue()
                    end

                    args[#args + 1] = val ~= nil and val ~= "" and val ~= "nil" and val or nil
                end
            end

            RunConsoleCommand("say", "/" .. cmdKey .. " " .. table.concat(args, " "))
            frame:Remove()
        end
    end

    function lia.command.send(command, ...)
        net.Start("liaCommandData")
        net.WriteString(command)
        net.WriteTable({...})
        net.SendToServer()
    end
end

if CLIENT then
    local function getCommandThemeColors()
        local theme = lia.color and lia.color.theme or {}
        local accent = theme.accent or theme.theme
        if not IsColor(accent) then accent = lia.config.get("Color") end
        if not IsColor(accent) then accent = Color(45, 190, 170) end
        local textColor = theme.text
        if not IsColor(textColor) then textColor = Color(225, 238, 238) end
        return accent, textColor
    end

    local function drawCommandPanel(x, y, w, h, radius, color, outline)
        draw.RoundedBox(radius, x, y, w, h, color)
        if outline then
            surface.SetDrawColor(outline)
            surface.DrawOutlinedRect(x, y, w, h, 1)
        end
    end

    local function createCommandButton(parent, label, accented, callback)
        local button = parent:Add("DButton")
        button:SetText("")
        button.Paint = function(self, w, h)
            local accent, textColor = getCommandThemeColors()
            local hovered = self:IsHovered() and self:IsEnabled()
            local background
            local outline
            if accented then
                background = Color(accent.r, accent.g, accent.b, hovered and 32 or 16)
                outline = Color(accent.r, accent.g, accent.b, hovered and 185 or 120)
            else
                background = hovered and Color(255, 255, 255, 10) or Color(4, 17, 22, 210)
                outline = Color(160, 190, 192, hovered and 90 or 48)
            end

            if not self:IsEnabled() then
                background = Color(255, 255, 255, 5)
                outline = Color(255, 255, 255, 22)
            end

            drawCommandPanel(0, 0, w, h, 5, background, outline)
            local color = self:IsEnabled() and (accented and accent or textColor) or Color(115, 135, 136)
            draw.SimpleText(label, "LiliaFont.17", w * 0.5, h * 0.5, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        button.DoClick = function(self)
            if not self:IsEnabled() then return end
            lia.webcontent.playButtonSound()
            callback()
        end
        return button
    end

    local function addCommandInfoRow(parent, label, value, valueColor)
        local row = parent:Add("DPanel")
        row:Dock(TOP)
        row:SetTall(46)
        row.Paint = function(_, w, h)
            surface.SetDrawColor(130, 160, 162, 35)
            surface.DrawRect(0, h - 1, w, 1)
            draw.SimpleText(label, "LiliaFont.16", 14, h * 0.5, Color(165, 187, 188), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText(value or "", "LiliaFont.16", w - 14, h * 0.5, valueColor or Color(224, 235, 235), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        end
        return row
    end

    hook.Add("CreateInformationButtons", "liaInformationCommandsUnified", function(pages)
        table.insert(pages, {
            name = "Commands",
            shouldShow = function() return true end,
            drawFunc = function(parent)
                parent:Clear()
                local client = LocalPlayer()
                local root = parent:Add("DPanel")
                root:Dock(FILL)
                root.Paint = function() end
                local listPanel = root:Add("DPanel")
                listPanel:Dock(LEFT)
                listPanel:SetWide(math.Clamp(ScrW() * 0.245, 360, 440))
                listPanel:DockMargin(0, 0, 12, 0)
                listPanel:DockPadding(12, 12, 12, 12)
                listPanel.Paint = function(_, w, h)
                    local accent = getCommandThemeColors()
                    drawCommandPanel(0, 0, w, h, 7, Color(5, 18, 23, 215), Color(accent.r, accent.g, accent.b, 58))
                end

                local detailPanel = root:Add("DPanel")
                detailPanel:Dock(FILL)
                detailPanel.Paint = function() end
                local controls = listPanel:Add("DPanel")
                controls:Dock(TOP)
                controls:SetTall(46)
                controls:DockMargin(0, 0, 0, 12)
                controls.Paint = function() end
                local filter = controls:Add("DComboBox")
                filter:Dock(RIGHT)
                filter:SetWide(136)
                filter:DockMargin(8, 0, 0, 0)
                filter:SetValue("All Commands")
                filter:AddChoice("All Commands", "all")
                filter:AddChoice("General", "general")
                filter:AddChoice("Privileged", "privileged")
                filter:SetFont("LiliaFont.16")
                filter:SetTextColor(Color(0, 0, 0, 0))
                filter.Paint = function(self, w, h)
                    local accent = getCommandThemeColors()
                    drawCommandPanel(0, 0, w, h, 5, Color(6, 20, 26, 225), Color(accent.r, accent.g, accent.b, 60))
                    draw.SimpleText(self:GetValue(), "LiliaFont.16", 12, h * 0.5, Color(215, 229, 229), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                    draw.SimpleText("▼", "LiliaFont.15", w - 14, h * 0.5, Color(175, 197, 198), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end

                local searchPanel = controls:Add("DPanel")
                searchPanel:Dock(FILL)
                searchPanel:DockPadding(12, 0, 8, 0)
                searchPanel.Paint = function(_, w, h)
                    local accent = getCommandThemeColors()
                    drawCommandPanel(0, 0, w, h, 5, Color(6, 20, 26, 225), Color(accent.r, accent.g, accent.b, 60))
                end

                local searchEntry = searchPanel:Add("DTextEntry")
                searchEntry:Dock(FILL)
                searchEntry:SetFont("LiliaFont.16")
                searchEntry:SetTextColor(Color(225, 236, 236))
                searchEntry:SetCursorColor(getCommandThemeColors())
                searchEntry:SetPlaceholderText("Search Commands")
                searchEntry:SetPaintBackground(false)
                searchEntry:SetPaintBackground(false)
                searchEntry:SetPaintBorderEnabled(false)
                local sectionLabel = listPanel:Add("DLabel")
                sectionLabel:Dock(TOP)
                sectionLabel:SetTall(34)
                sectionLabel:SetText("AVAILABLE COMMANDS")
                sectionLabel:SetFont("LiliaFont.17")
                sectionLabel:SetTextColor(getCommandThemeColors())
                sectionLabel:SetContentAlignment(4)
                local countLabel = listPanel:Add("DLabel")
                countLabel:Dock(BOTTOM)
                countLabel:SetTall(28)
                countLabel:SetFont("LiliaFont.15")
                countLabel:SetTextColor(Color(145, 169, 170))
                countLabel:SetContentAlignment(4)
                local listScroll = listPanel:Add("liaScrollPanel")
                listScroll:Dock(FILL)
                listScroll.Paint = function() end
                local listCanvas = listScroll:GetCanvas()
                if IsValid(listCanvas) then
                    listCanvas:DockPadding(0, 0, 4, 0)
                    listCanvas.Paint = function() end
                else
                    listCanvas = listScroll
                end

                local records = {}
                local selectedRecord
                local selectedCard
                local selectedFilter = "all"
                local function updateCount()
                    local visible = 0
                    for _, record in ipairs(records) do
                        if IsValid(record.card) and record.card:IsVisible() then visible = visible + 1 end
                    end

                    countLabel:SetText(string.format("%d %s", visible, visible == 1 and "command" or "commands"))
                end

                local function matchesFilter(record)
                    if selectedFilter == "general" then return not record.privileged end
                    if selectedFilter == "privileged" then return record.privileged end
                    return true
                end

                local function applyFilters()
                    local query = string.Trim(searchEntry:GetValue() or ""):lower()
                    for _, record in ipairs(records) do
                        local visible = matchesFilter(record) and (query == "" or record.searchText:find(query, 1, true) ~= nil)
                        if IsValid(record.card) then record.card:SetVisible(visible) end
                    end

                    if IsValid(listCanvas) then listCanvas:InvalidateLayout(true) end
                    updateCount()
                end

                local function formatArguments(arguments)
                    if not arguments or #arguments == 0 then return "None" end
                    local names = {}
                    for _, argument in ipairs(arguments) do
                        local name = tostring(argument.name or argument.type or "Argument")
                        if argument.optional then name = name .. " (optional)" end
                        names[#names + 1] = name
                    end
                    return table.concat(names, ", ")
                end

                local function formatAliases(commandData)
                    local alias = commandData.alias
                    if not alias then return "None" end
                    if istable(alias) then return table.concat(alias, ", ") end
                    return tostring(alias)
                end

                local function rebuildDetail(record)
                    selectedRecord = record
                    detailPanel:Clear()
                    local accent, textColor = getCommandThemeColors()
                    local header = detailPanel:Add("DPanel")
                    header:Dock(TOP)
                    header:SetTall(140)
                    header:DockMargin(0, 0, 0, 12)
                    header.Paint = function(_, w, h)
                        drawCommandPanel(0, 0, w, h, 7, Color(5, 18, 23, 218), Color(accent.r, accent.g, accent.b, 58))
                        draw.SimpleText("/" .. record.name, "LiliaFont.26", 28, 24, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                        draw.SimpleText(record.syntax ~= "" and record.syntax or "No arguments required", "LiliaFont.16", 28, 60, Color(165, 187, 188), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                        local accessColor = record.privileged and accent or Color(60, 225, 160)
                        draw.SimpleText(record.access, "LiliaFont.16", 28, 102, accessColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                    end

                    local copyButton = createCommandButton(header, "COPY COMMAND", false, function()
                        local text = "/" .. record.name
                        if record.syntax ~= "" then text = text .. " " .. record.syntax end
                        SetClipboardText(text)
                    end)

                    copyButton:SetSize(160, 42)
                    local runButton = createCommandButton(header, "RUN COMMAND", true, function()
                        local arguments = record.data.arguments or {}
                        if #arguments > 0 then
                            local missing = {}
                            for _, argument in ipairs(arguments) do
                                missing[#missing + 1] = argument.name
                            end

                            lia.command.openArgumentPrompt(record.name, missing, {}, arguments)
                        else
                            lia.command.send(record.name)
                        end
                    end)

                    runButton:SetSize(154, 42)
                    header.PerformLayout = function(_, w)
                        runButton:SetPos(w - 170, 49)
                        copyButton:SetPos(w - 340, 49)
                    end

                    local scroll = detailPanel:Add("liaScrollPanel")
                    scroll:Dock(FILL)
                    scroll.Paint = function() end
                    local canvas = scroll:GetCanvas()
                    if IsValid(canvas) then
                        canvas:DockPadding(0, 0, 4, 0)
                        canvas.Paint = function() end
                    else
                        canvas = scroll
                    end

                    local infoSection = canvas:Add("DPanel")
                    infoSection:Dock(TOP)
                    infoSection:DockMargin(0, 0, 0, 12)
                    infoSection:DockPadding(14, 48, 14, 14)
                    infoSection.Paint = function(_, w, h)
                        drawCommandPanel(0, 0, w, h, 7, Color(5, 18, 23, 205), Color(accent.r, accent.g, accent.b, 52))
                        draw.SimpleText("COMMAND INFORMATION", "LiliaFont.17", 14, 16, accent, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                        surface.SetDrawColor(accent.r, accent.g, accent.b, 45)
                        surface.DrawRect(14, 39, w - 28, 1)
                    end

                    addCommandInfoRow(infoSection, "Command", "/" .. record.name)
                    addCommandInfoRow(infoSection, "Syntax", record.syntax ~= "" and record.syntax or "None")
                    addCommandInfoRow(infoSection, "Access", record.access, record.privileged and accent or Color(60, 225, 160))
                    addCommandInfoRow(infoSection, "Arguments", formatArguments(record.data.arguments))
                    addCommandInfoRow(infoSection, "Aliases", formatAliases(record.data))
                    infoSection.PerformLayout = function(self) self:SetTall(48 + 46 * 5 + 14) end
                    local descriptionSection = canvas:Add("DPanel")
                    descriptionSection:Dock(TOP)
                    descriptionSection:SetTall(170)
                    descriptionSection:DockMargin(0, 0, 0, 12)
                    descriptionSection:DockPadding(14, 50, 14, 14)
                    descriptionSection.Paint = function(_, w, h)
                        drawCommandPanel(0, 0, w, h, 7, Color(5, 18, 23, 205), Color(accent.r, accent.g, accent.b, 52))
                        draw.SimpleText("DESCRIPTION", "LiliaFont.17", 14, 16, accent, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                        surface.SetDrawColor(accent.r, accent.g, accent.b, 45)
                        surface.DrawRect(14, 39, w - 28, 1)
                    end

                    local description = descriptionSection:Add("DLabel")
                    description:Dock(FILL)
                    description:SetWrap(true)
                    description:SetAutoStretchVertical(true)
                    description:SetFont("LiliaFont.17")
                    description:SetTextColor(Color(205, 220, 220))
                    description:SetText(record.description ~= "" and record.description or "No description available.")
                    description:SetContentAlignment(7)
                end

                local function selectRecord(record)
                    if selectedRecord == record then return end
                    if IsValid(selectedCard) then selectedCard.selected = false end
                    selectedRecord = record
                    selectedCard = record.card
                    if IsValid(selectedCard) then selectedCard.selected = true end
                    rebuildDetail(record)
                end

                for cmdName, cmdData in SortedPairs(lia.command.list) do
                    if not isnumber(cmdName) then
                        local hasAccess, privilege = lia.command.hasAccess(client, cmdName, cmdData)
                        if hasAccess then
                            local syntax = cmdData.syntax and tostring(cmdData.syntax) or ""
                            local description = cmdData.desc and tostring(cmdData.desc) or ""
                            local access = privilege and tostring(privilege) or "Global"
                            local privileged = access ~= "Global"
                            local record = {
                                name = tostring(cmdName),
                                data = cmdData,
                                syntax = syntax,
                                description = description,
                                access = access,
                                privileged = privileged
                            }

                            record.searchText = table.concat({record.name, record.syntax, record.description, record.access, formatAliases(record.data)}, " "):lower()
                            local card = listCanvas:Add("DButton")
                            card:Dock(TOP)
                            card:SetTall(82)
                            card:DockMargin(0, 0, 0, 8)
                            card:SetText("")
                            card.selected = false
                            card.Paint = function(self, w, h)
                                local cardAccent = getCommandThemeColors()
                                local active = self.selected
                                local hovered = self:IsHovered()
                                local background = active and Color(cardAccent.r, cardAccent.g, cardAccent.b, 18) or hovered and Color(255, 255, 255, 7) or Color(6, 20, 25, 205)
                                local outline = active and Color(cardAccent.r, cardAccent.g, cardAccent.b, 125) or Color(cardAccent.r, cardAccent.g, cardAccent.b, 42)
                                drawCommandPanel(0, 0, w, h, 5, background, outline)
                                if active then
                                    surface.SetDrawColor(cardAccent.r, cardAccent.g, cardAccent.b, 235)
                                    surface.DrawRect(0, 8, 3, h - 16)
                                end

                                draw.SimpleText("/" .. record.name, "LiliaFont.18", 16, 17, active and Color(245, 249, 249) or Color(220, 231, 231), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                                local subtitle = record.syntax ~= "" and record.syntax or "No arguments"
                                draw.SimpleText(subtitle, "LiliaFont.15", 16, 48, Color(145, 169, 170), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                            end

                            card.DoClick = function()
                                lia.webcontent.playButtonSound()
                                selectRecord(record)
                            end

                            record.card = card
                            records[#records + 1] = record
                        end
                    end
                end

                if #records == 0 then
                    countLabel:SetText("0 commands")
                    local empty = listCanvas:Add("DLabel")
                    empty:Dock(TOP)
                    empty:SetTall(80)
                    empty:SetText("No commands available.")
                    empty:SetContentAlignment(5)
                    empty:SetTextColor(Color(150, 170, 170))
                    empty:SetFont("LiliaFont.18")
                    detailPanel.Paint = function(_, w, h)
                        local accent = getCommandThemeColors()
                        drawCommandPanel(0, 0, w, h, 7, Color(5, 18, 23, 190), Color(accent.r, accent.g, accent.b, 45))
                        draw.SimpleText("No commands available.", "LiliaFont.20", w * 0.5, h * 0.5, Color(150, 170, 170), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    end
                    return
                end

                searchEntry.OnChange = applyFilters
                filter.OnSelect = function(_, _, _, data)
                    selectedFilter = data or "all"
                    applyFilters()
                end

                selectRecord(records[1])
                applyFilters()
                parent.refreshCommands = function()
                    if not IsValid(parent) then return end
                    applyFilters()
                end
            end,
            onSelect = function(panel) if panel.refreshCommands then panel.refreshCommands() end end
        })
    end)
end

lia.command.findPlayer = lia.util.findPlayer
if SERVER then
    local function sanitizeFlags(flags)
        if not flags then return "" end
        local cleaned = tostring(flags):gsub("%s", "")
        local seen = {}
        local result = ""
        for i = 1, #cleaned do
            local flag = cleaned:sub(i, i)
            if not seen[flag] then
                seen[flag] = true
                result = result .. flag
            end
        end
        return result
    end

    local function mergeFlags(existing, additions)
        existing = sanitizeFlags(existing)
        additions = sanitizeFlags(additions)
        if additions == "" then return existing, "" end
        local seen = {}
        for i = 1, #existing do
            local flag = existing:sub(i, i)
            seen[flag] = true
        end

        local appended = ""
        for i = 1, #additions do
            local flag = additions:sub(i, i)
            if not seen[flag] then
                seen[flag] = true
                appended = appended .. flag
            end
        end

        if appended ~= "" then existing = existing .. appended end
        return existing, appended
    end

    local function normalizeSteamID(value)
        if not value or value == "" then return nil end
        if value:find("^%d+$") then
            local converted = util.SteamIDFrom64(value)
            if converted and converted ~= "STEAM_0:0:0" then return converted end
        end
        return value
    end

    local function findPlayerBySteamID(steamID)
        local steamID64 = util.SteamIDTo64(steamID)
        for _, ply in player.Iterator() do
            if ply:SteamID() == steamID or ply:SteamID64() == steamID64 then return ply end
        end
    end

    local function appendPermanentFlags(steamID, flagsStr)
        local normalized = normalizeSteamID(steamID)
        if not normalized then
            MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), "Invalid SteamID supplied.\n")
            return
        end

        local cleanedFlags = sanitizeFlags(flagsStr)
        if cleanedFlags == "" then
            MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), "No flags provided.\n")
            return
        end

        local target = findPlayerBySteamID(normalized)
        if target then
            local merged, appended = mergeFlags(target:getLiliaData("permanentflags", ""), cleanedFlags)
            if appended == "" then
                MsgC(Color(255, 165, 0), "[Lilia] ", Color(255, 255, 255), "No new flags to add for " .. normalized .. ".\n")
                return
            end

            target:setLiliaData("permanentflags", merged)
            local char = target:getChar()
            if char then char:giveFlags(appended) end
            MsgC(Color(0, 255, 0), "[Lilia] ", Color(255, 255, 255), "Added flags '" .. appended .. "' to " .. normalized .. ".\n")
            return
        end

        lia.db.selectOne({"data"}, "players", "steamID = " .. lia.db.convertDataType(normalized)):next(function(row)
            local data = {}
            if row and row.data then
                if isstring(row.data) then
                    data = util.JSONToTable(row.data) or {}
                elseif istable(row.data) then
                    data = row.data
                end
            end

            if not istable(data) then data = {} end
            local existingFlags = data.permanentflags or ""
            local merged, appended = mergeFlags(existingFlags, cleanedFlags)
            if appended == "" then
                MsgC(Color(255, 165, 0), "[Lilia] ", Color(255, 255, 255), "No new flags to add for " .. normalized .. ". Existing flags: '" .. existingFlags .. "', Attempted to add: '" .. cleanedFlags .. "'\n")
                return
            end

            data.permanentflags = merged
            if row then
                lia.db.updateTable({
                    data = util.TableToJSON(data)
                }, nil, "players", "steamID = " .. lia.db.convertDataType(normalized)):next(function() MsgC(Color(0, 255, 0), "[Lilia] ", Color(255, 255, 255), "Added flags '" .. appended .. "' to " .. normalized .. ". New flags: '" .. merged .. "'\n") end):catch(function(err) MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), "Error updating flags for (" .. normalized .. "): " .. tostring(err) .. "\n") end)
            else
                lia.db.insertTable({
                    steamID = normalized,
                    data = util.TableToJSON(data)
                }, nil, "players"):next(function() MsgC(Color(0, 255, 0), "[Lilia] ", Color(255, 255, 255), "Created player entry and added flags '" .. appended .. "' to " .. normalized .. ". New flags: '" .. merged .. "'\n") end):catch(function(err) MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), "Error creating player entry for (" .. normalized .. "): " .. tostring(err) .. "\n") end)
            end
        end):catch(function(err) MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), "Database error while checking player (" .. normalized .. "): " .. tostring(err) .. "\n") end)
    end

    concommand.Add("lia_givepermaflags", function(client, _, args)
        lia.debug("[Permissions]", "Permission Check for concommand lia_givepermaflags", "isValidPlayer=", tostring(IsValid(client)), "isSuperAdmin=", tostring(IsValid(client) and client:IsSuperAdmin() or true), "finalResult=", tostring(not IsValid(client) or client:IsSuperAdmin()))
        if IsValid(client) and not client:IsSuperAdmin() then return end
        appendPermanentFlags(args[1], args[2])
    end)

    concommand.Add("kickbots", function(client)
        lia.debug("[Permissions]", "Permission Check for concommand kickbots", "isValidPlayer=", tostring(IsValid(client)), "isSuperAdmin=", tostring(IsValid(client) and client:IsSuperAdmin() or true), "finalResult=", tostring(not IsValid(client) or client:IsSuperAdmin()))
        if IsValid(client) and not client:IsSuperAdmin() then
            client:notifyError(string.format("You do not have permission to use this command."))
            return
        end

        if timer.Exists("Bots_Add_Timer") then timer.Remove("Bots_Add_Timer") end
        local kickedCount = 0
        for _, bot in player.Iterator() do
            if bot:IsBot() then
                bot:Kick("All bots kicked")
                kickedCount = kickedCount + 1
            end
        end

        if IsValid(client) then
            if kickedCount == 0 then
                client:notifyError(string.format("No bots to kick."))
            else
                client:notifyInfo(string.format("Kicked %d bots from the server.", kickedCount))
            end
        else
            local message = kickedCount == 0 and "No bots to kick." or string.format("Kicked %d bots from the server.", kickedCount)
            MsgC(Color(83, 143, 239), "[Lilia] ", Color(255, 255, 255), message .. "\n")
        end
    end)

    concommand.Add("lia_check_updates", function(client)
        lia.debug("[Permissions]", "Permission Check for concommand lia_check_updates", "isValidPlayer=", tostring(IsValid(client)), "isSuperAdmin=", tostring(IsValid(client) and client:IsSuperAdmin() or true), "finalResult=", tostring(not IsValid(client) or client:IsSuperAdmin()))
        if IsValid(client) and not client:IsSuperAdmin() then
            client:notifyError(string.format("You do not have permission to use this command."))
            return
        end

        MsgC(Color(83, 143, 239), "[Lilia] ", Color(255, 255, 255), "Checking for updates..." .. "\n")
        lia.loader.checkForUpdates()
    end)

    local function handleSetUserGroup(ply, _, args)
        local steamID = string.Trim(args[1] or "")
        local usergroup = string.Trim(args[2] or "")
        local canUse = not IsValid(ply)
        lia.debug("[Permissions]", "Permission Check for function handleSetUserGroup", "isValidPlayer=", tostring(IsValid(ply)), "finalResult=", tostring(canUse))
        if not canUse then
            ply:notifyError(string.format("You are not allowed to do this."))
            return
        end

        if steamID == "" or not string.match(steamID, "^STEAM_%d+:%d+:%d+$") then
            if IsValid(ply) then
                ply:notifyError(string.format("Invalid player: %s", steamID))
            else
                MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), string.format("Invalid player: %s", steamID) .. "\n")
            end
            return
        end

        if usergroup == "" or not lia.admin.groups[usergroup] then
            if IsValid(ply) then
                ply:notifyError(string.format("Invalid usergroup: %s", usergroup))
            else
                MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), string.format("Invalid usergroup: %s", usergroup) .. "\n")
            end
            return
        end

        local target = lia.util.getBySteamID(steamID)
        lia.db.selectOne({"steamName", "userGroup"}, "players", "steamID = " .. lia.db.convertDataType(steamID)):next(function(data)
            if not data then
                if IsValid(ply) then
                    ply:notifyError(string.format("Player does not exist."))
                else
                    MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), string.format("Invalid player: %s", steamID) .. "\n")
                end
                return
            end

            lia.db.updateTable({
                userGroup = usergroup
            }, nil, "players", "steamID = " .. lia.db.convertDataType(steamID)):next(function()
                lia.admin.setSteamIDUsergroup(steamID, usergroup, IsValid(ply) and ply:Name() or "Console")
                if IsValid(target) and isfunction(target.getName) then target:notifyInfo(string.format("Usergroup set to %s.", usergroup)) end
                if IsValid(ply) then
                    local targetName = isfunction(target and target.getName) and target:getName() or data.steamName or steamID
                    ply:notifyInfo(string.format("%s's usergroup has been set to %s by an admin.", targetName, usergroup))
                end

                local playerName = isfunction(target and target.getName) and target:getName() or data.steamName or steamID
                MsgC(Color(0, 255, 0), "[Lilia] ", Color(255, 255, 255), "Set " .. playerName .. " (" .. steamID .. ") to usergroup: " .. usergroup .. "\n")
            end)
        end)
    end

    concommand.Add("plysetgroup", handleSetUserGroup)
    concommand.Add("plysetusergroup", handleSetUserGroup)
    concommand.Add("stopsoundall", function(client)
        local permission = client:hasPrivilege("stopSoundForEveryone")
        lia.debug("[Permissions]", "Permission Check for concommand stopsoundall", "hasPrivilege(stopSoundForEveryone)=", tostring(permission), "finalResult=", tostring(permission))
        if permission then
            for _, v in player.Iterator() do
                v:ConCommand("stopsound")
            end
        else
            client:notifyError(string.format("You are not allowed to do this."))
        end
    end)

    concommand.Add("bots", function(ply)
        if IsValid(ply) and not ply:IsSuperAdmin() then return end
        if timer.Exists("Bots_Add_Timer") then return end
        timer.Create("Bots_Add_Timer", 2, 0, function()
            if player.GetCount() >= game.MaxPlayers() then
                timer.Remove("Bots_Add_Timer")
                return
            end

            game.ConsoleCommand("bot\n")
        end)
    end)

    concommand.Add("list_entities", function(client)
        local entityCount = {}
        local totalEntities = 0
        if not IsValid(client) then
            lia.information("Entities on the server(" .. "):")
            for _, entity in ents.Iterator() do
                local class = entity:GetClass()
                entityCount[class] = (entityCount[class] or 0) + 1
                totalEntities = totalEntities + 1
            end

            for class, count in SortedPairs(entityCount) do
                MsgC(Color(83, 143, 239), "[Lilia] (", Color(255, 255, 255), class .. "): " .. count .. "\n")
            end

            MsgC(Color(83, 143, 239), "[Lilia] ", Color(255, 255, 255), string.format("Total entities on the server: %s", totalEntities) .. "\n")
        else
            client:notifyError(string.format("This command can only be run from the server console."))
        end
    end)

    concommand.Add("print_vector", function(client)
        if not IsValid(client) then
            MsgC(Color(255, 0, 0), "[Lilia] " .. "Error Prefix" .. "This command can only be used by players." .. "\n")
            return
        end

        local pos = client:GetPos()
        local vec = Vector(pos.x, pos.y, pos.z)
        MsgC(Color(83, 143, 239), "[Lilia] ", Color(255, 255, 255), "Vector(" .. "): " .. tostring(vec) .. "\n")
    end)

    concommand.Add("print_angle", function(client)
        if not IsValid(client) then
            MsgC(Color(255, 0, 0), "[Lilia] " .. "Error Prefix" .. "This command can only be used by players." .. "\n")
            return
        end

        local ang = client:GetAngles()
        MsgC(Color(83, 143, 239), "[Lilia] ", Color(255, 255, 255), "Angle: " .. tostring(ang) .. "\n")
    end)
else
    concommand.Add("lia_vgui_cleanup", function()
        for _, v in pairs(vgui.GetWorldPanel():GetChildren()) do
            if not (v.Init and debug.getinfo(v.Init, "Sln").short_src:find("chatbox")) then v:Remove() end
        end
    end)

    concommand.Add("printpos", function(client)
        if not IsValid(client) then
            MsgC(Color(255, 0, 0), "[Lilia] " .. "Error Prefix" .. "This command can only be used by players." .. "\n")
            return
        end

        local pos = client:GetPos()
        local ang = client:GetAngles()
        MsgC(Color(255, 255, 255), "Vector = (" .. math.Round(pos.x, 2) .. ", " .. math.Round(pos.y, 2) .. ", " .. math.Round(pos.z, 2) .. "), \nAngle = (" .. math.Round(ang.x, 2) .. ", " .. math.Round(ang.y, 2) .. ", " .. math.Round(ang.z, 2) .. ")\n")
    end)
end

lia.command.add("playtime", {
    adminOnly = false,
    desc = "Displays your total playtime on the server.",
    onRun = function(client)
        local secs = client:getPlayTime()
        if not secs then
            client:notifyError(string.format("Could not retrieve your playtime."))
            return
        end

        local h = math.floor(secs / 3600)
        local m = math.floor((secs % 3600) / 60)
        local s = secs % 60
        client:notifyInfo(string.format("Your playtime is %s hours, %s minutes, and %s seconds.", h, m, s))
    end
})

lia.command.add("charid", {
    adminOnly = false,
    desc = "Displays your current character's ID.",
    onRun = function(client)
        local char = client:getChar()
        if not char then
            client:notifyError(string.format("You have no character selected"))
            return
        end

        local charID = char:getID()
        client:notifyInfo(string.format("Your character ID is: %s", charID))
    end
})

lia.command.add("plygetplaytime", {
    adminOnly = true,
    arguments = {
        {
            name = "Name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "Get Player Playtime",
        ButtonText = "View Play Time",
        Category = "Player Info",
    },
    desc = "Shows the total playtime of the specified character.",
    onRun = function(client, args)
        if not args[1] then
            client:notifyError(string.format("Please specify a player."))
            return
        end

        local target = lia.util.findPlayer(client, args[1])
        if not IsValid(target) then
            client:notifyError(string.format("Target not found"))
            return
        end

        local secs = target:getPlayTime()
        local h = math.floor(secs / 3600)
        local m = math.floor((secs % 3600) / 60)
        local s = secs % 60
        client:ChatPrint(string.format("%s's playtime is %s hours, %s minutes, and %s seconds.", target:Nick(), h, m, s))
    end
})

lia.command.add("plycheckid", {
    adminOnly = true,
    arguments = {
        {
            name = "Name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "Check Character ID",
        ButtonText = "View Character ID",
        Category = "Player Info",
    },
    desc = "Shows the character ID of the specified player.",
    onRun = function(client, args)
        if not args[1] then
            client:notifyError(string.format("Please specify a player."))
            return
        end

        local target = lia.util.findPlayer(client, args[1])
        if not IsValid(target) then
            client:notifyError(string.format("Target not found"))
            return
        end

        local char = target:getChar()
        if not char then
            client:notifyError(string.format("Player has no character loaded"))
            return
        end

        local charID = char:getID()
        client:ChatPrint(string.format("%s's character ID is: %s", target:Nick(), charID))
    end
})

lia.command.add("checkid", {
    desc = "Displays your current character's ID.",
    onRun = function(client)
        local char = client:getChar()
        if not char then
            client:notifyError(string.format("You have no character selected"))
            return
        end

        local charID = char:getID()
        client:ChatPrint(string.format("Your character ID is: %s", charID))
    end
})

lia.command.add("charkill", {
    superAdminOnly = true,
    alias = "permakill",
    desc = "Opens the PK case menu to permanently kill a character.",
    arguments = {
        {
            name = "Name",
            type = "player"
        }
    },
    AdminStick = {
        Name = "Character Kill (Permakill)",
        ButtonText = "Kill Character",
        Category = "Character Discipline",
    },
    onRun = function(client, args)
        if not args[1] then
            client:notifyError(string.format("Please specify a player."))
            return
        end

        local ply = lia.util.findPlayer(client, args[1])
        if not IsValid(ply) then
            client:notifyError(string.format("Target not found"))
            return
        end

        local char = ply:getChar()
        if not char then
            client:notifyError(string.format("Player has no character loaded"))
            return
        end

        local isPermakilled = char:getData("permakilled", false)
        if isPermakilled then
            char:setData("permakilled", nil)
            lia.db.delete("permakills", "charID = " .. lia.db.convertDataType(char:getID()))
            client:notifySuccess(string.format("%s removed permakill marking from character %s.", client:Name(), ply:Nick()))
        else
            local reasonKey = "Reason"
            local evidenceKey = "Evidence"
            client:requestArguments("PK Reason & Evidence", {
                [reasonKey] = "string",
                [evidenceKey] = "string"
            }, function(success, data)
                if not success then return end
                local reason = data[reasonKey]
                local evidence = data[evidenceKey]
                lia.db.insertTable({
                    player = ply:Nick(),
                    reason = reason,
                    steamID = ply:SteamID(),
                    charID = char:getID(),
                    submitterName = client:Name(),
                    submitterSteamID = client:SteamID(),
                    timestamp = os.time(),
                    evidence = evidence
                }, nil, "permakills")

                char:setData("permakilled", true)
                local instantDeathKey = "Kill instantly (auto-ban)"
                client:requestArguments("PK Death Option", {
                    [instantDeathKey] = "boolean"
                }, function(success2, data2)
                    if not success2 then return end
                    local instantDeath = data2[instantDeathKey]
                    if instantDeath then
                        ply:Kill()
                        client:notifySuccess(string.format("%s marked character %s for permakill and killed them instantly.", client:Name(), ply:Nick()))
                    else
                        client:notifySuccess(string.format("%s marked character %s for permakill.", client:Name(), ply:Nick()))
                    end
                end)
            end)
        end
    end
})

lia.command.add("plyban", {
    adminOnly = true,
    desc = "Ban a player from the server for a duration.",
    arguments = {
        {
            name = "Name",
            type = "player"
        },
        {
            name = "duration",
            type = "string",
            optional = true
        },
        {
            name = "Reason",
            type = "string"
        },
    },
    AdminStick = {
        Name = "Ban Player",
        ButtonText = "Ban Player",
        Category = "Player Punishment",
    },
    onRun = function(client, arguments) lia.admin.serverExecCommand("ban", arguments[1], arguments[2], arguments[3], client) end
})

lia.command.add("plykick", {
    adminOnly = true,
    desc = "Kick a player from the server.",
    arguments = {
        {
            name = "Name",
            type = "player"
        },
        {
            name = "Reason",
            type = "string",
            optional = true
        },
    },
    AdminStick = {
        Name = "Kick Player",
        ButtonText = "Kick Player",
        Category = "Player Punishment",
    },
    onRun = function(client, arguments) lia.admin.serverExecCommand("kick", arguments[1], nil, arguments[2], client) end
})

lia.command.add("plykill", {
    adminOnly = true,
    desc = "Kill the specified player.",
    arguments = {
        {
            name = "Name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "Kill Player",
        ButtonText = "Kill Player",
        Category = "Player State",
    },
    onRun = function(client, arguments) lia.admin.serverExecCommand("kill", arguments[1], nil, nil, client) end
})

lia.command.add("plyunban", {
    adminOnly = true,
    desc = "Remove a player's ban by SteamID.",
    arguments = {
        {
            name = "steamid",
            type = "string"
        },
    },
    onRun = function(client, arguments)
        local steamid = arguments[1]
        if steamid and steamid ~= "" then
            lia.db.query("DELETE FROM lia_bans WHERE playerSteamID = " .. lia.db.convertDataType(steamid))
            client:notifySuccess(string.format("Player unbanned"))
        end
    end
})

lia.command.add("plyfreeze", {
    adminOnly = true,
    desc = "Freeze a player for an optional duration.",
    arguments = {
        {
            name = "Name",
            type = "player"
        },
        {
            name = "duration",
            type = "string",
            optional = true
        },
    },
    onRun = function(client, arguments) lia.admin.serverExecCommand("freeze", arguments[1], arguments[2], nil, client) end
})

lia.command.add("plyunfreeze", {
    adminOnly = true,
    desc = "Unfreeze a player.",
    arguments = {
        {
            name = "Name",
            type = "player"
        },
    },
    onRun = function(client, arguments) lia.admin.serverExecCommand("unfreeze", arguments[1], nil, nil, client) end
})

lia.command.add("plyslay", {
    adminOnly = true,
    desc = "Slay a player instantly.",
    arguments = {
        {
            name = "Name",
            type = "player"
        },
    },
    onRun = function(client, arguments) lia.admin.serverExecCommand("slay", arguments[1], nil, nil, client) end
})

lia.command.add("plyrespawn", {
    adminOnly = true,
    desc = "Force another player to respawn.",
    arguments = {
        {
            name = "Name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "Respawn Player",
        ButtonText = "Respawn Player",
        Category = "Player State",
    },
    onRun = function(client, arguments) lia.admin.serverExecCommand("respawn", arguments[1], nil, nil, client) end
})

lia.command.add("plyblind", {
    adminOnly = true,
    desc = "Blind a player with a black screen.",
    arguments = {
        {
            name = "Name",
            type = "player"
        },
        {
            name = "time",
            type = "string",
            optional = true
        },
    },
    onRun = function(client, arguments) lia.admin.serverExecCommand("blind", arguments[1], arguments[2], nil, client) end
})

lia.command.add("plyunblind", {
    adminOnly = true,
    desc = "Remove blindness from a player.",
    arguments = {
        {
            name = "Name",
            type = "player"
        },
    },
    onRun = function(client, arguments) lia.admin.serverExecCommand("unblind", arguments[1], nil, nil, client) end
})

lia.command.add("plyblindfade", {
    adminOnly = true,
    desc = "Fade a player's screen to a color.",
    arguments = {
        {
            name = "Name",
            type = "player"
        },
        {
            name = "time",
            type = "string",
            optional = true
        },
        {
            name = "Color",
            type = "string",
            optional = true
        },
        {
            name = "fadein",
            type = "string",
            optional = true
        },
        {
            name = "fadeout",
            type = "string",
            optional = true
        },
    },
    AdminStick = {
        Name = "Blind Player (Fade)",
        ButtonText = "Blindfade Player",
        Category = "Player State",
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if IsValid(target) then
            if lia.admin.isProtectedStaffTarget("blind", target) then
                lia.admin.notifyProtectedStaffTarget(client)
                return
            end

            local duration = tonumber(arguments[2]) or 0
            local colorName = (arguments[3] or "black"):lower()
            local fadeIn = tonumber(arguments[4])
            local fadeOut = tonumber(arguments[5])
            fadeIn = fadeIn or duration * 0.05
            fadeOut = fadeOut or duration * 0.05
            net.Start("liaBlindFade")
            net.WriteBool(colorName == "white")
            net.WriteFloat(duration)
            net.WriteFloat(fadeIn)
            net.WriteFloat(fadeOut)
            net.Send(target)
        end
    end
})

lia.command.add("blindfadeall", {
    adminOnly = true,
    desc = "Fade all non-staff players' screens.",
    arguments = {
        {
            name = "time",
            type = "string",
            optional = true
        },
        {
            name = "Color",
            type = "string",
            optional = true
        },
        {
            name = "fadein",
            type = "string",
            optional = true
        },
        {
            name = "fadeout",
            type = "string",
            optional = true
        },
    },
    onRun = function(_, arguments)
        local duration = tonumber(arguments[1]) or 0
        local colorName = (arguments[2] or "black"):lower()
        local fadeIn = tonumber(arguments[3]) or duration * 0.05
        local fadeOut = tonumber(arguments[4]) or duration * 0.05
        local isWhite = colorName == "white"
        for _, ply in player.Iterator() do
            local isStaffOnDuty = ply:isStaffOnDuty()
            lia.debug("[Permissions]", "Permission Check for command blindfadeall player recipient", "targetPlayer=", tostring(ply:Name()), "isStaffOnDuty=", tostring(isStaffOnDuty), "finalResult=", tostring(not isStaffOnDuty))
            if not isStaffOnDuty then
                net.Start("liaBlindFade")
                net.WriteBool(isWhite)
                net.WriteFloat(duration)
                net.WriteFloat(fadeIn)
                net.WriteFloat(fadeOut)
                net.Send(ply)
            end
        end
    end
})

lia.command.add("plygag", {
    adminOnly = true,
    desc = "Gag a player, blocking voice chat.",
    arguments = {
        {
            name = "Name",
            type = "player"
        },
    },
    onRun = function(client, arguments) lia.admin.serverExecCommand("gag", arguments[1], nil, nil, client) end
})

lia.command.add("plyungag", {
    adminOnly = true,
    desc = "Ungag a player.",
    arguments = {
        {
            name = "Name",
            type = "player"
        },
    },
    onRun = function(client, arguments) lia.admin.serverExecCommand("ungag", arguments[1], nil, nil, client) end
})

lia.command.add("plymute", {
    adminOnly = true,
    desc = "Mute a player's voice chat.",
    arguments = {
        {
            name = "Name",
            type = "player"
        },
    },
    onRun = function(client, arguments) lia.admin.serverExecCommand("mute", arguments[1], nil, nil, client) end
})

lia.command.add("plyunmute", {
    adminOnly = true,
    desc = "Unmute a player's voice chat.",
    arguments = {
        {
            name = "Name",
            type = "player"
        },
    },
    onRun = function(client, arguments) lia.admin.serverExecCommand("unmute", arguments[1], nil, nil, client) end
})

lia.command.add("plybring", {
    adminOnly = true,
    desc = "Teleport a player to you.",
    arguments = {
        {
            name = "Name",
            type = "player"
        },
    },
    onRun = function(client, arguments) lia.admin.serverExecCommand("bring", arguments[1], nil, nil, client) end
})

lia.command.add("plygoto", {
    adminOnly = true,
    desc = "Teleport yourself to a player.",
    arguments = {
        {
            name = "Name",
            type = "player"
        },
    },
    onRun = function(client, arguments) lia.admin.serverExecCommand("goto", arguments[1], nil, nil, client) end
})

lia.command.add("plyreturn", {
    adminOnly = true,
    desc = "Return a player to their previous position.",
    arguments = {
        {
            name = "Name",
            type = "player",
            optional = true
        },
    },
    onRun = function(client, arguments) lia.admin.serverExecCommand("return", arguments[1] or client:Name(), nil, nil, client) end
})

lia.command.add("plyjail", {
    adminOnly = true,
    desc = "Jail a player by locking and freezing them.",
    arguments = {
        {
            name = "Name",
            type = "player"
        },
    },
    onRun = function(client, arguments) lia.admin.serverExecCommand("jail", arguments[1], nil, nil, client) end
})

lia.command.add("plyunjail", {
    adminOnly = true,
    desc = "Release a jailed player.",
    arguments = {
        {
            name = "Name",
            type = "player"
        },
    },
    onRun = function(client, arguments) lia.admin.serverExecCommand("unjail", arguments[1], nil, nil, client) end
})

lia.command.add("plycloak", {
    adminOnly = true,
    desc = "Make a player invisible.",
    arguments = {
        {
            name = "Name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "Cloak Player",
        ButtonText = "Cloak Player",
        Category = "Player State",
    },
    onRun = function(client, arguments) lia.admin.serverExecCommand("cloak", arguments[1], nil, nil, client) end
})

lia.command.add("plyuncloak", {
    adminOnly = true,
    desc = "Remove invisibility from a player.",
    arguments = {
        {
            name = "Name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "Uncloak Player",
        ButtonText = "Uncloak Player",
        Category = "Player State",
    },
    onRun = function(client, arguments) lia.admin.serverExecCommand("uncloak", arguments[1], nil, nil, client) end
})

lia.command.add("plygod", {
    adminOnly = true,
    desc = "Enable god mode on a player.",
    arguments = {
        {
            name = "Name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "Give God Mode",
        ButtonText = "Enable Godmode",
        Category = "Player State",
    },
    onRun = function(client, arguments) lia.admin.serverExecCommand("god", arguments[1], nil, nil, client) end
})

lia.command.add("plyungod", {
    adminOnly = true,
    desc = "Disable a player's god mode.",
    arguments = {
        {
            name = "Name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "Remove God Mode",
        ButtonText = "Disable Godmode",
        Category = "Player State",
    },
    onRun = function(client, arguments) lia.admin.serverExecCommand("ungod", arguments[1], nil, nil, client) end
})

lia.command.add("plyignite", {
    adminOnly = true,
    desc = "Set a player on fire.",
    arguments = {
        {
            name = "Name",
            type = "player"
        },
        {
            name = "duration",
            type = "string",
            optional = true
        },
    },
    onRun = function(client, arguments) lia.admin.serverExecCommand("ignite", arguments[1], arguments[2], nil, client) end
})

lia.command.add("plyextinguish", {
    adminOnly = true,
    desc = "Extinguish the specified player.",
    arguments = {
        {
            name = "Name",
            type = "player"
        },
    },
    onRun = function(client, arguments) lia.admin.serverExecCommand("extinguish", arguments[1], nil, nil, client) end
})

lia.command.add("plystrip", {
    adminOnly = true,
    desc = "Strip all weapons from a player.",
    arguments = {
        {
            name = "Name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "Strip Weapons",
        ButtonText = "Strip Weapons",
        Category = "Player State",
    },
    onRun = function(client, arguments) lia.admin.serverExecCommand("strip", arguments[1], nil, nil, client) end
})

if SERVER then
    local function registerAdminConsoleCommand(name, callback)
        concommand.Add("lia_" .. name, function(client, _, arguments) callback(client, arguments or {}) end)
    end

    local function hasConsoleCommandAccess(client, privilegeID)
        if not IsValid(client) then return true end
        if lia.admin.hasAccess(client, privilegeID) then return true end
        client:notifyError(string.format("You are not allowed to do this."))
        return false
    end

    local function runTargetedAdminCommand(commandID, client, arguments, durationIndex, reasonStartIndex)
        if not hasConsoleCommandAccess(client, lia.admin.getCommandPrivilegeID(commandID)) then return end
        local target = arguments[1]
        if not target or target == "" then
            if IsValid(client) then
                client:notifyError(string.format("Target not found"))
            else
                print("[Lilia] Missing target.")
            end
            return
        end

        local duration = durationIndex and arguments[durationIndex] or nil
        local reason = reasonStartIndex and table.concat(arguments, " ", reasonStartIndex) or nil
        if reason == "" then reason = nil end
        lia.admin.serverExecCommand(commandID, target, duration, reason, client)
    end

    registerAdminConsoleCommand("plyban", function(client, arguments) runTargetedAdminCommand("ban", client, arguments, 2, 3) end)
    registerAdminConsoleCommand("plykick", function(client, arguments) runTargetedAdminCommand("kick", client, arguments, nil, 2) end)
    registerAdminConsoleCommand("plykill", function(client, arguments) runTargetedAdminCommand("kill", client, arguments) end)
    registerAdminConsoleCommand("plyunban", function(client, arguments)
        if not hasConsoleCommandAccess(client, lia.admin.getCommandPrivilegeID("unban")) then return end
        local steamid = arguments[1]
        if not steamid or steamid == "" then
            if IsValid(client) then
                client:notifyError(string.format("Target not found"))
            else
                print("[Lilia] Missing SteamID.")
            end
            return
        end

        lia.db.query("DELETE FROM lia_bans WHERE playerSteamID = " .. lia.db.convertDataType(steamid))
        if IsValid(client) then
            client:notifySuccess(string.format("Player unbanned"))
        else
            print("[Lilia] Unbanned " .. steamid .. ".")
        end
    end)

    registerAdminConsoleCommand("plyfreeze", function(client, arguments) runTargetedAdminCommand("freeze", client, arguments, 2) end)
    registerAdminConsoleCommand("plyunfreeze", function(client, arguments) runTargetedAdminCommand("unfreeze", client, arguments) end)
    registerAdminConsoleCommand("plyslay", function(client, arguments) runTargetedAdminCommand("slay", client, arguments) end)
    registerAdminConsoleCommand("plyrespawn", function(client, arguments) runTargetedAdminCommand("respawn", client, arguments) end)
    registerAdminConsoleCommand("plyblind", function(client, arguments) runTargetedAdminCommand("blind", client, arguments, 2) end)
    registerAdminConsoleCommand("plyunblind", function(client, arguments) runTargetedAdminCommand("unblind", client, arguments) end)
    registerAdminConsoleCommand("plygag", function(client, arguments) runTargetedAdminCommand("gag", client, arguments) end)
    registerAdminConsoleCommand("plyungag", function(client, arguments) runTargetedAdminCommand("ungag", client, arguments) end)
    registerAdminConsoleCommand("plymute", function(client, arguments) runTargetedAdminCommand("mute", client, arguments) end)
    registerAdminConsoleCommand("plyunmute", function(client, arguments) runTargetedAdminCommand("unmute", client, arguments) end)
    registerAdminConsoleCommand("plybring", function(client, arguments) runTargetedAdminCommand("bring", client, arguments) end)
    registerAdminConsoleCommand("plygoto", function(client, arguments) runTargetedAdminCommand("goto", client, arguments) end)
    registerAdminConsoleCommand("plyreturn", function(client, arguments)
        if not arguments[1] and IsValid(client) then arguments[1] = client:Name() end
        runTargetedAdminCommand("return", client, arguments)
    end)

    registerAdminConsoleCommand("plyjail", function(client, arguments) runTargetedAdminCommand("jail", client, arguments) end)
    registerAdminConsoleCommand("plyunjail", function(client, arguments) runTargetedAdminCommand("unjail", client, arguments) end)
    registerAdminConsoleCommand("plycloak", function(client, arguments) runTargetedAdminCommand("cloak", client, arguments) end)
    registerAdminConsoleCommand("plyuncloak", function(client, arguments) runTargetedAdminCommand("uncloak", client, arguments) end)
    registerAdminConsoleCommand("plygod", function(client, arguments) runTargetedAdminCommand("god", client, arguments) end)
    registerAdminConsoleCommand("plyungod", function(client, arguments) runTargetedAdminCommand("ungod", client, arguments) end)
    registerAdminConsoleCommand("plyignite", function(client, arguments) runTargetedAdminCommand("ignite", client, arguments, 2) end)
    registerAdminConsoleCommand("plyextinguish", function(client, arguments) runTargetedAdminCommand("extinguish", client, arguments) end)
    registerAdminConsoleCommand("plystrip", function(client, arguments) runTargetedAdminCommand("strip", client, arguments) end)
    registerAdminConsoleCommand("plyblindfade", function(client, arguments)
        if not hasConsoleCommandAccess(client, "command_blind") then return end
        local target = lia.util.findPlayer(client, arguments[1])
        if not IsValid(target) then
            if not IsValid(client) then print("[Lilia] Target not found.") end
            return
        end

        if lia.admin.isProtectedStaffTarget("blind", target) then
            if IsValid(client) then
                lia.admin.notifyProtectedStaffTarget(client)
            else
                print("[Lilia] You cannot use targeted admin commands on players in the staff faction.")
            end
            return
        end

        local duration = tonumber(arguments[2]) or 0
        local colorName = (arguments[3] or "black"):lower()
        local fadeIn = tonumber(arguments[4]) or duration * 0.05
        local fadeOut = tonumber(arguments[5]) or duration * 0.05
        net.Start("liaBlindFade")
        net.WriteBool(colorName == "white")
        net.WriteFloat(duration)
        net.WriteFloat(fadeIn)
        net.WriteFloat(fadeOut)
        net.Send(target)
        if not IsValid(client) then print(string.format("[Lilia] Applied blind fade to %s.", target:Name())) end
    end)

    registerAdminConsoleCommand("blindfadeall", function(client, arguments)
        if not hasConsoleCommandAccess(client, "command_blind") then return end
        local duration = tonumber(arguments[1]) or 0
        local colorName = (arguments[2] or "black"):lower()
        local fadeIn = tonumber(arguments[3]) or duration * 0.05
        local fadeOut = tonumber(arguments[4]) or duration * 0.05
        local isWhite = colorName == "white"
        for _, ply in player.Iterator() do
            local isStaffOnDuty = ply:isStaffOnDuty()
            lia.debug("[Permissions]", "Permission Check for admin console blindfadeall recipient", "targetPlayer=", tostring(ply:Name()), "isStaffOnDuty=", tostring(isStaffOnDuty), "finalResult=", tostring(not isStaffOnDuty))
            if not isStaffOnDuty then
                net.Start("liaBlindFade")
                net.WriteBool(isWhite)
                net.WriteFloat(duration)
                net.WriteFloat(fadeIn)
                net.WriteFloat(fadeOut)
                net.Send(ply)
            end
        end

        if not IsValid(client) then print("[Lilia] Applied blind fade to all non-staff-faction players.") end
    end)

    registerAdminConsoleCommand("charvoicetoggle", function(client, arguments)
        if not hasConsoleCommandAccess(client, "command_mute") then return end
        local target = lia.util.findPlayer(client, arguments[1])
        if not IsValid(target) then
            if not IsValid(client) then print("[Lilia] Target not found.") end
            return
        end

        if lia.admin.isProtectedStaffTarget("mute", target) then
            if IsValid(client) then
                lia.admin.notifyProtectedStaffTarget(client)
            else
                print("[Lilia] You cannot use targeted admin commands on players in the staff faction.")
            end
            return
        end

        if IsValid(client) and target == client then
            client:notifyError(string.format("You cannot toggle mute on yourself."))
            return
        end

        if not target:getChar() then
            if IsValid(client) then
                client:notifyError(string.format("The target does not have a valid character."))
            else
                print("[Lilia] That player does not have a valid character.")
            end
            return
        end

        local isMuted = target:getLiliaData("liaMuted", false)
        target:setLiliaData("liaMuted", not isMuted)
        if IsValid(client) then
            if isMuted then
                client:notifySuccess(string.format("%s has been unmuted for text chat.", target:Name()))
                target:notifyInfo(string.format("You have been unmuted for text chat by an admin."))
            else
                client:notifySuccess(string.format("%s has been muted for text chat.", target:Name()))
                target:notifyWarning(string.format("You have been muted for text chat by an admin."))
            end
        else
            if isMuted then
                print(string.format("[Lilia] Unmuted %s for text chat.", target:Name()))
            else
                print(string.format("[Lilia] Muted %s for text chat.", target:Name()))
            end
        end
    end)
end

lia.command.add("charunbanoffline", {
    superAdminOnly = true,
    desc = "Unban an offline character using their Char ID.",
    arguments = {
        {
            name = "charId",
            type = "string"
        },
    },
    onRun = function(client, arguments)
        local charID = tonumber(arguments[1])
        if not charID then return client:notifyError(string.format("Invalid character ID.")) end
        local result = sql.Query("SELECT id FROM lia_characters WHERE id = " .. charID .. " LIMIT 1")
        if not istable(result) or not result[1] then return client:notifyError(string.format("Character not found.")) end
        lia.char.setCharDatabase(charID, "banned", 0)
        lia.char.setCharDatabase(charID, "charBanInfo", nil)
        client:notifySuccess(string.format("Offline character ID %s has been unbanned.", charID))
    end
})

lia.command.add("charbanoffline", {
    superAdminOnly = true,
    desc = "Ban an offline character using their Char ID.",
    arguments = {
        {
            name = "charId",
            type = "string"
        },
    },
    onRun = function(client, arguments)
        local charID = tonumber(arguments[1])
        if not charID then return client:notifyError(string.format("Invalid character ID.")) end
        local result = sql.Query("SELECT id FROM lia_characters WHERE id = " .. charID .. " LIMIT 1")
        if not istable(result) or not result[1] then return client:notifyError(string.format("Character not found.")) end
        lia.char.setCharDatabase(charID, "banned", -1)
        lia.char.setCharDatabase(charID, "charBanInfo", {
            name = client:Nick(),
            steamID = client:SteamID(),
            rank = client:GetUserGroup()
        })

        for _, ply in player.Iterator() do
            if ply:getChar() and ply:getChar():getID() == charID then
                ply:Kick("You have been banned.")
                break
            end
        end

        client:notifySuccess(string.format("Offline character ID %s has been banned.", charID))
    end
})

lia.command.add("playglobalsound", {
    superAdminOnly = true,
    desc = "Play a global sound for all players.",
    arguments = {
        {
            name = "sound",
            type = "string"
        },
    },
    onRun = function(client, arguments)
        local sound = arguments[1]
        if not sound or sound == "" then
            client:notifyError(string.format("You must specify a sound path or name."))
            return
        end

        for _, target in player.Iterator() do
            target:PlaySound(sound)
        end
    end
})

lia.command.add("plyspectate", {
    adminOnly = true,
    desc = "Spectate a player in third person.",
    arguments = {
        {
            name = "Name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "Spectate Player",
        ButtonText = "Spectate Player",
        Category = "Observation",
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyError(string.format("Target not found"))
            return
        end

        if target == client then
            client:notifyError(string.format("You cannot spectate yourself"))
            return
        end

        if target.liaSpectating then
            client:notifyError(string.format("That player is already being spectated"))
            return
        end

        client.returnPos = client:GetPos()
        client.returnAng = client:EyeAngles()
        client:Spectate(OBS_MODE_CHASE)
        client:SpectateEntity(target)
        client:GodEnable()
        client.liaSpectating = true
        client:notifySuccess(string.format("You are now spectating %s.", target:Nick()))
        target:notifyInfo(string.format("%s is now spectating you.", client:Nick()))
    end
})

lia.command.add("stopspectate", {
    adminOnly = true,
    desc = "Stop spectating and return to normal view.",
    onRun = function(client)
        if not client.liaSpectating then
            client:notifyError(string.format("You are not currently spectating anyone"))
            return
        end

        client:UnSpectate()
        client:GodDisable()
        client.liaSpectating = false
        local returnPos = client.returnPos
        local returnAng = client.returnAng
        if returnPos then
            client:SetPos(returnPos)
            client.returnPos = nil
        end

        if returnAng then
            client:SetEyeAngles(returnAng)
            client.returnAng = nil
        end

        client:Give("weapon_physgun")
        client:Give("weapon_physcannon")
        client:Give("gmod_tool")
        client:notifySuccess(string.format("You have stopped spectating."))
    end
})

lia.command.add("playsound", {
    superAdminOnly = true,
    desc = "Play the specified sound on a specific player.",
    arguments = {
        {
            name = "Name",
            type = "player"
        },
        {
            name = "sound",
            type = "string"
        },
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        local sound = arguments[2]
        if not target or not IsValid(target) then
            client:notifyError(string.format("Target not found"))
            return
        end

        if not sound or sound == "" then
            client:notifyError(string.format("You must specify a sound path or name."))
            return
        end

        target:PlaySound(sound)
    end
})

lia.command.add("returntodeathpos", {
    adminOnly = true,
    desc = "Return to your last recorded death position.",
    onRun = function(client)
        if IsValid(client) and client:Alive() then
            local character = client:getChar()
            local oldPos = character and character:getData("deathPos")
            if oldPos then
                client:SetPos(oldPos)
                character:setData("deathPos", nil)
            else
                client:notifyError(string.format("No death position saved."))
            end
        else
            client:notifyWarning(string.format("Wait until you respawn."))
        end
    end
})

lia.command.add("roll", {
    adminOnly = false,
    desc = "Rolls a dice and displays the result.",
    onRun = function(client)
        local rollValue = math.random(0, 100)
        lia.chat.send(client, "roll", rollValue)
    end
})

lia.command.add("forcefallover", {
    adminOnly = true,
    desc = "Force another player to fall over (go into ragdoll).",
    arguments = {
        {
            name = "Name",
            type = "player"
        },
        {
            name = "time",
            type = "string",
            optional = true
        },
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyError(string.format("Target not found"))
            return
        end

        local time = tonumber(arguments[2])
        if not time or time < 1 then
            time = 5
        else
            time = math.Clamp(time, 1, 60)
        end

        target.FallOverCooldown = true
        target:setRagdolled(true, time)
    end
})

lia.command.add("forcegetup", {
    adminOnly = true,
    desc = "Force another player to get up from ragdoll.",
    arguments = {
        {
            name = "Name",
            type = "player"
        },
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyError(string.format("Target not found"))
            return
        end

        if not IsValid(target:GetRagdollEntity()) then return end
        local entity = target:GetRagdollEntity()
        if IsValid(entity) and entity.liaGrace and entity.liaGrace < CurTime() and entity:GetVelocity():Length2D() < 8 and not entity.liaWakingUp then
            entity.liaWakingUp = true
            target:setAction("Getting up", 5, function()
                if IsValid(entity) then
                    hook.Run("OnCharGetup", target, entity)
                    SafeRemoveEntity(entity)
                end
            end)
        end
    end
})

lia.command.add("chardesc", {
    adminOnly = false,
    desc = "Change your character's description.",
    arguments = {
        {
            name = "Description",
            type = "string",
            optional = true
        },
    },
    onRun = function(client, arguments)
        local desc = table.concat(arguments, " ")
        if not desc:find("%S") then return client:requestString("Change Name", "Enter the character's new name below.", function(text) lia.command.run(client, "chardesc", {text}) end, client:getChar() and client:getChar():getDesc() or "") end
        local trimmedDesc = string.Trim(desc)
        local descWithoutSpaces = string.gsub(trimmedDesc, "%s", "")
        local minLength = lia.config.get("MinDescLen", 16)
        if #descWithoutSpaces < minLength then
            client:notifyError(string.format("Description must be at least %s characters long.", minLength))
            return
        end

        local character = client:getChar()
        if character then character:setDesc(desc) end
        return "Character description has been changed."
    end
})

lia.command.add("chargetup", {
    adminOnly = false,
    desc = "Force yourself to get up from ragdoll (if possible).",
    onRun = function(client)
        if not IsValid(client:GetRagdollEntity()) then return end
        local entity = client:GetRagdollEntity()
        if IsValid(entity) and entity.liaGrace and entity.liaGrace < CurTime() and entity:GetVelocity():Length2D() < 8 and not entity.liaWakingUp then
            entity.liaWakingUp = true
            client:setAction("Getting up", 5, function()
                if IsValid(entity) then
                    hook.Run("OnCharGetup", client, entity)
                    SafeRemoveEntity(entity)
                end
            end)
        end
    end,
    alias = {"getup"}
})

lia.command.add("fallover", {
    adminOnly = false,
    desc = "Fall over (ragdoll) for a certain duration.",
    arguments = {
        {
            name = "time",
            type = "string",
            optional = true
        },
    },
    onRun = function(client, arguments)
        if client.FallOverCooldown then
            client:notifyWarning(string.format("This Command Is In Cooldown!"))
            return
        elseif client:IsFrozen() then
            client:notifyWarning(string.format("You cannot use this while frozen!"))
            return
        elseif not client:Alive() then
            client:notifyError(string.format("You cannot use this while dead!"))
            return
        elseif IsValid(client:GetVehicle()) then
            client:notifyWarning(string.format("You cannot use this as you are in a vehicle!"))
            return
        elseif client:GetMoveType() == MOVETYPE_NOCLIP then
            client:notifyWarning(string.format("You cannot use this while in noclip!"))
            return
        elseif IsValid(client:GetRagdollEntity()) then
            return
        end

        local time = math.Clamp(tonumber(arguments[1]) or 5, 1, 60)
        client.FallOverCooldown = true
        client:setRagdolled(true, time)
        timer.Simple(time, function() if IsValid(client) then client.FallOverCooldown = false end end)
    end
})

lia.command.add("togglelockcharacters", {
    superAdminOnly = true,
    desc = "Toggle whether players can swap characters.",
    onRun = function()
        local newVal = not GetGlobalBool("characterSwapLock", false)
        SetGlobalBool("characterSwapLock", newVal)
        if not newVal then
            return "Now the players will be able to change character"
        else
            return "Now the players won't be able to change character until the server is restarted or until you re-enable it"
        end
    end
})

lia.command.add("checkinventory", {
    adminOnly = true,
    desc = "Check another player's inventory.",
    arguments = {
        {
            name = "Name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "Check Inventory",
        ButtonText = "View Inventory",
        Category = "Inventory",
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyError(string.format("Target not found"))
            return
        end

        if target == client then
            client:notifyError(string.format("This isn't meant for checking your own inventory."))
            return
        end

        local inventory = target:getChar():getInv()
        inventory:addAccessRule(function(_, action) return action == "transfer" end, 1)
        inventory:addAccessRule(function(_, action) return action == "repl" end, 1)
        inventory:sync(client)
        net.Start("liaOpenInvMenu")
        net.WriteEntity(target)
        net.WriteType(inventory:getID())
        net.Send(client)
    end
})

lia.command.add("flaggive", {
    adminOnly = true,
    desc = "Give the following flags to the player.",
    arguments = {
        {
            name = "Name",
            type = "player"
        },
        {
            name = "Flags",
            type = "string"
        },
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyError(string.format("Target not found"))
            return
        end

        local flags = arguments[2]
        if not flags then
            local available = ""
            for k in SortedPairs(lia.flag.list) do
                if not target:hasFlags(k) then available = available .. k .. " " end
            end

            available = available:Trim()
            if available == "" then
                client:notifyInfo(string.format("No available flags to give."))
                return
            end
            return client:requestString("Give" .. " " .. "Flags", "Give the following flags to the player.", function(text) lia.command.run(client, "flaggive", {target:Name(), text}) end, available)
        end

        target:giveFlags(flags)
        client:notifySuccess(string.format("%s has given %s '%s' flags.", client:Name(), flags, target:Name()))
    end,
    alias = {"giveflag", "chargiveflag"}
})

lia.command.add("flaggiveall", {
    adminOnly = true,
    desc = "Give all possible flags to a character.",
    arguments = {
        {
            name = "Name",
            type = "player"
        },
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyError(string.format("Target not found"))
            return
        end

        for k, _ in SortedPairs(lia.flag.list) do
            if not target:hasFlags(k) then target:giveFlags(k) end
        end

        client:notifySuccess(string.format("You gave this player all flags!"))
    end
})

lia.command.add("flagtakeall", {
    adminOnly = true,
    desc = "Remove all flags from a character.",
    arguments = {
        {
            name = "Name",
            type = "player"
        },
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyError(string.format("Target not found"))
            return
        end

        if not target:getChar() then
            client:notifyError(string.format("Invalid Target!"))
            return
        end

        for k, _ in SortedPairs(lia.flag.list) do
            if target:hasFlags(k) then target:takeFlags(k) end
        end

        client:notifySuccess(string.format("You took this player's flags!"))
    end
})

lia.command.add("flagtake", {
    adminOnly = true,
    desc = "Remove the following flags from the player.",
    arguments = {
        {
            name = "Name",
            type = "player"
        },
        {
            name = "Flags",
            type = "string"
        },
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyError(string.format("Target not found"))
            return
        end

        local flags = arguments[2]
        if not flags then
            local currentFlags = target:getFlags()
            return client:requestString("Take" .. " " .. "Flags", "Remove the following flags from the player.", function(text) lia.command.run(client, "flagtake", {target:Name(), text}) end, table.concat(currentFlags, ", "))
        end

        target:takeFlags(flags)
        client:notifySuccess(string.format("%s has taken '%s' flags from %s.", client:Name(), flags, target:Name()))
    end,
    alias = {"takeflag"}
})

lia.command.add("bringlostitems", {
    superAdminOnly = true,
    desc = "Bring lost items in a 500 radius to your position.",
    onRun = function(client)
        for _, v in ipairs(ents.FindInSphere(client:GetPos(), 500)) do
            if v:isItem() then v:SetPos(client:GetPos()) end
        end
    end
})

lia.command.add("charvoicetoggle", {
    adminOnly = true,
    desc = "Toggles voice chat ban for the specified character.",
    arguments = {
        {
            name = "Name",
            type = "string"
        },
    },
    AdminStick = {
        Name = "Toggle Voice",
        ButtonText = "Toggle Voice",
        Category = "Communication",
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyError(string.format("Target not found"))
            return
        end

        if lia.admin.isProtectedStaffTarget("mute", target) then
            lia.admin.notifyProtectedStaffTarget(client)
            return false
        end

        if target == client then
            client:notifyError(string.format("You cannot toggle mute on yourself."))
            return false
        end

        if target:getChar() then
            local isMuted = target:getLiliaData("liaMuted", false)
            target:setLiliaData("liaMuted", not isMuted)
            if isMuted then
                client:notifySuccess(string.format("%s has been unmuted for text chat.", target:Name()))
                target:notifyInfo(string.format("You have been unmuted for text chat by an admin."))
            else
                client:notifySuccess(string.format("%s has been muted for text chat.", target:Name()))
                target:notifyWarning(string.format("You have been muted for text chat by an admin."))
            end
        else
            client:notifyError(string.format("The target does not have a valid character."))
        end
    end
})

lia.command.add("cleanitems", {
    superAdminOnly = true,
    desc = "Remove all item entities from the map.",
    onRun = function(client)
        local count = 0
        for _, v in ipairs(ents.FindByClass("lia_item")) do
            count = count + 1
            SafeRemoveEntity(v)
        end

        client:notifySuccess(string.format("You cleaned up %s: %s entities removed.", "Items", count))
    end
})

lia.command.add("cleanprops", {
    superAdminOnly = true,
    desc = "Remove all prop entities from the map.",
    onRun = function(client)
        local count = 0
        for _, entity in ents.Iterator() do
            if IsValid(entity) and entity:isProp() then
                count = count + 1
                SafeRemoveEntity(entity)
            end
        end

        client:notifySuccess(string.format("You cleaned up %s: %s entities removed.", "Props", count))
    end
})

lia.command.add("cleanragdolls", {
    superAdminOnly = true,
    desc = "Remove all ragdoll entities from the map except active player ragdolls.",
    onRun = function(client)
        local count = 0
        local protectedRagdolls = {}
        for _, ply in player.Iterator() do
            local ragdoll = ply:getRagdoll()
            if IsValid(ragdoll) then protectedRagdolls[ragdoll] = true end
        end

        for _, entity in ipairs(ents.FindByClass("prop_ragdoll")) do
            if IsValid(entity) and not protectedRagdolls[entity] then
                count = count + 1
                SafeRemoveEntity(entity)
            end
        end

        client:notifySuccess("You cleaned up ragdolls: " .. count .. " entities removed.")
    end
})

lia.command.add("resetmapprops", {
    superAdminOnly = true,
    desc = "Restore all map-created props by performing a map cleanup.",
    onRun = function(client)
        local started = SysTime()
        client:notifyInfo(string.format("Map cleanup started; map props will be restored shortly."))
        game.CleanUpMap(false, nil, function()
            if not IsValid(client) then return end
            local elapsed = math.Round((SysTime() - started) * 1000)
            client:notifySuccess(string.format("Map cleanup finished in %d ms; map props restored.", elapsed))
        end)
    end
})

lia.command.add("cleannpcs", {
    superAdminOnly = true,
    desc = "Remove all NPC entities from the map.",
    onRun = function(client)
        local count = 0
        for _, entity in ents.Iterator() do
            if IsValid(entity) and entity:IsNPC() then
                count = count + 1
                SafeRemoveEntity(entity)
            end
        end

        client:notifySuccess(string.format("You cleaned up %s: %s entities removed.", "NPCs", count))
    end
})

lia.command.add("charunban", {
    superAdminOnly = true,
    desc = "Unban a character by name or ID.",
    arguments = {
        {
            name = "nameOrNumberId",
            type = "string"
        },
    },
    onRun = function(client, arguments)
        if (client.liaNextSearch or 0) >= CurTime() then return "Searching for character..." end
        local queryArg = table.concat(arguments, " ")
        local charFound
        local id = tonumber(queryArg)
        if id then
            for _, v in pairs(lia.char.getAll()) do
                if v:getID() == id then
                    charFound = v
                    break
                end
            end
        else
            for _, v in pairs(lia.char.getAll()) do
                if lia.util.stringMatches(v:getName(), queryArg) then
                    charFound = v
                    break
                end
            end
        end

        if charFound then
            if charFound:isBanned() then
                charFound:setBanned(0)
                charFound:setData("permakilled", nil)
                charFound:setData("charBanInfo", nil)
                charFound:save()
                client:notifySuccess(string.format("%s has unbanned the character %s.", client:Name(), charFound:getName()))
            else
                return "This character isn't banned!"
            end
        end

        client.liaNextSearch = CurTime() + 15
        local sqlCondition = id and "id = " .. id or "name LIKE \"%" .. lia.db.escape(queryArg) .. "%\""
        lia.db.query("SELECT id, name FROM lia_characters WHERE " .. sqlCondition .. " LIMIT 1", function(data)
            if data and data[1] then
                local charID = tonumber(data[1].id)
                local banned = lia.char.getCharBanned(charID)
                client.liaNextSearch = 0
                if not banned or banned == 0 then
                    client:notifyInfo(string.format("This character isn't banned!"))
                    return
                end

                lia.char.setCharDatabase(charID, "banned", 0)
                lia.char.setCharDatabase(charID, "charBanInfo", nil)
                client:notifySuccess(string.format("%s has unbanned the character %s.", client:Name(), data[1].name))
            end
        end)
    end
})

lia.command.add("clearinv", {
    superAdminOnly = true,
    desc = "Clear a player's entire inventory.",
    arguments = {
        {
            name = "Name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "Clear Inventory",
        ButtonText = "Clear Inventory",
        Category = "Inventory",
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyError(string.format("Target not found"))
            return
        end

        target:getChar():getInv():wipeItems()
        client:notifySuccess(string.format("You have cleared %s's inventory!", target:getChar():getName()))
    end
})

lia.command.add("charkick", {
    adminOnly = true,
    desc = "Kick the target's active character to the character menu.",
    arguments = {
        {
            name = "Name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "Kick Character",
        ButtonText = "Kick Character",
        Category = "Character Discipline",
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyError(string.format("Target not found"))
            return
        end

        local character = target:getChar()
        if character then
            for _, targets in player.Iterator() do
                targets:notifyInfo(string.format("%s kicked character %s.", client:Name(), target:Name()))
            end

            character:kick()
        else
            client:notifyError(string.format("No character found!"))
        end
    end
})

lia.command.add("freezeallprops", {
    superAdminOnly = true,
    desc = "Freeze all props owned by a specific player.",
    arguments = {
        {
            name = "Name",
            type = "player"
        },
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyError(string.format("Target not found"))
            return
        end

        local count = 0
        local tbl = cleanup.GetList(target)[target:UniqueID()] or {}
        for _, propTable in pairs(tbl) do
            for _, ent in pairs(propTable) do
                if IsValid(ent) and IsValid(ent:GetPhysicsObject()) then
                    ent:GetPhysicsObject():EnableMotion(false)
                    count = count + 1
                end
            end
        end

        client:notifySuccess(string.format("You have frozen all of %s's Entities.", target:Name()))
        client:notifySuccess(string.format("Frozen %s Entities belonging to %s.", count, target:Name()))
    end
})

lia.command.add("charban", {
    superAdminOnly = true,
    desc = "Ban a character by name or ID.",
    arguments = {
        {
            name = "nameOrNumberId",
            type = "string"
        },
    },
    AdminStick = {
        Name = "Ban Character",
        ButtonText = "Ban Character",
        Category = "Character Discipline",
    },
    onRun = function(client, arguments)
        local queryArg = table.concat(arguments, " ")
        local target
        local id = tonumber(queryArg)
        if id then
            for _, ply in player.Iterator() do
                if IsValid(ply) and ply:getChar() and ply:getChar():getID() == id then
                    target = ply
                    break
                end
            end
        else
            target = lia.util.findPlayer(client, arguments[1])
        end

        if not target or not IsValid(target) then
            client:notifyError(string.format("Target not found"))
            return
        end

        local character = target:getChar()
        if character then
            character:setBanned(-1)
            character:setData("charBanInfo", {
                name = client.steamName and client:steamName() or client:Name(),
                steamID = client:SteamID(),
                rank = client:GetUserGroup()
            })

            character:save()
            character:kick()
            client:notifySuccess(string.format("%s banned the character %s.", client:Name(), target:Name()))
        else
            client:notifyError(string.format("No character found!"))
        end
    end
})

lia.command.add("charwipe", {
    superAdminOnly = true,
    desc = "Completely wipe a character from the database by name or ID.",
    arguments = {
        {
            name = "nameOrNumberId",
            type = "string"
        },
    },
    AdminStick = {
        Name = "Wipe Character",
        ButtonText = "Wipe Character",
        Category = "Character Discipline",
    },
    onRun = function(client, arguments)
        local queryArg = table.concat(arguments, " ")
        local target
        local id = tonumber(queryArg)
        if id then
            for _, ply in player.Iterator() do
                if IsValid(ply) and ply:getChar() and ply:getChar():getID() == id then
                    target = ply
                    break
                end
            end
        else
            target = lia.util.findPlayer(client, arguments[1])
        end

        if not target or not IsValid(target) then
            client:notifyError(string.format("Target not found"))
            return
        end

        local character = target:getChar()
        if character then
            local charID = character:getID()
            local charName = character:getName()
            character:kick()
            lia.char.delete(charID, target)
            if IsValid(target) and target.liaCharList then
                for i, charId in ipairs(target.liaCharList) do
                    if charId == charID then
                        table.remove(target.liaCharList, i)
                        break
                    end
                end

                hook.Run("SyncCharList", target)
            end

            client:notifySuccess(string.format("%s wiped the character %s from the database.", client:Name(), charName))
        else
            client:notifyError(string.format("No character found!"))
        end
    end
})

lia.command.add("charwipeoffline", {
    superAdminOnly = true,
    desc = "Completely wipe an offline character from the database using their Char ID.",
    arguments = {
        {
            name = "charId",
            type = "string"
        },
    },
    onRun = function(client, arguments)
        local charID = tonumber(arguments[1])
        if not charID then return client:notifyError(string.format("Invalid character ID.")) end
        lia.db.query("SELECT name FROM lia_characters WHERE id = " .. charID, function(data)
            if not data or #data == 0 then
                client:notifyError(string.format("Character not found."))
                return
            end

            for _, ply in player.Iterator() do
                if ply:getChar() and ply:getChar():getID() == charID then
                    ply:Kick("Your character has been wiped from the database.")
                    break
                end
            end

            lia.char.delete(charID)
            client:notifySuccess(string.format("Offline character ID %s has been wiped from the database.", charID))
        end)
    end
})

lia.command.add("checkmoney", {
    adminOnly = true,
    desc = "Check how much money the target player has.",
    arguments = {
        {
            name = "Name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "Check Money",
        ButtonText = "View Money",
        Category = "Character Info",
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyError(string.format("Target not found"))
            return
        end

        local money = target:getChar():getMoney()
        client:notifyMoney(string.format("%s has %s", target:GetName(), lia.currency.get(money)))
    end
})

lia.command.add("charsetspeed", {
    adminOnly = true,
    desc = "Set a player's run speed.",
    arguments = {
        {
            name = "Name",
            type = "player"
        },
        {
            name = "speed",
            type = "string",
            optional = true
        },
    },
    AdminStick = {
        Name = "Set Character Speed",
        ButtonText = "Set Character Speed",
        Category = "Character Editing",
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyError(string.format("Target not found"))
            return
        end

        local speed = tonumber(arguments[2]) or lia.config.get("WalkSpeed")
        target:SetRunSpeed(speed)
    end
})

lia.command.add("charsetmodel", {
    adminOnly = true,
    privilege = "manageCharacterInformation",
    desc = "Set a player's model.",
    arguments = {
        {
            name = "Name",
            type = "player"
        },
        {
            name = "Model",
            type = "string",
            optional = true
        },
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyError(string.format("Target not found"))
            return
        end

        local oldModel = target:getChar():getModel()
        target:getChar():setModel(arguments[2] or oldModel)
        target:SetupHands()
        client:notifySuccess(string.format("%s changed %s's model to %s.", client:Name(), target:Name(), arguments[2] or oldModel))
    end
})

lia.command.add("chargiveitem", {
    superAdminOnly = true,
    desc = "Give an item to a player's inventory.",
    arguments = {
        {
            name = "Name",
            type = "player"
        },
        {
            name = "Item Name",
            type = "string"
        },
    },
    AdminStick = {
        Name = "Give Item",
        ButtonText = "Give Item",
        Category = "Inventory",
    },
    onRun = function(client, arguments)
        local itemName = arguments[2]
        if not itemName or itemName == "" then
            client:notifyError(string.format("You must specify an item to give."))
            return
        end

        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyError(string.format("Target not found"))
            return
        end

        local uniqueID
        for _, v in SortedPairs(lia.item.list) do
            if lia.util.stringMatches(v.name, itemName) or lia.util.stringMatches(v.uniqueID, itemName) then
                uniqueID = v.uniqueID
                break
            end
        end

        if not uniqueID then
            client:notifyError(string.format("Sorry, the item that you requested does not exist."))
            return
        end

        local inv = target:getChar():getInv()
        local succ, err = inv:add(uniqueID)
        if succ then
            target:notifySuccess(string.format("Item created successfully."))
            if target ~= client then client:notifySuccess(string.format("Item created successfully.")) end
        else
            target:notifyError(err or "Unknown error")
        end
    end
})

lia.command.add("charsetdesc", {
    adminOnly = true,
    desc = "Set a player's character description.",
    arguments = {
        {
            name = "Name",
            type = "player"
        },
        {
            name = "description",
            type = "string",
            optional = true
        },
    },
    AdminStick = {
        Name = "Set Character Description",
        ButtonText = "Set Description",
        Category = "Character Editing",
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyError(string.format("Target not found"))
            return
        end

        if not target:getChar() then
            client:notifyError(string.format("No character found!"))
            return
        end

        local desc = table.concat(arguments, " ", 2)
        if not desc:find("%S") then return client:requestString(string.format("Change %s's Description", target:Name()), "Enter new description", function(text) lia.command.run(client, "charsetdesc", {arguments[1], text}) end, target:getChar():getDesc()) end
        target:getChar():setDesc(desc)
        return string.format("%s has changed %s's character description.", client:Name(), target:Name())
    end
})

lia.command.add("charsetname", {
    adminOnly = true,
    desc = "Set a player's character name.",
    arguments = {
        {
            name = "Name",
            type = "player"
        },
        {
            name = "newName",
            type = "string",
            optional = true
        },
    },
    AdminStick = {
        Name = "Set Character Name",
        ButtonText = "Set Character Name",
        Category = "Character Editing",
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyError(string.format("Target not found"))
            return
        end

        local newName = table.concat(arguments, " ", 2)
        if newName == "" then return client:requestString("Change Name", "Enter the character's new name below.", function(text) lia.command.run(client, "charsetname", {target:Name(), text}) end, target:Name()) end
        local oldName = target:getChar():getName()
        target:getChar():setName(newName:gsub("#", "#?"))
        client:notifySuccess(string.format("%s changed %s's name to %s.", client:Name(), oldName, newName))
    end
})

lia.command.add("charsetscale", {
    adminOnly = true,
    desc = "Set a player's model scale.",
    arguments = {
        {
            name = "Name",
            type = "player"
        },
        {
            name = "scale",
            type = "string",
            optional = true
        },
    },
    AdminStick = {
        Name = "Set Character Scale",
        ButtonText = "Set Character Scale",
        Category = "Character Editing",
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        local scale = tonumber(arguments[2]) or 1
        if not target or not IsValid(target) then
            client:notifyError(string.format("Target not found"))
            return
        end

        target:SetModelScale(scale, 0)
        client:notifySuccess(string.format("You changed %s's model scale to %s.", target:Name(), scale))
    end
})

lia.command.add("charsetjump", {
    adminOnly = true,
    desc = "Set a player's jump power.",
    arguments = {
        {
            name = "Name",
            type = "player"
        },
        {
            name = "power",
            type = "string",
            optional = true
        },
    },
    AdminStick = {
        Name = "Set Character Jump Height",
        ButtonText = "Set Jump Power",
        Category = "Character Editing",
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        local power = tonumber(arguments[2]) or 200
        if not target or not IsValid(target) then
            client:notifyError(string.format("Target not found"))
            return
        end

        target:SetJumpPower(power)
        client:notifySuccess(string.format("You changed %s's jump power to %s.", target:Name(), power))
    end
})

lia.command.add("charsetmoney", {
    superAdminOnly = true,
    desc = "Set a player's money to a specific amount.",
    arguments = {
        {
            name = "Name",
            type = "player"
        },
        {
            name = "amount",
            type = "string"
        },
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        local amount = tonumber(arguments[2])
        if not amount or amount < 0 then
            client:notifyError(string.format("Invalid argument."))
            return
        end

        if not target or not IsValid(target) then
            client:notifyError(string.format("Target not found"))
            return
        end

        target:getChar():setMoney(math.floor(amount))
        client:notifyMoney(string.format("You set %s's money to %s.", target:Name(), lia.currency.get(math.floor(amount))))
        StaffAddTextShadowed(Color(34, 139, 34), "MONEY", Color(255, 255, 255), string.format("%s set money of %s (Steam64ID: %s) to %s", client:Name(), target:Name(), target:SteamID64(), lia.currency.get(math.floor(amount))))
    end
})

lia.command.add("charaddmoney", {
    superAdminOnly = true,
    desc = "Add a certain amount of money to a player's balance.",
    arguments = {
        {
            name = "Name",
            type = "player"
        },
        {
            name = "amount",
            type = "string"
        },
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        local amount = tonumber(arguments[2])
        if not amount then
            client:notifyError(string.format("Invalid argument."))
            return
        end

        if not target or not IsValid(target) then
            client:notifyError(string.format("Target not found"))
            return
        end

        amount = math.Round(amount)
        local currentMoney = target:getChar():getMoney()
        target:getChar():setMoney(currentMoney + amount)
        client:notifyMoney(string.format("You gave %s an additional %s. Total: %s", target:Name(), lia.currency.get(amount), lia.currency.get(currentMoney + amount)))
        StaffAddTextShadowed(Color(34, 139, 34), "MONEY", Color(255, 255, 255), string.format("%s gave %s to %s (Steam64ID: %s). New balance: %s", client:Name(), lia.currency.get(amount), target:Name(), target:SteamID64(), lia.currency.get(currentMoney + amount)))
    end,
    alias = {"chargivemoney"}
})

lia.command.add("globalbotsay", {
    superAdminOnly = true,
    desc = "Force all bots on the server to say something.",
    arguments = {
        {
            name = "Message",
            type = "string"
        },
    },
    onRun = function(client, arguments)
        local message = table.concat(arguments, " ")
        if message == "" then
            client:notifyError(string.format("You must specify a message."))
            return
        end

        for _, bot in player.Iterator() do
            if bot:IsBot() then bot:Say(message) end
        end
    end
})

lia.command.add("botsay", {
    superAdminOnly = true,
    desc = "Force a specific bot to say something.",
    arguments = {
        {
            name = "botName",
            type = "string"
        },
        {
            name = "Message",
            type = "string"
        },
    },
    onRun = function(client, arguments)
        if #arguments < 2 then
            client:notifyError(string.format("You must specify a bot and a message."))
            return
        end

        local botName = arguments[1]
        local message = table.concat(arguments, " ", 2)
        local targetBot
        for _, bot in player.Iterator() do
            if bot:IsBot() and string.find(string.lower(bot:Nick()), string.lower(botName)) then
                targetBot = bot
                break
            end
        end

        if not targetBot then
            client:notifyError(string.format("No bot found with the name: %s", botName))
            return
        end

        targetBot:Say(message)
    end
})

lia.command.add("forcesay", {
    superAdminOnly = true,
    desc = "Force a player to say something in chat.",
    arguments = {
        {
            name = "Name",
            type = "player"
        },
        {
            name = "Message",
            type = "string"
        },
    },
    AdminStick = {
        Name = "Force Say",
        ButtonText = "Force Say",
        Category = "Communication",
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        local message = table.concat(arguments, " ", 2)
        if not target or not IsValid(target) then
            client:notifyError(string.format("Target not found"))
            return
        end

        if message == "" then
            client:notifyError(string.format("You must specify a message."))
            return
        end

        target:Say(message)
    end
})

lia.command.add("getmodel", {
    desc = "Get the model of the entity you are looking at.",
    onRun = function(client)
        local entity = client:getTracedEntity()
        if not IsValid(entity) then
            client:notifyError(string.format("No valid entity found in front of you."))
            return
        end

        local model = entity:GetModel()
        client:ChatPrint(model and string.format("The model is: %s", model) or "No model found.")
    end
})

lia.command.add("pm", {
    desc = "Sends a private message to a specified player.",
    arguments = {
        {
            name = "Name",
            type = "player"
        },
        {
            name = "Message",
            type = "string"
        },
    },
    onRun = function(client, arguments)
        if not lia.config.get("AllowPMs") then
            client:notifyError(string.format("Private Messages are Disabled"))
            return
        end

        local targetName = arguments[1]
        local message = table.concat(arguments, " ", 2)
        local target = lia.util.findPlayer(client, targetName)
        if not target or not IsValid(target) then
            client:notifyError(string.format("Target not found"))
            return
        end

        if not message:find("%S") then
            client:notifyError(string.format("You must specify a message."))
            return
        end

        lia.chat.send(client, "pm", message, false, {client, target})
    end
})

lia.command.add("chargetmodel", {
    adminOnly = true,
    desc = "Get the model of a player's character.",
    arguments = {
        {
            name = "Name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "Get Character Model",
        ButtonText = "View Model",
        Category = "Character Info",
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyError(string.format("Target not found"))
            return
        end

        client:ChatPrint(string.format("Character Model: %s", target:GetModel()))
    end
})

lia.command.add("checkallmoney", {
    superAdminOnly = true,
    desc = "Check every player's money balance.",
    onRun = function(client)
        for _, target in player.Iterator() do
            local char = target:getChar()
            if char then client:ChatPrint(string.format("%s has %s", target:GetName(), lia.currency.get(char:getMoney()))) end
        end
    end
})

lia.command.add("checkflags", {
    adminOnly = true,
    desc = "Check which flags a player has.",
    arguments = {
        {
            name = "Name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "Get Character Flags",
        ButtonText = "View Flags",
        Category = "Character Info",
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyError(string.format("Target not found"))
            return
        end

        local flags = target:getFlags()
        if flags and #flags > 0 then
            client:ChatPrint(string.format("Character flags for %s: %s", target:Name(), table.concat(flags, ", ")))
        else
            client:notifyInfo(string.format("%s has no flags.", target:Name()))
        end
    end
})

lia.command.add("chargetname", {
    adminOnly = true,
    desc = "Get a player's character name.",
    arguments = {
        {
            name = "Name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "Get Character Name",
        ButtonText = "View Character Name",
        Category = "Character Info",
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyError(string.format("Target not found"))
            return
        end

        client:ChatPrint(string.format("Character Name: %s", target:getChar():getName()))
    end
})

lia.command.add("chargethealth", {
    adminOnly = true,
    desc = "Get a player's current health.",
    arguments = {
        {
            name = "Name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "Get Character Health",
        ButtonText = "View Health",
        Category = "Character Info",
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyError(string.format("Target not found"))
            return
        end

        client:ChatPrint(string.format("Character Health: %s/%s", target:Health(), target:GetMaxHealth()))
    end
})

lia.command.add("chargetmoney", {
    adminOnly = true,
    desc = "Get how much money a player has.",
    arguments = {
        {
            name = "Name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "Get Character Money",
        ButtonText = "View Money",
        Category = "Character Info",
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyError(string.format("Target not found"))
            return
        end

        local money = target:getChar():getMoney()
        client:ChatPrint(string.format("Character Money: %s", lia.currency.get(money)))
    end
})

lia.command.add("chargetinventory", {
    adminOnly = true,
    desc = "Get the contents of a player's inventory.",
    arguments = {
        {
            name = "Name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "Get Character Inventory",
        ButtonText = "View Inventory",
        Category = "Character Info",
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyError(string.format("Target not found"))
            return
        end

        local inventory = target:getChar():getInv()
        local items = inventory:getItems()
        if not items or table.Count(items) < 1 then
            client:notifyInfo(string.format("Character Inventory is empty."))
            return
        end

        local result = {}
        for _, item in pairs(items) do
            table.insert(result, item.name)
        end

        client:ChatPrint(string.format("Character Inventory: %s", table.concat(result, ", ")))
    end
})

lia.command.add("getallinfos", {
    adminOnly = true,
    desc = "Print all character data columns to the console.",
    arguments = {
        {
            name = "Name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "Get All Informations",
        ButtonText = "View All Info",
        Category = "Character Info",
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyError(string.format("Target not found"))
            return
        end

        local char = target:getChar()
        if not char then
            client:notifyError(string.format("No character found!"))
            return
        end

        local data = lia.char.getCharData(char:getID())
        if not data then
            client:notifyError(string.format("No character found!"))
            return
        end

        lia.admin(string.format("=== All information for %s ===(", char:getName()))
        for column, value in pairs(data) do
            if istable(value) then
                lia.admin(column .. "):")
                PrintTable(value)
            else
                lia.admin(column .. " = " .. tostring(value))
            end
        end

        client:notifyInfo(string.format("Character information printed to console."))
    end
})

lia.command.add("dropmoney", {
    desc = "Drop money from your character's balance as a physical entity.",
    arguments = {
        {
            name = "amount",
            type = "string"
        },
    },
    onRun = function(client, arguments)
        local originalAmount = tonumber(arguments[1]) or 0
        local amount = math.floor(originalAmount)
        if originalAmount ~= amount and originalAmount > 0 then
            for _, admin in player.Iterator() do
                if admin:IsAdmin() then admin:notify(string.format("%s attempted to %s with decimal amount %s (floored to %s) - potential money duping!", client:Name(), "dropmoney", tostring(originalAmount), tostring(amount))) end
            end
        end

        if not amount or amount <= 0 then
            client:notifyError(string.format("Invalid argument."))
            return
        end

        local character = client:getChar()
        if not character or not character:hasMoney(amount) then
            client:notifyError(string.format("You don't have enough money"))
            return
        end

        local maxEntities = lia.config.get("MaxMoneyEntities", 3)
        local existingMoneyEntities = 0
        for _, entity in pairs(ents.FindByClass("lia_money")) do
            if entity.client == client then existingMoneyEntities = existingMoneyEntities + 1 end
        end

        if existingMoneyEntities >= maxEntities then
            client:notifyError(string.format("You have reached the maximum number of money entities (%d). Please wait for them to be picked up or removed.", maxEntities))
            return
        end

        character:takeMoney(amount)
        local money = lia.currency.spawn(client:getItemDropPos(), amount)
        if IsValid(money) then
            money.client = client
            money.charID = character:getID()
            client:notifyMoney(string.format("You dropped %s on the ground.", lia.currency.get(amount)))
        end

        client:doGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GMOD_GESTURE_ITEM_PLACE, true)
    end
})

lia.command.add("exportprivileges", {
    adminOnly = true,
    desc = "Export all current privileges to a data file",
    onRun = function(client)
        local filename = "lilia_registered_privileges.json"
        if not SERVER then return end
        local seen = {}
        local list = {}
        local function add(id, name)
            if isstring(id) or isnumber(id) then return end
            id = tostring(id)
            if id == "" then return end
            if seen[id] then return end
            seen[id] = true
            table.insert(list, {
                id = id,
                name = name and tostring(name) or ""
            })
        end

        local function walk(v)
            if istable(v) then return end
            for k, val in pairs(v) do
                if isstring(k) and (isboolean(val) or istable(val)) then if k ~= "" and k ~= "None" then add(k) end end
                if istable(val) then
                    local id = val.id or val.ID or val.Id or val.uniqueID or val.UniqueID
                    local name = val.name or val.Name or val.title or val.Title
                    if id then add(id, name) end
                    if val.privilege or val.Privilege then add(val.privilege or val.Privilege, name) end
                    if val.privileges or val.Privileges then
                        for _, p in pairs(val.privileges or val.Privileges) do
                            if istable(p) then
                                add(p.id or p.ID or p, p.name or p.Name)
                            elseif isstring(p) or isnumber(p) then
                                add(p)
                            end
                        end
                    end

                    walk(val)
                elseif isstring(val) or isnumber(val) then
                    if isstring(k) and k:lower() == "id" then add(val) end
                end
            end
        end

        local function collect(t)
            if istable(t) == "table" then walk(t) end
        end

        local srcs = {}
        do
            if lia.admin then
                table.insert(srcs, lia.admin.privileges)
                local privileges = lia.admin.getPrivileges(lia.admin)
                if privileges then table.insert(srcs, privileges) end
            end

            if lia.admin then
                table.insert(srcs, lia.admin.privileges)
                local privileges = lia.admin.getPrivileges(lia.admin)
                if privileges then table.insert(srcs, privileges) end
            end

            if lia.permission then
                table.insert(srcs, lia.permission.list)
                local permissions = lia.permission.getAll(lia.permission)
                if permissions then table.insert(srcs, permissions) end
            end

            if lia.permissions then table.insert(srcs, lia.permissions) end
            if lia.privileges then table.insert(srcs, lia.privileges) end
            if lia.command then table.insert(srcs, lia.command.stored or lia.command.list) end
            for _, p in pairs(lia.module.list) do
                if istable(p) == "table" then
                    table.insert(srcs, p.Privileges or p.privileges)
                    collect(p)
                end
            end
        end

        for _, s in pairs(srcs) do
            collect(s)
        end

        table.sort(list, function(a, b) return a.id < b.id end)
        local payload = {
            privileges = list
        }

        local jsonData = util.TableToJSON(payload, true)
        local wrote = false
        do
            local f = file.Open("gamemodes/Lilia/data/" .. filename, "wb", "GAME")
            if f then
                f:Write(jsonData)
                f:Close()
                wrote = true
            end
        end

        if not wrote then
            if not file.Exists("data", "DATA") then file.CreateDir("data") end
            wrote = file.Write("data/" .. filename, jsonData) and true or false
        end

        if wrote then
            client:notifySuccess(string.format("Privileges exported successfully to: %s", filename))
            MsgC(Color(83, 143, 239), "[Lilia] ", "[" .. "Admin" .. "] ")
            MsgC(Color(255, 153, 0), string.format("Privileges exported by %s to: %s", client:Nick(), filename), "\n")
        else
            client:notifyError(string.format("Failed to export privileges to expected locations"))
            lia.error("Failed to export privileges to expected locations")
        end
    end
})

lia.command.add("fillwithbots", {
    superAdminOnly = true,
    desc = "Manage server bots - list, kick, or spawn bots.",
    alias = {"bots"},
    arguments = {
        {
            name = "amount",
            type = "number",
            optional = true
        }
    },
    onRun = function(client, arguments)
        if not SERVER then return end
        if timer.Exists("Bots_Add_Timer") then
            client:notifyError(string.format("Bots are already being added to the server."))
            return
        end

        local requestedAmount = arguments.amount
        if requestedAmount then
            requestedAmount = math.max(1, math.floor(requestedAmount))
            local maxPlayers = game.MaxPlayers()
            local availableSlots = maxPlayers - player.GetCount()
            if requestedAmount > availableSlots then
                client:notifyError(string.format("Cannot spawn %d bots. Only %d slots available (server limit: %d).", requestedAmount, availableSlots, maxPlayers))
                return
            end

            if requestedAmount <= 0 then
                client:notifyError(string.format("Invalid amount. Please specify a positive number of bots to spawn."))
                return
            end

            local botsSpawned = 0
            timer.Create("Bots_Add_Timer", 2, 0, function()
                if botsSpawned < requestedAmount and player.GetCount() < game.MaxPlayers() then
                    game.ConsoleCommand("bot\n")
                    botsSpawned = botsSpawned + 1
                else
                    timer.Remove("Bots_Add_Timer")
                end
            end)

            client:notifyInfo(string.format("Spawning %d bots...", requestedAmount))
        else
            timer.Create("Bots_Add_Timer", 2, 0, function()
                if player.GetCount() < game.MaxPlayers() then
                    game.ConsoleCommand("bot\n")
                else
                    timer.Remove("Bots_Add_Timer")
                end
            end)

            client:notifyInfo(string.format("Filling server with bots..."))
        end
    end
})

lia.command.add("spawnbots", {
    superAdminOnly = true,
    desc = "Spawn a specific number of bots around your position.",
    arguments = {
        {
            name = "amount",
            type = "number"
        }
    },
    onRun = function(client, arguments)
        if not SERVER then return end
        local requestedAmount = math.max(1, math.floor(arguments.amount or 1))
        local maxPlayers = game.MaxPlayers()
        local availableSlots = maxPlayers - player.GetCount()
        if requestedAmount > availableSlots then
            client:notifyError(string.format("Cannot spawn %d bots. Only %d slots available (server limit: %d).", requestedAmount, availableSlots, maxPlayers))
            return
        end

        if requestedAmount <= 0 then
            client:notifyError(string.format("Invalid amount. Please specify a positive number of bots to spawn."))
            return
        end

        local botsSpawned = 0
        client:notifyInfo(string.format("Spawning %d bots...", requestedAmount))
        for i = 1, requestedAmount do
            timer.Simple((i - 1) * 0.5, function()
                if not IsValid(client) then return end
                game.ConsoleCommand("bot\n")
                botsSpawned = botsSpawned + 1
            end)
        end

        timer.Simple(requestedAmount * 0.5 + 2, function() if IsValid(client) then client:notifySuccess(string.format("Successfully spawned %d bots!", botsSpawned)) end end)
    end
})

lia.command.add("bot", {
    superAdminOnly = true,
    desc = "Spawn a bot and bring it to your location",
    onRun = function(client)
        if not SERVER then return end
        local maxPlayers = game.MaxPlayers()
        if player.GetCount() >= maxPlayers then
            client:notifyError(string.format("Cannot spawn %d bots. Only %d slots available (server limit: %d).", 1, 0, maxPlayers))
            return
        end

        client:notifyInfo(string.format("Spawning %d bots...", 1))
        game.ConsoleCommand("bot\n")
        timer.Simple(0.5, function()
            if not IsValid(client) then return end
            local bots = {}
            for _, ply in player.Iterator() do
                if ply:IsBot() then table.insert(bots, ply) end
            end

            table.sort(bots, function(a, b) return a:UserID() > b:UserID() end)
            local bot = bots[1]
            if IsValid(bot) then
                bot:SetPos(client:GetPos() + client:GetForward() * 50)
                local botName = bot:Name()
                if botName == "" then botName = "Bot" .. bot:UserID() end
                client:notifySuccess(string.format("Bot '%s' spawned and brought to your location!", botName))
            else
                client:notifyError(string.format("Failed to spawn bot."))
            end
        end)
    end
})

lia.command.add("botspeak", {
    superAdminOnly = true,
    desc = "Make all bots say a specified number of random phrases.",
    arguments = {
        {
            name = "phrases",
            type = "number",
            optional = true,
            default = 50
        }
    },
    onRun = function(client, arguments)
        if not SERVER then return end
        local phrasesPerBot = math.Clamp(arguments.phrases or 50, 1, 200)
        local cooldown = 1
        local bots = {}
        for _, ent in ents.Iterator() do
            if ent:IsNPC() or ent:IsNextBot() or (ent:IsPlayer() and ent:IsBot()) then table.insert(bots, ent) end
        end

        if #bots == 0 then
            client:notifyError(string.format("No bots found on the server."))
            return
        end

        client:notifyInfo(string.format("Found %d bots. Starting phrase sequence with %d phrases per bot...", #bots, phrasesPerBot))
        local randomPhrases = {"Hello there!", "What's going on?", "I need help!", "Over here!", "Watch out!", "Come on!", "Let's go!", "This way!", "Behind you!", "Enemy spotted!", "Clear!", "Move up!", "Hold position!", "Cover me!", "Reloading!", "Taking fire!", "Need backup!", "All clear!", "Contact!", "Engaging!", "Fall back!", "Push forward!", "Hold the line!", "Secure the area!", "Enemy down!", "Got one!", "Nice shot!", "Good work!", "Keep moving!", "Stay alert!"}
        local phraseCount = {}
        for _, bot in ipairs(bots) do
            phraseCount[bot] = 0
        end

        local function makeBotSpeak(bot)
            if not IsValid(bot) then return end
            if phraseCount[bot] < phrasesPerBot then
                local randomPhrase = randomPhrases[math.random(#randomPhrases)]
                bot:Say(randomPhrase)
                phraseCount[bot] = phraseCount[bot] + 1
                if phraseCount[bot] < phrasesPerBot then
                    timer.Simple(cooldown, function() if IsValid(bot) then makeBotSpeak(bot) end end)
                else
                    client:notifySuccess(string.format("Bot %s finished all %d phrases", bot:GetName() or tostring(bot), phrasesPerBot))
                end
            end
        end

        for _, bot in ipairs(bots) do
            makeBotSpeak(bot)
        end

        timer.Simple((phrasesPerBot * cooldown) + 5, function()
            local totalPhrases = 0
            for _, count in pairs(phraseCount) do
                totalPhrases = totalPhrases + count
            end

            client:notifySuccess(string.format("All bots finished! Total phrases said: %d", totalPhrases))
        end)
    end
})

lia.command.add("charsetattrib", {
    superAdminOnly = true,
    desc = "Set Attributes",
    arguments = {
        {
            name = "Name",
            type = "player"
        },
        {
            name = "attribute",
            type = "table",
            options = function()
                local options = {}
                for k, v in pairs(lia.attribs.list) do
                    options[v.name] = k
                end
                return options
            end
        },
        {
            name = "level",
            type = "number"
        }
    },
    AdminStick = {
        Name = "Set Attributes",
        ButtonText = "Set Attributes",
        Category = "Attributes",
    },
    onRun = function(client, arguments)
        if table.IsEmpty(lia.attribs.list) then
            client:notifyError(string.format("No attributes are currently registered in the system."))
            return
        end

        local target = lia.util.findPlayer(client, arguments[1])
        local attribName = arguments[2]
        local attribNumber = tonumber(arguments[3])
        if not target or not IsValid(target) then
            client:notifyError(string.format("Target not found"))
            return
        end

        local character = target:getChar()
        if character then
            for k, v in pairs(lia.attribs.list) do
                if lia.util.stringMatches(v.name, attribName) or lia.util.stringMatches(k, attribName) then
                    character:setAttrib(k, math.abs(attribNumber))
                    client:notifySuccess(string.format("You set %s's %s to %s.", target:Name(), v.name, math.abs(attribNumber)))
                    return
                end
            end
        end
    end
})

lia.command.add("checkattributes", {
    adminOnly = true,
    desc = "Check Attributes",
    arguments = {
        {
            name = "Name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "Check Attributes",
        ButtonText = "View Attributes",
        Category = "Attributes",
    },
    onRun = function(client, arguments)
        if table.IsEmpty(lia.attribs.list) then
            client:notifyError(string.format("No attributes are currently registered in the system."))
            return
        end

        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyError(string.format("Target not found"))
            return
        end

        local attributesData = {}
        for attrKey, attrData in SortedPairsByMemberValue(lia.attribs.list, "name") do
            local currentValue = target:getChar():getAttrib(attrKey, 0) or 0
            local limits = hook.Run("GetAttributeLimits", target, attrKey) or {}
            local maxValue = limits.max or 100
            local progress = math.Round(currentValue / maxValue * 100, 1)
            table.insert(attributesData, {
                charID = attrData.name,
                name = tostring(attrData.name),
                current = currentValue,
                max = maxValue,
                progress = progress .. "%"
            })
        end

        lia.util.createTableUI({
            title = "Character Attributes",
            columns = {
                {
                    name = "Attribute Name",
                    field = "name"
                },
                {
                    name = "Current Value",
                    field = "current"
                },
                {
                    name = "Max Value",
                    field = "max"
                },
                {
                    name = "Progress",
                    field = "progress"
                }
            },
            data = attributesData,
            options = {
                {
                    name = "Change Attribute",
                    ExtraFields = {
                        ["Amount"] = "text",
                        ["Mode"] = {"Add", "set"}
                    },
                    net = "ChangeAttribute"
                }
            },
            characterID = client:getChar():getID(),
        }, client)
    end
})

lia.command.add("staffdiscord", {
    desc = "Sets your staff Discord username.",
    arguments = {
        {
            name = "Discord",
            type = "string"
        }
    },
    onRun = function(client, arguments)
        local discord = arguments[1]
        local character = client:getChar()
        if not character or character:getFaction() ~= FACTION_STAFF then
            client:notifyError(string.format("No staff character found. Create one in the staff faction."))
            return
        end

        client:setLiliaData("staffDiscord", discord)
        local description = string.format("Staff Character - Discord: %s, SteamID: %s", discord, client:SteamID())
        character:setDesc(description)
        client:notifySuccess(string.format("Staff character description updated!"))
    end
})

lia.command.add("trunk", {
    adminOnly = false,
    desc = "Open the vehicle trunk you're looking at to access its storage inventory.",
    onRun = function(client)
        local entity = client:getTracedEntity()
        local maxDistance = 128
        local openTime = 0.7
        if not IsValid(entity) then
            client:notifyError(string.format("You're not looking at any vehicle!"))
            return
        end

        if not hook.Run("IsSuitableForTrunk", entity) == false then
            client:notifyError(string.format("You're not looking at any vehicle!"))
            return
        end

        if client:GetPos():Distance(entity:GetPos()) > maxDistance then
            client:notifyError(string.format("You're too far to open the trunk!"))
            return
        end

        client.liaStorageEntity = entity
        client:setAction("Opening...", openTime, function()
            if not IsValid(entity) then
                client.liaStorageEntity = nil
                return
            end

            if client:GetPos():Distance(entity:GetPos()) > maxDistance then
                client.liaStorageEntity = nil
                return
            end

            entity.receivers = entity.receivers or {}
            entity.receivers[client] = true
            local invID = entity:getNetVar("inv")
            local inv = invID and lia.inventory.instances[invID]
            local function openStorage(storageInv)
                if not storageInv then
                    client:notifyError(string.format("Player has no inventory"))
                    client.liaStorageEntity = nil
                    return
                end

                storageInv:sync(client)
                net.Start("liaStorageOpen")
                net.WriteBool(true)
                net.WriteEntity(entity)
                net.Send(client)
                entity:EmitSound("items/ammocrate_open.wav")
            end

            if inv then
                openStorage(inv)
            else
                lia.module.get("storage"):InitializeStorage(entity):next(openStorage, function(err)
                    client:notifyError(string.format("Unable to create storage entity for %s\n%s", entity:GetClass(), err))
                    client.liaStorageEntity = nil
                end)
            end
        end)
    end
})

lia.command.add("restockvendor", {
    superAdminOnly = true,
    desc = "Restocks all items for the vendor you are looking at to their default quantities.",
    onRun = function(client)
        local target = client:getTracedEntity()
        if not target or not IsValid(target) then
            client:notifyError(string.format("Target not found"))
            return
        end

        if target:GetClass() == "lia_vendor" then
            for id, itemData in pairs(target.items) do
                if itemData[2] and itemData[4] then target.items[id][2] = itemData[4] end
            end

            client:notifySuccess(string.format("The vendor has been restocked."))
        else
            client:notifyError(string.format("You are not looking at a valid vendor."))
        end
    end
})

lia.command.add("restockallvendors", {
    superAdminOnly = true,
    desc = "Restocks all items on every vendor on the map to their default quantities.",
    onRun = function(client)
        local count = 0
        for _, vendor in ipairs(ents.FindByClass("lia_vendor")) do
            for id, itemData in pairs(vendor.items) do
                if itemData[2] and itemData[4] then vendor.items[id][2] = itemData[4] end
            end

            count = count + 1
        end

        client:notifySuccess(string.format("All vendors have been restocked. Total vendors restocked: %s.", count))
    end
})

lia.command.add("deletevendorpreset", {
    adminOnly = true,
    desc = "Delete a saved vendor preset by name.",
    arguments = {
        {
            name = "presetName",
            type = "string"
        },
    },
    onRun = function(client, arguments)
        lia.debug("[Permissions]", "Permission Check for command savevendorpreset", "hasPrivilege(canCreateVendorPresets)=", tostring(client:hasPrivilege("canCreateVendorPresets")), "finalResult=", tostring(client:hasPrivilege("canCreateVendorPresets")))
        if not client:hasPrivilege("canCreateVendorPresets") then
            client:notifyError(string.format("No Permission"))
            return
        end

        local presetName = arguments[1]
        if not presetName or presetName:Trim() == "" then
            client:notifyError(string.format("Preset name is required"))
            return
        end

        presetName = presetName:Trim():lower()
        if not lia.vendor.presets[presetName] then
            client:notifyError(string.format("Vendor preset '%s' not found.", presetName))
            return
        end

        lia.vendor.presets[presetName] = nil
        if SERVER then
            lia.db.delete("vendor_presets", "name = " .. lia.db.convertDataType(presetName))
            net.Start("liaVendorSyncPresets")
            net.WriteTable(lia.vendor.presets)
            net.Broadcast()
        end

        client:notifySuccess(string.format("Vendor preset '%s' has been deleted.", presetName))
    end
})

lia.command.add("listvendorpresets", {
    adminOnly = true,
    desc = "List all saved vendor preset names.",
    onRun = function(client)
        lia.debug("[Permissions]", "Permission Check for command listvendorpresets", "hasPrivilege(canCreateVendorPresets)=", tostring(client:hasPrivilege("canCreateVendorPresets")), "finalResult=", tostring(client:hasPrivilege("canCreateVendorPresets")))
        if not client:hasPrivilege("canCreateVendorPresets") then
            client:notifyError(string.format("No Permission"))
            return
        end

        local presets = {}
        for name in pairs(lia.vendor.presets or {}) do
            presets[#presets + 1] = name
        end

        if #presets == 0 then
            client:notifyInfo(string.format("No vendor presets found."))
        else
            table.sort(presets)
            client:notifyInfo(string.format("Available presets: %s", table.concat(presets, ", ")))
        end
    end
})

lia.command.add("charaddattrib", {
    superAdminOnly = true,
    desc = "Add Attributes",
    arguments = {
        {
            name = "Name",
            type = "player"
        },
        {
            name = "attribute",
            type = "table",
            options = function()
                local options = {}
                for k, v in pairs(lia.attribs.list) do
                    options[v.name] = k
                end
                return options
            end
        },
        {
            name = "level",
            type = "number"
        }
    },
    AdminStick = {
        Name = "Add Attributes",
        ButtonText = "Add Attributes",
        Category = "Attributes",
    },
    onRun = function(client, arguments)
        if table.IsEmpty(lia.attribs.list) then
            client:notifyError(string.format("No attributes are currently registered in the system."))
            return
        end

        local target = lia.util.findPlayer(client, arguments[1])
        local attribName = arguments[2]
        local attribNumber = tonumber(arguments[3])
        if not target or not IsValid(target) then
            client:notifyError(string.format("Target not found"))
            return
        end

        local character = target:getChar()
        if character then
            for k, v in pairs(lia.attribs.list) do
                if lia.util.stringMatches(v.name, attribName) or lia.util.stringMatches(k, attribName) then
                    character:updateAttrib(k, math.abs(attribNumber))
                    client:notifySuccess(string.format("You added %s's %s by %s.", target:Name(), v.name, math.abs(attribNumber)))
                    return
                end
            end
        end
    end
})

lia.command.add("banooc", {
    adminOnly = true,
    desc = "Bans the specified player from using out-of-character chat.",
    arguments = {
        {
            name = "Name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "Ban OOC",
        ButtonText = "Ban From OOC",
        Category = "Communication",
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyError(string.format("Target not found"))
            return
        end

        target:setLiliaData("oocBanned", true)
        client:notifySuccess(string.format("%s has been banned from OOC.", target:Name()))
    end
})

lia.command.add("unbanooc", {
    adminOnly = true,
    desc = "Unbans the specified player from out-of-character chat.",
    arguments = {
        {
            name = "Name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "Unban OOC",
        ButtonText = "Unban From OOC",
        Category = "Communication",
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyError(string.format("Target not found"))
            return
        end

        target:setLiliaData("oocBanned", nil)
        client:notifySuccess(string.format("%s has been unbanned from OOC.", target:Name()))
    end
})

lia.command.add("clearchat", {
    adminOnly = true,
    desc = "Clears chat for all players.",
    onRun = function(client)
        net.Start("liaRegenChat")
        net.Broadcast()
    end
})

local function getDoorByMapID(doorID)
    doorID = math.floor(tonumber(doorID) or 0)
    if doorID <= 0 then return end
    local door = ents.GetMapCreatedEntity(doorID)
    if IsValid(door) and door:isDoor() then return door end
end

local function resolveDoorCommandTarget(client, arguments, minimumArgumentCount)
    minimumArgumentCount = minimumArgumentCount or 0
    arguments = istable(arguments) and arguments or {}
    local door
    local nextArgumentIndex = 1
    if #arguments > minimumArgumentCount then
        door = getDoorByMapID(arguments[1])
        if door then nextArgumentIndex = 2 end
    end

    if not IsValid(door) then
        local tracedDoor = client:getTracedEntity()
        if IsValid(tracedDoor) and tracedDoor:isDoor() then door = tracedDoor end
    end

    if not (IsValid(door) and door:isDoor()) then return end
    return door, nextArgumentIndex
end

lia.command.add("doorsell", {
    desc = "Sell a door you own and receive a refund based on the door's price.",
    adminOnly = false,
    AdminStick = {
        Name = "Sell Door",
        ButtonText = "Sell This Door",
        Category = "Door Actions",
        TargetClass = "door",
    },
    onRun = function(client, arguments)
        local door = resolveDoorCommandTarget(client, arguments, 0)
        if door then
            local doorData = lia.doors.getData(door)
            if not doorData.disabled then
                if client == door:GetDTEntity(0) then
                    local price = math.Round((doorData.price or 0) * lia.config.get("DoorSellRatio", 0.5))
                    door:removeDoorAccessData()
                    client:getChar():giveMoney(price)
                    client:notifyMoney(string.format("You have sold this door for %s.", lia.currency.get(price)))
                    hook.Run("OnPlayerPurchaseDoor", client, door, false)
                else
                    client:notifyError(string.format("You do not own this door."))
                end
            else
                client:notifyError(string.format("You are not looking at a valid door."))
            end
        else
            client:notifyError(string.format("You are not looking at a valid door."))
        end
    end
})

lia.command.add("admindoorsell", {
    desc = "Admin command to sell a door on behalf of its owner and refund the owner.",
    adminOnly = true,
    AdminStick = {
        Name = "Admin Sell Door",
        ButtonText = "Force Sell This Door",
        Category = "Door Actions",
        TargetClass = "door",
    },
    onRun = function(client, arguments)
        local door = resolveDoorCommandTarget(client, arguments, 0)
        if door then
            local doorData = lia.doors.getData(door)
            if not doorData.disabled then
                local owner = door:GetDTEntity(0)
                if IsValid(owner) and owner:IsPlayer() then
                    local price = math.Round((doorData.price or 0) * lia.config.get("DoorSellRatio", 0.5))
                    door:removeDoorAccessData()
                    owner:getChar():giveMoney(price)
                    owner:notifyMoney(string.format("You have sold this door for %s.", lia.currency.get(price)))
                    client:notifyMoney(string.format("You have sold this door for %s.", lia.currency.get(price)))
                    hook.Run("OnPlayerPurchaseDoor", owner, door, false)
                else
                    client:notifyError(string.format("You do not own this door."))
                end
            else
                client:notifyError(string.format("You are not looking at a valid door."))
            end
        else
            client:notifyError(string.format("You are not looking at a valid door."))
        end
    end
})

lia.command.add("doortogglelock", {
    desc = "Toggle a door's lock state between locked and unlocked.",
    adminOnly = true,
    AdminStick = {
        Name = "Toggle Door State",
        ButtonText = "Toggle Door Lock",
        Category = "Door Actions",
        TargetClass = "door",
    },
    onRun = function(client, arguments)
        local door = resolveDoorCommandTarget(client, arguments, 0)
        if door then
            local doorData = lia.doors.getData(door)
            if not doorData.disabled then
                local currentLockState = door:GetInternalVariable("m_bLocked")
                local toggleState = not currentLockState
                if toggleState then
                    door:Fire("lock")
                    door:EmitSound("doors/door_latch3.wav")
                    doorData.locked = true
                    lia.doors.setCachedData(door, doorData)
                else
                    door:Fire("unlock")
                    door:EmitSound("doors/door_latch1.wav")
                    doorData.locked = false
                    lia.doors.setCachedData(door, doorData)
                end

                local partner = door:getDoorPartner()
                if IsValid(partner) then
                    local partnerData = lia.doors.getData(partner)
                    if toggleState then
                        partner:Fire("lock")
                        partnerData.locked = true
                        lia.doors.setCachedData(partner, partnerData)
                    else
                        partner:Fire("unlock")
                        partnerData.locked = false
                        lia.doors.setCachedData(partner, partnerData)
                    end
                end
            else
                client:notifyError(string.format("You are not looking at a valid door."))
            end
        else
            client:notifyError(string.format("You are not looking at a valid door."))
        end
    end
})

lia.command.add("doorbuy", {
    desc = "Purchase a door if it is available and you can afford it.",
    adminOnly = false,
    AdminStick = {
        Name = "Buy Door",
        ButtonText = "Buy This Door",
        Category = "Door Actions",
        TargetClass = "door",
    },
    onRun = function(client, arguments)
        local door = resolveDoorCommandTarget(client, arguments, 0)
        if door then
            local doorData = lia.doors.getData(door)
            if not doorData.disabled then
                local factions = doorData.factions
                local classes = doorData.classes
                if doorData.noSell or (factions and #factions > 0) or (classes and #classes > 0) then return client:notifyError(string.format("You are not allowed to own this door.")) end
                if IsValid(door:GetDTEntity(0)) then
                    client:notifyInfo(string.format("This door is owned by %s.", door:GetDTEntity(0):Name()))
                    return false
                end

                local price = doorData.price or 0
                if client:getChar():hasMoney(price) then
                    door:SetDTEntity(0, client)
                    door.liaAccess = {
                        [client] = DOOR_OWNER
                    }

                    client:getChar():takeMoney(price)
                    client:notifySuccess(string.format("You have purchased this door for %s.", lia.currency.get(price)))
                    hook.Run("OnPlayerPurchaseDoor", client, door, true)
                else
                    client:notifyError(string.format("You cannot afford this door."))
                end
            else
                client:notifyError(string.format("You are not looking at a valid door."))
            end
        else
            client:notifyError(string.format("You are not looking at a valid door."))
        end
    end
})

lia.command.add("doortoggleownable", {
    desc = "Toggle whether a door can be owned by players.",
    adminOnly = true,
    AdminStick = {
        Name = "Toggle Door Ownable",
        ButtonText = "Toggle Door Ownable",
        Category = "Door Settings",
        TargetClass = "door",
    },
    onRun = function(client, arguments)
        local door = resolveDoorCommandTarget(client, arguments, 0)
        if door then
            local doorData = lia.doors.getData(door)
            if not doorData.disabled then
                local factions = doorData.factions or {}
                local classes = doorData.classes or {}
                local hasFactions = factions and #factions > 0
                local hasClasses = classes and #classes > 0
                local isUnownable = doorData.noSell or false
                local newState = not isUnownable
                if newState and (hasFactions or hasClasses) then
                    client:notifyError(string.format("This door cannot be owned."))
                    return false
                end

                doorData.noSell = newState and true or nil
                lia.doors.setData(door, doorData)
                hook.Run("DoorOwnableToggled", client, door, newState)
                client:notifySuccess(newState and "This door is now unownable." or "This door is now ownable.")
                lia.module.get("doors"):SaveData()
            else
                client:notifyError(string.format("You are not looking at a valid door."))
            end
        else
            client:notifyError(string.format("You are not looking at a valid door."))
        end
    end
})

lia.command.add("doorresetdata", {
    desc = "Reset door data to default settings.",
    adminOnly = true,
    AdminStick = {
        Name = "Reset Door Data",
        ButtonText = "Reset Door Data",
        Category = "Door Maintenance",
        TargetClass = "door",
    },
    onRun = function(client, arguments)
        local door = resolveDoorCommandTarget(client, arguments, 0)
        if door then
            local doorData = {
                disabled = nil,
                noSell = nil,
                hidden = nil,
                classes = nil,
                factions = {},
                name = nil,
                price = 0,
                locked = false
            }

            lia.doors.setData(door, doorData)
            client:notifySuccess(string.format("The door data has been reset."))
            lia.module.get("doors"):SaveData()
        else
            client:notifyError(string.format("You are not looking at a valid door."))
        end
    end
})

lia.command.add("doortoggleenabled", {
    desc = "Toggle door enabled state (active/inactive).",
    adminOnly = true,
    AdminStick = {
        Name = "Toggle Door Enabled",
        ButtonText = "Toggle Door Enabled",
        Category = "Door Settings",
        TargetClass = "door",
    },
    onRun = function(client, arguments)
        local door = resolveDoorCommandTarget(client, arguments, 0)
        if door then
            local doorData = lia.doors.getData(door)
            local isDisabled = doorData.disabled or false
            local newState = not isDisabled
            doorData.disabled = newState and true or nil
            lia.doors.setData(door, doorData)
            hook.Run("DoorEnabledToggled", client, door, newState)
            client:notifySuccess(newState and "This door is now disabled." or "This door is now enabled.")
            lia.module.get("doors").list["doors"]:SaveData()
        else
            client:notifyError(string.format("You are not looking at a valid door."))
        end
    end
})

lia.command.add("doortogglehidden", {
    desc = "Toggle the hidden state of a door.",
    adminOnly = true,
    AdminStick = {
        Name = "Toggle Door Hidden",
        ButtonText = "Toggle Door Hidden",
        Category = "Door Settings",
        TargetClass = "door",
    },
    onRun = function(client, arguments)
        local door = resolveDoorCommandTarget(client, arguments, 0)
        if door then
            local doorData = lia.doors.getData(door)
            local currentState = doorData.hidden or false
            local newState = not currentState
            doorData.hidden = newState
            lia.doors.setData(door, doorData)
            hook.Run("DoorHiddenToggled", client, door, newState)
            client:notifySuccess(newState and "This door is now hidden." or "This door is now visible.")
            lia.module.get("doors"):SaveData()
        else
            client:notifyError(string.format("You are not looking at a valid door."))
        end
    end
})

lia.command.add("doorsetprice", {
    desc = "Set the price for a door.",
    arguments = {
        {
            name = "Price",
            type = "string"
        },
    },
    adminOnly = true,
    AdminStick = {
        Name = "Set Door Price",
        ButtonText = "Set Door Price",
        Category = "Door Settings",
        TargetClass = "door",
    },
    onRun = function(client, arguments)
        local door, argumentIndex = resolveDoorCommandTarget(client, arguments, 1)
        if door then
            local doorData = lia.doors.getData(door)
            if not doorData.disabled then
                if not arguments[argumentIndex] or not tonumber(arguments[argumentIndex]) then return client:notifyError(string.format("The specified class is not valid.")) end
                local price = math.Clamp(math.floor(tonumber(arguments[argumentIndex])), 0, 1000000)
                doorData.price = price
                lia.doors.setData(door, doorData)
                hook.Run("DoorPriceSet", client, door, price)
                client:notifySuccess(string.format("You have set this door's price to %s.", lia.currency.get(price)))
                lia.module.get("doors"):SaveData()
            else
                client:notifyError(string.format("You are not looking at a valid door."))
            end
        else
            client:notifyError(string.format("You are not looking at a valid door."))
        end
    end
})

lia.command.add("doorsettitle", {
    desc = "Set the title for a door.",
    arguments = {
        {
            name = "Title",
            type = "string"
        },
    },
    adminOnly = true,
    AdminStick = {
        Name = "Set Door Title",
        ButtonText = "Set Door Title",
        Category = "Door Settings",
        TargetClass = "door",
    },
    onRun = function(client, arguments)
        local door, argumentIndex = resolveDoorCommandTarget(client, arguments, 1)
        if door then
            local doorData = lia.doors.getData(door)
            if not doorData.disabled then
                local name = table.concat(arguments, " ", argumentIndex)
                if not name:find("%S") then return client:notifyError(string.format("The specified class is not valid.")) end
                if door:checkDoorAccess(client, DOOR_TENANT) or client:isStaff() then
                    doorData.name = name
                    lia.doors.setData(door, doorData)
                    hook.Run("DoorTitleSet", client, door, name)
                    client:notifySuccess(string.format("Door title set to '%s'.", name))
                else
                    client:notifyError(string.format("You do not own this door."))
                end
            else
                client:notifyError(string.format("You are not looking at a valid door."))
            end
        else
            client:notifyError(string.format("You are not looking at a valid door."))
        end
    end
})

lia.command.add("savedoors", {
    desc = "Save door data persistently.",
    adminOnly = true,
    AdminStick = {
        Name = "Save Doors",
        ButtonText = "Save Door Data",
        Category = "Door Maintenance",
        TargetClass = "door",
    },
    onRun = function(client)
        lia.module.get("doors"):SaveData()
        client:notifySuccess(string.format("Saved Doors!"))
    end
})

lia.command.add("doorinfo", {
    desc = "Display information about the targeted door.",
    adminOnly = true,
    AdminStick = {
        Name = "Get Door Information",
        ButtonText = "View Door Info",
        Category = "Door Information",
        TargetClass = "door",
    },
    onRun = function(client, arguments)
        local door = resolveDoorCommandTarget(client, arguments, 0)
        if door then
            local doorData = lia.doors.getData(door)
            local disabled = doorData.disabled or false
            local price = doorData.price or 0
            local noSell = doorData.noSell or false
            local factions = doorData.factions or {}
            local factionNames = {}
            for _, id in ipairs(factions) do
                local info = lia.faction.get(id)
                if info then table.insert(factionNames, info.name) end
            end

            local classes = doorData.classes or {}
            local classNames = {}
            for _, uid in ipairs(classes) do
                local idx = lia.class.retrieveClass(uid)
                local info = lia.class.list[idx]
                if info then table.insert(classNames, info.name) end
            end

            local hidden = doorData.hidden or false
            local infoData = {
                {
                    property = "Disabled",
                    value = tostring(disabled)
                },
                {
                    property = "Name",
                    value = tostring(doorData.name or "Unowned Door")
                },
                {
                    property = "Price",
                    value = lia.currency.get(price)
                },
                {
                    property = "No Sell",
                    value = tostring(noSell)
                },
                {
                    property = "Factions",
                    value = tostring(not table.IsEmpty(factionNames) and table.concat(factionNames, ", ") or "None")
                },
                {
                    property = "Classes",
                    value = tostring(not table.IsEmpty(classNames) and table.concat(classNames, ", ") or "None")
                },
                {
                    property = "Hidden",
                    value = tostring(hidden)
                }
            }

            lia.util.createTableUI({
                title = "Door" .. " " .. "Information",
                columns = {
                    {
                        name = "Property",
                        field = "property"
                    },
                    {
                        name = "Value",
                        field = "value"
                    }
                },
                data = infoData,
            }, client)
        else
            client:notifyError(string.format("You are not looking at a valid door."))
        end
    end
})

lia.command.add("doorsampledata", {
    desc = "Add sample information to a door using common door variables.",
    adminOnly = true,
    AdminStick = {
        Name = "Add Sample Data",
        ButtonText = "Copy Door Settings",
        Category = "Door Maintenance",
        TargetClass = "door",
    },
    onRun = function(client, arguments)
        local door = resolveDoorCommandTarget(client, arguments, 0)
        if door then
            local doorData = lia.doors.getData(door)
            local sampleData = {
                name = string.format("Sample Door %s", door:MapCreationID() or "Unknown"),
                price = 1000,
                locked = false,
                disabled = false,
                hidden = false,
                noSell = false,
                factions = {"citizen"},
                classes = {"citizen"}
            }

            for key, value in pairs(sampleData) do
                doorData[key] = value
            end

            lia.doors.setData(door, doorData)
            client:notify(string.format("Door sample data applied successfully!"))
        else
            client:notifyError(string.format("You are not looking at a valid door."))
        end
    end
})

local randomDoorPrefixes = {"North", "South", "East", "West", "Upper", "Lower", "Grand", "Old", "Prime", "Quiet"}
local randomDoorPlaces = {"Office", "Suite", "Storage", "Lobby", "Workshop", "Checkpoint", "Garage", "Apartment", "Archive", "Lab"}
local function getRandomDoorRestrictionData()
    local restrictionType = math.random(1, 4)
    local data = {
        factions = {},
        classes = {},
        noSell = false
    }

    if restrictionType == 1 then return data end
    if restrictionType == 4 then
        data.noSell = true
        return data
    end

    if restrictionType == 2 then
        local factions = {}
        for _, faction in pairs(lia.faction.indices or {}) do
            if faction and faction.uniqueID and faction.uniqueID ~= "staff" then factions[#factions + 1] = faction.uniqueID end
        end

        if #factions > 0 then
            data.factions = {factions[math.random(#factions)]}
            data.noSell = true
            return data
        end
    end

    local classes = {}
    for _, classData in pairs(lia.class.list or {}) do
        if classData and classData.uniqueID then classes[#classes + 1] = classData.uniqueID end
    end

    if #classes > 0 then
        data.classes = {classes[math.random(#classes)]}
        data.noSell = true
    end
    return data
end

lia.command.add("doorrandominfo", {
    desc = "Apply randomized information to the door you are looking at.",
    adminOnly = true,
    AdminStick = {
        Name = "Randomize Door Info",
        ButtonText = "Randomize Door Info",
        Category = "Door Maintenance",
        TargetClass = "door",
    },
    onRun = function(client, arguments)
        local door = resolveDoorCommandTarget(client, arguments, 0)
        if not door then return end
        local doorData = lia.doors.getData(door)
        local restrictionData = getRandomDoorRestrictionData()
        doorData.name = string.format("%s %s %d", randomDoorPrefixes[math.random(#randomDoorPrefixes)], randomDoorPlaces[math.random(#randomDoorPlaces)], math.random(1, 99))
        doorData.price = math.random(0, 5000)
        doorData.hidden = math.random() > 0.7
        doorData.disabled = math.random() > 0.85
        doorData.noSell = restrictionData.noSell
        doorData.factions = restrictionData.factions
        doorData.classes = restrictionData.classes
        doorData.useCount = math.random(0, 250)
        doorData.lastUsed = os.time() - math.random(0, 86400)
        door.liaFactions = not table.IsEmpty(restrictionData.factions) and restrictionData.factions or nil
        door.liaClasses = not table.IsEmpty(restrictionData.classes) and restrictionData.classes or nil
        lia.doors.setData(door, doorData)
        lia.module.get("doors"):SaveData()
        client:notifySuccess("Random door information applied.")
    end
})

lia.command.add("dooraddfaction", {
    desc = "Add a faction restriction to a door, allowing only specific factions to access it.",
    arguments = {
        {
            name = "Faction",
            type = "string"
        }
    },
    adminOnly = true,
    onRun = function(client, arguments)
        local door, argumentIndex = resolveDoorCommandTarget(client, arguments, 1)
        if door then
            local doorData = lia.doors.getData(door)
            if not doorData.disabled then
                local input = arguments[argumentIndex]
                local faction
                if input then
                    local factionIndex = tonumber(input)
                    if factionIndex then
                        faction = lia.faction.indices[factionIndex]
                        if not faction then
                            client:notifyError(string.format("The specified faction is not valid."))
                            return
                        end
                    else
                        for k, v in pairs(lia.faction.teams) do
                            if lia.util.stringMatches(k, input) or lia.util.stringMatches(v.name, input) then
                                faction = v
                                break
                            end
                        end
                    end
                end

                if faction then
                    local facs = doorData.factions or {}
                    if not table.HasValue(facs, faction.uniqueID) then facs[#facs + 1] = faction.uniqueID end
                    doorData.factions = facs
                    door.liaFactions = facs
                    doorData.noSell = true
                    lia.doors.setData(door, doorData)
                    client:notifySuccess(string.format("This door now belongs to the '%s' faction.", faction.name))
                elseif arguments[argumentIndex] then
                    client:notifyError(string.format("The specified faction is not valid."))
                else
                    doorData.factions = {}
                    door.liaFactions = nil
                    lia.doors.setData(door, doorData)
                    client:notifySuccess(string.format("This door no longer belongs to any faction."))
                end

                lia.module.get("doors"):SaveData()
            else
                client:notifyError(string.format("You are not looking at a valid door."))
            end
        else
            client:notifyError(string.format("You are not looking at a valid door."))
        end
    end
})

lia.command.add("doorremovefaction", {
    desc = "Remove a faction restriction from a door, or clear all restrictions.",
    arguments = {
        {
            name = "Faction",
            type = "string"
        }
    },
    adminOnly = true,
    onRun = function(client, arguments)
        local door, argumentIndex = resolveDoorCommandTarget(client, arguments, 1)
        if door then
            local doorData = lia.doors.getData(door)
            if not doorData.disabled then
                local input = arguments[argumentIndex]
                local faction
                if input then
                    local factionIndex = tonumber(input)
                    if factionIndex then
                        faction = lia.faction.indices[factionIndex]
                        if not faction then
                            client:notifyError(string.format("The specified faction is not valid."))
                            return
                        end
                    else
                        for k, v in pairs(lia.faction.teams) do
                            if lia.util.stringMatches(k, input) or lia.util.stringMatches(v.name, input) then
                                faction = v
                                break
                            end
                        end
                    end
                end

                if faction then
                    local facs = doorData.factions or {}
                    table.RemoveByValue(facs, faction.uniqueID)
                    doorData.factions = facs
                    door.liaFactions = facs
                    lia.doors.setData(door, doorData)
                    client:notifySuccess(string.format("This door no longer belongs to the '%s' faction.", faction.name))
                elseif arguments[argumentIndex] then
                    client:notifyError(string.format("The specified faction is not valid."))
                else
                    doorData.factions = {}
                    door.liaFactions = nil
                    lia.doors.setData(door, doorData)
                    client:notifySuccess(string.format("This door no longer belongs to any faction."))
                end

                lia.module.get("doors"):SaveData()
            else
                client:notifyError(string.format("You are not looking at a valid door."))
            end
        else
            client:notifyError(string.format("You are not looking at a valid door."))
        end
    end
})

lia.command.add("doorsetclass", {
    desc = "Set a class (job) restriction for a door.",
    arguments = {
        {
            name = "Class",
            type = "string"
        }
    },
    adminOnly = true,
    onRun = function(client, arguments)
        local door, argumentIndex = resolveDoorCommandTarget(client, arguments, 1)
        if door then
            local doorData = lia.doors.getData(door)
            if not doorData.disabled then
                local input = arguments[argumentIndex]
                local class, classData
                if input then
                    local classIndex = tonumber(input)
                    if classIndex then
                        classData = lia.class.list[classIndex]
                        if classData then
                            class = classIndex
                        else
                            client:notifyError(string.format("The specified class is not valid."))
                            return
                        end
                    else
                        local id = lia.class.retrieveClass(input)
                        if id then
                            class, classData = id, lia.class.list[id]
                        else
                            for k, v in pairs(lia.class.list) do
                                if lia.util.stringMatches(v.name, input) or lia.util.stringMatches(v.uniqueID, input) then
                                    class, classData = k, v
                                    break
                                end
                            end
                        end
                    end
                end

                if class then
                    local classes = doorData.classes or {}
                    if not table.HasValue(classes, classData.uniqueID) then classes[#classes + 1] = classData.uniqueID end
                    doorData.classes = classes
                    door.liaClasses = classes
                    doorData.noSell = true
                    lia.doors.setData(door, doorData)
                    client:notifySuccess(string.format("This door now belongs to the '%s' class.", classData.name))
                elseif arguments[argumentIndex] then
                    client:notifyError(string.format("The specified class is not valid."))
                else
                    doorData.classes = {}
                    door.liaClasses = nil
                    lia.doors.setData(door, doorData)
                    client:notifySuccess(string.format("This door no longer belongs to any class."))
                end

                lia.module.get("doors"):SaveData()
            else
                client:notifyError(string.format("You are not looking at a valid door."))
            end
        else
            client:notifyError(string.format("You are not looking at a valid door."))
        end
    end,
    alias = {"jobdoor"}
})

lia.command.add("doorremoveclass", {
    desc = "Remove a class (job) restriction from a door.",
    arguments = {
        {
            name = "Class",
            type = "string"
        }
    },
    adminOnly = true,
    onRun = function(client, arguments)
        local door, argumentIndex = resolveDoorCommandTarget(client, arguments, 1)
        if door then
            local doorData = lia.doors.getData(door)
            if not doorData.disabled then
                local input = arguments[argumentIndex]
                local class, classData
                if input then
                    local classIndex = tonumber(input)
                    if classIndex then
                        classData = lia.class.list[classIndex]
                        if classData then
                            class = classIndex
                        else
                            client:notifyError(string.format("The specified class is not valid."))
                            return
                        end
                    else
                        local id = lia.class.retrieveClass(input)
                        if id then
                            class, classData = id, lia.class.list[id]
                        else
                            for k, v in pairs(lia.class.list) do
                                if lia.util.stringMatches(v.name, input) or lia.util.stringMatches(v.uniqueID, input) then
                                    class, classData = k, v
                                    break
                                end
                            end
                        end
                    end
                end

                if class then
                    local classes = doorData.classes or {}
                    if table.HasValue(classes, classData.uniqueID) then
                        table.RemoveByValue(classes, classData.uniqueID)
                        doorData.classes = classes
                        door.liaClasses = classes
                        lia.doors.setData(door, doorData)
                        client:notifySuccess(string.format("The '%s' class has been removed from this door.", classData.name))
                    else
                        client:notifyError(string.format("The '%s' class is not assigned to this door.", classData.name))
                    end
                elseif arguments[argumentIndex] then
                    client:notifyError(string.format("The specified class is not valid."))
                else
                    doorData.classes = {}
                    door.liaClasses = nil
                    lia.doors.setData(door, doorData)
                    client:notifySuccess(string.format("This door no longer belongs to any class."))
                end

                lia.module.get("doors"):SaveData()
            else
                client:notifyError(string.format("You are not looking at a valid door."))
            end
        else
            client:notifyError(string.format("You are not looking at a valid door."))
        end
    end
})

local function cloneDoorRestrictionList(values)
    local cloned = {}
    for index, value in ipairs(values or {}) do
        cloned[index] = value
    end
    return cloned
end

lia.command.add("doorcopyfactions", {
    adminOnly = true,
    onRun = function(client, arguments)
        local door = resolveDoorCommandTarget(client, arguments, 0)
        if not door then return end
        local doorData = lia.doors.getData(door)
        if doorData.disabled then
            client:notifyError(string.format("You are not looking at a valid door."))
            return
        end

        client.liaCopiedDoorFactions = {
            hasData = true,
            values = cloneDoorRestrictionList(doorData.factions)
        }

        client:notifySuccess(string.format("Copied %s faction restriction(s) from this door.", #(client.liaCopiedDoorFactions.values or {})))
    end
})

lia.command.add("doorpastefactions", {
    adminOnly = true,
    onRun = function(client, arguments)
        local door = resolveDoorCommandTarget(client, arguments, 0)
        if not door then return end
        local doorData = lia.doors.getData(door)
        if doorData.disabled then
            client:notifyError(string.format("You are not looking at a valid door."))
            return
        end

        local copiedData = client.liaCopiedDoorFactions
        if not copiedData or not copiedData.hasData then
            client:notifyError(string.format("You have no copied door faction restrictions to paste."))
            return
        end

        local factions = cloneDoorRestrictionList(copiedData.values)
        doorData.factions = factions
        door.liaFactions = #factions > 0 and factions or nil
        if #factions > 0 then doorData.noSell = true end
        lia.doors.setData(door, doorData)
        lia.module.get("doors"):SaveData()
        client:notifySuccess(string.format("Pasted %s faction restriction(s) onto this door.", #factions))
    end
})

lia.command.add("doorcopyclasses", {
    adminOnly = true,
    onRun = function(client, arguments)
        local door = resolveDoorCommandTarget(client, arguments, 0)
        if not door then return end
        local doorData = lia.doors.getData(door)
        if doorData.disabled then
            client:notifyError(string.format("You are not looking at a valid door."))
            return
        end

        client.liaCopiedDoorClasses = {
            hasData = true,
            values = cloneDoorRestrictionList(doorData.classes)
        }

        client:notifySuccess(string.format("Copied %s class restriction(s) from this door.", #(client.liaCopiedDoorClasses.values or {})))
    end
})

lia.command.add("doorpasteclasses", {
    adminOnly = true,
    onRun = function(client, arguments)
        local door = resolveDoorCommandTarget(client, arguments, 0)
        if not door then return end
        local doorData = lia.doors.getData(door)
        if doorData.disabled then
            client:notifyError(string.format("You are not looking at a valid door."))
            return
        end

        local copiedData = client.liaCopiedDoorClasses
        if not copiedData or not copiedData.hasData then
            client:notifyError(string.format("You have no copied door class restrictions to paste."))
            return
        end

        local classes = cloneDoorRestrictionList(copiedData.values)
        doorData.classes = classes
        door.liaClasses = #classes > 0 and classes or nil
        if #classes > 0 then doorData.noSell = true end
        lia.doors.setData(door, doorData)
        lia.module.get("doors"):SaveData()
        client:notifySuccess(string.format("Pasted %s class restriction(s) onto this door.", #classes))
    end
})

lia.command.add("togglealldoors", {
    desc = "Toggle the enabled state for all doors in the map.",
    adminOnly = true,
    onRun = function(client)
        local toggleToDisable = false
        for _, door in ents.Iterator() do
            if IsValid(door) and door:isDoor() then
                local doorData = lia.doors.getData(door)
                toggleToDisable = not (doorData.disabled or false)
                break
            end
        end

        local count = 0
        for _, door in ents.Iterator() do
            if IsValid(door) and door:isDoor() then
                local doorData = lia.doors.getData(door)
                if (doorData.disabled or false) ~= toggleToDisable then
                    doorData.disabled = toggleToDisable and true or nil
                    lia.doors.setData(door, doorData)
                    count = count + 1
                end
            end
        end

        client:notifySuccess(string.format(toggleToDisable and "Disabled all doors (%d doors)" or "Enabled all doors (%d doors)", count))
        lia.module.get("doors"):SaveData()
    end
})

lia.command.add("doorid", {
    desc = "Set the door ID for identification purposes.",
    adminOnly = true,
    onRun = function(client, arguments)
        local door = resolveDoorCommandTarget(client, arguments, 0)
        if door then
            local mapID = door:MapCreationID()
            if mapID and mapID > 0 then
                local pos = door:GetPos()
                client:notifyInfo(string.format("Door ID" .. " " .. mapID .. " | " .. "Position(" .. "): " .. string.format("%.0f, %.0f, %.0f", pos.x, pos.y, pos.z)))
            else
                client:notifyError(string.format("No valid map ID found for this door."))
            end
        else
            client:notifyError(string.format("You must be looking at a door."))
        end
    end
})

lia.command.add("listdoorids", {
    desc = "List every door on the current map with its map ID, position, and model.",
    adminOnly = true,
    onRun = function(client)
        local doorData = {}
        for _, door in ents.Iterator() do
            if IsValid(door) and door:isDoor() then
                local mapID = door:MapCreationID()
                if mapID and mapID > 0 then
                    local pos = door:GetPos()
                    table.insert(doorData, {
                        id = mapID,
                        position = string.format("%.0f, %.0f, %.0f", pos.x, pos.y, pos.z),
                        model = door:GetModel() or "Unknown"
                    })
                end
            end
        end

        if #doorData == 0 then
            client:notifyInfo(string.format("No doors found."))
            return
        end

        table.sort(doorData, function(a, b) return a.id < b.id end)
        local doorList = {}
        for _, data in ipairs(doorData) do
            table.insert(doorList, {
                property = "Door ID" .. data.id,
                value = "Position(" .. "): " .. data.position .. "Model Label" .. data.model
            })
        end

        lia.util.createTableUI({
            title = string.format("Door IDs on map %s", game.GetMap()),
            columns = {
                {
                    name = "Door ID",
                    field = "property"
                },
                {
                    name = "Details Column",
                    field = "value"
                }
            },
            data = doorList,
        }, client)
    end
})

lia.command.add("plytransfer", {
    adminOnly = true,
    desc = "Transfers the specified player to a new faction.",
    alias = {"charsetfaction"},
    arguments = {
        {
            name = "Name",
            type = "player"
        },
        {
            name = "Faction",
            type = "table",
            options = function()
                local options = {}
                for k, v in pairs(lia.faction.teams) do
                    if k ~= "staff" then options[v.name] = k end
                end
                return options
            end
        }
    },
    onRun = function(client, arguments)
        local targetPlayer
        local factionArgIndex = 2
        if istable(arguments) and #arguments >= 2 then
            local lastArg = arguments[#arguments]
            local assumedFaction = lia.faction.teams[lastArg]
            if not assumedFaction then
                local factionIndex = tonumber(lastArg)
                if factionIndex then assumedFaction = lia.faction.indices[factionIndex] end
            end

            if assumedFaction then
                local assumedName = table.concat(arguments, " ", 1, #arguments - 1)
                local assumedTarget = lia.util.findPlayer(client, assumedName)
                if assumedTarget and IsValid(assumedTarget) then
                    targetPlayer = assumedTarget
                    factionArgIndex = #arguments
                end
            end
        end

        targetPlayer = targetPlayer or lia.util.findPlayer(client, arguments[1])
        if (not targetPlayer or not IsValid(targetPlayer)) and arguments[2] then
            local combined = tostring(arguments[1]) .. " " .. tostring(arguments[2])
            local combinedTarget = lia.util.findPlayer(client, combined)
            if combinedTarget and IsValid(combinedTarget) then
                targetPlayer = combinedTarget
                factionArgIndex = 3
            end
        end

        if (not targetPlayer or not IsValid(targetPlayer)) and arguments[3] then
            local combined = tostring(arguments[1]) .. " " .. tostring(arguments[2]) .. " " .. tostring(arguments[3])
            local combinedTarget = lia.util.findPlayer(client, combined)
            if combinedTarget and IsValid(combinedTarget) then
                targetPlayer = combinedTarget
                factionArgIndex = 4
            end
        end

        if not targetPlayer or not IsValid(targetPlayer) then
            client:notifyError(string.format("Target not found"))
            return
        end

        local factionName = arguments[factionArgIndex]
        local faction = lia.faction.teams[factionName]
        if not faction then
            local factionIndex = tonumber(factionName)
            if factionIndex then faction = lia.faction.indices[factionIndex] end
        end

        if not faction then
            faction = lia.util.findFaction(client, tostring(factionName))
            if not faction then return end
        end

        if faction.uniqueID == "staff" then
            client:notifyError(string.format("You cannot transfer a player to the staff faction through commands. Staff characters must be created through the menu system."))
            return
        end

        local targetChar = targetPlayer:getChar()
        if hook.Run("CanCharBeTransfered", targetChar, faction, targetPlayer:Team()) == false then return end
        local oldFaction = targetChar:getFaction()
        hook.Run("TrackFactionTransfer", targetChar, oldFaction, faction, client, "commandTransfer")
        targetChar.vars.faction = faction.uniqueID
        targetChar:setFaction(faction.index)
        hook.Run("OnTransferred", targetPlayer)
        if faction.OnTransferred then faction:OnTransferred(targetPlayer, oldFaction) end
        client:notifySuccess(string.format("%s has been transferred to %s.", targetPlayer:Name(), faction.name))
        if client ~= targetPlayer then targetPlayer:notifyInfo(string.format("You have been transferred to %s by %s.", faction.name, client:Name())) end
    end
})

lia.command.add("plywhitelist", {
    adminOnly = true,
    desc = "Adds the specified player to a faction whitelist.",
    alias = {"factionwhitelist"},
    arguments = {
        {
            name = "Name",
            type = "player"
        },
        {
            name = "Faction",
            type = "table",
            options = function()
                local options = {}
                for k, v in pairs(lia.faction.teams) do
                    if k ~= "staff" then options[v.name] = k end
                end
                return options
            end
        }
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyError(string.format("Target not found"))
            return
        end

        local faction = lia.util.findFaction(client, arguments[2])
        if not faction then
            client:notifyError(string.format("The specified faction is not valid."))
            return
        end

        if faction.uniqueID == "staff" then
            client:notifyError(string.format("You cannot whitelist a player to the staff faction through commands. Staff characters must be created through the menu system."))
            return
        end

        local data = lia.faction.indices[faction.index]
        if data then
            if data.uniqueID == "staff" then return end
            local whitelists = target:getLiliaData("whitelists", {})
            whitelists[SCHEMA.folder] = whitelists[SCHEMA.folder] or {}
            whitelists[SCHEMA.folder][data.uniqueID] = true
            target:setLiliaData("whitelists", whitelists)
            for _, v in player.Iterator() do
                v:notifyInfo(string.format("%s has whitelisted %s for the %s faction.", client:Name(), target:Name(), faction.name))
            end
        end
    end
})

lia.command.add("plyunwhitelist", {
    adminOnly = true,
    desc = "Removes the specified player from a faction whitelist.",
    alias = {"factionunwhitelist"},
    arguments = {
        {
            name = "Name",
            type = "player"
        },
        {
            name = "Faction",
            type = "table",
            options = function()
                local options = {}
                for k, v in pairs(lia.faction.teams) do
                    if k ~= "staff" then options[v.name] = k end
                end
                return options
            end
        }
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyError(string.format("Target not found"))
            return
        end

        local faction = lia.util.findFaction(client, arguments[2])
        if not faction then
            client:notifyError(string.format("The specified faction is not valid."))
            return
        end

        if faction.uniqueID == "staff" then
            client:notifyError(string.format("You cannot unwhitelist a player from the staff faction through commands. Staff character management must be done through the menu system."))
            return
        end

        if faction and not faction.isDefault then
            local data = lia.faction.indices[faction.index]
            if data then
                if data.uniqueID == "staff" then return end
                local whitelists = target:getLiliaData("whitelists", {})
                whitelists[SCHEMA.folder] = whitelists[SCHEMA.folder] or {}
                whitelists[SCHEMA.folder][data.uniqueID] = nil
                target:setLiliaData("whitelists", whitelists)
                for _, v in player.Iterator() do
                    v:notifyInfo(string.format("%s has unwhitelisted %s from the %s faction.", client:Name(), target:Name(), faction.name))
                end
            end
        else
            client:notifyError(string.format("The specified faction is not valid."))
        end
    end
})

lia.command.add("beclass", {
    adminOnly = false,
    desc = "Changes your current class to the specified class.",
    arguments = {
        {
            name = "Class",
            type = "table",
            options = function()
                local options = {}
                for _, v in pairs(lia.class.list) do
                    options[v.name] = v.uniqueID
                end
                return options
            end
        },
        {
            name = "Model",
            type = "string",
            optional = true
        }
    },
    onRun = function(client, arguments)
        local className = arguments[1]
        local requestedModel = arguments[2]
        local character = client:getChar()
        if not IsValid(client) or not character then
            client:notifyError(string.format("You are not whitelisted for this faction."))
            return
        end

        local classID = tonumber(className) or lia.class.retrieveClass(className)
        local classData = lia.class.get(classID)
        if not classData then
            client:notifyError(string.format("The specified class is not valid."))
            return
        end

        local classModels = classData.model or classData.models
        local currentClass = character:getClass()
        local isSameClass = currentClass == classID
        local function applyRequestedClassModel()
            if not istable(classModels) then
                character:setData("classModel", nil)
                return false
            end

            if not isstring(requestedModel) or requestedModel == "" then return false end
            local function gatherModels(mdl, out)
                if isstring(mdl) and mdl ~= "" then
                    out[#out + 1] = mdl
                elseif istable(mdl) then
                    for _, v in pairs(mdl) do
                        gatherModels(v, out)
                    end
                end
            end

            local validModels = {}
            gatherModels(classModels, validModels)
            local ok = false
            for _, v in ipairs(validModels) do
                if v == requestedModel then
                    ok = true
                    break
                end
            end

            if not ok then return false end
            if util and util.IsValidModel and not util.IsValidModel(requestedModel) then return false end
            character:setData("classModel", requestedModel)
            return true
        end

        if isSameClass then
            if applyRequestedClassModel() then client:notify(string.format("Model updated. Will apply on respawn.")) end
            return
        end

        if lia.class.canBe(client, classID) then
            if character:joinClass(classID) then
                if not istable(classModels) then character:setData("classModel", nil) end
                applyRequestedClassModel()
                client:notifySuccess(string.format("You have become %s.", classData.name))
            else
                client:notifyError(string.format("Failed to become %s.", classData.name))
            end
        else
            client:notifyError(string.format("The specified class is not valid."))
        end
    end
})

lia.command.add("setclass", {
    adminOnly = true,
    desc = "Sets the specified player's class.",
    arguments = {
        {
            name = "Name",
            type = "player"
        },
        {
            name = "Class",
            type = "table",
            options = function(client, prefix)
                local options = {}
                local targetName = prefix and prefix[1]
                local target = targetName and lia.util.findPlayer(client, targetName)
                if not target or not target:getChar() then return options end
                local targetFaction = target:Team()
                local factionClasses = lia.faction.getClasses(targetFaction)
                if not factionClasses or #factionClasses == 0 then return options end
                for _, v in pairs(factionClasses) do
                    local canAccess = true
                    if lia.class.hasWhitelist(v.index) then canAccess = target:getChar():getClasswhitelists()[v.index] end
                    if canAccess and target:getChar():getClass() ~= v.uniqueID then options[v.name] = v.uniqueID end
                end
                return options
            end
        }
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyError(string.format("Target not found"))
            return
        end

        if not target:getChar() then
            client:notifyError(string.format("Invalid Target!"))
            return
        end

        if not lia.class.list or table.IsEmpty(lia.class.list) then
            client:notifyError(string.format("No classes are currently available."))
            return
        end

        local targetFaction = target:Team()
        local factionClasses = lia.faction.getClasses(targetFaction)
        if not factionClasses or #factionClasses == 0 then
            client:notifyError(string.format("The target player's faction does not have any classes."))
            return
        end

        local className = arguments[2]
        local classID = lia.class.retrieveClass(className)
        local classData = lia.class.list[classID]
        if classData then
            if target:Team() == classData.faction then
                target:getChar():joinClass(classID, true)
                target:notifyInfo(string.format("Your class was set to %s%s.", classData.name))
                if client ~= target then client:notifySuccess(string.format("You set %s class to %s.", target:GetName(), classData.name)) end
                hook.Run("PlayerLoadout", target)
            else
                client:notifyError(string.format("The class does not match the target's faction!"))
            end
        else
            client:notifyError(string.format("The specified class is not valid."))
        end
    end
})

lia.command.add("classwhitelist", {
    adminOnly = true,
    desc = "Grants the specified player whitelist access to a class.",
    arguments = {
        {
            name = "Name",
            type = "player"
        },
        {
            name = "Class",
            type = "table",
            options = function()
                local options = {}
                for _, v in pairs(lia.class.list) do
                    options[v.name] = v.uniqueID
                end
                return options
            end
        }
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        local classID = lia.class.retrieveClass(arguments[2])
        if not target or not IsValid(target) then
            client:notifyError(string.format("Target not found"))
            return
        elseif not classID then
            client:notifyError(string.format("The specified class is not valid."))
            return
        end

        local classData = lia.class.list[classID]
        if target:Team() ~= classData.faction then
            client:notifyError(string.format("You cannot whitelist a class outside the faction."))
        elseif target:getChar():getClasswhitelists()[classID] then
            client:notifyInfo(string.format("This player is already whitelisted."))
        else
            local wl = target:getChar():getClasswhitelists()
            wl[classID] = true
            target:getChar():setClasswhitelists(wl)
            client:notifySuccess(string.format("Successfully whitelisted the player."))
            target:notifyInfo(string.format("Class '%s' has been assigned to your current character.", classData.name))
        end
    end
})

lia.command.add("classunwhitelist", {
    adminOnly = true,
    desc = "Revokes the specified player's whitelist access to a class.",
    arguments = {
        {
            name = "Name",
            type = "player"
        },
        {
            name = "Class",
            type = "table",
            options = function()
                local options = {}
                for _, v in pairs(lia.class.list) do
                    options[v.name] = v.uniqueID
                end
                return options
            end
        }
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        local classID = lia.class.retrieveClass(arguments[2])
        if not target or not IsValid(target) then
            client:notifyError(string.format("Target not found"))
            return
        elseif not classID then
            client:notifyError(string.format("The specified class is not valid."))
            return
        end

        local classData = lia.class.list[classID]
        if target:Team() ~= classData.faction then
            client:notifyError(string.format("You cannot whitelist a class outside the faction."))
        elseif not target:getChar():getClasswhitelists()[classID] then
            client:notifyInfo(string.format("This player is not whitelisted."))
        else
            local wl = target:getChar():getClasswhitelists()
            wl[classID] = nil
            target:getChar():setClasswhitelists(wl)
            client:notifySuccess(string.format("Successfully removed the player's whitelist."))
            target:notifyInfo(string.format("Class '%s' has been removed from your character.", classData.name))
        end
    end
})

lia.command.add("spawnadd", {
    adminOnly = true,
    desc = "Adds a spawn point at your current position for the specified faction.",
    arguments = {
        {
            name = "Faction",
            type = "table",
            options = function()
                local options = {}
                for k, v in pairs(lia.faction.teams) do
                    options[k] = tostring(v.name)
                end
                return options
            end
        },
        {
            name = "radius",
            type = "string",
            optional = true
        }
    },
    onRun = function(client, arguments)
        local factionName = arguments[1]
        if not factionName then
            client:notifyError(string.format("Invalid argument."))
            return
        end

        local factionInfo = lia.faction.teams[factionName] or lia.util.findFaction(client, factionName)
        if factionInfo then
            lia.module.get("spawns"):FetchSpawns():next(function(spawns)
                spawns[factionInfo.uniqueID] = spawns[factionInfo.uniqueID] or {}
                local newSpawn = {
                    pos = client:GetPos(),
                    ang = client:EyeAngles(),
                    map = game.GetMap(),
                    radius = math.Clamp(tonumber(arguments[2]) or 0, 0, 2048)
                }

                table.insert(spawns[factionInfo.uniqueID], newSpawn)
                lia.module.get("spawns"):StoreSpawns(spawns):next(function() client:notifySuccess(string.format("Sucessfully Added Point")) end)
            end)
        else
            client:notifyError(string.format("The specified faction is not valid."))
        end
    end
})

lia.command.add("spawnremoveinradius", {
    adminOnly = true,
    desc = "Removes all spawn points within the given radius of your position (default 120).",
    arguments = {
        {
            name = "radius",
            type = "string",
            optional = true
        },
    },
    onRun = function(client, arguments)
        local position = client:GetPos()
        local radius = tonumber(arguments[1]) or 120
        lia.module.get("spawns"):FetchSpawns():next(function(spawns)
            local removedCount = 0
            local curMap = game.GetMap():lower()
            for faction, list in pairs(spawns) do
                for i = #list, 1, -1 do
                    local data = list[i]
                    if not (data.map and data.map:lower() ~= curMap) then
                        local spawn = data.pos or data
                        if not isvector(spawn) then spawn = lia.data.decodeVector(spawn) end
                        if isvector(spawn) and spawn:Distance(position) <= radius then
                            table.remove(list, i)
                            removedCount = removedCount + 1
                        end
                    end
                end

                if #list == 0 then spawns[faction] = nil end
            end

            if removedCount > 0 then
                lia.module.get("spawns"):StoreSpawns(spawns):next(function() client:notifySuccess(string.format("Sucessfully Removed Points")) end)
            else
                client:notifySuccess(string.format("Sucessfully Removed Points"))
            end
        end)
    end
})

lia.command.add("spawnremovebyname", {
    adminOnly = true,
    desc = "Removes all spawn points for the specified faction.",
    arguments = {
        {
            name = "Faction",
            type = "table",
            options = function()
                local options = {}
                for k, v in pairs(lia.faction.teams) do
                    options[k] = tostring(v.name)
                end
                return options
            end
        }
    },
    onRun = function(client, arguments)
        local factionName = arguments[1]
        local factionInfo = factionName and (lia.faction.teams[factionName] or lia.util.findFaction(client, factionName))
        if factionInfo then
            lia.module.get("spawns"):FetchSpawns():next(function(spawns)
                local list = spawns[factionInfo.uniqueID]
                if list then
                    local curMap = game.GetMap():lower()
                    local removedCount = 0
                    for i = #list, 1, -1 do
                        local data = list[i]
                        if not (data.map and data.map:lower() ~= curMap) then
                            table.remove(list, i)
                            removedCount = removedCount + 1
                        end
                    end

                    if removedCount > 0 then
                        if #list == 0 then spawns[factionInfo.uniqueID] = nil end
                        lia.module.get("spawns"):StoreSpawns(spawns):next(function() client:notifySuccess(string.format("Sucessfully Removed Points")) end)
                    else
                        client:notifyInfo(string.format("No spawn points exist for this faction."))
                    end
                else
                    client:notifyInfo(string.format("No spawn points exist for this faction."))
                end
            end)
        else
            client:notifyError(string.format("The specified faction is not valid."))
        end
    end
})

lia.command.add("returnitems", {
    superAdminOnly = true,
    desc = "Returns items lost on death to the specified player, if any.",
    arguments = {
        {
            name = "Name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "Return Items",
        ButtonText = "Return Lost Items",
        Category = "Inventory",
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyError(string.format("Target not found"))
            return
        end

        if lia.config.get("LoseItemsonDeathHuman", false) or lia.config.get("LoseItemsonDeathNPC", false) then
            if not target.LostItems or table.IsEmpty(target.LostItems) then
                client:notifyInfo(string.format("The target hasn't lost any items or they've already been returned."))
                return
            end

            local character = target:getChar()
            if not character then return end
            local inv = character:getInv()
            if not inv then return end
            for _, item in pairs(target.LostItems) do
                inv:add(lia.item.new(item.name, item.id))
            end

            target.LostItems = nil
            target:notifySuccess(string.format("Your items have been returned."))
            client:notifySuccess(string.format("Returned the items."))
        else
            client:notifyInfo(string.format("Item loss on death is not enabled!"))
        end
    end
})

lia.command.add("returnallitems", {
    superAdminOnly = true,
    desc = "Returns items lost on death to all players who have lost items.",
    AdminStick = {
        Name = "Return All Items",
        ButtonText = "Return All Lost Items",
        Category = "Inventory",
    },
    onRun = function(client)
        if not lia.config.get("LoseItemsonDeathHuman", false) and not lia.config.get("LoseItemsonDeathNPC", false) then
            client:notifyInfo(string.format("Item loss on death is not enabled!"))
            return
        end

        local returnedCount = 0
        local totalItems = 0
        for _, target in player.Iterator() do
            if not target.LostItems or table.IsEmpty(target.LostItems) then continue end
            local character = target:getChar()
            if not character then continue end
            local inv = character:getInv()
            if not inv then continue end
            local playerItemCount = 0
            for _, item in pairs(target.LostItems) do
                inv:add(lia.item.new(item.name, item.id))
                playerItemCount = playerItemCount + 1
            end

            target.LostItems = nil
            target:notifySuccess(string.format("Your items have been returned."))
            returnedCount = returnedCount + 1
            totalItems = totalItems + playerItemCount
        end

        if returnedCount > 0 then
            client:notifySuccess(string.format("Returned items to %d players (%d total items).", returnedCount, totalItems))
        else
            client:notifyInfo(string.format("No players have lost items to return."))
        end
    end
})

local function GetTicketsByRequester(steamID)
    local condition = "requesterSteamID = " .. lia.db.convertDataType(steamID)
    return lia.db.select({"timestamp", "requester", "requesterSteamID", "admin", "adminSteamID", "message"}, "ticketclaims", condition):next(function(res)
        local tickets = {}
        for _, row in ipairs(res.results or {}) do
            tickets[#tickets + 1] = {
                timestamp = isnumber(row.timestamp) and row.timestamp or os.time(lia.time.toNumber(row.timestamp)),
                requester = row.requester,
                requesterSteamID = row.requesterSteamID,
                admin = row.admin,
                adminSteamID = row.adminSteamID,
                message = row.message
            }
        end
        return tickets
    end)
end

lia.command.add("viewtickets", {
    adminOnly = true,
    desc = "Displays all tickets requested by the specified player.",
    arguments = {
        {
            name = "Name",
            type = "player"
        },
    },
    onRun = function(client, arguments)
        local targetName = arguments[1]
        if not targetName then
            client:notifyError(string.format("Please specify a player."))
            return
        end

        local target = lia.util.findPlayer(client, targetName)
        local steamID, displayName
        if IsValid(target) then
            steamID = target:SteamID()
            displayName = target:Nick()
        else
            steamID = targetName
            displayName = targetName
        end

        GetTicketsByRequester(steamID):next(function(tickets)
            if #tickets == 0 then
                client:notifyInfo(string.format("No tickets found for the specified player."))
                return
            end

            local ticketsData = {}
            for _, ticket in ipairs(tickets) do
                ticketsData[#ticketsData + 1] = {
                    timestamp = os.date("%Y-%m-%d %H:%M:%S", ticket.timestamp),
                    admin = string.format("%s (%s)", ticket.admin or "N/A", ticket.adminSteamID or "N/A"),
                    message = ticket.message or ""
                }
            end

            lia.util.createTableUI({
                title = string.format("Tickets for %s", displayName),
                columns = {
                    {
                        name = "Timestamp",
                        field = "timestamp"
                    },
                    {
                        name = "Admin",
                        field = "admin"
                    },
                    {
                        name = "Message",
                        field = "message"
                    }
                },
                data = ticketsData,
            }, client)
        end)
    end
})

lia.command.add("plyviewclaims", {
    adminOnly = true,
    desc = "Displays detailed claim information for the specified player.",
    arguments = {
        {
            name = "Name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "View Ticket Claims",
        ButtonText = "View Ticket Claims",
        Category = "Tickets",
    },
    onRun = function(client, arguments)
        local targetName = arguments[1]
        if not targetName then
            client:notifyError(string.format("Please specify a player."))
            return
        end

        local target = lia.util.findPlayer(client, targetName)
        if not target or not IsValid(target) then
            client:notifyError(string.format("Target not found"))
            return
        end

        local steamID = target:SteamID()
        lia.module.get("administration"):GetAllCaseClaims():next(function(caseclaims)
            local claim = caseclaims[steamID]
            if not claim then
                client:notifyInfo(string.format("No claims found for the specified player."))
                return
            end

            local claimsData = {
                {
                    steamID = steamID,
                    name = claim.name,
                    claims = claim.claims,
                    lastclaim = os.date("%Y-%m-%d %H:%M:%S", claim.lastclaim),
                    timeSinceLastClaim = lia.time.timeSince(claim.lastclaim),
                    claimedFor = table.IsEmpty(claim.claimedFor) and "None" or table.concat((function()
                        local t = {}
                        for sid, name in pairs(claim.claimedFor) do
                            table.insert(t, string.format("%s (%s)", name, sid))
                        end
                        return t
                    end)(), "\n")
                }
            }

            lia.util.createTableUI({
                title = string.format("Claims for %s", target:Nick()),
                columns = {
                    {
                        name = "SteamID",
                        field = "steamID"
                    },
                    {
                        name = "Admin Name",
                        field = "name"
                    },
                    {
                        name = "Total Claims",
                        field = "claims"
                    },
                    {
                        name = "Last Claim Date",
                        field = "lastclaim"
                    },
                    {
                        name = "Time Since Last Claim",
                        field = "timeSinceLastClaim"
                    },
                    {
                        name = "Claimed For",
                        field = "claimedFor"
                    }
                },
                data = claimsData,
            }, client)
        end)
    end
})

lia.command.add("viewallclaims", {
    adminOnly = true,
    desc = "Displays a summary table of claim data for all admins.",
    onRun = function(client)
        lia.module.get("administration"):GetAllCaseClaims():next(function(caseclaims)
            if table.IsEmpty(caseclaims) then
                client:notifyInfo(string.format("No claims have been recorded yet."))
                return
            end

            local claimsData = {}
            for steamID, claim in pairs(caseclaims) do
                table.insert(claimsData, {
                    steamID = steamID,
                    name = claim.name,
                    claims = claim.claims,
                    lastclaim = os.date("%Y-%m-%d %H:%M:%S", claim.lastclaim),
                    timeSinceLastClaim = lia.time.timeSince(claim.lastclaim),
                    claimedFor = table.IsEmpty(claim.claimedFor) and "None" or table.concat((function()
                        local t = {}
                        for sid, name in pairs(claim.claimedFor) do
                            table.insert(t, string.format("%s (%s)", name, sid))
                        end
                        return t
                    end)(), ", ")
                })
            end

            lia.util.createTableUI({
                title = "Admin Claims",
                columns = {
                    {
                        name = "SteamID",
                        field = "steamID"
                    },
                    {
                        name = "Admin Name",
                        field = "name"
                    },
                    {
                        name = "Total Claims",
                        field = "claims"
                    },
                    {
                        name = "Last Claim Date",
                        field = "lastclaim"
                    },
                    {
                        name = "Time Since Last Claim",
                        field = "timeSinceLastClaim"
                    },
                    {
                        name = "Claimed For",
                        field = "claimedFor"
                    }
                },
                data = claimsData,
            }, client)
        end)
    end
})

lia.command.add("viewclaims", {
    adminOnly = true,
    desc = "Prints detailed claim information for every admin to chat.",
    onRun = function(client)
        lia.module.get("administration"):GetAllCaseClaims():next(function(caseclaims)
            if table.IsEmpty(caseclaims) then
                client:notifyInfo(string.format("No claims data available."))
                return
            end

            local claimsData = {}
            for steamID, claim in pairs(caseclaims) do
                table.insert(claimsData, {
                    steamID = steamID,
                    name = claim.name,
                    claims = claim.claims,
                    lastclaim = os.date("%Y-%m-%d %H:%M:%S", claim.lastclaim),
                    timeSinceLastClaim = lia.time.timeSince(claim.lastclaim),
                    claimedFor = table.IsEmpty(claim.claimedFor) and "None" or table.concat((function()
                        local t = {}
                        for sid, name in pairs(claim.claimedFor) do
                            table.insert(t, string.format("%s (%s)", name, sid))
                        end
                        return t
                    end)(), "\n")
                })
            end

            lia.util.createTableUI({
                title = "Admin Claims",
                columns = {
                    {
                        name = "SteamID",
                        field = "steamID"
                    },
                    {
                        name = "Admin Name",
                        field = "name"
                    },
                    {
                        name = "Total Claims",
                        field = "claims"
                    },
                    {
                        name = "Last Claim Date",
                        field = "lastclaim"
                    },
                    {
                        name = "Time Since Last Claim",
                        field = "timeSinceLastClaim"
                    },
                    {
                        name = "Claimed For",
                        field = "claimedFor"
                    }
                },
                data = claimsData,
            }, client)
        end)
    end
})

lia.command.add("warn", {
    adminOnly = true,
    desc = "Issues a warning to the specified player with a given reason.",
    arguments = {
        {
            name = "target",
            type = "player"
        },
        {
            name = "severity",
            type = "string",
            optional = true
        },
        {
            name = "Reason",
            type = "string"
        },
    },
    AdminStick = {
        Name = "Warn Player",
        ButtonText = "Warn Player",
        Category = "Warnings",
    },
    onRun = function(client, arguments)
        local targetName = arguments[1]
        local rawSeverity = arguments[2]
        local reasonStartIndex = 3
        local severity = "Medium"
        local function normalizeSeverity(value)
            if not isstring(value) then return nil end
            local lowered = string.lower(string.Trim(value))
            if lowered == "low" or lowered == "minor" then return "Low" end
            if lowered == "medium" or lowered == "med" then return "Medium" end
            if lowered == "high" or lowered == "major" then return "High" end
            return nil
        end

        local normalized = normalizeSeverity(rawSeverity)
        if normalized then
            severity = normalized
        elseif rawSeverity and rawSeverity ~= "" then
            client:notifyError(string.format("Invalid argument."))
            return
        else
            reasonStartIndex = 2
        end

        local reason = table.concat(arguments, " ", reasonStartIndex)
        if not targetName or reason == "" then return "Usage: warn [player] [severity] [reason]" end
        local target = lia.util.findPlayer(client, targetName)
        if not target or not IsValid(target) then
            client:notifyError(string.format("Target not found"))
            return
        end

        local timestamp = os.date("%Y-%m-%d %H:%M:%S")
        local warnerName = client:Nick()
        local warnerSteamID = client:SteamID()
        hook.Run("AddWarning", target:getChar():getID(), target:Nick(), target:SteamID(), timestamp, reason, warnerName, warnerSteamID, severity)
        lia.db.count("warnings", "charID = " .. lia.db.convertDataType(target:getChar():getID())):next(function(count)
            target:notifyWarning(string.format("You have been warned by %s (%s) for: %s", warnerName .. " (" .. warnerSteamID .. ")", severity, reason))
            client:notifySuccess(string.format("Warning issued to %s", target:Nick()))
            local message = string.format("%s warned %s (Character %s | Steam64ID: %s) for \"%s\" [Severity: %s].", warnerName, target:Name(), target:getChar():getID(), target:SteamID64(), reason, severity)
            StaffAddTextShadowed(Color(255, 140, 0), "WARNING", Color(255, 255, 255), message)
            hook.Run("WarningIssued", client, target, reason, severity, count, warnerSteamID, target:SteamID())
        end)
    end
})

lia.command.add("viewwarns", {
    adminOnly = true,
    desc = "Displays all warnings issued to the specified player.",
    arguments = {
        {
            name = "target",
            type = "string"
        },
    },
    AdminStick = {
        Name = "View Player Warnings",
        ButtonText = "View Warnings",
        Category = "Warnings",
    },
    onRun = function(client, arguments)
        local targetName = arguments[1]
        if not targetName then
            client:notifyError(string.format("Target not found"))
            return
        end

        local target = lia.util.findPlayer(client, targetName)
        local lookupSteamID, displayName = targetName, targetName
        local warningsPromise
        if IsValid(target) then
            displayName = target:Nick()
            warningsPromise = lia.db.select({"id", "timestamp", "message", "warner", "warnerSteamID", "severity"}, "warnings", "charID = " .. lia.db.convertDataType(target:getChar():getID())):next(function(res) return res.results or {} end)
        else
            warningsPromise = lia.db.select({"id", "timestamp", "message", "warner", "warnerSteamID", "severity", "warned"}, "warnings", "warnedSteamID = " .. lia.db.convertDataType(lookupSteamID)):next(function(res)
                local rows = res.results or {}
                if #rows > 0 then displayName = rows[1].warned or displayName end
                return rows
            end)
        end

        warningsPromise:next(function(warns)
            if #warns == 0 then
                client:notifyInfo(string.format("%s has no warnings.", displayName))
                return
            end

            local warningList = {}
            for index, warn in ipairs(warns) do
                table.insert(warningList, {
                    index = index,
                    timestamp = warn.timestamp or "N/A",
                    admin = string.format("%s (%s)", warn.warner or "N/A", warn.warnerSteamID or "N/A"),
                    warningMessage = warn.message or "N/A",
                    severity = warn.severity or "Medium"
                })
            end

            lia.util.createTableUI({
                title = string.format("%s's Warnings", displayName),
                columns = {
                    {
                        name = "id",
                        field = "index"
                    },
                    {
                        name = "Timestamp",
                        field = "timestamp"
                    },
                    {
                        name = "Admin",
                        field = "admin"
                    },
                    {
                        name = "Warning Message",
                        field = "warningMessage"
                    },
                    {
                        name = "Severity",
                        field = "severity"
                    }
                },
                data = warningList,
                options = {
                    {
                        name = string.format("Remove %s", "Warning"),
                        net = "liaRequestRemoveWarning"
                    }
                },
                characterID = target:getChar():getID(),
            }, client)
        end)
    end
})

local function GetWarningsByIssuer(steamID)
    local condition = "warnerSteamID = " .. lia.db.convertDataType(steamID)
    return lia.db.select({"id", "timestamp", "message", "warned", "warnedSteamID", "warner", "warnerSteamID", "severity"}, "warnings", condition):next(function(res) return res.results or {} end)
end

lia.command.add("viewwarnsissued", {
    adminOnly = true,
    desc = "Displays all warnings issued by the specified staff member.",
    arguments = {
        {
            name = "Staff",
            type = "string"
        },
    },
    onRun = function(client, arguments)
        local targetName = arguments[1]
        if not targetName then
            client:notifyError(string.format("Target not found"))
            return
        end

        local target = lia.util.findPlayer(client, targetName)
        local steamID, displayName = targetName, targetName
        if IsValid(target) then
            steamID = target:SteamID()
            displayName = target:Nick()
        end

        GetWarningsByIssuer(steamID):next(function(warns)
            if #warns == 0 then
                client:notifyInfo(string.format("%s has no warnings.", displayName))
                return
            end

            local warningList = {}
            for index, warn in ipairs(warns) do
                warningList[#warningList + 1] = {
                    index = index,
                    timestamp = warn.timestamp or "N/A",
                    player = string.format("%s (%s)", warn.warned or "N/A", warn.warnedSteamID or "N/A"),
                    warningMessage = warn.message or "N/A",
                    severity = warn.severity or "Medium"
                }
            end

            lia.util.createTableUI({
                title = string.format("Warnings Issued by %s", displayName),
                columns = {
                    {
                        name = "id",
                        field = "index"
                    },
                    {
                        name = "Timestamp",
                        field = "timestamp"
                    },
                    {
                        name = "Player",
                        field = "player"
                    },
                    {
                        name = "Warning Message",
                        field = "warningMessage"
                    },
                    {
                        name = "Severity",
                        field = "severity"
                    }
                },
                data = warningList,
            }, client)
        end)
    end
})

lia.command.add("recogwhisper", {
    adminOnly = true,
    arguments = {
        {
            name = "Name",
            type = "player"
        },
    },
    desc = "Force player recognition in whisper range.",
    AdminStick = {
        Name = "Force Recognition (Whisper)",
        ButtonText = "Force Recognize Whisper",
        Category = "Recognition",
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1]) or client
        if not IsValid(target) or not target:getChar() then return end
        hook.Run("ForceRecognizeRange", target, "whisper")
    end
})

lia.command.add("recognormal", {
    adminOnly = true,
    arguments = {
        {
            name = "Name",
            type = "player"
        },
    },
    desc = "Force player recognition in normal range.",
    AdminStick = {
        Name = "Force Recognition (Normal)",
        ButtonText = "Force Recognize Nearby",
        Category = "Recognition",
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1]) or client
        if not IsValid(target) or not target:getChar() then return end
        hook.Run("ForceRecognizeRange", target, "normal")
    end
})

lia.command.add("recogyell", {
    adminOnly = true,
    arguments = {
        {
            name = "Name",
            type = "player"
        },
    },
    desc = "Force player recognition in yell range.",
    AdminStick = {
        Name = "Force Recognition (Yell)",
        ButtonText = "Force Recognize Yell",
        Category = "Recognition",
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1]) or client
        if not IsValid(target) or not target:getChar() then return end
        hook.Run("ForceRecognizeRange", target, "yell")
    end
})

lia.command.add("recogbots", {
    superAdminOnly = true,
    arguments = {
        {
            name = "Range",
            type = "string",
            optional = true
        },
        {
            name = "Name",
            type = "string",
            optional = true
        },
    },
    desc = "Force all bots to recognize people around them. Optionally specify a fake name.",
    onRun = function(_, arguments)
        local range = arguments[1] or "normal"
        local fakeName = arguments[2]
        for _, ply in player.Iterator() do
            if ply:IsBot() then hook.Run("ForceRecognizeRange", ply, range, fakeName) end
        end
    end
})

lia.command.add("kickbots", {
    privilege = "Manage Bots",
    desc = "Kick all bots from the server.",
    onRun = function(client)
        if timer.Exists("Bots_Add_Timer") then timer.Remove("Bots_Add_Timer") end
        local kickedCount = 0
        for _, bot in player.Iterator() do
            if bot:IsBot() then
                bot:Kick("All bots kicked")
                client:notifySuccess(string.format("Player kicked."))
                lia.db.insertTable({
                    player = bot:Name(),
                    playerSteamID = bot:SteamID(),
                    steamID = bot:SteamID(),
                    action = "plykick",
                    staffName = client:Name(),
                    staffSteamID = client:SteamID(),
                    timestamp = os.time()
                }, nil, "staffactions")

                kickedCount = kickedCount + 1
            end
        end

        if kickedCount == 0 then
            client:notifyError(string.format("No bots to kick."))
        else
            client:notifyInfo(string.format("Kicked %d bots from the server.", kickedCount))
        end
    end
})

lia.command.add("forcerespawn", {
    desc = "Force yourself to respawn after death.",
    onRun = function(client)
        if client:Alive() then
            client:notifyError(string.format("Player is already alive."))
            return
        end

        local baseTime = lia.config.get("SpawnTime", 5)
        baseTime = hook.Run("OverrideSpawnTime", client, baseTime) or baseTime
        local lastDeath = client:getLocalVar("lastDeathTime", os.time())
        local timePassed = os.time() - lastDeath
        if timePassed < baseTime then
            client:notifyError(string.format("You cannot respawn yet. Please wait %s seconds.", baseTime - timePassed))
            return
        end

        client:Spawn()
        client:setLocalVar("lastDeathTime", 0)
        client:notifySuccess(string.format("Successfully force respawned %s.", client:Name()))
        client:notify(string.format("You were force respawned by an admin."))
    end
})

lia.command.add("resetvendorcooldowns", {
    desc = "Reset vendor cooldowns for a player",
    privilege = "Can Edit Vendors",
    adminOnly = true,
    arguments = {
        {
            name = "target",
            type = "player",
            description = "The player to reset cooldowns for"
        }
    },
    AdminStick = {
        Name = "Reset Vendor Cooldowns",
        ButtonText = "Reset Vendor Cooldowns",
        Category = "Vendors",
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not IsValid(target) then
            client:notifyError(string.format("Invalid Target!"))
            return
        end

        local character = target:getChar()
        if not character then
            client:notifyError(string.format("Invalid Target!"))
            return
        end

        character:setData("vendorCooldowns", {})
        client:notify(string.format("Vendor cooldowns have been reset for %s.", target:Name()))
        target:notify(string.format("Your vendor cooldowns have been reset by an administrator."))
    end
})

lia.command.add("storagepasswordremove", {
    adminOnly = true,
    desc = "Remove the password from the storage container you're looking at.",
    arguments = {},
    onRun = function(client)
        local trace = client:GetEyeTrace()
        local entity = trace.Entity
        if not IsValid(entity) or trace.HitPos:Distance(client:GetPos()) > 128 then
            client:notifyError(string.format("Invalid Target!"))
            return
        end

        if not entity.password then
            client:notifyError(string.format("This storage is not locked."))
            return
        end

        entity.password = nil
        entity:setNetVar("locked", false)
        client:notifySuccess(string.format("Storage password has been removed."))
        hook.Run("UpdateEntityPersistence", entity)
    end
})

lia.command.add("storagepasswordchange", {
    adminOnly = true,
    desc = "Change the password on the storage container you're looking at.",
    arguments = {
        {
            name = "Password",
            type = "string"
        },
    },
    onRun = function(client, arguments)
        local trace = client:GetEyeTrace()
        local entity = trace.Entity
        local newPassword = arguments[1]
        if not IsValid(entity) or trace.HitPos:Distance(client:GetPos()) > 128 then
            client:notifyError(string.format("Invalid Target!"))
            return
        end

        if not newPassword or newPassword == "" then
            client:notifyError(string.format("Password cannot be empty."))
            return
        end

        entity.password = newPassword
        entity:setNetVar("locked", true)
        client:notifySuccess(string.format("Storage password has been changed."))
        hook.Run("UpdateEntityPersistence", entity)
    end
})

lia.command.add("listnearbyentities", {
    adminOnly = true,
    desc = "Lists all entities within a specified radius around the player.",
    arguments = {
        {
            name = "radius",
            type = "string",
            optional = true
        },
    },
    onRun = function(client, arguments)
        local radius = tonumber(arguments[1]) or 500
        if radius <= 0 then radius = 500 end
        if radius > 10000 then radius = 10000 end
        local pos = client:GetPos()
        local entities = ents.FindInSphere(pos, radius)
        local entityCategories = {
            players = {},
            npcs = {},
            props = {},
            vehicles = {},
            weapons = {},
            other = {}
        }

        for _, ent in ipairs(entities) do
            if not IsValid(ent) then continue end
            local class = ent:GetClass()
            local category = "Other"
            if ent:IsPlayer() then
                category = "Players"
            elseif ent:IsNPC() then
                category = "NPCs"
            elseif ent:IsVehicle() then
                category = "Vehicles"
            elseif ent:IsWeapon() then
                category = "Weapons"
            elseif class:find("prop_") or class == "lia_item" then
                category = "Props"
            end

            table.insert(entityCategories[category], {
                class = class,
                model = ent:GetModel() or "N/A",
                pos = ent:GetPos(),
                distance = pos:Distance(ent:GetPos()),
                health = ent.Health and ent:Health() or "N/A",
                name = ent.GetName and ent:GetName() or "N/A"
            })
        end

        client:ChatPrint(string.format("=== Entities within %s units ===", radius))
        for categoryName, entitiesInCategory in pairs(entityCategories) do
            if #entitiesInCategory > 0 then
                local displayCategoryName = lia.lang.resolve(categoryName):upper()
                client:ChatPrint(string.format("--- %s (%s) ---", displayCategoryName, #entitiesInCategory))
                table.sort(entitiesInCategory, function(a, b) return a.distance < b.distance end)
                for _, entData in ipairs(entitiesInCategory) do
                    local info = string.format("%s units: %s", string.format("%.1f", entData.distance), entData.class)
                    if entData.name ~= "N/A" and entData.name ~= "" then info = info .. " (" .. entData.name .. ")" end
                    if entData.health ~= "N/A" then info = info .. " [" .. string.format("HP: %s", entData.health) .. "]" end
                    client:ChatPrint(info)
                end

                client:ChatPrint("")
            end
        end

        local totalEntities = 0
        for _, entitiesInCategory in pairs(entityCategories) do
            totalEntities = totalEntities + #entitiesInCategory
        end

        client:ChatPrint(string.format("Total entities found: %s", totalEntities))
        client:notify(string.format("Listed %s entities within %s units", totalEntities, radius))
    end
})

concommand.Add("lia_setextrachars", function(client, _, args)
    if IsValid(client) then
        client:notifyError(string.format("This command can only be run from the server console."))
        return
    end

    local steamid = args[1]
    local amount = tonumber(args[2])
    if not steamid or steamid == "" then
        MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), "Invalid SteamID provided.\n")
        return
    end

    if not amount or amount < 0 then
        MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), "Invalid amount provided. Must be a non-negative number.\n")
        return
    end

    lia.db.query("SELECT steamID, data FROM lia_players WHERE steamID = " .. lia.db.convertDataType(steamid) .. " LIMIT 1", function(data)
        local playerData = {}
        if data and data[1] then
            playerData = data[1].data
            if isstring(playerData) then
                playerData = util.JSONToTable(playerData) or {}
            elseif not playerData then
                playerData = {}
            end
        else
            lia.db.insertTable({
                steamID = steamid,
                steamName = "Unknown",
                data = "{}",
                lastJoin = os.date("%Y-%m-%d %H:%M:%S", os.time()),
                lastIP = "",
                lastOnline = os.time(),
                totalOnlineTime = 0
            }, nil, "players")
        end

        local currentExtra = tonumber(playerData.extraCharacters) or 0
        local newExtra = currentExtra + amount
        playerData.extraCharacters = newExtra
        lia.db.updateTable({
            data = util.TableToJSON(playerData)
        }, nil, "players", "steamID = " .. lia.db.convertDataType(steamid))

        for _, ply in player.Iterator() do
            if ply:SteamID() == steamid then
                ply:setLiliaData("extraCharacters", newExtra)
                break
            end
        end

        MsgC(Color(0, 255, 0), "[Lilia] ", Color(255, 255, 255), "Added " .. amount .. " extra character slot" .. (amount == 1 and "" or "s") .. " to player " .. steamid .. ". New total: " .. newExtra .. " (was " .. currentExtra .. ").\n")
    end)
end)

concommand.Add("lia_set_inventory_size_all_chars", function(client, _, args)
    if IsValid(client) then return end
    local steamID = args[1]
    local width = tonumber(args[2])
    local height = tonumber(args[3])
    if not steamID or not width or not height then
        MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), "Usage: lia_set_inventory_size_all_chars <steamID> <width> <height>\n")
        return
    end

    if width < 1 or height < 1 then
        MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), "Width and height must be positive numbers.\n")
        return
    end

    lia.db.select({"id", "name"}, "characters", "steamID = " .. lia.db.convertDataType(steamID)):next(function(res)
        local characters = res.results or {}
        if not characters or #characters == 0 then
            MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), string.format("No characters found for SteamID: %s", steamID) .. "\n")
            return
        end

        MsgC(Color(255, 255, 255), "[Lilia] ", "Processing " .. #characters .. " characters...\n")
        local ply = player.GetBySteamID(steamID)
        local isPlayerOnline = IsValid(ply) and ply:IsPlayer()
        local updatePromises = {}
        local sizeOverride = {width, height}
        local hasNotifiedPlayer = false
        local hasNotifiedStaff = false
        for _, charData in ipairs(characters) do
            local charID = charData.id
            local charName = charData.name
            local promise
            if isPlayerOnline then
                local character = lia.char.getCharacter(charID)
                if character then
                    character:setData("invSizeOverride", sizeOverride)
                    if not hasNotifiedPlayer then
                        ClientAddTextShadowed(ply, Color(255, 0, 0), "INVENTORY", Color(255, 255, 255), " " .. string.format("Your inventory size has been changed to %sx%s. Please swap characters for the change to take effect.", width, height))
                        hasNotifiedPlayer = true
                    end

                    if not hasNotifiedStaff then
                        local staffMessage = string.format("Inventory size set to %sx%s for %s (Steam64ID: %s).", width, height, ply:Name(), ply:SteamID64())
                        StaffAddTextShadowed(Color(199, 21, 133), "INVENTORY", Color(255, 255, 255), staffMessage)
                        hasNotifiedStaff = true
                    end

                    MsgC(Color(0, 255, 0), "[Lilia] ", Color(255, 255, 255), "Set inventory size override for character '" .. charName .. "' (ID: " .. charID .. ") to " .. width .. "x" .. height .. " (player online)\n")
                    promise = deferred.resolve(true)
                else
                    promise = deferred.new()
                    local encoded = pon.encode({sizeOverride})
                    lia.db.upsert({
                        charID = charID,
                        key = "invSizeOverride",
                        value = encoded
                    }, "chardata", function(success, err)
                        if success then
                            MsgC(Color(0, 255, 0), "[Lilia] ", Color(255, 255, 255), "Set inventory size override for character '" .. charName .. "' (ID: " .. charID .. ") to " .. width .. "x" .. height .. " (player online, char not loaded)\n")
                            promise:resolve(true)
                        else
                            MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), "Error setting inventory size override for character '" .. charName .. "' (ID: " .. charID .. "): " .. tostring(err) .. "\n")
                            promise:resolve(false)
                        end
                    end)
                end
            else
                promise = deferred.new()
                local encoded = pon.encode({sizeOverride})
                lia.db.upsert({
                    charID = charID,
                    key = "invSizeOverride",
                    value = encoded
                }, "chardata", function(success, err)
                    if success then
                        MsgC(Color(0, 255, 0), "[Lilia] ", Color(255, 255, 255), "Set inventory size override for character '" .. charName .. "' (ID: " .. charID .. ") to " .. width .. "x" .. height .. " (player offline)\n")
                        promise:resolve(true)
                    else
                        MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), "Error setting inventory size override for character '" .. charName .. "' (ID: " .. charID .. "): " .. tostring(err) .. "\n")
                        promise:resolve(false)
                    end
                end)
            end

            table.insert(updatePromises, promise)
        end

        deferred.map(updatePromises, function(result) return result end):next(function(results)
            local successCount = 0
            for _, success in ipairs(results) do
                if success then successCount = successCount + 1 end
            end

            MsgC(Color(0, 255, 0), "[Lilia] ", Color(255, 255, 255), "Successfully set inventory size override for " .. successCount .. " of " .. #characters .. " characters.\n")
            MsgC(Color(255, 255, 0), "[Lilia] ", Color(255, 255, 255), "Note: Inventory sizes will be applied when characters load.\n")
        end)
    end):catch(function(err) MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), "Database error: " .. tostring(err) .. "\n") end)
end)

concommand.Add("lia_give_money_steamid", function(client, _, args)
    if IsValid(client) then
        client:notifyError(string.format("This command can only be run from the server console."))
        return
    end

    local steamID = args[1]
    local amount = tonumber(args[2])
    if not steamID or not amount then
        MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), "Usage: lia_give_money_steamid <steamID> <amount>\n")
        return
    end

    if amount < 0 then
        MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), "Amount must be a positive number.\n")
        return
    end

    lia.db.select({"id", "name", "money"}, "characters", "steamID = " .. lia.db.convertDataType(steamID)):next(function(res)
        local characters = res.results or {}
        if not characters or #characters == 0 then
            MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), "No characters found for SteamID: " .. steamID .. "\n")
            return
        end

        local ply = player.GetBySteamID(steamID)
        local isPlayerOnline = IsValid(ply) and ply:IsPlayer()
        local updatedCount = 0
        for _, charData in ipairs(characters) do
            local charID = charData.id
            local charName = charData.name
            local currentMoney = tonumber(charData.money) or 0
            local newMoney = currentMoney + amount
            if isPlayerOnline and ply:getChar() and ply:getChar():getID() == charID then
                local char = ply:getChar()
                char:giveMoney(amount)
                local actualNewMoney = char:getMoney()
                updatedCount = updatedCount + 1
                MsgC(Color(0, 255, 0), "[Lilia] ", Color(255, 255, 255), string.format("Gave %s to character '%s' (ID: %s). New balance: %s (player online)", lia.currency.get(amount), charName, charID, lia.currency.get(actualNewMoney)) .. "\n")
                if updatedCount == #characters then MsgC(Color(0, 255, 0), "[Lilia] ", Color(255, 255, 255), string.format("Successfully gave %s to %s characters owned by SteamID: %s", lia.currency.get(amount), #characters, steamID) .. "\n") end
            else
                if lia.char.setCharDatabase(charID, "money", newMoney) then
                    updatedCount = updatedCount + 1
                    MsgC(Color(0, 255, 0), "[Lilia] ", Color(255, 255, 255), string.format("Gave %s to character '%s' (ID: %s). New balance: %s (player offline)", lia.currency.get(amount), charName, charID, lia.currency.get(newMoney)) .. "\n")
                    if updatedCount == #characters then MsgC(Color(0, 255, 0), "[Lilia] ", Color(255, 255, 255), string.format("Successfully gave %s to %s characters owned by SteamID: %s", lia.currency.get(amount), #characters, steamID) .. "\n") end
                else
                    MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), string.format("Error updating money for character '%s' (ID: %s)", charName, charID) .. "\n")
                end
            end
        end
    end):catch(function(err) MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), string.format("Database error: %s", tostring(err)) .. "\n") end)
end)
