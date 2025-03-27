local MODULE = MODULE
MODULE.OOCBans = MODULE.OOCBans or {}
lia.command.add("banooc", {
    adminOnly = true,
    privilege = "Ban OOC",
    desc = "Bans the specified player from using out‑of‑character chat.",
    syntax = "[string charname]",
    AdminStick = {
        Name = "Ban OOC",
        Category = "Moderation Tools",
        SubCategory = "OOC",
        Icon = "icon16/sound_mute.png"
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        MODULE.OOCBans[target:SteamID64()] = true
        client:notify(target:Name() .. " has been banned from OOC.")
    end
})

lia.command.add("unbanooc", {
    adminOnly = true,
    privilege = "Unban OOC",
    desc = "Unbans the specified player from out‑of‑character chat.",
    syntax = "[string charname]",
    AdminStick = {
        Name = "Unban OOC",
        Category = "Moderation Tools",
        SubCategory = "OOC",
        Icon = "icon16/sound.png"
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        MODULE.OOCBans[target:SteamID64()] = nil
        client:notify(target:Name() .. " has been unbanned from OOC.")
    end
})

lia.command.add("blockooc", {
    superAdminOnly = true,
    privilege = "Block OOC",
    desc = "Toggles a global block on all out‑of‑character chat.",
    onRun = function(client)
        local blocked = GetGlobalBool("oocblocked", false)
        SetGlobalBool("oocblocked", not blocked)
        client:notify(blocked and "Unlocked OOC!" or "Blocked OOC!")
    end
})

lia.command.add("refreshfonts", {
    superAdminOnly = true,
    privilege = "Refresh Fonts",
    desc = "Refreshes client fonts.",
    onRun = function(client) client:ConCommand("refreshfonts") end
})

lia.command.add("clearchat", {
    adminOnly = true,
    privilege = "Clear Chat",
    desc = "Clears chat for all players.",
    onRun = function()
        for _, ply in player.Iterator() do
            ply:ConCommand("fixchatplz")
        end
    end
})
