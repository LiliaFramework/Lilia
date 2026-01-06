--[[
    Folder: Compatibility
    File:  advdupe.md
]]
--[[
    Advanced Duplicator Compatibility

    Provides compatibility and security measures for the Advanced Duplicator addon within the Lilia framework.
]]
--[[
    Improvements Done:
        The Advanced Duplicator compatibility module ensures safe and controlled usage of the Advanced Duplicator addon. It implements security measures to prevent crash exploits and unauthorized duplication.
        The module operates on the server side to validate duplication attempts, checking for oversized models and entities marked as non-duplicable.
        It includes logging functionality to track potential security violations and crash attempts.
        The module integrates with the notification system to inform players of duplication restrictions and security measures.
]]
local function CheckDuplicationScale(client, entities)
    entities = entities or {}
    for _, ent in pairs(entities) do
        if ent.ModelScale and ent.ModelScale > 10 then
            client:notifyErrorLocalized("duplicationSizeLimit")
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
            client:notifyErrorLocalized("cannotDuplicateEntity", tool)
            return false
        end
    end

    if not CheckDuplicationScale(client, toolobj.Entities) then return false end
end)

lia.log.addType("dupeCrashAttempt", function(client) return L("dupeCrashAttemptLog", IsValid(client) and client:Name() or L("unknown"), IsValid(client) and client:SteamID() or L("na")) end, L("categorySecurity"))
