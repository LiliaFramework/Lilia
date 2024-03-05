local lastcheck
function MODULE:Think()
    if not lastcheck then lastcheck = CurTime() end
    if CurTime() - lastcheck > 60 then
        local commands, _ = concommand.GetTable()
        for _, cmd in pairs(self.HackCommands) do
            if commands[cmd] then
                net.Start("IAmHackingOwO")
                net.SendToServer()
            end
        end

        for _, cvarName in ipairs(self.BadCVars) do
            if GetConVar_Internal(cvarName) ~= nil then
                net.Start("IAmHackingOwO")
                net.SendToServer()
            end
        end

        for _, name in ipairs(self.HackGlobals) do
            if _G[name] then
                net.Start("IAmHackingOwO")
                net.SendToServer()
            end
        end

        lastcheck = CurTime()
    end
end
