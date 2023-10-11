--------------------------------------------------------------------------------------------------------
lia.command = lia.command or {}
lia.command.list = lia.command.list or {}
--------------------------------------------------------------------------------------------------------
function lia.command.add(command, data)
    data.syntax = data.syntax or "[none]"
    if not data.onRun then return ErrorNoHalt("Command '" .. command .. "' does not have a callback, not adding!\n") end
    if not data.onCheckAccess then
        if data.group then
            ErrorNoHalt("Command '" .. data.name .. "' tried to use the deprecated field 'group'!\n")

            return
        end

        local privilege = "Lilia - Commands - " .. (isstring(data.privilege) and data.privilege or command)
        if not CAMI.GetPrivilege(privilege) then
            CAMI.RegisterPrivilege(
                {
                    Name = privilege,
                    MinAccess = data.superAdminOnly and "superadmin" or (data.adminOnly and "admin" or "user"),
                    Description = data.description
                }
            )
        end

        function data:onCheckAccess(client)
            local bHasAccess, _ = CAMI.PlayerHasAccess(client, privilege, nil)

            return bHasAccess
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

--------------------------------------------------------------------------------------------------------
function lia.command.hasAccess(client, command)
    command = lia.command.list[command:lower()]
    if command then
        if command.onCheckAccess then
            return command.onCheckAccess(client)
        else
            return true
        end
    end

    return hook.Run("CanPlayerUseCommand", client, command) or false
end

--------------------------------------------------------------------------------------------------------
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

    if curString ~= "" then
        arguments[#arguments + 1] = curString
    end

    return arguments
end
--------------------------------------------------------------------------------------------------------
function lia.command.send(command, ...)
    netstream.Start("cmd", command, {...})
end
--------------------------------------------------------------------------------------------------------