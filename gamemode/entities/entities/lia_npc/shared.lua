ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Dialog NPC"
ENT.Author = "Samael"
ENT.Contact = "@liliaplayer"
ENT.Category = "Lilia"
ENT.Spawnable = true
ENT.AdminOnly = false
ENT.DrawEntityInfo = true
ENT.Model = "models/player/breen.mdl"
ENT.IsPersistent = true
function ENT:setAnim()
    if self.customAnimation and self.customAnimation ~= "auto" then
        local sequenceIndex = self:LookupSequence(self.customAnimation)
        if sequenceIndex >= 0 then
            self:ResetSequence(sequenceIndex)
            return
        end
    end

    for k, v in ipairs(self:GetSequenceList()) do
        if v:lower():find("idle") and v ~= "idlenoise" then return self:ResetSequence(k) end
    end

    self:ResetSequence(4)
end
