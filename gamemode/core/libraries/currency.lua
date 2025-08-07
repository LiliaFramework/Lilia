--[[
# Currency Library

This page documents the functions for working with currency and money systems.

---

## Overview

The currency library provides utilities for managing currency and money systems within the Lilia framework. It handles currency formatting, money entity spawning, and provides functions for working with currency amounts and symbols. The library supports configurable currency symbols and names, and provides utilities for creating and managing money entities in the world.
]]
lia.currency = lia.currency or {}
lia.currency.symbol = lia.config.get("CurrencySymbol", "")
lia.currency.singular = lia.config.get("CurrencySingularName", L("currencySingular"))
lia.currency.plural = lia.config.get("CurrencyPluralName", L("currencyPlural"))
--[[
    lia.currency.get

    Purpose:
        Returns a formatted string representing the given amount of currency, using the configured symbol and singular/plural names.
        Handles proper singular/plural grammar based on the amount.

    Parameters:
        amount (number) - The amount of currency to format.

    Returns:
        string - The formatted currency string (e.g., "$1 Dollar" or "$5 Dollars").

    Realm:
        Shared.

    Example Usage:
        -- Get a string for 1 unit of currency
        local single = lia.currency.get(1) -- "$1 Dollar"

        -- Get a string for 50 units of currency
        local multi = lia.currency.get(50) -- "$50 Dollars"
]]
function lia.currency.get(amount)
    return lia.currency.symbol .. (amount == 1 and "1 " .. lia.currency.singular or amount .. " " .. lia.currency.plural)
end

if SERVER then
    --[[
        lia.currency.spawn

        Purpose:
            Spawns a money entity at the specified position with the given amount and optional angle.
            Notifies if the position or amount is invalid.

        Parameters:
            pos (Vector)      - The position to spawn the money entity.
            amount (number)   - The amount of currency to assign to the entity.
            angle (Angle)     - (Optional) The angle to set for the entity (defaults to angle_zero).

        Returns:
            Entity - The spawned money entity, or nil if invalid parameters.

        Realm:
            Server.

        Example Usage:
            -- Spawn $100 at a specific position and angle
            local pos = Vector(100, 200, 300)
            local ang = Angle(0, 90, 0)
            local moneyEnt = lia.currency.spawn(pos, 100, ang)

            -- Spawn $50 at a position with default angle
            local moneyEnt2 = lia.currency.spawn(Vector(0, 0, 0), 50)
    ]]
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
