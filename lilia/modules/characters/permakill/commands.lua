lia.command.add("pktoggle", {
    adminOnly = true,
    privilege = "Toggle Permakill",
    syntax = "[string charname]",
    onRun = function(client, arguments)
        local target = lia.command.findPlayer(client, arguments[1])
        if not IsValid(target) then
            client:notifyLocalized("invalid", "Player")
            return
        end

        local character = target:getChar()
        if not character then
            client:notifyLocalized("invalid", "Character")
            return
        end

        local currentState = character:getData("PermaKillFlagged", false)
        local newState = not currentState
        character:setData("PermaKillFlagged", newState)
        if newState then
            client:notifyLocalized("pktoggle_true")
        else
            client:notifyLocalized("pktoggle_false")
        end
    end
})

lia.command.add("charPK", {
    superAdminOnly = true,
    privilege = "Force Permakill",
    syntax = "[string charname]",
    onRun = function(client, arguments)
        local target = lia.command.findPlayer(client, arguments[1])
        if not IsValid(target) or not target:getChar() then
            client:notifyLocalized("charPK_target_not_found")
            return
        end

        local character = target:getChar()
        character:ban()
        client:notifyLocalized("charPK_success_admin", target:Name())
        target:notifyLocalized("charPK_success_target", client:Name())
    end
})
