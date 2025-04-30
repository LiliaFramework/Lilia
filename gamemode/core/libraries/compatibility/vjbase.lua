local exploitable_nets = {"VJSay", "vj_fireplace_turnon1", "vj_npcmover_sv_create", "vj_npcmover_sv_startmove", "vj_npcmover_removesingle", "vj_npcmover_removeall", "vj_npcspawner_sv_create", "vj_npcrelationship_sr_leftclick", "vj_testentity_runtextsd", "vj_fireplace_turnon2"}
local console_settings = {
    vj_npc_processtime = "1",
    vj_npc_corpsefade = "1",
    vj_npc_corpsefadetime = "5",
    vj_npc_nogib = "1",
    vj_npc_nosnpcchat = "1",
    vj_npc_slowplayer = "1",
    vj_npc_noproppush = "1",
    vj_npc_nothrowgrenade = "1",
    vj_npc_fadegibstime = "5",
    vj_npc_knowenemylocation = "1",
    vj_npc_dropweapon = "0",
    vj_npc_plypickupdropwep = "0"
}

local function handle_exploitable_net(client, name)
    if not IsValid(client) or not client:IsPlayer() then return end
    client:ChatPrint(L("unauthorizedNetMessage", name))
    lia.log.add(client, "unprotectedVJNetCall", {
        netMessage = name
    })
end

for _, name in ipairs(exploitable_nets) do
    net.Receive(name, function(_, client) handle_exploitable_net(client, name) end)
end

timer.Create("vjbase_console_commands", 180, 0, function()
    for cmd, val in pairs(console_settings) do
        RunConsoleCommand(cmd, val)
    end
end)

hook.Add("OnEntityCreated", "vjbase_entity_handler", function(ent)
    timer.Simple(0, function()
        if not IsValid(ent) then return end
        if ent:GetClass() == "obj_vj_spawner_base" then
            SafeRemoveEntity(ent)
        elseif ent:isLiliaPersistent() or ent.noTarget then
            ent:AddFlags(FL_NOTARGET)
        end
    end)
end)

timer.Simple(10, function()
    hook.Remove("PlayerInitialSpawn", "VJBaseSpawn")
    hook.Remove("PlayerInitialSpawn", "drvrejplayerInitialSpawn")
    concommand.Remove("vj_cleanup")
end)