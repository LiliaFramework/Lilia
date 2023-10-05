--------------------------------------------------------------------------------------------------------
local lastcheck
--------------------------------------------------------------------------------------------------------
function MODULE:Think()
    if not lastcheck then
        lastcheck = CurTime()
    end

    if CurTime() - lastcheck > 30 then
        local commands, _ = concommand.GetTable()
        for _, cmd in pairs(lia.config.HackCommands) do
            if commands[cmd] then
                net.Start("BanMeAmHack")
                net.SendToServer()
            end
        end

        lastcheck = CurTime()
    end
end
-------------------------------------------------------------------------------------------------------