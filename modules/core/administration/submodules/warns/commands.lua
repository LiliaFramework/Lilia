lia.command.add("warn", {
    adminOnly = true,
    privilege = "Issue Warnings",
    desc = L("warnDesc"),
    syntax = "[string target] [string reason]",
    AdminStick = {
        Name = L("warnPlayer"),
        Category = L("moderationTools"),
        SubCategory = L("warnings"),
        Icon = "icon16/error.png",
        ExtraFields = {
            [L("warningField")] = "text"
        }
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
        target:notify(L("playerWarned", warning.admin, reason))
        client:notify(L("warningIssued", target:Nick()))
        lia.log.add(client, "warningIssued", target, reason)
    end
})

lia.command.add("viewwarns", {
    adminOnly = true,
    privilege = "View Player Warnings",
    desc = L("viewWarnsDesc"),
    syntax = "[string target]",
    AdminStick = {
        Name = L("viewPlayerWarnings"),
        Category = L("moderationTools"),
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
            client:notify(L("noWarnings", target:Nick()))
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
                name = L("idField"),
                field = "index"
            },
            {
                name = L("timestampField"),
                field = "timestamp"
            },
            {
                name = L("reasonField"),
                field = "reason"
            },
            {
                name = L("adminField"),
                field = "admin"
            }
        }, warningList, {
            {
                name = L("removeWarning"),
                net = "RequestRemoveWarning"
            }
        }, target:getChar():getID())
    end
})