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

hook.Add("CanTool", "liaAdvDupe2", function(client, _, tool) if tool == "advdupe2" and client.AdvDupe2 and not CheckDuplicationScale(client, client.AdvDupe2.Entities) then return false end end)