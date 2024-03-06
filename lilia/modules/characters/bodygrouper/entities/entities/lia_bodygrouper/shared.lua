
ENT.Type = "anim"

ENT.PrintName = "Bodygroup Closet"

ENT.Category = "Lilia"

ENT.Spawnable = true

ENT.AdminOnly = true

function ENT:HasUser(user)
    self.users = self.users or {}
    return self.users[user] == true
end


function ENT:AddUser(user)
    self.users = self.users or {}
    self.users[user] = true
    hook.Run("BodygrouperClosetAddUser", self, user)
end


function ENT:RemoveUser(user)
    self.users = self.users or {}
    self.users[user] = nil
    hook.Run("BodygrouperClosetRemoveUser", self, user)
end

