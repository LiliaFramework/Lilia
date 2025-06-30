lia.command.add("warn", {
    adminOnly = true,
    privilege = "Issue Warnings",
    desc = L("warnDesc"),
    syntax = "[player Target] [string Reason]",
    AdminStick = {
        Name = L("warnPlayer"),
        Category = "moderationTools",
        SubCategory = L("warnings"),
        Icon = "icon16/error.png"
    },
    onRun = function(client, arguments)
        local targetName = arguments[1]
        local reason = table.concat(arguments, " ", 2)
        if not targetName or reason == "" then return L("warnUsage") end
        local target = lia.util.findPlayer(client, targetName)
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        local warning = {
            timestamp = os.date("%Y-%m-%d %H:%M:%S"),
            reason = reason,
            admin = client:Nick() .. " (" .. client:SteamID64() .. ")"
        }

        local warns = target:getLiliaData("warns") or {}
        table.insert(warns, warning)
        target:setLiliaData("warns", warns)
        target:notifyLocalized("playerWarned", warning.admin, reason)
        client:notifyLocalized("warningIssued", target:Nick())
        lia.log.add(client, "warningIssued", target, reason)
    end
})

lia.command.add("viewwarns", {
    adminOnly = true,
    privilege = "View Player Warnings",
    desc = L("viewWarnsDesc"),
    syntax = "[player Target]",
    AdminStick = {
        Name = L("viewPlayerWarnings"),
        Category = "moderationTools",
        SubCategory = L("warnings"),
        Icon = "icon16/eye.png"
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        local warns = target:getLiliaData("warns") or {}
        if table.Count(warns) == 0 then
            client:notifyLocalized("noWarnings", target:Nick())
            return
        end

        local warningList = {}
        for index, warn in ipairs(warns) do
            table.insert(warningList, {
                index = index,
                timestamp = warn.timestamp or "N/A",
                reason = warn.reason or "N/A",
                admin = warn.admin or "N/A"
            })
        end

        lia.util.CreateTableUI(client, target:Nick() .. "'s " .. L("warnings"), {
            {
                name = L("id"),
                field = "index"
            },
            {
                name = L("timestamp"),
                field = "timestamp"
            },
            {
                name = L("reason"),
                field = "reason"
            },
            {
                name = L("admin"),
                field = "admin"
            }
        }, warningList, {
            {
                name = L("removeWarning"),
                net = "RequestRemoveWarning"
            }
        }, target:getChar():getID())

        lia.log.add(client, "viewWarns", target)
    end
})