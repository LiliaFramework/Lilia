function ENT:onDrawEntityInfo(alpha)
    local uniqueID = self:getNetVar("uniqueID", "")
    local npcName = self:getNetVar("NPCName", self.PrintName or "NPC")
    if uniqueID == "" or uniqueID == nil then npcName = "Unconfigured NPC" end
    lia.util.drawEntText(self, npcName, 0, alpha)
end
