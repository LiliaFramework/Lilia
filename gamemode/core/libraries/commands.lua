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
                MinAccess = superAdminOnly and "superadmin" or "admin",
                Description = data.description
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

    if hook.Run("CanPlayerUseCommand", client, command) == false then hasAccess = false end
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
    if not syntax or syntax == "" then return fields end
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
            end
        else
            name = inner
            typ = "text"
        end

        fields[#fields + 1] = {
            name = name,
            type = typ
        }
    end
    return fields
end

-- Combines arguments split within brackets back into a single token.
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
                local fields = lia.command.parseSyntaxFields(command.syntax)
                if IsValid(client) and client:IsPlayer() and #fields > 0 then
                    local tokens = combineBracketArgs(arguments)
                    local missing = {}
                    local prefix = {}
                    for i, field in ipairs(fields) do
                        local arg = tokens[i]
                        if not arg or isPlaceholder(arg) then
                            missing[field.name] = field.type
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
        local player = LocalPlayer()
        local frame = vgui.Create("DFrame")
        frame:SetTitle(L(cmdKey))
        frame:SetSize(500, 150 + table.Count(fields) * 40 + 100)
        frame:Center()
        frame:MakePopup()
        frame:ShowCloseButton(false)
        local y = 40
        local inputs = {}
        for name, typ in pairs(fields) do
            local label = vgui.Create("DLabel", frame)
            label:SetPos(25, y)
            label:SetSize(150, 30)
            label:SetFont("DermaDefaultBold")
            label:SetText(L(name))
            if isfunction(typ) then
                local opts, mode = typ()
                if mode == "combo" then
                    local combo = vgui.Create("DComboBox", frame)
                    combo:SetPos(100, y)
                    combo:SetSize(300, 30)
                    for _, option in ipairs(opts) do
                        combo:AddChoice(option)
                    end

                    inputs[name] = combo
                end
            elseif typ == "text" or typ == "number" then
                local textEntry = vgui.Create("DTextEntry", frame)
                textEntry:SetPos(100, y)
                textEntry:SetSize(300, 30)
                textEntry:SetFont("DermaDefault")
                textEntry:SetPaintBackground(true)
                if typ == "number" and textEntry.SetNumeric then textEntry:SetNumeric(true) end
                inputs[name] = textEntry
            elseif typ == "boolean" then
                local checkBox = vgui.Create("DCheckBox", frame)
                checkBox:SetPos(100, y + 5)
                inputs[name] = checkBox
            end

            y = y + 40
        end

        local submitButton = vgui.Create("DButton", frame)
        submitButton:SetText(L("submit"))
        submitButton:SetPos(100, frame:GetTall() - 70)
        submitButton:SetSize(150, 50)
        submitButton:SetFont("DermaDefaultBold")
        submitButton:SetColor(Color(255, 255, 255))
        submitButton:SetMaterial("icon16/tick.png")
        submitButton.DoClick = function()
            local args = {}
            for key, typ in pairs(fields) do
                local value
                if isfunction(typ) then
                    value = inputs[key]:GetSelected()
                elseif typ == "text" or typ == "number" then
                    value = inputs[key]:GetValue()
                elseif typ == "boolean" then
                    value = inputs[key]:GetChecked() and "1" or "0"
                end

                table.insert(args, value)
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
            for _, arg in ipairs(args) do
                cmd = cmd .. " " .. arg
            end

            player:ConCommand("say " .. cmd)
            frame:Remove()
            AdminStickIsOpen = false
        end

        local cancelButton = vgui.Create("DButton", frame)
        cancelButton:SetText(L("cancel"))
        cancelButton:SetPos(250, frame:GetTall() - 70)
        cancelButton:SetSize(150, 50)
        cancelButton:SetFont("DermaDefaultBold")
        cancelButton:SetColor(Color(255, 255, 255))
        cancelButton:SetMaterial("icon16/cross.png")
        cancelButton.DoClick = function()
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
                    commandPanel.Paint = function(panel, w, h)
                        derma.SkinHook("Paint", "Panel", panel, w, h)
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