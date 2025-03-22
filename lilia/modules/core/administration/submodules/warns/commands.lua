lia.command.add("warn", {
    adminOnly = true,
    privilege = "Issue Warnings",
    syntax = "<string target> <string reason>",
    AdminStick = {
        Name = "Warn Player",
        Category = "Moderation Tools",
        SubCategory = "Warnings",
        Icon = "icon16/error.png",
        ExtraFields = {
            ["Warning"] = "text"
        }
    },
    onRun = function(client, arguments)
        local targetName = arguments[1]
        local reason = table.concat(arguments, " ", 2)
        if not targetName or not reason then return "Usage: warn <player> <reason>" end
        local target = lia.command.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyLocalized("noTarget")
            return
        end

        local warning = {
            timestamp = os.date("%Y-%m-%d %H:%M:%S"),
            reason = reason,
            admin = client:Nick() .. " (" .. client:SteamID() .. ")"
        }

        local warns = target:getLiliaData("warns") or {}
        table.insert(warns, warning)
        target:setLiliaData("warns", warns)
        target:notify("You have been warned by " .. warning.admin .. " for: " .. reason)
        client:notify("Warning issued to " .. target:Nick())
        lia.log.add(client, "warningIssued", target, reason)
    end
})

lia.command.add("viewwarns", {
    adminOnly = true,
    privilege = "View Player Warnings",
    syntax = "<string target>",
    AdminStick = {
        Name = "View Player Warnings",
        Category = "Moderation Tools",
        SubCategory = "Warnings",
        Icon = "icon16/eye.png"
    },
    onRun = function(client, arguments)
        local target = lia.command.findPlayer(client, arguments[1])
        local warns = target:getLiliaData("warns") or {}
        if not target or not IsValid(target) then
            client:notifyLocalized("noTarget")
            return
        end

        if table.Count(warns) == 0 then
            client:notify(target:Nick() .. " has no warnings.")
            return
        end

        local warningList = {}
        for index, warn in ipairs(warns) do
            table.insert(warningList, {
                index = index,
                timestamp = warn.timestamp or "N/A",
                reason = warn.reason or "N/A",
                admin = warn.admin or "N/A",
            })
        end

        lia.util.CreateTableUI(client, target:Nick() .. "'s Warnings", {
            {
                name = "ID",
                field = "index"
            },
            {
                name = "Timestamp",
                field = "timestamp"
            },
            {
                name = "Reason",
                field = "reason"
            },
            {
                name = "Admin",
                field = "admin"
            },
        }, warningList, {
            {
                name = "Remove Warning",
                net = "RequestRemoveWarning"
            }
        }, target:getChar():getID())
    end
})