---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.command = lia.command or {}
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
lia.command.list = lia.command.list or {}
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function lia.command.add(command, data)
    data.syntax = data.syntax or "[none]"
    if not data.onRun then return ErrorNoHalt("Command '" .. command .. "' does not have a callback, not adding!\n") end
    if data.group then
        ErrorNoHalt("Command '" .. data.name .. "' tried to use the deprecated field 'group'!\n")
        return
    end

    local privilege = "Commands - " .. (isstring(data.privilege) and data.privilege or command)
    if not CAMI.GetPrivilege(privilege) then
        CAMI.RegisterPrivilege({
            Name = privilege,
            MinAccess = data.superAdminOnly and "superadmin" or (data.adminOnly and "admin" or "user"),
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

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function lia.command.hasAccess(client, command, data)
    if data == nil then data = lia.command.list[command] end
    local privilege = data.privilege
    if not privilege then privilege = command end
    local bHasAccess, _ = CAMI.PlayerHasAccess(client, "Commands - " .. privilege, nil)
    if hook.GetTable()["CanPlayerUseCommand"] then return hook.Run("CanPlayerUseCommand") end
    return bHasAccess
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
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
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
