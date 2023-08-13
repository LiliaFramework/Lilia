--------------------------------------------------------------------------------------------------------
local SCHEMA = SCHEMA

--------------------------------------------------------------------------------------------------------
function GM:GetGameDescription()
    if istable(SCHEMA) then return tostring(SCHEMA.name) end

    return lia.config.DefaultGamemodeName
end

--------------------------------------------------------------------------------------------------------
function GM:PlayerSpray(client)
    return not lia.config.PlayerSprayEnabled
end

--------------------------------------------------------------------------------------------------------
function GM:ChooseCharacter(id)
    assert(isnumber(id), "id must be a number")
    local d = deferred.new()

    net.Receive("liaCharChoose", function()
        local message = net.ReadString()

        if message == "" then
            d:resolve()
            hook.Run("CharacterLoaded", lia.char.loaded[id])
        else
            d:reject(message)
        end
    end)

    net.Start("liaCharChoose")
    net.WriteUInt(id, 32)
    net.SendToServer()

    return d
end

function GM:CreateCharacter(data)
    assert(istable(data), "data must be a table")
    local d = deferred.new()
    local payload = {}

    for key, charVar in pairs(lia.char.vars) do
        if charVar.noDisplay then continue end
        local value = data[key]

        if isfunction(charVar.onValidate) then
            local results = {charVar.onValidate(value, data, LocalPlayer())}

            if results[1] == false then return d:reject(L(unpack(results, 2))) end
        end

        payload[key] = value
    end

    -- Resolve promise after character is created.
    net.Receive("liaCharCreate", function()
        local id = net.ReadUInt(32)
        local reason = net.ReadString()

        if id > 0 then
            d:resolve(id)
        else
            d:reject(reason)
        end
    end)

    net.Start("liaCharCreate")
    net.WriteUInt(table.Count(payload), 32)

    for key, value in pairs(payload) do
        net.WriteString(key)
        net.WriteType(value)
    end

    net.SendToServer()

    return d
end

function GM:DeleteCharacter(id)
    assert(isnumber(id), "id must be a number")
    net.Start("liaCharDelete")
    net.WriteUInt(id, 32)
    net.SendToServer()
end