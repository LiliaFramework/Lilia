function MODULE:CanProperty(client, property, ent)
    if property == "editentity" and ent:isSimfphysCar() then return client:hasPrivilege("Staff Permissions - Can Edit Simfphys Cars") end
end

function MODULE:isSuitableForTrunk(vehicle)
    if IsValid(vehicle) and vehicle:isSimfphysCar() then return true end
end

function MODULE:CheckValidSit(client)
    local vehicle = client:getTracedEntity()
    if IsValid(vehicle) and vehicle:isSimfphysCar() then return false end
end

function MODULE:simfphysPhysicsCollide()
    return true
end
