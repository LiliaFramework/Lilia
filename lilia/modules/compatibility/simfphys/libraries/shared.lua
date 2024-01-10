function SimfphysCompatibility:InitializedModules()
    for k, v in pairs(self.SimfphysConsoleCommands) do
        RunConsoleCommand(k, v)
    end
end

function SimfphysCompatibility:simfphysPhysicsCollide()
    return true
end
