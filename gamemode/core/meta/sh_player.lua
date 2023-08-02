local playerMeta = FindMetaTable("Player")

function playerMeta:AddMoney(amt)
    local char = self:getChar()

    if char then
        char:giveMoney(amt)
    end
end

function playerMeta:TakeMoney(amt)
    local char = self:getChar()

    if char then
        char:giveMoney(-amt)
    end
end

function playerMeta:addMoney(amt)
    local char = self:getChar()

    if char then
        char:giveMoney(amt)
    end
end

function playerMeta:takeMoney(amt)
    local char = self:getChar()

    if char then
        char:giveMoney(-amt)
    end
end

function playerMeta:getMoney()
    local char = self:getChar()

    return char and char:getMoney() or 0
end

function playerMeta:canAfford(amount)
    local char = self:getChar()

    return char and char:hasMoney(amount)
end

function playerMeta:GetMoney()
    local char = self:getChar()

    return char and char:getMoney() or 0
end

function playerMeta:CanAfford(amount)
    local char = self:getChar()

    return char and char:hasMoney(amount)
end

if CLIENT then
    netstream.Hook("liaSyncGesture", function(entity, a, b, c)
        if IsValid(entity) then
            entity:AnimRestartGesture(a, b, c)
        end
    end)
end

function playerMeta:doGesture(a, b, c)
    self:AnimRestartGesture(a, b, c)
    netstream.Start(self:GetPos(), "liaSyncGesture", self, a, b, c)
end