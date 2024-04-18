--- Helper library for managing currency.
-- @module lia.currency
lia.currency = lia.currency or {}
lia.currency.symbol = lia.currency.symbol or "$"
lia.currency.singular = lia.currency.singular or "dollar"
lia.currency.plural = lia.currency.plural or "dollars"
--- Sets the symbol, singular, and plural forms of the currency.
-- @string symbol The currency symbol.
-- @string singular The singular form of the currency name.
-- @string plural The plural form of the currency name.
-- @realm shared
-- @internal
function lia.currency.set(symbol, singular, plural)
    lia.currency.symbol = symbol
    lia.currency.singular = singular
    lia.currency.plural = plural
end

--- Retrieves the formatted currency string based on the amount.
-- @int amount The amount of currency.
-- @return string The formatted currency string.
-- @realm shared
function lia.currency.get(amount)
    return lia.currency.symbol .. (amount == 1 and ("1 " .. lia.currency.singular) or (amount .. " " .. lia.currency.plural))
end

if SERVER then
--- Spawns a currency entity at the specified position with the given amount and angle.
-- This function is only available on the server.
-- @vector pos The position where the currency entity will be spawned.
-- @int amount The amount of currency for the spawned entity.
-- @angle angle (Optional) The angle of the spawned entity. Default is Angle(0, 0, 0).
-- @realm server
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
end

timer.Simple(1, function() lia.currency.set(lia.config.CurrencySymbol, lia.config.CurrencySingularName, lia.config.CurrencyPluralName) end)
