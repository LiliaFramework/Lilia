lia.currency = lia.currency or {}
lia.currency.symbol = lia.currency.symbol or "$"
lia.currency.singular = lia.currency.singular or "dollar"
lia.currency.plural = lia.currency.plural or "dollars"

function lia.currency.set(symbol, singular, plural)
	lia.currency.symbol = symbol
	lia.currency.singular = singular
	lia.currency.plural = plural
end

function lia.currency.get(amount)
	return lia.currency.symbol .. (amount == 1 and ("1 " .. lia.currency.singular) or (amount .. " " ..lia.currency.plural))
end

function lia.currency.spawn(pos, amount, angle)
	if (!pos) then
		print("[Lilia] Can't create currency entity: Invalid Position")
	elseif (!amount or amount < 0) then
		print("[Lilia] Can't create currency entity: Invalid Amount of money")
	else
		local money = ents.Create("lia_money")
		money:SetPos(pos)
		money:setAmount(math.Round(math.abs(amount)))
		money:SetAngles(angle or Angle(0, 0, 0))
		money:Spawn()
		money:Activate()

		return money
	end
end

function GM:OnPickupMoney(client, moneyEntity)
	if (moneyEntity and moneyEntity:IsValid()) then
		local amount = moneyEntity:getAmount()

		client:getChar():giveMoney(amount)
		client:notifyLocalized("moneyTaken", lia.currency.get(amount))
	end
end


local charMeta = lia.meta.character

function charMeta:hasMoney(amount)
	if (amount < 0) then
		print("Negative Money Check Received.")	
	end

	return self:getMoney() >= amount
end

function charMeta:giveMoney(amount, takingMoney)
	if (!takingMoney) then
		lia.log.add(self:getPlayer(), "money", amount)
	end
		
	self:setMoney(self:getMoney() + amount)

	return true
end

function charMeta:takeMoney(amount)
	lia.log.add(self:getPlayer(), "money", -amount)

	amount = math.abs(amount)
	self:giveMoney(-amount, true)

	return true
end
