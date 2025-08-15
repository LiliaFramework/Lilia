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

        local name = arg.name or typ
        local optional = arg.optional and " optional" or ""
        tokens[#tokens + 1] = string.format("[%s %s%s]", typ, name, optional)
    end
    return table.concat(tokens, " ")
end

function lia.command.add(command, data)
    data.arguments = data.arguments or {}
    data.syntax = lia.command.buildSyntaxFromArguments(data.arguments)
    data.syntax = L(data.syntax or "")
    data.desc = data.desc or ""
    data.privilege = data.privilege or nil
    local superAdminOnly = data.superAdminOnly
    local adminOnly = data.adminOnly
    if not data.onRun then
        lia.error(L("commandNoCallback", command))
        return
    end

    if superAdminOnly or adminOnly then
        local privilegeName = data.privilege and L(data.privilege) or L("accessTo", command)
        local privilegeID = data.privilege or string.lower("command_" .. command)
        lia.administrator.registerPrivilege({
            Name = privilegeName,
            ID = privilegeID,
            MinAccess = superAdminOnly and "superadmin" or "admin",
            Category = "commands"
        })
    end

    for _, arg in ipairs(data.arguments) do
        if arg.type == "boolean" then
            arg.type = "bool"
        elseif arg.type ~= "player" and arg.type ~= "table" and arg.type ~= "bool" then
            arg.type = "string"
        end

        arg.optional = arg.optional or false
    end

    local onRun = data.onRun
    data._onRun = data.onRun
    data.onRun = function(client, arguments)
        local hasAccess, _ = lia.command.hasAccess(client, command, data)
        if hasAccess then
            return onRun(client, arguments)
        else
            return "@noPerm"
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
                    lia.administrator.registerPrivilege({
                        Name = data.privilege and L(data.privilege) or L("accessTo", v),
                        ID = aliasPrivilegeID,
                        MinAccess = superAdminOnly and "superadmin" or "admin",
                        Category = "commands"
                    })
                end
            end
        elseif isstring(alias) then
            local aliasData = table.Copy(data)
            aliasData.realCommand = command
            lia.command.list[alias:lower()] = aliasData
            if superAdminOnly or adminOnly then
                local aliasPrivilegeID = data.privilege or string.lower("command_" .. alias)
                lia.administrator.registerPrivilege({
                    Name = data.privilege and L(data.privilege) or L("accessTo", alias),
                    ID = aliasPrivilegeID,
                    MinAccess = superAdminOnly and "superadmin" or "admin",
                    Category = "commands"
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

    hook.Run("liaCommandAdded", command, data)
end

function lia.command.hasAccess(client, command, data)
    if not data then data = lia.command.list[command] end
    if not data then return false, "unknown" end
    local privilegeID = data.privilege or string.lower("command_" .. command)
    local superAdminOnly = data.superAdminOnly
    local adminOnly = data.adminOnly
    local accessLevels = superAdminOnly and "superadmin" or adminOnly and "admin" or "user"
    local privilegeName = data.privilege and L(data.privilege) or accessLevels == "user" and L("globalAccess") or L("accessTo", command)
    local hasAccess = true
    if accessLevels ~= "user" then
        if not isstring(privilegeID) then
            lia.error("Command '" .. tostring(command) .. "' has invalid privilege ID type: " .. tostring(privilegeID))
            return false, privilegeName
        end

        hasAccess = client:hasPrivilege(privilegeID)
    end

    local hookResult = hook.Run("CanPlayerUseCommand", client, command)
    if hookResult ~= nil then return hookResult, privilegeName end
    local char = IsValid(client) and client.getChar and client:getChar()
    if char then
        local faction = lia.faction.indices[char:getFaction()]
        if faction and faction.commands and faction.commands[command] then return true, privilegeName end
        local classData = lia.class.list[char:getClass()]
        if classData and classData.commands and classData.commands[command] then return true, privilegeName end
    end
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
            hook.Run("liaCommandRan", client, command, arguments or {}, results)
            local result = results[1]
            if isstring(result) then
                if IsValid(client) then
                    if result:sub(1, 1) == "@" then
                        client:notifyLocalized(result:sub(2), unpack(results, 2))
                    else
                        client:notify(result)
                    end
                else
                    print(result)
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
                if not arguments then arguments = lia.command.extractArgs(text:sub(#match + 3)) end
                local fields = command.arguments or {}
                if IsValid(client) and client:IsPlayer() and #fields > 0 then
                    local tokens = combineBracketArgs(arguments)
                    local missing = {}
                    local prefix = {}
                    for i, field in ipairs(fields) do
                        local arg = tokens[i]
                        if not arg or isPlaceholder(arg) then
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
                        net.Send(client)
                        return true
                    end
                end

                lia.command.run(client, match, arguments)
                if not realCommand then lia.log.add(client, "command", text) end
            else
                if IsValid(client) then
                    client:notifyLocalized("cmdNoExist")
                else
                    lia.information(L("cmdNoExist"))
                end
            end
            return true
        end
        return false
    end
else
    function lia.command.openArgumentPrompt(cmdKey, missing, prefix)
        local command = lia.command.list[cmdKey]
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
        local frameW, frameH = 600, 200 + numFields * 75
        local frame = vgui.Create("DFrame")
        frame:SetTitle("")
        frame:SetSize(frameW, frameH)
        frame:Center()
        frame:MakePopup()
        frame:ShowCloseButton(false)
        frame.Paint = function(self, w, h)
            derma.SkinHook("Paint", "Frame", self, w, h)
            draw.SimpleText(L(cmdKey), "liaMediumFont", w / 2, 10, color_white, TEXT_ALIGN_CENTER)
        end

        local scroll = vgui.Create("DScrollPanel", frame)
        scroll:Dock(FILL)
        scroll:DockMargin(10, 40, 10, 10)
        surface.SetFont("liaSmallFont")
        local controls = {}
        local watchers = {}
        local validate
        for name, data in pairs(fields) do
            local fieldType = data.type
            local optional = data.optional
            local options = data.options
            local filter = data.filter
            local panel = vgui.Create("DPanel", scroll)
            panel:Dock(TOP)
            panel:DockMargin(0, 0, 0, 5)
            panel:SetTall(70)
            panel.Paint = function() end
            local textW = select(1, surface.GetTextSize(L(data.description or name)))
            local ctrl
            if fieldType == "player" then
                ctrl = vgui.Create("DComboBox", panel)
                ctrl:SetValue(L("select") .. " " .. L("player"))
                local players = {}
                for _, plyObj in player.Iterator() do
                    if IsValid(plyObj) then players[#players + 1] = plyObj end
                end

                if isfunction(filter) then
                    local ok, res = pcall(filter, LocalPlayer(), players)
                    if ok and istable(res) then players = res end
                end

                for _, plyObj in ipairs(players) do
                    ctrl:AddChoice(plyObj:Name(), plyObj:SteamID())
                end
            elseif fieldType == "table" then
                ctrl = vgui.Create("DComboBox", panel)
                ctrl:SetValue(L("select") .. " " .. L(name))
                local opts = options
                if isfunction(opts) then
                    local ok, res = pcall(opts)
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
            elseif fieldType == "bool" then
                ctrl = vgui.Create("DCheckBox", panel)
            else
                ctrl = vgui.Create("DTextEntry", panel)
                ctrl:SetFont("liaSmallFont")
            end

            local label = vgui.Create("DLabel", panel)
            label:SetFont("liaSmallFont")
            label:SetText(L(data.description or name))
            label:SizeToContents()
            panel.PerformLayout = function(_, w, h)
                local ctrlH = 30
                ctrl:SetTall(ctrlH)
                local ctrlW = w * 0.7
                local totalW = textW + 10 + ctrlW
                local xOff = (w - totalW) / 2
                label:SetPos(xOff, (h - label:GetTall()) / 2)
                ctrl:SetPos(xOff + textW + 10, (h - ctrlH) / 2)
                ctrl:SetWide(ctrlW)
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

        local buttons = vgui.Create("DPanel", frame)
        buttons:Dock(BOTTOM)
        buttons:SetTall(90)
        buttons:DockPadding(15, 15, 15, 15)
        buttons.Paint = function() end
        local submit = vgui.Create("DButton", buttons)
        submit:Dock(LEFT)
        submit:DockMargin(0, 0, 15, 0)
        submit:SetWide(270)
        submit:SetText(L("submit"))
        submit:SetFont("liaSmallFont")
        submit:SetIcon("icon16/tick.png")
        submit:SetEnabled(false)
        validate = function()
            for _, data in pairs(controls) do
                if not data.optional then
                    local ctl = data.ctrl
                    local ftype = data.type
                    local filled
                    if ftype == "player" or ftype == "table" then
                        local txt, _ = ctl:GetSelected()
                        filled = txt ~= nil and txt ~= ""
                    elseif ftype == "bool" then
                        filled = true
                    else
                        filled = ctl:GetValue() ~= nil and ctl:GetValue() ~= ""
                    end

                    if not filled then
                        submit:SetEnabled(false)
                        return
                    end
                end
            end

            submit:SetEnabled(true)
        end

        for _, fn in ipairs(watchers) do
            fn()
        end

        validate()
        local cancel = vgui.Create("DButton", buttons)
        cancel:Dock(RIGHT)
        cancel:SetWide(270)
        cancel:SetText(L("cancel"))
        cancel:SetFont("liaSmallFont")
        cancel:SetIcon("icon16/cross.png")
        cancel.DoClick = function() frame:Remove() end
        submit.DoClick = function()
            local args = {}
            if prefix then table.Add(args, prefix) end
            for _, info in pairs(controls) do
                local ctl = info.ctrl
                local typ = info.type
                local val
                if typ == "player" or typ == "table" then
                    local _, dataVal = ctl:GetSelected()
                    val = dataVal or ctl:GetValue()
                elseif typ == "bool" then
                    val = ctl:GetChecked()
                else
                    val = ctl:GetValue()
                end

                args[#args + 1] = val ~= "" and val or nil
            end

            RunConsoleCommand("say", "/" .. cmdKey .. " " .. table.concat(args, " "))
            frame:Remove()
        end
    end

    function lia.command.send(command, ...)
        net.Start("cmd")
        net.WriteString(command)
        net.WriteTable({...})
        net.SendToServer()
    end
end

hook.Add("CreateInformationButtons", "liaInformationCommandsUnified", function(pages)
    local client = LocalPlayer()
    table.insert(pages, {
        name = "commands",
        drawFunc = function(parent)
            local sheet = vgui.Create("liaSheet", parent)
            sheet:SetPlaceholderText(L("searchCommands"))
            local useList = false
            if useList then
                local data = {}
                for cmdName, cmdData in SortedPairs(lia.command.list) do
                    if not isnumber(cmdName) then
                        local hasAccess = lia.command.hasAccess(client, cmdName, cmdData)
                        if hasAccess then
                            local text = "/" .. cmdName
                            if cmdData.syntax and cmdData.syntax ~= "" then text = text .. " " .. L(cmdData.syntax) end
                            local desc = cmdData.desc ~= "" and L(cmdData.desc) or ""
                            local priv = cmdData.privilege and L(cmdData.privilege) or ""
                            data[#data + 1] = {text, desc, priv}
                        end
                    end
                end

                sheet:AddListViewRow({
                    columns = {L("command"), L("description"), L("privilege")},
                    data = data,
                    height = 300
                })
            else
                for cmdName, cmdData in SortedPairs(lia.command.list) do
                    if not isnumber(cmdName) then
                        local hasAccess, privilege = lia.command.hasAccess(client, cmdName, cmdData)
                        if hasAccess then
                            local text = "/" .. cmdName
                            if cmdData.syntax and cmdData.syntax ~= "" then text = text .. " " .. L(cmdData.syntax) end
                            local desc = cmdData.desc ~= "" and L(cmdData.desc) or ""
                            local right = privilege and privilege ~= L("globalAccess") and privilege or ""
                            local row = sheet:AddTextRow({
                                title = text,
                                desc = desc,
                                right = right
                            })

                            row.filterText = (cmdName .. " " .. L(cmdData.syntax or "") .. " " .. desc .. " " .. right):lower()
                        end
                    end
                end
            end

            sheet:Refresh()
            parent.refreshSheet = function() if IsValid(sheet) then sheet:Refresh() end end
        end,
        onSelect = function(pnl) if pnl.refreshSheet then pnl.refreshSheet() end end
    })
end)

lia.command.findPlayer = lia.util.findPlayer
