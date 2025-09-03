lia.playerinteract.addInteraction("inviteToFaction", {
    serverOnly = true,
    category = L("categoryFactionManagement"),
    shouldShow = function(client, target)
        local cChar = client:getChar()
        local tChar = target:getChar()
        if not cChar or not tChar then return false end
        if cChar:hasFlags("Z") then return true end
        local classData = lia.class.list[cChar:getClass()]
        if classData and classData.canInviteToFaction then return true end
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

        if faction.uniqueID == "staff" then
            client:notifyLocalized("staffInviteBlocked")
            return
        end

        target:binaryQuestion(L("joinFactionPrompt"), L("yes"), L("no"), false, function(choice)
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

lia.playerinteract.addInteraction("inviteToClass", {
    serverOnly = true,
    category = L("categoryFactionManagement"),
    shouldShow = function(client, target)
        local cChar = client:getChar()
        local tChar = target:getChar()
        if not cChar or not tChar then return false end
        if cChar:hasFlags("X") then return true end
        local classData = lia.class.list[cChar:getClass()]
        if classData and classData.canInviteToClass then return true end
        if cChar:getFaction() ~= tChar:getFaction() then return false end
        return hook.Run("CanInviteToClass", client, target) ~= false
    end,
    onRun = function(client, target)
        if not SERVER then return end
        local cChar = client:getChar()
        local tChar = target:getChar()
        if not cChar or not tChar then return end
        local class = lia.class.list[cChar:getClass()]
        if not class then
            client:notifyLocalized("invalidClass")
            return
        end

        target:binaryQuestion(L("joinClassPrompt"), L("yes"), L("no"), false, function(choice)
            if choice ~= 0 then
                client:notifyLocalized("inviteDeclined")
                return
            end

            if hook.Run("CanCharBeTransfered", tChar, class, tChar:getClass()) == false then return end
            local oldClass = tChar:getClass()
            tChar:setClass(class.index)
            hook.Run("OnPlayerJoinClass", target, class.index, oldClass)
            client:notifyLocalized("transferSuccess", target:Name(), class.name)
            if client ~= target then target:notifyLocalized("transferNotification", class.name, client:Name()) end
        end)
    end
})