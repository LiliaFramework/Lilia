plogs.Register("Maestro", false)

local function concat(t)
    local s = ""
    for k, v in pairs(t) do
        if not istable(v) then
            s = s .. tostring(v)
        else
            s = s .. concat(v)
        end
    end
end

plogs.AddHook("maestro_command", function(client, cmd, arguments)
    if client:IsPlayer() then
        plogs.PlayerLog(client, "Maestro", client:NameID() .. " has ran command '" .. cmd .. "' with arguments '" .. concat(arguments, " ") .. "'", {
            ["Name"] = client:Name(),
            ["SteamID"] = client:SteamID(),
        })
    end
end)