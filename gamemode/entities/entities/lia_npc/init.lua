function ENT:Initialize()
    self:SetModel(self.Model)
    self:SetUseType(SIMPLE_USE)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:DrawShadow(true)
    self:SetSolid(SOLID_OBB)
    self:PhysicsInit(SOLID_OBB)
    self:SetCollisionGroup(COLLISION_GROUP_WORLD)
    local physObj = self:GetPhysicsObject()
    if IsValid(physObj) then
        physObj:EnableMotion(false)
        physObj:Sleep()
    end

    if self.BodyGroups and istable(self.BodyGroups) then
        for bodygroup, value in pairs(self.BodyGroups) do
            local bgIndex = self:FindBodygroupByName(bodygroup)
            if bgIndex > -1 then self:SetBodygroup(bgIndex, value) end
        end
    end

    if self.skin then self:SetSkin(self.skin) end
    if IsValid(self) then self:setAnim() end
    self:setNetVar("uniqueID", self.uniqueID or "")
    self:setNetVar("NPCName", self.NPCName or "Unconfigured NPC")
    hook.Run("OnEntityCreated", self)
end

function ENT:OnTakeDamage()
    return false
end

function ENT:Use(client)
    local character = client:getChar()
    if not character then return end
    if self.uniqueID and self.uniqueID ~= "" then
        lia.dialog.openDialog(client, self, self.uniqueID)
        return
    end

    lia.dialog.syncToClients(client)
    timer.Simple(0.1, function()
        if not IsValid(client) or not IsValid(self) then return end
        local npcOptions = {}
        for uniqueID, data in pairs(lia.dialog.stored) do
            local displayName = data.PrintName or uniqueID
            table.insert(npcOptions, {displayName, uniqueID})
        end

        if not table.IsEmpty(npcOptions) then
            client.npcEntity = self
            net.Start("liaRequestNPCSelection")
            net.WriteEntity(self)
            net.WriteTable(npcOptions)
            net.Send(client)
        else
            client:notifyError("No NPC types available! The server may still be loading modules. Please try again in a moment.")
        end
    end)
end
