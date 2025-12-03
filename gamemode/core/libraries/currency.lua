--[[
    Currency Library

    In-game currency formatting, display, and management system for the Lilia framework.
]]
--[[
    Overview:
        The currency library provides comprehensive functionality for managing in-game currency within the Lilia framework. It handles currency formatting, display, and physical money entity spawning.
        The library operates on both server and client sides, with the server handling money entity creation and spawning, while the client handles currency display formatting.
        It includes localization support for currency names and symbols, ensuring proper pluralization and formatting based on amount values.
        The library integrates with the configuration system to allow customizable currency symbols and names.
]]
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
