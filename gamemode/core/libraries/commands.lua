--[[
    Folder: Developer - Libraries
    File: lia.command.md
]]
--[[
    Command

    Command registration, parsing, permissions, argument prompts, and network dispatch helpers for Lilia commands.
]]
--[[
    Overview:
        The command library centralizes shared command registration under `lia.command`, normalizes command argument metadata, manages command aliases and privilege checks, parses chat commands on the server, opens clientside argument prompts for missing required arguments, and sends command payloads from the client to the server.
]]
--[[
    Hooks:
        CharListExtraDetails(client, entry, stored)

    Purpose:
        temp

    Category:
        temp

    Parameters:
        temp

    Example Usage:
        ```lua
        hook.Add("CharListExtraDetails", "liaExampleCharListExtraDetails", function(client, entry, stored)
            temp
        end)
        ```

    Realm:
        temp
]]
--[[
    Hooks:
        DoorEnabledToggled(client, door, newState)

    Purpose:
        temp

    Category:
        temp

    Parameters:
        temp

    Example Usage:
        ```lua
        hook.Add("DoorEnabledToggled", "liaExampleDoorEnabledToggled", function(client, door, newState)
            temp
        end)
        ```

    Realm:
        temp
]]
--[[
    Hooks:
        DoorHiddenToggled(client, entity, newState)

    Purpose:
        temp

    Category:
        temp

    Parameters:
        temp

    Example Usage:
        ```lua
        hook.Add("DoorHiddenToggled", "liaExampleDoorHiddenToggled", function(client, entity, newState)
            temp
        end)
        ```

    Realm:
        temp
]]
--[[
    Hooks:
        DoorOwnableToggled(client, door, newState)

    Purpose:
        temp

    Category:
        temp

    Parameters:
        temp

    Example Usage:
        ```lua
        hook.Add("DoorOwnableToggled", "liaExampleDoorOwnableToggled", function(client, door, newState)
            temp
        end)
        ```

    Realm:
        temp
]]
--[[
    Hooks:
        DoorPriceSet(client, door, price)

    Purpose:
        temp

    Category:
        temp

    Parameters:
        temp

    Example Usage:
        ```lua
        hook.Add("DoorPriceSet", "liaExampleDoorPriceSet", function(client, door, price)
            temp
        end)
        ```

    Realm:
        temp
]]
--[[
    Hooks:
        DoorTitleSet(client, door, name)

    Purpose:
        temp

    Category:
        temp

    Parameters:
        temp

    Example Usage:
        ```lua
        hook.Add("DoorTitleSet", "liaExampleDoorTitleSet", function(client, door, name)
            temp
        end)
        ```

    Realm:
        temp
]]
--[[
    Hooks:
        ForceRecognizeRange(ply, range, fakeName)

    Purpose:
        temp

    Category:
        temp

    Parameters:
        temp

    Example Usage:
        ```lua
        hook.Add("ForceRecognizeRange", "liaExampleForceRecognizeRange", function(ply, range, fakeName)
            temp
        end)
        ```

    Realm:
        temp
]]
--[[
    Hooks:
        OnPlayerPurchaseDoor(client, door, arg3)

    Purpose:
        temp

    Category:
        temp

    Parameters:
        temp

    Example Usage:
        ```lua
        hook.Add("OnPlayerPurchaseDoor", "liaExampleOnPlayerPurchaseDoor", function(client, door, arg3)
            temp
        end)
        ```

    Realm:
        temp
]]
--[[
    Hooks:
        OnTransferred(target)

    Purpose:
        temp

    Category:
        temp

    Parameters:
        temp

    Example Usage:
        ```lua
        hook.Add("OnTransferred", "liaExampleOnTransferred", function(target)
            temp
        end)
        ```

    Realm:
        temp
]]
--[[
    Hooks:
        CommandAdded(string command, table data)

    Purpose:
        Runs after a command has been registered with `lia.command.add`.

    Category:
        Commands

    Parameters:
        command (string)
            The command name that was registered.

        data (table)
            The command definition table stored in `lia.command.list`.

    Example Usage:
        ```lua
        hook.Add("CommandAdded", "liaExampleCommandAdded", function(command, data)
            print("[MyModule] handled CommandAdded")
        end)
        ```

    Realm:
        Shared
]]
--[[
    Hooks:
        CanPlayerUseCommand(Player client, string command)

    Purpose:
        Allows plugins or modules to override whether a player can use a command after normal privilege checks are prepared.

    Category:
        Commands

    Parameters:
        client (Player)
            The player whose command access is being checked.

        command (string)
            The command name being checked.

    Example Usage:
        ```lua
        hook.Add("CanPlayerUseCommand", "liaExampleCanPlayerUseCommand", function(client, command)
            if IsValid(client) and client:IsAdmin() then
                return true
            end
        end)
        ```

    Returns:
        boolean|nil
            Return true to allow the command, false to deny it, or nil to keep the normal access result.

    Realm:
        Shared
]]
--[[
    Hooks:
        CommandRan(Player client, string command, table arguments, table results)

    Purpose:
        Runs after a command callback has executed.

    Category:
        Commands

    Parameters:
        client (Player)
            The player who ran the command.

        command (string)
            The command name that was executed.

        arguments (table)
            The parsed command arguments passed to the command.

        results (table)
            The return values from the command callback.

    Example Usage:
        ```lua
        hook.Add("CommandRan", "liaExampleCommandRan", function(client, command, arguments, results)
            if not IsValid(client) then return end
            print(string.format("[MyModule] handled CommandRan for %s", client:Name()))
        end)
        ```

    Realm:
        Server
]]
lia.command = lia.command or {}
lia.command.list = lia.command.list or {}
--[[
    Purpose:
        Builds a display syntax string from a command argument definition list.

    Parameters:
        args (table)
            Sequential command argument definitions. Each entry may define `name`, `type`, and `optional`.

    Returns:
        string
            A space-separated syntax string in bracketed argument format.

    Example Usage:
        ```lua
        local syntax = lia.command.buildSyntaxFromArguments({
            {name = "target", type = "player"},
            {name = "reason", type = "string", optional = true}
        })
        ```

    Realm:
        Shared
]]
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

        local name = lia.lang.resolveToken(arg.name or typ)
        local optional = arg.optional and " optional" or ""
        tokens[#tokens + 1] = string.format("[%s %s%s]", typ, name, optional)
    end
    return table.concat(tokens, " ")
end

--[[
    Purpose:
        Registers a Lilia command, resolves localized command metadata, normalizes argument definitions, creates aliases, registers admin privileges when required, and wraps the command callback with access checks.

    Parameters:
        command (string)
            The command name to register.

        data (table)
            The command definition. Expected fields include `onRun`, and may include `arguments`, `syntax`, `desc`, `alias`, `adminOnly`, `superAdminOnly`, `privilege`, `privilegeName`, `AdminStick`, and `onCheckAccess`.

    Example Usage:
        ```lua
        lia.command.add("example", {
            desc = "@exampleDesc",
            arguments = {
                {name = "target", type = "player"}
            },
            onRun = function(client, arguments)
                client:notifyInfo("Example command ran.")
            end
        })
        ```

    Realm:
        Shared
]]
function lia.command.add(command, data)
    data.arguments = data.arguments or {}
    data.syntax = data.syntax or lia.command.buildSyntaxFromArguments(data.arguments)
    data.syntax = isstring(data.syntax) and lia.lang.resolveToken(data.syntax) or data.syntax or ""
    data.desc = isstring(data.desc) and lia.lang.resolveToken(data.desc) or data.desc or ""
    if istable(data.AdminStick) then
        data.AdminStick.Name = isstring(data.AdminStick.Name) and lia.lang.resolveToken(data.AdminStick.Name) or data.AdminStick.Name
        data.AdminStick.ButtonText = isstring(data.AdminStick.ButtonText) and lia.lang.resolveToken(data.AdminStick.ButtonText) or data.AdminStick.ButtonText
        data.AdminStick.Category = isstring(data.AdminStick.Category) and lia.lang.resolveToken(data.AdminStick.Category) or data.AdminStick.Category
        data.AdminStick.SubCategory = isstring(data.AdminStick.SubCategory) and lia.lang.resolveToken(data.AdminStick.SubCategory) or data.AdminStick.SubCategory
    end

    if isstring(data.privilege) and data.privilege:sub(1, 1) == "@" then
        data.privilegeName = lia.lang.resolveToken(data.privilege)
        data.privilege = data.privilege:sub(2)
    else
        data.privilegeName = data.privilegeName or data.privilege
    end

    data.privilege = data.privilege or nil
    local superAdminOnly = data.superAdminOnly
    local adminOnly = data.adminOnly
    if not data.onRun then
        lia.error(L("commandNoCallback", command))
        return
    end

    if superAdminOnly or adminOnly then
        local privilegeName = data.privilegeName or L("accessTo", command)
        local privilegeID = data.privilege or string.lower("command_" .. command)
        lia.admin.registerPrivilege({
            Name = privilegeName,
            ID = privilegeID,
            MinAccess = superAdminOnly and "superadmin" or "admin",
            Category = "@staffPermissions"
        })
    end

    for _, arg in ipairs(data.arguments) do
        if arg.type == "boolean" then
            arg.type = "bool"
        elseif arg.type ~= "player" and arg.type ~= "table" and arg.type ~= "bool" then
            arg.type = "string"
        end

        arg.description = isstring(arg.description) and lia.lang.resolveToken(arg.description) or arg.description
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
                    lia.admin.registerPrivilege({
                        Name = data.privilegeName or L("accessTo", v),
                        ID = aliasPrivilegeID,
                        MinAccess = superAdminOnly and "superadmin" or "admin",
                        Category = "@commands"
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
                    Name = data.privilegeName or L("accessTo", alias),
                    ID = aliasPrivilegeID,
                    MinAccess = superAdminOnly and "superadmin" or "admin",
                    Category = "@commands"
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

--[[
    Purpose:
        Checks whether a player can use a registered command.

    Parameters:
        client (Player)
            The player whose access is being checked.

        command (string)
            The command name being checked.

        data (table)
            Optional command definition. When omitted, the command is looked up in `lia.command.list`.

    Returns:
        boolean
            True when the player can use the command, otherwise false.

        string
            The display name of the privilege or access level used for the check.

    Example Usage:
        ```lua
        local canUse, privilege = lia.command.hasAccess(client, "plygetplaytime")
        if not canUse then
            client:notifyErrorLocalized("noPerm")
        end
        ```

    Realm:
        Shared
]]
function lia.command.hasAccess(client, command, data)
    if not data then data = lia.command.list[command] end
    if not data then return false, "unknown" end
    local privilegeID = data.privilege or string.lower("command_" .. command)
    local superAdminOnly = data.superAdminOnly
    local adminOnly = data.adminOnly
    local accessLevels = superAdminOnly and "superadmin" or adminOnly and "admin" or "user"
    local privilegeName = data.privilegeName or accessLevels == "user" and L("globalAccess") or L("accessTo", command)
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

--[[
    Purpose:
        Splits a raw command argument string into arguments while preserving quoted text as a single argument.

    Parameters:
        text (string)
            The raw argument string to parse.

    Returns:
        table
            Sequential command arguments extracted from the input string.

    Example Usage:
        ```lua
        local arguments = lia.command.extractArgs("target \"quoted reason\"")
        ```

    Realm:
        Shared
]]
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
    --[[
    Purpose:
        Executes a registered command callback and handles localized string return values as player notifications.

    Parameters:
        client (Player)
            The player running the command.

        command (string)
            The command name to execute.

        arguments (table)
            Optional parsed arguments to pass to the command callback.

    Example Usage:
        ```lua
        lia.command.run(client, "playtime", {})
        ```

    Realm:
        Server
    ]]
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

    --[[
    Purpose:
        Parses chat command text, checks command access, prompts the player for missing required arguments when needed, and runs the command.

    Parameters:
        client (Player)
            The player whose input is being parsed.

        text (string)
            The raw chat text or command text.

        realCommand (string)
            Optional command name to run instead of parsing one from `text`.

        arguments (table)
            Optional pre-parsed command arguments.

    Returns:
        boolean
            True when the text was handled as a command, otherwise false.

    Example Usage:
        ```lua
        hook.Add("PlayerSay", "ParseLiliaCommands", function(client, text)
            if lia.command.parse(client, text) then return "" end
        end)
        ```

    Realm:
        Server
    ]]
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
    --[[
    Purpose:
        Opens the clientside command argument prompt for missing required command arguments.

    Parameters:
        cmdKey (string)
            The command key being completed.

        missing (table)
            Argument names that still need values.

        prefix (table)
            Arguments already supplied before the prompt opened.

        definitions (table)
            Optional argument definitions used when the command is not available locally.

    Example Usage:
        ```lua
        lia.command.openArgumentPrompt("example", {"target"}, {}, definitions)
        ```

    Realm:
        Client
    ]]
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
                        local identifier = plyObj:SteamID()
                        if identifier == "BOT" then identifier = plyObj:Name() end
                        ctrl:AddChoice(plyObj:Name(), identifier)
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

    --[[
    Purpose:
        Sends a command and its arguments from the client to the server over the Lilia command net message.

    Parameters:
        command (string)
            The command name to send.

        ... (any)
            Arguments to send with the command.

    Example Usage:
        ```lua
        lia.command.send("playtime")
        ```

    Realm:
        Client
    ]]
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
        if not IsColor(accent) and lia.config and lia.config.get then accent = lia.config.get("Color") end
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
            lia.websound.playButtonSound()
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
            name = "commands",
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
                searchEntry:SetPlaceholderText(L("searchCommands"))
                searchEntry:SetDrawBackground(false)
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
                        local name = tostring(argument.name or argument.type or "argument")
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
                            local access = privilege and tostring(privilege) or L("globalAccess")
                            local privileged = access ~= L("globalAccess")
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
                                lia.websound.playButtonSound()
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
                }, nil, "players", "steamID = " .. lia.db.convertDataType(normalized)):next(function() MsgC(Color(0, 255, 0), "[Lilia] ", Color(255, 255, 255), "Added flags '" .. appended .. "' to " .. normalized .. ". New flags: '" .. merged .. "'\n") end):catch(function(err) MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), "Error updating flags for " .. normalized .. ": " .. tostring(err) .. "\n") end)
            else
                lia.db.insertTable({
                    steamID = normalized,
                    data = util.TableToJSON(data)
                }, nil, "players"):next(function() MsgC(Color(0, 255, 0), "[Lilia] ", Color(255, 255, 255), "Created player entry and added flags '" .. appended .. "' to " .. normalized .. ". New flags: '" .. merged .. "'\n") end):catch(function(err) MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), "Error creating player entry for " .. normalized .. ": " .. tostring(err) .. "\n") end)
            end
        end):catch(function(err) MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), "Database error while checking player " .. normalized .. ": " .. tostring(err) .. "\n") end)
    end

    concommand.Add("lia_givepermaflags", function(client, _, args)
        lia.debug("[Permissions]", "Permission Check for concommand lia_givepermaflags", "isValidPlayer=", tostring(IsValid(client)), "isSuperAdmin=", tostring(IsValid(client) and client:IsSuperAdmin() or true), "finalResult=", tostring(not IsValid(client) or client:IsSuperAdmin()))
        if IsValid(client) and not client:IsSuperAdmin() then return end
        appendPermanentFlags(args[1], args[2])
    end)

    concommand.Add("kickbots", function(client)
        lia.debug("[Permissions]", "Permission Check for concommand kickbots", "isValidPlayer=", tostring(IsValid(client)), "isSuperAdmin=", tostring(IsValid(client) and client:IsSuperAdmin() or true), "finalResult=", tostring(not IsValid(client) or client:IsSuperAdmin()))
        if IsValid(client) and not client:IsSuperAdmin() then
            client:notifyErrorLocalized("staffPermissionDenied")
            return
        end

        if timer.Exists("Bots_Add_Timer") then timer.Remove("Bots_Add_Timer") end
        local kickedCount = 0
        for _, bot in player.Iterator() do
            if bot:IsBot() then
                bot:Kick(L("allBotsKicked"))
                kickedCount = kickedCount + 1
            end
        end

        if IsValid(client) then
            if kickedCount == 0 then
                client:notifyErrorLocalized("noBotsToKick")
            else
                client:notifyInfoLocalized("botsKickedAll", kickedCount)
            end
        else
            local message = kickedCount == 0 and L("noBotsToKick") or L("botsKickedAll", kickedCount)
            MsgC(Color(83, 143, 239), "[Lilia] ", Color(255, 255, 255), message .. "\n")
        end
    end)

    concommand.Add("lia_check_updates", function(client)
        lia.debug("[Permissions]", "Permission Check for concommand lia_check_updates", "isValidPlayer=", tostring(IsValid(client)), "isSuperAdmin=", tostring(IsValid(client) and client:IsSuperAdmin() or true), "finalResult=", tostring(not IsValid(client) or client:IsSuperAdmin()))
        if IsValid(client) and not client:IsSuperAdmin() then
            client:notifyErrorLocalized("staffPermissionDenied")
            return
        end

        MsgC(Color(83, 143, 239), "[Lilia] ", Color(255, 255, 255), L("checkingForUpdates") .. "\n")
        lia.loader.checkForUpdates()
    end)

    local function handleSetUserGroup(ply, _, args)
        local steamID = string.Trim(args[1] or "")
        local usergroup = string.Trim(args[2] or "")
        local canUse = not IsValid(ply)
        lia.debug("[Permissions]", "Permission Check for function handleSetUserGroup", "isValidPlayer=", tostring(IsValid(ply)), "finalResult=", tostring(canUse))
        if not canUse then
            ply:notifyErrorLocalized("noPerm")
            return
        end

        if steamID == "" or not string.match(steamID, "^STEAM_%d+:%d+:%d+$") then
            if IsValid(ply) then
                ply:notifyErrorLocalized("invalidPlayer", steamID)
            else
                MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), L("invalidPlayer", steamID) .. "\n")
            end
            return
        end

        if usergroup == "" or not lia.admin.groups[usergroup] then
            if IsValid(ply) then
                ply:notifyErrorLocalized("invalidUsergroup", usergroup)
            else
                MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), L("invalidUsergroup", usergroup) .. "\n")
            end
            return
        end

        local target = lia.util.getBySteamID(steamID)
        lia.db.selectOne({"steamName", "userGroup"}, "players", "steamID = " .. lia.db.convertDataType(steamID)):next(function(data)
            if not data then
                if IsValid(ply) then
                    ply:notifyErrorLocalized("plyNoExist")
                else
                    MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), L("invalidPlayer", steamID) .. "\n")
                end
                return
            end

            lia.db.updateTable({
                userGroup = usergroup
            }, nil, "players", "steamID = " .. lia.db.convertDataType(steamID)):next(function()
                lia.admin.setSteamIDUsergroup(steamID, usergroup, IsValid(ply) and ply:Name() or "Console")
                if IsValid(target) and isfunction(target.getName) then target:notifyInfoLocalized("userGroupSet", usergroup) end
                if IsValid(ply) then
                    local targetName = isfunction(target and target.getName) and target:getName() or data.steamName or steamID
                    ply:notifyInfoLocalized("userGroupSetBy", targetName, usergroup)
                end

                lia.log.add(IsValid(ply) and ply or nil, "usergroup", IsValid(target) and target or steamID, usergroup)
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
            client:notifyErrorLocalized("noPerm")
        end
    end)

    concommand.Add("bots", function()
        if LocalPlayer():IsSuperAdmin() then return end
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

    concommand.Add("lia_randomconfig", function(client)
        if IsValid(client) then
            client:notifyErrorLocalized("commandConsoleOnly")
            return
        end

        local randomValues = {
            Boolean = function() return math.random(0, 1) == 1 end,
            Number = function(cfg) return math.Round(math.Rand(cfg.data.min or 0, cfg.data.max or 100), 2) end,
            Int = function(cfg) return math.random(cfg.data.min or 0, cfg.data.max or 100) end,
            Float = function(cfg) return math.Round(math.Rand(cfg.data.min or 0, cfg.data.max or 100), cfg.data.decimals or 2) end,
            Color = function() return Color(math.random(0, 255), math.random(0, 255), math.random(0, 255), 255) end,
            Generic = function() return "random_" .. tostring(math.random(1000, 9999)) end,
            Table = function(cfg)
                local opts = lia.config.getOptions and lia.config.getOptions(cfg.key)
                if opts and next(opts) then
                    local keys = {}
                    for k in pairs(opts) do
                        keys[#keys + 1] = k
                    end

                    local pick = opts[keys[math.random(#keys)]]
                    return pick and pick.value or nil
                end
            end,
        }

        local byType = {}
        for key, cfg in pairs(lia.config.stored) do
            local t = (cfg.data and cfg.data.type) or cfg.type or "Generic"
            if not byType[t] then
                byType[t] = {
                    key = key,
                    cfg = cfg
                }
            end
        end

        local results = {}
        for typeName, info in SortedPairs(byType) do
            local gen = randomValues[typeName]
            if not gen then continue end
            info.cfg.key = info.key
            local newVal = gen(info.cfg)
            if newVal == nil then
                results[#results + 1] = string.format("  [%s] %s -> skipped (no options)", typeName, info.key)
                continue
            end

            lia.config.set(info.key, newVal)
            results[#results + 1] = string.format("  [%s] %s = %s", typeName, info.key, tostring(newVal))
        end

        lia.debug("[lia_randomconfig] Set one random config per type:")
        for _, line in ipairs(results) do
            lia.debug(line)
        end
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


    concommand.Add("lia_snapshot", function(client, _, args)
        if IsValid(client) then
            client:notifyErrorLocalized("commandConsoleOnly")
            return
        end

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

    concommand.Add("lia_snapshot_load", function(client, _, args)
        if IsValid(client) then
            client:notifyErrorLocalized("commandConsoleOnly")
            return
        end

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

    concommand.Add("lia_wipetable", function(client, _, args)
        if IsValid(client) then
            client:notifyErrorLocalized("commandConsoleOnly")
            return
        end

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
    concommand.Add("lia_scoreboard_reload", function()
        if IsValid(lia.gui.score) then lia.gui.score:Remove() end
        vgui.Create("liaScoreboard")
    end)

    concommand.Add("lia_vgui_cleanup", function()
        for _, v in pairs(vgui.GetWorldPanel():GetChildren()) do
            if not (v.Init and debug.getinfo(v.Init, "Sln").short_src:find("chatbox")) then v:Remove() end
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
            LocalPlayer():ChatPrint(L("noSavedSoundsFound"))
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
            playButton:SetText("? " .. L("play"))
            playButton:SetWide(80)
            playButton:Dock(RIGHT)
            playButton:DockMargin(5, 5, 5, 5)
            playButton.DoClick = function()
                if file.Exists(soundPath, "DATA") then
                    local fullPath = "data/" .. soundPath
                    timer.Simple(0.1, function()
                        sound.PlayFile(fullPath, "", function(channel, _, errorString)
                            if IsValid(channel) then
                                LocalPlayer():ChatPrint(L("playingSound", soundName))
                            else
                                LocalPlayer():ChatPrint(L("failedToPlaySound", soundName, errorString or L("unknown")))
                            end
                        end)
                    end)
                else
                    LocalPlayer():ChatPrint(L("soundFileNotFound", soundName))
                end
            end

            local stopButton = vgui.Create("liaButton", panel)
            stopButton:SetText("? " .. L("stop"))
            stopButton:SetWide(80)
            stopButton:Dock(RIGHT)
            stopButton:DockMargin(5, 5, 5, 5)
            stopButton.DoClick = function()
                timer.Simple(0.1, function()
                    sound.PlayFile("", "", function() end)
                    LocalPlayer():ChatPrint(L("stoppedAllSounds"))
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
            LocalPlayer():ChatPrint(L("noSavedImagesFound"))
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
            viewButton:SetText("?? " .. L("view"))
            viewButton:SetWide(80)
            viewButton:SetPos(120, 40)
            viewButton.DoClick = function()
                local viewFrame = vgui.Create("liaFrame")
                viewFrame:SetTitle(L("imageViewerTitle", imageName))
                viewFrame:SetSize(800, 600)
                viewFrame:Center()
                viewFrame:MakePopup()
                local fullImage = vgui.Create("DImage", viewFrame)
                fullImage:Dock(FILL)
                fullImage:DockMargin(10, 10, 10, 10)
                fullImage:SetImage("data/" .. imagePath)
            end

            local copyButton = vgui.Create("liaButton", panel)
            copyButton:SetText("?? " .. L("copyPath"))
            copyButton:SetWide(100)
            copyButton:SetPos(210, 40)
            copyButton.DoClick = function()
                SetClipboardText("data/" .. imagePath)
                LocalPlayer():ChatPrint(L("imagePathCopied", "data/" .. imagePath))
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

    concommand.Add("printpos", function(client)
        if not IsValid(client) then
            MsgC(Color(255, 0, 0), "[Lilia] " .. L("errorPrefix") .. L("commandCanOnlyBeUsedByPlayers") .. "\n")
            return
        end

        local pos = client:GetPos()
        local ang = client:GetAngles()
        MsgC(Color(255, 255, 255), "Vector = (" .. math.Round(pos.x, 2) .. ", " .. math.Round(pos.y, 2) .. ", " .. math.Round(pos.z, 2) .. "), \nAngle = (" .. math.Round(ang.x, 2) .. ", " .. math.Round(ang.y, 2) .. ", " .. math.Round(ang.z, 2) .. ")\n")
    end)
end

lia.command.add("playtime", {
    adminOnly = false,
    desc = "@playtimeDesc",
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
    desc = "@charidDesc",
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
        Name = "@adminStickGetPlayTimeName",
        ButtonText = "View Play Time",
        Category = "Player Info",
    },
    desc = "@plygetplaytimeDesc",
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
        Name = "@adminStickCheckCharIDName",
        ButtonText = "View Character ID",
        Category = "Player Info",
    },
    desc = "@plycheckidDesc",
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
    desc = "@charidDesc",
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
    desc = "@manageSitroomsDesc",
    onRun = function(client)
        lia.debug("[Permissions]", "Permission Check for command manageSitRooms", "hasPrivilege(manageSitRooms)=", tostring(client:hasPrivilege("manageSitRooms")), "finalResult=", tostring(client:hasPrivilege("manageSitRooms")))
        if not client:hasPrivilege("manageSitRooms") then return end
        local rooms = lia.data.get("sitrooms", {})
        net.Start("liaManagesitrooms")
        net.WriteTable(rooms)
        net.Send(client)
    end
})

lia.command.add("addsitroom", {
    superAdminOnly = true,
    desc = "@setSitroomDesc",
    onRun = function(client)
        client:requestString("@enterNamePrompt", L("enterSitroomPrompt") .. ":", function(name)
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
    desc = "@sendToSitRoomDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "@sendToSitRoom",
        ButtonText = "Send To Sit Room",
        Category = "Teleportation",
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

        client:requestDropdown("@chooseSitroomTitle", L("selectSitroomPrompt") .. ":", names, function(selection)
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
    desc = "@returnFromSitroomDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "@returnFromSitroom",
        ButtonText = "Return From Sit Room",
        Category = "Teleportation",
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
    desc = "@charkillDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        }
    },
    AdminStick = {
        Name = "@adminStickCharKillName",
        ButtonText = "Kill Character",
        Category = "Character Discipline",
    },
    onRun = function(client, args)
        if not args[1] then
            client:notifyErrorLocalized("specifyPlayer")
            return
        end

        local ply = lia.util.findPlayer(client, args[1])
        if not IsValid(ply) then
            client:notifyErrorLocalized("targetNotFound")
            return
        end

        local char = ply:getChar()
        if not char then
            client:notifyErrorLocalized("noCharacterLoaded")
            return
        end

        local isPermakilled = char:getData("permakilled", false)
        if isPermakilled then
            char:setData("permakilled", nil)
            lia.db.delete("permakills", "charID = " .. lia.db.convertDataType(char:getID()))
            client:notifySuccessLocalized("charUnkill", client:Name(), ply:Nick())
            lia.log.add(client, "charUnkill", ply:Nick(), char:getID())
        else
            local reasonKey = L("reason")
            local evidenceKey = L("evidence")
            client:requestArguments(L("pkReasonMenu"), {
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
                local instantDeathKey = L("instantDeath")
                client:requestArguments(L("pkDeathOptionMenu"), {
                    [instantDeathKey] = "boolean"
                }, function(success2, data2)
                    if not success2 then return end
                    local instantDeath = data2[instantDeathKey]
                    if instantDeath then
                        ply:Kill()
                        client:notifySuccessLocalized("charKillInstant", client:Name(), ply:Nick())
                        lia.log.add(client, "charKillInstant", ply:Nick(), char:getID(), reason)
                    else
                        client:notifySuccessLocalized("charKill", client:Name(), ply:Nick())
                        lia.log.add(client, "charKill", ply:Nick(), char:getID(), reason)
                    end
                end)
            end)
        end
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
    desc = "@charListDesc",
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
    desc = "@plyBanDesc",
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
        Name = "@adminStickBanName",
        ButtonText = "Ban Player",
        Category = "Player Punishment",
    },
    onRun = function(client, arguments) lia.admin.serverExecCommand("ban", arguments[1], arguments[2], arguments[3], client) end
})

lia.command.add("plykick", {
    adminOnly = true,
    desc = "@plyKickDesc",
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
        Name = "@adminStickKickName",
        ButtonText = "Kick Player",
        Category = "Player Punishment",
    },
    onRun = function(client, arguments) lia.admin.serverExecCommand("kick", arguments[1], nil, arguments[2], client) end
})

lia.command.add("plykill", {
    adminOnly = true,
    desc = "@plyKillDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "@adminStickKillPlayerName",
        ButtonText = "Kill Player",
        Category = "Player State",
    },
    onRun = function(client, arguments) lia.admin.serverExecCommand("kill", arguments[1], nil, nil, client) end
})

lia.command.add("plyunban", {
    adminOnly = true,
    desc = "@plyUnbanDesc",
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
    desc = "@plyFreezeDesc",
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
    onRun = function(client, arguments) lia.admin.serverExecCommand("freeze", arguments[1], arguments[2], nil, client) end
})

lia.command.add("plyunfreeze", {
    adminOnly = true,
    desc = "@plyUnfreezeDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    onRun = function(client, arguments) lia.admin.serverExecCommand("unfreeze", arguments[1], nil, nil, client) end
})

lia.command.add("plyslay", {
    adminOnly = true,
    desc = "@plySlayDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    onRun = function(client, arguments) lia.admin.serverExecCommand("slay", arguments[1], nil, nil, client) end
})

lia.command.add("plyrespawn", {
    adminOnly = true,
    desc = "@plyRespawnDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "@adminStickRespawnPlayerName",
        ButtonText = "Respawn Player",
        Category = "Player State",
    },
    onRun = function(client, arguments) lia.admin.serverExecCommand("respawn", arguments[1], nil, nil, client) end
})

lia.command.add("plyblind", {
    adminOnly = true,
    desc = "@plyBlindDesc",
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
    onRun = function(client, arguments) lia.admin.serverExecCommand("blind", arguments[1], arguments[2], nil, client) end
})

lia.command.add("plyunblind", {
    adminOnly = true,
    desc = "@plyUnblindDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    onRun = function(client, arguments) lia.admin.serverExecCommand("unblind", arguments[1], nil, nil, client) end
})

lia.command.add("plyblindfade", {
    adminOnly = true,
    desc = "@plyBlindFadeDesc",
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
        Name = "@adminStickBlindFadeName",
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
            lia.log.add(client, "plyBlindFade", target:Name(), duration, colorName)
        end
    end
})

lia.command.add("blindfadeall", {
    adminOnly = true,
    desc = "@blindFadeAllDesc",
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
    desc = "@plyGagDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    onRun = function(client, arguments) lia.admin.serverExecCommand("gag", arguments[1], nil, nil, client) end
})

lia.command.add("plyungag", {
    adminOnly = true,
    desc = "@plyUngagDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    onRun = function(client, arguments) lia.admin.serverExecCommand("ungag", arguments[1], nil, nil, client) end
})

lia.command.add("plymute", {
    adminOnly = true,
    desc = "@plyMuteDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    onRun = function(client, arguments) lia.admin.serverExecCommand("mute", arguments[1], nil, nil, client) end
})

lia.command.add("plyunmute", {
    adminOnly = true,
    desc = "@plyUnmuteDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    onRun = function(client, arguments) lia.admin.serverExecCommand("unmute", arguments[1], nil, nil, client) end
})

lia.command.add("plybring", {
    adminOnly = true,
    desc = "@plyBringDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    onRun = function(client, arguments) lia.admin.serverExecCommand("bring", arguments[1], nil, nil, client) end
})

lia.command.add("plygoto", {
    adminOnly = true,
    desc = "@plyGotoDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    onRun = function(client, arguments) lia.admin.serverExecCommand("goto", arguments[1], nil, nil, client) end
})

lia.command.add("plyreturn", {
    adminOnly = true,
    desc = "@plyReturnDesc",
    arguments = {
        {
            name = "name",
            type = "player",
            optional = true
        },
    },
    onRun = function(client, arguments) lia.admin.serverExecCommand("return", arguments[1] or client:Name(), nil, nil, client) end
})

lia.command.add("plyjail", {
    adminOnly = true,
    desc = "@plyJailDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    onRun = function(client, arguments) lia.admin.serverExecCommand("jail", arguments[1], nil, nil, client) end
})

lia.command.add("plyunjail", {
    adminOnly = true,
    desc = "@plyUnjailDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    onRun = function(client, arguments) lia.admin.serverExecCommand("unjail", arguments[1], nil, nil, client) end
})

lia.command.add("plycloak", {
    adminOnly = true,
    desc = "@plyCloakDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "@adminStickCloakName",
        ButtonText = "Cloak Player",
        Category = "Player State",
    },
    onRun = function(client, arguments) lia.admin.serverExecCommand("cloak", arguments[1], nil, nil, client) end
})

lia.command.add("plyuncloak", {
    adminOnly = true,
    desc = "@plyUncloakDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "@adminStickUncloakName",
        ButtonText = "Uncloak Player",
        Category = "Player State",
    },
    onRun = function(client, arguments) lia.admin.serverExecCommand("uncloak", arguments[1], nil, nil, client) end
})

lia.command.add("plygod", {
    adminOnly = true,
    desc = "@plyGodDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "@adminStickGodModeName",
        ButtonText = "Enable Godmode",
        Category = "Player State",
    },
    onRun = function(client, arguments) lia.admin.serverExecCommand("god", arguments[1], nil, nil, client) end
})

lia.command.add("plyungod", {
    adminOnly = true,
    desc = "@plyUngodDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "@adminStickRemoveGodModeName",
        ButtonText = "Disable Godmode",
        Category = "Player State",
    },
    onRun = function(client, arguments) lia.admin.serverExecCommand("ungod", arguments[1], nil, nil, client) end
})

lia.command.add("plyignite", {
    adminOnly = true,
    desc = "@plyIgniteDesc",
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
    onRun = function(client, arguments) lia.admin.serverExecCommand("ignite", arguments[1], arguments[2], nil, client) end
})

lia.command.add("plyextinguish", {
    adminOnly = true,
    desc = "@plyExtinguishDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    onRun = function(client, arguments) lia.admin.serverExecCommand("extinguish", arguments[1], nil, nil, client) end
})

lia.command.add("plystrip", {
    adminOnly = true,
    desc = "@plyStripDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "@adminStickStripWeaponsName",
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
        client:notifyErrorLocalized("noPerm")
        lia.log.add(client, "unauthorizedCommand", privilegeID)
        return false
    end

    local function runTargetedAdminCommand(commandID, client, arguments, durationIndex, reasonStartIndex)
        if not hasConsoleCommandAccess(client, lia.admin.getCommandPrivilegeID(commandID)) then return end
        local target = arguments[1]
        if not target or target == "" then
            if IsValid(client) then
                client:notifyErrorLocalized("targetNotFound")
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
                client:notifyErrorLocalized("targetNotFound")
            else
                print("[Lilia] Missing SteamID.")
            end
            return
        end

        lia.db.query("DELETE FROM lia_bans WHERE playerSteamID = " .. lia.db.convertDataType(steamid))
        if IsValid(client) then
            client:notifySuccessLocalized("playerUnbanned")
            lia.log.add(client, "plyUnban", steamid)
        else
            print("[Lilia] Unbanned " .. steamid .. ".")
            lia.log.add(nil, "command", "Console unbanned " .. steamid)
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
        if IsValid(client) then
            lia.log.add(client, "plyBlindFade", target:Name(), duration, colorName)
        else
            print(string.format("[Lilia] Applied blind fade to %s.", target:Name()))
            lia.log.add(nil, "command", string.format("Console applied blind fade to %s for %s seconds (%s).", target:Name(), tostring(duration), colorName))
        end
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

        if IsValid(client) then
            lia.log.add(client, "blindFadeAll", duration, colorName)
        else
            print("[Lilia] Applied blind fade to all non-staff-faction players.")
            lia.log.add(nil, "command", string.format("Console applied blind fade to all non-staff-faction players for %s seconds (%s).", tostring(duration), colorName))
        end
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
            client:notifyErrorLocalized("cannotMuteSelf")
            return
        end

        if not target:getChar() then
            if IsValid(client) then
                client:notifyErrorLocalized("noValidCharacter")
            else
                print("[Lilia] That player does not have a valid character.")
            end
            return
        end

        local isMuted = target:getLiliaData("liaMuted", false)
        target:setLiliaData("liaMuted", not isMuted)
        if IsValid(client) then
            if isMuted then
                client:notifySuccessLocalized("textUnmuted", target:Name())
                target:notifyInfoLocalized("textUnmutedByAdmin")
            else
                client:notifySuccessLocalized("textMuted", target:Name())
                target:notifyWarningLocalized("textMutedByAdmin")
            end

            lia.log.add(client, "textToggle", target:Name(), isMuted and L("unmuted") or L("muted"))
        else
            if isMuted then
                print(string.format("[Lilia] Unmuted %s for text chat.", target:Name()))
            else
                print(string.format("[Lilia] Muted %s for text chat.", target:Name()))
            end

            lia.log.add(nil, "command", string.format("Console toggled text mute for %s to %s.", target:Name(), isMuted and "unmuted" or "muted"))
        end
    end)
end

lia.command.add("charunbanoffline", {
    superAdminOnly = true,
    desc = "@charUnbanOfflineDesc",
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
    desc = "@charBanOfflineDesc",
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
    desc = "@playGlobalSoundDesc",
    arguments = {
        {
            name = "sound",
            type = "string"
        },
    },
    onRun = function(client, arguments)
        local sound = arguments[1]
        if not sound or sound == "" then
            client:notifyErrorLocalized("noSound")
            return
        end

        for _, target in player.Iterator() do
            target:PlaySound(sound)
        end
    end
})

lia.command.add("plyspectate", {
    adminOnly = true,
    desc = "@plySpectateDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "@adminStickSpectateName",
        ButtonText = "Spectate Player",
        Category = "Observation",
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
    desc = "@stopSpectateDesc",
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
    desc = "@playSoundDesc",
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
    desc = "@returnToDeathPosDesc",
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
    desc = "@rollDesc",
    onRun = function(client)
        local rollValue = math.random(0, 100)
        lia.chat.send(client, "roll", rollValue)
    end
})

lia.command.add("forcefallover", {
    adminOnly = true,
    desc = "@forceFalloverDesc",
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

--[[
    Hooks:
        OnCharGetup(Player target, Entity entity)

    Purpose:
        Runs just before a ragdolled character gets up and their ragdoll entity is removed.

    Category:
        Character

    Parameters:
        target (Player)
            The player getting up from ragdoll state.

        entity (Entity)
            The ragdoll entity that is about to be removed.

    Returns:
        nil

    Example Usage:
        ```lua
        hook.Add("OnCharGetup", "liaExampleOnCharGetup", function(target, entity)
            if IsValid(target) then
                print(target:Nick(), "got up")
            end
        end)
        ```

    Realm:
        Server
]]
lia.command.add("forcegetup", {
    adminOnly = true,
    desc = "@forceGetUpDesc",
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

        if not IsValid(target:GetRagdollEntity()) then return end
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
    desc = "@changeCharDesc",
    arguments = {
        {
            name = "desc",
            type = "string",
            optional = true
        },
    },
    onRun = function(client, arguments)
        local desc = table.concat(arguments, " ")
        if not desc:find("%S") then return client:requestString("@chgName", "@chgNameDesc", function(text) lia.command.run(client, "chardesc", {text}) end, client:getChar() and client:getChar():getDesc() or "") end
        local trimmedDesc = string.Trim(desc)
        local descWithoutSpaces = string.gsub(trimmedDesc, "%s", "")
        local minLength = lia.config.get("MinDescLen", 16)
        if #descWithoutSpaces < minLength then
            client:notifyErrorLocalized("descMinLen", minLength)
            return
        end

        local character = client:getChar()
        if character then character:setDesc(desc) end
        return "@descChanged"
    end
})

lia.command.add("chargetup", {
    adminOnly = false,
    desc = "@forceSelfGetUpDesc",
    onRun = function(client)
        if not IsValid(client:GetRagdollEntity()) then return end
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
    desc = "@fallOverDesc",
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
    desc = "@toggleCharLockDesc",
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
    desc = "@checkInventoryDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "@adminStickCheckInventoryName",
        ButtonText = "View Inventory",
        Category = "Inventory",
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
    desc = "@flagGiveDesc",
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
            return client:requestString(L("give") .. " " .. L("flags"), "@flagGiveDesc", function(text) lia.command.run(client, "flaggive", {target:Name(), text}) end, available)
        end

        target:giveFlags(flags)
        client:notifySuccessLocalized("flagGive", client:Name(), flags, target:Name())
        lia.log.add(client, "flagGive", target:Name(), flags)
    end,
    alias = {"giveflag", "chargiveflag"}
})

lia.command.add("flaggiveall", {
    adminOnly = true,
    desc = "@giveAllFlagsDesc",
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
    desc = "@takeAllFlagsDesc",
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
    desc = "@flagTakeDesc",
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
            return client:requestString(L("take") .. " " .. L("flags"), "@flagTakeDesc", function(text) lia.command.run(client, "flagtake", {target:Name(), text}) end, table.concat(currentFlags, ", "))
        end

        target:takeFlags(flags)
        client:notifySuccessLocalized("flagTake", client:Name(), flags, target:Name())
        lia.log.add(client, "flagTake", target:Name(), flags)
    end,
    alias = {"takeflag"}
})

lia.command.add("bringlostitems", {
    superAdminOnly = true,
    desc = "@bringLostItemsDesc",
    onRun = function(client)
        for _, v in ipairs(ents.FindInSphere(client:GetPos(), 500)) do
            if v:isItem() then v:SetPos(client:GetPos()) end
        end
    end
})

lia.command.add("charvoicetoggle", {
    adminOnly = true,
    desc = "@charVoiceToggleDesc",
    arguments = {
        {
            name = "name",
            type = "string"
        },
    },
    AdminStick = {
        Name = "@toggleVoice",
        ButtonText = "Toggle Voice",
        Category = "Communication",
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyErrorLocalized("targetNotFound")
            return
        end

        if lia.admin.isProtectedStaffTarget("mute", target) then
            lia.admin.notifyProtectedStaffTarget(client)
            return false
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
    desc = "@cleanItemsDesc",
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
    desc = "@cleanPropsDesc",
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
    desc = "@resetMapPropsDesc",
    onRun = function(client)
        local started = SysTime()
        client:notifyInfoLocalized("resetMapPropsRunning")
        game.CleanUpMap(false, nil, function()
            if not IsValid(client) then return end
            local elapsed = math.Round((SysTime() - started) * 1000)
            client:notifySuccessLocalized("resetMapPropsSuccess", elapsed)
        end)
    end
})

lia.command.add("cleannpcs", {
    superAdminOnly = true,
    desc = "@cleanNPCsDesc",
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
    desc = "@charUnbanDesc",
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
    desc = "@clearInvDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "@adminStickClearInventoryName",
        ButtonText = "Clear Inventory",
        Category = "Inventory",
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
    desc = "@kickCharDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "@adminStickKickCharacterName",
        ButtonText = "Kick Character",
        Category = "Character Discipline",
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
    desc = "@freezeAllPropsDesc",
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
    desc = "@banCharDesc",
    arguments = {
        {
            name = "nameOrNumberId",
            type = "string"
        },
    },
    AdminStick = {
        Name = "@banCharacter",
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
    desc = "@charWipeDesc",
    arguments = {
        {
            name = "nameOrNumberId",
            type = "string"
        },
    },
    AdminStick = {
        Name = "@wipeCharacter",
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

                hook.Run("SyncCharList", target)
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
    desc = "@charWipeOfflineDesc",
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
    desc = "@checkMoneyDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "@adminStickCheckMoneyName",
        ButtonText = "View Money",
        Category = "Character Info",
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
    desc = "@listBodygroupsDesc",
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
    desc = "@setSpeedDesc",
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
        Name = "@adminStickSetCharSpeedName",
        ButtonText = "Set Character Speed",
        Category = "Character Editing",
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
    privilege = "manageCharacterInformation",
    desc = "@setModelDesc",
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
        client:notifySuccessLocalized("changeModelAdmin", client:Name(), target:Name(), arguments[2] or oldModel)
        lia.log.add(client, "charsetmodel", target:Name(), arguments[2], oldModel)
    end
})

lia.command.add("chareditbodygroups", {
    adminOnly = true,
    privilege = "changeBodygroups",
    desc = "@editBodygroupsDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        }
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1] or "")
        if not target or not IsValid(target) then
            client:notifyErrorLocalized("targetNotFound")
            return
        end

        if not target:getChar() then
            client:notifyErrorLocalized("noCharacterLoaded")
            return
        end

        net.Start("BodygrouperMenu")
        net.WriteEntity(target)
        net.Send(client)
    end
})

lia.command.add("chargiveitem", {
    superAdminOnly = true,
    desc = "@giveItemDesc",
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
        Name = "@adminStickGiveItemName",
        ButtonText = "Give Item",
        Category = "Inventory",
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
    desc = "@setDescDesc",
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
        Name = "@adminStickSetCharDescName",
        ButtonText = "Set Description",
        Category = "Character Editing",
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
        if not desc:find("%S") then return client:requestString(L("chgDescTitle", target:Name()), "@enterNewDesc", function(text) lia.command.run(client, "charsetdesc", {arguments[1], text}) end, target:getChar():getDesc()) end
        target:getChar():setDesc(desc)
        return L("descChangedTarget", client:Name(), target:Name())
    end
})

lia.command.add("charsetname", {
    adminOnly = true,
    desc = "@setNameDesc",
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
        Name = "@adminStickSetCharNameName",
        ButtonText = "Set Character Name",
        Category = "Character Editing",
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyErrorLocalized("targetNotFound")
            return
        end

        local newName = table.concat(arguments, " ", 2)
        if newName == "" then return client:requestString("@chgName", "@chgNameDesc", function(text) lia.command.run(client, "charsetname", {target:Name(), text}) end, target:Name()) end
        local oldName = target:getChar():getName()
        target:getChar():setName(newName:gsub("#", "#?"))
        client:notifySuccessLocalized("changeName", client:Name(), oldName, newName)
    end
})

lia.command.add("charsetscale", {
    adminOnly = true,
    desc = "@setScaleDesc",
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
        Name = "@adminStickSetCharScaleName",
        ButtonText = "Set Character Scale",
        Category = "Character Editing",
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
    desc = "@setJumpDesc",
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
        Name = "@adminStickSetCharJumpName",
        ButtonText = "Set Jump Power",
        Category = "Character Editing",
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
    desc = "@setBodygroupDesc",
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

        local index = lia.util.resolveBodygroupIndex(target, bodyGroup)
        if index ~= nil then
            if value and value < 1 then value = nil end
            local groups = lia.util.normalizeBodygroups(target:getChar().vars.bodygroups)
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
    desc = "@setSkinDesc",
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
        Name = "@adminStickSetCharSkinName",
        ButtonText = "Set Character Skin",
        Category = "Character Editing",
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
            client:notifyErrorLocalized("invalidArg")
            return
        end

        target:getChar():setSkin(skin)
        target:SetSkin(skin)
        client:notifySuccessLocalized("changeSkin", client:Name(), target:Name(), skin)
    end
})

lia.command.add("charsetmoney", {
    superAdminOnly = true,
    desc = "@setMoneyDesc",
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
        StaffAddTextShadowed(Color(34, 139, 34), "MONEY", Color(255, 255, 255), L("staffLogSetMoney", client:Name(), target:Name(), target:SteamID64(), lia.currency.get(math.floor(amount))))
    end
})

lia.command.add("charaddmoney", {
    superAdminOnly = true,
    desc = "@addMoneyDesc",
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
        StaffAddTextShadowed(Color(34, 139, 34), "MONEY", Color(255, 255, 255), L("staffLogGaveMoney", client:Name(), lia.currency.get(amount), target:Name(), target:SteamID64(), lia.currency.get(currentMoney + amount)))
    end,
    alias = {"chargivemoney"}
})

lia.command.add("globalbotsay", {
    superAdminOnly = true,
    desc = "@globalBotSayDesc",
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
    desc = "@botSayDesc",
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
    desc = "@forceSayDesc",
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
        Name = "@adminStickForceSayName",
        ButtonText = "Force Say",
        Category = "Communication",
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
    desc = "@getModelDesc",
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
    desc = "@pmDesc",
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
    desc = "@getCharModelDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "@adminStickGetCharModelName",
        ButtonText = "View Model",
        Category = "Character Info",
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
    desc = "@checkAllMoneyDesc",
    onRun = function(client)
        for _, target in player.Iterator() do
            local char = target:getChar()
            if char then client:ChatPrint(L("playerMoney", target:GetName(), lia.currency.get(char:getMoney()))) end
        end
    end
})

lia.command.add("checkflags", {
    adminOnly = true,
    desc = "@checkFlagsDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "@adminStickGetCharFlagsName",
        ButtonText = "View Flags",
        Category = "Character Info",
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
    desc = "@getCharNameDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "@adminStickGetCharNameName",
        ButtonText = "View Character Name",
        Category = "Character Info",
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
    desc = "@getHealthDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "@adminStickGetCharHealthName",
        ButtonText = "View Health",
        Category = "Character Info",
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
    desc = "@getMoneyDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "@adminStickGetCharMoneyName",
        ButtonText = "View Money",
        Category = "Character Info",
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
    desc = "@getInventoryDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "@adminStickGetCharInventoryName",
        ButtonText = "View Inventory",
        Category = "Character Info",
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
    desc = "@getAllInfosDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "@adminStickGetAllInfosName",
        ButtonText = "View All Info",
        Category = "Character Info",
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

        lia.admin(L("allInfoFor", char:getName()))
        for column, value in pairs(data) do
            if istable(value) then
                lia.admin(column .. ":")
                PrintTable(value)
            else
                lia.admin(column .. " = " .. tostring(value))
            end
        end

        client:notifyInfoLocalized("infoPrintedConsole")
    end
})

lia.command.add("dropmoney", {
    desc = "@dropMoneyDesc",
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
    desc = "@exportprivilegesDesc",
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
            if lia.admin then
                table.insert(srcs, lia.admin.privileges)
                if isfunction(lia.admin.getPrivileges) == "function" then
                    local ok, r = pcall(lia.admin.getPrivileges, lia.admin)
                    if ok then table.insert(srcs, r) end
                end
            end

            if lia.admin then
                table.insert(srcs, lia.admin.privileges)
                if isfunction(lia.admin.getPrivileges) then
                    local ok, r = pcall(lia.admin.getPrivileges, lia.admin)
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
            MsgC(Color(83, 143, 239), "[Lilia] ", "[" .. L("admin") .. "] ")
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
    desc = "@botsManageDesc",
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
            client:notifyErrorLocalized("botsAlreadyAdding")
            return
        end

        local requestedAmount = arguments.amount
        if requestedAmount then
            requestedAmount = math.max(1, math.floor(requestedAmount))
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
            timer.Create("Bots_Add_Timer", 2, 0, function()
                if botsSpawned < requestedAmount and player.GetCount() < game.MaxPlayers() then
                    game.ConsoleCommand("bot\n")
                    botsSpawned = botsSpawned + 1
                else
                    timer.Remove("Bots_Add_Timer")
                end
            end)

            client:notifyInfoLocalized("spawningBots", requestedAmount)
        else
            timer.Create("Bots_Add_Timer", 2, 0, function()
                if player.GetCount() < game.MaxPlayers() then
                    game.ConsoleCommand("bot\n")
                else
                    timer.Remove("Bots_Add_Timer")
                end
            end)

            client:notifyInfoLocalized("botsFillingServer")
        end
    end
})

lia.command.add("spawnbots", {
    superAdminOnly = true,
    desc = "@spawnBotsDesc",
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
    desc = "@spawnBotDesc",
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
    desc = "@botsSpeakDesc",
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
    desc = "@setAttributes",
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
        Name = "@setAttributes",
        ButtonText = "Set Attributes",
        Category = "Attributes",
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
                if lia.util.stringMatches(v.name, attribName) or lia.util.stringMatches(k, attribName) then
                    character:setAttrib(k, math.abs(attribNumber))
                    client:notifySuccessLocalized("attribSet", target:Name(), v.name, math.abs(attribNumber))
                    lia.log.add(client, "attribSet", target:Name(), k, math.abs(attribNumber))
                    return
                end
            end
        end
    end
})

lia.command.add("checkattributes", {
    adminOnly = true,
    desc = "@checkAttributes",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "@checkAttributes",
        ButtonText = "View Attributes",
        Category = "Attributes",
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
    desc = "@staffdiscordDesc",
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
    desc = "@trunkOpenDesc",
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
    desc = "@restockVendorDesc",
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
    desc = "@restockAllVendorsDesc",
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
    desc = "@deleteVendorPresetDesc",
    arguments = {
        {
            name = "presetName",
            type = "string"
        },
    },
    onRun = function(client, arguments)
        lia.debug("[Permissions]", "Permission Check for command savevendorpreset", "hasPrivilege(canCreateVendorPresets)=", tostring(client:hasPrivilege("canCreateVendorPresets")), "finalResult=", tostring(client:hasPrivilege("canCreateVendorPresets")))
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
    desc = "@listVendorPresetsDesc",
    onRun = function(client)
        lia.debug("[Permissions]", "Permission Check for command listvendorpresets", "hasPrivilege(canCreateVendorPresets)=", tostring(client:hasPrivilege("canCreateVendorPresets")), "finalResult=", tostring(client:hasPrivilege("canCreateVendorPresets")))
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
    desc = "@addAttributes",
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
        Name = "@addAttributes",
        ButtonText = "Add Attributes",
        Category = "Attributes",
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
                if lia.util.stringMatches(v.name, attribName) or lia.util.stringMatches(k, attribName) then
                    character:updateAttrib(k, math.abs(attribNumber))
                    client:notifySuccessLocalized("attribUpdate", target:Name(), v.name, math.abs(attribNumber))
                    lia.log.add(client, "attribAdd", target:Name(), k, math.abs(attribNumber))
                    return
                end
            end
        end
    end
})

lia.command.add("banooc", {
    adminOnly = true,
    desc = "@banOOCCommandDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "@banOOC",
        ButtonText = "Ban From OOC",
        Category = "Communication",
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
    desc = "@unbanOOCCommandDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "@unbanOOCStickName",
        ButtonText = "Unban From OOC",
        Category = "Communication",
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
    desc = "@clearChatCommandDesc",
    onRun = function(client)
        net.Start("liaRegenChat")
        net.Broadcast()
        lia.log.add(client, "clearChat")
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
    desc = "@doorsellDesc",
    adminOnly = false,
    AdminStick = {
        Name = "@adminStickDoorSellName",
        ButtonText = "Sell This Door",
        Category = "doorActions",
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
    desc = "@admindoorsellDesc",
    adminOnly = true,
    AdminStick = {
        Name = "@adminStickAdminDoorSellName",
        ButtonText = "Force Sell This Door",
        Category = "doorActions",
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
    desc = "@doortogglelockDesc",
    adminOnly = true,
    AdminStick = {
        Name = "@adminStickToggleDoorLockName",
        ButtonText = "Toggle Door Lock",
        Category = "doorActions",
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
                    lia.log.add(client, "toggleLock", door, L("locked"))
                else
                    door:Fire("unlock")
                    door:EmitSound("doors/door_latch1.wav")
                    doorData.locked = false
                    lia.doors.setCachedData(door, doorData)
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
    desc = "@doorbuyDesc",
    adminOnly = false,
    AdminStick = {
        Name = "@buyDoor",
        ButtonText = "Buy This Door",
        Category = "doorActions",
        TargetClass = "door",
    },
    onRun = function(client, arguments)
        local door = resolveDoorCommandTarget(client, arguments, 0)
        if door then
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
    desc = "@doortoggleownableDesc",
    adminOnly = true,
    AdminStick = {
        Name = "@adminStickToggleDoorOwnableName",
        ButtonText = "Toggle Door Ownable",
        Category = "doorSettings",
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
    desc = "@doorresetdataDesc",
    adminOnly = true,
    AdminStick = {
        Name = "@adminStickResetDoorDataName",
        ButtonText = "Reset Door Data",
        Category = "doorMaintenance",
        TargetClass = "door",
    },
    onRun = function(client, arguments)
        local door = resolveDoorCommandTarget(client, arguments, 0)
        if door then
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
    desc = "@doortoggleenabledDesc",
    adminOnly = true,
    AdminStick = {
        Name = "@adminStickToggleDoorEnabledName",
        ButtonText = "Toggle Door Enabled",
        Category = "doorSettings",
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
    desc = "@doortogglehiddenDesc",
    adminOnly = true,
    AdminStick = {
        Name = "@adminStickToggleDoorHiddenName",
        ButtonText = "Toggle Door Hidden",
        Category = "doorSettings",
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
            lia.log.add(client, "doorSetHidden", door, newState)
            hook.Run("DoorHiddenToggled", client, door, newState)
            client:notifySuccessLocalized(newState and "doorSetHidden" or "doorSetNotHidden")
            lia.module.get("doors"):SaveData()
        else
            client:notifyErrorLocalized("doorNotValid")
        end
    end
})

lia.command.add("doorsetprice", {
    desc = "@doorsetpriceDesc",
    arguments = {
        {
            name = "price",
            type = "string"
        },
    },
    adminOnly = true,
    AdminStick = {
        Name = "@adminStickSetDoorPriceName",
        ButtonText = "Set Door Price",
        Category = "doorSettings",
        TargetClass = "door",
    },
    onRun = function(client, arguments)
        local door, argumentIndex = resolveDoorCommandTarget(client, arguments, 1)
        if door then
            local doorData = lia.doors.getData(door)
            if not doorData.disabled then
                if not arguments[argumentIndex] or not tonumber(arguments[argumentIndex]) then return client:notifyErrorLocalized("invalidClass") end
                local price = math.Clamp(math.floor(tonumber(arguments[argumentIndex])), 0, 1000000)
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
    desc = "@doorsettitleDesc",
    arguments = {
        {
            name = "title",
            type = "string"
        },
    },
    adminOnly = true,
    AdminStick = {
        Name = "@doorsettitle",
        ButtonText = "Set Door Title",
        Category = "doorSettings",
        TargetClass = "door",
    },
    onRun = function(client, arguments)
        local door, argumentIndex = resolveDoorCommandTarget(client, arguments, 1)
        if door then
            local doorData = lia.doors.getData(door)
            if not doorData.disabled then
                local name = table.concat(arguments, " ", argumentIndex)
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
    desc = "@savedoorsDesc",
    adminOnly = true,
    AdminStick = {
        Name = "@adminStickSaveDoorsName",
        ButtonText = "Save Door Data",
        Category = "doorMaintenance",
        TargetClass = "door",
    },
    onRun = function(client)
        lia.module.get("doors"):SaveData()
        lia.log.add(client, "doorSaveData")
        client:notifySuccessLocalized("doorsSaved")
    end
})

lia.command.add("doorinfo", {
    desc = "@doorinfoDesc",
    adminOnly = true,
    AdminStick = {
        Name = "@adminStickDoorInfoName",
        ButtonText = "View Door Info",
        Category = "doorInformation",
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
                    property = L("disabled"),
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
    desc = "@doorsampledataDesc",
    adminOnly = true,
    AdminStick = {
        Name = "@adminStickDoorSampleName",
        ButtonText = "Copy Door Settings",
        Category = "doorMaintenance",
        TargetClass = "door",
    },
    onRun = function(client, arguments)
        local door = resolveDoorCommandTarget(client, arguments, 0)
        if door then
            local doorData = lia.doors.getData(door)
            local sampleData = {
                name = L("sampleDoorName", door:MapCreationID() or L("unknown")),
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
        Category = "doorMaintenance",
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
        lia.log.add(client, "doorSampleData", door, "randomized")
        client:notifySuccess("Random door information applied.")
    end
})

lia.command.add("dooraddfaction", {
    desc = "@dooraddfactionDesc",
    arguments = {
        {
            name = "faction",
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
                elseif arguments[argumentIndex] then
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
    desc = "@doorremovefactionDesc",
    arguments = {
        {
            name = "faction",
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
                elseif arguments[argumentIndex] then
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
    desc = "@doorsetclassDesc",
    arguments = {
        {
            name = "class",
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
                elseif arguments[argumentIndex] then
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
    desc = "@doorremoveclassDesc",
    arguments = {
        {
            name = "class",
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
                elseif arguments[argumentIndex] then
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
            client:notifyErrorLocalized("doorNotValid")
            return
        end

        client.liaCopiedDoorFactions = {
            hasData = true,
            values = cloneDoorRestrictionList(doorData.factions)
        }

        client:notifySuccessLocalized("doorFactionsCopied", #(client.liaCopiedDoorFactions.values or {}))
    end
})

lia.command.add("doorpastefactions", {
    adminOnly = true,
    onRun = function(client, arguments)
        local door = resolveDoorCommandTarget(client, arguments, 0)
        if not door then return end
        local doorData = lia.doors.getData(door)
        if doorData.disabled then
            client:notifyErrorLocalized("doorNotValid")
            return
        end

        local copiedData = client.liaCopiedDoorFactions
        if not copiedData or not copiedData.hasData then
            client:notifyErrorLocalized("doorNoCopiedFactions")
            return
        end

        local factions = cloneDoorRestrictionList(copiedData.values)
        doorData.factions = factions
        door.liaFactions = #factions > 0 and factions or nil
        if #factions > 0 then doorData.noSell = true end
        lia.doors.setData(door, doorData)
        lia.module.get("doors"):SaveData()
        client:notifySuccessLocalized("doorFactionsPasted", #factions)
    end
})

lia.command.add("doorcopyclasses", {
    adminOnly = true,
    onRun = function(client, arguments)
        local door = resolveDoorCommandTarget(client, arguments, 0)
        if not door then return end
        local doorData = lia.doors.getData(door)
        if doorData.disabled then
            client:notifyErrorLocalized("doorNotValid")
            return
        end

        client.liaCopiedDoorClasses = {
            hasData = true,
            values = cloneDoorRestrictionList(doorData.classes)
        }

        client:notifySuccessLocalized("doorClassesCopied", #(client.liaCopiedDoorClasses.values or {}))
    end
})

lia.command.add("doorpasteclasses", {
    adminOnly = true,
    onRun = function(client, arguments)
        local door = resolveDoorCommandTarget(client, arguments, 0)
        if not door then return end
        local doorData = lia.doors.getData(door)
        if doorData.disabled then
            client:notifyErrorLocalized("doorNotValid")
            return
        end

        local copiedData = client.liaCopiedDoorClasses
        if not copiedData or not copiedData.hasData then
            client:notifyErrorLocalized("doorNoCopiedClasses")
            return
        end

        local classes = cloneDoorRestrictionList(copiedData.values)
        doorData.classes = classes
        door.liaClasses = #classes > 0 and classes or nil
        if #classes > 0 then doorData.noSell = true end
        lia.doors.setData(door, doorData)
        lia.module.get("doors"):SaveData()
        client:notifySuccessLocalized("doorClassesPasted", #classes)
    end
})

lia.command.add("togglealldoors", {
    desc = "@togglealldoorsDesc",
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
    desc = "@doorIDDesc",
    adminOnly = true,
    onRun = function(client, arguments)
        local door = resolveDoorCommandTarget(client, arguments, 0)
        if door then
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
    desc = "@listDoorIDsDesc",
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
                property = L("doorID") .. data.id,
                value = L("position") .. ": " .. data.position .. L("modelLabel") .. data.model
            })
        end

        lia.util.sendTableUI(client, L("doorIDsOnMap", game.GetMap()), {
            {
                name = L("doorID"),
                field = "property"
            },
            {
                name = L("detailsColumn"),
                field = "value"
            }
        }, doorList)
    end
})

lia.command.add("plytransfer", {
    adminOnly = true,
    desc = "@plyTransferDesc",
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
            client:notifyErrorLocalized("targetNotFound")
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
            client:notifyErrorLocalized("staffTransferBlocked")
            return
        end

        local targetChar = targetPlayer:getChar()
        if hook.Run("CanCharBeTransfered", targetChar, faction, targetPlayer:Team()) == false then return end
        local oldFaction = targetChar:getFaction()
        local oldFactionName = lia.faction.indices[oldFaction] and lia.faction.indices[oldFaction].name or oldFaction
        hook.Run("TrackFactionTransfer", targetChar, oldFaction, faction, client, "commandTransfer")
        targetChar.vars.faction = faction.uniqueID
        targetChar:setFaction(faction.index)
        hook.Run("OnTransferred", targetPlayer)
        if faction.OnTransferred then faction:OnTransferred(targetPlayer, oldFaction) end
        client:notifySuccessLocalized("transferSuccess", targetPlayer:Name(), faction.name)
        if client ~= targetPlayer then targetPlayer:notifyInfoLocalized("transferNotification", faction.name, client:Name()) end
        lia.log.add(client, "plyTransfer", targetPlayer:Name(), oldFactionName, faction.name)
    end
})

lia.command.add("plywhitelist", {
    adminOnly = true,
    desc = "@plyWhitelistDesc",
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
                    if k ~= "staff" then options[v.name] = k end
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
                v:notifyInfoLocalized("whitelist", client:Name(), target:Name(), faction.name)
            end

            lia.log.add(client, "plyWhitelist", target:Name(), faction.name)
        end
    end
})

lia.command.add("plyunwhitelist", {
    adminOnly = true,
    desc = "@plyUnwhitelistDesc",
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
                    if k ~= "staff" then options[v.name] = k end
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
                    v:notifyInfoLocalized("unwhitelist", client:Name(), target:Name(), faction.name)
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
    desc = "@beClassDesc",
    arguments = {
        {
            name = "class",
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
            name = "model",
            type = "string",
            optional = true
        }
    },
    onRun = function(client, arguments)
        local className = arguments[1]
        local requestedModel = arguments[2]
        local character = client:getChar()
        if not IsValid(client) or not character then
            client:notifyErrorLocalized("illegalAccess")
            return
        end

        local classID = tonumber(className) or lia.class.retrieveClass(className)
        local classData = lia.class.get(classID)
        if not classData then
            client:notifyErrorLocalized("invalidClass")
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
            if applyRequestedClassModel() then client:notifyLocalized("modelUpdatedOnRespawn") end
            return
        end

        if lia.class.canBe(client, classID) then
            if character:joinClass(classID) then
                if not istable(classModels) then character:setData("classModel", nil) end
                applyRequestedClassModel()
                client:notifySuccessLocalized("becomeClass", classData.name)
                lia.log.add(client, "beClass", classData.name)
            else
                client:notifyErrorLocalized("becomeClassFail", classData.name)
            end
        else
            client:notifyErrorLocalized("invalidClass")
        end
    end
})

lia.command.add("setclass", {
    adminOnly = true,
    desc = "@setClassDesc",
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
                    if canAccess and target:getChar():getClass() ~= v.uniqueID then options[v.name] = v.uniqueID end
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
                target:notifyInfoLocalized("classSet", classData.name)
                if client ~= target then client:notifySuccessLocalized("classSetOther", target:GetName(), classData.name) end
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
    desc = "@classWhitelistDesc",
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
            target:notifyInfoLocalized("classAssigned", classData.name)
            lia.log.add(client, "classWhitelist", target:Name(), classData.name)
        end
    end
})

lia.command.add("classunwhitelist", {
    adminOnly = true,
    desc = "@classUnwhitelistDesc",
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
            target:notifyInfoLocalized("classUnassigned", classData.name)
            lia.log.add(client, "classUnwhitelist", target:Name(), classData.name)
        end
    end
})

lia.command.add("spawnadd", {
    adminOnly = true,
    desc = "@spawnAddDesc",
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
                    client:notifySuccessLocalized("spawnAdded")
                end)
            end)
        else
            client:notifyErrorLocalized("invalidFaction")
        end
    end
})

lia.command.add("spawnremoveinradius", {
    adminOnly = true,
    desc = "@spawnRemoveInRadiusDesc",
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
                    client:notifySuccessLocalized("spawnDeleted")
                end)
            else
                lia.log.add(client, "spawnRemoveRadius", radius, removedCount)
                client:notifySuccessLocalized("spawnDeleted")
            end
        end)
    end
})

lia.command.add("spawnremovebyname", {
    adminOnly = true,
    desc = "@spawnRemoveByNameDesc",
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
                            client:notifySuccessLocalized("spawnDeletedByName")
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
    desc = "@returnItemsDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "@returnItems",
        ButtonText = "Return Lost Items",
        Category = "Inventory",
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
    desc = "@returnAllItemsDesc",
    AdminStick = {
        Name = "@returnAllItems",
        ButtonText = "Return All Lost Items",
        Category = "Inventory",
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
    desc = "@viewTicketsDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    onRun = function(client, arguments)
        local targetName = arguments[1]
        if not targetName then
            client:notifyErrorLocalized("specifyPlayer")
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
    desc = "@plyViewClaimsDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "@viewTicketClaims",
        ButtonText = "View Ticket Claims",
        Category = "Tickets",
    },
    onRun = function(client, arguments)
        local targetName = arguments[1]
        if not targetName then
            client:notifyErrorLocalized("specifyPlayer")
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
    desc = "@viewAllClaimsDesc",
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
    desc = "@viewClaimsDesc",
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
    desc = "@warnDesc",
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
            name = "reason",
            type = "string"
        },
    },
    AdminStick = {
        Name = "@warnPlayer",
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
            client:notifyErrorLocalized("invalidArg")
            return
        else
            reasonStartIndex = 2
        end

        local reason = table.concat(arguments, " ", reasonStartIndex)
        if not targetName or reason == "" then return L("warnUsage") end
        local target = lia.util.findPlayer(client, targetName)
        if not target or not IsValid(target) then
            client:notifyErrorLocalized("targetNotFound")
            return
        end

        local timestamp = os.date("%Y-%m-%d %H:%M:%S")
        local warnerName = client:Nick()
        local warnerSteamID = client:SteamID()
        hook.Run("AddWarning", target:getChar():getID(), target:Nick(), target:SteamID(), timestamp, reason, warnerName, warnerSteamID, severity)
        lia.db.count("warnings", "charID = " .. lia.db.convertDataType(target:getChar():getID())):next(function(count)
            target:notifyWarningLocalized("playerWarned", warnerName .. " (" .. warnerSteamID .. ")", severity, reason)
            client:notifySuccessLocalized("warningIssued", target:Nick())
            local message = L("staffLogWarnedPlayer", warnerName, target:Name(), target:getChar():getID(), target:SteamID64(), reason, severity)
            StaffAddTextShadowed(Color(255, 140, 0), "WARNING", Color(255, 255, 255), message)
            hook.Run("WarningIssued", client, target, reason, severity, count, warnerSteamID, target:SteamID())
        end)
    end
})

lia.command.add("previewchatmessages", {
    superAdminOnly = true,
    desc = "@previewChatOutputs",
    onRun = function(client)
        if not IsValid(client) then return end
        local ts = os.date("%Y-%m-%d %H:%M:%S")
        ClientAddTextShadowed(client, Color(255, 165, 0), "PREVIEW", Color(255, 255, 255), " | " .. ts .. " | Shadowed sample message (general).")
        ClientAddTextShadowed(client, Color(255, 140, 0), "WARNING", Color(255, 255, 255), " | " .. ts .. " | Low severity warning preview.")
        ClientAddTextShadowed(client, Color(255, 215, 0), "WARNING", Color(255, 255, 255), " | " .. ts .. " | Medium severity warning preview.")
        ClientAddTextShadowed(client, Color(255, 0, 0), "WARNING", Color(255, 255, 255), " | " .. ts .. " | High severity warning preview.")
        ClientAddTextShadowed(client, Color(255, 0, 0), "DEATH", Color(255, 255, 255), " | " .. ts .. " | John Doe (Character 12 | Steam64ID: 76561198000000000) was killed by Character 13 | Steam64ID: 76561198000000001.")
        ClientAddTextShadowed(client, Color(255, 165, 0), "INSERT", Color(255, 255, 255), " | " .. ts .. " | Player 12 (Steam64ID: 76561198000000002) pressed the Insert key.")
        ClientAddTextShadowed(client, Color(199, 21, 133), "INVENTORY", Color(255, 255, 255), " | " .. ts .. " | Inventory size changed to 10x10.")
        ClientAddTextShadowed(client, Color(34, 139, 34), "MONEY", Color(255, 255, 255), " | " .. ts .. " | $5,000 granted to player preview.")
        ClientAddTextShadowed(client, Color(123, 104, 238), "SIT", Color(255, 255, 255), " | " .. ts .. " | Teleport preview to sit room.")
        ClientAddText(client, Color(200, 200, 200), "[Preview] ", Color(255, 255, 255), "Non-shadowed chat line for comparison.")
        client:notifySuccessLocalized("previewMessagesSent")
    end
})

if CLIENT then
    local panelBrowserCatalog = {
        {
            name = "liaFrame",
            note = "Shared frame panel using the updated F1-style paint.",
            example = true
        },
        {
            name = "liaButton",
            note = "Shared button panel using the updated F1-style paint.",
            example = true
        },
        {
            name = "liaScrollPanel",
            note = "Shared scroll panel using the updated F1-style paint.",
            example = true
        },
        {
            name = "liaHeaderPanel",
            note = "Shared header line panel using the updated F1-style paint.",
            example = true
        }
    }

    local rawPreviewPanels = {
        liaButton = true,
        liaFrame = true,
        liaHeaderPanel = true,
        liaScrollPanel = true
    }

    table.sort(panelBrowserCatalog, function(a, b) return a.name < b.name end)
    local function panelBrowserHost(title, width, height)
        local frame = vgui.Create("liaFrame")
        frame:SetSize(width or 720, height or 480)
        frame:Center()
        frame:SetTitle(title or "Lilia Panel Preview")
        frame:MakePopup()
        return frame
    end

    local function panelBrowserLabel(parent, text, font, dockMargin)
        local label = parent:Add("DLabel")
        label:Dock(TOP)
        label:DockMargin(dockMargin or 0, 0, 0, 8)
        label:SetFont(font or "LiliaFont.18")
        label:SetTextColor(lia.color.theme.text or color_white)
        label:SetText(text or "")
        label:SetWrap(true)
        label:SetAutoStretchVertical(true)
        return label
    end

    local function panelBrowserNotify(text, isError)
        if not IsValid(LocalPlayer()) then return end
        if isError then
            LocalPlayer():notifyError(text)
        else
            LocalPlayer():notifyInfo(text)
        end
    end

    local function panelBrowserTryRaw(name)
        if not rawPreviewPanels[name] then
            panelBrowserNotify(name .. " does not have a safe standalone preview.", true)
            return
        end

        local ok, result = pcall(function()
            local host = panelBrowserHost(name .. " Raw Preview", 760, 520)
            local child = host:Add(name)
            if not IsValid(child) then error("Failed to add child panel to preview host.") end
            child:Dock(FILL)
            child:DockMargin(8, 8, 8, 8)
            return host
        end)

        if not ok then
            panelBrowserNotify("Raw preview failed for " .. name .. ": " .. tostring(result), true)
            return
        end

        if not IsValid(result) then
            panelBrowserNotify("Raw preview returned an invalid panel for " .. name .. ".", true)
            return
        end

        panelBrowserNotify("Opened raw preview for " .. name .. ".")
    end

    local exampleBuilders = {}
    function exampleBuilders.liaFrame()
        local frame = panelBrowserHost("liaFrame Example", 500, 300)
        frame:Notify("Updated liaFrame preview.", 3)
    end

    function exampleBuilders.liaButton()
        local frame = panelBrowserHost("liaButton Example", 440, 220)
        local button = frame:Add("liaButton")
        button:Dock(TOP)
        button:DockMargin(16, 16, 16, 0)
        button:SetTall(48)
        button:SetText("Example Button")
        button.DoClick = function() frame:Notify("liaButton clicked.", 2) end
    end

    function exampleBuilders.liaScrollPanel()
        local frame = panelBrowserHost("liaScrollPanel Example", 500, 420)
        local scroll = frame:Add("liaScrollPanel")
        scroll:Dock(FILL)
        scroll:DockMargin(16, 16, 16, 16)
        for i = 1, 12 do
            local button = scroll:Add("liaButton")
            button:Dock(TOP)
            button:DockMargin(0, 0, 0, 8)
            button:SetTall(36)
            button:SetText("Scrollable Item " .. i)
        end
    end

    function exampleBuilders.liaHeaderPanel()
        local frame = panelBrowserHost("liaHeaderPanel Example", 520, 220)
        local header = frame:Add("liaHeaderPanel")
        header:Dock(TOP)
        header:DockMargin(16, 16, 16, 0)
        header:SetTall(38)
        header:SetLineColor(lia.color.theme.accent or lia.color.theme.theme or Color(45, 190, 170))
    end

    local function openPanelBrowser()
        if IsValid(lia.gui.panelBrowser) then lia.gui.panelBrowser:Remove() end
        local frame = panelBrowserHost("Lilia Panel Preview", 980, 620)
        lia.gui.panelBrowser = frame
        local left = frame:Add("EditablePanel")
        left:Dock(LEFT)
        left:SetWide(300)
        left:DockMargin(12, 12, 8, 12)
        left.Paint = function(_, w, h) draw.RoundedBox(8, 0, 0, w, h, Color(20, 26, 31, 230)) end
        local right = frame:Add("EditablePanel")
        right:Dock(FILL)
        right:DockMargin(8, 12, 12, 12)
        right.Paint = function(_, w, h) draw.RoundedBox(8, 0, 0, w, h, Color(20, 26, 31, 230)) end
        local search = left:Add("liaEntry")
        search:Dock(TOP)
        search:DockMargin(12, 12, 12, 10)
        search:SetPlaceholderText("Search shared panels")
        local list = left:Add("liaScrollPanel")
        list:Dock(FILL)
        list:DockMargin(12, 0, 12, 12)
        local title = panelBrowserLabel(right, "Select a panel from the list.", "LiliaFont.24", 16)
        title:DockMargin(16, 16, 16, 8)
        local subtitle = panelBrowserLabel(right, "", "LiliaFont.17", 16)
        subtitle:DockMargin(16, 0, 16, 8)
        local note = panelBrowserLabel(right, "", "LiliaFont.18", 16)
        note:DockMargin(16, 0, 16, 12)
        local actions = right:Add("EditablePanel")
        actions:Dock(TOP)
        actions:DockMargin(16, 0, 16, 12)
        actions:SetTall(42)
        actions.Paint = nil
        local exampleButton = actions:Add("liaButton")
        exampleButton:Dock(LEFT)
        exampleButton:SetWide(180)
        exampleButton:SetText("Open Example")
        local rawButton = actions:Add("liaButton")
        rawButton:Dock(LEFT)
        rawButton:DockMargin(8, 0, 0, 0)
        rawButton:SetWide(180)
        rawButton:SetText("Try Raw Preview")
        local detailScroll = right:Add("liaScrollPanel")
        detailScroll:Dock(FILL)
        detailScroll:DockMargin(16, 0, 16, 16)
        local detailInfo = detailScroll:Add("DLabel")
        detailInfo:Dock(TOP)
        detailInfo:SetTextColor(lia.color.theme.text or color_white)
        detailInfo:SetFont("LiliaFont.17")
        detailInfo:SetWrap(true)
        detailInfo:SetAutoStretchVertical(true)
        detailInfo:SetText("Choose a shared panel to preview.")
        local selectedPanel
        local function renderSelection(data)
            selectedPanel = data
            local control = vgui.GetControlTable(data.name)
            local base = control and (control.Base or control.base or control.BaseClass and control.BaseClass.ClassName) or "unknown"
            local hasExample = exampleBuilders[data.name] ~= nil
            local hasRawPreview = rawPreviewPanels[data.name] == true
            title:SetText(data.name)
            subtitle:SetText("Base: " .. tostring(base) .. " | Example: " .. (hasExample and "yes" or "no") .. " | Raw preview: " .. (hasRawPreview and "yes" or "no"))
            note:SetText(data.note or "No note provided.")
            detailInfo:SetText("Open Example shows a curated preview, while Try Raw Preview embeds the real shared panel directly inside a host frame.")
            exampleButton:SetDisabled(not hasExample)
            rawButton:SetDisabled(not hasRawPreview)
        end

        exampleButton.DoClick = function()
            if not selectedPanel then return end
            local builder = exampleBuilders[selectedPanel.name]
            if not builder then
                panelBrowserNotify("No curated example is available for " .. selectedPanel.name .. ".", true)
                return
            end

            builder()
        end

        rawButton.DoClick = function()
            if not selectedPanel then return end
            panelBrowserTryRaw(selectedPanel.name)
        end

        local function refreshList(filterText)
            list:Clear()
            local filter = string.Trim(string.lower(filterText or ""))
            for _, data in ipairs(panelBrowserCatalog) do
                if filter ~= "" and not string.find(string.lower(data.name), filter, 1, true) then continue end
                local row = list:Add("liaButton")
                row:Dock(TOP)
                row:DockMargin(0, 0, 0, 8)
                row:SetTall(40)
                row:SetText(data.name)
                row.DoClick = function() renderSelection(data) end
            end
        end

        search.OnTextChanged = function(_, value) refreshList(value) end
        refreshList("")
        if panelBrowserCatalog[1] then renderSelection(panelBrowserCatalog[1]) end
    end

    net.Receive("liaOpenPanelBrowser", openPanelBrowser)
end

lia.command.add("panelbrowser", {
    superAdminOnly = true,
    alias = "preview",
    desc = "Open a browser for previewing shared Lilia panels.",
    onRun = function(client)
        if not IsValid(client) then return end
        net.Start("liaOpenPanelBrowser")
        net.Send(client)
    end
})

lia.command.add("viewwarns", {
    adminOnly = true,
    desc = "@viewWarnsDesc",
    arguments = {
        {
            name = "target",
            type = "string"
        },
    },
    AdminStick = {
        Name = "@viewPlayerWarnings",
        ButtonText = "View Warnings",
        Category = "Warnings",
    },
    onRun = function(client, arguments)
        local targetName = arguments[1]
        if not targetName then
            client:notifyErrorLocalized("targetNotFound")
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
                client:notifyInfoLocalized("noWarnings", displayName)
                return
            end

            local warningList = {}
            for index, warn in ipairs(warns) do
                table.insert(warningList, {
                    index = index,
                    timestamp = warn.timestamp or L("na"),
                    admin = string.format("%s (%s)", warn.warner or L("na"), warn.warnerSteamID or L("na")),
                    warningMessage = warn.message or L("na"),
                    severity = warn.severity or "Medium"
                })
            end

            lia.util.sendTableUI(client, L("playerWarningsTitle", displayName), {
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
                },
                {
                    name = L("warningSeverity"),
                    field = "severity"
                }
            }, warningList, {
                {
                    name = L("removeThing", L("warning")),
                    net = "liaRequestRemoveWarning"
                }
            }, target:getChar():getID())

            lia.log.add(client, "viewWarns", target)
        end)
    end
})

local function GetWarningsByIssuer(steamID)
    local condition = "warnerSteamID = " .. lia.db.convertDataType(steamID)
    return lia.db.select({"id", "timestamp", "message", "warned", "warnedSteamID", "warner", "warnerSteamID", "severity"}, "warnings", condition):next(function(res) return res.results or {} end)
end

lia.command.add("viewwarnsissued", {
    adminOnly = true,
    desc = "@viewWarnsIssuedDesc",
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

        GetWarningsByIssuer(steamID):next(function(warns)
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
                    warningMessage = warn.message or L("na"),
                    severity = warn.severity or "Medium"
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
                },
                {
                    name = L("warningSeverity"),
                    field = "severity"
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
    desc = "@recogWhisperDesc",
    AdminStick = {
        Name = "@adminStickForceRecognitionWhisperName",
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
            name = "name",
            type = "player"
        },
    },
    desc = "@recogNormalDesc",
    AdminStick = {
        Name = "@adminStickForceRecognitionNormalName",
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
            name = "name",
            type = "player"
        },
    },
    desc = "@recogYellDesc",
    AdminStick = {
        Name = "@adminStickForceRecognitionYellName",
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
    desc = "@recogBotsDesc",
    onRun = function(_, arguments)
        local range = arguments[1] or "normal"
        local fakeName = arguments[2]
        for _, ply in player.Iterator() do
            if ply:IsBot() then hook.Run("ForceRecognizeRange", ply, range, fakeName) end
        end
    end
})

lia.command.add("kickbots", {
    privilege = "@manageBots",
    desc = "@kickAllBotsDesc",
    onRun = function(client)
        if timer.Exists("Bots_Add_Timer") then timer.Remove("Bots_Add_Timer") end
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
    desc = "@npcchangetypeDesc",
    AdminStick = {
        Name = "@npcChangeTypeTitle",
        ButtonText = "Change NPC Type",
        Category = "NPCs",
        TargetClass = "lia_npc",
    },
    onRun = function(client)
        local permission = client:hasPrivilege("Can Manage NPCs")
        lia.debug("[Permissions]", "Permission Check for command npcchangetype", "hasPrivilege(Can Manage NPCs)=", tostring(permission), "finalResult=", tostring(permission))
        if not permission then return client:notifyErrorLocalized("noManageNPCPermission") end
        local ent = client:getTracedEntity()
        if not ent or not IsValid(ent) then return client:notifyErrorLocalized("mustLookAtValidEntity") end
        if not lia.dialog.isDialogNPCEntity(ent) then return client:notifyErrorLocalized("mustLookAtDialogNPC") end
        lia.dialog.syncToClients(client)
        timer.Simple(0.1, function()
            if not IsValid(client) or not IsValid(ent) then return end
            local npcOptions = lia.dialog.getCompatibleDialogOptions(ent)
            local displayToUniqueID = {}
            for _, option in ipairs(npcOptions) do
                displayToUniqueID[option[1]] = option[2]
            end

            if not table.IsEmpty(npcOptions) then
                client.npcDisplayToUniqueID = displayToUniqueID
                client.npcEntity = ent
                client:requestDropdown("@npcChangeTypeTitle", "@npcChangeTypePrompt", npcOptions, function(selectedDisplayName, selectedUniqueID)
                    if selectedDisplayName and selectedDisplayName ~= "" then
                        local uniqueID = selectedUniqueID or (client.npcDisplayToUniqueID and client.npcDisplayToUniqueID[selectedDisplayName])
                        if uniqueID and IsValid(client.npcEntity) then
                            local npc = client.npcEntity
                            local npcType = uniqueID
                            if lia.dialog.isGeneratedDialogSelection and lia.dialog.isGeneratedDialogSelection(npcType) then npcType = lia.dialog.ensureGeneratedDialogType and select(1, lia.dialog.ensureGeneratedDialogType(npc, nil, npc.NPCName)) or nil end
                            if not IsValid(npc) or not npcType then return end
                            local existingCustomData = npc.customData
                            npc.uniqueID = npcType
                            local npcData = lia.dialog.getNPCData(npcType)
                            if npcData then
                                local currentPos = npc:GetPos()
                                local currentAng = npc:GetAngles()
                                npc:SetModel("models/Barney.mdl")
                                if npcData.BodyGroups and istable(npcData.BodyGroups) then lia.util.applyBodygroups(npc, npcData.BodyGroups) end
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
                                    if existingCustomData.bodygroups and istable(existingCustomData.bodygroups) then lia.util.applyBodygroups(npc, existingCustomData.bodygroups) end
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
                                client:notifyInfoLocalized("npcTypeChanged", npcData.PrintName or npcType)
                            end
                        end
                    end
                end)
            else
                client:notifyErrorLocalized("noNPCTypesAvailable")
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
    desc = "@plyRespawnDesc",
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
    desc = "@forceRespawnDesc",
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
    desc = "@resetvendorcooldownsDesc",
    privilege = "@canEditVendors",
    adminOnly = true,
    arguments = {
        {
            name = "target",
            type = "player",
            description = "@resetVendorCooldownsTargetDesc"
        }
    },
    AdminStick = {
        Name = "@adminStickResetVendorCooldownsName",
        ButtonText = "Reset Vendor Cooldowns",
        Category = "Vendors",
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
    desc = "@storagePasswordRemoveDesc",
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
    desc = "@storagePasswordChangeDesc",
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
    desc = "@listNearbyEntitiesDesc",
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
                model = ent:GetModel() or L("na"),
                pos = ent:GetPos(),
                distance = pos:Distance(ent:GetPos()),
                health = ent.Health and ent:Health() or L("na"),
                name = ent.GetName and ent:GetName() or L("na")
            })
        end

        client:ChatPrint(L("entitiesWithinRadiusHeader", radius))
        for categoryName, entitiesInCategory in pairs(entityCategories) do
            if #entitiesInCategory > 0 then
                local displayCategoryName = lia.lang.resolveToken("@" .. categoryName):upper()
                client:ChatPrint(L("entityCategoryHeader", displayCategoryName, #entitiesInCategory))
                table.sort(entitiesInCategory, function(a, b) return a.distance < b.distance end)
                for _, entData in ipairs(entitiesInCategory) do
                    local info = L("entityDistanceClassInfo", string.format("%.1f", entData.distance), entData.class)
                    if entData.name ~= L("na") and entData.name ~= "" then info = info .. " (" .. entData.name .. ")" end
                    if entData.health ~= L("na") then info = info .. " [" .. L("entityHealthLabel", entData.health) .. "]" end
                    client:ChatPrint(info)
                end

                client:ChatPrint("")
            end
        end

        local totalEntities = 0
        for _, entitiesInCategory in pairs(entityCategories) do
            totalEntities = totalEntities + #entitiesInCategory
        end

        client:ChatPrint(L("totalEntitiesFound", totalEntities))
        client:notifyLocalized("listedEntitiesWithinRadius", totalEntities, radius)
    end
})

concommand.Add("lia_setextrachars", function(client, _, args)
    if IsValid(client) then
        client:notifyErrorLocalized("commandConsoleOnly")
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
        lia.log.add(nil, "addExtraChars", steamid, amount, newExtra)
    end)
end)

lia.command.add("viewBodygroups", {
    adminOnly = true,
    arguments = {
        {
            name = "target",
            type = "player"
        }
    },
    desc = "@viewBodygroupsDesc",
    AdminStick = {
        Name = "@viewBodygroupsDesc",
        ButtonText = "View Bodygroups",
        Category = "Character Info",
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1] or "")
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        net.Start("BodygrouperMenu")
        net.WriteEntity(target)
        net.Send(client)
    end
})

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
            MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), L("noCharactersFoundForSteamID", steamID) .. "\n")
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
                        ClientAddTextShadowed(ply, Color(255, 0, 0), "INVENTORY", Color(255, 255, 255), " " .. L("inventorySizeChangedSwapCharacters", width, height))
                        hasNotifiedPlayer = true
                    end

                    if not hasNotifiedStaff then
                        local staffMessage = L("staffLogInventorySizeSet", width, height, ply:Name(), ply:SteamID64())
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
            lia.log.add(nil, "setInventorySizeAllChars", steamID, width, height, successCount)
        end)
    end):catch(function(err) MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), "Database error: " .. tostring(err) .. "\n") end)
end)

concommand.Add("lia_give_money_steamid", function(client, _, args)
    if IsValid(client) then
        client:notifyErrorLocalized("commandConsoleOnly")
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
                MsgC(Color(0, 255, 0), "[Lilia] ", Color(255, 255, 255), L("gaveMoneyToCharacterOnline", lia.currency.get(amount), charName, charID, lia.currency.get(actualNewMoney)) .. "\n")
                if updatedCount == #characters then
                    MsgC(Color(0, 255, 0), "[Lilia] ", Color(255, 255, 255), L("successfullyGaveMoneyToCharacters", lia.currency.get(amount), #characters, steamID) .. "\n")
                    lia.log.add(nil, "giveMoneySteamID", steamID, amount, #characters)
                end
            else
                if lia.char.setCharDatabase(charID, "money", newMoney) then
                    updatedCount = updatedCount + 1
                    MsgC(Color(0, 255, 0), "[Lilia] ", Color(255, 255, 255), L("gaveMoneyToCharacterOffline", lia.currency.get(amount), charName, charID, lia.currency.get(newMoney)) .. "\n")
                    if updatedCount == #characters then
                        MsgC(Color(0, 255, 0), "[Lilia] ", Color(255, 255, 255), L("successfullyGaveMoneyToCharacters", lia.currency.get(amount), #characters, steamID) .. "\n")
                        lia.log.add(nil, "giveMoneySteamID", steamID, amount, #characters)
                    end
                else
                    MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), L("errorUpdatingMoneyForCharacter", charName, charID) .. "\n")
                end
            end
        end
    end):catch(function(err) MsgC(Color(255, 0, 0), "[Lilia] ", Color(255, 255, 255), L("databaseErrorValue", tostring(err)) .. "\n") end)
end)
