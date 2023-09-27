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
function GM:SecToTime(t)
    if t < 0 then
        return "?"
    elseif t < 60 then
        return math.floor(t) .. " seconds"
    elseif t < 3600 then
        return math.floor(t / 60) .. " minutes " .. math.floor(t) % 60 .. " seconds"
    elseif t < 24 * 3600 then
        return math.floor(t / 3600) .. " hours " .. math.floor(t / 60) % 60 .. " minutes " .. math.floor(t) % 60 .. " seconds"
    elseif t < 7 * 24 * 3600 then
        return math.floor(t / 3600 / 24) .. " days " .. math.floor(t / 3600) % 24 .. " hours " .. math.floor(t / 60) % 60 .. " minutes "
    else
        return math.floor(t / 3600 / 24 / 7) .. " weeks " .. math.floor(t / 3600 / 24) % 7 .. " days " .. math.floor(t / 3600) % 24 .. " hours"
    end
end
--------------------------------------------------------------------------------------------------------