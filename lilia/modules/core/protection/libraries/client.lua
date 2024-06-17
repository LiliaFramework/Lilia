local lastcheck = CurTime()

function MODULE:CanDeleteChar(_, character)
    if IsValid(character) and character:getMoney() < lia.config.DefaultMoney then return false end
end

function MODULE:Think()
    if CurTime() - lastcheck > 60 then
        local commands, _ = concommand.GetTable()
        for _, cmd in pairs(self.HackCommands) do
            if commands[cmd] ~= nil then
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
            if _G[name] ~= nil then
                net.Start("IAmHackingOwO")
                net.SendToServer()
            end
        end

        lastcheck = CurTime()
    end
end