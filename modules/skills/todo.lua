////////////////////////////////////////////////////////////////////////////////
function PLUGIN:CanPlayerInteractItem(client, action, item)
    if action == "equip" and hook.Run("CanPlayerEquipItem", client, item) == false then return false end
end

function PLUGIN:CanPlayerEquipItem(client, item)
    if not item.RequiredSkillLevels then return true end

    return client:MeetsRequiredSkills(item.RequiredSkillLevels)
end
////////////////////////////////////////////////////////////////////////////////


add to item bases
////////////////////////////////////////////////////////////////////////////////
remove roll
////////////////////////////////////////////////////////////////////////////////

sh_meta 

local playerMeta = FindMetaTable("Player")

function playerMeta:HasSkillLevel(skill, level)
    local currentLevel = self:getChar():getAttrib(skill, 0)
    return currentLevel >= level
end

function playerMeta:MeetsRequiredSkills(requiredSkillLevels)
    if not requiredSkillLevels then return true end
    for skill, level in pairs(requiredSkillLevels) do
        if not self:HasSkillLevel(skill, level) then return false end
    end
    return true
end

MODULE.RollMultiplier = 1 -- Bonus roll multiplier on the commands
MODULE.StrengthMultiplier = 2.0 -- Percentage bonus damage melee weapons do
MODULE.PunchStrengthMultiplier = 0.7 -- Extra damage multiplier for punches
MODULE.MeleeWeapons = {"weapon_crowbar", "weapon_knife",}
