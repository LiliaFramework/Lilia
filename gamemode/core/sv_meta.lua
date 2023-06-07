local playerMeta = FindMetaTable("Player")

do
    -- @type function SetRestricted
    -- @typeCommentStart
    -- Sets the restriction state of the player.
    -- Parameters:
    --   state (boolean): Indicates whether to restrict the player (true) or unrestrict them (false).
    --   noMessage (boolean): Determines whether to show a restriction message to the player (true) or not (false).
    -- @typeCommentEnd
    -- @classmod PlayerMeta
    -- @realm server
    -- @usageStart
    -- Example usage:
    --    player:SetRestricted(true, true)
    -- @usageEnd
    function playerMeta:SetRestricted(state, noMessage)
        self:setRestricted(state, noMessage)
    end

    -- @type function setRestricted
    -- @typeCommentStart
    -- Removes a player's weapon and restricts interactivity.
    -- Parameters:
    --   state (boolean): Indicates whether to restrict the player (true) or unrestrict them (false).
    --   noMessage (boolean): Determines whether to show a restriction message to the player (true) or not (false).
    -- @typeCommentEnd
    -- @classmod PlayerMeta
    -- @realm server
    -- @usageStart
    -- Example usage:
    --    player:setRestricted(true, false)
    -- @usageEnd
    function playerMeta:setRestricted(state, noMessage)
        if state then
            self:setNetVar("restricted", true)

            if noMessage then
                self:setLocalVar("restrictNoMsg", true)
            end

            self.liaRestrictWeps = self.liaRestrictWeps or {}

            -- Store the player's current weapons for later restoration.
            for k, v in ipairs(self:GetWeapons()) do
                self.liaRestrictWeps[k] = v:GetClass()
            end

            -- Remove all weapons from the player.
            timer.Simple(0, function()
                self:StripWeapons()
            end)

            -- Trigger the "OnPlayerRestricted" hook.
            hook.Run("OnPlayerRestricted", self)
        else
            self:setNetVar("restricted")

            -- Clear the restriction message variable.
            if self:getLocalVar("restrictNoMsg") then
                self:setLocalVar("restrictNoMsg")
            end

            -- Restore the player's previously stored weapons.
            if self.liaRestrictWeps then
                for k, v in ipairs(self.liaRestrictWeps) do
                    self:Give(v)
                end

                self.liaRestrictWeps = nil
            end

            -- Trigger the "OnPlayerUnRestricted" hook.
            hook.Run("OnPlayerUnRestricted", self)
        end
    end

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
        return self:getPlayTime()
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
        local diff = os.time(lia.util.dateToNumber(self.lastJoin)) - os.time(lia.util.dateToNumber(self.firstJoin))

        return diff + (RealTime() - (self.liaJoinTime or RealTime()))
    end
end