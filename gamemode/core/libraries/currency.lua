--[[
    Folder: Libraries
    File: currency.md
]]
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
--[[
    Purpose:
        Format a numeric amount into a localized currency string with the configured symbol and singular/plural name.

    When Called:
        Whenever a currency amount needs to be shown to players or logged (UI, chat, logs, tooltips).

    Parameters:
        amount (number)
            Raw amount to format; must be a number.

    Returns:
        string
            Formatted amount with symbol prefix and the singular or plural currency name.

    Realm:
        Shared

    Example Usage:
        ```lua
        chat.AddText(L("youReceivedMoney", lia.currency.get(250)))
        lia.log.add(client, "moneyPickedUp", 250)
        ```
]]
function lia.currency.get(amount)
    return lia.currency.symbol .. (amount == 1 and "1 " .. lia.currency.singular or amount .. " " .. lia.currency.plural)
end

if SERVER then
    --[[
    Purpose:
        Spawn a physical money entity at a world position and assign it an amount.

    When Called:
        Server-side when creating droppable currency (player drops, rewards, refunds, scripted events).

    Parameters:
        pos (Vector)
            World position to spawn the money entity; required.
        amount (number)
            Currency amount to store on the entity; must be non-negative.
        angle (Angle|nil)
            Optional spawn angles; defaults to `angle_zero` when omitted.

    Returns:
        Entity|nil
            Created `lia_money` entity, or nil if input is invalid or entity creation fails.

    Realm:
        Server

    Example Usage:
        ```lua
        hook.Add("OnNPCKilled", "DropBountyCash", function(npc, attacker)
            if not IsValid(attacker) or not attacker:IsPlayer() then return end
            local money = lia.currency.spawn(npc:GetPos() + Vector(0, 0, 10), math.random(50, 150))
            if IsValid(money) then
                money:SetVelocity(VectorRand() * 80)
            end
        end)
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
