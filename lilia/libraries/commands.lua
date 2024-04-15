lia.command = lia.command or {}
lia.command.list = lia.command.list or {}
function lia.command.add(command, data)
    data.syntax = data.syntax or "[none]"
    local superAdminOnly = data.superAdminOnly
    local adminOnly = data.adminOnly
    local acessLevels = superAdminOnly and "superadmin" or (adminOnly and "admin" or "user")
    local userCommand = acessLevels == "user"
    if not data.onRun then return ErrorNoHalt("Command '" .. command .. "' does not have a callback, not adding!\n") end
    if data.group then
        ErrorNoHalt("Command '" .. data.name .. "' tried to use the deprecated field 'group'!\n")
        return
    end

    local privilege = "Commands - " .. (isstring(data.privilege) and data.privilege or (userCommand and "Default User Commands" or command))
    if not CAMI.GetPrivilege(privilege) then
        CAMI.RegisterPrivilege({
            Name = privilege,
            MinAccess = superAdminOnly and "superadmin" or (adminOnly and "admin" or "user"),
            Description = data.description
        })
    end

    local onRun = data.onRun
    data._onRun = data.onRun
    data.onRun = function(client, arguments)
        if lia.command.hasAccess(client, command, data) then
            return onRun(client, arguments)
        else
            return "@noPerm"
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
    if data == nil then data = lia.command.list[command] end
    local privilege = data.privilege
    if not privilege then privilege = command end
    local bHasAccess, _ = CAMI.PlayerHasAccess(client, "Commands - " .. privilege, nil)
    if hook.GetTable()["CanPlayerUseCommand"] then return hook.Run("CanPlayerUseCommand") end
    return bHasAccess
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

if SERVER then
    function lia.command.findPlayer(client, name)
        if isstring(name) then
            if name == "^" then
                return client
            elseif name == "@" then
                local trace = client:GetEyeTrace().Entity
                if IsValid(trace) and trace:IsPlayer() then
                    return trace
                else
                    client:notifyLocalized("lookToUseAt")
                    return
                end
            end

            local target = lia.util.findPlayer(name) or NULL
            if IsValid(target) then
                return target
            else
                client:notifyLocalized("plyNoExist")
            end
        else
            client:notifyLocalized("mustProvideString")
        end
    end

    function lia.command.findFaction(client, name)
        if lia.faction.teams[name] then return lia.faction.teams[name] end
        for _, v in ipairs(lia.faction.indices) do
            if lia.util.stringMatches(L(v.name, client), name) then return v end
        end

        client:notifyLocalized("invalidFaction")
    end

    function lia.command.findPlayerSilent(client, name)
        local target = type(name) == "string" and lia.util.findPlayer(name) or NULL
        if type(name) == "string" and name == "@" then
            local lookingAt = client:GetEyeTrace().Entity
            if IsValid(lookingAt) and lookingAt:IsPlayer() then target = lookingAt end
        end

        if IsValid(target) then return target end
    end

    function lia.command.findFaction(client, name)
        if lia.faction.teams[name] then return lia.faction.teams[name] end
        for _, v in ipairs(lia.faction.indices) do
            if lia.util.stringMatches(L(v.name, client), name) then return v end
        end

        client:notifyLocalized("invalidFaction")
    end

    function lia.command.run(client, command, arguments)
        command = lia.command.list[command:lower()]
        if command then
            local results = {command.onRun(client, arguments or {})}
            local result = results[1]
            if isstring(result) then
                if IsValid(client) then
                    if result:sub(1, 1) == "@" then
                        client:notifyLocalized(result:sub(2), unpack(results, 2))
                    else
                        client:notify(result)
                    end

                    lia.log.add(client, "command", command, table.concat(arguments, ", "))
                else
                    print(result)
                end
            end
        end
    end

    function lia.command.parse(client, text, realCommand, arguments)
        if realCommand or text:utf8sub(1, 1) == "/" then
            local match = realCommand or text:lower():match("/" .. "([_%w]+)")
            if not match then
                local post = string.Explode(" ", text)
                local len = string.len(post[1])
                match = post[1]:utf8sub(2, len)
            end

            match = match:lower()
            local command = lia.command.list[match]
            if command then
                if not arguments then arguments = lia.command.extractArgs(text:sub(#match + 3)) end
                lia.command.run(client, match, arguments)
                if not realCommand then lia.log.add(client, "command", text) end
            else
                if IsValid(client) then
                    client:notifyLocalized("cmdNoExist")
                else
                    print("Sorry, that command does not exist.")
                end
            end
            return true
        end
        return false
    end
else
    function lia.command.send(command, ...)
        netstream.Start("cmd", command, {...})
    end
end