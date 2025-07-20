lia.command.add("togglecheater", {
    adminOnly = true,
    privilege = "Toggle Cheater Status",
    desc = "toggleCheaterDesc",
    syntax = "[player Target]",
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        local isCheater = target:getLiliaData("cheater", false)
        target:setLiliaData("cheater", not isCheater)
        target:setNetVar("cheater", not isCheater and true or nil)
        target:saveLiliaData()

        if isCheater then
            client:notifyLocalized("cheaterUnmarked", target:Name())
            target:notifyLocalized("cheaterUnmarkedByAdmin")
        else
            client:notifyLocalized("cheaterMarked", target:Name())
            target:notifyLocalized("cheaterMarkedByAdmin")
            local warning = {
                timestamp = os.date("%Y-%m-%d %H:%M:%S"),
                reason = L("cheaterWarningReason"),
                admin = client:Nick() .. " (" .. client:SteamID() .. ")"
            }
            local warns = target:getLiliaData("warns") or {}
            table.insert(warns, warning)
            target:setLiliaData("warns", warns)
            target:notifyLocalized("playerWarned", warning.admin, warning.reason)
            client:notifyLocalized("warningIssued", target:Nick())
            hook.Run("WarningIssued", client, target, warning.reason, #warns)
        end

        lia.log.add(client, "cheaterToggle", target:Name(), isCheater and "Unmarked" or "Marked")
    end
})

