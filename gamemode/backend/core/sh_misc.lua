--------------------------------------------------------------------------------------------------------
function GM:GetGameDescription()
    if istable(SCHEMA) then return tostring(SCHEMA.name) end
    return lia.config.DefaultGamemodeName
end

--------------------------------------------------------------------------------------------------------
function GM:PlayerSpray(client)
    return true
end
--------------------------------------------------------------------------------------------------------