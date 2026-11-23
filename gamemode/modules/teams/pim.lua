local function canInviteToFaction(client, target)
    local clientChar = client:getChar()
    local targetChar = target:getChar()
    if not clientChar or not targetChar then return false end
    if clientChar:getFaction() == targetChar:getFaction() then return false end
    if clientChar:hasFlags("Z") then return true end
    local classData = lia.class.list[clientChar:getClass()]
    if classData and classData.canInviteToFaction then return true end
    return hook.Run("CanInviteToFaction", client, target) == true
end

local function canInviteToClass(client, target)
    local clientChar = client:getChar()
    local targetChar = target:getChar()
    if not clientChar or not targetChar then return false end
    if clientChar:getFaction() ~= targetChar:getFaction() then return false end
    if clientChar:hasFlags("X") then return true end
    local classData = lia.class.list[clientChar:getClass()]
    if classData and classData.canInviteToClass then return true end
    return hook.Run("CanInviteToClass", client, target) == true
end

lia.playerinteract.addInteraction("Invite To Faction", {
    serverOnly = true,
    category = "Faction Management",
    shouldShow = canInviteToFaction,
    onRun = function(client, target)
        if not SERVER or not canInviteToFaction(client, target) then return end
        local clientChar = client:getChar()
        local targetChar = target:getChar()
        if not clientChar or not targetChar then return end
        local faction
        for _, factionData in pairs(lia.faction.teams) do
            if factionData.index == client:Team() then
                faction = factionData
                break
            end
        end

        if not faction then
            client:notifyError(string.format("The specified faction is not valid."))
            return
        end

        if faction.uniqueID == "staff" then
            client:notifyError(string.format("You cannot invite players to the staff faction through the interaction menu. Staff characters must be created through the menu system."))
            return
        end

        target:requestBinaryQuestion("Join Faction", "Do you want to join this faction?", "Yes", "No", function(choice)
            if not IsValid(client) or not IsValid(target) then return end
            if choice ~= 0 then
                client:notifyInfo(string.format("Invite declined."))
                return
            end

            clientChar = client:getChar()
            targetChar = target:getChar()
            if not clientChar or not targetChar then return end
            if not canInviteToFaction(client, target) then return end
            if hook.Run("CanCharBeTransfered", targetChar, faction, targetChar:getFaction()) == false then return end
            local oldFaction = targetChar:getFaction()
            hook.Run("TrackFactionTransfer", targetChar, oldFaction, faction, client, "inviteToFaction")
            targetChar.vars.faction = faction.uniqueID
            targetChar:setFaction(faction.index)
            hook.Run("OnTransferred", target)
            if faction.OnTransferred then faction:OnTransferred(target, oldFaction) end
            hook.Run("PlayerLoadout", target)
            client:notifySuccess(string.format("%s has been transferred to %s.", target:Name(), faction.name))
            if client ~= target then target:notifyInfo(string.format("You have been transferred to %s by %s.", faction.name, client:Name())) end
            targetChar:takeFlags("Z")
        end)
    end
})

lia.playerinteract.addInteraction("Invite To Class", {
    serverOnly = true,
    category = "Faction Management",
    shouldShow = canInviteToClass,
    onRun = function(client, target)
        if not SERVER or not canInviteToClass(client, target) then return end
        local clientChar = client:getChar()
        local targetChar = target:getChar()
        if not clientChar or not targetChar then return end
        local class = lia.class.list[clientChar:getClass()]
        if not class then
            client:notifyError(string.format("The specified class is not valid."))
            return
        end

        target:requestBinaryQuestion("Join Class", "Do you want to join this class?", "Yes", "No", function(choice)
            if not IsValid(client) or not IsValid(target) then return end
            if choice ~= 0 then
                client:notifyInfo(string.format("Invite declined."))
                return
            end

            clientChar = client:getChar()
            targetChar = target:getChar()
            if not clientChar or not targetChar then return end
            if not canInviteToClass(client, target) then return end
            class = lia.class.list[clientChar:getClass()]
            if not class then return end
            if hook.Run("CanCharBeTransfered", targetChar, class, targetChar:getClass()) == false then return end
            local oldClass = targetChar:getClass()
            targetChar:setClass(class.index)
            hook.Run("OnPlayerJoinClass", target, class.index, oldClass)
            client:notifySuccess(string.format("%s has been transferred to %s.", target:Name(), class.name))
            if client ~= target then target:notifyInfo(string.format("You have been transferred to %s by %s.", class.name, client:Name())) end
        end)
    end
})
