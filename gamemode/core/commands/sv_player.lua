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

-------------------------------------------------------------------------------------------------------------------------
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

-------------------------------------------------------------------------------------------------------------------------
lia.command.add("roll", {
    syntax = "[number maximum]",
    onRun = function(client, arguments)
        lia.chat.send(client, "roll", math.random(0, math.min(tonumber(arguments[1]) or 100, 100)))
    end
})

-------------------------------------------------------------------------------------------------------------------------
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

-------------------------------------------------------------------------------------------------------------------------
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

-------------------------------------------------------------------------------------------------------------------------
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

-------------------------------------------------------------------------------------------------------------------------
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