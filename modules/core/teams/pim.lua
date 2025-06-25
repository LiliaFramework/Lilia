AddInteraction("Invite To Faction", {
    runServer = true,
    shouldShow = function(client, target)
        local clientChar = client:getChar()
        local targetChar = target:getChar()
        if not clientChar or not targetChar then return false end
        return clientChar:hasFlags("Z") and clientChar:getFaction() ~= targetChar:getFaction()
    end,
    onRun = function(client, target)
        if not SERVER then return end
        local inviterChar = client:getChar()
        local targetChar = target:getChar()
        if not inviterChar or not targetChar then return end
        local factionIndex = client:Team()
        for _, fac in pairs(lia.faction.teams) do
            if fac.index == factionIndex then faction = fac end
        end

        if not faction then
            client:notifyLocalized("invalidFaction")
            return
        end

        target:binaryQuestion("Do you want to join this faction?", "Yes", "No", false, function(choice)
            if choice ~= 0 then
                client:notifyLocalized("inviteDeclined")
                return
            end

            if hook.Run("CanCharBeTransfered", targetChar, faction, targetChar:getFaction()) == false then return end
            targetChar.vars.faction = faction.uniqueID
            targetChar:setFaction(factionIndex)
            targetChar:kickClass()
            local defaultClass = lia.faction.getDefaultClass(factionIndex)
            if defaultClass then targetChar:joinClass(defaultClass.index) end
            hook.Run("OnTransferred", target)
            if faction.OnTransferred then faction:OnTransferred(target) end
            hook.Run("PlayerLoadout", target)
            client:notifyLocalized("transferSuccess", target:Name(), faction.name)
            if client ~= target then target:notifyLocalized("transferNotification", faction.name, client:Name()) end
            targetChar:takeFlags("Z")
        end)
    end
})
