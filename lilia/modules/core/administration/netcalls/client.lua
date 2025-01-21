netstream.Hook("cfgList", function(data)
    for k, v in pairs(data) do
        if lia.config.stored[k] then lia.config.stored[k].value = v end
    end

    hook.Run("InitializedConfig", data)
end)

netstream.Hook("cfgSet", function(key, value)
    local config = lia.config.stored[key]
    if config then
        if config.callback then config.callback(config.value, value) end
        config.value = value
        local properties = lia.gui.properties
        if IsValid(properties) then
            local row = properties:GetCategory(L(config.data and config.data.category or "misc")):GetRow(key)
            if IsValid(row) then
                if istable(value) and value.r and value.g and value.b then value = Vector(value.r / 255, value.g / 255, value.b / 255) end
                row:SetValue(value)
            end
        end
    end
end)

net.Receive("AdminModeSwapCharacter", function()
    local id = net.ReadInt(32)
    assert(isnumber(id), "id must be a number")
    local d = deferred.new()
    net.Receive("liaCharChoose", function()
        local message = net.ReadString()
        if message == "" then
            d:resolve()
            hook.Run("CharLoaded", lia.char.loaded[id])
        else
            d:reject(message)
        end
    end)

    net.Start("liaCharChoose")
    net.WriteUInt(id, 32)
    net.SendToServer()
end)