--[[
    VJ Base Compatibility

    Description:
        Prevents known exploit nets from executing and adjusts certain
        console commands to keep the base from affecting gameplay. This
        file also removes leftover hooks and spawners that VJ Base
        registers when it loads.
]]
-- List of VJ Base network messages that are often abused.
local exploitable_nets = {
    "VJSay",
    "vj_fireplace_turnon1",
    "vj_npcmover_sv_create",
    "vj_npcmover_sv_startmove",
    "vj_npcmover_removesingle",
    "vj_npcmover_removeall",
    "vj_npcspawner_sv_create",
    "vj_npcrelationship_sr_leftclick",
    "vj_testentity_runtextsd",
    "vj_fireplace_turnon2",
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

--[[
    optimizeVJ()

    Description:
        Sets the VJ Base NPC think rate based on the current number of
        players. Lower values help performance when the server is empty
        while keeping responsive AI during busier times.

    Parameters:
        None

    Realm:
        Server

    Returns:
        None
]]
function optimizeVJ()
    RunConsoleCommand("vj_npc_processtime", 1 + #player.GetAll() / 40)
end

timer.Create("vjbase_console_commands", 180, 0, function() optimizeVJ() end)
--[[
    OnEntityCreated entity

    Description:
        Removes VJ Base spawners as soon as they are created and ensures
        persistent entities do not attract NPCs.

    Parameters:
        entity (Entity) – The entity that was created.

    Realm:
        Server

    Returns:
        None
]]
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

--[[
    Cleanup VJ Base hooks

    Description:
        After initialization, remove unused VJ Base hooks and console
        commands so they cannot be triggered later.

    Parameters:
        None

    Realm:
        Server

    Returns:
        None
]]
timer.Simple(10, function()
    hook.Remove("PlayerInitialSpawn", "VJBaseSpawn")
    hook.Remove("PlayerInitialSpawn", "drvrejplayerInitialSpawn")
    concommand.Remove("vj_cleanup")
end)
