lia.currency = lia.currency or {}
lia.currency.symbol = lia.config.get("CurrencySymbol", "")
lia.currency.singular = L(lia.config.get("CurrencySingularName", "currencySingular"))
lia.currency.plural = L(lia.config.get("CurrencyPluralName", "currencyPlural"))
function lia.currency.get(amount)
    return lia.currency.symbol .. (amount == 1 and "1 " .. lia.currency.singular or amount .. " " .. lia.currency.plural)
end
if SERVER then
    function lia.currency.spawn(pos, amount, angle)
        if not pos then
            lia.information(L("invalidCurrencyPosition"))
        elseif not amount or amount < 0 then
            lia.information(L("invalidCurrencyAmount"))
        else
            local money = ents.Create("lia_money")
            money:SetPos(pos)
            money:setAmount(math.Round(math.abs(amount)))
            money:SetAngles(angle or angle_zero)
            money:Spawn()
            money:Activate()
            return money
        end
    end
end
