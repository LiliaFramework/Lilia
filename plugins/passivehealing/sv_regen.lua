local function canRegen(client)
    return lia.config.get("AutoRegen", true)
end

function PLUGIN:Think()
    if not self.nextThink then
        self.nextThink = 0
    end

    if self.nextThink < CurTime() then
        local players = player.GetAll()

        for k, v in pairs(players) do
            local hp = v:Health()
            local maxhp = v:GetMaxHealth()

            if hp < maxhp then
                local char = v:getChar()

                if canRegen(v) then
                    local newHP = hp + 1
                    v:SetHealth(math.Clamp(newHP, 0, maxhp))
                end
            end
        end

        self.nextThink = CurTime() + 60
    end
end