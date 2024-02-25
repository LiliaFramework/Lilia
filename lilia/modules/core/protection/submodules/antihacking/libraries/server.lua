---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
local MODULE = MODULE
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
AntiHacking = AntiHacking or {}
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
AntiHacking.antiNetSpam = {}
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
AntiHacking.flaggedNetPlayers = {}
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
AntiHacking.antiConSpam = {}
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
AntiHacking.flaggedConPlayers = {}
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
AntiHacking.threshold = 20
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function MODULE:InitializedModules()
    file.CreateDir("lilia/netlogs")
    file.CreateDir("lilia/concommandlogs")
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
timer.Create("AntiHacking.CleanSpam", 1, 0, function()
    AntiHacking.antiNetSpam = {}
    AntiHacking.flaggedNetPlayers = {}
    AntiHacking.antiConSpam = {}
    AntiHacking.flaggedConPlayers = {}
end)

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function net.Incoming(len, client)
    local i = net.ReadHeader()
    local name = util.NetworkIDToString(i)
    if not name then return end
    local plySteamid = IsValid(client) and client:SteamID() or "UNKNOWN STEAMID"
    local plyNick = IsValid(client) and client:Nick() or "UNKNOWN PLAYER NAME"
    local plyIP = IsValid(client) and client:IPAddress() or "UNKNOWN IP"
    local antiNetSpam = AntiHacking.antiNetSpam
    local flaggedNetPlayers = AntiHacking.flaggedNetPlayers
    antiNetSpam[plySteamid] = antiNetSpam[plySteamid] or {}
    antiNetSpam[plySteamid][name] = (antiNetSpam[plySteamid][name] or 0) + 1
    if antiNetSpam[plySteamid][name] > AntiHacking.threshold then
        if not flaggedNetPlayers[plySteamid] then file.Append("lilia/netlogs/" .. os.date("%x"):gsub("/", "-") .. ".txt", "[" .. os.date("%X") .. "]\t" .. string.format("Net spam attempted on Net Message: %s Client: %s (STEAMID: %s) (IP: %s) \n", name, plyNick, plySteamid, plyIP) .. "\r\n") end
        flaggedNetPlayers[plySteamid] = true
    end

    local func = net.Receivers[name:lower()]
    if not func then
        file.Append("lilia/netlogs/" .. os.date("%x"):gsub("/", "-") .. ".txt", "[" .. os.date("%X") .. "]\t" .. string.format("No receiving function for '%s' (net msg #%d) Client: %s (STEAMID: %s) (IP: %s) \n", name, i, plyNick, plySteamid, plyIP) .. "\r\n")
        return
    end

    len = len - 16
    local curString = not table.HasValue(AntiHacking.ExploitableNetMessages, name) and "Net message '%s' (%d) received (%.2fkb (%db)) Client: %s (STEAMID: %s) (IP: %s) \n" or "Net message '%s' (%d) received (%.2fkb (%db)) Client: %s (STEAMID: %s) (IP: %s) [ Exploitable String ] \n"
    file.Append("lilia/netlogs/" .. os.date("%x"):gsub("/", "-") .. ".txt", "[" .. os.date("%X") .. "]\t" .. string.format(curString, name, i, len / 8 / 1024, len / 8, plyNick, plySteamid, plyIP) .. "\r\n")
    local status, error = pcall(function() func(len, client) end)
    if not status then file.Append("lilia/netlogs/" .. os.date("%x"):gsub("/", "-") .. ".txt", "[" .. os.date("%X") .. "]\t" .. string.format("Error during net message (%s). Reasoning: %s \n", name, error) .. "\r\n") end
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
AntiHacking.crun = AntiHacking.crun or concommand.Run
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function concommand.Run(client, cmd, args, argStr)
    if not IsValid(client) then return AntiHacking.crun(client, cmd, args, argStr) end
    if not cmd then return AntiHacking.crun(client, cmd, args, argStr) end
    local plySteamid = IsValid(client) and client:SteamID() or "UNKNOWN STEAMID"
    local plyNick = IsValid(client) and client:Nick() or "UNKNOWN PLAYER NAME"
    local plyIP = IsValid(client) and client:IPAddress() or "UNKNOWN IP"
    local antiConSpam = AntiHacking.antiConSpam
    local flaggedConPlayers = AntiHacking.flaggedConPlayers
    antiConSpam[plySteamid] = antiConSpam[plySteamid] or {}
    antiConSpam[plySteamid][cmd] = (antiConSpam[plySteamid][cmd] or 0) + 1
    local temp = (args and args ~= "" and #args ~= 0) and " " .. table.concat(args, " ") or "None"
    if antiConSpam[plySteamid][cmd] > 10 then
        if not flaggedConPlayers[plySteamid] then file.Append("lilia/concommandlogs/" .. os.date("%x"):gsub("/", "-") .. ".txt", "[" .. os.date("%X") .. "]\t" .. "Player " .. "'" .. plyNick .. "'" .. " (" .. plySteamid .. ") " .. "(" .. plyIP .. ")" .. " has attempted to concommand spam with command: " .. cmd .. " args: " .. temp .. "\r\n") end
        flaggedConPlayers[plySteamid] = true
    end

    file.Append("lilia/concommandlogs/" .. os.date("%x"):gsub("/", "-") .. ".txt", "[" .. os.date("%X") .. "]\t" .. "Player " .. "'" .. plyNick .. "'" .. " (" .. plySteamid .. ") " .. "(" .. plyIP .. ")" .. " has executed this command: " .. cmd .. " args: " .. temp .. "\r\n")
    return AntiHacking.crun(client, cmd, args, argStr)
end
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
