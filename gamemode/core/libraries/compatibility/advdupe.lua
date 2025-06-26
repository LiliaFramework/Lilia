local function CheckDuplicationScale(client, entities)
    entities = entities or {}
    for _, v in pairs(entities) do
        if v.ModelScale and v.ModelScale > 10 then
            client:notifyLocalized("duplicationSizeLimit")
            print("[Server Warning] Potential server crash using dupes attempt by player: " .. client:Name() .. " (" .. client:SteamID64() .. ")")
            return false
        end

        v.ModelScale = 1
    end
    return true
end

hook.Add("CanTool", "lia_CheckAdvDuplicatorScale", function(client, _, tool)
    if tool == "adv_duplicator" then
        local weapon = client:GetActiveWeapon()
        if IsValid(weapon) then
            local toolobj = weapon:GetToolObject()
            if toolobj and toolobj.Entities and not CheckDuplicationScale(client, toolobj.Entities) then return false end
        end
    end
end)