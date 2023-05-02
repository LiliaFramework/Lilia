-------------------------------------------------------------------------------------------------------------------------
lia.command.add("charsetdesc", {
    syntax = "<string name> <string desc>",
    onRun = function(client, arguments)
        local uniqueID = client:GetUserGroup()

        if not UserGroups.modRanks[uniqueID] then
            client:notify("Your rank is not high enough to use this command.")

            return false
        end

        local target = lia.command.findPlayer(client, arguments[1])
        if not IsValid(target) then return end
        if not target:getChar() then return "No character loaded" end
        local arg = table.concat(arguments, " ", 2)

        if not arg:find("%S") then
            return client:requestString("Change " .. target:Nick() .. "'s Description", "Enter new description", function(text)
                lia.command.run(client, "charsetdesc", {arguments[1], text})
            end, target:getChar():getDesc())
        end

        local info = lia.char.vars.desc
        local result, fault, count = info.onValidate(arg)
        if result == false then return "@" .. fault, count end
        target:getChar():setDesc(arg)

        return "Successfully changed " .. target:Nick() .. "'s description"
    end
})

-------------------------------------------------------------------------------------------------------------------------
lia.command.add("charsetattrib", {
    syntax = "<string charname> <string attribname> <number level>",
    onRun = function(client, arguments)
        local uniqueID = client:GetUserGroup()

        if not UserGroups.superRanks[uniqueID] then
            client:notify("Your rank is not high enough to use this command.")

            return false
        end

        local attribName = arguments[2]
        if not attribName then return L("invalidArg", client, 2) end
        local attribNumber = arguments[3]
        attribNumber = tonumber(attribNumber)
        if not attribNumber or not isnumber(attribNumber) then return L("invalidArg", client, 3) end
        local target = lia.command.findPlayer(client, arguments[1])

        if IsValid(target) then
            local char = target:getChar()

            if char then
                for k, v in pairs(lia.attribs.list) do
                    if lia.util.stringMatches(L(v.name, client), attribName) or lia.util.stringMatches(k, attribName) then
                        char:setAttrib(k, math.abs(attribNumber))
                        client:notifyLocalized("attribSet", target:Name(), L(v.name, client), math.abs(attribNumber))

                        return
                    end
                end
            end
        end
    end
})

-------------------------------------------------------------------------------------------------------------------------
lia.command.add("charaddattrib", {
    syntax = "<string charname> <string attribname> <number level>",
    onRun = function(client, arguments)
        local uniqueID = client:GetUserGroup()

        if not UserGroups.superRanks[uniqueID] then
            client:notify("Your rank is not high enough to use this command.")

            return false
        end

        local attribName = arguments[2]
        if not attribName then return L("invalidArg", client, 2) end
        local attribNumber = arguments[3]
        attribNumber = tonumber(attribNumber)
        if not attribNumber or not isnumber(attribNumber) then return L("invalidArg", client, 3) end
        local target = lia.command.findPlayer(client, arguments[1])

        if IsValid(target) then
            local char = target:getChar()

            if char then
                for k, v in pairs(lia.attribs.list) do
                    if lia.util.stringMatches(L(v.name, client), attribName) or lia.util.stringMatches(k, attribName) then
                        char:updateAttrib(k, math.abs(attribNumber))
                        client:notifyLocalized("attribUpdate", target:Name(), L(v.name, client), math.abs(attribNumber))

                        return
                    end
                end
            end
        end
    end
})

-------------------------------------------------------------------------------------------------------------------------
lia.command.add("plytransfer", {
    syntax = "<string name> <string faction>",
    onRun = function(client, arguments)
        local uniqueID = client:GetUserGroup()

        if not UserGroups.trustedRanks[uniqueID] then
            client:notify("Your rank is not high enough to use this command.")

            return false
        end

        local target = lia.command.findPlayer(client, arguments[1])
        local name = table.concat(arguments, " ", 2)
        if IsValid(target) and target == client and uniqueID == "plat" then return "Your rank cannot target itself with these commands." end

        if IsValid(target) and target:getChar() then
            local faction = lia.faction.teams[name]

            if not faction then
                for k, v in pairs(lia.faction.indices) do
                    if lia.util.stringMatches(L(v.name, client), name) then
                        faction = v
                        break
                    end
                end
            end

            if faction then
                target:getChar().vars.faction = faction.uniqueID
                target:getChar():setFaction(faction.index)

                if faction.onTransfered then
                    faction:onTransfered(target)
                end

                client:notify("You have transferred " .. target:Name() .. " to " .. faction.name)
                target:notify("You have been transferred to " .. faction.name .. " by " .. client:Name())
            else
                return "@invalidFaction"
            end
        end
    end
})

-------------------------------------------------------------------------------------------------------------------------
lia.command.add("charsetname", {
    syntax = "<string name> [string newName]",
    onRun = function(client, arguments)
        local uniqueID = client:GetUserGroup()

        if not UserGroups.trustedRanks[uniqueID] then
            client:notify("Your rank is not high enough to use this command.")

            return false
        end

        local target = lia.command.findPlayer(client, arguments[1])
        if IsValid(target) and target == client and uniqueID == "plat" then return "Your rank cannot target itself with these commands." end

        if IsValid(target) and not arguments[2] then
            return client:requestString("@chgName", "@chgNameDesc", function(text)
                lia.command.run(client, "charsetname", {target:Name(), text})
            end, target:Name())
        end

        table.remove(arguments, 1)
        local targetName = table.concat(arguments, " ")

        if IsValid(target) and target:getChar() then
            client:notifyLocalized("cChangeName", client:Name(), target:Name(), targetName)
            target:getChar():setName(targetName:gsub("#", "#?"))
        end
    end
})

-------------------------------------------------------------------------------------------------------------------------
lia.command.add("charsetmodel", {
    syntax = "<string name> <string model>",
    onRun = function(client, arguments)
        local uniqueID = client:GetUserGroup()

        if not UserGroups.trustedRanks[uniqueID] then
            client:notify("Your rank is not high enough to use this command.")

            return false
        end

        if not arguments[2] then return L("invalidArg", client, 2) end
        local target = lia.command.findPlayer(client, arguments[1])
        if IsValid(target) and target == client and uniqueID == "plat" then return "Your rank cannot target itself with these commands." end

        if IsValid(target) and target:getChar() then
            target:getChar():setModel(arguments[2])
            target:SetupHands()
            client:notifyLocalized("cChangeModel", client:Name(), target:Name(), arguments[2])
        end
    end
})

-------------------------------------------------------------------------------------------------------------------------
lia.command.add("charsetskin", {
    syntax = "<string name> [number skin]",
    onRun = function(client, arguments)
        local uniqueID = client:GetUserGroup()

        if not UserGroups.trustedRanks[uniqueID] then
            client:notify("Your rank is not high enough to use this command.")

            return false
        end

        local skin = tonumber(arguments[2])
        local target = lia.command.findPlayer(client, arguments[1])
        if IsValid(target) and target == client and uniqueID == "plat" then return "Your rank cannot target itself with these commands." end

        if IsValid(target) and target:getChar() then
            target:getChar():setData("skin", skin)
            target:SetSkin(skin or 0)
            client:notifyLocalized("cChangeSkin", client:Name(), target:Name(), skin or 0)
        end
    end
})

-------------------------------------------------------------------------------------------------------------------------
lia.command.add("charsetbodygroup", {
    syntax = "<string name> <string bodyGroup> [number value]",
    onRun = function(client, arguments)
        local uniqueID = client:GetUserGroup()

        if not UserGroups.trustedRanks[uniqueID] then
            client:notify("Your rank is not high enough to use this command.")

            return false
        end

        local value = tonumber(arguments[3])
        local target = lia.command.findPlayer(client, arguments[1])
        if IsValid(target) and target == client and uniqueID == "plat" then return "Your rank cannot target itself with these commands." end

        if IsValid(target) and target:getChar() then
            local index = target:FindBodygroupByName(arguments[2])

            if index > -1 then
                if value and value < 1 then
                    value = nil
                end

                local groups = target:getChar():getData("groups", {})
                groups[index] = value
                target:getChar():setData("groups", groups)
                target:SetBodygroup(index, value or 0)
                client:notifyLocalized("cChangeGroups", client:Name(), target:Name(), arguments[2], value or 0)
            else
                return "@invalidArg", 2
            end
        end
    end
})

-------------------------------------------------------------------------------------------------------------------------
lia.command.add("charban", {
    syntax = "<string name>",
    onRun = function(client, arguments)
        local uniqueID = client:GetUserGroup()

        if not UserGroups.uaRanks[uniqueID] then
            client:notify("Your rank is not high enough to use this command.")

            return false
        end

        local target = lia.command.findPlayer(client, arguments[1])

        if IsValid(target) then
            local char = target:getChar()

            if char then
                client:notifyLocalized("charBan", client:Name(), target:Name())
                char:setData("banned", true)

                char:setData("charBanInfo", {
                    name = client.SteamName and client:SteamName() or client:Nick(),
                    steamID = client:SteamID(),
                    rank = client:GetUserGroup()
                })

                char:save()
                char:kick()
            end
        end
    end
})

-------------------------------------------------------------------------------------------------------------------------
lia.command.add("charselectskin", {
    syntax = "[number skin]",
    onRun = function(client, arguments)
        local uniqueID = client:GetUserGroup()
        local skin = tonumber(arguments[1])
        local target = client

        if not UserGroups.uaRanks[uniqueID] then
            client:notify("Your rank is not high enough to use this command.")

            return false
        end

        if IsValid(target) and target:getChar() then
            target:getChar():setData("skin", skin)
            target:SetSkin(skin or 0)
            client:notifyLocalized("cChangeSkin", nil, client:Name(), target:Name(), skin or 0)
        end
    end
})

-------------------------------------------------------------------------------------------------------------------------
lia.command.add("charselectbodygroup", {
    syntax = "<string targer> <string bodyGroup> [number value]",
    onRun = function(client, arguments)
        local uniqueID = client:GetUserGroup()
        local value = tonumber(arguments[2])
        local target = lia.command.findPlayer(client, arguments[1])

        if not UserGroups.uaRanks[uniqueID] then
            client:notify("Your rank is not high enough to use this command.")

            return false
        end

        if not arguments[1] then
            client:notify("No bodygroup specified.")

            return false
        end

        if IsValid(client) and client:getChar() then
            local index = client:FindBodygroupByName(arguments[1])

            if index > -1 then
                if value and value < 1 then
                    value = nil
                end

                local groups = client:getChar():getData("groups", {})
                groups[index] = value
                client:getChar():setData("groups", groups)
                client:SetBodygroup(index, value or 0)
                client:notify("Bodygroup changed successfully")
                client:notifyLocalized("cChangeGroups", nil, client:Name(), target:Name(), arguments[2], value or 0)
            else
                return "@invalidArg", 2
            end
        end
    end
})

-------------------------------------------------------------------------------------------------------------------------
lia.command.add("charforceunequip", {
    syntax = "<string name>",
    onRun = function(client, arguments)
        local uniqueID = client:GetUserGroup()
        local target = lia.command.findPlayer(client, arguments[1])

        if not UserGroups.uaRanks[uniqueID] then
            client:notify("Your rank is not high enough to use this command.")

            return false
        end

        if IsValid(target) and target:getChar() then
            local inventory = target:getChar():getInv()

            for k, v in pairs(inventory:getItems()) do
                if v:getData("equip") then
                    v:setData("equip", false)
                end
            end
        end
    end
})

-------------------------------------------------------------------------------------------------------------------------
lia.command.add("chargetmoney", {
    syntax = "<string name>",
    onRun = function(client, arguments)
        local uniqueID = client:GetUserGroup()

        if not UserGroups.modRanks[uniqueID] then
            client:notify("Your rank is not high enough to use this command.")

            return false
        end

        local target = lia.command.findPlayer(client, arguments[1])

        if IsValid(target) and target:getChar() then
            local char = target:getChar()
            client:notify(char:getMoney())
        else
            client:notify("Invalid Target")
        end
    end
})

-------------------------------------------------------------------------------------------------------------------------
lia.command.add("chargetmodel", {
    syntax = "<string name>",
    onRun = function(client, arguments)
        local uniqueID = client:GetUserGroup()

        if not UserGroups.modRanks[uniqueID] then
            client:notify("Your rank is not high enough to use this command.")

            return false
        end

        local target = lia.command.findPlayer(client, arguments[1])

        if IsValid(target) and target:getChar() then
            client:notify(target:GetModel())
        else
            client:notify("Invalid Target")
        end
    end
})

-------------------------------------------------------------------------------------------------------------------------
lia.command.add("checkallmoney", {
    syntax = "<string charname>",
    onRun = function(client, arguments)
        local uniqueID = client:GetUserGroup()

        if not UserGroups.uaRanks[uniqueID] then
            client:notify("Your rank is not high enough to use this command.")

            return false
        end

        for k, v in pairs(player.GetAll()) do
            if v:getChar() then
                client:ChatPrint(v:Name() .. " has " .. v:getChar():getMoney())
            end
        end
    end
})

-------------------------------------------------------------------------------------------------------------------------
lia.command.add("bringlostitems", {
    syntax = "",
    onRun = function(client, arguments)
        local uniqueID = client:GetUserGroup()

        if not UserGroups.uaRanks[uniqueID] then
            client:notify("Your rank is not high enough to use this command.")

            return false
        end

        for k, v in pairs(ents.FindInSphere(client:GetPos(), 500)) do
            if v:GetClass() == "lia_item" then
                v:SetPos(client:GetPos())
            end
        end
    end
})

-------------------------------------------------------------------------------------------------------------------------
lia.command.add("logs", {
    adminOnly = false,
    onRun = function(client, arguments)
        local uniqueID = client:GetUserGroup()

        if not UserGroups.modRanks[uniqueID] then
            client:notify("Your rank is not high enough to use this command.")

            return false
        end

        client:ConCommand("mlogs")
    end
})

-------------------------------------------------------------------------------------------------------------------------
lia.command.add("chargiveitem", {
    syntax = "<string name> <string item>",
    onRun = function(client, arguments)
        local rank = client:GetUserGroup()

        if not UserGroups.uaRanks[rank] then
            client:notify("Your rank is not high enough to use this command.")

            return false
        end

        if not arguments[2] then return L("invalidArg", client, 2) end
        local target = lia.command.findPlayer(client, arguments[1])

        if IsValid(target) and target:getChar() then
            local uniqueID = arguments[2]:lower()

            if not lia.item.list[uniqueID] then
                for k, v in SortedPairs(lia.item.list) do
                    if lia.util.stringMatches(v.name, uniqueID) then
                        uniqueID = k
                        break
                    end
                end
            end

            local inv = target:getChar():getInv()
            local succ, err = target:getChar():getInv():add(uniqueID)

            if succ then
                target:notifyLocalized("itemCreated")

                if target ~= client then
                    client:notifyLocalized("itemCreated")
                end
            else
                target:notify(tostring(succ))
                target:notify(tostring(err))
            end
        end
    end
})

-------------------------------------------------------------------------------------------------------------------------
lia.command.add("charsetmoney", {
    syntax = "<string target> <number amount>",
    onRun = function(client, arguments)
        local uniqueID = client:GetUserGroup()

        if not UserGroups.superRanks[uniqueID] then
            client:notify("Your rank is not high enough to use this command.")

            return false
        end

        local amount = tonumber(arguments[2])
        if not amount or not isnumber(amount) or amount < 0 then return "@invalidArg", 2 end
        local target = lia.command.findPlayer(client, arguments[1])

        if IsValid(target) then
            local char = target:getChar()

            if char and amount then
                amount = math.Round(amount)
                char:setMoney(amount)
                client:notifyLocalized("setMoney", target:Name(), lia.currency.get(amount))
            end
        end
    end
})

-------------------------------------------------------------------------------------------------------------------------
lia.command.add("getpos", {
    onRun = function(client, arguments)
        client:ChatPrint("MY POSITION: " .. tostring(client:GetPos()))
    end
})

-------------------------------------------------------------------------------------------------------------------------
lia.command.add("doorname", {
    onRun = function(client, arguments)
        local tr = util.TraceLine(util.GetPlayerTrace(client))

        if IsValid(tr.Entity) then
            print("I saw a " .. tr.Entity:GetName())
        end
    end
})

-------------------------------------------------------------------------------------------------------------------------
lia.command.add("factionlist", {
    syntax = "<string text>",
    onRun = function(client, arguments)
        for k, v in ipairs(lia.faction.indices) do
            client:ChatPrint("NAME: " .. v.name .. " ID: " .. v.uniqueID)
        end
    end
})