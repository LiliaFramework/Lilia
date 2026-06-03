lia.currency = lia.currency or {}
lia.currency.singular = lia.lang.resolveToken(lia.config.get("CurrencySingularName", "@currencySingular"))
lia.currency.plural = lia.lang.resolveToken(lia.config.get("CurrencyPluralName", "@currencyPlural"))
lia.currency.symbol = ""
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

hook.Add("InitializedModules", "CurrencyConfig", function()
    lia.currency.singular = lia.lang.resolveToken(lia.config.get("CurrencySingularName", "@currencySingular"))
    lia.currency.plural = lia.lang.resolveToken(lia.config.get("CurrencyPluralName", "@currencyPlural"))
    lia.currency.symbol = lia.config.get("CurrencySymbol", "")
end)

hook.Add("OnConfigUpdated", "CurrencyConfigUpdate", function(key)
    if key == "CurrencySingularName" then
        lia.currency.singular = lia.lang.resolveToken(lia.config.get("CurrencySingularName", "@currencySingular"))
    elseif key == "CurrencyPluralName" then
        lia.currency.plural = lia.lang.resolveToken(lia.config.get("CurrencyPluralName", "@currencyPlural"))
    elseif key == "CurrencySymbol" then
        lia.currency.symbol = lia.config.get("CurrencySymbol", "")
    end
end)


