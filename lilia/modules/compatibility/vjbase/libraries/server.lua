
local vjThink = 0

function VJBaseCompatibility:Think()
    if vjThink <= CurTime() then
        for k, v in pairs(self.VJBaseConsoleCommands) do
            RunConsoleCommand(k, v)
        end

        vjThink = CurTime() + 180
    end
end


hook.Remove("PlayerInitialSpawn", "VJBaseSpawn")

hook.Remove("PlayerInitialSpawn", "drvrejplayerInitialSpawn")

