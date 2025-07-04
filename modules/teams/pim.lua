AddInteraction("Invite To Faction", {
    runServer = true,
    shouldShow = function(client, target)
        local cChar = client:getChar()
        local tChar = target:getChar()
        if not cChar or not tChar then return false end
        if cChar:hasFlags("Z") then return true end
        return hook.Run("CanInviteToFaction", client, target) ~= false and cChar:getFaction() ~= tChar:getFaction()
    end,
    onRun = function(client, target)
        if not SERVER then return end
        local iChar = client:getChar()
        local tChar = target:getChar()
        if not iChar or not tChar then return end
        local faction
        for _, fac in pairs(lia.faction.teams) do
            if fac.index == client:Team() then faction = fac end
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

            if hook.Run("CanCharBeTransfered", tChar, faction, tChar:getFaction()) == false then return end
            local oldFaction = tChar:getFaction()
            tChar.vars.faction = faction.uniqueID
            tChar:setFaction(faction.index)
            tChar:kickClass()
            local defClass = lia.faction.getDefaultClass(faction.index)
            if defClass then tChar:joinClass(defClass.index) end
            hook.Run("OnTransferred", target)
            if faction.OnTransferred then faction:OnTransferred(target, oldFaction) end
            hook.Run("PlayerLoadout", target)
            client:notifyLocalized("transferSuccess", target:Name(), faction.name)
            if client ~= target then target:notifyLocalized("transferNotification", faction.name, client:Name()) end
            tChar:takeFlags("Z")
        end)
    end
})