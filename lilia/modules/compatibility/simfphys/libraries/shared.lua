function simfphys.IsCar(ent)
    if not IsValid(ent) then return false end
    return ent:GetClass() == "gmod_sent_vehicle_fphysics_base" or ent.IsSimfphyscar or ent:GetClass() == "gmod_sent_vehicle_fphysics_wheel" or ent.Base == "gmod_sent_vehicle_fphysics_base" or ent.Base == "gmod_sent_vehicle_fphysics_wheel"
end

function MODULE:simfphysPhysicsCollide()
    return true
end
