-- @type command card - Draw Card Command
-- @typeCommentStart
-- Draws a random card from a deck of cards.
-- @typeCommentEnd
-- @classmod Commands
-- @realm server
-- @usageStart
-- /card - Draw a random card.
-- @usageEnd
lia.command.add("card", {
    syntax = "<none>",
    onRun = function(client, arguments)
        local inventory = client:getChar():getInv()

        if not inventory:hasItem("carddeck") then
            client:notify("You do not have a deck of cards.")

            return
        end

        local cards = {"1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "Ace", "Queen", "King", "Jack"}

        local family = {"Spades", "Hearts", "Diamonds", "Clubs"}

        local msg = "draws the " .. table.Random(cards) .. " of " .. table.Random(family)
        lia.chat.send(client, "rolld", msg)
    end
})

-- @type command fallover - Fall Over Command
-- @typeCommentStart
-- Makes the player fall over as a ragdoll for a specified amount of time.
-- @typeCommentEnd
-- @classmod Commands
-- @realm server
-- @usageStart
-- /fallover [number time] - Make the player fall over as a ragdoll.
-- @usageEnd
lia.command.add("fallover", {
    syntax = "[number time]",
    onRun = function(client, arguments)
        if client:InVehicle() then
            client:notify("You cannot use this as you are in a vehicle!")

            return
        end

        if client:IsFrozen() then return end
        if not client:Alive() then return end
        local time = tonumber(arguments[1])

        if not isnumber(time) then
            time = 5
        end

        if time > 0 then
            time = math.Clamp(time, 1, 60)
        else
            time = nil
        end

        if not IsValid(client.liaRagdoll) then
            client:setRagdolled(true, time)
        end
    end
})

-- @type command roll - Roll Command
-- @typeCommentStart
-- Rolls a random number between 0 and a specified maximum value.
-- @typeCommentEnd
-- @classmod Commands
-- @realm server
-- @usageStart
-- /roll [number maximum] - Roll a random number.
-- @usageEnd
lia.command.add("roll", {
    syntax = "[number maximum]",
    onRun = function(client, arguments)
        lia.chat.send(client, "roll", math.random(0, math.min(tonumber(arguments[1]) or 100, 100)))
    end
})

-- @type command chardesc - Change Character Description Command
-- @typeCommentStart
-- Changes the description of the character.
-- @typeCommentEnd
-- @classmod Commands
-- @realm server
-- @usageStart
-- /chardesc [string desc] - Change the description of your character.
-- @usageEnd
lia.command.add("chardesc", {
    syntax = "<string desc>",
    onRun = function(client, arguments)
        arguments = table.concat(arguments, " ")

        if not arguments:find("%S") then
            return client:requestString("@chgDesc", "@chgDescDesc", function(text)
                lia.command.run(client, "chardesc", {text})
            end, client:getChar():getDesc())
        end

        local info = lia.char.vars.desc
        local result, fault, count = info.onValidate(arguments)
        if result == false then return "@" .. fault, count end
        client:getChar():setDesc(arguments)

        return "@descChanged"
    end
})

-- @type command beclass - Become Class Command
-- @typeCommentStart
-- Allows the player to become a specific class.
-- @typeCommentEnd
-- @classmod Commands
-- @realm server
-- @usageStart
-- /beclass [string class] - Become a specific class.
-- @usageEnd
lia.command.add("beclass", {
    syntax = "<string class>",
    onRun = function(client, arguments)
        local class = table.concat(arguments, " ")
        local char = client:getChar()

        if IsValid(client) and char then
            local num = isnumber(tonumber(class)) and tonumber(class) or -1

            if lia.class.list[num] then
                local v = lia.class.list[num]

                if char:joinClass(num) then
                    client:notifyLocalized("becomeClass", L(v.name, client))

                    return
                else
                    client:notifyLocalized("becomeClassFail", L(v.name, client))

                    return
                end
            else
                for k, v in ipairs(lia.class.list) do
                    if lia.util.stringMatches(v.uniqueID, class) or lia.util.stringMatches(L(v.name, client), class) then
                        if char:joinClass(k) then
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

-- @type command chargestup - Character Get Up Command
-- @typeCommentStart
-- Allows the character to get up from a ragdoll state.
-- @typeCommentEnd
-- @classmod Commands
-- @realm server
-- @usageStart
-- /chargetup - Get up from a ragdoll state.
-- @usageEnd
lia.command.add("chargetup", {
    onRun = function(client, arguments)
        local entity = client.liaRagdoll

        if IsValid(entity) and entity.liaGrace and entity.liaGrace < CurTime() and entity:GetVelocity():Length2D() < 8 and not entity.liaWakingUp then
            entity.liaWakingUp = true

            client:setAction("@gettingUp", 5, function()
                if not IsValid(entity) then return end
                entity:Remove()
            end)
        end
    end
})

-- @type command givemoney - Give Money Command
-- @typeCommentStart
-- Gives a specified amount of money to another player.
-- @typeCommentEnd
-- @classmod Commands
-- @realm server
-- @usageStart
-- /givemoney <number amount> - Give money to another player.
-- @usageEnd
lia.command.add("givemoney", {
    syntax = "<number amount>",
    onRun = function(client, arguments)
        local number = tonumber(arguments[1])
        number = number or 0
        local amount = math.floor(number)
        if not amount or not isnumber(amount) or amount <= 0 then return L("invalidArg", client, 1) end
        local data = {}
        data.start = client:GetShootPos()
        data.endpos = data.start + client:GetAimVector() * 96
        data.filter = client
        local target = util.TraceLine(data).Entity

        if IsValid(target) and target:IsPlayer() and target:getChar() then
            amount = math.Round(amount)
            if not client:getChar():hasMoney(amount) then return end
            target:getChar():giveMoney(amount)
            client:getChar():takeMoney(amount)
            target:notifyLocalized("moneyTaken", lia.currency.get(amount))
            client:notifyLocalized("moneyGiven", lia.currency.get(amount))
            client:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GMOD_GESTURE_ITEM_PLACE, true)
        else
            client:notify("You need to be looking at someone!")
        end
    end
})

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

lia.command.add("factionbroadcast", {
    syntax = "<string factions> <string text>",
    onRun = function(client, arguments)
        if not client:getChar() or not client:getChar():hasFlags("B") then return "Your character does not have the required flags for this command." end
        if not arguments[1] then return "Invalid argument (#1)" end
        if not arguments[2] then return "Invalid argument (#2)" end
        local message = table.concat(arguments, " ", 2)
        local factionList = {}
        local factionListSimple = {}

        for k, v in pairs(string.Explode(",", arguments[1])) do
            local foundFaction
            local foundID
            local multiFind

            for m, n in pairs(lia.faction.indices) do
                if string.lower(n.uniqueID) == string.lower(v) then
                    foundFaction = m
                    foundID = n.name
                    multiFind = false
                    break
                elseif string.lower(n.uniqueID):find(string.lower(v), 1, true) then
                    if foundFaction then
                        multiFind = true
                    end

                    foundID = n.name
                    foundFaction = m
                end
            end

            if foundFaction == "staff" or foundFaction == FACTION_staff then return "No." end
            if not foundFaction then return "Cannot find faction '" .. v .. "' - use the unique IDs of factions (example: okw, okh, citizen, etc)" end
            if multiFind then return "Ambiguous entry (multiple possible factions) - '" .. v .. "'" end
            factionList[foundFaction] = foundID
            factionListSimple[#factionListSimple + 1] = foundID
        end

        if table.Count(factionList) == 0 then return "No valid factions found" end

        for k, v in pairs(player.GetAll()) do
            if v == client or (v:getChar() and factionList[v:getChar():getFaction()]) then
                v:SendMessage(Color(200, 200, 100), "[Local Broadcast]", Color(255, 255, 255), ": ", Color(180, 180, 100), client:Nick(), Color(255, 255, 255), ": ", message)
                v:SendMessage(Color(200, 200, 100), "[Local Broadcast]", Color(255, 255, 255), ": This message was sent to ", table.concat(factionListSimple, ", "), ".")
            end
        end

        client:notify("Broadcast sent.")
    end
})
