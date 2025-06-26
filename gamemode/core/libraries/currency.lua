lia.currency = lia.currency or {}
lia.currency.symbol = lia.config.get("CurrencySymbol") or ""
lia.currency.singular = lia.config.get("CurrencySingularName") or "dollar"
lia.currency.plural = lia.config.get("CurrencyPluralName") or "dollars"
--[[
    lia.currency.get

    Description:
        Formats a numeric amount into a currency string using the defined symbol,
        singular, and plural names. If the amount is exactly 1, it returns the singular
        form; otherwise, it returns the plural form.

    Parameters:
        amount (number) – The amount to format.

    Returns:
        string – The formatted currency string.

    Realm:
        Shared

    Example Usage:
        lia.currency.get(10)  -- e.g., "$10 dollars"
]]
function lia.currency.get(amount)
    return lia.currency.symbol .. (amount == 1 and "1 " .. lia.currency.singular or amount .. " " .. lia.currency.plural)
end

if SERVER then
    --[[
        lia.currency.spawn

        Description:
            Spawns a currency entity at the specified position with a given amount and optional angle.
            Validates the position and ensures the amount is a non-negative number.

        Parameters:
            pos (Vector) – The spawn position for the currency entity.
            amount (number) – The monetary value for the entity.
            angle (Angle, optional) – The orientation for the entity (defaults to angle_zero).

        Returns:
            Entity – The spawned currency entity if successful; nil otherwise.

        Realm:
            Server

        Example Usage:
            lia.currency.spawn(vector_origin, 100)
    ]]
    function lia.currency.spawn(pos, amount, angle)
        if not pos then
            lia.information("[Lilia] Can't create currency entity: Invalid Position")
        elseif not amount or amount < 0 then
            lia.information("[Lilia] Can't create currency entity: Invalid Amount of money")
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
