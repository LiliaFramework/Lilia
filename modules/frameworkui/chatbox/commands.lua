local MODULE = MODULE
MODULE.OOCBans = MODULE.OOCBans or {}
lia.command.add("banooc", {
    adminOnly = true,
    privilege = "Ban OOC",
    desc = L("banOOCCommandDesc"),
    syntax = "[player Player Name]",
    AdminStick = {
        Name = L("banOOCCommandName"),
        Category = "moderationTools",
        SubCategory = L("oocCategory"),
        Icon = "icon16/sound_mute.png"
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        MODULE.OOCBans[target:SteamID64()] = true
        client:notify(target:Name() .. " " .. L("hasBeenBannedFromOOC"))
        lia.log.add(client, "banOOC", target:Name(), target:SteamID64())
    end
})

lia.command.add("unbanooc", {
    adminOnly = true,
    privilege = "Unban OOC",
    desc = L("unbanOOCCommandDesc"),
    syntax = "[player Player Name]",
    AdminStick = {
        Name = L("unbanOOCCommandName"),
        Category = "moderationTools",
        SubCategory = L("oocCategory"),
        Icon = "icon16/sound.png"
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        MODULE.OOCBans[target:SteamID64()] = nil
        client:notify(target:Name() .. " " .. L("hasBeenUnbannedFromOOC"))
        lia.log.add(client, "unbanOOC", target:Name(), target:SteamID64())
    end
})

lia.command.add("blockooc", {
    superAdminOnly = true,
    privilege = "Block OOC",
    desc = L("blockOOCCommandDesc"),
    onRun = function(client)
        local blocked = GetGlobalBool("oocblocked", false)
        SetGlobalBool("oocblocked", not blocked)
        client:notify(blocked and L("unlockedOOC") or L("blockedOOC"))
        lia.log.add(client, "blockOOC", not blocked)
    end
})

lia.command.add("clearchat", {
    adminOnly = true,
    privilege = "Clear Chat",
    desc = L("clearChatCommandDesc"),
    onRun = function(client)
        for _, ply in player.Iterator() do
            ply:ConCommand("fixchatplz")
        end
        lia.log.add(client, "clearChat")
    end
})
