--------------------------------------------------------------------------------------------------------------------------
local charMeta = lia.meta.character or {}
--------------------------------------------------------------------------------------------------------------------------
charMeta.__index = charMeta
charMeta.id = charMeta.id or 0
charMeta.vars = charMeta.vars or {}
debug.getregistry().Character = lia.meta.character
--------------------------------------------------------------------------------------------------------------------------
function charMeta:__tostring()
    return "character[" .. (self.id or 0) .. "]"
end

--------------------------------------------------------------------------------------------------------------------------
function charMeta:__eq(other)
    return self:getID() == other:getID()
end

--------------------------------------------------------------------------------------------------------------------------
function charMeta:getID()
    return self.id
end

--------------------------------------------------------------------------------------------------------------------------
function charMeta:getBoost(attribID)
    local boosts = self:getBoosts()
    return boosts[attribID]
end

--------------------------------------------------------------------------------------------------------------------------
function charMeta:getBoosts()
    return self:getVar("boosts", {})
end

--------------------------------------------------------------------------------------------------------------------------
function charMeta:getAttrib(key, default)
    local att = self:getAttribs()[key] or default or 0
    local boosts = self:getBoosts()[key]
    if boosts then
        for _, v in pairs(boosts) do
            att = att + v
        end
    end
    return att
end

--------------------------------------------------------------------------------------------------------------------------
function charMeta:getPlayer()
    if IsValid(self.player) then
        return self.player
    elseif self.steamID then
        local steamID = self.steamID
        for k, v in ipairs(player.GetAll()) do
            if v:SteamID64() == steamID then
                self.player = v
                return v
            end
        end
    else
        for k, v in ipairs(player.GetAll()) do
            local char = v:getChar()
            if char and (char:getID() == self:getID()) then
                self.player = v
                return v
            end
        end
    end
end

--------------------------------------------------------------------------------------------------------------------------
function charMeta:hasMoney(amount)
    if amount < 0 then print("Negative Money Check Received.") end
    return self:getMoney() >= amount
end

--------------------------------------------------------------------------------------------------------------------------
function charMeta:giveMoney(amount, takingMoney)
    local client = self:getPlayer()
    local currentMoney = self:getMoney()
    local maxMoneyLimit = lia.config.MoneyLimit
    if hook.Run("WalletLimit", client) ~= nil then maxMoneyLimit = hook.Run("WalletLimit", client) end
    if not takingMoney then
        if maxMoneyLimit > 0 then
            local totalMoney = currentMoney + amount
            if totalMoney > maxMoneyLimit then
                local remainingMoney = totalMoney - maxMoneyLimit
                client:notify("You can't carry more than " .. maxMoneyLimit .. " " .. lia.currency.plural .. " dropping remaining " .. remainingMoney .. " " .. lia.currency.plural .. " on the ground!")
                self:setMoney(maxMoneyLimit)
                local money = lia.currency.spawn(client:getItemDropPos(), remainingMoney)
                money.client = client
                money.charID = self:getID()
            else
                self:setMoney(totalMoney)
            end
        else
            self:setMoney(currentMoney + amount)
        end
    else
        self:setMoney(currentMoney - amount)
    end
    return true
end

--------------------------------------------------------------------------------------------------------------------------
function charMeta:takeMoney(amount)
    amount = math.abs(amount)
    self:giveMoney(-amount, true)
    return true
end

--------------------------------------------------------------------------------------------------------------------------
function charMeta:getFlags()
    return self:getData("f", "")
end

--------------------------------------------------------------------------------------------------------------------------
function charMeta:hasFlags(flags)
    for i = 1, #flags do
        if self:getFlags():find(flags:sub(i, i), 1, true) then return true end
    end
    return hook.Run("CharacterFlagCheck", self, flags) or false
end

--------------------------------------------------------------------------------------------------------------------------
function charMeta:joinClass(class, isForced)
    if not class then
        self:kickClass()
        return
    end

    local oldClass = self:getClass()
    local client = self:getPlayer()
    if isForced or lia.class.canBe(client, class) then
        self:setClass(class)
        hook.Run("OnPlayerJoinClass", client, class, oldClass)
        return true
    else
        return false
    end
end

--------------------------------------------------------------------------------------------------------------------------
function charMeta:kickClass()
    local client = self:getPlayer()
    if not client then return end
    local goClass
    for k, v in pairs(lia.class.list) do
        if v.faction == client:Team() and v.isDefault then
            goClass = k
            break
        end
    end

    self:joinClass(goClass)
    hook.Run("OnPlayerJoinClass", client, goClass)
end

--------------------------------------------------------------------------------------------------------------------------
lia.meta.character = charMeta
--------------------------------------------------------------------------------------------------------------------------
