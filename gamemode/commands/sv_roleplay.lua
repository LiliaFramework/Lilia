--------------------------------------------------------------------------------------------------------
lia.command.add(
    "roll",
    {
        adminOnly = false,
        privilege = "Default User Commands",
        onRun = function(client, arguments)
            lia.chat.send(client, "roll", math.random(0, 100))
        end
    }
)

--------------------------------------------------------------------------------------------------------
lia.command.add(
    "point",
    {
        adminOnly = false,
        privilege = "Default User Commands",
        syntax = "[number maximum]",
        onRun = function(client, arguments)
            local table = ents.FindInSphere(client:EyePos(), 200)
            local i = #table
            local pointing = client:GetEyeTraceNoCursor()
            ::GOTO_REVERSE::
            if table[i]:IsPlayer() then
                local trace = util.TraceLine{
                    start = client:EyePos(),
                    endpos = table[i]:EyePos(),
                    mask = MASK_SOLID_BRUSHONLY,
                }

                if not trace.Hit then
                    net.Start("Pointing")
                    net.WriteFloat(CurTime() + 10)
                    net.WriteVector(pointing.HitPos)
                    net.Send(table[i])
                end
            end

            i = i - 1
            if i ~= 0 then
                goto GOTO_REVERSE
            end
        end
    }
)

--------------------------------------------------------------------------------------------------------
lia.command.add(
    "chardesc",
    {
        adminOnly = false,
        privilege = "Default User Commands",
        syntax = "<string desc>",
        onRun = function(client, arguments)
            arguments = table.concat(arguments, " ")
            if not arguments:find("%S") then
                return client:requestString(
                    "@chgDesc",
                    "@chgDescDesc",
                    function(text)
                        lia.command.run(client, "chardesc", {text})
                    end, client:getChar():getDesc()
                )
            end

            local info = lia.char.vars.desc
            local result, fault, count = info.onValidate(arguments)
            if result == false then return "@" .. fault, count end
            client:getChar():setDesc(arguments)

            return "@descChanged"
        end
    }
)

--------------------------------------------------------------------------------------------------------
lia.command.add(
    "beclass",
    {
        adminOnly = false,
        privilege = "Default User Commands",
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
    }
)

--------------------------------------------------------------------------------------------------------
lia.command.add(
    "chargetup",
    {
        adminOnly = false,
        privilege = "Default User Commands",
        onRun = function(client, arguments)
            local entity = client.liaRagdoll
            if IsValid(entity) and entity.liaGrace and entity.liaGrace < CurTime() and entity:GetVelocity():Length2D() < 8 and not entity.liaWakingUp then
                entity.liaWakingUp = true
                client:setAction(
                    "@gettingUp",
                    5,
                    function()
                        if not IsValid(entity) then return end
                        entity:Remove()
                    end
                )
            end
        end
    }
)

--------------------------------------------------------------------------------------------------------
lia.command.add(
    "givemoney",
    {
        adminOnly = false,
        privilege = "Default User Commands",
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
    }
)

--------------------------------------------------------------------------------------------------------
lia.command.add(
    "bringlostitems",
    {
        adminOnly = false,
        privilege = "Default User Commands",
        onRun = function(client, arguments)
            for k, v in pairs(ents.FindInSphere(client:GetPos(), 500)) do
                if v:GetClass() == "lia_item" then
                    v:SetPos(client:GetPos())
                end
            end
        end
    }
)

--------------------------------------------------------------------------------------------------------
lia.command.add(
    "carddraw",
    {
        adminOnly = false,
        privilege = "Default User Commands",
        onRun = function(client, arguments)
            local cards = {"1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "Ace", "Queen", "King", "Jack"}
            local family = {"Spades", "Hearts", "Diamonds", "Clubs"}
            local msg = "draws the " .. table.Random(cards) .. " of " .. table.Random(family)
            lia.chat.send(client, "rolld", msg)
        end
    }
)

--------------------------------------------------------------------------------------------------------
lia.command.add(
    "fallover",
    {
        adminOnly = false,
        privilege = "Default User Commands",
        syntax = "[number time]",
        onRun = function(client, arguments)
            if client:IsFrozen() then
                client:notify("You cannot use this while frozen!")

                return
            elseif not client:Alive() then
                client:notify("You cannot use this while dead!")

                return
            elseif client:InVehicle() then
                client:notify("You cannot use this as you are in a vehicle!")

                return
            elseif client:GetMoveType() == MOVETYPE_NOCLIP then
                client:notify("You cannot use this while in noclip!")

                return
            end

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
    }
)

--------------------------------------------------------------------------------------------------------
lia.command.add(
    "factionlist",
    {
        adminOnly = false,
        privilege = "Default User Commands",
        syntax = "<string text>",
        onRun = function(client, arguments)
            for k, v in ipairs(lia.faction.indices) do
                client:ChatPrint("NAME: " .. v.name .. " ID: " .. v.uniqueID)
            end
        end
    }
)

--------------------------------------------------------------------------------------------------------
lia.command.add(
    "getpos",
    {
        adminOnly = false,
        privilege = "Default User Commands",
        onRun = function(client, arguments)
            client:ChatPrint("MY POSITION: " .. tostring(client:GetPos()))
        end
    }
)

--------------------------------------------------------------------------------------------------------
lia.command.add(
    "doorname",
    {
        adminOnly = false,
        privilege = "Default User Commands",
        onRun = function(client, arguments)
            local tr = util.TraceLine(util.GetPlayerTrace(client))
            if IsValid(tr.Entity) then
                client:ChatPrint("I saw a " .. tr.Entity:GetName())
            end
        end
    }
)

--------------------------------------------------------------------------------------------------------
if lia.config.FactionBroadcastEnabled then
    lia.command.add(
        "factionbroadcast",
        {
            adminOnly = false,
            privilege = "Default User Commands",
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
        }
    )
end

--------------------------------------------------------------------------------------------------------
if lia.config.AdvertisementEnabled then
    lia.command.add(
        "advertisement",
        {
            adminOnly = false,
            privilege = "Default User Commands",
            syntax = "<string factions> <string text>",
            onRun = function(client, arguments)
                if not arguments[1] then return "Invalid argument (#1)" end
                local message = table.concat(arguments, " ", 1)
                if not client.advertdelay then
                    client.advertdelay = 0
                end

                if CurTime() < client.advertdelay then
                    client:notify("This command is in cooldown!")

                    return
                else
                    if string.len(message) <= 250 then
                        if client:getChar():hasMoney(25) then
                            client.advertdelay = CurTime() + 60
                            client:getChar():takeMoney(25)
                            client:notify("25 " .. lia.currency.plural .. " have been deducted from your wallet for advertising.")
                            net.Start("advert_client")
                            net.WriteString(client:Nick())
                            net.WriteString(message)
                            net.Broadcast()
                        else
                            client:notify("You lack sufficient funds to make an advertisement.")

                            return
                        end
                    else
                        client:notify("This Advertisement is too big.")
                    end
                end
            end
        }
    )
end
--------------------------------------------------------------------------------------------------------