local entityMeta = FindMetaTable("Entity")
local ChairCache = {}
function entityMeta:isProp()
    return self:GetClass() == "prop_physics"
end

function entityMeta:NearEntity(radius)
    for _, v in ipairs(ents.FindInSphere(self:GetPos(), radius or 96)) do
        if v:GetClass() == self then return true end
    end
    return false
end

function entityMeta:GetViewAngle(pos)
    local diff = pos - self:EyePos()
    diff:Normalize()
    return math.abs(math.deg(math.acos(self:EyeAngles():Forward():Dot(diff))))
end

function entityMeta:InFov(ent, fov)
    return self:GetViewAngle(ent:EyePos()) < (fov or 88)
end

function entityMeta:isInRoom(target)
    local tracedata = {}
    tracedata.start = self:GetPos()
    tracedata.endpos = target:GetPos()
    local trace = util.TraceLine(tracedata)

    return not trace.HitWorld
end

function entityMeta:InTrace(ent)
    return     util.TraceLine(
        {
            start = ent:EyePos(),
            endpos = self:EyePos()
        }
    ).Entity == self
end

function entityMeta:IsScreenVisible(ent, maxDist, fov)
    return self:EyePos():DistToSqr(ent:EyePos()) < (maxDist or 512 * 512) and self:IsLineOfSightClear(ent:EyePos()) and self:InFov(ent, fov)
end

function entityMeta:isChair()
    return ChairCache[self:GetModel()]
end

function entityMeta:CanSeeEntity(entity)
    if not (IsValid(self) and IsValid(entity)) then return false end
    if not (self:IsPlayer() or self:IsNPC()) then return false end
    if not self:IsLineOfSightClear(entity) then return false end
    local diff = entity:GetPos() - self:GetShootPos()
    if self:GetAimVector():Dot(diff) / diff:Length() < 0.455 then return false end
    return true
end

for _, v in pairs(list.Get("Vehicles")) do
    if v.Category == "Chairs" then ChairCache[v.Model] = true end
end
