--------------------------------------------------------------------------------------------------------------------------
local KEY_BLACKLIST = bit.bor(IN_ATTACK, IN_ATTACK2)
--------------------------------------------------------------------------------------------------------------------------
function MODULE:StartCommand(client, command)
    local weapon = client:GetActiveWeapon()
    if not client:isWepRaised() then
        if IsValid(weapon) and weapon.FireWhenLowered then return end
        command:RemoveKey(KEY_BLACKLIST)
    end
end

--------------------------------------------------------------------------------------------------------------------------
function MODULE:CanPlayerThrowPunch(client)
    if not client:isWepRaised() then return false end
end
--------------------------------------------------------------------------------------------------------------------------
