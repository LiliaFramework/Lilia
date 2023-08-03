local GM = GM or Gamemode or gamemode or {}

function GM:OnPickupMoney(client, moneyEntity)
    if not lia.config.CentsCompatibility then return end

    if moneyEntity and moneyEntity:IsValid() then
        local amount = moneyEntity:getAmount()
        client:getChar():giveMoney(amount)
        client:notifyLocalized("moneyTaken", lia.currency.get(amount / 1))
    end
end

function MODULE:InitializedModules()
    if not lia.config.CentsCompatibility then return end

    lia.command.list.dropmoney.onRun = function(client, arguments)
        local amount = tonumber(arguments[1])
        if not amount or not isnumber(amount) or amount < 0 then return "@invalidArg", 1 end
        amount = math.Round(amount)
        if not client:getChar():hasMoney(amount) then return end
        client:getChar():takeMoney(amount)
        local money = lia.currency.spawn(client:getItemDropPos(), amount)
        money.client = client
        money.charID = client:getChar():getID()
        client:doGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GMOD_GESTURE_ITEM_PLACE, true)
    end

    lia.command.list.charsetmoney.onRun = function(client, arguments)
        local amount = tonumber(arguments[2])
        if not amount or not isnumber(amount) or amount < 0 then return "@invalidArg", 2 end
        local target = lia.command.findPlayer(client, arguments[1])

        if IsValid(target) then
            local char = target:getChar()

            if char and amount then
                amount = math.Round(amount)
                char:setMoney(amount)
                client:notifyLocalized("setMoney", target:Name(), lia.currency.get(amount / 1))
            end
        end

        lia.command.list.givemoney.onRun = function(client, arguments)
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
            end
        end
    end
end