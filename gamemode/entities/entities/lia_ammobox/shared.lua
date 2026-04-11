ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = L("liaAmmoBoxName")
ENT.Author = "Samael"
ENT.Contact = "@liliaplayer"
ENT.Category = "Lilia"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.DrawEntityInfo = true
ENT.noTarget = true
ENT.Holdable = true
ENT.NoDuplicate = true
ENT.Model = "models/items/boxsrounds.mdl"
ENT.DefaultAmmoAmount = 30
function ENT:getAmmoAmount(weapon)
    local clipSize = IsValid(weapon) and weapon:GetMaxClip1() or -1
    if clipSize <= 0 then
        local storedWeapon = IsValid(weapon) and weapons.GetStored(weapon:GetClass())
        clipSize = storedWeapon and storedWeapon.Primary and tonumber(storedWeapon.Primary.ClipSize) or clipSize
    end

    if clipSize and clipSize > 0 then return math.floor(clipSize) end
    return self.DefaultAmmoAmount
end
