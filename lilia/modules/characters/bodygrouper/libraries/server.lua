function MODULE:SaveData()
    local data = {}
    for _, v in pairs(ents.FindByClass("lia_bodygrouper")) do
        data[#data + 1] = {v:GetPos(), v:GetAngles()}
    end

    self:setData(data)
end

function MODULE:LoadData()
    for _, v in pairs(self:getData()) do
        local closet = ents.Create("lia_bodygrouper")
        closet:SetPos(v[1])
        closet:SetAngles(v[2])
        closet:Spawn()
        local phys = closet:GetPhysicsObject()
        if IsValid(phys) then phys:EnableMotion(false) end
    end
end

function MODULE:BodygrouperClosetAddUser(closet)
    local opensound = self.BodygrouperOpenSound
    if opensound then closet:EmitSound(opensound) end
end

function MODULE:BodygrouperClosetRemoveUser(closet)
    local closesound = self.BodygrouperCloseSound
    if closesound then closet:EmitSound(closesound) end
end
