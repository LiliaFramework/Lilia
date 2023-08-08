lia.currency = lia.currency or {}
lia.currency.plural = lia.currency.plural or lia.currency.PluralDefaultCurrency
lia.currency.singular = lia.currency.singular or lia.currency.SingularDefaultCurrency
lia.currency.symbol = lia.currency.symbol or lia.currency.DefaultCurrencySymbol
lia.currency.SingularDefaultCurrency = "Dollar"
lia.currency.PluralDefaultCurrency = "Dollars"
lia.currency.DefaultCurrencySymbol = "$"

function lia.currency.set(symbol, singular, plural)
	lia.currency.symbol = symbol
	lia.currency.singular = singular
	lia.currency.plural = plural
end

function lia.currency.get(amount)
	return lia.currency.symbol .. (amount == 1 and ("1 " .. lia.currency.singular) or (amount .. " " .. lia.currency.plural))
end

function lia.currency.spawn(pos, amount, angle)
	if not pos then
		print("[Lilia] Can't create currency entity: Invalid Position")
	elseif not amount or amount < 0 then
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
	if moneyEntity and moneyEntity:IsValid() then
		local amount = moneyEntity:getAmount()
		client:getChar():giveMoney(amount)
		client:notifyLocalized("moneyTaken", lia.currency.get(amount))
	end
end