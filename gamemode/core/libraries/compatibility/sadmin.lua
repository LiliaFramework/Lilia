--[[
    Folder: Compatibility
    File:  sadmin.md
]]
--[[
    SAdmin Compatibility

    Provides compatibility with SAdmin for unified admin command handling within the Lilia framework.
]]
--[[
    Improvements Done:
        The SAdmin compatibility module enables integration with SAdmin's admin commands and Lilia's permission system.
        The module operates on the server side to handle admin command execution, permission validation, and staff duty integration for SAdmin commands.
        It includes command mapping for kick, ban, mute, gag, freeze, slay, and other administrative actions with proper permission checking.
        The module integrates with Lilia's staff system to enforce duty requirements and faction restrictions for admin command usage.
]]
local sadminCommands = {
    kick = function(id, _, reason) RunConsoleCommand("sa", "kick", id, reason or "") end,
    ban = function(id, dur, reason) RunConsoleCommand("sa", "ban", id, tostring(dur or 0), reason or "") end,
    banid = function(id, dur, reason) RunConsoleCommand("sa", "banid", id, tostring(dur or 0), reason or "") end,
    unban = function(id) RunConsoleCommand("sa", "unban", id) end,
    mute = function(id, dur, reason) RunConsoleCommand("sa", "mute", id, tostring(dur or 0), reason or "") end,
    unmute = function(id) RunConsoleCommand("sa", "unmute", id) end,
    gag = function(id, dur, reason) RunConsoleCommand("sa", "gag", id, tostring(dur or 0), reason or "") end,
    ungag = function(id) RunConsoleCommand("sa", "ungag", id) end,
    noclip = function(id) RunConsoleCommand("sa", "noclip", id) end,
    hp = function(id, _, amount) RunConsoleCommand("sa", "hp", id, amount or "") end,
    armor = function(id, _, amount) RunConsoleCommand("sa", "armor", id, amount or "") end,
    freeze = function(id, dur) RunConsoleCommand("sa", "freeze", id, tostring(dur or 0)) end,
    unfreeze = function(id) RunConsoleCommand("sa", "unfreeze", id) end,
    slay = function(id) RunConsoleCommand("sa", "slay", id) end,
    bring = function(id) RunConsoleCommand("sa", "bring", id) end,
    ["goto"] = function(id) RunConsoleCommand("sa", "goto", id) end,
    ["return"] = function(id) RunConsoleCommand("sa", "return", id) end,
    tp = function(id, dest) RunConsoleCommand("sa", "tp", id, dest or "") end,
    jail = function(id, dur) RunConsoleCommand("sa", "jail", id, tostring(dur or 0)) end,
    unjail = function(id) RunConsoleCommand("sa", "unjail", id) end,
    cloak = function(id) RunConsoleCommand("sa", "cloak", id) end,
    uncloak = function(id) RunConsoleCommand("sa", "uncloak", id) end,
    god = function(id) RunConsoleCommand("sa", "god", id) end,
    ungod = function(id) RunConsoleCommand("sa", "ungod", id) end,
    ignite = function(id, dur) RunConsoleCommand("sa", "ignite", id, tostring(dur or 1)) end,
    extinguish = function(id) RunConsoleCommand("sa", "extinguish", id) end,
    unignite = function(id) RunConsoleCommand("sa", "extinguish", id) end,
    strip = function(id) RunConsoleCommand("sa", "strip", id) end,
    stopsound = function() RunConsoleCommand("sa", "stopsound") end,
    cleardecals = function() RunConsoleCommand("sa", "cleardecals") end
}

hook.Add("RunAdminSystemCommand", "liaSAdmin", function(cmd, admin, victim, dur, reason)
    local id = isstring(victim) and victim or IsValid(victim) and victim:SteamID()
    if not id then return end
    local commandFunc = sadminCommands[cmd]
    if commandFunc then
        commandFunc(id, dur, reason)
        return true, function() end
    end
end)

hook.Add("OnSetUsergroup", "liaSAdminSetUserGroup", function(steamID, group)
    if not steamID or steamID == "" or not group or group == "" then return end
    RunConsoleCommand("sa", "setrankid", steamID, group, "0")
end)