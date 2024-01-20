function PerfomanceCore:InitializedModules()
    for hookType, identifiers in pairs(PerfomanceCore.RemovableHooks) do
        for _, identifier in ipairs(identifiers) do
            local hookTable = hook.GetTable()[hookType]
            if hookTable and hookTable[identifier] then
                hook.Remove(hookType, identifier)
                print(string.format("Removed hook: %s - %s", hookType, identifier))
            end
        end
    end

    for _, timerName in ipairs(PerfomanceCore.TimersToRemove) do
        if timer.Exists(timerName) then
            timer.Remove(timerName)
            print(string.format("Removed timer: %s", timerName))
        end
    end

    for command, value in pairs(PerfomanceCore.StartupConsoleCommands) do
        local client_command = command .. " " .. value
        if concommand.GetTable()[command] then
            if SERVER then
                RunConsoleCommand(command, value)
                print(string.format("Executed console command on server: %s %s", command, value))
            else
                LocalPlayer():ConCommand(client_command)
                print(string.format("Executed console command on client: %s", client_command))
            end
        end
    end
end
