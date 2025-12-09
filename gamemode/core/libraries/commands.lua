--[[
    Commands Library

    Comprehensive command registration, parsing, and execution system for the Lilia framework.
]]
--[[
    Overview:
        The commands library provides comprehensive functionality for managing and executing commands in the Lilia framework. It handles command registration, argument parsing, access control, privilege management, and command execution across both server and client sides. The library supports complex argument types including players, booleans, strings, and tables, with automatic syntax generation and validation. It integrates with the administrator system for privilege-based access control and provides user interface elements for command discovery and argument prompting. The library ensures secure command execution with proper permission checks and logging capabilities.
]]
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
            Category = "staffPermissions"
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
                    return "@noPerm"
                end
            end
        end

        if accessResult == nil then accessResult, privilegeName = lia.command.hasAccess(client, command, data) end
        if accessResult then
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

    hook.Run("CommandAdded", command, data)
end

function lia.command.hasAccess(client, command, data)
    if not data then data = lia.command.list[command] end
    if not data then return false, "unknown" end
    local privilegeID = data.privilege or string.lower("command_" .. command)
    local superAdminOnly = data.superAdminOnly
    local adminOnly = data.adminOnly
    local accessLevels = superAdminOnly and "superadmin" or adminOnly and "admin" or "user"
    local privilegeName = data.privilege and L(data.privilege) or accessLevels == "user" and L("globalAccess") or L("accessTo", command)
    if data.onCheckAccess then
        local accessResult, customPrivilegeName = data.onCheckAccess(client, command, data)
        if accessResult ~= nil then return accessResult, customPrivilegeName or privilegeName end
    end

    local hasAccess = true
    if accessLevels ~= "user" then
        if not isstring(privilegeID) then
            lia.error(L("invalidPrivilegeIDType"))
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
            hook.Run("CommandRan", client, command, arguments or {}, results)
            local result = results[1]
            if isstring(result) then
                if IsValid(client) then
                    if result:sub(1, 1) == "@" then
                        client:notifyInfoLocalized(result:sub(2), unpack(results, 2))
                    else
                        client:notifyErrorLocalized(result)
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
                    if IsValid(client) then client:notifyErrorLocalized("noAccess") end
                    return true
                end

                if not arguments then arguments = lia.command.extractArgs(text:sub(#match + 3)) end
                local fields = command.arguments or {}
                if IsValid(client) and client:IsPlayer() and #fields > 0 then
                    local tokens = combineBracketArgs(arguments)
                    local missing = {}
                    local prefix = {}
                    local firstMissingIndex
                    for i, field in ipairs(fields) do
                        local arg = tokens[i]
                        local isMissing = not arg or isPlaceholder(arg)
                        if isMissing then
                            if not firstMissingIndex then firstMissingIndex = i end
                            if (not field.optional) or (i >= firstMissingIndex) then missing[#missing + 1] = field.name end
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
                    client:notifyErrorLocalized("cmdNoExist")
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
        local frameW, frameH = 600, math.min(450 + numFields * 135, ScrH() * 0.5)
        local frame = vgui.Create("liaFrame")
        frame:SetTitle("")
        frame:SetCenterTitle(L(cmdKey))
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
                local textW = select(1, surface.GetTextSize(L(data.description or name)))
                local ctrl
                if fieldType == "player" then
                    ctrl = vgui.Create("liaComboBox", panel)
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

                    ctrl:FinishAddingOptions()
                    ctrl:PostInit()
                elseif fieldType == "table" then
                    ctrl = vgui.Create("liaComboBox", panel)
                    ctrl:SetValue(L("select") .. " " .. L(name))
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
                label:SetText(L(data.description or name))
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
        submit:SetTxt(L("submit"))
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
        cancel:SetTxt(L("cancel"))
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

hook.Add("CreateInformationButtons", "liaInformationCommandsUnified", function(pages)
    local client = LocalPlayer()
    table.insert(pages, {
        name = "commands",
        drawFunc = function(parent)
            parent:Clear()
            local sheet = vgui.Create("liaSheet", parent)
            sheet:Dock(FILL)
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
if SERVER then
    concommand.Add("kickbots", function()
        for _, bot in player.Iterator() do
            if bot:IsBot() then lia.administrator.execCommand("kick", bot, nil, L("allBotsKicked")) end
        end
    end)

    concommand.Add("lia_check_updates", function(client)
        if IsValid(client) and not client:IsSuperAdmin() then
            client:notifyErrorLocalized("staffPermissionDenied")
            return
        end

        MsgC(Color(83, 143, 239), "[Lilia] ", Color(255, 255, 255), L("checkingForUpdates") .. "\n")
        lia.loader.checkForUpdates()
    end)

    concommand.Add("plysetgroup", function(ply, _, args)
        local target = lia.util.findPlayer(ply, args[1])
        local usergroup = args[2]
        if not IsValid(ply) or not game.IsDedicated() then
            if IsValid(target) then
                if lia.administrator.groups[usergroup] then
                    target.liaUserGroup = usergroup
                    target:notifyInfoLocalized("userGroupSet", usergroup)
                    lia.log.add(nil, "usergroup", target, usergroup)
                    MsgC(Color(0, 255, 0), "[Lilia] ", Color(255, 255, 255), "Set " .. target:getName() .. " (" .. target:SteamID() .. ") to usergroup: " .. usergroup .. "\n")
                else
                    MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), L("invalidUsergroup") .. " \"" .. usergroup .. "\"\n")
                end
            else
                MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), L("invalidPlayer") .. " \"" .. args[1] .. "\"\n")
            end
        elseif ply:hasPrivilege("setUserGroup") then
            if IsValid(target) then
                if lia.administrator.groups[usergroup] then
                    target.liaUserGroup = usergroup
                    target:notifyInfoLocalized("userGroupSet", usergroup)
                    ply:notifyInfoLocalized("userGroupSetBy", target:getName(), usergroup)
                    lia.log.add(ply, "usergroup", target, usergroup)
                    MsgC(Color(0, 255, 0), "[Lilia] ", Color(255, 255, 255), "Set " .. target:getName() .. " (" .. target:SteamID() .. ") to usergroup: " .. usergroup .. "\n")
                else
                    ply:notifyErrorLocalized("invalidUsergroup" .. " \"" .. usergroup .. "\"")
                end
            else
                ply:notifyErrorLocalized("plyNoExist")
            end
        else
            ply:notifyErrorLocalized("noPerm")
        end
    end)

    concommand.Add("stopsoundall", function(client)
        if client:hasPrivilege("stopSoundForEveryone") then
            for _, v in player.Iterator() do
                v:ConCommand("stopsound")
            end
        else
            client:notifyErrorLocalized("noPerm")
        end
    end)

    concommand.Add("bots", function()
        timer.Create("Bots_Add_Timer", 2, 0, function()
            if player.GetCount() < game.MaxPlayers() then
                game.ConsoleCommand("bot\n")
            else
                timer.Remove("Bots_Add_Timer")
            end
        end)
    end)

    concommand.Add("lia_wipedb", function(client)
        if IsValid(client) then
            client:notifyErrorLocalized("commandConsoleOnly")
            return
        end

        lia.db.wipeTables(function()
            lia.information(L("dbWiped"))
            lia.db.loadTables()
            hook.Add("PostLoadData", "lia_wipedb_changemap", function()
                hook.Remove("PostLoadData", "lia_wipedb_changemap")
                timer.Simple(2.5, function()
                    lia.information("Database wipe complete. Changing map...")
                    RunConsoleCommand("changelevel", game.GetMap())
                end)
            end)
        end)
    end)

    concommand.Add("lia_resetconfig", function(client)
        if IsValid(client) then
            client:notifyErrorLocalized("commandConsoleOnly")
            return
        end

        lia.config.load(true)
        lia.information(L("configReloaded"))
    end)

    concommand.Add("lia_wipecharacters", function(client)
        if IsValid(client) then
            client:notifyErrorLocalized("commandConsoleOnly")
            return
        end

        lia.db.wipeCharacters()
        lia.information(L("charsWiped"))
    end)

    concommand.Add("lia_wipelogs", function(client)
        if IsValid(client) then
            client:notifyErrorLocalized("commandConsoleOnly")
            return
        end

        lia.db.wipeLogs()
        lia.information(L("logsWiped"))
    end)

    concommand.Add("lia_wipebans", function(client)
        if IsValid(client) then
            client:notifyErrorLocalized("commandConsoleOnly")
            return
        end

        lia.db.wipeBans()
        lia.information(L("bansWiped"))
    end)

    concommand.Add("lia_wipepersistence", function(client)
        if IsValid(client) then
            client:notifyErrorLocalized("commandConsoleOnly")
            return
        end

        lia.data.deleteAll()
        lia.information(L("persistenceWiped"))
    end)

    concommand.Add("lia_wipeconfig", function(client)
        if IsValid(client) then
            client:notifyErrorLocalized("commandConsoleOnly")
            return
        end

        lia.config.reset()
        lia.information(L("configWiped"))
    end)

    concommand.Add("list_entities", function(client)
        local entityCount = {}
        local totalEntities = 0
        if not IsValid(client) then
            lia.information(L("entitiesOnServer") .. ":")
            for _, entity in ents.Iterator() do
                local class = entity:GetClass()
                entityCount[class] = (entityCount[class] or 0) + 1
                totalEntities = totalEntities + 1
            end

            for class, count in SortedPairs(entityCount) do
                MsgC(Color(83, 143, 239), "[Lilia] ", Color(255, 255, 255), class .. ": " .. count .. "\n")
            end

            MsgC(Color(83, 143, 239), "[Lilia] ", Color(255, 255, 255), L("totalEntities", totalEntities) .. "\n")
        else
            client:notifyErrorLocalized("commandConsoleOnly")
        end
    end)

    concommand.Add("lia_database_list", function(ply)
        if IsValid(ply) then return end
        lia.db.getCharacterTable(function(columns)
            if #columns == 0 then
                lia.error(L("dbColumnsNone"))
            else
                lia.information(L("dbColumnsList", #columns))
                for _, column in ipairs(columns) do
                    MsgC(Color(83, 143, 239), "[Lilia] ", Color(255, 255, 255), column .. "\n")
                end
            end
        end)
    end)

    concommand.Add("lia_fix_characters", function(client)
        if IsValid(client) then
            client:notifyErrorLocalized("commandConsoleOnly")
            return
        end

        lia.db.fixCharacters()
        lia.information(L("charsFixed"))
    end)

    concommand.Add("lia_redownload_assets", function(client)
        if IsValid(client) then
            client:notifyErrorLocalized("commandConsoleOnly")
            return
        end

        lia.loader.downloadAssets()
        lia.information(L("assetsRedownloaded"))
    end)

    concommand.Add("test_existing_notifications", function(client)
        if IsValid(client) then
            client:notifyErrorLocalized("commandConsoleOnly")
            return
        end

        lia.notices.notifyLocalized("testNotification")
        lia.notices.notifyInfoLocalized("testNotificationInfo")
        lia.notices.notifyWarningLocalized("testNotificationWarning")
        lia.notices.notifyErrorLocalized("testNotificationError")
        lia.notices.notifySuccessLocalized("testNotificationSuccess")
    end)

    concommand.Add("print_vector", function(client)
        if not IsValid(client) then
            MsgC(Color(255, 0, 0), "[Lilia] " .. L("errorPrefix") .. L("commandCanOnlyBeUsedByPlayers") .. "\n")
            return
        end

        local pos = client:GetPos()
        local vec = Vector(pos.x, pos.y, pos.z)
        MsgC(Color(83, 143, 239), "[Lilia] ", Color(255, 255, 255), L("vector") .. ": " .. tostring(vec) .. "\n")
    end)

    concommand.Add("print_angle", function(client)
        if not IsValid(client) then
            MsgC(Color(255, 0, 0), "[Lilia] " .. L("errorPrefix") .. L("commandCanOnlyBeUsedByPlayers") .. "\n")
            return
        end

        local ang = client:GetAngles()
        MsgC(Color(83, 143, 239), "[Lilia] ", Color(255, 255, 255), "Angle: " .. tostring(ang) .. "\n")
    end)

    concommand.Add("workshop_force_redownload", function()
        table.Empty(queue)
        buildQueue(true)
        start()
    end)

    concommand.Add("lia_snapshot", function(_, _, args)
        if not args[1] then
            MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), L("snapshotTableUsage") .. "\n")
            return
        end

        local tableName = args[1]
        MsgC(Color(83, 143, 239), "[Lilia] ", Color(255, 255, 255), L("creatingSnapshot", tableName) .. "\n")
        lia.db.createSnapshot(tableName):next(function(snapshot)
            MsgC(Color(0, 255, 0), "[Lilia] ", Color(255, 255, 255), L("snapshotCreated") .. "\n")
            MsgC(Color(83, 143, 239), "[Lilia] ", Color(255, 255, 255), L("snapshotRecords", snapshot.records) .. "\n")
            MsgC(Color(83, 143, 239), "[Lilia] ", Color(255, 255, 255), L("snapshotPath", snapshot.path) .. "\n")
        end, function(err) MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), L("snapshotFailed", tostring(err)) .. "\n") end)
    end)

    concommand.Add("lia_snapshot_load", function(_, _, args)
        if not args[1] then
            MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), L("snapshotUsage") .. "\n")
            MsgC(Color(83, 143, 239), "[Lilia] ", Color(255, 255, 255), L("availableSnapshots") .. "\n")
            local files = file.Find("lilia/snapshots/*", "DATA")
            if #files == 0 then
                MsgC(Color(255, 165, 0), "[Lilia] ", Color(255, 255, 255), L("noSnapshotsFound") .. "\n")
            else
                for _, fileName in ipairs(files) do
                    MsgC(Color(83, 143, 239), "[Lilia] ", Color(255, 255, 255), "  - " .. fileName .. "\n")
                end
            end
            return
        end

        local fileName = args[1]
        MsgC(Color(83, 143, 239), "[Lilia] ", Color(255, 255, 255), L("loadingSnapshot", fileName) .. "\n")
        lia.db.loadSnapshot(fileName):next(function(result)
            MsgC(Color(0, 255, 0), "[Lilia] ", Color(255, 255, 255), L("snapshotLoaded") .. "\n")
            MsgC(Color(83, 143, 239), "[Lilia] ", Color(255, 255, 255), L("snapshotTable", result.table) .. "\n")
            MsgC(Color(83, 143, 239), "[Lilia] ", Color(255, 255, 255), L("snapshotRecords", result.records) .. "\n")
        end, function(err) MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), L("snapshotLoadFailed", tostring(err)) .. "\n") end)
    end)

    concommand.Add("lia_wipetable", function(_, _, args)
        if not args[1] then
            MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), L("wipeTableUsage") .. "\n")
            return
        end

        local tableName = args[1]
        local fullTableName = "lia_" .. tableName
        MsgC(Color(255, 165, 0), "[Lilia] ", Color(255, 255, 255), L("creatingBackupBeforeWipe", tableName) .. "\n")
        lia.db.createSnapshot(tableName):next(function(snapshot)
            MsgC(Color(83, 143, 239), "[Lilia] ", Color(255, 255, 255), L("backupCreated", snapshot.file) .. "\n")
            MsgC(Color(255, 165, 0), "[Lilia] ", Color(255, 255, 255), L("wipingTable", fullTableName) .. "\n")
            lia.db.query("DELETE FROM " .. fullTableName, function() MsgC(Color(0, 255, 0), "[Lilia] ", Color(255, 255, 255), L("tableWiped", fullTableName) .. "\n") end, function(err) MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), L("tableWipeFailed", tostring(err)) .. "\n") end)
        end, function(err) MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), L("backupFailedAbortingWipe", tostring(err)) .. "\n") end)
    end)
else
    concommand.Add("weighpoint_stop", function() hook.Remove("HUDPaint", "WeighPoint") end)
    concommand.Add("lia_vgui_cleanup", function()
        for _, v in pairs(vgui.GetWorldPanel():GetChildren()) do
            if not (v.Init and debug.getinfo(v.Init, "Sln").short_src:find("chatbox")) then v:Remove() end
        end
    end)

    local function performPanelCheck()
        local function enumeratePanels(panel, depth)
            depth = depth or 0
            local children = panel:GetChildren()
            local count = 0
            for _, child in ipairs(children) do
                if IsValid(child) then
                    count = count + 1
                    count = count + enumeratePanels(child, depth + 1)
                end
            end
            return count
        end

        local function collectPanelData(panel, panelTypes, hiddenPanelTypes, depth)
            depth = depth or 0
            local children = panel:GetChildren()
            for _, child in ipairs(children) do
                if IsValid(child) then
                    local panelType = child:GetName() or "Unknown"
                    if child:IsVisible() then
                        panelTypes[panelType] = (panelTypes[panelType] or 0) + 1
                    else
                        hiddenPanelTypes[panelType] = (hiddenPanelTypes[panelType] or 0) + 1
                    end

                    collectPanelData(child, panelTypes, hiddenPanelTypes, depth + 1)
                end
            end
        end

        local worldPanel = vgui.GetWorldPanel()
        local panelCount = enumeratePanels(worldPanel)
        local visiblePanels = 0
        local panelTypes = {}
        local hiddenPanelTypes = {}
        collectPanelData(worldPanel, panelTypes, hiddenPanelTypes)
        for _, count in pairs(panelTypes) do
            visiblePanels = visiblePanels + count
        end

        LocalPlayer():ChatPrint("Total panels on screen (including subpanels): " .. panelCount)
        LocalPlayer():ChatPrint("Visible panels: " .. visiblePanels)
        if table.Count(panelTypes) > 0 then
            LocalPlayer():ChatPrint("Visible panel types:")
            for panelType, count in pairs(panelTypes) do
                LocalPlayer():ChatPrint("  " .. panelType .. ": " .. count)
            end
        end

        LocalPlayer():ChatPrint("Hidden panels: " .. (panelCount - visiblePanels))
        if table.Count(hiddenPanelTypes) > 0 then
            LocalPlayer():ChatPrint("Hidden panel types:")
            for panelType, count in pairs(hiddenPanelTypes) do
                LocalPlayer():ChatPrint("  " .. panelType .. ": " .. count)
            end
        end
    end

    concommand.Add("lia_test_panels", function(_, _, args)
        local delay = tonumber(args[1]) or 0
        if delay > 0 then
            LocalPlayer():ChatPrint("Checking panels in " .. delay .. " seconds...")
            timer.Simple(delay, function()
                if not IsValid(LocalPlayer()) then return end
                performPanelCheck()
            end)
        else
            performPanelCheck()
        end
    end)

    concommand.Add("lia_saved_sounds", function()
        local baseDir = "lilia/websounds/"
        local files = file.Find(baseDir .. "**", "DATA")
        local soundFiles = {}
        if files then
            for _, fileName in ipairs(files) do
                if string.EndsWith(fileName, ".mp3") or string.EndsWith(fileName, ".wav") or string.EndsWith(fileName, ".ogg") then table.insert(soundFiles, fileName) end
            end
        end

        if #soundFiles == 0 then
            LocalPlayer():ChatPrint("No saved sounds found!")
            return
        end

        local f = vgui.Create("liaFrame")
        f:SetTitle(L("savedSounds"))
        f:SetSize(600, 500)
        f:Center()
        f:MakePopup()
        local scroll = vgui.Create("liaScrollPanel", f)
        scroll:Dock(FILL)
        scroll:DockMargin(5, 5, 5, 5)
        for _, fileName in ipairs(soundFiles) do
            local soundName = string.StripExtension(fileName)
            local soundPath = baseDir .. fileName
            local panel = vgui.Create("DPanel", scroll)
            panel:Dock(TOP)
            panel:SetTall(40)
            panel:DockMargin(2, 2, 2, 2)
            panel.Paint = function(_, w, h)
                surface.SetDrawColor(60, 60, 60, 200)
                surface.DrawRect(0, 0, w, h)
                surface.SetDrawColor(100, 100, 100, 100)
                surface.DrawOutlinedRect(0, 0, w, h)
            end

            local nameLabel = vgui.Create("DLabel", panel)
            nameLabel:SetText(soundName)
            nameLabel:SetFont("LiliaFont.17")
            nameLabel:SetTextColor(Color(255, 255, 255))
            nameLabel:Dock(LEFT)
            nameLabel:DockMargin(10, 0, 0, 0)
            nameLabel:SetWide(300)
            local playButton = vgui.Create("liaButton", panel)
            playButton:SetText("▶ Play")
            playButton:SetWide(80)
            playButton:Dock(RIGHT)
            playButton:DockMargin(5, 5, 5, 5)
            playButton.DoClick = function()
                if file.Exists(soundPath, "DATA") then
                    local fullPath = "data/" .. soundPath
                    timer.Simple(0.1, function()
                        sound.PlayFile(fullPath, "", function(channel, _, errorString)
                            if IsValid(channel) then
                                LocalPlayer():ChatPrint("Playing: " .. soundName)
                            else
                                LocalPlayer():ChatPrint("Failed to play: " .. soundName .. " (" .. (errorString or "unknown error") .. ")")
                            end
                        end)
                    end)
                else
                    LocalPlayer():ChatPrint("Sound file not found: " .. soundName)
                end
            end

            local stopButton = vgui.Create("liaButton", panel)
            stopButton:SetText("⏹ Stop")
            stopButton:SetWide(80)
            stopButton:Dock(RIGHT)
            stopButton:DockMargin(5, 5, 5, 5)
            stopButton.DoClick = function()
                timer.Simple(0.1, function()
                    sound.PlayFile("", "", function() end)
                    LocalPlayer():ChatPrint("Stopped all sounds")
                end)
            end
        end
    end)

    concommand.Add("lia_wipe_sounds", function()
        local baseDir = "lilia/websounds/"
        local files = file.Find(baseDir .. "**", "DATA")
        local deletedCount = 0
        for _, fn in ipairs(files) do
            if string.EndsWith(fn, ".mp3") or string.EndsWith(fn, ".wav") or string.EndsWith(fn, ".ogg") or string.EndsWith(fn, ".dat") then
                file.Delete(baseDir .. fn)
                deletedCount = deletedCount + 1
            end
        end

        LocalPlayer():ChatPrint(L("soundsWiped") .. " (" .. deletedCount .. " files)")
    end)

    concommand.Add("lia_validate_sounds", function()
        local baseDir = "lilia/websounds/"
        local files = file.Find(baseDir .. "**", "DATA")
        local validCount = 0
        local invalidCount = 0
        for _, fileName in ipairs(files) do
            if string.EndsWith(fileName, ".mp3") or string.EndsWith(fileName, ".wav") or string.EndsWith(fileName, ".ogg") then
                local data = file.Read(baseDir .. fileName, "DATA")
                if data and #data > 0 then
                    validCount = validCount + 1
                else
                    invalidCount = invalidCount + 1
                end
            elseif string.EndsWith(fileName, ".dat") then
                local data = file.Read(baseDir .. fileName, "DATA")
                if data then
                    local success, soundData = pcall(pon.decode, data)
                    if success and soundData then
                        validCount = validCount + 1
                    else
                        invalidCount = invalidCount + 1
                    end
                end
            end
        end

        LocalPlayer():ChatPrint(L("soundValidationComplete", validCount, invalidCount))
    end)

    concommand.Add("lia_cleanup_sounds", function()
        local baseDir = "lilia/websounds/"
        local files = file.Find(baseDir .. "**", "DATA")
        local removedCount = 0
        for _, fileName in ipairs(files) do
            if string.EndsWith(fileName, ".mp3") or string.EndsWith(fileName, ".wav") or string.EndsWith(fileName, ".ogg") then
                local data = file.Read(baseDir .. fileName, "DATA")
                if not data or #data == 0 then
                    file.Delete(baseDir .. fileName)
                    removedCount = removedCount + 1
                end
            elseif string.EndsWith(fileName, ".dat") then
                local data = file.Read(baseDir .. fileName, "DATA")
                if not data then
                    file.Delete(baseDir .. fileName)
                    removedCount = removedCount + 1
                else
                    local success, soundData = pcall(pon.decode, data)
                    if not success or not soundData then
                        file.Delete(baseDir .. fileName)
                        removedCount = removedCount + 1
                    end
                end
            end
        end

        LocalPlayer():ChatPrint(L("cleanedUpInvalidSounds", removedCount))
    end)

    concommand.Add("lia_list_sounds", function()
        local baseDir = "lilia/websounds/"
        local files = file.Find(baseDir .. "**", "DATA")
        if #files == 0 then return end
        LocalPlayer():ChatPrint(L("savedSounds"))
        for _, fileName in ipairs(files) do
            if string.EndsWith(fileName, ".mp3") or string.EndsWith(fileName, ".wav") or string.EndsWith(fileName, ".ogg") or string.EndsWith(fileName, ".dat") then LocalPlayer():ChatPrint(L("soundFileList", string.StripExtension(fileName))) end
        end
    end)

    local function findImagesRecursive(dir, result)
        result = result or {}
        local files, dirs = file.Find(dir .. "*", "DATA")
        if files then
            for _, fn in ipairs(files) do
                table.insert(result, dir .. fn)
            end
        end

        if dirs then
            for _, subdir in ipairs(dirs) do
                findImagesRecursive(dir .. subdir .. "/", result)
            end
        end
        return result
    end

    local function deleteDirectoryRecursive(dir)
        local files, dirs = file.Find(dir .. "*", "DATA")
        if files then
            for _, fn in ipairs(files) do
                file.Delete(dir .. fn)
            end
        end

        if dirs then
            for _, subdir in ipairs(dirs) do
                deleteDirectoryRecursive(dir .. subdir .. "/")
                file.Delete(dir .. subdir)
            end
        end
    end

    concommand.Add("lia_saved_images", function()
        local baseDir = "lilia/webimages/"
        local files = findImagesRecursive(baseDir)
        local imageFiles = {}
        if files then
            for _, fileName in ipairs(files) do
                if string.EndsWith(fileName, ".png") or string.EndsWith(fileName, ".jpg") or string.EndsWith(fileName, ".jpeg") then table.insert(imageFiles, fileName) end
            end
        end

        if #imageFiles == 0 then
            LocalPlayer():ChatPrint("No saved images found!")
            return
        end

        local f = vgui.Create("liaFrame")
        f:SetTitle(L("savedImages"))
        f:SetSize(700, 600)
        f:Center()
        f:MakePopup()
        local scroll = vgui.Create("liaScrollPanel", f)
        scroll:Dock(FILL)
        scroll:DockMargin(5, 5, 5, 5)
        for _, fileName in ipairs(imageFiles) do
            local imageName = string.StripExtension(fileName)
            local imagePath = baseDir .. fileName
            local panel = vgui.Create("DPanel", scroll)
            panel:Dock(TOP)
            panel:SetTall(120)
            panel:DockMargin(2, 2, 2, 2)
            panel.Paint = function(_, w, h)
                surface.SetDrawColor(60, 60, 60, 200)
                surface.DrawRect(0, 0, w, h)
                surface.SetDrawColor(100, 100, 100, 100)
                surface.DrawOutlinedRect(0, 0, w, h)
            end

            local imagePreview = vgui.Create("DImage", panel)
            imagePreview:SetPos(10, 10)
            imagePreview:SetSize(100, 100)
            imagePreview:SetImage("data/" .. imagePath)
            local nameLabel = vgui.Create("DLabel", panel)
            nameLabel:SetText(imageName)
            nameLabel:SetFont("LiliaFont.17")
            nameLabel:SetTextColor(Color(255, 255, 255))
            nameLabel:SetPos(120, 10)
            nameLabel:SetWide(300)
            local viewButton = vgui.Create("liaButton", panel)
            viewButton:SetText("👁 View")
            viewButton:SetWide(80)
            viewButton:SetPos(120, 40)
            viewButton.DoClick = function()
                local viewFrame = vgui.Create("liaFrame")
                viewFrame:SetTitle("Image Viewer - " .. imageName)
                viewFrame:SetSize(800, 600)
                viewFrame:Center()
                viewFrame:MakePopup()
                local fullImage = vgui.Create("DImage", viewFrame)
                fullImage:Dock(FILL)
                fullImage:DockMargin(10, 10, 10, 10)
                fullImage:SetImage("data/" .. imagePath)
            end

            local copyButton = vgui.Create("liaButton", panel)
            copyButton:SetText("📋 Copy Path")
            copyButton:SetWide(100)
            copyButton:SetPos(210, 40)
            copyButton.DoClick = function()
                SetClipboardText("data/" .. imagePath)
                LocalPlayer():ChatPrint("Image path copied to clipboard: data/" .. imagePath)
            end
        end
    end)

    concommand.Add("lia_cleanup_images", function()
        local baseDir = "lilia/webimages/"
        local files = findImagesRecursive(baseDir)
        local removedCount = 0
        for _, filePath in ipairs(files) do
            if not file.Exists(filePath, "DATA") then removedCount = removedCount + 1 end
        end

        LocalPlayer():ChatPrint(L("foundImageFiles", #files))
    end)

    concommand.Add("lia_wipewebimages", function()
        local baseDir = "lilia/webimages/"
        deleteDirectoryRecursive(baseDir)
        cache = {}
        urlMap = {}
        LocalPlayer():ChatPrint(L("webImagesWiped"))
    end)

    concommand.Add("test_webimage_menu", function()
        local frame = vgui.Create("liaFrame")
        frame:SetTitle(L("webImageTesterTitle"))
        frame:SetSize(500, 400)
        frame:Center()
        frame:MakePopup()
        local textEntry = vgui.Create("liaEntry", frame)
        textEntry:Dock(TOP)
        textEntry:DockMargin(5, 5, 5, 5)
        textEntry:SetPlaceholderText(L("webImageTesterURL"))
        local button = vgui.Create("liaButton", frame)
        button:Dock(TOP)
        button:DockMargin(5, 0, 5, 5)
        button:SetText(L("webImageTesterLoad"))
        local imagePanel = vgui.Create("DPanel", frame)
        imagePanel:Dock(FILL)
        imagePanel:DockMargin(5, 5, 5, 5)
        button.DoClick = function()
            local url = textEntry:GetValue()
            if url and url ~= "" then
                local img = vgui.Create("DImage", imagePanel)
                img:Dock(FILL)
                img:SetImage(url)
            end
        end
    end)

    concommand.Add("test_sound_playback", function()
        local baseDir = "lilia/websounds/"
        local files = file.Find(baseDir .. "**", "DATA")
        local soundFiles = {}
        if files then
            for _, fileName in ipairs(files) do
                if string.EndsWith(fileName, ".mp3") or string.EndsWith(fileName, ".wav") or string.EndsWith(fileName, ".ogg") then table.insert(soundFiles, fileName) end
            end
        end

        if #soundFiles > 0 then
            local testFile = soundFiles[1]
            local fullPath = "data/" .. baseDir .. testFile
            sound.PlayFile(fullPath, "", function(channel, _, errorString)
                if IsValid(channel) then
                    LocalPlayer():ChatPrint("Direct test successful: " .. testFile)
                else
                    LocalPlayer():ChatPrint("Direct test failed: " .. testFile .. " (" .. (errorString or "unknown error") .. ")")
                end
            end)
        else
            LocalPlayer():ChatPrint("No sound files found for testing")
        end
    end)

    concommand.Add("test_saved_commands", function()
        local baseDir = "lilia/websounds/"
        local files = file.Find(baseDir .. "**", "DATA")
        local soundFiles = {}
        if files then
            for _, fileName in ipairs(files) do
                if string.EndsWith(fileName, ".mp3") or string.EndsWith(fileName, ".wav") or string.EndsWith(fileName, ".ogg") or string.EndsWith(fileName, ".dat") then table.insert(soundFiles, fileName) end
            end
        end

        for i, fileName in ipairs(soundFiles) do
            LocalPlayer():ChatPrint("  " .. i .. ": " .. fileName)
        end

        local baseDir2 = "lilia/webimages/"
        local files2 = file.Find(baseDir2 .. "**", "DATA")
        local imageFiles = {}
        if files2 then
            for _, fileName in ipairs(files2) do
                if string.EndsWith(fileName, ".png") or string.EndsWith(fileName, ".jpg") or string.EndsWith(fileName, ".jpeg") then table.insert(imageFiles, fileName) end
            end
        end

        for i, fileName in ipairs(imageFiles) do
            LocalPlayer():ChatPrint("  " .. i .. ": " .. fileName)
        end
    end)

    concommand.Add("printpos", function(client)
        if not IsValid(client) then
            MsgC(Color(255, 0, 0), "[Lilia] " .. L("errorPrefix") .. L("commandCanOnlyBeUsedByPlayers") .. "\n")
            return
        end

        local pos = client:GetPos()
        local ang = client:GetAngles()
        MsgC(Color(255, 255, 255), "Vector = (" .. math.Round(pos.x, 2) .. ", " .. math.Round(pos.y, 2) .. ", " .. math.Round(pos.z, 2) .. "), \nAngle = (" .. math.Round(ang.x, 2) .. ", " .. math.Round(ang.y, 2) .. ", " .. math.Round(ang.z, 2) .. ")\n")
    end)

    concommand.Add("debugFactionMaps", function(client, _, args)
        if not IsValid(client) then
            MsgC(Color(255, 0, 0), "[Lilia] " .. L("errorPrefix") .. L("commandCanOnlyBeUsedByPlayers") .. "\n")
            return
        end

        local factionName = args[1]
        if not factionName then
            MsgC(Color(255, 193, 7), "[Lilia] " .. L("debugFactionMapsUsage") .. "\n")
            return
        end

        local faction = nil
        for _, f in pairs(lia.faction.teams) do
            if string.lower(f.name) == string.lower(factionName) then
                faction = f
                break
            end
        end

        if not faction then
            MsgC(Color(255, 0, 0), "[Lilia] " .. L("factionNotFound") .. "\n")
            return
        end

        MsgC(Color(0, 255, 0), "[Lilia] " .. L("debugFactionInfo", faction.name) .. "\n")
        MsgC(Color(255, 255, 0), "Current map: " .. game.GetMap() .. "\n")
        if not faction.mainMenuPosition then
            MsgC(Color(255, 0, 0), L("noMainMenuPosition") .. "\n")
            return
        end

        if isvector(faction.mainMenuPosition) then
            MsgC(Color(0, 255, 0), "Simple vector position: " .. tostring(faction.mainMenuPosition) .. "\n")
        elseif istable(faction.mainMenuPosition) then
            MsgC(Color(0, 255, 0), L("mapSpecificPositions") .. "\n")
            for mapName, posData in pairs(faction.mainMenuPosition) do
                local isCurrentMap = mapName == lia.data.getEquivalencyMap(game.GetMap())
                local mapColor = isCurrentMap and Color(0, 255, 0) or Color(255, 255, 255)
                MsgC(mapColor, "  " .. (isCurrentMap and ">>> " or "    ") .. mapName .. ":\n")
                if istable(posData) then
                    MsgC(mapColor, "    " .. L("position") .. ": " .. tostring(posData.position or posData) .. "\n")
                    if posData.angles then MsgC(mapColor, "    " .. L("angles") .. ": " .. tostring(posData.angles) .. "\n") end
                elseif isvector(posData) then
                    MsgC(mapColor, "    " .. L("position") .. ": " .. tostring(posData) .. "\n")
                end
            end
        end
    end)
end

lia.command.add("demorequests", {
    desc = "demoRequestsDesc",
    privilege = "Staff",
    onRun = function(client)
        if SERVER then
            client:notifyInfoLocalized("openingDemo")
            client:requestBinaryQuestion("UI Demo", L("demoQuestion"), L("yesShowMe"), L("noThanks"), function(confirmed)
                if confirmed then
                    client:requestDropdown(L("demoDropdownTitle"), L("chooseColor"), {{"Red", "red"}, {"Blue", "blue"}, {"Green", "green"}, {"Yellow", "yellow"}}, function(selected)
                        if selected ~= nil then
                            client:requestOptions(L("demoOptionsTitle"), L("selectFavoriteActivities"), {{"Gaming", "gaming"}, {"Reading", "reading"}, {"Sports", "sports"}, {"Music", "music"}, {"Cooking", "cooking"}, {"Travel", "travel"}}, 3, function(selectedOptions)
                                if selectedOptions and #selectedOptions > 0 then
                                    client:requestString(L("demoTextInputTitle"), L("enterFunMessage"), function(message)
                                        if message then
                                            client:requestArguments(L("demoStructuredTitle"), {
                                                {"Name", "string"},
                                                {
                                                    "Age",
                                                    {
                                                        "number",
                                                        {
                                                            min = 1,
                                                            max = 150
                                                        }
                                                    }
                                                },
                                                {L("favoriteColor"), {"table", {{"Red", "red"}, {"Blue", "blue"}, {"Green", "green"}}}},
                                                {L("agreeToTerms"), "boolean"}
                                            }, function(success, argumentsData)
                                                if success and argumentsData then
                                                    client:requestButtons(L("demoButtonSelection"), {
                                                        {
                                                            text = L("saveProgress"),
                                                            icon = "icon16/disk.png"
                                                        },
                                                        {
                                                            text = L("loadPrevious"),
                                                            icon = "icon16/folder.png"
                                                        },
                                                        {
                                                            text = L("startOver"),
                                                            icon = "icon16/arrow_refresh.png"
                                                        },
                                                        {
                                                            text = L("exitDemo"),
                                                            icon = "icon16/door.png"
                                                        }
                                                    }, function(_, buttonText) client:notify(L("demoCompleted") .. " " .. buttonText, "success") end, L("chooseNextAction"))
                                                else
                                                    client:notifyWarningLocalized("argumentsDemoCancelled")
                                                end
                                            end, {
                                                Name = L("demoUser"),
                                                Age = 25,
                                                [L("favoriteColor")] = {"Blue", "blue"},
                                                [L("agreeToTerms")] = true
                                            })
                                        else
                                            client:notifyWarningLocalized("stringInputDemoCancelled")
                                        end
                                    end, "", 50)
                                else
                                    client:notifyWarningLocalized("optionsDemoCancelled")
                                end
                            end)
                        else
                            client:notifyWarningLocalized("dropdownDemoCancelled")
                        end
                    end)
                else
                    client:notifyInfoLocalized("demoCancelledNoProblem")
                end
            end)
        end
    end
})

lia.command.add("playtime", {
    adminOnly = false,
    desc = "playtimeDesc",
    onRun = function(client)
        local secs = client:getPlayTime()
        if not secs then
            client:notifyErrorLocalized("playtimeError")
            return
        end

        local h = math.floor(secs / 3600)
        local m = math.floor((secs % 3600) / 60)
        local s = secs % 60
        client:notifyInfoLocalized("playtimeYour", h, m, s)
    end
})

lia.command.add("charid", {
    adminOnly = false,
    desc = "charidDesc",
    onRun = function(client)
        local char = client:getChar()
        if not char then
            client:notifyErrorLocalized("noCharacterSelected")
            return
        end

        local charID = char:getID()
        client:notifyInfoLocalized("charidYour", charID)
    end
})

lia.command.add("plygetplaytime", {
    adminOnly = true,
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "adminStickGetPlayTimeName",
        Category = "moderation",
        SubCategory = "misc",
        Icon = "icon16/time.png"
    },
    desc = "plygetplaytimeDesc",
    onRun = function(client, args)
        if not args[1] then
            client:notifyErrorLocalized("specifyPlayer")
            return
        end

        local target = lia.util.findPlayer(client, args[1])
        if not IsValid(target) then
            client:notifyErrorLocalized("targetNotFound")
            return
        end

        local secs = target:getPlayTime()
        local h = math.floor(secs / 3600)
        local m = math.floor((secs % 3600) / 60)
        local s = secs % 60
        client:ChatPrint(L("playtimeFor", target:Nick(), h, m, s))
    end
})

lia.command.add("plycheckid", {
    adminOnly = true,
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "adminStickCheckCharIDName",
        Category = "moderation",
        SubCategory = "misc",
        Icon = "icon16/vcard.png"
    },
    desc = "plycheckidDesc",
    onRun = function(client, args)
        if not args[1] then
            client:notifyErrorLocalized("specifyPlayer")
            return
        end

        local target = lia.util.findPlayer(client, args[1])
        if not IsValid(target) then
            client:notifyErrorLocalized("targetNotFound")
            return
        end

        local char = target:getChar()
        if not char then
            client:notifyErrorLocalized("noCharacterLoaded")
            return
        end

        local charID = char:getID()
        client:ChatPrint(L("charidFor", target:Nick(), charID))
    end
})

lia.command.add("checkid", {
    desc = "charidDesc",
    onRun = function(client)
        local char = client:getChar()
        if not char then
            client:notifyErrorLocalized("noCharacterSelected")
            return
        end

        local charID = char:getID()
        client:ChatPrint(L("charidYour", charID))
    end
})

lia.command.add("managesitrooms", {
    superAdminOnly = true,
    desc = "manageSitroomsDesc",
    onRun = function(client)
        if not client:hasPrivilege("manageSitRooms") then return end
        local rooms = lia.data.get("sitrooms", {})
        net.Start("liaManagesitrooms")
        net.WriteTable(rooms)
        net.Send(client)
    end
})

lia.command.add("addsitroom", {
    superAdminOnly = true,
    desc = "setSitroomDesc",
    onRun = function(client)
        client:requestString(L("enterNamePrompt"), L("enterSitroomPrompt") .. ":", function(name)
            if name == "" then
                client:notifyErrorLocalized("invalidName")
                return
            end

            local rooms = lia.data.get("sitrooms", {})
            rooms[name] = client:GetPos()
            lia.data.set("sitrooms", rooms)
            client:notifySuccessLocalized("sitroomSet")
            lia.log.add(client, "sitRoomSet", L("sitroomSetDetail", name, tostring(client:GetPos())), L("logSetSitroom"))
        end)
    end
})

lia.command.add("sendtositroom", {
    adminOnly = true,
    desc = "sendToSitRoomDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "sendToSitRoom",
        Category = "moderation",
        SubCategory = "moderationTools",
        Icon = "icon16/arrow_down.png"
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyErrorLocalized("targetNotFound")
            return
        end

        local rooms = lia.data.get("sitrooms", {})
        local names = {}
        for n in pairs(rooms) do
            names[#names + 1] = n
        end

        if #names == 0 then
            client:notifyErrorLocalized("sitroomNotSet")
            return
        end

        client:requestDropdown(L("chooseSitroomTitle"), L("selectSitroomPrompt") .. ":", names, function(selection)
            local pos = rooms[selection]
            if not pos then
                client:notifyErrorLocalized("sitroomNotSet")
                return
            end

            target:SetPos(pos)
            client:notifySuccessLocalized("sitroomTeleport", target:Nick())
            target:notifyInfoLocalized("sitroomArrive")
            lia.log.add(client, "sendToSitRoom", target:Nick(), selection)
        end)
    end
})

lia.command.add("returnsitroom", {
    adminOnly = true,
    desc = "returnFromSitroomDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "returnFromSitroom",
        Category = "moderation",
        SubCategory = "moderationTools",
        Icon = "icon16/arrow_up.png"
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1]) or client
        if not IsValid(target) then
            client:notifyErrorLocalized("targetNotFound")
            return
        end

        local prev = target.previousSitroomPos
        if not prev then
            client:notifyErrorLocalized("noPreviousSitroomPos")
            return
        end

        target:SetPos(prev)
        client:notifySuccessLocalized("sitroomReturnSuccess")
        if target ~= client then target:notifyInfoLocalized("sitroomReturned") end
        lia.log.add(client, "sitRoomReturn", target:Nick())
    end
})

lia.command.add("charkill", {
    superAdminOnly = true,
    alias = "permakill",
    desc = "charkillDesc",
    AdminStick = {
        Name = "adminStickCharKillName",
        Category = "characterManagement",
        SubCategory = "adminStickSubCategoryBans",
        Icon = "icon16/user_delete.png"
    },
    onRun = function(client)
        local choices = {}
        for _, ply in player.Iterator() do
            if ply:getChar() then
                choices[#choices + 1] = {
                    ply:Nick(),
                    {
                        name = ply:Nick(),
                        steamID = ply:SteamID(),
                        charID = ply:getChar():getID()
                    }
                }
            end
        end

        local playerKey = L("player")
        local reasonKey = L("reason")
        local evidenceKey = L("evidence")
        client:requestArguments(L("pkActiveMenu"), {
            [playerKey] = {"table", choices},
            [reasonKey] = "string",
            [evidenceKey] = "string"
        }, function(success, data)
            if not success then return end
            local selection = data[playerKey]
            local reason = data[reasonKey]
            local evidence = data[evidenceKey]
            if not (isstring(evidence) and evidence:match("^https?://")) then
                client:notifyErrorLocalized("evidenceInvalidURL")
                return
            end

            lia.db.insertTable({
                player = selection.name,
                reason = reason,
                steamID = selection.steamID,
                charID = selection.charID,
                submitterName = client:Name(),
                submitterSteamID = client:SteamID(),
                timestamp = os.time(),
                evidence = evidence
            }, nil, "permakills")

            for _, ply in player.Iterator() do
                if ply:SteamID() == selection.steamID and ply:getChar() then
                    ply:getChar():ban()
                    break
                end
            end
        end)
    end
})

local function sanitizeForNet(tbl)
    if istable(tbl) then return tbl end
    local result = {}
    for k, v in pairs(tbl) do
        if istable(c) then
            result[k] = sanitizeForNet(v)
        elseif not isfunction(v) then
            result[k] = v
        end
    end
    return result
end

lia.command.add("charlist", {
    adminOnly = true,
    desc = "charListDesc",
    arguments = {
        {
            name = "playerOrSteamId",
            type = "string"
        },
    },
    onRun = function(client, arguments)
        local identifier = arguments[1]
        local target
        local steamID
        if identifier then
            target = lia.util.findPlayer(client, identifier)
            if IsValid(target) then
                steamID = target:SteamID()
            elseif identifier:match("^STEAM_%d:%d:%d+$") then
                steamID = identifier
            else
                client:notifyErrorLocalized("targetNotFound")
                return
            end
        else
            steamID = client:SteamID()
        end

        local query = [[SELECT c.*, d.value AS charBanInfo FROM lia_characters AS c LEFT JOIN lia_chardata AS d ON d.charID = c.id AND d.key = 'charBanInfo' WHERE c.steamID = ]] .. lia.db.convertDataType(steamID)
        lia.db.query(query, function(data)
            if not data or #data == 0 then
                client:notifyInfoLocalized("noCharactersForPlayer")
                return
            end

            local sendData = {}
            for _, row in ipairs(data) do
                local charID = tonumber(row.id) or row.id
                local stored = lia.char.getCharacter(charID)
                local info = stored and stored:getData() or {}
                local allVars = {}
                if stored then
                    for varName in pairs(lia.char.vars) do
                        local value
                        if varName == "data" then
                            value = stored:getData()
                        elseif varName == "var" then
                            value = stored:getVar()
                        else
                            local getter = stored["get" .. varName:sub(1, 1):upper() .. varName:sub(2)]
                            if isfunction(getter) then
                                value = getter(stored)
                            else
                                value = stored.vars and stored.vars[varName]
                            end
                        end

                        allVars[varName] = value
                    end
                end

                local banInfo = info.charBanInfo
                if not banInfo and row.charBanInfo and row.charBanInfo ~= "" then
                    local ok, decoded = pcall(pon.decode, row.charBanInfo)
                    if ok then
                        banInfo = decoded and decoded[1] or {}
                    else
                        banInfo = util.JSONToTable(row.charBanInfo) or {}
                    end
                end

                local bannedVal = stored and stored:getBanned() or tonumber(row.banned) or 0
                local isBanned = bannedVal ~= 0 and (bannedVal == -1 or bannedVal > os.time())
                local entry = {
                    ID = charID,
                    Name = stored and stored:getName() or row.name,
                    Desc = row.desc,
                    Faction = row.faction,
                    Banned = isBanned and L("yes") or L("no"),
                    BanningAdminName = banInfo and banInfo.name or "",
                    BanningAdminSteamID = banInfo and banInfo.steamID or "",
                    BanningAdminRank = banInfo and banInfo.rank or "",
                    Money = row.money,
                    LastUsed = stored and L("onlineNow") or row.lastJoinTime,
                    allVars = allVars
                }

                entry.extraDetails = {}
                hook.Run("CharListExtraDetails", client, entry, stored)
                entry = sanitizeForNet(entry)
                table.insert(sendData, entry)
            end

            sendData = sanitizeForNet(sendData)
            net.Start("liaDisplayCharList")
            net.WriteTable(sendData)
            net.WriteString(steamID)
            net.Send(client)
        end)
    end
})

lia.command.add("plyban", {
    adminOnly = true,
    desc = "plyBanDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
        {
            name = "duration",
            type = "string",
            optional = true
        },
        {
            name = "reason",
            type = "string"
        },
    },
    AdminStick = {
        Name = "adminStickBanName",
        Category = "moderation",
        SubCategory = "adminStickSubCategoryBans",
        Icon = "icon16/lock.png"
    },
    onRun = function(client, arguments) lia.administrator.serverExecCommand("ban", arguments[1], arguments[2], arguments[3], client) end
})

lia.command.add("plykick", {
    adminOnly = true,
    desc = "plyKickDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
        {
            name = "reason",
            type = "string",
            optional = true
        },
    },
    AdminStick = {
        Name = "adminStickKickPlayerName",
        Category = "moderation",
        SubCategory = "adminStickSubCategoryBans",
        Icon = "icon16/user_delete.png"
    },
    onRun = function(client, arguments) lia.administrator.serverExecCommand("kick", arguments[1], nil, arguments[2], client) end
})

lia.command.add("plykill", {
    adminOnly = true,
    desc = "plyKillDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "adminStickKillPlayerName",
        Category = "moderation",
        SubCategory = "moderationTools",
        Icon = "icon16/user_red.png"
    },
    onRun = function(client, arguments) lia.administrator.serverExecCommand("kill", arguments[1], nil, nil, client) end
})

lia.command.add("plyunban", {
    adminOnly = true,
    desc = "plyUnbanDesc",
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
            client:notifySuccessLocalized("playerUnbanned")
            lia.log.add(client, "plyUnban", steamid)
        end
    end
})

lia.command.add("plyfreeze", {
    adminOnly = true,
    desc = "plyFreezeDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
        {
            name = "duration",
            type = "string",
            optional = true
        },
    },
    onRun = function(client, arguments) lia.administrator.serverExecCommand("freeze", arguments[1], arguments[2], nil, client) end
})

lia.command.add("plyunfreeze", {
    adminOnly = true,
    desc = "plyUnfreezeDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    onRun = function(client, arguments) lia.administrator.serverExecCommand("unfreeze", arguments[1], nil, nil, client) end
})

lia.command.add("plyslay", {
    adminOnly = true,
    desc = "plySlayDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    onRun = function(client, arguments) lia.administrator.serverExecCommand("slay", arguments[1], nil, nil, client) end
})

lia.command.add("plyrespawn", {
    adminOnly = true,
    desc = "plyRespawnDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "adminStickRespawnPlayerName",
        Category = "moderation",
        SubCategory = "moderationTools",
        Icon = "icon16/arrow_refresh.png"
    },
    onRun = function(client, arguments) lia.administrator.serverExecCommand("respawn", arguments[1], nil, nil, client) end
})

lia.command.add("plyblind", {
    adminOnly = true,
    desc = "plyBlindDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
        {
            name = "time",
            type = "string",
            optional = true
        },
    },
    onRun = function(client, arguments) lia.administrator.serverExecCommand("blind", arguments[1], arguments[2], nil, client) end
})

lia.command.add("plyunblind", {
    adminOnly = true,
    desc = "plyUnblindDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    onRun = function(client, arguments) lia.administrator.serverExecCommand("unblind", arguments[1], nil, nil, client) end
})

lia.command.add("plyblindfade", {
    adminOnly = true,
    desc = "plyBlindFadeDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
        {
            name = "time",
            type = "string",
            optional = true
        },
        {
            name = "color",
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
        Name = "adminStickBlindFadeName",
        Category = "moderation",
        SubCategory = "moderationTools",
        Icon = "icon16/eye.png"
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if IsValid(target) then
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
            lia.log.add(client, "plyBlindFade", target:Name(), duration, colorName)
        end
    end
})

lia.command.add("blindfadeall", {
    adminOnly = true,
    desc = "blindFadeAllDesc",
    arguments = {
        {
            name = "time",
            type = "string",
            optional = true
        },
        {
            name = "color",
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
            if not ply:isStaffOnDuty() then
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
    desc = "plyGagDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    onRun = function(client, arguments) lia.administrator.serverExecCommand("gag", arguments[1], nil, nil, client) end
})

lia.command.add("plyungag", {
    adminOnly = true,
    desc = "plyUngagDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    onRun = function(client, arguments) lia.administrator.serverExecCommand("ungag", arguments[1], nil, nil, client) end
})

lia.command.add("plymute", {
    adminOnly = true,
    desc = "plyMuteDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    onRun = function(client, arguments) lia.administrator.serverExecCommand("mute", arguments[1], nil, nil, client) end
})

lia.command.add("plyunmute", {
    adminOnly = true,
    desc = "plyUnmuteDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    onRun = function(client, arguments) lia.administrator.serverExecCommand("unmute", arguments[1], nil, nil, client) end
})

lia.command.add("plybring", {
    adminOnly = true,
    desc = "plyBringDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    onRun = function(client, arguments) lia.administrator.serverExecCommand("bring", arguments[1], nil, nil, client) end
})

lia.command.add("plygoto", {
    adminOnly = true,
    desc = "plyGotoDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    onRun = function(client, arguments) lia.administrator.serverExecCommand("goto", arguments[1], nil, nil, client) end
})

lia.command.add("plyreturn", {
    adminOnly = true,
    desc = "plyReturnDesc",
    arguments = {
        {
            name = "name",
            type = "player",
            optional = true
        },
    },
    onRun = function(client, arguments) lia.administrator.serverExecCommand("return", arguments[1] or client:Name(), nil, nil, client) end
})

lia.command.add("plyjail", {
    adminOnly = true,
    desc = "plyJailDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    onRun = function(client, arguments) lia.administrator.serverExecCommand("jail", arguments[1], nil, nil, client) end
})

lia.command.add("plyunjail", {
    adminOnly = true,
    desc = "plyUnjailDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    onRun = function(client, arguments) lia.administrator.serverExecCommand("unjail", arguments[1], nil, nil, client) end
})

lia.command.add("plycloak", {
    adminOnly = true,
    desc = "plyCloakDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "adminStickCloakName",
        Category = "moderation",
        SubCategory = "moderationTools",
        Icon = "icon16/status_offline.png"
    },
    onRun = function(client, arguments) lia.administrator.serverExecCommand("cloak", arguments[1], nil, nil, client) end
})

lia.command.add("plyuncloak", {
    adminOnly = true,
    desc = "plyUncloakDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "adminStickUncloakName",
        Category = "moderation",
        SubCategory = "moderationTools",
        Icon = "icon16/status_online.png"
    },
    onRun = function(client, arguments) lia.administrator.serverExecCommand("uncloak", arguments[1], nil, nil, client) end
})

lia.command.add("plygod", {
    adminOnly = true,
    desc = "plyGodDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "adminStickGodModeName",
        Category = "moderation",
        SubCategory = "moderationTools",
        Icon = "icon16/shield.png"
    },
    onRun = function(client, arguments) lia.administrator.serverExecCommand("god", arguments[1], nil, nil, client) end
})

lia.command.add("plyungod", {
    adminOnly = true,
    desc = "plyUngodDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "adminStickRemoveGodModeName",
        Category = "moderation",
        SubCategory = "moderationTools",
        Icon = "icon16/shield_delete.png"
    },
    onRun = function(client, arguments) lia.administrator.serverExecCommand("ungod", arguments[1], nil, nil, client) end
})

lia.command.add("plyignite", {
    adminOnly = true,
    desc = "plyIgniteDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
        {
            name = "duration",
            type = "string",
            optional = true
        },
    },
    onRun = function(client, arguments) lia.administrator.serverExecCommand("ignite", arguments[1], arguments[2], nil, client) end
})

lia.command.add("plyextinguish", {
    adminOnly = true,
    desc = "plyExtinguishDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    onRun = function(client, arguments) lia.administrator.serverExecCommand("extinguish", arguments[1], nil, nil, client) end
})

lia.command.add("plystrip", {
    adminOnly = true,
    desc = "plyStripDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "adminStickStripWeaponsName",
        Category = "moderation",
        SubCategory = "moderationTools",
        Icon = "icon16/gun.png"
    },
    onRun = function(client, arguments) lia.administrator.serverExecCommand("strip", arguments[1], nil, nil, client) end
})

lia.command.add("charunbanoffline", {
    superAdminOnly = true,
    desc = "charUnbanOfflineDesc",
    arguments = {
        {
            name = "charId",
            type = "string"
        },
    },
    onRun = function(client, arguments)
        local charID = tonumber(arguments[1])
        if not charID then return client:notifyErrorLocalized("invalidCharID") end
        local result = sql.Query("SELECT id FROM lia_characters WHERE id = " .. charID .. " LIMIT 1")
        if not istable(result) or not result[1] then return client:notifyErrorLocalized("characterNotFound") end
        lia.char.setCharDatabase(charID, "banned", 0)
        lia.char.setCharDatabase(charID, "charBanInfo", nil)
        client:notifySuccessLocalized("offlineCharUnbanned", charID)
        lia.log.add(client, "charUnbanOffline", charID)
    end
})

lia.command.add("charbanoffline", {
    superAdminOnly = true,
    desc = "charBanOfflineDesc",
    arguments = {
        {
            name = "charId",
            type = "string"
        },
    },
    onRun = function(client, arguments)
        local charID = tonumber(arguments[1])
        if not charID then return client:notifyErrorLocalized("invalidCharID") end
        local result = sql.Query("SELECT id FROM lia_characters WHERE id = " .. charID .. " LIMIT 1")
        if not istable(result) or not result[1] then return client:notifyErrorLocalized("characterNotFound") end
        lia.char.setCharDatabase(charID, "banned", -1)
        lia.char.setCharDatabase(charID, "charBanInfo", {
            name = client:Nick(),
            steamID = client:SteamID(),
            rank = client:GetUserGroup()
        })

        for _, ply in player.Iterator() do
            if ply:getChar() and ply:getChar():getID() == charID then
                ply:Kick(L("youHaveBeenBanned"))
                break
            end
        end

        client:notifySuccessLocalized("offlineCharBanned", charID)
        lia.log.add(client, "charBanOffline", charID)
    end
})

lia.command.add("playglobalsound", {
    superAdminOnly = true,
    desc = "playGlobalSoundDesc",
    arguments = {
        {
            name = "sound",
            type = "string"
        },
    },
    onRun = function(client, arguments)
        local sound = arguments[1]
        if not sound or sound == "" then
            client:notifyErrorLocalized("mustSpecifySound")
            return
        end

        for _, target in player.Iterator() do
            target:PlaySound(sound)
        end
    end
})

lia.command.add("plyspectate", {
    adminOnly = true,
    desc = "plySpectateDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "adminStickSpectateName",
        Category = "moderation",
        SubCategory = "moderationTools",
        Icon = "icon16/zoom.png"
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyErrorLocalized("targetNotFound")
            return
        end

        if target == client then
            client:notifyErrorLocalized("cannotSpectateSelf")
            return
        end

        if target.liaSpectating then
            client:notifyErrorLocalized("targetAlreadySpectated")
            return
        end

        client.returnPos = client:GetPos()
        client.returnAng = client:EyeAngles()
        client:Spectate(OBS_MODE_CHASE)
        client:SpectateEntity(target)
        client:GodEnable()
        client.liaSpectating = true
        client:notifySuccessLocalized("spectateStarted", target:Nick())
        target:notifyInfoLocalized("beingSpectated", client:Nick())
        lia.log.add(client, "plySpectate", target:Nick())
    end
})

lia.command.add("stopspectate", {
    adminOnly = true,
    desc = "stopSpectateDesc",
    onRun = function(client)
        if not client.liaSpectating then
            client:notifyErrorLocalized("notSpectating")
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
        client:notifySuccessLocalized("spectateStopped")
        lia.log.add(client, "stopSpectate")
    end
})

lia.command.add("playsound", {
    superAdminOnly = true,
    desc = "playSoundDesc",
    arguments = {
        {
            name = "name",
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
            client:notifyErrorLocalized("targetNotFound")
            return
        end

        if not sound or sound == "" then
            client:notifyErrorLocalized("noSound")
            return
        end

        target:PlaySound(sound)
    end
})

lia.command.add("returntodeathpos", {
    adminOnly = true,
    desc = "returnToDeathPosDesc",
    onRun = function(client)
        if IsValid(client) and client:Alive() then
            local character = client:getChar()
            local oldPos = character and character:getData("deathPos")
            if oldPos then
                client:SetPos(oldPos)
                character:setData("deathPos", nil)
            else
                client:notifyErrorLocalized("noDeathPosition")
            end
        else
            client:notifyWarningLocalized("waitRespawn")
        end
    end
})

lia.command.add("roll", {
    adminOnly = false,
    desc = "rollDesc",
    onRun = function(client)
        local rollValue = math.random(0, 100)
        lia.chat.send(client, "roll", rollValue)
    end
})

lia.command.add("forcefallover", {
    adminOnly = true,
    desc = "forceFalloverDesc",
    arguments = {
        {
            name = "name",
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
            client:notifyErrorLocalized("targetNotFound")
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
    desc = "forceGetUpDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyErrorLocalized("targetNotFound")
            return
        end

        if not IsValid(target:GetRagdollEntity()) then
            target:notifyErrorLocalized("noRagdoll")
            return
        end

        local entity = target:GetRagdollEntity()
        if IsValid(entity) and entity.liaGrace and entity.liaGrace < CurTime() and entity:GetVelocity():Length2D() < 8 and not entity.liaWakingUp then
            entity.liaWakingUp = true
            target:setAction("gettingUp", 5, function()
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
    desc = "changeCharDesc",
    arguments = {
        {
            name = "desc",
            type = "string",
            optional = true
        },
    },
    onRun = function(client, arguments)
        local desc = table.concat(arguments, " ")
        if not desc:find("%S") then return client:requestString(L("chgName"), L("chgNameDesc"), function(text) lia.command.run(client, "chardesc", {text}) end, client:getChar() and client:getChar():getDesc() or "") end
        local character = client:getChar()
        if character then character:setDesc(desc) end
        return "@descChanged"
    end
})

lia.command.add("chargetup", {
    adminOnly = false,
    desc = "forceSelfGetUpDesc",
    onRun = function(client)
        if not IsValid(client:GetRagdollEntity()) then
            client:notifyErrorLocalized("noRagdoll")
            return
        end

        local entity = client:GetRagdollEntity()
        if IsValid(entity) and entity.liaGrace and entity.liaGrace < CurTime() and entity:GetVelocity():Length2D() < 8 and not entity.liaWakingUp then
            entity.liaWakingUp = true
            client:setAction("gettingUp", 5, function()
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
    desc = "fallOverDesc",
    arguments = {
        {
            name = "time",
            type = "string",
            optional = true
        },
    },
    onRun = function(client, arguments)
        if client.FallOverCooldown then
            client:notifyWarningLocalized("cmdCooldown")
            return
        elseif client:IsFrozen() then
            client:notifyWarningLocalized("cmdFrozen")
            return
        elseif not client:Alive() then
            client:notifyErrorLocalized("cmdDead")
            return
        elseif IsValid(client:GetVehicle()) then
            client:notifyWarningLocalized("cmdVehicle")
            return
        elseif client:GetMoveType() == MOVETYPE_NOCLIP then
            client:notifyWarningLocalized("cmdNoclip")
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
    desc = "toggleCharLockDesc",
    onRun = function()
        local newVal = not GetGlobalBool("characterSwapLock", false)
        SetGlobalBool("characterSwapLock", newVal)
        if not newVal then
            return L("characterLockDisabled")
        else
            return L("characterLockEnabled")
        end
    end
})

lia.command.add("checkinventory", {
    adminOnly = true,
    desc = "checkInventoryDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "adminStickCheckInventoryName",
        Category = "characterManagement",
        SubCategory = "items",
        Icon = "icon16/box.png"
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyErrorLocalized("targetNotFound")
            return
        end

        if target == client then
            client:notifyErrorLocalized("invCheckSelf")
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
    desc = "flagGiveDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
        {
            name = "flags",
            type = "string"
        },
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyErrorLocalized("targetNotFound")
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
                client:notifyInfoLocalized("noAvailableFlags")
                return
            end
            return client:requestString(L("give") .. " " .. L("flags"), L("flagGiveDesc"), function(text) lia.command.run(client, "flaggive", {target:Name(), text}) end, available)
        end

        target:giveFlags(flags)
        client:notifySuccessLocalized("flagGive", client:Name(), flags, target:Name())
        lia.log.add(client, "flagGive", target:Name(), flags)
    end,
    alias = {"giveflag", "chargiveflag"}
})

lia.command.add("flaggiveall", {
    adminOnly = true,
    desc = "giveAllFlagsDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyErrorLocalized("targetNotFound")
            return
        end

        for k, _ in SortedPairs(lia.flag.list) do
            if not target:hasFlags(k) then target:giveFlags(k) end
        end

        client:notifySuccessLocalized("gaveAllFlags")
        lia.log.add(client, "flagGiveAll", target:Name())
    end
})

lia.command.add("flagtakeall", {
    adminOnly = true,
    desc = "takeAllFlagsDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyErrorLocalized("targetNotFound")
            return
        end

        if not target:getChar() then
            client:notifyErrorLocalized("invalidTarget")
            return
        end

        for k, _ in SortedPairs(lia.flag.list) do
            if target:hasFlags(k) then target:takeFlags(k) end
        end

        client:notifySuccessLocalized("tookAllFlags")
        lia.log.add(client, "flagTakeAll", target:Name())
    end
})

lia.command.add("flagtake", {
    adminOnly = true,
    desc = "flagTakeDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
        {
            name = "flags",
            type = "string"
        },
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyErrorLocalized("targetNotFound")
            return
        end

        local flags = arguments[2]
        if not flags then
            local currentFlags = target:getFlags()
            return client:requestString(L("take") .. " " .. L("flags"), L("flagTakeDesc"), function(text) lia.command.run(client, "flagtake", {target:Name(), text}) end, table.concat(currentFlags, ", "))
        end

        target:takeFlags(flags)
        client:notifySuccessLocalized("flagTake", client:Name(), flags, target:Name())
        lia.log.add(client, "flagTake", target:Name(), flags)
    end,
    alias = {"takeflag"}
})

lia.command.add("bringlostitems", {
    superAdminOnly = true,
    desc = "bringLostItemsDesc",
    onRun = function(client)
        for _, v in ipairs(ents.FindInSphere(client:GetPos(), 500)) do
            if v:isItem() then v:SetPos(client:GetPos()) end
        end
    end
})

lia.command.add("charvoicetoggle", {
    adminOnly = true,
    desc = "charVoiceToggleDesc",
    arguments = {
        {
            name = "name",
            type = "string"
        },
    },
    AdminStick = {
        Name = "toggleVoice",
        Category = "moderation",
        SubCategory = "moderationTools",
        Icon = "icon16/sound_mute.png"
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyErrorLocalized("targetNotFound")
            return
        end

        if target == client then
            client:notifyErrorLocalized("cannotMuteSelf")
            return false
        end

        if target:getChar() then
            local isMuted = target:getLiliaData("liaMuted", false)
            target:setLiliaData("liaMuted", not isMuted)
            if isMuted then
                client:notifySuccessLocalized("textUnmuted", target:Name())
                target:notifyInfoLocalized("textUnmutedByAdmin")
            else
                client:notifySuccessLocalized("textMuted", target:Name())
                target:notifyWarningLocalized("textMutedByAdmin")
            end

            lia.log.add(client, "textToggle", target:Name(), isMuted and L("unmuted") or L("muted"))
        else
            client:notifyErrorLocalized("noValidCharacter")
        end
    end
})

lia.command.add("cleanitems", {
    superAdminOnly = true,
    desc = "cleanItemsDesc",
    onRun = function(client)
        local count = 0
        for _, v in ipairs(ents.FindByClass("lia_item")) do
            count = count + 1
            SafeRemoveEntity(v)
        end

        client:notifySuccessLocalized("cleaningFinished", L("items"), count)
    end
})

lia.command.add("cleanprops", {
    superAdminOnly = true,
    desc = "cleanPropsDesc",
    onRun = function(client)
        local count = 0
        for _, entity in ents.Iterator() do
            if IsValid(entity) and entity:isProp() then
                count = count + 1
                SafeRemoveEntity(entity)
            end
        end

        client:notifySuccessLocalized("cleaningFinished", L("props"), count)
    end
})

lia.command.add("cleannpcs", {
    superAdminOnly = true,
    desc = "cleanNPCsDesc",
    onRun = function(client)
        local count = 0
        for _, entity in ents.Iterator() do
            if IsValid(entity) and entity:IsNPC() then
                count = count + 1
                SafeRemoveEntity(entity)
            end
        end

        client:notifySuccessLocalized("cleaningFinished", L("npcs"), count)
    end
})

lia.command.add("charunban", {
    superAdminOnly = true,
    desc = "charUnbanDesc",
    arguments = {
        {
            name = "nameOrNumberId",
            type = "string"
        },
    },
    onRun = function(client, arguments)
        if (client.liaNextSearch or 0) >= CurTime() then return L("searchingChar") end
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
                client:notifySuccessLocalized("charUnBan", client:Name(), charFound:getName())
                lia.log.add(client, "charUnban", charFound:getName(), charFound:getID())
            else
                return L("charNotBanned")
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
                    client:notifyInfoLocalized("charNotBanned")
                    return
                end

                lia.char.setCharDatabase(charID, "banned", 0)
                lia.char.setCharDatabase(charID, "charBanInfo", nil)
                client:notifySuccessLocalized("charUnBan", client:Name(), data[1].name)
                lia.log.add(client, "charUnban", data[1].name, charID)
            end
        end)
    end
})

lia.command.add("clearinv", {
    superAdminOnly = true,
    desc = "clearInvDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "adminStickClearInventoryName",
        Category = "characterManagement",
        SubCategory = "items",
        Icon = "icon16/bin.png"
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyErrorLocalized("targetNotFound")
            return
        end

        target:getChar():getInv():wipeItems()
        client:notifySuccessLocalized("resetInv", target:getChar():getName())
    end
})

lia.command.add("charkick", {
    adminOnly = true,
    desc = "kickCharDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "adminStickKickCharacterName",
        Category = "characterManagement",
        SubCategory = "adminStickSubCategoryBans",
        Icon = "icon16/user_delete.png"
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyErrorLocalized("targetNotFound")
            return
        end

        local character = target:getChar()
        if character then
            for _, targets in player.Iterator() do
                targets:notifyInfoLocalized("charKick", client:Name(), target:Name())
            end

            character:kick()
            lia.log.add(client, "charKick", target:Name(), character:getID())
        else
            client:notifyErrorLocalized("noChar")
        end
    end
})

lia.command.add("freezeallprops", {
    superAdminOnly = true,
    desc = "freezeAllPropsDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyErrorLocalized("targetNotFound")
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

        client:notifySuccessLocalized("freezeAllProps", target:Name())
        client:notifySuccessLocalized("freezeAllPropsCount", count, target:Name())
    end
})

lia.command.add("charban", {
    superAdminOnly = true,
    desc = "banCharDesc",
    arguments = {
        {
            name = "nameOrNumberId",
            type = "string"
        },
    },
    AdminStick = {
        Name = "banCharacter",
        Category = "characterManagement",
        SubCategory = "adminStickSubCategoryBans",
        Icon = "icon16/user_red.png"
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
            client:notifyErrorLocalized("targetNotFound")
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
            client:notifySuccessLocalized("charBan", client:Name(), target:Name())
            lia.log.add(client, "charBan", target:Name(), character:getID())
        else
            client:notifyErrorLocalized("noChar")
        end
    end
})

lia.command.add("charwipe", {
    superAdminOnly = true,
    desc = "charWipeDesc",
    arguments = {
        {
            name = "nameOrNumberId",
            type = "string"
        },
    },
    AdminStick = {
        Name = "wipeCharacter",
        Category = "characterManagement",
        SubCategory = "adminStickSubCategoryBans",
        Icon = "icon16/user_delete.png"
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
            client:notifyErrorLocalized("targetNotFound")
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

                lia.module.get("mainmenu"):SyncCharList(target)
            end

            client:notifySuccessLocalized("charWipe", client:Name(), charName)
            lia.log.add(client, "charWipe", charName, charID)
        else
            client:notifyErrorLocalized("noChar")
        end
    end
})

lia.command.add("charwipeoffline", {
    superAdminOnly = true,
    desc = "charWipeOfflineDesc",
    arguments = {
        {
            name = "charId",
            type = "string"
        },
    },
    onRun = function(client, arguments)
        local charID = tonumber(arguments[1])
        if not charID then return client:notifyErrorLocalized("invalidCharID") end
        lia.db.query("SELECT name FROM lia_characters WHERE id = " .. charID, function(data)
            if not data or #data == 0 then
                client:notifyErrorLocalized("characterNotFound")
                return
            end

            local charName = data[1].name
            for _, ply in player.Iterator() do
                if ply:getChar() and ply:getChar():getID() == charID then
                    ply:Kick(L("youHaveBeenWiped"))
                    break
                end
            end

            lia.char.delete(charID)
            client:notifySuccessLocalized("offlineCharWiped", charID)
            lia.log.add(client, "charWipeOffline", charName, charID)
        end)
    end
})

lia.command.add("checkmoney", {
    adminOnly = true,
    desc = "checkMoneyDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "adminStickCheckMoneyName",
        Category = "characterManagement",
        SubCategory = "items",
        Icon = "icon16/money.png"
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyErrorLocalized("targetNotFound")
            return
        end

        local money = target:getChar():getMoney()
        client:notifyMoneyLocalized("playerMoney", target:GetName(), lia.currency.get(money))
    end
})

lia.command.add("listbodygroups", {
    adminOnly = true,
    desc = "listBodygroupsDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyErrorLocalized("targetNotFound")
            return
        end

        local bodygroups = {}
        for i = 0, target:GetNumBodyGroups() - 1 do
            if target:GetBodygroupCount(i) > 1 then
                table.insert(bodygroups, {
                    group = i,
                    name = target:GetBodygroupName(i),
                    range = "0-" .. target:GetBodygroupCount(i) - 1
                })
            end
        end

        if #bodygroups > 0 then
            lia.util.sendTableUI(client, L("uiBodygroupsFor", target:Nick()), {
                {
                    name = "groupID",
                    field = "group"
                },
                {
                    name = "name",
                    field = "name"
                },
                {
                    name = "range",
                    field = "range"
                }
            }, bodygroups)
        else
            client:notifyInfoLocalized("noBodygroups")
        end
    end
})

lia.command.add("charsetspeed", {
    adminOnly = true,
    desc = "setSpeedDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
        {
            name = "speed",
            type = "string",
            optional = true
        },
    },
    AdminStick = {
        Name = "adminStickSetCharSpeedName",
        Category = "characterManagement",
        SubCategory = "adminStickSubCategorySetInfos",
        Icon = "icon16/lightning.png"
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyErrorLocalized("targetNotFound")
            return
        end

        local speed = tonumber(arguments[2]) or lia.config.get("WalkSpeed")
        target:SetRunSpeed(speed)
    end
})

lia.command.add("charsetmodel", {
    adminOnly = true,
    desc = "setModelDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
        {
            name = "model",
            type = "string",
            optional = true
        },
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyErrorLocalized("targetNotFound")
            return
        end

        local oldModel = target:getChar():getModel()
        target:getChar():setModel(arguments[2] or oldModel)
        target:SetupHands()
        client:notifySuccessLocalized("changeModel", client:Name(), target:Name(), arguments[2] or oldModel)
        lia.log.add(client, "charsetmodel", target:Name(), arguments[2], oldModel)
    end
})

lia.command.add("chargiveitem", {
    superAdminOnly = true,
    desc = "giveItemDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
        {
            name = "itemName",
            type = "string"
        },
    },
    AdminStick = {
        Name = "adminStickGiveItemName",
        Category = "characterManagement",
        SubCategory = "items",
        Icon = "icon16/user_gray.png"
    },
    onRun = function(client, arguments)
        local itemName = arguments[2]
        if not itemName or itemName == "" then
            client:notifyErrorLocalized("mustSpecifyItem")
            return
        end

        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyErrorLocalized("targetNotFound")
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
            client:notifyErrorLocalized("itemNoExist")
            return
        end

        local inv = target:getChar():getInv()
        local succ, err = inv:add(uniqueID)
        if succ then
            target:notifySuccessLocalized("itemCreated")
            if target ~= client then client:notifySuccessLocalized("itemCreated") end
            lia.log.add(client, "chargiveItem", lia.item.list[uniqueID] and lia.item.list[uniqueID].name or uniqueID, target, L("command"))
        else
            target:notifyErrorLocalized(err or "unknownError")
        end
    end
})

lia.command.add("charsetdesc", {
    adminOnly = true,
    desc = "setDescDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
        {
            name = "description",
            type = "string",
            optional = true
        },
    },
    AdminStick = {
        Name = "adminStickSetCharDescName",
        Category = "characterManagement",
        SubCategory = "adminStickSubCategorySetInfos",
        Icon = "icon16/user_comment.png"
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyErrorLocalized("targetNotFound")
            return
        end

        if not target:getChar() then
            client:notifyErrorLocalized("noChar")
            return
        end

        local desc = table.concat(arguments, " ", 2)
        if not desc:find("%S") then return client:requestString(L("chgDescTitle", target:Name()), L("enterNewDesc"), function(text) lia.command.run(client, "charsetdesc", {arguments[1], text}) end, target:getChar():getDesc()) end
        target:getChar():setDesc(desc)
        return L("descChangedTarget", client:Name(), target:Name())
    end
})

lia.command.add("charsetname", {
    adminOnly = true,
    desc = "setNameDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
        {
            name = "newName",
            type = "string",
            optional = true
        },
    },
    AdminStick = {
        Name = "adminStickSetCharNameName",
        Category = "characterManagement",
        SubCategory = "adminStickSubCategorySetInfos",
        Icon = "icon16/user_edit.png"
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyErrorLocalized("targetNotFound")
            return
        end

        local newName = table.concat(arguments, " ", 2)
        if newName == "" then return client:requestString(L("chgName"), L("chgNameDesc"), function(text) lia.command.run(client, "charsetname", {target:Name(), text}) end, target:Name()) end
        local oldName = target:getChar():getName()
        target:getChar():setName(newName:gsub("#", "#?"))
        client:notifySuccessLocalized("changeName", client:Name(), oldName, newName)
    end
})

lia.command.add("charsetscale", {
    adminOnly = true,
    desc = "setScaleDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
        {
            name = "scale",
            type = "string",
            optional = true
        },
    },
    AdminStick = {
        Name = "adminStickSetCharScaleName",
        Category = "characterManagement",
        SubCategory = "adminStickSubCategorySetInfos",
        Icon = "icon16/arrow_out.png"
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        local scale = tonumber(arguments[2]) or 1
        if not target or not IsValid(target) then
            client:notifyErrorLocalized("targetNotFound")
            return
        end

        target:SetModelScale(scale, 0)
        client:notifySuccessLocalized("changedScale", target:Name(), scale)
    end
})

lia.command.add("charsetjump", {
    adminOnly = true,
    desc = "setJumpDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
        {
            name = "power",
            type = "string",
            optional = true
        },
    },
    AdminStick = {
        Name = "adminStickSetCharJumpName",
        Category = "characterManagement",
        SubCategory = "adminStickSubCategorySetInfos",
        Icon = "icon16/arrow_up.png"
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        local power = tonumber(arguments[2]) or 200
        if not target or not IsValid(target) then
            client:notifyErrorLocalized("targetNotFound")
            return
        end

        target:SetJumpPower(power)
        client:notifySuccessLocalized("changedJump", target:Name(), power)
    end
})

lia.command.add("charsetbodygroup", {
    adminOnly = true,
    desc = "setBodygroupDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
        {
            name = "bodygroupName",
            type = "string"
        },
        {
            name = "value",
            type = "string"
        },
    },
    onRun = function(client, arguments)
        local name = arguments[1]
        local bodyGroup = arguments[2]
        local value = tonumber(arguments[3])
        local target = lia.util.findPlayer(client, name)
        if not target or not IsValid(target) then
            client:notifyErrorLocalized("targetNotFound")
            return
        end

        local index = target:FindBodygroupByName(bodyGroup)
        if index > -1 then
            if value and value < 1 then value = nil end
            local groups = target:getChar():getBodygroups()
            groups[index] = value
            target:getChar():setBodygroups(groups)
            target:SetBodygroup(index, value or 0)
            client:notifySuccessLocalized("changeBodygroups", client:Name(), target:Name(), bodyGroup, value or 0)
        else
            client:notifyErrorLocalized("invalidArg")
        end
    end
})

lia.command.add("charsetskin", {
    adminOnly = true,
    desc = "setSkinDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
        {
            name = "skin",
            type = "string"
        },
    },
    AdminStick = {
        Name = "adminStickSetCharSkinName",
        Category = "characterManagement",
        SubCategory = "adminStickSubCategorySetInfos",
        Icon = "icon16/user_gray.png"
    },
    onRun = function(client, arguments)
        local name = arguments[1]
        local skin = tonumber(arguments[2])
        local target = lia.util.findPlayer(client, name)
        if not target or not IsValid(target) then
            client:notifyErrorLocalized("targetNotFound")
            return
        end

        if not skin then
            client:notifyErrorLocalized("invalidArg", 2)
            return
        end

        target:getChar():setSkin(skin)
        target:SetSkin(skin)
        client:notifySuccessLocalized("changeSkin", client:Name(), target:Name(), skin)
    end
})

lia.command.add("charsetmoney", {
    superAdminOnly = true,
    desc = "setMoneyDesc",
    arguments = {
        {
            name = "name",
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
            client:notifyErrorLocalized("invalidArg")
            return
        end

        if not target or not IsValid(target) then
            client:notifyErrorLocalized("targetNotFound")
            return
        end

        target:getChar():setMoney(math.floor(amount))
        client:notifyMoneyLocalized("setMoney", target:Name(), lia.currency.get(math.floor(amount)))
        lia.log.add(client, "charSetMoney", target:Name(), math.floor(amount))
    end
})

lia.command.add("charaddmoney", {
    superAdminOnly = true,
    desc = "addMoneyDesc",
    arguments = {
        {
            name = "name",
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
            client:notifyErrorLocalized("invalidArg")
            return
        end

        if not target or not IsValid(target) then
            client:notifyErrorLocalized("targetNotFound")
            return
        end

        amount = math.Round(amount)
        local currentMoney = target:getChar():getMoney()
        target:getChar():setMoney(currentMoney + amount)
        client:notifyMoneyLocalized("addMoney", target:Name(), lia.currency.get(amount), lia.currency.get(currentMoney + amount))
        lia.log.add(client, "charAddMoney", target:Name(), amount, currentMoney + amount)
    end,
    alias = {"chargivemoney"}
})

lia.command.add("globalbotsay", {
    superAdminOnly = true,
    desc = "globalBotSayDesc",
    arguments = {
        {
            name = "message",
            type = "string"
        },
    },
    onRun = function(client, arguments)
        local message = table.concat(arguments, " ")
        if message == "" then
            client:notifyErrorLocalized("noMessage")
            return
        end

        for _, bot in player.Iterator() do
            if bot:IsBot() then bot:Say(message) end
        end
    end
})

lia.command.add("botsay", {
    superAdminOnly = true,
    desc = "botSayDesc",
    arguments = {
        {
            name = "botName",
            type = "string"
        },
        {
            name = "message",
            type = "string"
        },
    },
    onRun = function(client, arguments)
        if #arguments < 2 then
            client:notifyErrorLocalized("needBotAndMessage")
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
            client:notifyErrorLocalized("botNotFound", botName)
            return
        end

        targetBot:Say(message)
    end
})

lia.command.add("forcesay", {
    superAdminOnly = true,
    desc = "forceSayDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
        {
            name = "message",
            type = "string"
        },
    },
    AdminStick = {
        Name = "adminStickForceSayName",
        Category = "moderation",
        SubCategory = "moderationTools",
        Icon = "icon16/comments.png"
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        local message = table.concat(arguments, " ", 2)
        if not target or not IsValid(target) then
            client:notifyErrorLocalized("targetNotFound")
            return
        end

        if message == "" then
            client:notifyErrorLocalized("noMessage")
            return
        end

        target:Say(message)
        lia.log.add(client, "forceSay", target:Name(), message)
    end
})

lia.command.add("getmodel", {
    desc = "getModelDesc",
    onRun = function(client)
        local entity = client:getTracedEntity()
        if not IsValid(entity) then
            client:notifyErrorLocalized("noEntityInFront")
            return
        end

        local model = entity:GetModel()
        client:ChatPrint(model and L("modelIs", model) or L("noModelFound"))
    end
})

lia.command.add("pm", {
    desc = "pmDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
        {
            name = "message",
            type = "string"
        },
    },
    onRun = function(client, arguments)
        if not lia.config.get("AllowPMs") then
            client:notifyErrorLocalized("pmsDisabled")
            return
        end

        local targetName = arguments[1]
        local message = table.concat(arguments, " ", 2)
        local target = lia.util.findPlayer(client, targetName)
        if not target or not IsValid(target) then
            client:notifyErrorLocalized("targetNotFound")
            return
        end

        if not message:find("%S") then
            client:notifyErrorLocalized("noMessage")
            return
        end

        lia.chat.send(client, "pm", message, false, {client, target})
    end
})

lia.command.add("chargetmodel", {
    adminOnly = true,
    desc = "getCharModelDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "adminStickGetCharModelName",
        Category = "characterManagement",
        SubCategory = "adminStickSubCategoryGetInfos",
        Icon = "icon16/user_gray.png"
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyErrorLocalized("targetNotFound")
            return
        end

        client:ChatPrint(L("charModelIs", target:GetModel()))
    end
})

lia.command.add("checkallmoney", {
    superAdminOnly = true,
    desc = "checkAllMoneyDesc",
    onRun = function(client)
        for _, target in player.Iterator() do
            local char = target:getChar()
            if char then client:ChatPrint(L("playerMoney", target:GetName(), lia.currency.get(char:getMoney()))) end
        end
    end
})

lia.command.add("checkflags", {
    adminOnly = true,
    desc = "checkFlagsDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "adminStickGetCharFlagsName",
        Category = "characterManagement",
        SubCategory = "adminStickSubCategoryGetInfos",
        Icon = "icon16/flag_yellow.png"
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyErrorLocalized("targetNotFound")
            return
        end

        local flags = target:getFlags()
        if flags and #flags > 0 then
            client:ChatPrint(L("charFlags", target:Name(), table.concat(flags, ", ")))
        else
            client:notifyInfoLocalized("noFlags", target:Name())
        end
    end
})

lia.command.add("chargetname", {
    adminOnly = true,
    desc = "getCharNameDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "adminStickGetCharNameName",
        Category = "characterManagement",
        SubCategory = "adminStickSubCategoryGetInfos",
        Icon = "icon16/user.png"
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyErrorLocalized("targetNotFound")
            return
        end

        client:ChatPrint(L("charNameIs", target:getChar():getName()))
    end
})

lia.command.add("chargethealth", {
    adminOnly = true,
    desc = "getHealthDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "adminStickGetCharHealthName",
        Category = "characterManagement",
        SubCategory = "adminStickSubCategoryGetInfos",
        Icon = "icon16/heart.png"
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyErrorLocalized("targetNotFound")
            return
        end

        client:ChatPrint(L("charHealthIs", target:Health(), target:GetMaxHealth()))
    end
})

lia.command.add("chargetmoney", {
    adminOnly = true,
    desc = "getMoneyDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "adminStickGetCharMoneyName",
        Category = "characterManagement",
        SubCategory = "adminStickSubCategoryGetInfos",
        Icon = "icon16/money.png"
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyErrorLocalized("targetNotFound")
            return
        end

        local money = target:getChar():getMoney()
        client:ChatPrint(L("charMoneyIs", lia.currency.get(money)))
    end
})

lia.command.add("chargetinventory", {
    adminOnly = true,
    desc = "getInventoryDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "adminStickGetCharInventoryName",
        Category = "characterManagement",
        SubCategory = "adminStickSubCategoryGetInfos",
        Icon = "icon16/box.png"
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyErrorLocalized("targetNotFound")
            return
        end

        local inventory = target:getChar():getInv()
        local items = inventory:getItems()
        if not items or table.Count(items) < 1 then
            client:notifyInfoLocalized("charInvEmpty")
            return
        end

        local result = {}
        for _, item in pairs(items) do
            table.insert(result, item.name)
        end

        client:ChatPrint(L("charInventoryIs", table.concat(result, ", ")))
    end
})

lia.command.add("getallinfos", {
    adminOnly = true,
    desc = "getAllInfosDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "adminStickGetAllInfosName",
        Category = "characterManagement",
        SubCategory = "adminStickSubCategoryGetInfos",
        Icon = "icon16/table.png"
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyErrorLocalized("targetNotFound")
            return
        end

        local char = target:getChar()
        if not char then
            client:notifyErrorLocalized("noChar")
            return
        end

        local data = lia.char.getCharData(char:getID())
        if not data then
            client:notifyErrorLocalized("noChar")
            return
        end

        lia.administrator(L("allInfoFor", char:getName()))
        for column, value in pairs(data) do
            if istable(value) then
                lia.administrator(column .. ":")
                PrintTable(value)
            else
                lia.administrator(column .. " = " .. tostring(value))
            end
        end

        client:notifyInfoLocalized("infoPrintedConsole")
    end
})

lia.command.add("dropmoney", {
    desc = "dropMoneyDesc",
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
            lia.log.add(client, "moneyDupeAttempt", "Attempted to drop " .. tostring(originalAmount) .. " money (floored to " .. amount .. ")")
            for _, admin in player.Iterator() do
                if admin:IsAdmin() then admin:notifyLocalized("moneyDupeAttempt", client:Name(), "dropmoney", tostring(originalAmount), tostring(amount)) end
            end
        end

        if not amount or amount <= 0 then
            client:notifyErrorLocalized("invalidArg")
            return
        end

        local character = client:getChar()
        if not character or not character:hasMoney(amount) then
            client:notifyErrorLocalized("notEnoughMoney")
            return
        end

        local maxEntities = lia.config.get("MaxMoneyEntities", 3)
        local existingMoneyEntities = 0
        for _, entity in pairs(ents.FindByClass("lia_money")) do
            if entity.client == client then existingMoneyEntities = existingMoneyEntities + 1 end
        end

        if existingMoneyEntities >= maxEntities then
            client:notifyErrorLocalized("maxMoneyEntitiesReached", maxEntities)
            return
        end

        character:takeMoney(amount)
        local money = lia.currency.spawn(client:getItemDropPos(), amount)
        if IsValid(money) then
            money.client = client
            money.charID = character:getID()
            client:notifyMoneyLocalized("moneyDropped", lia.currency.get(amount))
            lia.log.add(client, "moneyDropped", amount)
        end

        client:doGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GMOD_GESTURE_ITEM_PLACE, true)
    end
})

lia.command.add("exportprivileges", {
    adminOnly = true,
    desc = "exportprivilegesDesc",
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
        if lia then
            if lia.administrator then
                table.insert(srcs, lia.administrator.privileges)
                if isfunction(lia.administrator.getPrivileges) == "function" then
                    local ok, r = pcall(lia.administrator.getPrivileges, lia.administrator)
                    if ok then table.insert(srcs, r) end
                end
            end

            if lia.administrator then
                table.insert(srcs, lia.administrator.privileges)
                if isfunction(lia.administrator.getPrivileges) then
                    local ok, r = pcall(lia.administrator.getPrivileges, lia.administrator)
                    if ok then table.insert(srcs, r) end
                end
            end

            if lia.permission then
                table.insert(srcs, lia.permission.list)
                if isfunction(lia.permission.getAll) then
                    local ok, r = pcall(lia.permission.getAll, lia.permission)
                    if ok then table.insert(srcs, r) end
                end
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
            client:notifySuccessLocalized("privilegesExportedSuccessfully", filename)
            MsgC(Color(83, 143, 239), "[Lilia] ", "[" .. L("logAdmin") .. "] ")
            MsgC(Color(255, 153, 0), L("privilegesExportedBy", client:Nick(), filename), "\n")
            lia.log.add(client, "privilegesExported", filename)
        else
            client:notifyErrorLocalized("privilegesExportFailed")
            lia.error(L("privilegesExportFailed"))
        end
    end
})

lia.command.add("fillwithbots", {
    superAdminOnly = true,
    desc = "botsManageDesc",
    alias = {"bots"},
    onRun = function(client)
        if not SERVER then return end
        if not timer.Exists("Bots_Add_Timer") then
            timer.Create("Bots_Add_Timer", 2, 0, function()
                if player.GetCount() < game.MaxPlayers() then
                    game.ConsoleCommand("bot\n")
                else
                    timer.Remove("Bots_Add_Timer")
                end
            end)

            client:notifyInfoLocalized("botsFillingServer")
        else
            client:notifyErrorLocalized("botsAlreadyAdding")
        end
    end
})

lia.command.add("spawnbots", {
    superAdminOnly = true,
    desc = "spawnBotsDesc",
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
            client:notifyErrorLocalized("spawnBotsLimit", requestedAmount, availableSlots, maxPlayers)
            return
        end

        if requestedAmount <= 0 then
            client:notifyErrorLocalized("spawnBotsInvalidAmount")
            return
        end

        local botsSpawned = 0
        client:notifyInfoLocalized("spawningBots", requestedAmount)
        for i = 1, requestedAmount do
            timer.Simple((i - 1) * 0.5, function()
                if not IsValid(client) then return end
                game.ConsoleCommand("bot\n")
                botsSpawned = botsSpawned + 1
            end)
        end

        timer.Simple(requestedAmount * 0.5 + 2, function() if IsValid(client) then client:notifySuccessLocalized("botsSpawnedSimple", botsSpawned) end end)
    end
})

lia.command.add("bot", {
    superAdminOnly = true,
    desc = "spawnBotDesc",
    onRun = function(client)
        if not SERVER then return end
        local maxPlayers = game.MaxPlayers()
        if player.GetCount() >= maxPlayers then
            client:notifyErrorLocalized("spawnBotsLimit", 1, 0, maxPlayers)
            return
        end

        client:notifyInfoLocalized("spawningBots", 1)
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
                client:notifySuccessLocalized("botSpawnedAndBrought", botName)
            else
                client:notifyErrorLocalized("botSpawnFailed")
            end
        end)
    end
})

lia.command.add("botspeak", {
    superAdminOnly = true,
    desc = "botsSpeakDesc",
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
            client:notifyErrorLocalized("noBotsFound")
            return
        end

        client:notifyInfoLocalized("foundBotsStarting", #bots, phrasesPerBot)
        local randomPhrases = {L("chatHelloThere"), L("chatWhatsGoingOn"), L("chatNeedHelp"), L("chatOverHere"), L("chatWatchOut"), L("chatComeOn"), L("chatLetsGo"), L("chatThisWay"), L("chatBehindYou"), L("chatEnemySpotted"), L("chatClear"), L("chatMoveUp"), L("chatHoldPosition"), L("chatCoverMe"), L("chatReloading"), L("chatTakingFire"), L("chatNeedBackup"), L("chatAllClear"), L("chatContact"), L("chatEngaging"), L("chatFallBack"), L("chatPushForward"), L("chatHoldTheLine"), L("chatSecureArea"), L("chatEnemyDown"), L("chatGotOne"), L("chatNiceShot"), L("chatGoodWork"), L("chatKeepMoving"), L("chatStayAlert")}
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
                    client:notifySuccessLocalized("botFinishedPhrases", bot:GetName() or tostring(bot), phrasesPerBot)
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

            client:notifySuccessLocalized("allBotsFinished", totalPhrases)
        end)
    end
})

lia.command.add("charsetattrib", {
    superAdminOnly = true,
    desc = "setAttributes",
    arguments = {
        {
            name = "name",
            type = "player"
        },
        {
            name = "attribute",
            type = "table",
            options = function()
                local options = {}
                for k, v in pairs(lia.attribs.list) do
                    options[L(v.name)] = k
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
        Name = "setAttributes",
        Category = "characterManagement",
        SubCategory = "attributes",
        Icon = "icon16/wrench.png"
    },
    onRun = function(client, arguments)
        if table.IsEmpty(lia.attribs.list) then
            client:notifyErrorLocalized("noAttributesRegistered")
            return
        end

        local target = lia.util.findPlayer(client, arguments[1])
        local attribName = arguments[2]
        local attribNumber = tonumber(arguments[3])
        if not target or not IsValid(target) then
            client:notifyErrorLocalized("targetNotFound")
            return
        end

        lia.log.add(client, "attribCheck", target:Name())
        local character = target:getChar()
        if character then
            for k, v in pairs(lia.attribs.list) do
                if lia.util.stringMatches(L(v.name), attribName) or lia.util.stringMatches(k, attribName) then
                    character:setAttrib(k, math.abs(attribNumber))
                    client:notifySuccessLocalized("attribSet", target:Name(), L(v.name), math.abs(attribNumber))
                    lia.log.add(client, "attribSet", target:Name(), k, math.abs(attribNumber))
                    return
                end
            end
        end
    end
})

lia.command.add("checkattributes", {
    adminOnly = true,
    desc = "checkAttributes",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "checkAttributes",
        Category = "characterManagement",
        SubCategory = "attributes",
        Icon = "icon16/zoom.png"
    },
    onRun = function(client, arguments)
        if table.IsEmpty(lia.attribs.list) then
            client:notifyErrorLocalized("noAttributesRegistered")
            return
        end

        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyErrorLocalized("targetNotFound")
            return
        end

        local attributesData = {}
        for attrKey, attrData in SortedPairsByMemberValue(lia.attribs.list, "name") do
            local currentValue = target:getChar():getAttrib(attrKey, 0) or 0
            local maxValue = hook.Run("GetAttributeMax", target, attrKey) or 100
            local progress = math.Round(currentValue / maxValue * 100, 1)
            table.insert(attributesData, {
                charID = attrData.name,
                name = L(attrData.name),
                current = currentValue,
                max = maxValue,
                progress = progress .. "%"
            })
        end

        lia.util.sendTableUI(client, "characterAttributes", {
            {
                name = "attributeName",
                field = "name"
            },
            {
                name = "currentValue",
                field = "current"
            },
            {
                name = "maxValue",
                field = "max"
            },
            {
                name = "progress",
                field = "progress"
            }
        }, attributesData, {
            {
                name = "changeAttribute",
                ExtraFields = {
                    [L("attribAmount")] = "text",
                    [L("attribMode")] = {L("add"), L("set")}
                },
                net = "ChangeAttribute"
            }
        }, client:getChar():getID())
    end
})

lia.command.add("staffdiscord", {
    desc = "staffdiscordDesc",
    arguments = {
        {
            name = "discord",
            type = "string"
        }
    },
    onRun = function(client, arguments)
        local discord = arguments[1]
        local character = client:getChar()
        if not character or character:getFaction() ~= FACTION_STAFF then
            client:notifyErrorLocalized("noStaffChar")
            return
        end

        client:setLiliaData("staffDiscord", discord)
        local description = L("staffCharacterDiscordSteamID", discord, client:SteamID())
        character:setDesc(description)
        client:notifySuccessLocalized("staffDescUpdated")
    end
})

lia.command.add("trunk", {
    adminOnly = false,
    desc = "trunkOpenDesc",
    onRun = function(client)
        local entity = client:getTracedEntity()
        local maxDistance = 128
        local openTime = 0.7
        if not IsValid(entity) then
            client:notifyErrorLocalized("notLookingAtVehicle")
            return
        end

        if hook.Run("IsSuitableForTrunk", entity) == false then
            client:notifyErrorLocalized("notLookingAtVehicle")
            return
        end

        if client:GetPos():Distance(entity:GetPos()) > maxDistance then
            client:notifyErrorLocalized("tooFarToOpenTrunk")
            return
        end

        client.liaStorageEntity = entity
        client:setAction(L("openingTrunk"), openTime, function()
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
                    client:notifyErrorLocalized("noInventory")
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
                    client:notifyErrorLocalized("unableCreateStorageEntity", entity:GetClass(), err)
                    client.liaStorageEntity = nil
                end)
            end
        end)
    end
})

lia.command.add("restockvendor", {
    superAdminOnly = true,
    desc = "restockVendorDesc",
    AdminStick = {
        Name = "restockVendorStickName",
        TargetClass = "lia_vendor",
        Icon = "icon16/box.png"
    },
    onRun = function(client)
        local target = client:getTracedEntity()
        if not target or not IsValid(target) then
            client:notifyErrorLocalized("targetNotFound")
            return
        end

        if target:GetClass() == "lia_vendor" then
            for id, itemData in pairs(target.items) do
                if itemData[2] and itemData[4] then target.items[id][2] = itemData[4] end
            end

            client:notifySuccessLocalized("vendorRestocked")
            lia.log.add(client, "restockvendor", target)
        else
            client:notifyErrorLocalized("notLookingAtValidVendor")
        end
    end
})

lia.command.add("restockallvendors", {
    superAdminOnly = true,
    desc = "restockAllVendorsDesc",
    onRun = function(client)
        local count = 0
        for _, vendor in ipairs(ents.FindByClass("lia_vendor")) do
            for id, itemData in pairs(vendor.items) do
                if itemData[2] and itemData[4] then vendor.items[id][2] = itemData[4] end
            end

            count = count + 1
            lia.log.add(client, "restockvendor", vendor)
        end

        client:notifySuccessLocalized("vendorAllVendorsRestocked", count)
        lia.log.add(client, "restockallvendors", count)
    end
})

lia.command.add("deletevendorpreset", {
    adminOnly = true,
    desc = "deleteVendorPresetDesc",
    arguments = {
        {
            name = "presetName",
            type = "string"
        },
    },
    onRun = function(client, arguments)
        if not client:hasPrivilege("canCreateVendorPresets") then
            client:notifyErrorLocalized("noPermission")
            return
        end

        local presetName = arguments[1]
        if not presetName or presetName:Trim() == "" then
            client:notifyErrorLocalized("vendorPresetNameRequired")
            return
        end

        presetName = presetName:Trim():lower()
        if not lia.vendor.presets[presetName] then
            client:notifyErrorLocalized("vendorPresetNotFound", presetName)
            return
        end

        lia.vendor.presets[presetName] = nil
        if SERVER then
            lia.db.delete("vendor_presets", "name = " .. lia.db.convertDataType(presetName))
            net.Start("liaVendorSyncPresets")
            net.WriteTable(lia.vendor.presets)
            net.Broadcast()
        end

        client:notifySuccessLocalized("vendorPresetDeleted", presetName)
        lia.log.add(client, "deletevendorpreset", presetName)
    end
})

lia.command.add("listvendorpresets", {
    adminOnly = true,
    desc = "listVendorPresetsDesc",
    onRun = function(client)
        if not client:hasPrivilege("canCreateVendorPresets") then
            client:notifyErrorLocalized("noPermission")
            return
        end

        local presets = {}
        for name in pairs(lia.vendor.presets or {}) do
            presets[#presets + 1] = name
        end

        if #presets == 0 then
            client:notifyInfoLocalized("vendorNoPresets")
        else
            table.sort(presets)
            client:notifyInfoLocalized("vendorPresetList", table.concat(presets, ", "))
        end
    end
})

lia.command.add("charaddattrib", {
    superAdminOnly = true,
    desc = "addAttributes",
    arguments = {
        {
            name = "name",
            type = "player"
        },
        {
            name = "attribute",
            type = "table",
            options = function()
                local options = {}
                for k, v in pairs(lia.attribs.list) do
                    options[L(v.name)] = k
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
        Name = "addAttributes",
        Category = "characterManagement",
        SubCategory = "attributes",
        Icon = "icon16/add.png"
    },
    onRun = function(client, arguments)
        if table.IsEmpty(lia.attribs.list) then
            client:notifyErrorLocalized("noAttributesRegistered")
            return
        end

        local target = lia.util.findPlayer(client, arguments[1])
        local attribName = arguments[2]
        local attribNumber = tonumber(arguments[3])
        if not target or not IsValid(target) then
            client:notifyErrorLocalized("targetNotFound")
            return
        end

        local character = target:getChar()
        if character then
            for k, v in pairs(lia.attribs.list) do
                if lia.util.stringMatches(L(v.name), attribName) or lia.util.stringMatches(k, attribName) then
                    character:updateAttrib(k, math.abs(attribNumber))
                    client:notifySuccessLocalized("attribUpdate", target:Name(), L(v.name), math.abs(attribNumber))
                    lia.log.add(client, "attribAdd", target:Name(), k, math.abs(attribNumber))
                    return
                end
            end
        end
    end
})

lia.command.add("banooc", {
    adminOnly = true,
    desc = "banOOCCommandDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "banOOCStickName",
        Category = "utility",
        SubCategory = "ooc",
        Icon = "icon16/sound_mute.png"
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyErrorLocalized("targetNotFound")
            return
        end

        target:setLiliaData("oocBanned", true)
        client:notifySuccessLocalized("playerBannedFromOOC", target:Name())
        lia.log.add(client, "banOOC", target:Name(), target:SteamID())
    end
})

lia.command.add("unbanooc", {
    adminOnly = true,
    desc = "unbanOOCCommandDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "unbanOOCStickName",
        Category = "utility",
        SubCategory = "ooc",
        Icon = "icon16/sound.png"
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyErrorLocalized("targetNotFound")
            return
        end

        target:setLiliaData("oocBanned", nil)
        client:notifySuccessLocalized("playerUnbannedFromOOC", target:Name())
        lia.log.add(client, "unbanOOC", target:Name(), target:SteamID())
    end
})

lia.command.add("clearchat", {
    adminOnly = true,
    desc = "clearChatCommandDesc",
    onRun = function(client)
        net.Start("liaRegenChat")
        net.Broadcast()
        lia.log.add(client, "clearChat")
    end
})

lia.command.add("doorsell", {
    desc = "doorsellDesc",
    adminOnly = false,
    AdminStick = {
        Name = "adminStickDoorSellName",
        Category = "doorManagement",
        SubCategory = "doorActions",
        TargetClass = "door",
        Icon = "icon16/money.png"
    },
    onRun = function(client)
        local door = client:getTracedEntity()
        if IsValid(door) and door:isDoor() then
            local doorData = lia.doors.getData(door)
            if not doorData.disabled then
                if client == door:GetDTEntity(0) then
                    local price = math.Round((doorData.price or 0) * lia.config.get("DoorSellRatio", 0.5))
                    door:removeDoorAccessData()
                    client:getChar():giveMoney(price)
                    client:notifyMoneyLocalized("doorSold", lia.currency.get(price))
                    hook.Run("OnPlayerPurchaseDoor", client, door, false)
                    lia.log.add(client, "doorsell", price)
                else
                    client:notifyErrorLocalized("doorNotOwner")
                end
            else
                client:notifyErrorLocalized("doorNotValid")
            end
        else
            client:notifyErrorLocalized("doorNotValid")
        end
    end
})

lia.command.add("admindoorsell", {
    desc = "admindoorsellDesc",
    adminOnly = true,
    AdminStick = {
        Name = "adminStickAdminDoorSellName",
        Category = "doorManagement",
        SubCategory = "doorActions",
        TargetClass = "door",
        Icon = "icon16/money_delete.png"
    },
    onRun = function(client)
        local door = client:getTracedEntity()
        if IsValid(door) and door:isDoor() then
            local doorData = lia.doors.getData(door)
            if not doorData.disabled then
                local owner = door:GetDTEntity(0)
                if IsValid(owner) and owner:IsPlayer() then
                    local price = math.Round((doorData.price or 0) * lia.config.get("DoorSellRatio", 0.5))
                    door:removeDoorAccessData()
                    owner:getChar():giveMoney(price)
                    owner:notifyMoneyLocalized("doorSold", lia.currency.get(price))
                    client:notifyMoneyLocalized("doorSold", lia.currency.get(price))
                    hook.Run("OnPlayerPurchaseDoor", owner, door, false)
                    lia.log.add(client, "admindoorsell", owner:Name(), price)
                else
                    client:notifyErrorLocalized("doorNotOwner")
                end
            else
                client:notifyErrorLocalized("doorNotValid")
            end
        else
            client:notifyErrorLocalized("doorNotValid")
        end
    end
})

lia.command.add("doortogglelock", {
    desc = "doortogglelockDesc",
    adminOnly = true,
    AdminStick = {
        Name = "adminStickToggleDoorLockName",
        Category = "doorManagement",
        SubCategory = "doorSettings",
        TargetClass = "door",
        Icon = "icon16/lock.png"
    },
    onRun = function(client)
        local door = client:getTracedEntity()
        if IsValid(door) and door:isDoor() then
            local doorData = lia.doors.getData(door)
            if not doorData.disabled then
                local currentLockState = door:GetInternalVariable("m_bLocked")
                local toggleState = not currentLockState
                if toggleState then
                    door:Fire("lock")
                    door:EmitSound("doors/door_latch3.wav")
                    doorData.locked = true
                    lia.doors.setCachedData(door, doorData)
                    client:notifyInfoLocalized("doorToggleLocked", L("locked"):lower())
                    lia.log.add(client, "toggleLock", door, L("locked"))
                else
                    door:Fire("unlock")
                    door:EmitSound("doors/door_latch1.wav")
                    doorData.locked = false
                    lia.doors.setCachedData(door, doorData)
                    client:notifyInfoLocalized("doorToggleLocked", L("unlocked"))
                    lia.log.add(client, "toggleLock", door, L("unlocked"))
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
                client:notifyErrorLocalized("doorNotValid")
            end
        else
            client:notifyErrorLocalized("doorNotValid")
        end
    end
})

lia.command.add("doorbuy", {
    desc = "doorbuyDesc",
    adminOnly = false,
    AdminStick = {
        Name = "buyDoor",
        Category = "doorManagement",
        SubCategory = "doorActions",
        TargetClass = "door",
        Icon = "icon16/money_add.png"
    },
    onRun = function(client)
        local door = client:getTracedEntity()
        if IsValid(door) and door:isDoor() then
            local doorData = lia.doors.getData(door)
            if not doorData.disabled then
                local factions = doorData.factions
                local classes = doorData.classes
                if doorData.noSell or (factions and #factions > 0) or (classes and #classes > 0) then return client:notifyErrorLocalized("doorNotAllowedToOwn") end
                if IsValid(door:GetDTEntity(0)) then
                    client:notifyInfoLocalized("doorOwnedBy", door:GetDTEntity(0):Name())
                    return false
                end

                local price = doorData.price or 0
                if client:getChar():hasMoney(price) then
                    door:SetDTEntity(0, client)
                    door.liaAccess = {
                        [client] = DOOR_OWNER
                    }

                    client:getChar():takeMoney(price)
                    client:notifySuccessLocalized("doorPurchased", lia.currency.get(price))
                    hook.Run("OnPlayerPurchaseDoor", client, door, true)
                    lia.log.add(client, "buydoor", price)
                else
                    client:notifyErrorLocalized("doorCanNotAfford")
                end
            else
                client:notifyErrorLocalized("doorNotValid")
            end
        else
            client:notifyErrorLocalized("doorNotValid")
        end
    end
})

lia.command.add("doortoggleownable", {
    desc = "doortoggleownableDesc",
    adminOnly = true,
    AdminStick = {
        Name = "adminStickToggleDoorOwnableName",
        Category = "doorManagement",
        SubCategory = "doorSettings",
        TargetClass = "door",
        Icon = "icon16/pencil.png"
    },
    onRun = function(client)
        local door = client:getTracedEntity()
        if IsValid(door) and door:isDoor() then
            local doorData = lia.doors.getData(door)
            if not doorData.disabled then
                local factions = doorData.factions or {}
                local classes = doorData.classes or {}
                local hasFactions = factions and #factions > 0
                local hasClasses = classes and #classes > 0
                local isUnownable = doorData.noSell or false
                local newState = not isUnownable
                if newState and (hasFactions or hasClasses) then
                    client:notifyErrorLocalized("doorIsNotOwnable")
                    return false
                end

                doorData.noSell = newState and true or nil
                lia.doors.setData(door, doorData)
                lia.log.add(client, "doorToggleOwnable", door, newState)
                hook.Run("DoorOwnableToggled", client, door, newState)
                client:notifySuccessLocalized(newState and "doorMadeUnownable" or "doorMadeOwnable")
                lia.module.get("doors"):SaveData()
            else
                client:notifyErrorLocalized("doorNotValid")
            end
        else
            client:notifyErrorLocalized("doorNotValid")
        end
    end
})

lia.command.add("doorresetdata", {
    desc = "doorresetdataDesc",
    adminOnly = true,
    AdminStick = {
        Name = "adminStickResetDoorDataName",
        Category = "doorManagement",
        SubCategory = "doorMaintenance",
        TargetClass = "door",
        Icon = "icon16/arrow_refresh.png"
    },
    onRun = function(client)
        local door = client:getTracedEntity()
        if IsValid(door) and door:isDoor() then
            lia.log.add(client, "doorResetData", door)
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
            client:notifySuccessLocalized("doorResetData")
            lia.module.get("doors"):SaveData()
        else
            client:notifyErrorLocalized("doorNotValid")
        end
    end
})

lia.command.add("doortoggleenabled", {
    desc = "doortoggleenabledDesc",
    adminOnly = true,
    AdminStick = {
        Name = "adminStickToggleDoorEnabledName",
        Category = "doorManagement",
        SubCategory = "doorSettings",
        TargetClass = "door",
        Icon = "icon16/stop.png"
    },
    onRun = function(client)
        local door = client:getTracedEntity()
        if IsValid(door) and door:isDoor() then
            local doorData = lia.doors.getData(door)
            local isDisabled = doorData.disabled or false
            local newState = not isDisabled
            doorData.disabled = newState and true or nil
            lia.doors.setData(door, doorData)
            lia.log.add(client, newState and "doorDisable" or "doorEnable", door)
            hook.Run("DoorEnabledToggled", client, door, newState)
            client:notifySuccessLocalized(newState and "doorSetDisabled" or "doorSetNotDisabled")
            lia.module.get("doors").list["doors"]:SaveData()
        else
            client:notifyErrorLocalized("doorNotValid")
        end
    end
})

lia.command.add("doortogglehidden", {
    desc = "doortogglehiddenDesc",
    adminOnly = true,
    AdminStick = {
        Name = "adminStickToggleDoorHiddenName",
        Category = "doorManagement",
        SubCategory = "doorSettings",
        TargetClass = "door",
        Icon = "icon16/eye.png"
    },
    onRun = function(client)
        local entity = client:GetEyeTrace().Entity
        if IsValid(entity) and entity:isDoor() then
            local doorData = lia.doors.getData(entity)
            local currentState = doorData.hidden or false
            local newState = not currentState
            doorData.hidden = newState
            lia.doors.setData(entity, doorData)
            lia.log.add(client, "doorSetHidden", entity, newState)
            hook.Run("DoorHiddenToggled", client, entity, newState)
            client:notifySuccessLocalized(newState and "doorSetHidden" or "doorSetNotHidden")
            lia.module.get("doors"):SaveData()
        else
            client:notifyErrorLocalized("doorNotValid")
        end
    end
})

lia.command.add("doorsetprice", {
    desc = "doorsetpriceDesc",
    arguments = {
        {
            name = "price",
            type = "string"
        },
    },
    adminOnly = true,
    AdminStick = {
        Name = "adminStickSetDoorPriceName",
        Category = "doorManagement",
        SubCategory = "doorSettings",
        TargetClass = "door",
        Icon = "icon16/money.png"
    },
    onRun = function(client, arguments)
        local door = client:getTracedEntity()
        if IsValid(door) and door:isDoor() then
            local doorData = lia.doors.getData(door)
            if not doorData.disabled then
                if not arguments[1] or not tonumber(arguments[1]) then return client:notifyErrorLocalized("invalidClass") end
                local price = math.Clamp(math.floor(tonumber(arguments[1])), 0, 1000000)
                doorData.price = price
                lia.doors.setData(door, doorData)
                lia.log.add(client, "doorSetPrice", door, price)
                hook.Run("DoorPriceSet", client, door, price)
                client:notifySuccessLocalized("doorSetPrice", lia.currency.get(price))
                lia.module.get("doors"):SaveData()
            else
                client:notifyErrorLocalized("doorNotValid")
            end
        else
            client:notifyErrorLocalized("doorNotValid")
        end
    end
})

lia.command.add("doorsettitle", {
    desc = "doorsettitleDesc",
    arguments = {
        {
            name = "title",
            type = "string"
        },
    },
    adminOnly = true,
    AdminStick = {
        Name = "adminStickSetDoorTitleName",
        Category = "doorManagement",
        SubCategory = "doorSettings",
        TargetClass = "door",
        Icon = "icon16/textfield.png"
    },
    onRun = function(client, arguments)
        local door = client:getTracedEntity()
        if IsValid(door) and door:isDoor() then
            local doorData = lia.doors.getData(door)
            if not doorData.disabled then
                local name = table.concat(arguments, " ")
                if not name:find("%S") then return client:notifyErrorLocalized("invalidClass") end
                if door:checkDoorAccess(client, DOOR_TENANT) or client:isStaff() then
                    doorData.name = name
                    lia.doors.setData(door, doorData)
                    hook.Run("DoorTitleSet", client, door, name)
                    lia.log.add(client, "doorSetTitle", door, name)
                    client:notifySuccessLocalized("doorTitleSet", name)
                else
                    client:notifyErrorLocalized("doorNotOwner")
                end
            else
                client:notifyErrorLocalized("doorNotValid")
            end
        else
            client:notifyErrorLocalized("doorNotValid")
        end
    end
})

lia.command.add("savedoors", {
    desc = "savedoorsDesc",
    adminOnly = true,
    AdminStick = {
        Name = "adminStickSaveDoorsName",
        Category = "doorManagement",
        SubCategory = "doorMaintenance",
        TargetClass = "door",
        Icon = "icon16/disk.png"
    },
    onRun = function(client)
        lia.module.get("doors"):SaveData()
        lia.log.add(client, "doorSaveData")
        client:notifySuccessLocalized("doorsSaved")
    end
})

lia.command.add("doorinfo", {
    desc = "doorinfoDesc",
    adminOnly = true,
    AdminStick = {
        Name = "adminStickDoorInfoName",
        Category = "doorManagement",
        SubCategory = "doorInformation",
        TargetClass = "door",
        Icon = "icon16/information.png"
    },
    onRun = function(client)
        local door = client:getTracedEntity()
        if IsValid(door) and door:isDoor() then
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
            local locked = doorData.locked or false
            local infoData = {
                {
                    property = L("doorInfoDisabled"),
                    value = tostring(disabled)
                },
                {
                    property = L("name"),
                    value = tostring(doorData.name or L("doorTitle"))
                },
                {
                    property = L("price"),
                    value = lia.currency.get(price)
                },
                {
                    property = L("doorInfoNoSell"),
                    value = tostring(noSell)
                },
                {
                    property = L("factions"),
                    value = tostring(not table.IsEmpty(factionNames) and table.concat(factionNames, ", ") or L("none"))
                },
                {
                    property = L("classes"),
                    value = tostring(not table.IsEmpty(classNames) and table.concat(classNames, ", ") or L("none"))
                },
                {
                    property = L("doorInfoHidden"),
                    value = tostring(hidden)
                },
                {
                    property = L("locked"),
                    value = tostring(locked)
                }
            }

            lia.util.sendTableUI(client, L("door") .. " " .. L("information"), {
                {
                    name = "doorInfoProperty",
                    field = "property"
                },
                {
                    name = "doorInfoValue",
                    field = "value"
                }
            }, infoData)
        else
            client:notifyErrorLocalized("doorNotValid")
        end
    end
})

lia.command.add("doorsampledata", {
    desc = "doorsampledataDesc",
    adminOnly = true,
    AdminStick = {
        Name = L("adminStickDoorSampleName"),
        Category = "doorManagement",
        SubCategory = "doorInformation",
        TargetClass = "door",
        Icon = "icon16/add.png"
    },
    onRun = function(client)
        local door = client:getTracedEntity()
        if IsValid(door) and door:isDoor() then
            local doorData = lia.doors.getData(door)
            local sampleData = {
                name = "Sample Door " .. (door:MapCreationID() or "Unknown"),
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
            client:notifyLocalized("doorSampleDataApplied")
            lia.log.add(client, "doorSampleData", door)
        else
            client:notifyErrorLocalized("doorNotValid")
        end
    end
})

lia.command.add("dooraddfaction", {
    desc = "dooraddfactionDesc",
    arguments = {
        {
            name = "faction",
            type = "string"
        }
    },
    adminOnly = true,
    onRun = function(client, arguments)
        local door = client:getTracedEntity()
        if IsValid(door) and door:isDoor() then
            local doorData = lia.doors.getData(door)
            if not doorData.disabled then
                local input = arguments[1]
                local faction
                if input then
                    local factionIndex = tonumber(input)
                    if factionIndex then
                        faction = lia.faction.indices[factionIndex]
                        if not faction then
                            client:notifyErrorLocalized("invalidFaction")
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
                    lia.log.add(client, "doorSetFaction", door, faction.name)
                    client:notifySuccessLocalized("doorSetFaction", faction.name)
                elseif arguments[1] then
                    client:notifyErrorLocalized("invalidFaction")
                else
                    doorData.factions = {}
                    door.liaFactions = nil
                    lia.doors.setData(door, doorData)
                    lia.log.add(client, "doorRemoveFaction", door, "all")
                    client:notifySuccessLocalized("doorRemoveFaction")
                end

                lia.module.get("doors"):SaveData()
            else
                client:notifyErrorLocalized("doorNotValid")
            end
        else
            client:notifyErrorLocalized("doorNotValid")
        end
    end
})

lia.command.add("doorremovefaction", {
    desc = "doorremovefactionDesc",
    arguments = {
        {
            name = "faction",
            type = "string"
        }
    },
    adminOnly = true,
    onRun = function(client, arguments)
        local door = client:getTracedEntity()
        if IsValid(door) and door:isDoor() then
            local doorData = lia.doors.getData(door)
            if not doorData.disabled then
                local input = arguments[1]
                local faction
                if input then
                    local factionIndex = tonumber(input)
                    if factionIndex then
                        faction = lia.faction.indices[factionIndex]
                        if not faction then
                            client:notifyErrorLocalized("invalidFaction")
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
                    lia.log.add(client, "doorRemoveFaction", door, faction.name)
                    client:notifySuccessLocalized("doorRemoveFactionSpecific", faction.name)
                elseif arguments[1] then
                    client:notifyErrorLocalized("invalidFaction")
                else
                    doorData.factions = {}
                    door.liaFactions = nil
                    lia.doors.setData(door, doorData)
                    lia.log.add(client, "doorRemoveFaction", door, "all")
                    client:notifySuccessLocalized("doorRemoveFaction")
                end

                lia.module.get("doors"):SaveData()
            else
                client:notifyErrorLocalized("doorNotValid")
            end
        else
            client:notifyErrorLocalized("doorNotValid")
        end
    end
})

lia.command.add("doorsetclass", {
    desc = "doorsetclassDesc",
    arguments = {
        {
            name = "class",
            type = "string"
        }
    },
    adminOnly = true,
    onRun = function(client, arguments)
        local door = client:getTracedEntity()
        if IsValid(door) and door:isDoor() then
            local doorData = lia.doors.getData(door)
            if not doorData.disabled then
                local input = arguments[1]
                local class, classData
                if input then
                    local classIndex = tonumber(input)
                    if classIndex then
                        classData = lia.class.list[classIndex]
                        if classData then
                            class = classIndex
                        else
                            client:notifyErrorLocalized("invalidClass")
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
                    lia.log.add(client, "doorSetClass", door, classData.name)
                    client:notifySuccessLocalized("doorSetClass", classData.name)
                elseif arguments[1] then
                    client:notifyErrorLocalized("invalidClass")
                else
                    doorData.classes = {}
                    door.liaClasses = nil
                    lia.doors.setData(door, doorData)
                    lia.log.add(client, "doorRemoveClass", door)
                    client:notifySuccessLocalized("doorRemoveClass")
                end

                lia.module.get("doors"):SaveData()
            else
                client:notifyErrorLocalized("doorNotValid")
            end
        else
            client:notifyErrorLocalized("doorNotValid")
        end
    end,
    alias = {"jobdoor"}
})

lia.command.add("doorremoveclass", {
    desc = "doorremoveclassDesc",
    arguments = {
        {
            name = "class",
            type = "string"
        }
    },
    adminOnly = true,
    AdminStick = {
        Name = "adminStickDoorRemoveClassName",
        Category = "doorManagement",
        SubCategory = "doorSettings",
        TargetClass = "door",
        Icon = "icon16/delete.png"
    },
    onRun = function(client, arguments)
        local door = client:getTracedEntity()
        if IsValid(door) and door:isDoor() then
            local doorData = lia.doors.getData(door)
            if not doorData.disabled then
                local input = arguments[1]
                local class, classData
                if input then
                    local classIndex = tonumber(input)
                    if classIndex then
                        classData = lia.class.list[classIndex]
                        if classData then
                            class = classIndex
                        else
                            client:notifyErrorLocalized("invalidClass")
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
                        lia.log.add(client, "doorRemoveClassSpecific", door, classData.name)
                        client:notifySuccessLocalized("doorRemoveClassSpecific", classData.name)
                    else
                        client:notifyErrorLocalized("doorClassNotAssigned", classData.name)
                    end
                elseif arguments[1] then
                    client:notifyErrorLocalized("invalidClass")
                else
                    doorData.classes = {}
                    door.liaClasses = nil
                    lia.doors.setData(door, doorData)
                    lia.log.add(client, "doorRemoveClass", door)
                    client:notifySuccessLocalized("doorRemoveClass")
                end

                lia.module.get("doors"):SaveData()
            else
                client:notifyErrorLocalized("doorNotValid")
            end
        else
            client:notifyErrorLocalized("doorNotValid")
        end
    end
})

lia.command.add("togglealldoors", {
    desc = "togglealldoorsDesc",
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
                    lia.log.add(client, toggleToDisable and "doorDisable" or "doorEnable", door)
                    count = count + 1
                end
            end
        end

        client:notifySuccessLocalized(toggleToDisable and "doorDisableAll" or "doorEnableAll", count)
        lia.log.add(client, toggleToDisable and "doorDisableAll" or "doorEnableAll", count)
        lia.module.get("doors"):SaveData()
    end
})

lia.command.add("doorid", {
    desc = "doorIDDesc",
    adminOnly = true,
    onRun = function(client)
        local door = client:getTracedEntity()
        if IsValid(door) and door:isDoor() then
            local mapID = door:MapCreationID()
            if mapID and mapID > 0 then
                local pos = door:GetPos()
                client:notifyInfoLocalized("doorID" .. " " .. mapID .. " | " .. L("position") .. ": " .. string.format("%.0f, %.0f, %.0f", pos.x, pos.y, pos.z))
                lia.log.add(client, "doorID", door, mapID)
            else
                client:notifyErrorLocalized("doorNoValidMapID")
            end
        else
            client:notifyErrorLocalized("doorMustBeLookingAt")
        end
    end
})

lia.command.add("listdoorids", {
    desc = "listDoorIDsDesc",
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
                        model = door:GetModel() or L("unknown")
                    })
                end
            end
        end

        if #doorData == 0 then
            client:notifyInfoLocalized("doorNoDoorsFound")
            return
        end

        table.sort(doorData, function(a, b) return a.id < b.id end)
        local doorList = {}
        for _, data in ipairs(doorData) do
            table.insert(doorList, {
                property = L("doorIDProperty") .. data.id,
                value = L("positionLabel") .. data.position .. L("modelLabel") .. data.model
            })
        end

        lia.util.sendTableUI(client, L("doorIDsOnMap", game.GetMap()), {
            {
                name = L("doorIDColumn"),
                field = "property"
            },
            {
                name = L("detailsColumn"),
                field = "value"
            }
        }, doorList)

        client:notifyInfoLocalized("doorFoundCount", #doorData)
    end
})

lia.command.add("plytransfer", {
    adminOnly = true,
    desc = "plyTransferDesc",
    alias = {"charsetfaction"},
    arguments = {
        {
            name = "name",
            type = "player"
        },
        {
            name = "faction",
            type = "table",
            options = function()
                local options = {}
                for k, v in pairs(lia.faction.teams) do
                    if k ~= "staff" then options[L(v.name)] = k end
                end
                return options
            end
        }
    },
    onRun = function(client, arguments)
        local targetPlayer = lia.util.findPlayer(client, arguments[1])
        if not targetPlayer or not IsValid(targetPlayer) then
            client:notifyErrorLocalized("targetNotFound")
            return
        end

        local factionName = arguments[2]
        local faction = lia.faction.teams[factionName] or lia.util.findFaction(client, factionName)
        if not faction then
            client:notifyErrorLocalized("invalidFaction")
            return
        end

        if faction.uniqueID == "staff" then
            client:notifyErrorLocalized("staffTransferBlocked")
            return
        end

        local targetChar = targetPlayer:getChar()
        if hook.Run("CanCharBeTransfered", targetChar, faction, targetPlayer:Team()) == false then return end
        local oldFaction = targetChar:getFaction()
        local oldFactionName = lia.faction.indices[oldFaction] and lia.faction.indices[oldFaction].name or oldFaction
        targetChar.vars.faction = faction.uniqueID
        targetChar:setFaction(faction.index)
        hook.Run("OnTransferred", targetPlayer)
        if faction.OnTransferred then faction:OnTransferred(targetPlayer, oldFaction) end
        client:notifySuccessLocalized("transferSuccess", targetPlayer:Name(), L(faction.name, client))
        if client ~= targetPlayer then targetPlayer:notifyInfoLocalized("transferNotification", L(faction.name, targetPlayer), client:Name()) end
        lia.log.add(client, "plyTransfer", targetPlayer:Name(), oldFactionName, faction.name)
    end
})

lia.command.add("plywhitelist", {
    adminOnly = true,
    desc = "plyWhitelistDesc",
    alias = {"factionwhitelist"},
    arguments = {
        {
            name = "name",
            type = "player"
        },
        {
            name = "faction",
            type = "table",
            options = function()
                local options = {}
                for k, v in pairs(lia.faction.teams) do
                    if k ~= "staff" then options[L(v.name)] = k end
                end
                return options
            end
        }
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyErrorLocalized("targetNotFound")
            return
        end

        local faction = lia.util.findFaction(client, arguments[2])
        if not faction then
            client:notifyErrorLocalized("invalidFaction")
            return
        end

        if faction.uniqueID == "staff" then
            client:notifyErrorLocalized("staffWhitelistBlocked")
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
                v:notifyInfoLocalized("whitelist", client:Name(), target:Name(), L(faction.name, v))
            end

            lia.log.add(client, "plyWhitelist", target:Name(), faction.name)
        end
    end
})

lia.command.add("plyunwhitelist", {
    adminOnly = true,
    desc = "plyUnwhitelistDesc",
    alias = {"factionunwhitelist"},
    arguments = {
        {
            name = "name",
            type = "player"
        },
        {
            name = "faction",
            type = "table",
            options = function()
                local options = {}
                for k, v in pairs(lia.faction.teams) do
                    if k ~= "staff" then options[L(v.name)] = k end
                end
                return options
            end
        }
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyErrorLocalized("targetNotFound")
            return
        end

        local faction = lia.util.findFaction(client, arguments[2])
        if not faction then
            client:notifyErrorLocalized("invalidFaction")
            return
        end

        if faction.uniqueID == "staff" then
            client:notifyErrorLocalized("staffUnwhitelistBlocked")
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
                    v:notifyInfoLocalized("unwhitelist", client:Name(), target:Name(), L(faction.name, v))
                end

                lia.log.add(client, "plyUnwhitelist", target:Name(), faction.name)
            end
        else
            client:notifyErrorLocalized("invalidFaction")
        end
    end
})

lia.command.add("beclass", {
    adminOnly = false,
    desc = "beClassDesc",
    arguments = {
        {
            name = "class",
            type = "table",
            options = function()
                local options = {}
                for _, v in pairs(lia.class.list) do
                    options[L(v.name)] = v.uniqueID
                end
                return options
            end
        }
    },
    onRun = function(client, arguments)
        local className = arguments[1]
        local character = client:getChar()
        if not IsValid(client) or not character then
            client:notifyErrorLocalized("illegalAccess")
            return
        end

        local classID = tonumber(className) or lia.class.retrieveClass(className)
        local classData = lia.class.get(classID)
        if classData and lia.class.canBe(client, classID) then
            if character:joinClass(classID) then
                client:notifySuccessLocalized("becomeClass", L(classData.name))
                lia.log.add(client, "beClass", classData.name)
            else
                client:notifyErrorLocalized("becomeClassFail", L(classData.name))
            end
        else
            client:notifyErrorLocalized("invalidClass")
        end
    end
})

lia.command.add("setclass", {
    adminOnly = true,
    desc = "setClassDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
        {
            name = "class",
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
                    if canAccess and target:getChar():getClass() ~= v.uniqueID then options[L(v.name)] = v.uniqueID end
                end
                return options
            end
        }
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyErrorLocalized("targetNotFound")
            return
        end

        if not target:getChar() then
            client:notifyErrorLocalized("invalidTarget")
            return
        end

        if not lia.class.list or table.IsEmpty(lia.class.list) then
            client:notifyErrorLocalized("noClassesAvailable")
            return
        end

        local targetFaction = target:Team()
        local factionClasses = lia.faction.getClasses(targetFaction)
        if not factionClasses or #factionClasses == 0 then
            client:notifyErrorLocalized("factionHasNoClasses")
            return
        end

        local className = arguments[2]
        local classID = lia.class.retrieveClass(className)
        local classData = lia.class.list[classID]
        if classData then
            if target:Team() == classData.faction then
                target:getChar():joinClass(classID, true)
                lia.log.add(client, "setClass", target:Name(), classData.name)
                target:notifyInfoLocalized("classSet", L(classData.name), client:GetName())
                if client ~= target then client:notifySuccessLocalized("classSetOther", target:GetName(), L(classData.name)) end
                hook.Run("PlayerLoadout", target)
            else
                client:notifyErrorLocalized("classFactionMismatch")
            end
        else
            client:notifyErrorLocalized("invalidClass")
        end
    end
})

lia.command.add("classwhitelist", {
    adminOnly = true,
    desc = "classWhitelistDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
        {
            name = "class",
            type = "table",
            options = function()
                local options = {}
                for _, v in pairs(lia.class.list) do
                    options[L(v.name)] = v.uniqueID
                end
                return options
            end
        }
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        local classID = lia.class.retrieveClass(arguments[2])
        if not target or not IsValid(target) then
            client:notifyErrorLocalized("targetNotFound")
            return
        elseif not classID then
            client:notifyErrorLocalized("invalidClass")
            return
        end

        local classData = lia.class.list[classID]
        if target:Team() ~= classData.faction then
            client:notifyErrorLocalized("whitelistFactionMismatch")
        elseif target:getChar():getClasswhitelists()[classID] then
            client:notifyInfoLocalized("alreadyWhitelisted")
        else
            local wl = target:getChar():getClasswhitelists()
            wl[classID] = true
            target:getChar():setClasswhitelists(wl)
            client:notifySuccessLocalized("whitelistedSuccess")
            target:notifyInfoLocalized("classAssigned", L(classData.name))
            lia.log.add(client, "classWhitelist", target:Name(), classData.name)
        end
    end
})

lia.command.add("classunwhitelist", {
    adminOnly = true,
    desc = "classUnwhitelistDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
        {
            name = "class",
            type = "table",
            options = function()
                local options = {}
                for _, v in pairs(lia.class.list) do
                    options[L(v.name)] = v.uniqueID
                end
                return options
            end
        }
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        local classID = lia.class.retrieveClass(arguments[2])
        if not target or not IsValid(target) then
            client:notifyErrorLocalized("targetNotFound")
            return
        elseif not classID then
            client:notifyErrorLocalized("invalidClass")
            return
        end

        local classData = lia.class.list[classID]
        if target:Team() ~= classData.faction then
            client:notifyErrorLocalized("whitelistFactionMismatch")
        elseif not target:getChar():getClasswhitelists()[classID] then
            client:notifyInfoLocalized("notWhitelisted")
        else
            local wl = target:getChar():getClasswhitelists()
            wl[classID] = nil
            target:getChar():setClasswhitelists(wl)
            client:notifySuccessLocalized("unwhitelistedSuccess")
            target:notifyInfoLocalized("classUnassigned", L(classData.name))
            lia.log.add(client, "classUnwhitelist", target:Name(), classData.name)
        end
    end
})

lia.command.add("spawnadd", {
    adminOnly = true,
    desc = "spawnAddDesc",
    arguments = {
        {
            name = "faction",
            type = "table",
            options = function()
                local options = {}
                for k, v in pairs(lia.faction.teams) do
                    options[k] = L(v.name)
                end
                return options
            end
        }
    },
    onRun = function(client, arguments)
        local factionName = arguments[1]
        if not factionName then
            client:notifyErrorLocalized("invalidArg")
            return
        end

        local factionInfo = lia.faction.teams[factionName] or lia.util.findFaction(client, factionName)
        if factionInfo then
            lia.module.get("spawns"):FetchSpawns():next(function(spawns)
                spawns[factionInfo.uniqueID] = spawns[factionInfo.uniqueID] or {}
                local newSpawn = {
                    pos = client:GetPos(),
                    ang = client:EyeAngles(),
                    map = lia.data.getEquivalencyMap(game.GetMap())
                }

                table.insert(spawns[factionInfo.uniqueID], newSpawn)
                lia.module.get("spawns"):StoreSpawns(spawns):next(function()
                    lia.log.add(client, "spawnAdd", factionInfo.name)
                    client:notifySuccessLocalized("spawnAdded", L(factionInfo.name))
                end)
            end)
        else
            client:notifyErrorLocalized("invalidFaction")
        end
    end
})

lia.command.add("spawnremoveinradius", {
    adminOnly = true,
    desc = "spawnRemoveInRadiusDesc",
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
            local curMap = lia.data.getEquivalencyMap(game.GetMap()):lower()
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
                lia.module.get("spawns"):StoreSpawns(spawns):next(function()
                    lia.log.add(client, "spawnRemoveRadius", radius, removedCount)
                    client:notifySuccessLocalized("spawnDeleted", removedCount)
                end)
            else
                lia.log.add(client, "spawnRemoveRadius", radius, removedCount)
                client:notifySuccessLocalized("spawnDeleted", removedCount)
            end
        end)
    end
})

lia.command.add("spawnremovebyname", {
    adminOnly = true,
    desc = "spawnRemoveByNameDesc",
    arguments = {
        {
            name = "faction",
            type = "table",
            options = function()
                local options = {}
                for k, v in pairs(lia.faction.teams) do
                    options[k] = L(v.name)
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
                    local curMap = lia.data.getEquivalencyMap(game.GetMap()):lower()
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
                        lia.module.get("spawns"):StoreSpawns(spawns):next(function()
                            lia.log.add(client, "spawnRemoveByName", factionInfo.name, removedCount)
                            client:notifySuccessLocalized("spawnDeletedByName", L(factionInfo.name), removedCount)
                        end)
                    else
                        client:notifyInfoLocalized("noSpawnsForFaction")
                    end
                else
                    client:notifyInfoLocalized("noSpawnsForFaction")
                end
            end)
        else
            client:notifyErrorLocalized("invalidFaction")
        end
    end
})

lia.command.add("returnitems", {
    superAdminOnly = true,
    desc = "returnItemsDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "returnItems",
        Category = "characterManagement",
        SubCategory = "items",
        Icon = "icon16/arrow_refresh.png"
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyErrorLocalized("targetNotFound")
            return
        end

        if lia.config.get("LoseItemsonDeathHuman", false) or lia.config.get("LoseItemsonDeathNPC", false) then
            if not target.LostItems or table.IsEmpty(target.LostItems) then
                client:notifyInfoLocalized("returnItemsTargetNoItems")
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
            target:notifySuccessLocalized("returnItemsReturnedToPlayer")
            client:notifySuccessLocalized("returnItemsAdminConfirmed")
            lia.log.add(client, "returnItems", target:Name())
        else
            client:notifyInfoLocalized("returnItemsNotEnabled")
        end
    end
})

lia.command.add("returnallitems", {
    superAdminOnly = true,
    desc = "returnAllItemsDesc",
    AdminStick = {
        Name = "returnAllItems",
        Category = "characterManagement",
        SubCategory = "items",
        Icon = "icon16/arrow_refresh.png"
    },
    onRun = function(client)
        if not lia.config.get("LoseItemsonDeathHuman", false) and not lia.config.get("LoseItemsonDeathNPC", false) then
            client:notifyInfoLocalized("returnItemsNotEnabled")
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
            target:notifySuccessLocalized("returnItemsReturnedToPlayer")
            returnedCount = returnedCount + 1
            totalItems = totalItems + playerItemCount
            lia.log.add(client, "returnItems", target:Name())
        end

        if returnedCount > 0 then
            client:notifySuccessLocalized("returnAllItemsAdminConfirmed", returnedCount, totalItems)
        else
            client:notifyInfoLocalized("returnAllItemsNoItemsFound")
        end
    end
})

lia.command.add("viewtickets", {
    adminOnly = true,
    desc = "viewTicketsDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    onRun = function(client, arguments)
        local targetName = arguments[1]
        if not targetName then
            client:notifyErrorLocalized("mustSpecifyPlayer")
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

        lia.module.get("administration"):GetTicketsByRequester(steamID):next(function(tickets)
            if #tickets == 0 then
                client:notifyInfoLocalized("noTicketsFound")
                return
            end

            local ticketsData = {}
            for _, ticket in ipairs(tickets) do
                ticketsData[#ticketsData + 1] = {
                    timestamp = os.date("%Y-%m-%d %H:%M:%S", ticket.timestamp),
                    admin = string.format("%s (%s)", ticket.admin or L("na"), ticket.adminSteamID or L("na")),
                    message = ticket.message or ""
                }
            end

            lia.util.sendTableUI(client, L("ticketsForTitle", displayName), {
                {
                    name = "timestamp",
                    field = "timestamp"
                },
                {
                    name = "admin",
                    field = "admin"
                },
                {
                    name = "message",
                    field = "message"
                }
            }, ticketsData)

            lia.log.add(client, "viewPlayerTickets", displayName)
        end)
    end
})

lia.command.add("plyviewclaims", {
    adminOnly = true,
    desc = "plyViewClaimsDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "viewTicketClaims",
        Category = "moderation",
        SubCategory = "misc",
        Icon = "icon16/page_white_text.png"
    },
    onRun = function(client, arguments)
        local targetName = arguments[1]
        if not targetName then
            client:notifyErrorLocalized("mustSpecifyPlayer")
            return
        end

        local target = lia.util.findPlayer(client, targetName)
        if not target or not IsValid(target) then
            client:notifyErrorLocalized("targetNotFound")
            return
        end

        local steamID = target:SteamID()
        lia.module.get("administration"):GetAllCaseClaims():next(function(caseclaims)
            local claim = caseclaims[steamID]
            if not claim then
                client:notifyInfoLocalized("noClaimsFound")
                return
            end

            local claimsData = {
                {
                    steamID = steamID,
                    name = claim.name,
                    claims = claim.claims,
                    lastclaim = os.date("%Y-%m-%d %H:%M:%S", claim.lastclaim),
                    timeSinceLastClaim = lia.time.timeSince(claim.lastclaim),
                    claimedFor = table.IsEmpty(claim.claimedFor) and L("none") or table.concat((function()
                        local t = {}
                        for sid, name in pairs(claim.claimedFor) do
                            table.insert(t, string.format("%s (%s)", name, sid))
                        end
                        return t
                    end)(), "\n")
                }
            }

            lia.util.sendTableUI(client, L("claimsForTitle", target:Nick()), {
                {
                    name = "steamID",
                    field = "steamID"
                },
                {
                    name = "adminName",
                    field = "name"
                },
                {
                    name = "totalClaims",
                    field = "claims"
                },
                {
                    name = "lastClaimDate",
                    field = "lastclaim"
                },
                {
                    name = "timeSinceLastClaim",
                    field = "timeSinceLastClaim"
                },
                {
                    name = "claimedFor",
                    field = "claimedFor"
                }
            }, claimsData)

            lia.log.add(client, "viewPlayerClaims", target:Name())
        end)
    end
})

lia.command.add("viewallclaims", {
    adminOnly = true,
    desc = "viewAllClaimsDesc",
    onRun = function(client)
        lia.module.get("administration"):GetAllCaseClaims():next(function(caseclaims)
            if table.IsEmpty(caseclaims) then
                client:notifyInfoLocalized("noClaimsRecorded")
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
                    claimedFor = table.IsEmpty(claim.claimedFor) and L("none") or table.concat((function()
                        local t = {}
                        for sid, name in pairs(claim.claimedFor) do
                            table.insert(t, string.format("%s (%s)", name, sid))
                        end
                        return t
                    end)(), ", ")
                })
            end

            lia.util.sendTableUI(client, "adminClaimsTitle", {
                {
                    name = "steamID",
                    field = "steamID"
                },
                {
                    name = "adminName",
                    field = "name"
                },
                {
                    name = "totalClaims",
                    field = "claims"
                },
                {
                    name = "lastClaimDate",
                    field = "lastclaim"
                },
                {
                    name = "timeSinceLastClaim",
                    field = "timeSinceLastClaim"
                },
                {
                    name = "claimedFor",
                    field = "claimedFor"
                }
            }, claimsData)

            lia.log.add(client, "viewAllClaims")
        end)
    end
})

lia.command.add("viewclaims", {
    adminOnly = true,
    desc = "viewClaimsDesc",
    onRun = function(client)
        lia.module.get("administration"):GetAllCaseClaims():next(function(caseclaims)
            if table.IsEmpty(caseclaims) then
                client:notifyInfoLocalized("noClaimsData")
                return
            end

            lia.log.add(client, "viewAllClaims")
            local claimsData = {}
            for steamID, claim in pairs(caseclaims) do
                table.insert(claimsData, {
                    steamID = steamID,
                    name = claim.name,
                    claims = claim.claims,
                    lastclaim = os.date("%Y-%m-%d %H:%M:%S", claim.lastclaim),
                    timeSinceLastClaim = lia.time.timeSince(claim.lastclaim),
                    claimedFor = table.IsEmpty(claim.claimedFor) and L("none") or table.concat((function()
                        local t = {}
                        for sid, name in pairs(claim.claimedFor) do
                            table.insert(t, string.format("%s (%s)", name, sid))
                        end
                        return t
                    end)(), "\n")
                })
            end

            lia.util.sendTableUI(client, "adminClaimsTitle", {
                {
                    name = "steamID",
                    field = "steamID"
                },
                {
                    name = "adminName",
                    field = "name"
                },
                {
                    name = "totalClaims",
                    field = "claims"
                },
                {
                    name = "lastClaimDate",
                    field = "lastclaim"
                },
                {
                    name = "timeSinceLastClaim",
                    field = "timeSinceLastClaim"
                },
                {
                    name = "claimedFor",
                    field = "claimedFor"
                }
            }, claimsData)
        end)
    end
})

lia.command.add("warn", {
    adminOnly = true,
    desc = "warnDesc",
    arguments = {
        {
            name = "target",
            type = "player"
        },
        {
            name = "reason",
            type = "string"
        },
    },
    AdminStick = {
        Name = "warnPlayer",
        Category = "moderation",
        SubCategory = "warnings",
        Icon = "icon16/error.png"
    },
    onRun = function(client, arguments)
        local targetName = arguments[1]
        local reason = table.concat(arguments, " ", 2)
        if not targetName or reason == "" then return L("warnUsage") end
        local target = lia.util.findPlayer(client, targetName)
        if not target or not IsValid(target) then
            client:notifyErrorLocalized("targetNotFound")
            return
        end

        if target == client then
            client:notifyErrorLocalized("cannotWarnSelf")
            return
        end

        local timestamp = os.date("%Y-%m-%d %H:%M:%S")
        local warnerName = client:Nick()
        local warnerSteamID = client:SteamID()
        lia.module.get("administration"):AddWarning(target:getChar():getID(), target:Nick(), target:SteamID(), timestamp, reason, warnerName, warnerSteamID)
        lia.db.count("warnings", "charID = " .. lia.db.convertDataType(target:getChar():getID())):next(function(count)
            target:notifyWarningLocalized("playerWarned", warnerName .. " (" .. warnerSteamID .. ")", reason)
            client:notifySuccessLocalized("warningIssued", target:Nick())
            hook.Run("WarningIssued", client, target, reason, count, warnerSteamID, target:SteamID())
        end)
    end
})

lia.command.add("viewwarns", {
    adminOnly = true,
    desc = "viewWarnsDesc",
    arguments = {
        {
            name = "target",
            type = "player"
        },
    },
    AdminStick = {
        Name = "viewPlayerWarnings",
        Category = "moderation",
        SubCategory = "warnings",
        Icon = "icon16/eye.png"
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyErrorLocalized("targetNotFound")
            return
        end

        lia.module.get("administration"):GetWarnings(target:getChar():getID()):next(function(warns)
            if #warns == 0 then
                client:notifyInfoLocalized("noWarnings", target:Nick())
                return
            end

            local warningList = {}
            for index, warn in ipairs(warns) do
                table.insert(warningList, {
                    index = index,
                    timestamp = warn.timestamp or L("na"),
                    admin = string.format("%s (%s)", warn.warner or L("na"), warn.warnerSteamID or L("na")),
                    warningMessage = warn.message or L("na")
                })
            end

            lia.util.sendTableUI(client, L("playerWarningsTitle", target:Nick()), {
                {
                    name = "id",
                    field = "index"
                },
                {
                    name = "timestamp",
                    field = "timestamp"
                },
                {
                    name = "admin",
                    field = "admin"
                },
                {
                    name = "warningMessage",
                    field = "warningMessage"
                }
            }, warningList, {
                {
                    name = "removeWarning",
                    net = "liaRequestRemoveWarning"
                }
            }, target:getChar():getID())

            lia.log.add(client, "viewWarns", target)
        end)
    end
})

lia.command.add("viewwarnsissued", {
    adminOnly = true,
    desc = "viewWarnsIssuedDesc",
    arguments = {
        {
            name = "staff",
            type = "string"
        },
    },
    onRun = function(client, arguments)
        local targetName = arguments[1]
        if not targetName then
            client:notifyErrorLocalized("targetNotFound")
            return
        end

        local target = lia.util.findPlayer(client, targetName)
        local steamID, displayName = targetName, targetName
        if IsValid(target) then
            steamID = target:SteamID()
            displayName = target:Nick()
        end

        lia.module.get("administration"):GetWarningsByIssuer(steamID):next(function(warns)
            if #warns == 0 then
                client:notifyInfoLocalized("noWarnings", displayName)
                return
            end

            local warningList = {}
            for index, warn in ipairs(warns) do
                warningList[#warningList + 1] = {
                    index = index,
                    timestamp = warn.timestamp or L("na"),
                    player = string.format("%s (%s)", warn.warned or L("na"), warn.warnedSteamID or L("na")),
                    warningMessage = warn.message or L("na")
                }
            end

            lia.util.sendTableUI(client, L("warningsIssuedTitle", displayName), {
                {
                    name = "id",
                    field = "index"
                },
                {
                    name = "timestamp",
                    field = "timestamp"
                },
                {
                    name = "player",
                    field = "player"
                },
                {
                    name = "warningMessage",
                    field = "warningMessage"
                }
            }, warningList)

            lia.log.add(client, "viewWarnsIssued", target or steamID)
        end)
    end
})

lia.command.add("recogwhisper", {
    adminOnly = true,
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    desc = "recogWhisperDesc",
    AdminStick = {
        Name = "adminStickForceRecognitionWhisperName",
        Category = "moderation",
        SubCategory = "moderationTools",
        Icon = "icon16/user_comment.png"
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1]) or client
        if not IsValid(target) or not target:getChar() then return end
        lia.module.get("recognition"):ForceRecognizeRange(target, "whisper")
    end
})

lia.command.add("recognormal", {
    adminOnly = true,
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    desc = "recogNormalDesc",
    AdminStick = {
        Name = "adminStickForceRecognitionNormalName",
        Category = "moderation",
        SubCategory = "moderationTools",
        Icon = "icon16/user_green.png"
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1]) or client
        if not IsValid(target) or not target:getChar() then return end
        lia.module.get("recognition"):ForceRecognizeRange(target, "normal")
    end
})

lia.command.add("recogyell", {
    adminOnly = true,
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    desc = "recogYellDesc",
    AdminStick = {
        Name = "adminStickForceRecognitionYellName",
        Category = "moderation",
        SubCategory = "moderationTools",
        Icon = "icon16/user_red.png"
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1]) or client
        if not IsValid(target) or not target:getChar() then return end
        lia.module.get("recognition"):ForceRecognizeRange(target, "yell")
    end
})

lia.command.add("recogbots", {
    superAdminOnly = true,
    arguments = {
        {
            name = "range",
            type = "string",
            optional = true
        },
        {
            name = "name",
            type = "string",
            optional = true
        },
    },
    desc = "recogBotsDesc",
    onRun = function(_, arguments)
        local range = arguments[1] or "normal"
        local fakeName = arguments[2]
        for _, ply in player.Iterator() do
            if ply:IsBot() then lia.module.get("recognition"):ForceRecognizeRange(ply, range, fakeName) end
        end
    end
})

lia.command.add("kickbots", {
    privilege = "manageBots",
    desc = "kickAllBotsDesc",
    onRun = function(client)
        local kickedCount = 0
        for _, bot in player.Iterator() do
            if bot:IsBot() then
                bot:Kick(L("allBotsKicked"))
                client:notifySuccessLocalized("plyKicked")
                lia.log.add(client, "plyKick", bot:Name())
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
            client:notifyErrorLocalized("noBotsToKick")
        else
            client:notifyInfoLocalized("botsKickedAll", kickedCount)
        end
    end
})

lia.command.add("npcchangetype", {
    adminOnly = true,
    desc = "npcchangetypeDesc",
    AdminStick = {
        Name = "adminStickChangeNPCType",
        Category = "moderation",
        SubCategory = "moderationTools",
        TargetClass = "lia_npc",
        Icon = "icon16/user_edit.png"
    },
    onRun = function(client)
        if not client:hasPrivilege("Can Manage NPCs") then return client:notifyError("You lack permission to manage NPCs.") end
        local ent = client:getTracedEntity()
        if not ent or not IsValid(ent) then return client:notifyError("You must be looking at a valid entity.") end
        if ent:GetClass() ~= "lia_npc" then return client:notifyError("You must be looking at a dialog NPC.") end
        lia.dialog.syncToClients(client)
        timer.Simple(0.1, function()
            if not IsValid(client) or not IsValid(ent) then return end
            local npcOptions = {}
            local displayToUniqueID = {}
            for uniqueID, data in pairs(lia.dialog.stored) do
                local displayName = data.PrintName or uniqueID
                table.insert(npcOptions, {displayName, uniqueID})
                displayToUniqueID[displayName] = uniqueID
            end

            if not table.IsEmpty(npcOptions) then
                client.npcDisplayToUniqueID = displayToUniqueID
                client.npcEntity = ent
                client:requestDropdown("Change NPC Type", "Choose what type of NPC this should be:", npcOptions, function(selectedDisplayName, selectedUniqueID)
                    if selectedDisplayName and selectedDisplayName ~= "" then
                        local uniqueID = selectedUniqueID or (client.npcDisplayToUniqueID and client.npcDisplayToUniqueID[selectedDisplayName])
                        if uniqueID and IsValid(client.npcEntity) then
                            local npc = client.npcEntity
                            local npcType = uniqueID
                            if not IsValid(npc) or not npcType then return end
                            local existingCustomData = npc.customData
                            npc.uniqueID = npcType
                            local npcData = lia.dialog.getNPCData(npcType)
                            if npcData then
                                local currentPos = npc:GetPos()
                                local currentAng = npc:GetAngles()
                                npc:SetModel("models/Barney.mdl")
                                if npcData.BodyGroups and istable(npcData.BodyGroups) then
                                    for bodygroup, value in pairs(npcData.BodyGroups) do
                                        local bgIndex = npc:FindBodygroupByName(bodygroup)
                                        if bgIndex > -1 then npc:SetBodygroup(bgIndex, value) end
                                    end
                                end

                                if npcData.Skin then npc:SetSkin(npcData.Skin) end
                                npc.NPCName = npcData.PrintName or "NPC"
                                npc:setNetVar("uniqueID", npcType)
                                npc:setNetVar("NPCName", npc.NPCName)
                                npc:SetMoveType(MOVETYPE_VPHYSICS)
                                npc:SetSolid(SOLID_OBB)
                                npc:PhysicsInit(SOLID_OBB)
                                npc:SetCollisionGroup(COLLISION_GROUP_WORLD)
                                npc:SetPos(currentPos)
                                npc:SetAngles(currentAng)
                                local physObj = npc:GetPhysicsObject()
                                if IsValid(physObj) then
                                    physObj:EnableMotion(false)
                                    physObj:Sleep()
                                end

                                npc:setAnim()
                                if existingCustomData then
                                    if existingCustomData.name and existingCustomData.name ~= "" then npc.NPCName = existingCustomData.name end
                                    if existingCustomData.model and existingCustomData.model ~= "" then npc:SetModel(existingCustomData.model) end
                                    if existingCustomData.skin then npc:SetSkin(tonumber(existingCustomData.skin) or 0) end
                                    if existingCustomData.bodygroups and istable(existingCustomData.bodygroups) then
                                        for bodygroupIndex, value in pairs(existingCustomData.bodygroups) do
                                            npc:SetBodygroup(tonumber(bodygroupIndex) or 0, tonumber(value) or 0)
                                        end
                                    end

                                    if existingCustomData.animation and existingCustomData.animation ~= "auto" then
                                        local sequenceIndex = npc:LookupSequence(existingCustomData.animation)
                                        if sequenceIndex >= 0 then
                                            npc.customAnimation = existingCustomData.animation
                                            npc:ResetSequence(sequenceIndex)
                                        end
                                    end

                                    npc.customData = existingCustomData
                                end

                                npc:setNetVar("NPCName", npc.NPCName)
                                hook.Run("UpdateEntityPersistence", npc)
                                client:notifyInfo("NPC type changed to: " .. (npcData.PrintName or npcType))
                            end
                        end
                    end
                end)
            else
                client:notifyError("No NPC types available! The server may still be loading modules. Please try again in a moment.")
            end
        end)
    end
})

lia.command.add("plyrespawn", {
    adminOnly = true,
    arguments = {
        {
            name = "target",
            type = "player"
        }
    },
    desc = "plyRespawnDesc",
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyErrorLocalized("invalidTarget")
            return
        end

        target:Spawn()
        client:notifySuccessLocalized("playerForceRespawned", target:Name())
        target:notifyLocalized("youWereForceRespawned")
        lia.log.add(client, "plyrespawn", target:Name())
    end
})

lia.command.add("forcerespawn", {
    desc = "forceRespawnDesc",
    onRun = function(client)
        if client:Alive() then
            client:notifyErrorLocalized("playerAlreadyAlive")
            return
        end

        local baseTime = lia.config.get("SpawnTime", 5)
        baseTime = hook.Run("OverrideSpawnTime", client, baseTime) or baseTime
        local lastDeath = client:getLocalVar("lastDeathTime", os.time())
        local timePassed = os.time() - lastDeath
        if timePassed < baseTime then
            client:notifyErrorLocalized("cannotRespawnYet", baseTime - timePassed)
            return
        end

        client:Spawn()
        client:setLocalVar("lastDeathTime", 0)
        client:notifySuccessLocalized("playerForceRespawned", client:Name())
        client:notifyLocalized("youWereForceRespawned")
        lia.log.add(client, "forcerespawn", client:Name())
    end
})

lia.command.add("resetvendorcooldowns", {
    desc = "resetvendorcooldownsDesc",
    privilege = "canEditVendors",
    adminOnly = true,
    arguments = {
        {
            name = "target",
            type = "player",
            description = "The player to reset cooldowns for"
        }
    },
    AdminStick = {
        Name = "adminStickResetVendorCooldownsName",
        Category = "items",
        SubCategory = "items",
        Icon = "icon16/time_delete.png"
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not IsValid(target) then
            client:notifyErrorLocalized("invalidTarget")
            return
        end

        local character = target:getChar()
        if not character then
            client:notifyErrorLocalized("invalidTarget")
            return
        end

        character:setData("vendorCooldowns", {})
        client:notifyLocalized("vendorCooldownsReset", target:Name())
        target:notifyLocalized("vendorCooldownsResetByAdmin")
    end
})

lia.command.add("storagepasswordremove", {
    adminOnly = true,
    desc = "storagePasswordRemoveDesc",
    arguments = {},
    onRun = function(client)
        local trace = client:GetEyeTrace()
        local entity = trace.Entity
        if not IsValid(entity) or trace.HitPos:Distance(client:GetPos()) > 128 then
            client:notifyErrorLocalized("invalidTarget")
            return
        end

        if not entity.password then
            client:notifyErrorLocalized("storageNotLocked")
            return
        end

        entity.password = nil
        entity:setNetVar("locked", false)
        client:notifySuccessLocalized("storageUnlocked")
        lia.log.add(client, "storagePasswordRemoved", entity:GetClass())
        hook.Run("UpdateEntityPersistence", entity)
    end
})

lia.command.add("storagepasswordchange", {
    adminOnly = true,
    desc = "storagePasswordChangeDesc",
    arguments = {
        {
            name = "password",
            type = "string"
        },
    },
    onRun = function(client, arguments)
        local trace = client:GetEyeTrace()
        local entity = trace.Entity
        local newPassword = arguments[1]
        if not IsValid(entity) or trace.HitPos:Distance(client:GetPos()) > 128 then
            client:notifyErrorLocalized("invalidTarget")
            return
        end

        if not newPassword or newPassword == "" then
            client:notifyErrorLocalized("invalidPassword")
            return
        end

        entity.password = newPassword
        entity:setNetVar("locked", true)
        client:notifySuccessLocalized("storagePasswordChanged")
        lia.log.add(client, "storagePasswordChanged", entity:GetClass())
        hook.Run("UpdateEntityPersistence", entity)
    end
})

lia.command.add("listnearbyentities", {
    adminOnly = true,
    desc = "listNearbyEntitiesDesc",
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
            local category = "other"
            if ent:IsPlayer() then
                category = "players"
            elseif ent:IsNPC() then
                category = "npcs"
            elseif ent:IsVehicle() then
                category = "vehicles"
            elseif ent:IsWeapon() then
                category = "weapons"
            elseif class:find("prop_") or class == "lia_item" then
                category = "props"
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

        client:ChatPrint("=== Entities within " .. radius .. " units ===")
        for categoryName, entitiesInCategory in pairs(entityCategories) do
            if #entitiesInCategory > 0 then
                client:ChatPrint("--- " .. categoryName:upper() .. " (" .. #entitiesInCategory .. ") ---")
                table.sort(entitiesInCategory, function(a, b) return a.distance < b.distance end)
                for _, entData in ipairs(entitiesInCategory) do
                    local info = string.format("%.1f units: %s", entData.distance, entData.class)
                    if entData.name ~= "N/A" and entData.name ~= "" then info = info .. " (" .. entData.name .. ")" end
                    if entData.health ~= "N/A" then info = info .. " [HP: " .. entData.health .. "]" end
                    client:ChatPrint(info)
                end

                client:ChatPrint("")
            end
        end

        local totalEntities = 0
        for _, entitiesInCategory in pairs(entityCategories) do
            totalEntities = totalEntities + #entitiesInCategory
        end

        client:ChatPrint("Total entities found: " .. totalEntities)
        client:notify("Listed " .. totalEntities .. " entities within " .. radius .. " units")
    end
})