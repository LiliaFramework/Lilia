--------------------------------------------------------------------------------------------------------
local vjThink = 0
--------------------------------------------------------------------------------------------------------
lia.config.VJConvars = {
    ["vj_npc_corpsefade"] = 1,
    ["vj_npc_corpsefadetime"] = 5,
    ["vj_npc_nogib"] = 1,
    ["vj_npc_nosnpcchat"] = 1,
    ["vj_npc_slowplayer"] = 1,
    ["vj_npc_noproppush"] = 1,
    ["vj_npc_nothrowgrenade"] = 1,
    ["vj_npc_fadegibstime"] = 5,
    ["vj_npc_knowenemylocation"] = 1,
    ["vj_npc_dropweapon"] = 0,
    ["vj_npc_plypickupdropwep"] = 0,
}

--------------------------------------------------------------------------------------------------------
if VJ then
    function setupVJ()
        for k, v in pairs(lia.config.VJConvars) do
            RunConsoleCommand(k, tostring(v))
        end
    end

    function optimizeVJ()
        RunConsoleCommand("vj_npc_processtime", 1)
    end

    hook.Add(
        "Think",
        "OptimizerVJThink",
        function()
            if vjThink <= CurTime() then
                setupVJ()
                optimizeVJ()
                vjThink = CurTime() + 180
            end
        end
    )
end
--------------------------------------------------------------------------------------------------------