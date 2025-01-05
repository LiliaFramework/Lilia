--- A library of DarkRP compatibility functions.
-- @playermeta DarkRP
local playerMeta = FindMetaTable("Player")
--- Retrieves the player's DarkRP money.
-- This is used as compatibility for DarkRP Vars.
-- @realm shared
-- @string var The DarkRP variable to fetch (only "money" is allowed).
-- @treturn Integer|nil The player's money if the variable is valid, or nil if not.
-- @usage
-- local money = player:getDarkRPVar("money")
-- if money then
--     print("Player Money:", money)
-- end
function playerMeta:getDarkRPVar(var)
    local char = self:getChar()
    if var ~= "money" then
        self:ChatPrint("Invalid variable requested! Only 'money' can be fetched. Please refer to our Discord for help.")
        return nil
    end

    if char and char.getMoney then return char:getMoney() end
end

--- Retrieves the amount of money owned by the player's character.
-- @realm shared
-- @treturn Integer The amount of money owned by the player's character.
-- @usage
-- local money = player:getMoney()
-- print("Player Money:", money)
function playerMeta:getMoney()
    local character = self:getChar()
    return character and character:getMoney() or 0
end

--- Checks if the player's character can afford a specified amount of money.
-- This function uses Lilia methods to determine if the player can afford the specified amount.
-- It is designed to be compatible with the DarkRP `canAfford` method.
-- @realm shared
-- @int amount The amount of money to check.
-- @treturn Boolean Whether the player's character can afford the specified amount of money.
-- @usage
-- if player:canAfford(500) then
--     print("Player can afford the item.")
-- else
--     print("Player cannot afford the item.")
-- end
function playerMeta:canAfford(amount)
    local character = self:getChar()
    return character and character:hasMoney(amount)
end

if SERVER then
    --- Adds money to Adds money to the player's character.
    -- This function uses Lilia methods to add the specified amount of money to the player.
    -- It handles wallet limits and spawns excess money as an item in the world if necessary.
    -- @realm shared
    -- @int amount The amount of money to add.
    -- @usage
    -- player:addMoney(1000)
    function playerMeta:addMoney(amount)
        local character = self:getChar()
        if not character then return false end
        local client = self
        local currentMoney = character:getMoney()
        local maxMoneyLimit = lia.config.MoneyLimit or 0
        local totalMoney = currentMoney + amount
        if maxMoneyLimit > 0 and isnumber(maxMoneyLimit) and totalMoney > maxMoneyLimit then
            local excessMoney = totalMoney - maxMoneyLimit
            character:setMoney(maxMoneyLimit)
            client:notifyLocalized("moneyLimit", lia.currency.get(maxMoneyLimit), lia.currency.plural, lia.currency.get(excessMoney), lia.currency.plural)
            local money = lia.currency.spawn(client:getItemDropPos(), excessMoney)
            if IsValid(money) then
                money.client = client
                money.charID = character:getID()
            end

            lia.log.add(client, "money", maxMoneyLimit - currentMoney)
        else
            character:setMoney(totalMoney)
            lia.log.add(client, "money", amount)
        end
        return true
    end

    --- Takes money from the player's character.
    -- @realm shared
    -- @int amount The amount of money to take.
    -- @usage
    -- player:takeMoney(200)
    function playerMeta:takeMoney(amount)
        local character = self:getChar()
        if character then character:giveMoney(-amount) end
    end
end
