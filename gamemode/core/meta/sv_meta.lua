do
    local playerMeta = FindMetaTable("Player")

    function playerMeta:SetRestricted(state, noMessage)
        self:setRestricted(state, noMessage)
    end

    function playerMeta:setRestricted(state, noMessage)
        if state then
            self:setNetVar("restricted", true)

            if noMessage then
                self:setLocalVar("restrictNoMsg", true)
            end

            self.liaRestrictWeps = self.liaRestrictWeps or {}

            for k, v in ipairs(self:GetWeapons()) do
                self.liaRestrictWeps[k] = v:GetClass()
            end

            timer.Simple(0, function()
                self:StripWeapons()
            end)

            hook.Run("OnPlayerRestricted", self)
        else
            self:setNetVar("restricted")

            if self:getLocalVar("restrictNoMsg") then
                self:setLocalVar("restrictNoMsg")
            end

            if self.liaRestrictWeps then
                for k, v in ipairs(self.liaRestrictWeps) do
                    self:Give(v)
                end

                self.liaRestrictWeps = nil
            end

            hook.Run("OnPlayerUnRestricted", self)
        end
    end

    function playerMeta:GetPlayTime()
        return self:getPlayTime()
    end

    function playerMeta:getPlayTime()
        local diff = os.time(lia.util.dateToNumber(self.lastJoin)) - os.time(lia.util.dateToNumber(self.firstJoin))
        return diff + (RealTime() - (self.liaJoinTime or RealTime()))
    end
end