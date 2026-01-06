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
            client:notifyErrorLocalized("cannotDuplicateEntity", tool)
            return false
        end
    end

    if not CheckDuplicationScale(client, dupe.Entities) then return false end
end)

hook.Add("PreRegisterTOOL", "BetterDupeLoad", function(tool, class)
    if class ~= "duplicator" then return end
    function tool:LeftClick(trace)
        local ply = self:GetOwner()
        if CLIENT then return true end
        if not ply.CurrentDupe or not ply.CurrentDupe.Entities then return false end
        if ply.AdvDupe2.Pasting or ply.AdvDupe2.Downloading then
            AdvDupe2.Notify(ply, "Better Duplicator is busy.", NOTIFY_ERROR)
            return false
        end

        local dupe = ply.CurrentDupe
        local pos = trace.HitPos
        for _, v in pairs(dupe.Entities) do
            if v.LocalPos then v.LocalPos = nil end
        end

        pos.z = pos.z - dupe.Mins.z
        ply.tempBetterDupeAdvDupe2 = table.Copy(ply.AdvDupe2)
        ply.tempBetterDupe = true
        ply.AdvDupe2.Entities = dupe.Entities
        ply.AdvDupe2.Constraints = dupe.Constraints
        ply.AdvDupe2.Position = pos
        ply.AdvDupe2.Angle = self:GetOwner():EyeAngles()
        ply.AdvDupe2.Angle.pitch = 0
        ply.AdvDupe2.Angle.roll = 0
        ply.AdvDupe2.Pasting = true
        ply.AdvDupe2.Name = "Better dupe"
        ply.AdvDupe2.Revision = 5
        AdvDupe2.InitPastingQueue(ply, ply.AdvDupe2.Position, ply.AdvDupe2.Angle, nil, true, true, true, tobool(ply:GetInfo("advdupe2_paste_protectoveride")))
    end
end)

hook.Add("AdvDupe_FinishPasting", "Betterdupe_AdvDupe_FinishPasting", function(tbl)
    local ply = tbl[1].Player
    if not ply or not ply.tempBetterDupe then return end
    ply.AdvDupe2 = ply.tempBetterDupeAdvDupe2 or {}
    ply.AdvDupe2.Pasting = false
    ply.tempBetterDupeAdvDupe2 = nil
    ply.tempBetterDupe = nil
end)

lia.log.addType("dupeCrashAttempt", function(client) return L("dupeCrashAttemptLog", IsValid(client) and client:Name() or L("unknown"), IsValid(client) and client:SteamID() or L("na")) end, L("categorySecurity"))
