---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
local entityMeta = FindMetaTable("Entity")
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
local ChairCache = {}
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function entityMeta:isProp()
    return self:GetClass() == "prop_physics"
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function entityMeta:IsSimfphysCar()
    if not simfphys then return false end
    if not IsValid(self) then return false end
    return self:GetClass():lower() == "gmod_sent_vehicle_fphysics_base"
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function entityMeta:NearEntity(radius)
    for _, v in ipairs(ents.FindInSphere(self:GetPos(), radius or 96)) do
        if v:GetClass() == self then return true end
    end
    return false
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function entityMeta:GetViewAngle(pos)
    local diff = pos - self:EyePos()
    diff:Normalize()
    return math.abs(math.deg(math.acos(self:EyeAngles():Forward():Dot(diff))))
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function entityMeta:InFov(entity, fov)
    return self:GetViewAngle(entity:EyePos()) < (fov or 88)
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function entityMeta:isInRoom(target)
    local tracedata = {}
    tracedata.start = self:GetPos()
    tracedata.endpos = target:GetPos()
    local trace = util.TraceLine(tracedata)
    return not trace.HitWorld
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function entityMeta:InTrace(entity)
    return util.TraceLine({
        start = entity:EyePos(),
        endpos = self:EyePos()
    }).Entity == self
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function entityMeta:IsScreenVisible(entity, maxDist, fov)
    return self:EyePos():DistToSqr(entity:EyePos()) < (maxDist or 512 * 512) and self:IsLineOfSightClear(entity:EyePos()) and self:InFov(entity, fov)
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function entityMeta:isChair()
    return ChairCache[self:GetModel()]
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function entityMeta:CanSeeEntity(entity)
    if not (IsValid(self) and IsValid(entity)) then return false end
    if not (self:IsPlayer() or self:IsNPC()) then return false end
    if not self:IsLineOfSightClear(entity) then return false end
    local diff = entity:GetPos() - self:GetShootPos()
    if self:GetAimVector():Dot(diff) / diff:Length() < 0.455 then return false end
    return true
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
for _, v in pairs(list.Get("Vehicles")) do
    if v.Category == "Chairs" then ChairCache[v.Model] = true end
end
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
