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
function GM:ModuleShouldLoad(id)
    if lia.config.CustomMainMenu then
        if id == "charselect" then return false end
    end
end
--------------------------------------------------------------------------------------------------------