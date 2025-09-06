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

hook.Add("PlayerSpawnProp", "liaAdvDupe", function(client)
    local w = client:GetActiveWeapon()
    if IsValid(w) and w:GetClass() == "gmod_tool" then
        local t = w:GetToolObject()
        if t and t.Entities then return true end
    end
end)

hook.Add("CanTool", "liaAdvDupe", function(client, _, tool)
    if tool ~= "adv_duplicator" then return end
    local weapon = client:GetActiveWeapon()
    if not IsValid(weapon) then return end
    local toolobj = weapon:GetToolObject()
    if not toolobj or not toolobj.Entities then return end
    for _, ent in pairs(toolobj.Entities) do
        if ent.NoDuplicate then
            client:notifyLocalized("cannotDuplicateEntity", tool)
            return false
        end
    end

    if not CheckDuplicationScale(client, toolobj.Entities) then return false end
end)

lia.log.addType("dupeCrashAttempt", function(client) return L("dupeCrashAttemptLog", IsValid(client) and client:Name() or L("unknown"), IsValid(client) and client:SteamID() or L("na")) end, L("categorySecurity"))