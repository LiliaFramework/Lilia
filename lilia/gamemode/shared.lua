---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
DeriveGamemode("sandbox")
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
GM.Name = "Lilia"
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
GM.Author = "Leonheart"
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
GM.Website = "https://discord.gg/jjrhyeuzYV"
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
ModulesLoaded = false
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function GM:Initialize()
    hook.Run("LoadLiliaFonts", "Arial", "Segoe UI")
    lia.module.initialize()
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function GM:OnReloaded()
    if not ModulesLoaded then
        lia.module.initialize()
        ModulesLoaded = true
    end

    lia.faction.formatModelData()
    hook.Run("LoadLiliaFonts", lia.config.Font, lia.config.GenericFont)
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
for command, value in pairs(lia.config.StartupConsoleCommands) do
    if concommand.GetTable()[command] ~= nil then
        RunConsoleCommand(command, value)
        print(string.format("Executed console command on server: %s %s", command, value))
    end
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
for _, timerName in ipairs(lia.config.TimersToRemove) do
    if timer.Exists(timerName) then
        timer.Remove(timerName)
        print(string.format("Removed timer: %s", timerName))
    end
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
for hookType, identifiers in pairs(lia.config.RemovableHooks) do
    for _, identifier in ipairs(identifiers) do
        local hookTable = hook.GetTable()[hookType]
        if hookTable and isfunction(hookTable[identifier]) then
            hook.Remove(hookType, identifier)
            print(string.format("Removed hook: %s - %s", hookType, identifier))
        end
    end
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
if game.IsDedicated() then concommand.Remove("gm_save") end
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
