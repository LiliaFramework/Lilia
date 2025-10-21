--[[
    Currency Library

    In-game currency formatting, display, and management system for the Lilia framework.
]]
--[[
    Overview:
    The currency library provides comprehensive functionality for managing in-game currency
    within the Lilia framework. It handles currency formatting, display, and physical money
    entity spawning. The library operates on both server and client sides, with the server
    handling money entity creation and spawning, while the client handles currency display
    formatting. It includes localization support for currency names and symbols, ensuring
    proper pluralization and formatting based on amount values. The library integrates
    with the configuration system to allow customizable currency symbols and names.
]]
lia.currency = lia.currency or {}
lia.currency.symbol = lia.config.get("CurrencySymbol", "")
lia.currency.singular = L(lia.config.get("CurrencySingularName", "currencySingular"))
lia.currency.plural = L(lia.config.get("CurrencyPluralName", "currencyPlural"))
--[[
    Purpose: Formats a currency amount with proper symbol, singular/plural form, and localization
    When Called: When displaying currency amounts in UI, chat messages, or any text output
    Parameters: amount (number) - The numeric amount to format
    Returns: string - Formatted currency string with symbol and proper singular/plural form
    Realm: Shared (works on both client and server)
    Example Usage:

    Low Complexity:
    ```lua
    -- Simple: Format a basic currency amount
    local formatted = lia.currency.get(100)
    print(formatted) -- "$100 dollars" (example output)
    ```

    Medium Complexity:
    ```lua
    -- Medium: Format currency with conditional display
    local playerMoney = 1500
    if playerMoney > 0 then
        local displayText = "Balance: " .. lia.currency.get(playerMoney)
        chat.AddText(Color(255, 255, 255), displayText)
    end
    ```

    High Complexity:
    ```lua
    -- High: Format multiple currency amounts with validation
    local transactions = {100, 1, 0, -50, 2500}
    for _, amount in ipairs(transactions) do
        if amount and amount ~= 0 then
            local formatted = lia.currency.get(math.abs(amount))
            local prefix = amount > 0 and "+" or "-"
            print(prefix .. formatted)
        end
    end
    ```
]]
function lia.currency.get(amount)
    return lia.currency.symbol .. (amount == 1 and "1 " .. lia.currency.singular or amount .. " " .. lia.currency.plural)
end

if SERVER then
    --[[
        Purpose: Creates and spawns a physical money entity at the specified position with the given amount
        When Called: When spawning money drops, creating money rewards, or placing currency in the world
        Parameters:
            pos (Vector) - The position where the money entity should be spawned
            amount (number) - The amount of money the entity should contain (will be rounded and made positive)
            angle (Angle, optional) - The rotation angle for the money entity (defaults to angle_zero)
        Returns: Entity - The created money entity if successful, nil if parameters are invalid
        Realm: Server only
        Example Usage:

        Low Complexity:
        ```lua
        -- Simple: Spawn money at player's position
        local pos = player:GetPos()
        lia.currency.spawn(pos, 100)
        ```

        Medium Complexity:
        ```lua
        -- Medium: Spawn money with specific angle and validation
        local dropPos = trace.HitPos
        local dropAmount = math.random(50, 200)
        if dropPos then
            local money = lia.currency.spawn(dropPos, dropAmount, Angle(0, math.random(0, 360), 0))
            if money then
                print("Money spawned successfully")
            end
        end
        ```

        High Complexity:
        ```lua
        -- High: Spawn multiple money entities with advanced positioning
        local spawnPositions = {
            {pos = Vector(100, 200, 50), amount = 500, angle = Angle(0, 45, 0)},
            {pos = Vector(-100, 200, 50), amount = 250, angle = Angle(0, 90, 0)},
            {pos = Vector(0, 0, 100), amount = 1000, angle = Angle(0, 180, 0)}
        }

        for _, data in ipairs(spawnPositions) do
            local money = lia.currency.spawn(data.pos, data.amount, data.angle)
            if money then
                money:SetVelocity(Vector(math.random(-50, 50), math.random(-50, 50), 100))
            end
        end
        ```
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
