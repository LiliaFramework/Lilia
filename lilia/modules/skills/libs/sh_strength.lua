-------------------------------------------------------------------------------------------------------------------------~
function MODULE:GetStrengthBonusDamage(character)
    return (character:getAttrib("strength", 0) * lia.config.StrengthMultiplier) or 0
end

-------------------------------------------------------------------------------------------------------------------------~
function MODULE:GetPunchStrengthBonusDamage(character)
    return (character:getAttrib("strength", 0) * lia.config.PunchStrengthMultiplier) or 0
end
-------------------------------------------------------------------------------------------------------------------------~