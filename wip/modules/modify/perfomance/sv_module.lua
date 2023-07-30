------------------------------------------------------------------------------------------------------------------------s
-- Betters Ragdoll Rendeering
function MODULE:InitializedModules()
    timer.Simple(3, function()
        RunConsoleCommand("ai_serverragdolls", "1")
    end)
end

------------------------------------------------------------------------------------------------------------------------
-- Betters VJ Base Rendeering
hook.Remove("PlayerInitialSpawn", "VJBaseSpawn")

------------------------------------------------------------------------------------------------------------------------
-- Fixes Constraint Crashes 
function MODULE:PropBreak(attacker, ent)
    if IsValid(ent) and ent:GetPhysicsObject():IsValid() then
        constraint.RemoveAll(ent)
    end
end