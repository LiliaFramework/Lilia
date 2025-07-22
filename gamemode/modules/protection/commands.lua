local MODULE = MODULE
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
            local timestamp = os.date("%Y-%m-%d %H:%M:%S")
            local adminStr = client:Nick() .. " (" .. client:SteamID() .. ")"
            local warnsModule = lia.module.list["warns"]
            if warnsModule and warnsModule.AddWarning then
                warnsModule:AddWarning(target:getChar():getID(), target:SteamID64(), timestamp, L("cheaterWarningReason"), adminStr)
                lia.db.count("warnings", "_charID = " .. lia.db.convertDataType(target:getChar():getID())):next(function(count)
                    target:notifyLocalized("playerWarned", adminStr, L("cheaterWarningReason"))
                    client:notifyLocalized("warningIssued", target:Nick())
                    hook.Run("WarningIssued", client, target, L("cheaterWarningReason"), count)
                end)
            end
        end

        lia.log.add(client, "cheaterToggle", target:Name(), isCheater and "Unmarked" or "Marked")
    end
})
