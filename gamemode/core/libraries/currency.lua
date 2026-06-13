--[[
    Folder: Developer - Libraries
    File: lia.currency.md
]]
--[[
    Currency

    Currency helpers for formatting in-game money values and spawning physical money entities.
]]
--[[
    Overview:
        The currency library centralizes how Lilia formats money text and keeps the configured singular name, plural name, and symbol in sync with framework config updates. On the server it also provides the helper used to spawn `lia_money` entities in the world.
]]
lia.currency = lia.currency or {}
lia.currency.singular = lia.lang.resolveToken(lia.config.get("CurrencySingularName", "@currencySingular"))
lia.currency.plural = lia.lang.resolveToken(lia.config.get("CurrencyPluralName", "@currencyPlural"))
lia.currency.symbol = ""

--[[
    Purpose:
        Formats a numeric amount into the active in-game currency string.

    Parameters:
        amount (number)
            The amount of money to format.

    Returns:
        string
            The formatted currency string using the configured symbol and singular or plural name.

    Example Usage:
        ```lua
        client:notifyInfo(lia.currency.get(250))
        print(lia.currency.get(1))
        ```

    Realm:
        Shared
]]
function lia.currency.get(amount)
    return lia.currency.symbol .. (amount == 1 and "1 " .. lia.currency.singular or amount .. " " .. lia.currency.plural)
end

if SERVER then
    --[[
        Purpose:
            Spawns a physical `lia_money` entity at the given position.

        Parameters:
            pos (Vector)
                The world position where the money entity should be created.
            amount (number)
                The money amount stored on the spawned entity. Negative values are rejected.
            angle (Angle|nil)
                Optional spawn angle for the money entity. Defaults to `angle_zero`.

        Returns:
            Entity|nil
                The spawned `lia_money` entity, or `nil` when the input is invalid.

        Example Usage:
            ```lua
            local money = lia.currency.spawn(client:getItemDropPos(), 100)
            if IsValid(money) then
                money.client = client
            end
            ```

        Realm:
            Server
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
