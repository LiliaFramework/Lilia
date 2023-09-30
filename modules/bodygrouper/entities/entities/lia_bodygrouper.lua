--------------------------------------------------------------------------------------------------------
AddCSLuaFile()
--------------------------------------------------------------------------------------------------------
ENT.Type = "anim"
ENT.PrintName = "Bodygroup Closet"
ENT.Category = "Lilia"
ENT.Spawnable = true
ENT.AdminOnly = true
--------------------------------------------------------------------------------------------------------
if SERVER then
    function ENT:Initialize()
        self:SetModel(lia.config.BodygrouperModel)
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetUseType(SIMPLE_USE)
    end

    function ENT:Use(activator)
        if activator:IsPlayer() then
            net.Start("BodygroupMenu")
            net.Send(activator)
            self:AddUser(activator)
        end
    end
else
    function ENT:Draw()
        self:DrawModel()
    end
end

--------------------------------------------------------------------------------------------------------
function ENT:HasUser(user)
    self.users = self.users or {}

    return self.users[user] == true
end

--------------------------------------------------------------------------------------------------------
function ENT:AddUser(user)
    self.users = self.users or {}
    self.users[user] = true
    hook.Run("BodygrouperClosetAddUser", self, user)
end

--------------------------------------------------------------------------------------------------------
function ENT:RemoveUser(user)
    self.users = self.users or {}
    self.users[user] = nil
    hook.Run("BodygrouperClosetRemoveUser", self, user)
end
--------------------------------------------------------------------------------------------------------