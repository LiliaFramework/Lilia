local function LooksLikeSQLi(value)
    local lowerValue = string.lower(value or "")
    return lowerValue:find("'%s*;") or lowerValue:find("%-%-") or lowerValue:find("%f[%a]update%f[%A]") or lowerValue:find("%f[%a]insert%f[%A]") or lowerValue:find("%f[%a]delete%f[%A]") or lowerValue:find("%f[%a]drop%f[%A]") or lowerValue:find("%f[%a]union%f[%A]") or lowerValue:find("%f[%a]select%f[%A]")
end

function MediaPlayer.History:LogRequest(media)
    local id = media:UniqueID()
    if not id then return end
    local ply = media:GetOwner()
    if not IsValid(ply) then return end
    local mediaUrl = tostring(media:Url() or "")
    local playerName = tostring(ply:Nick() or "")
    local steamId = tostring(ply:SteamID64() or "-1")
    local mediaId = tostring(id)
    if LooksLikeSQLi(mediaId) or LooksLikeSQLi(mediaUrl) or LooksLikeSQLi(playerName) then print(string.format("[MediaPlayer] Suspicious media request blocked from SQL injection path: player=%s steamid=%s mediaid=%s url=%s", playerName, steamId, mediaId, mediaUrl)) end
    local query = string.format("INSERT INTO `%s` (mediaid,url,player_name,steamid) VALUES (%s,%s,%s,%s)", TableName, sql.SQLStr(mediaId), sql.SQLStr(mediaUrl), sql.SQLStr(playerName), sql.SQLStr(steamId))
    local result = sql.Query(query)
    if MediaPlayer.DEBUG then
        print("MediaPlayer.History.LogRequest")
        print(query)
        if istable(result) then
            PrintTable(result)
        else
            print(result)
        end
    end
    return result
end