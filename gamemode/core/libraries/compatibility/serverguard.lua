hook.Add("RunAdminSystemCommand", "liaServerguard", function(cmd, exec, victim, dur, reason)
    local caller = IsValid(exec) and exec or false
    if cmd == "kick" then
        serverguard.command.Run("kick", caller, victim:SteamID64(), reason or "")
        return true
    elseif cmd == "ban" then
        serverguard.command.Run("ban", caller, victim:SteamID64(), tostring(dur or 0), reason or "")
        return true
    elseif cmd == "unban" then
        serverguard.command.Run("unban", caller, isstring(victim) and victim or victim:SteamID64())
        return true
    elseif cmd == "mute" then
        serverguard.command.Run("mute", caller, victim:SteamID64(), tostring(dur or 0), reason or "")
        return true
    elseif cmd == "unmute" then
        serverguard.command.Run("unmute", caller, victim:SteamID64())
        return true
    elseif cmd == "gag" then
        serverguard.command.Run("gag", caller, victim:SteamID64(), tostring(dur or 0), reason or "")
        return true
    elseif cmd == "ungag" then
        serverguard.command.Run("ungag", caller, victim:SteamID64())
        return true
    elseif cmd == "freeze" then
        serverguard.command.Run("freeze", caller, victim:SteamID64(), tostring(dur or 0))
        return true
    elseif cmd == "unfreeze" then
        serverguard.command.Run("unfreeze", caller, victim:SteamID64())
        return true
    elseif cmd == "slay" then
        serverguard.command.Run("slay", caller, victim:SteamID64())
        return true
    elseif cmd == "bring" then
        serverguard.command.Run("bring", caller, victim:SteamID64())
        return true
    elseif cmd == "goto" then
        serverguard.command.Run("goto", caller, victim:SteamID64())
        return true
    elseif cmd == "return" then
        serverguard.command.Run("return", caller, victim:SteamID64())
        return true
    elseif cmd == "jail" then
        serverguard.command.Run("jail", caller, victim:SteamID64(), tostring(dur or 0))
        return true
    elseif cmd == "unjail" then
        serverguard.command.Run("unjail", caller, victim:SteamID64())
        return true
    elseif cmd == "cloak" then
        serverguard.command.Run("cloak", caller, victim:SteamID64())
        return true
    elseif cmd == "uncloak" then
        serverguard.command.Run("uncloak", caller, victim:SteamID64())
        return true
    elseif cmd == "god" then
        serverguard.command.Run("god", caller, victim:SteamID64())
        return true
    elseif cmd == "ungod" then
        serverguard.command.Run("ungod", caller, victim:SteamID64())
        return true
    elseif cmd == "ignite" then
        serverguard.command.Run("ignite", caller, victim:SteamID64(), tostring(dur or 0))
        return true
    elseif cmd == "extinguish" or cmd == "unignite" then
        serverguard.command.Run("extinguish", caller, victim:SteamID64())
        return true
    elseif cmd == "strip" then
        serverguard.command.Run("strip", caller, victim:SteamID64())
        return true
    end
end)

serverguard.plugin:Toggle("restrictions", false)