mLogs.addCategory("Lilia", "lilia", Color(121, 65, 203), function() return true end, nil, 105)
mLogs.addLogger("Lilia MLogs", "LiliaMLogs", "lilia")
mLogs.addCategoryDefinitions("lilia", {
    LiliaMLogs = function(data) return mLogs.doLogReplace({"[Lilia]", "^log"}, data) end,
})

function MLogsCompatibility:OnServerLog(_, _, logString)
    mLogs.log("LiliaMLogs", "lilia", {
        log = logString
    })
end

function MLogsCompatibility:PlayerSwitchWeapon(client, oldWeapon, newWeapon)
    if client.lastEquipLog and client.lastEquipLog.oldWep == oldWeapon and client.lastEquipLog.newWep == newWeapon and SysTime() - client.lastEquipLog.time < 1 then return end
    client.lastEquipLog = {
        oldWep = oldWeapon,
        newWep = newWeapon,
        time = SysTime()
    }

    mLogs.log("equiplogs", "general", {
        client = mLogs.logger.getPlayerData(client),
        weapon = mLogs.logger.getWeaponData(newWeapon)
    })
end
