do
    local playerMeta = FindMetaTable("Player")

    -- @type function GetPlayTime
    -- @typeCommentStart
    -- Gets the total play time of the player in seconds.
    -- Returns:
    --   (number) The total play time of the player.
    -- @typeCommentEnd
    -- @classmod PlayerMeta
    -- @realm server
    -- @usageStart
    -- Example usage:
    --    local playTime = player:GetPlayTime()
    -- @usageEnd
    function playerMeta:GetPlayTime()
        self:getPlayTime()
    end

    -- @type function getPlayTime
    -- @typeCommentStart
    -- Gets the total play time of the player in seconds.
    -- Returns:
    --   (number) The total play time of the player.
    -- @typeCommentEnd
    -- @classmod PlayerMeta
    -- @realm server
    -- @usageStart
    -- Example usage:
    --    local playTime = player:getPlayTime()
    -- @usageEnd
    function playerMeta:getPlayTime()
        local diff = os.time(lia.util.dateToNumber(lia.lastJoin)) - os.time(lia.util.dateToNumber(lia.firstJoin))

        return diff + (RealTime() - lia.joinTime or 0)
    end

    -- @type function isRunning
    -- @typeCommentStart
    -- Returns true if the player is moving at least the running speed.
    -- Returns:
    --   (boolean) Indicates whether the player is running or not.
    -- @typeCommentEnd
    -- @classmod PlayerMeta
    -- @realm server
    -- @usageStart
    -- Example usage:
    --    local isRunning = player:isRunning()
    -- @usageEnd
    local vectorLength2D = FindMetaTable("Vector").Length2D

    function playerMeta:isRunning()
        return vectorLength2D(self:GetVelocity()) > (self:GetWalkSpeed() + 10)
    end

    -- @type function IsRunning
    -- @typeCommentStart
    -- Returns true if the player is moving at least the running speed.
    -- @typeCommentEnd
    -- @classmod PlayerMeta
    -- @realm server
    -- @usageStart
    -- Example usage:
    --    local isRunning = player:IsRunning()
    -- @usageEnd
    function playerMeta:IsRunning()
        self:isRunning()
    end

    -- @type function IsFemale
    -- @typeCommentStart
    -- Checks if the player has a female model.
    -- Returns:
    --   (boolean) Indicates whether the player has a female model or not.
    -- @typeCommentEnd
    -- @classmod PlayerMeta
    -- @realm server
    -- @usageStart
    -- Example usage:
    --    local isFemale = player:IsFemale()
    -- @usageEnd
    function playerMeta:IsFemale()
        self:isFemale()
    end

    -- @type function isFemale
    -- @typeCommentStart
    -- Checks if the player has a female model.
    -- Returns:
    --   (boolean) Indicates whether the player has a female model or not.
    -- @typeCommentEnd
    -- @classmod PlayerMeta
    -- @realm server
    -- @usageStart
    -- Example usage:
    --    local isFemale = player:isFemale()
    -- @usageEnd
    function playerMeta:isFemale()
        local model = self:GetModel():lower()

        return model:find("female") or model:find("alyx") or model:find("mossman") or lia.anim.getModelClass(model) == "citizen_female"
    end

    -- @type function GetItemDropPos
    -- @typeCommentStart
    -- Returns a good position in front of the player for an entity.
    -- Returns:
    --   (Vector) The position in front of the player for dropping an entity.
    -- @typeCommentEnd
    -- @classmod PlayerMeta
    -- @realm server
    -- @usageStart
    -- Example usage:
    --    local itemDropPos = player:GetItemDropPos()
    -- @usageEnd
    function playerMeta:GetItemDropPos()
        self:getItemDropPos()
    end

    -- @type function getItemDropPos
    -- @typeCommentStart
    -- Returns a good position in front of the player for an entity.
    -- Returns:
    --   (Vector) The position in front of the player for dropping an entity.
    -- @typeCommentEnd
    -- @classmod PlayerMeta
    -- @realm server
    -- @usageStart
    -- Example usage:
    --    local itemDropPos = player:getItemDropPos()
    -- @usageEnd
    function playerMeta:getItemDropPos()
        -- Start a trace.
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