local function CheckDuplicationScale(client, entities)
    entities = entities or {}
    for _, ent in pairs(entities) do
        if ent.ModelScale and ent.ModelScale > 10 then
            client:notifyLocalized("duplicationSizeLimit")
            lia.log.add(client, "dupeCrashAttempt")
            return false
        end

        ent.ModelScale = 1
    end
    return true
end

hook.Add("PlayerSpawnProp", "liaAdvDupe2", function(client)
    local weapon = client:GetActiveWeapon()
    if IsValid(weapon) and weapon:GetClass() == "gmod_tool" then
        local toolobj = weapon:GetToolObject()
        if toolobj and (client.AdvDupe2 and client.AdvDupe2.Entities or client.CurrentDupe and client.CurrentDupe.Entities or toolobj.Entities) then return true end
    end
end)

hook.Add("CanTool", "liaAdvDupe2", function(client, _, tool)
    if tool ~= "advdupe2" then return end
    local dupe = client.AdvDupe2
    if not dupe then return end
    for _, ent in pairs(dupe.Entities or {}) do
        if ent.NoDuplicate then
            client:notifyLocalized("cannotDuplicateEntity", tool)
            return false
        end
    end

    if not CheckDuplicationScale(client, dupe.Entities) then return false end
end)

lia.log.addType("dupeCrashAttempt", function(client) return L("dupeCrashAttemptLog", IsValid(client) and client:Name() or L("unknown"), IsValid(client) and client:SteamID() or L("na")) end, L("categorySecurity"))