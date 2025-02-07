lia.command.add("plytransfer", {
    adminOnly = true,
    syntax = "[string name] [string faction]",
    privilege = "Manage Transfers",
    onRun = function(client, arguments)
        local target = lia.command.findPlayer(client, arguments[1])
        local name = table.concat(arguments, " ", 2)
        if IsValid(target) and target:getChar() then
            local faction = lia.faction.teams[name]
            if not faction then
                for _, v in pairs(lia.faction.indices) do
                    if lia.util.stringMatches(L(v.name), name) then
                        faction = v
                        break
                    end
                end
            end

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
    end,
    alias = {"charsetfaction"}
})

lia.command.add("plywhitelist", {
    adminOnly = true,
    privilege = "Manage Whitelists",
    syntax = "[string name] [string faction]",
    onRun = function(client, arguments)
        local target = lia.command.findPlayer(client, arguments[1])
        if IsValid(target) then
            local faction = lia.command.findFaction(client, table.concat(arguments, " ", 2))
            if faction and target:setWhitelisted(faction.index, true) then
                for _, v in player.Iterator() do
                    v:notifyLocalized("whitelist", client:Name(), target:Name(), L(faction.name, v))
                end
            end
        end
    end,
    alias = {"factionwhitelist"}
})

lia.command.add("plyunwhitelist", {
    adminOnly = true,
    privilege = "Manage Whitelists",
    syntax = "[string name] [string faction]",
    onRun = function(client, arguments)
        local target = lia.command.findPlayer(client, arguments[1])
        if IsValid(target) then
            local faction = lia.command.findFaction(client, table.concat(arguments, " ", 2))
            if faction and target:setWhitelisted(faction.index, false) then
                for _, v in player.Iterator() do
                    v:notifyLocalized("unwhitelist", client:Name(), target:Name(), L(faction.name, v))
                end
            end
        end
    end,
    alias = {"factionunwhitelist"}
})

lia.command.add("beclass", {
    adminOnly = false,
    syntax = "[string class]",
    onRun = function(client, arguments)
        local class = table.concat(arguments, " ")
        local character = client:getChar()
        if IsValid(client) and character then
            local num = tonumber(class) or lia.class.retrieveClass(class)
            if num then
                local v = lia.class.get(num)
                if v then
                    if lia.class.canBe(client, num) then
                        if character:joinClass(num) then
                            client:notifyLocalized("becomeClass", L(v.name))
                            return
                        else
                            client:notifyLocalized("becomeClassFail", L(v.name))
                            return
                        end
                    else
                        client:notifyLocalized("becomeClassFail", L(v.name))
                        return
                    end
                else
                    client:notifyLocalized("invalidClass")
                    return
                end
            else
                client:notifyLocalized("invalidClass")
                return
            end
        else
            client:notifyLocalized("illegalAccess")
        end
    end
})

lia.command.add("setclass", {
    adminOnly = true,
    privilege = "Manage Classes",
    syntax = "[string charname] [string class]",
    onRun = function(client, arguments)
        local target = lia.command.findPlayer(client, arguments[1])
        if target and target:getChar() then
            local character = target:getChar()
            local classFound
            local className = arguments[2]
            if lia.class.list[className] then
                classFound = lia.class.list[className]
            else
                for _, v in ipairs(lia.class.list) do
                    if lia.util.stringMatches(L(v.name), className) then
                        classFound = v
                        break
                    end
                end
            end

            if classFound then
                if classFound.faction == target:Team() then
                    character:joinClass(classFound.index, true)
                    target:notifyLocalized("classSet", L(classFound.name), client ~= target and client:GetName() or nil)
                    if client ~= target then client:notifyLocalized("classSetOther", target:GetName(), L(classFound.name)) end
                    hook.Run("PlayerLoadout", target)
                else
                    client:notifyLocalized("classFactionMismatch")
                end
            else
                client:notifyLocalized("invalidClass")
            end
        end
    end,
})

lia.command.add("classwhitelist", {
    adminOnly = true,
    privilege = "Manage Whitelists",
    syntax = "[string name] [string class]",
    onRun = function(client, arguments)
        local target = lia.command.findPlayer(client, arguments[1])
        if not IsValid(target) or not target:getChar() then
            client:notifyLocalized("illegalAccess")
            return
        end

        local class = lia.class.retrieveClass(table.concat(arguments, " ", 2))
        if not class or not isnumber(class) then
            client:notifyLocalized("invalidClass")
            return
        end

        if not lia.class.hasWhitelist(class) then
            client:notifyLocalized("noWhitelistNeeded")
            return false
        end

        local classTable = lia.class.list[class]
        if target:Team() ~= classTable.faction then
            client:notifyLocalized("whitelistFactionMismatch")
            return false
        end

        if target:hasClassWhitelist(class) then
            client:notifyLocalized("alreadyWhitelisted")
            return false
        end

        target:classWhitelist(class)
        client:notifyLocalized("whitelistedSuccess")
        target:notifyLocalized("classAssigned", L(classTable.name))
    end
})

lia.command.add("classunwhitelist", {
    adminOnly = true,
    privilege = "Manage Classes",
    syntax = "[string name] [string class]",
    onRun = function(client, arguments)
        local target = lia.command.findPlayer(client, arguments[1])
        if not IsValid(target) or not target:getChar() then
            client:notifyLocalized("illegalAccess")
            return
        end

        local class = lia.class.retrieveClass(table.concat(arguments, " ", 2))
        if not class then
            client:notifyLocalized("invalidClass")
            return
        end

        if not lia.class.hasWhitelist(class) then
            client:notifyLocalized("noWhitelistNeeded")
            return false
        end

        local classTable = lia.class.list[class]
        if target:Team() ~= classTable.faction then
            client:notifyLocalized("whitelistFactionMismatch")
            return false
        end

        if not target:hasClassWhitelist(class) then
            client:notifyLocalized("notWhitelisted")
            return false
        end

        target:classUnWhitelist(class)
        client:notifyLocalized("unwhitelistedSuccess")
        target:notifyLocalized("classUnassigned", L(classTable.name))
    end
})

lia.command.add("classlist", {
    adminOnly = false,
    onRun = function(client, arguments)
        local factionID = arguments[1]
        local classes = {}
        local function addClass(class)
            table.insert(classes, {
                name = L(class.name),
                desc = L(class.desc),
                faction = L(lia.faction.get(class.faction).name),
                isDefault = class.isDefault
            })
        end

        if factionID then
            local faction = lia.faction.teams[factionID]
            if not faction then
                for _, v in pairs(lia.faction.indices) do
                    if lia.util.stringMatches(L(v.name), factionID) then
                        faction = v
                        break
                    end
                end
            end

            if not faction then
                client:notifyLocalized("factionNotFound")
                for _, class in pairs(lia.class.list) do
                    addClass(class)
                end
            else
                for _, class in pairs(lia.class.list) do
                    if faction.uniqueID == lia.faction.get(class.faction).uniqueID then addClass(class) end
                end
            end
        else
            for _, class in pairs(lia.class.list) do
                addClass(class)
            end
        end

        net.Start("classlist")
        net.WriteTable(classes)
        net.Send(client)
    end,
    alias = {"classes"}
})

lia.command.add("factionlist", {
    adminOnly = false,
    onRun = function(client)
        local factions = {}
        local function addFaction(faction)
            table.insert(factions, {
                name = faction.name,
                desc = faction.desc,
                color = faction.color,
                isDefault = faction.isDefault
            })
        end

        for _, faction in pairs(lia.faction.indices) do
            addFaction(faction)
        end

        net.Start("factionlist")
        net.WriteTable(factions)
        net.Send(client)
    end,
    alias = {"factions"}
})