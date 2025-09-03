hook.Add("WarningIssued", "ExampleWarningIssued", function(admin, target, reason, count, adminSteamID, targetSteamID) print(string.format("[WARNING ISSUED] Admin: %s (%s) | Target: %s (%s) | Reason: %s | Total Warnings: %d", admin:Name(), adminSteamID, target:Name(), targetSteamID, reason, count)) end)
hook.Add("WarningRemoved", "ExampleWarningRemoved", function(admin, target, warning, index) print(string.format("[WARNING REMOVED] Admin: %s (%s) | Target: %s (%s) | Original Admin: %s (%s) | Reason: %s | Index: %d", admin:Name(), admin:SteamID(), target:Name(), warning.targetSteamID, warning.admin, warning.adminSteamID, warning.reason, index)) end)
hook.Add("WarningIssued", "AdvancedWarningLogger", function(admin, target, reason, count, adminSteamID, targetSteamID)
    local timestamp = os.date("%Y-%m-%d %H:%M:%S")
    local logEntry = {
        timestamp = timestamp,
        action = "warning_issued",
        admin_name = admin:Name(),
        admin_steamid = adminSteamID,
        target_name = target:Name(),
        target_steamid = targetSteamID,
        reason = reason,
        total_warnings = count,
        map = game.GetMap(),
        server_name = GetHostName()
    }

    print("Advanced Warning Log:", util.TableToJSON(logEntry, true))
end)

hook.Add("WarningRemoved", "AdvancedWarningRemovalLogger", function(admin, target, warning, index)
    local timestamp = os.date("%Y-%m-%d %H:%M:%S")
    local logEntry = {
        timestamp = timestamp,
        action = "warning_removed",
        remover_name = admin:Name(),
        remover_steamid = admin:SteamID(),
        target_name = target:Name(),
        target_steamid = warning.targetSteamID,
        original_admin = warning.admin,
        original_admin_steamid = warning.adminSteamID,
        original_reason = warning.reason,
        warning_index = index,
        map = game.GetMap(),
        server_name = GetHostName()
    }

    print("Advanced Warning Removal Log:", util.TableToJSON(logEntry, true))
end)