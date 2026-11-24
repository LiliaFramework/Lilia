ENT.Type = "anim"
ENT.PrintName = "Appearance Wardrobe"
ENT.Author = "liliaplayer"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.Category = "Lilia"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.NoPhysgun = true
ENT.NoRemover = true
ENT.IsPersistent = true
function ENT:HasUser(user)
    self.users = self.users or {}
    return self.users[user] == true
end

function ENT:AddUser(user)
    self.users = self.users or {}
    self.users[user] = true
end

function ENT:RemoveUser(user)
    self.users = self.users or {}
    self.users[user] = nil
end
