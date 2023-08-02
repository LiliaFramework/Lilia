do
    local playerMeta = FindMetaTable("Player")

    function playerMeta:GetPlayTime()
        self:getPlayTime()
    end

    function playerMeta:getPlayTime()
        local diff = os.time(lia.util.dateToNumber(lia.lastJoin)) - os.time(lia.util.dateToNumber(lia.firstJoin))
        return diff + (RealTime() - lia.joinTime or 0)
    end

    local vectorLength2D = FindMetaTable("Vector").Length2D

    function playerMeta:isRunning()
        return vectorLength2D(self:GetVelocity()) > (self:GetWalkSpeed() + 10)
    end

    function playerMeta:IsRunning()
        self:isRunning()
    end

    function playerMeta:IsFemale()
        self:isFemale()
    end

    function playerMeta:isFemale()
        local model = self:GetModel():lower()
        return model:find("female") or model:find("alyx") or model:find("mossman") or lia.anim.getModelClass(model) == "citizen_female"
    end

    function playerMeta:GetItemDropPos()
        self:getItemDropPos()
    end

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
end