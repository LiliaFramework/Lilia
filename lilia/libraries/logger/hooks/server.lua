local GM = GM or GAMEMODE
function GM:OnServerLog(client, logType, ...)
    for _, v in pairs(lia.util.getAdmins()) do
        if hook.Run("CanPlayerSeeLog", v, logType) ~= false then lia.log.send(v, lia.log.getString(client, logType, ...)) end
    end
end
