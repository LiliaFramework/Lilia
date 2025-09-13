local commands = {{"sitting_can_sit_on_players", "1"}, {"sitting_can_sit_on_player_ent", "1"}, {"sitting_can_damage_players_sitting", "1"}, {"sitting_allow_weapons_in_seat", "0"}, {"sitting_admin_only", "0"}, {"sitting_anti_prop_surf", "1"}, {"sitting_anti_tool_abuse", "1"}}
hook.Add("InitializedModules", "liaSitAnyWhere", function()
    for _, cmd in ipairs(commands) do
        RunConsoleCommand(cmd[1], cmd[2])
    end
end)

hook.Add("CheckValidSit", "liaSitAnyWhere", function(client)
    local entity = client:getTracedEntity()
    if entity:IsVehicle() or entity:IsPlayer() then return false end
end)