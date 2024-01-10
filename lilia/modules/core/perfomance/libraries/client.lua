function PerfomanceCore:ClientsideInitializedModules()
    for _, timerName in pairs(self.TimersToRemove) do
        if timer.Exists(timerName) then timer.Remove(timerName) end
    end

    for k, v in pairs(self.StartupConsoleCommands) do
        if concommand.GetTable()[k] then RunConsoleCommand(k, v) end
    end
end
