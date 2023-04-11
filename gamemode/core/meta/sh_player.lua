local PLAYER = FindMetaTable("Player")

-- I suggest you to follow the Lilia Coding Rules.
-- This is just for the DarkRP things mate.
-- trust me, you're going to use character class a lot if you're going to make something with Lilia.
function PLAYER:AddMoney(amt)
    local char = self:getChar()

    if char then
        char:giveMoney(amt)
    end
end

function PLAYER:TakeMoney(amt)
    local char = self:getChar()

    if char then
        char:giveMoney(-amt)
    end
end

function PLAYER:addMoney(amt)
    local char = self:getChar()

    if char then
        char:giveMoney(amt)
    end
end

function PLAYER:takeMoney(amt)
    local char = self:getChar()

    if char then
        char:giveMoney(-amt)
    end
end

function PLAYER:getMoney()
    local char = self:getChar()

    return char and char:getMoney() or 0
end

function PLAYER:canAfford(amount)
    local char = self:getChar()

    return char and char:hasMoney(amount)
end

function PLAYER:GetMoney()
    local char = self:getChar()

    return char and char:getMoney() or 0
end

function PLAYER:CanAfford(amount)
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

function PLAYER:doGesture(a, b, c)
    self:AnimRestartGesture(a, b, c)
    netstream.Start(self:GetPos(), "liaSyncGesture", self, a, b, c)
end
