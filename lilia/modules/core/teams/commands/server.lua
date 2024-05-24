lia.command.add("classwhitelist", {
    adminOnly = true,
    privilege = "Manage Whitelists",
    syntax = "<string name> <string class>",
    onRun = function(client, arguments)
        local target = lia.command.findPlayer(client, arguments[1])
        if not IsValid(target) or not target:getChar() then
            client:notifyLocalized("illegalAccess")
            return
        end

        local class = lia.class.retrieveClass(table.concat(arguments, " ", 2))
        if not class or not isnumber(class) then
            client:notifyLocalized("invalid", L("class", client))
            return
        end

        local classTable = lia.class.list[class]
        local wl = target:getChar():getData("whitelist", {})
        if target:Team() ~= classTable.faction then
            client:notify("Couldn't be whitelisted outside of the faction.")
            return false
        end

        if wl[class] then
            client:notify("Already whitelisted.")
            return false
        end

        wl[class] = true
        target:getChar():setData("whitelist", wl)
        client:notify("Whitelisted properly.")
        target:notify(string.format("Class '%s' have been assigned to your current character.", classTable.name))
    end
})

lia.command.add("plytransfer", {
    adminOnly = true,
    syntax = "<string name> <string faction>",
    privilege = "Manage Transfers",
    onRun = function(client, arguments)
        local target = lia.command.findPlayer(client, arguments[1])
        local name = table.concat(arguments, " ", 2)
        if IsValid(target) and target:getChar() then
            local faction = lia.faction.teams[name]
            if not faction then
                for _, v in pairs(lia.faction.indices) do
                    if lia.util.stringMatches(L(v.name, client), name) then
                        faction = v
                        break
                    end
                end
            end

            if faction then
                if hook.Run("CanCharBeTransfered", target:getChar(), faction, target:Team()) == false then return end
                target:getChar().vars.faction = faction.uniqueID
                target:getChar():setFaction(faction.index)
                hook.Run("OnTransferred", target)
                if faction.onTransfered then faction:onTransfered(target) end
                client:notify("You have transferred " .. target:Name() .. " to " .. faction.name)
                target:notify("You have been transferred to " .. faction.name .. " by " .. client:Name())
            else
                return "@invalidFaction"
            end
        end
    end,
    alias = {"charsetfaction"}
})

lia.command.add("plywhitelist", {
    adminOnly = true,
    privilege = "Manage Whitelists",
    syntax = "<string name> <string faction>",
    onRun = function(client, arguments)
        local target = lia.command.findPlayer(client, arguments[1])
        if IsValid(target) then
            local faction = lia.command.findFaction(client, table.concat(arguments, " ", 2))
            if faction and target:setWhitelisted(faction.index, true) then
                for _, v in ipairs(player.GetAll()) do
                    v:notifyLocalized("whitelist", client:Name(), target:Name(), L(faction.name, v))
                end
            end
        end
    end
})

lia.command.add("plyunwhitelist", {
    adminOnly = true,
    privilege = "Manage Whitelists",
    syntax = "<string name> <string faction>",
    onRun = function(client, arguments)
        local target = lia.command.findPlayer(client, arguments[1])
        if IsValid(target) then
            local faction = lia.command.findFaction(client, table.concat(arguments, " ", 2))
            if faction and target:setWhitelisted(faction.index, false) then
                for _, v in ipairs(player.GetAll()) do
                    v:notifyLocalized("unwhitelist", client:Name(), target:Name(), L(faction.name, v))
                end
            end
        end
    end
})

lia.command.add("beclass", {
    adminOnly = false,
    syntax = "<string class>",
    onRun = function(client, arguments)
        local class = table.concat(arguments, " ")
        local character = client:getChar()
        if IsValid(client) and character then
            local num = isnumber(tonumber(class)) and tonumber(class) or -1
            if lia.class.list[num] then
                local v = lia.class.list[num]
                if character:joinClass(num) then
                    client:notifyLocalized("becomeClass", L(v.name, client))
                    return
                else
                    client:notifyLocalized("becomeClassFail", L(v.name, client))
                    return
                end
            else
                for k, v in ipairs(lia.class.list) do
                    if lia.util.stringMatches(v.uniqueID, class) or lia.util.stringMatches(L(v.name, client), class) then
                        if character:joinClass(k) then
                            client:notifyLocalized("becomeClass", L(v.name, client))
                            return
                        else
                            client:notifyLocalized("becomeClassFail", L(v.name, client))
                            return
                        end
                    end
                end
            end

            client:notifyLocalized("invalid", L("class", client))
        else
            client:notifyLocalized("illegalAccess")
        end
    end
})

lia.command.add("setclass", {
    adminOnly = true,
    privilege = "Manage Classes",
    syntax = "<string target> <string class>",
    onRun = function(client, arguments)
        local target = lia.command.findPlayer(client, arguments[1])
        if target and target:getChar() then
            local character = target:getChar()
            local classFound
            if lia.class.list[name] then classFound = lia.class.list[name] end
            if not classFound then
                for _, v in ipairs(lia.class.list) do
                    if lia.util.stringMatches(L(v.name, client), arguments[2]) then
                        classFound = v
                        break
                    end
                end
            end

            if classFound then
                character:joinClass(classFound.index, true)
                target:notify("Your class was set to " .. classFound.name .. (client ~= target and "by " .. client:GetName() or "") .. ".")
                if client ~= target then client:notify("You set " .. target:GetName() .. "'s class to " .. classFound.name .. ".") end
            else
                client:notify("Invalid class.")
            end
        end
    end,
})

lia.command.add("classunwhitelist", {
    adminOnly = true,
    privilege = "Manage Classes",
    syntax = "<string name> <string class>",
    onRun = function(client, arguments)
        local target = lia.command.findPlayer(client, arguments[1])
        if not IsValid(target) or not target:getChar() then
            client:notifyLocalized("illegalAccess")
            return
        end

        local class = lia.class.retrieveClass(table.concat(arguments, " ", 2))
        if not class then
            client:notifyLocalized("invalid", L("class", client))
            return
        end

        local classTable = lia.class.list[class]
        local wl = target:getChar():getData("whitelist", {})
        if target:Team() ~= classTable.faction then
            client:notify("Couldn't be whitelisted outside of the faction.")
            return false
        end

        if not wl[class] then
            client:notify("Not whitelisted.")
            return false
        end

        wl[class] = false
        target:getChar():setData("whitelist", wl)
        client:notify("Unwhitelisted properly.")
        target:notify(string.format("Class '%s' have been unassigned from your current character.", classTable.name))
    end
})

lia.command.add("factionlist", {
    adminOnly = false,
    syntax = "<string text>",
    onRun = function(client)
        for _, v in ipairs(lia.faction.indices) do
            client:ChatNotify("NAME: " .. v.name .. " ID: " .. v.uniqueID)
        end
    end
})
