local exploitable_nets = {"VJSay", "vj_fireplace_turnon1", "vj_npcmover_sv_create", "vj_npcmover_sv_startmove", "vj_npcmover_removesingle", "vj_npcmover_removeall", "vj_npcspawner_sv_create", "vj_npcrelationship_sr_leftclick", "vj_testentity_runtextsd", "vj_fireplace_turnon2"}
local function handle_exploitable_net(client, name)
    if not IsValid(client) or not client:IsPlayer() then return end
    client:notifyErrorLocalized("unauthorizedNetMessage", name)
    lia.log.add(client, "unprotectedVJNetCall", {
        netMessage = name
    })
end

for _, name in ipairs(exploitable_nets) do
    net.Receive(name, function(_, client) handle_exploitable_net(client, name) end)
end

timer.Create("vjbase_console_commands", 180, 0, function() RunConsoleCommand("vj_npc_processtime", 1 + player.GetCount() / 40) end)
hook.Add("OnEntityCreated", "liaVJBase", function(ent)
    timer.Simple(0, function()
        if not IsValid(ent) then return end
        if ent:GetClass() == "obj_vj_spawner_base" then
            SafeRemoveEntity(ent)
        elseif ent.IsPersistent or ent.noTarget then
            ent:AddFlags(FL_NOTARGET)
        end
    end)
end)

timer.Simple(10, function()
    hook.Remove("PlayerInitialSpawn", "VJBaseSpawn")
    hook.Remove("PlayerInitialSpawn", "drvrejplayerInitialSpawn")
    concommand.Remove("vj_cleanup")
end)

lia.administrator.registerPrivilege({
    Name = "vjNpcProperties",
    ID = "property_vj_npc_properties",
    MinAccess = "superadmin",
    Category = "compatibility"
})

lia.log.addType("unprotectedVJNetCall", function(client, netMessage) return L("unprotectedVJNetCallLog", client:Name(), netMessage) end, L("categoryVJBase"))
