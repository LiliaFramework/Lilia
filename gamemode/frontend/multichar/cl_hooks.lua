--------------------------------------------------------------------------------------------------------
hook.Add("ChooseCharacter", "MultiCharChooseCharacter", function(id)
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
end)
--------------------------------------------------------------------------------------------------------
hook.Add("CreateCharacter", "MultiCharCreateCharacter", function(data)
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
end)
--------------------------------------------------------------------------------------------------------
hook.Add("DeleteCharacter", "MultiCharDeleteCharacter", function(id)
    assert(isnumber(id), "id must be a number")
    net.Start("liaCharDelete")
    net.WriteUInt(id, 32)
    net.SendToServer()
end)
--------------------------------------------------------------------------------------------------------
hook.Add("LiliaLoaded", "MyModule_LiliaLoaded", function()
    vgui.Create("liaCharacter")
end)
--------------------------------------------------------------------------------------------------------
hook.Add("KickedFromCharacter", "MyModule_KickedFromCharacter", function(id, isCurrentChar)
    if isCurrentChar then
        vgui.Create("liaCharacter")
    end
end)
--------------------------------------------------------------------------------------------------------
hook.Add("CreateMenuButtons", "MyModule_CreateMenuButtons", function(tabs)
    tabs["characters"] = function(panel)
        if IsValid(lia.gui.menu) then
            lia.gui.menu:Remove()
        end

        vgui.Create("liaCharacter")
    end
end)
--------------------------------------------------------------------------------------------------------