lia.command.add("banooc", {
    adminOnly = true,
    desc = "banOOCCommandDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "banOOCStickName",
        Category = "utility",
        SubCategory = "ooc",
        Icon = "icon16/sound_mute.png"
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        target:setLiliaData("oocBanned", true)
        client:notifyLocalized("playerBannedFromOOC", target:Name())
        lia.log.add(client, "banOOC", target:Name(), target:SteamID())
    end
})

lia.command.add("unbanooc", {
    adminOnly = true,
    desc = "unbanOOCCommandDesc",
    arguments = {
        {
            name = "name",
            type = "player"
        },
    },
    AdminStick = {
        Name = "unbanOOCStickName",
        Category = "utility",
        SubCategory = "ooc",
        Icon = "icon16/sound.png"
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        target:setLiliaData("oocBanned", nil)
        client:notifyLocalized("playerUnbannedFromOOC", target:Name())
        lia.log.add(client, "unbanOOC", target:Name(), target:SteamID())
    end
})

lia.command.add("blockooc", {
    superAdminOnly = true,
    desc = "blockOOCCommandDesc",
    onRun = function(client)
        local blocked = GetGlobalBool("oocblocked", false)
        SetGlobalBool("oocblocked", not blocked)
        client:notifyLocalized(blocked and "unlockedOOC" or "blockedOOC")
        lia.log.add(client, "blockOOC", not blocked)
    end
})

lia.command.add("clearchat", {
    adminOnly = true,
    desc = "clearChatCommandDesc",
    onRun = function(client)
        net.Start("RegenChat")
        net.Broadcast()
        lia.log.add(client, "clearChat")
    end
})