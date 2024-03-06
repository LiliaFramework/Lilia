
function simfphys.IsCar(ent)
    if not IsValid(ent) then return false end
    local IsVehicle = ent:GetClass():lower() == "gmod_sent_vehicle_fphysics_base"
    return IsVehicle
end


function MODULE:simfphysPhysicsCollide()
    return true
end

