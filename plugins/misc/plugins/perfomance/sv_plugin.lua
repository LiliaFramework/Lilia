------------------------------------------------------------------------------------------------------------------------s
-- Betters Ragdoll Rendeering
function PLUGIN:InitializedPlugins()
    timer.Simple(3, function()
        RunConsoleCommand("ai_serverragdolls", "1")
    end)
end

------------------------------------------------------------------------------------------------------------------------
-- Betters VJ Base Rendeering
hook.Remove("PlayerInitialSpawn", "VJBaseSpawn")