lia.command.add("togglecheater", {
    adminOnly = true,
    desc = "toggleCheaterDesc",
    arguments = {
        {
            name = "target",
            type = "player"
        },
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyErrorLocalized("targetNotFound")
            return
        end

        local isCheater = target:getLiliaData("cheater", false)
        target:setLiliaData("cheater", not isCheater)
        target:setNetVar("cheater", not isCheater and true or nil)
        hook.Run("OnCheaterStatusChanged", client, target, not isCheater)
        if isCheater then
            client:notifySuccessLocalized("cheaterUnmarked", target:Name())
            target:notifyInfoLocalized("cheaterUnmarkedByAdmin")
        else
            client:notifySuccessLocalized("cheaterMarked", target:Name())
            target:notifyWarningLocalized("cheaterMarkedByAdmin")
            local timestamp = os.date("%Y-%m-%d %H:%M:%S")
            local warnsModule = lia.module.list["warns"]
            if warnsModule and warnsModule.AddWarning then
                warnsModule:AddWarning(target:getChar():getID(), target:Nick(), target:SteamID(), timestamp, L("cheaterWarningReason"), client:Nick(), client:SteamID())
                lia.db.count("warnings", "charID = " .. lia.db.convertDataType(target:getChar():getID())):next(function(count)
                    target:notifyWarningLocalized("playerWarned", client:Nick() .. " (" .. client:SteamID() .. ")", L("cheaterWarningReason"))
                    client:notifySuccessLocalized("warningIssued", target:Nick())
                    hook.Run("WarningIssued", client, target, L("cheaterWarningReason"), count, client:SteamID(), target:SteamID())
                end)
            end
        end

        lia.log.add(client, "cheaterToggle", target:Name(), isCheater and L("cheaterStatusUnmarked") or L("cheaterStatusMarked"))
    end
})
