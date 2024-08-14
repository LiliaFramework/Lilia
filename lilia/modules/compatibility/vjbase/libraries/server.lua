local vjThink = 0
function MODULE:Think()
    if vjThink <= CurTime() then
        for k, v in pairs(self.VJBaseConsoleCommands) do
            RunConsoleCommand(k, v)
        end

        vjThink = CurTime() + 180
    end
end

function MODULE:OnEntityCreated(entity)
    if entity:GetClass() == "obj_vj_spawner_base" then entity:Remove() end
end

timer.Simple(10, function()
    hook.Remove("PlayerInitialSpawn", "VJBaseSpawn")
    hook.Remove("PlayerInitialSpawn", "drvrejplayerInitialSpawn")
    concommand.Remove("vj_cleanup")
end)

lia.log.addType("unprotectedVJNetCall", function(client) return string.format("%s is trying to abuse unprotected VJ net calls.", client:Name()) end, "Exploits", Color(255, 0, 0), "Exploits")
