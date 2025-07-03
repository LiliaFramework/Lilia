lia.command = lia.command or {}
lia.command.list = lia.command.list or {}
function lia.command.add(command, data)
    data.syntax = data.syntax or ""
    data.desc = data.desc or ""
    local superAdminOnly = data.superAdminOnly
    local adminOnly = data.adminOnly
    if not data.onRun then
        ErrorNoHalt("Command '" .. command .. "' does not have a callback, not adding!\n")
        return
    end

    if superAdminOnly or adminOnly then
        local privilegeName = "Commands - " .. (isstring(data.privilege) and data.privilege or command)
        if not CAMI.GetPrivilege(privilegeName) then
            CAMI.RegisterPrivilege({
                Name = privilegeName,
                MinAccess = superAdminOnly and "superadmin" or "admin"
            })
        end
    end

    local onRun = data.onRun
    data._onRun = data.onRun
    data.onRun = function(client, arguments)
        local hasAccess, _ = lia.command.hasAccess(client, command, data)
        if hasAccess then
            return onRun(client, arguments)
        else
            return "noPerm"
        end
    end

    local alias = data.alias
    if alias then
        if istable(alias) then
            for _, v in ipairs(alias) do
                lia.command.list[v:lower()] = data
            end
        elseif isstring(alias) then
            lia.command.list[alias:lower()] = data
        end
    end

    if command == command:lower() then
        lia.command.list[command] = data
    else
        data.realCommand = command
        lia.command.list[command:lower()] = data
    end
end

function lia.command.hasAccess(client, command, data)
    if not data then data = lia.command.list[command] end
    local privilege = data.privilege
    local superAdminOnly = data.superAdminOnly
    local adminOnly = data.adminOnly
    local accessLevels = superAdminOnly and "superadmin" or adminOnly and "admin" or "user"
    if not privilege then privilege = accessLevels == "user" and "Global" or command end
    local hasAccess = true
    if accessLevels ~= "user" then
        local privilegeName = "Commands - " .. privilege
        hasAccess = client:hasPrivilege(privilegeName)
    end

    local hookResult = hook.Run("CanPlayerUseCommand", client, command)
    if hookResult ~= nil then return hookResult, privilege end
    local char = IsValid(client) and client.getChar and client:getChar()
    if char then
        local faction = lia.faction.indices[char:getFaction()]
        if faction and faction.commands and faction.commands[command] then return true, privilege end
        local classData = lia.class.list[char:getClass()]
        if classData and classData.commands and classData.commands[command] then return true, privilege end
    end
    return hasAccess, privilege
end

function lia.command.extractArgs(text)
    local skip = 0
    local arguments = {}
    local curString = ""
    for i = 1, #text do
        if i <= skip then continue end
        local c = text:sub(i, i)
        if c == "\"" then
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
            if c == " " and curString == "" then continue end
            curString = curString .. c
        end
    end

    if curString ~= "" then arguments[#arguments + 1] = curString end
    return arguments
end

function lia.command.parseSyntaxFields(syntax)
    local fields = {}
    local valid = true
    if not syntax or syntax == "" then return fields, true end
    for token in syntax:gmatch("%b[]") do
        local inner = token:sub(2, -2)
        local typ, name = inner:match("^(%S+)%s+(.+)$")
        if name then
            typ = typ:lower()
            if typ == "string" then
                typ = "text"
            elseif typ == "number" then
                typ = "number"
            elseif typ == "bool" or typ == "boolean" then
                typ = "boolean"
            elseif typ == "player" or typ == "ply" then
                typ = "player"
            else
                valid = false
            end
        else
            name = inner
            typ = "text"
            valid = false
        end

        fields[#fields + 1] = {
            name = name,
            type = typ,
            optional = inner:lower():find("optional", 1, true) ~= nil
        }
    end

    local open = select(2, syntax:gsub("%[", ""))
    local close = select(2, syntax:gsub("%]", ""))
    if open ~= close then valid = false end
    if syntax:gsub("%b[]", ""):find("%S") then valid = false end
    return fields, valid
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
                local fields, valid = lia.command.parseSyntaxFields(command.syntax)
                if IsValid(client) and client:IsPlayer() and valid and #fields > 0 then
                    local tokens = combineBracketArgs(arguments)
                    local missing = {}
                    local prefix = {}
                    for i, field in ipairs(fields) do
                        local arg = tokens[i]
                        if not arg or isPlaceholder(arg) then
                            if not field.optional then missing[field.name] = field.type end
                        else
                            prefix[#prefix + 1] = arg
                        end
                    end

                    if table.Count(missing) > 0 then
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
                    lia.information("Sorry, that command does not exist.")
                end
            end
            return true
        end
        return false
    end
else
    function lia.command.openArgumentPrompt(cmdKey, fields, prefix)
        local ply = LocalPlayer()
        local command = lia.command.list[cmdKey]
        if not command then return end
        local firstKey = istable(fields) and next(fields)
        if not fields or isstring(fields) or firstKey and isnumber(firstKey) then
            local args = fields
            if isstring(args) then args = lia.command.extractArgs(args) end
            local parsed, valid = lia.command.parseSyntaxFields(command.syntax)
            if not valid then return end
            fields = {}
            prefix = {}
            local tokens = args and combineBracketArgs(args) or {}
            for i, field in ipairs(parsed) do
                local arg = tokens[i]
                if arg then
                    prefix[#prefix + 1] = arg
                else
                    fields[field.name] = {
                        type = field.type,
                        optional = field.optional
                    }
                end
            end
        else
            for k, v in pairs(fields) do
                if not istable(v) then
                    fields[k] = {
                        type = v,
                        optional = false
                    }
                end
            end
        end

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
        for name, data in pairs(fields) do
            local fieldType = data.type
            local optional = data.optional
            local panel = vgui.Create("DPanel", scroll)
            panel:Dock(TOP)
            panel:DockMargin(0, 0, 0, 5)
            panel:SetTall(70)
            panel.Paint = function() end
            local labelText = L(name)
            local textW = select(1, surface.GetTextSize(labelText))
            local ctrl
            if isfunction(fieldType) then
                local options, mode = fieldType()
                if mode == "combo" then
                    ctrl = vgui.Create("DComboBox", panel)
                    for _, opt in ipairs(options) do
                        ctrl:AddChoice(opt)
                    end
                end
            elseif fieldType == "player" then
                ctrl = vgui.Create("DComboBox", panel)
                ctrl:SetValue("Select Player")
                for _, plyObj in ipairs(player.GetAll()) do
                    if IsValid(plyObj) then ctrl:AddChoice(plyObj:Name(), plyObj:SteamID()) end
                end
            elseif fieldType == "text" or fieldType == "number" then
                ctrl = vgui.Create("DTextEntry", panel)
                ctrl:SetFont("liaSmallFont")
                if fieldType == "number" and ctrl.SetNumeric then ctrl:SetNumeric(true) end
            elseif fieldType == "boolean" then
                ctrl = vgui.Create("DCheckBox", panel)
            end

            local label = vgui.Create("DLabel", panel)
            label:SetFont("liaSmallFont")
            label:SetText(labelText)
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
                if ctrl.OnValueChange then
                    local old = ctrl.OnValueChange
                    function ctrl:OnValueChange(...)
                        if old then old(self, ...) end
                        validate()
                    end
                elseif ctrl.OnTextChanged then
                    local old = ctrl.OnTextChanged
                    function ctrl:OnTextChanged(...)
                        if old then old(self, ...) end
                        validate()
                    end
                elseif ctrl.OnChange then
                    local old = ctrl.OnChange
                    function ctrl:OnChange(...)
                        if old then old(self, ...) end
                        validate()
                    end
                elseif ctrl.OnSelect then
                    local old = ctrl.OnSelect
                    function ctrl:OnSelect(...)
                        if old then old(self, ...) end
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
        local submit = vgui.Create("DButton", buttons)
        submit:Dock(LEFT)
        submit:DockMargin(0, 0, 15, 0)
        submit:SetWide(270)
        submit:SetText(L("submit"))
        submit:SetFont("liaSmallFont")
        submit:SetIcon("icon16/tick.png")
        submit:SetEnabled(false)
        local function validate()
            for _, data in pairs(controls) do
                if not data.optional then
                    local ctl = data.ctrl
                    local ftype = data.type
                    local filled = false
                    if isfunction(ftype) or ftype == "player" then
                        local txt, _ = ctl:GetSelected()
                        filled = txt ~= nil and txt ~= ""
                    elseif ftype == "text" or ftype == "number" then
                        filled = ctl:GetValue() ~= nil and ctl:GetValue() ~= ""
                    elseif ftype == "boolean" then
                        filled = true
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
        submit.DoClick = function()
            local args = {}
            for key, field in pairs(fields) do
                local ctlData = controls[key]
                local ctl = ctlData.ctrl
                local ftype = field.type
                if isfunction(ftype) or ftype == "player" then
                    local txt, data = ctl:GetSelected()
                    if txt and txt ~= "" then args[#args + 1] = data or txt end
                elseif ftype == "text" or ftype == "number" then
                    local val = ctl:GetValue()
                    if val ~= "" or not field.optional then args[#args + 1] = val end
                elseif ftype == "boolean" then
                    args[#args + 1] = ctl:GetChecked() and "1" or "0"
                end
            end

            if prefix then
                if istable(prefix) then
                    for i = #prefix, 1, -1 do
                        table.insert(args, 1, prefix[i])
                    end
                else
                    table.insert(args, 1, prefix)
                end
            end

            local cmd = "/" .. cmdKey
            for _, v in ipairs(args) do
                cmd = cmd .. " " .. tostring(v)
            end

            ply:ConCommand("say " .. cmd)
            frame:Remove()
            AdminStickIsOpen = false
        end

        local cancel = vgui.Create("DButton", buttons)
        cancel:Dock(RIGHT)
        cancel:SetWide(270)
        cancel:SetText(L("cancel"))
        cancel:SetFont("liaSmallFont")
        cancel:SetIcon("icon16/cross.png")
        cancel.DoClick = function()
            frame:Remove()
            AdminStickIsOpen = false
        end
    end

    function lia.command.send(command, ...)
        net.Start("cmd")
        net.WriteString(command)
        net.WriteTable({...})
        net.SendToServer()
    end
end

hook.Add("CreateInformationButtons", "liaInformationCommands", function(pages)
    local client = LocalPlayer()
    table.insert(pages, {
        name = L("commands"),
        drawFunc = function(panel)
            local searchEntry = vgui.Create("DTextEntry", panel)
            searchEntry:Dock(TOP)
            searchEntry:SetTall(30)
            searchEntry:SetPlaceholderText(L("searchCommands"))
            local scroll = vgui.Create("DScrollPanel", panel)
            scroll:Dock(FILL)
            local iconLayout = vgui.Create("DIconLayout", scroll)
            iconLayout:Dock(FILL)
            iconLayout:SetSpaceY(5)
            iconLayout:SetSpaceX(5)
            iconLayout.PerformLayout = function(self)
                local y = 0
                local w = self:GetWide()
                for _, child in ipairs(self:GetChildren()) do
                    child:SetPos((w - child:GetWide()) * 0.5, y)
                    y = y + child:GetTall() + self:GetSpaceY()
                end

                self:SetTall(y)
            end

            local function refresh()
                iconLayout:Clear()
                local filter = searchEntry:GetValue():lower()
                for cmdName, cmdData in SortedPairs(lia.command.list) do
                    if isnumber(cmdName) then continue end
                    local nameLower = cmdName:lower()
                    local descLower = (cmdData.desc or ""):lower()
                    local syntaxLower = (cmdData.syntax or ""):lower()
                    if filter ~= "" and not (nameLower:find(filter) or descLower:find(filter) or syntaxLower:find(filter)) then continue end
                    local hasAccess, privilege = lia.command.hasAccess(client, cmdName, cmdData)
                    if not hasAccess then continue end
                    local hasDesc = cmdData.desc and cmdData.desc ~= ""
                    local height = hasDesc and 80 or 40
                    local commandPanel = vgui.Create("DPanel", iconLayout)
                    commandPanel:SetSize(panel:GetWide(), height)
                    commandPanel.Paint = function(self, w, h)
                        derma.SkinHook("Paint", "Panel", self, w, h)
                        local baseX = 20
                        local text = "/" .. cmdName
                        if cmdData.syntax and cmdData.syntax ~= "" then text = text .. " " .. cmdData.syntax end
                        if hasDesc then
                            draw.SimpleText(text, "liaMediumFont", baseX, 5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                            draw.SimpleText(cmdData.desc, "liaSmallFont", baseX, 45, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                            draw.SimpleText(privilege or L("none"), "liaSmallFont", w - 20, 45, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
                        else
                            draw.SimpleText(text, "liaMediumFont", baseX, h * 0.5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                            draw.SimpleText(privilege or L("none"), "liaSmallFont", w - 20, h * 0.5, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
                        end
                    end
                end

                iconLayout:InvalidateLayout(true)
            end

            searchEntry.OnTextChanged = refresh
            refresh()
        end
    })
end)

lia.command.findPlayer = lia.util.findPlayer