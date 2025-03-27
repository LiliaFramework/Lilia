lia.command.add("plytransfer", {
    adminOnly = true,
    privilege = "Manage Transfers",
    desc = "Transfers the specified player to a new faction.",
    syntax = "[string name] [string faction]",
    alias = {"charsetfaction"},
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        local factionName = table.concat(arguments, " ", 2)
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        local faction = lia.faction.teams[factionName] or lia.util.findFaction(client, factionName)
        if faction then
            if hook.Run("CanCharBeTransfered", target:getChar(), faction, target:Team()) == false then return end
            target:getChar().vars.faction = faction.uniqueID
            target:getChar():setFaction(faction.index)
            target:getChar():kickClass()
            local defaultClass = lia.faction.getDefaultClass(faction.index)
            if defaultClass then target:getChar():joinClass(defaultClass.index) end
            hook.Run("OnTransferred", target)
            if faction.OnTransferred then faction:OnTransferred(target) end
            client:notify(L("transferSuccess", target:Name(), L(faction.name, client)))
            hook.Run("PlayerLoadout", target)
            if client ~= target then target:notify(L("transferNotification", L(faction.name, target), client:Name())) end
        else
            return L("invalidFaction")
        end
    end
})

lia.command.add("plywhitelist", {
    adminOnly = true,
    privilege = "Manage Whitelists",
    desc = "Adds the specified player to a faction whitelist.",
    syntax = "[string name] [string faction]",
    alias = {"factionwhitelist"},
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        local faction = lia.util.findFaction(client, table.concat(arguments, " ", 2))
        if faction and target:setWhitelisted(faction.index, true) then
            for _, v in player.Iterator() do
                v:notifyLocalized("whitelist", client:Name(), target:Name(), L(faction.name, v))
            end
        end
    end
})

lia.command.add("plyunwhitelist", {
    adminOnly = true,
    privilege = "Manage Whitelists",
    desc = "Removes the specified player from a faction whitelist.",
    syntax = "[string name] [string faction]",
    alias = {"factionunwhitelist"},
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        local faction = lia.util.findFaction(client, table.concat(arguments, " ", 2))
        if faction and target:setWhitelisted(faction.index, false) then
            for _, v in player.Iterator() do
                v:notifyLocalized("unwhitelist", client:Name(), target:Name(), L(faction.name, v))
            end
        end
    end
})

lia.command.add("beclass", {
    adminOnly = false,
    desc = "Changes your current class to the specified class.",
    syntax = "[string class]",
    onRun = function(client, arguments)
        local className = table.concat(arguments, " ")
        local character = client:getChar()
        if not IsValid(client) or not character then
            client:notifyLocalized("illegalAccess")
            return
        end

        local classID = tonumber(className) or lia.class.retrieveClass(className)
        local classData = lia.class.get(classID)
        if classData and lia.class.canBe(client, classID) then
            if character:joinClass(classID) then
                client:notifyLocalized("becomeClass", L(classData.name))
            else
                client:notifyLocalized("becomeClassFail", L(classData.name))
            end
        else
            client:notifyLocalized("invalidClass")
        end
    end
})

lia.command.add("setclass", {
    adminOnly = true,
    privilege = "Manage Classes",
    desc = "Sets the specified player's class, bypassing requirements.",
    syntax = "[string charname] [string class]",
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        end

        local className = table.concat(arguments, " ", 2)
        local classID = lia.class.retrieveClass(className)
        local classData = lia.class.list[classID]
        if classData then
            if target:Team() == classData.faction then
                target:getChar():joinClass(classID, true)
                target:notifyLocalized("classSet", L(classData.name), client:GetName())
                if client ~= target then client:notifyLocalized("classSetOther", target:GetName(), L(classData.name)) end
                hook.Run("PlayerLoadout", target)
            else
                client:notifyLocalized("classFactionMismatch")
            end
        else
            client:notifyLocalized("invalidClass")
        end
    end
})

lia.command.add("classwhitelist", {
    adminOnly = true,
    privilege = "Manage Whitelists",
    desc = "Grants the specified player whitelist access to a class.",
    syntax = "[string name] [string class]",
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        local classID = lia.class.retrieveClass(table.concat(arguments, " ", 2))
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        elseif not classID or not lia.class.hasWhitelist(classID) then
            client:notifyLocalized("invalidClass")
            return
        end

        local classData = lia.class.list[classID]
        if target:Team() ~= classData.faction then
            client:notifyLocalized("whitelistFactionMismatch")
        elseif target:hasClassWhitelist(classID) then
            client:notifyLocalized("alreadyWhitelisted")
        else
            target:classWhitelist(classID)
            client:notifyLocalized("whitelistedSuccess")
            target:notifyLocalized("classAssigned", L(classData.name))
        end
    end
})

lia.command.add("classunwhitelist", {
    adminOnly = true,
    privilege = "Manage Classes",
    desc = "Revokes the specified player's whitelist access to a class.",
    syntax = "[string name] [string class]",
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        local classID = lia.class.retrieveClass(table.concat(arguments, " ", 2))
        if not target or not IsValid(target) then
            client:notifyLocalized("targetNotFound")
            return
        elseif not classID or not lia.class.hasWhitelist(classID) then
            client:notifyLocalized("invalidClass")
            return
        end

        local classData = lia.class.list[classID]
        if target:Team() ~= classData.faction then
            client:notifyLocalized("whitelistFactionMismatch")
        elseif not target:hasClassWhitelist(classID) then
            client:notifyLocalized("notWhitelisted")
        else
            target:classUnWhitelist(classID)
            client:notifyLocalized("unwhitelistedSuccess")
            target:notifyLocalized("classUnassigned", L(classData.name))
        end
    end
})
