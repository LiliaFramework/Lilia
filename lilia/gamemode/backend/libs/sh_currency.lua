--------------------------------------------------------------------------------------------------------
lia.currency = lia.currency or {}
--------------------------------------------------------------------------------------------------------
lia.currency.symbol = lia.config.CurrencySymbol or "$"
--------------------------------------------------------------------------------------------------------
lia.currency.singular = lia.config.CurrencySingularName or "dollar"
--------------------------------------------------------------------------------------------------------
lia.currency.plural = lia.config.CurrencyPluralName or "dollars"
--------------------------------------------------------------------------------------------------------
function lia.currency.set(symbol, singular, plural)
    lia.config.CurrencySymbol = symbol
    lia.config.CurrencySingularName = singular
    lia.config.CurrencyPluralName = plural
end
--------------------------------------------------------------------------------------------------------
function lia.currency.get(amount)
    return lia.currency.symbol .. (amount == 1 and ("1 " .. lia.currency.singular) or (amount .. " " .. lia.currency.plural))
end
--------------------------------------------------------------------------------------------------------
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
--------------------------------------------------------------------------------------------------------
