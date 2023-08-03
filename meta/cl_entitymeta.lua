--------------------------------------------------------------------------------------------------------
local entityMeta = FindMetaTable("Entity")
--------------------------------------------------------------------------------------------------------
function entityMeta:isDoor()
    return self:GetClass():find("door")
end
--------------------------------------------------------------------------------------------------------
function entityMeta:getDoorPartner()
    local owner = self:GetOwner() or self.liaDoorOwner
    if IsValid(owner) and owner:isDoor() then return owner end

    for k, v in ipairs(ents.FindByClass("prop_door_rotating")) do
        if v:GetOwner() == self then
            self.liaDoorOwner = v

            return v
        end
    end
end
--------------------------------------------------------------------------------------------------------