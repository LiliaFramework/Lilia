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

lia.playerinteract.addInteraction("inviteToFaction", {
    serverOnly = true,
    category = "@factionManagement",
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
            client:notifyErrorLocalized("invalidFaction")
            return
        end

        if faction.uniqueID == "staff" then
            client:notifyErrorLocalized("staffInviteBlocked")
            return
        end

        target:requestBinaryQuestion("@joinFactionTitle", "@joinFactionPrompt", "@yes", "@no", function(choice)
            if not IsValid(client) or not IsValid(target) then return end
            if choice ~= 0 then
                client:notifyInfoLocalized("inviteDeclined")
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
            client:notifySuccessLocalized("transferSuccess", target:Name(), faction.name)
            if client ~= target then target:notifyInfoLocalized("transferNotification", faction.name, client:Name()) end
            targetChar:takeFlags("Z")
        end)
    end
})

lia.playerinteract.addInteraction("inviteToClass", {
    serverOnly = true,
    category = "@factionManagement",
    shouldShow = canInviteToClass,
    onRun = function(client, target)
        if not SERVER or not canInviteToClass(client, target) then return end
        local clientChar = client:getChar()
        local targetChar = target:getChar()
        if not clientChar or not targetChar then return end
        local class = lia.class.list[clientChar:getClass()]
        if not class then
            client:notifyErrorLocalized("invalidClass")
            return
        end

        target:requestBinaryQuestion("@joinClass", "@joinClassPrompt", "@yes", "@no", function(choice)
            if not IsValid(client) or not IsValid(target) then return end
            if choice ~= 0 then
                client:notifyInfoLocalized("inviteDeclined")
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
            client:notifySuccessLocalized("transferSuccess", target:Name(), class.name)
            if client ~= target then target:notifyInfoLocalized("transferNotification", class.name, client:Name()) end
        end)
    end
})
