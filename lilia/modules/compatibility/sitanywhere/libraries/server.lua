---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function SittingCompatibility:InitializedModules()
    RunConsoleCommand("sitting_can_sit_on_players", "1")
    RunConsoleCommand("sitting_can_sit_on_player_ent", "1")
    RunConsoleCommand("sitting_can_damage_players_sitting", "1")
    RunConsoleCommand("sitting_allow_weapons_in_seat", "0")
    RunConsoleCommand("sitting_admin_only", "0")
    RunConsoleCommand("sitting_anti_prop_surf", "1")
    RunConsoleCommand("sitting_anti_tool_abuse", "1")
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function SittingCompatibility:CheckValidSit(client, _)
    local entity = client:GetTracedEntity()
    if entity:IsVehicle() or entity:IsPlayer() then return false end
end
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
