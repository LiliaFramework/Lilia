--------------------------------------------------------------------------------------------------------
local playerMeta = FindMetaTable("Player")
--------------------------------------------------------------------------------------------------------
function playerMeta:AddMoney(amt)
    local char = self:getChar()

    if char then
        char:giveMoney(amt)
    end
end
--------------------------------------------------------------------------------------------------------
function playerMeta:TakeMoney(amt)
    local char = self:getChar()

    if char then
        char:giveMoney(-amt)
    end
end
--------------------------------------------------------------------------------------------------------
function playerMeta:addMoney(amt)
    local char = self:getChar()

    if char then
        char:giveMoney(amt)
    end
end
--------------------------------------------------------------------------------------------------------
function playerMeta:takeMoney(amt)
    local char = self:getChar()

    if char then
        char:giveMoney(-amt)
    end
end
--------------------------------------------------------------------------------------------------------
function playerMeta:getMoney()
    local char = self:getChar()

    return char and char:getMoney() or 0
end
--------------------------------------------------------------------------------------------------------
function playerMeta:canAfford(amount)
    local char = self:getChar()

    return char and char:hasMoney(amount)
end
--------------------------------------------------------------------------------------------------------
function playerMeta:GetMoney()
    local char = self:getChar()

    return char and char:getMoney() or 0
end
--------------------------------------------------------------------------------------------------------
function playerMeta:CanAfford(amount)
    local char = self:getChar()

    return char and char:hasMoney(amount)
end
--------------------------------------------------------------------------------------------------------
function playerMeta:doGesture(a, b, c)
    self:AnimRestartGesture(a, b, c)
    netstream.Start(self:GetPos(), "liaSyncGesture", self, a, b, c)
end
--------------------------------------------------------------------------------------------------------

    function playerMeta:getPlayTime()
        local diff = os.time(lia.util.dateToNumber(lia.lastJoin)) - os.time(lia.util.dateToNumber(lia.firstJoin))
        return diff + (RealTime() - lia.joinTime or 0)
    end

--------------------------------------------------------------------------------------------------------
    function playerMeta:isRunning()
        return FindMetaTable("Vector").Length2D(self:GetVelocity()) > (self:GetWalkSpeed() + 10)
    end
--------------------------------------------------------------------------------------------------------


    function playerMeta:isFemale()
        local model = self:GetModel():lower()
        return model:find("female") or model:find("alyx") or model:find("mossman") or lia.anim.getModelClass(model) == "citizen_female"
    end
--------------------------------------------------------------------------------------------------------
    function playerMeta:GetItemDropPos()
        self:getItemDropPos()
    end
--------------------------------------------------------------------------------------------------------
    function playerMeta:getItemDropPos()
        local data = {}
        data.start = self:GetShootPos()
        data.endpos = self:GetShootPos() + self:GetAimVector() * 86
        data.filter = self
        local trace = util.TraceLine(data)
        data.start = trace.HitPos
        data.endpos = data.start + trace.HitNormal * 46
        data.filter = {}
        trace = util.TraceLine(data)
        return trace.HitPos
    end
--------------------------------------------------------------------------------------------------------