-- Table to hold currency-related functions and data
lia.currency = lia.currency or {}
-- Currency symbol, e.g., "$", "₽", "€", etc.
lia.currency.symbol = lia.config.get("CurrencySymbol", "")
-- Singular name for the currency, e.g., "credit"
lia.currency.singular = L(lia.config.get("CurrencySingularName", "currencySingular"))
-- Plural name for the currency, e.g., "credits"
lia.currency.plural = L(lia.config.get("CurrencyPluralName", "currencyPlural"))
--[[
    Returns a formatted string representing the amount of currency.
    Example: "$1 credit" or "$5 credits"
    @param amount (number) - The amount of currency to format
    @return (string) - The formatted currency string
]]
function lia.currency.get(amount)
    -- If the amount is 1, use the singular form; otherwise, use the plural form
    return lia.currency.symbol .. (amount == 1 and "1 " .. lia.currency.singular or amount .. " " .. lia.currency.plural)
end

-- Only define the spawn function on the server
if SERVER then
    --[[
        Spawns a money entity at the given position with the specified amount and angle.
        @param pos (Vector) - The position to spawn the money at
        @param amount (number) - The amount of money to spawn
        @param angle (Angle) - The angle to spawn the money at (optional)
        @return (Entity) - The spawned money entity, or nil if invalid input
    ]]
    function lia.currency.spawn(pos, amount, angle)
        -- Check if the position is valid
        if not pos then
            -- Inform about invalid position
            lia.information(L("invalidCurrencyPosition"))
            -- Check if the amount is valid (must be a positive number)
        elseif not amount or amount < 0 then
            -- Inform about invalid amount
            lia.information(L("invalidCurrencyAmount"))
        else
            -- Create the money entity
            local money = ents.Create("lia_money")
            -- Set the position of the money entity
            money:SetPos(pos)
            -- Set the amount, rounding and ensuring it's positive
            money:setAmount(math.Round(math.abs(amount)))
            -- Set the angle, or use angle_zero if not provided
            money:SetAngles(angle or angle_zero)
            -- Spawn the entity into the world
            money:Spawn()
            -- Activate the entity (calls Activate hook)
            money:Activate()
            -- Return the spawned money entity
            return money
        end
    end
end