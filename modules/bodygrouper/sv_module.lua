util.AddNetworkString("BodygrouperMenu")
util.AddNetworkString("BodygrouperMenuClose")

function MODULE:SaveData()
    local data = {}

    for k, v in pairs(ents.FindByClass("bodygrouper_closet")) do
        data[#data + 1] = {v:GetPos(), v:GetAngles()}
    end

    self:setData(data)
end

function MODULE:LoadData()
    for k, v in pairs(self:getData()) do
        local closet = ents.Create("bodygrouper_closet")
        closet:SetPos(v[1])
        closet:SetAngles(v[2])
        closet:Spawn()
        local phys = closet:GetPhysicsObject()

        if IsValid(phys) then
            phys:EnableMotion(false)
        end
    end
end

function MODULE:BodygrouperClosetAddUser(closet, user)
    local opensound = lia.config.BodygrouperOpenSound

    if opensound then
        closet:EmitSound(opensound)
    end
end

function MODULE:BodygrouperClosetRemoveUser(closet, user)
    local closesound = lia.config.BodygrouperCloseSound

    if closesound then
        closet:EmitSound(closesound)
    end
end