local vectorMeta = FindMetaTable("Vector")
function vectorMeta:Center(vec2)
    return (self + vec2) / 2
end

function vectorMeta:Distance(vec2)
    local x, y, z = self.x, self.y, self.z
    local x2, y2, z2 = vec2.x, vec2.y, vec2.z
    return math.sqrt((x - x2) ^ 2 + (y - y2) ^ 2 + (z - z2) ^ 2)
end

function vectorMeta:RotateAroundAxis(axis, degrees)
    local rad = math.rad(degrees)
    local cosTheta = math.cos(rad)
    local sinTheta = math.sin(rad)
    return Vector(cosTheta * self.x + sinTheta * (axis.y * self.z - axis.z * self.y), cosTheta * self.y + sinTheta * (axis.z * self.x - axis.x * self.z), cosTheta * self.z + sinTheta * (axis.x * self.y - axis.y * self.x))
end

local right = Vector(0, -1, 0)
function vectorMeta:Right(vUp)
    if self[1] == 0 and self[2] == 0 then return right end
    if not vUp then vUp = vector_up end
    local vRet = self:Cross(self, vUp)
    vRet:Normalize()
    return vRet
end

function vectorMeta:Up(vUp)
    if self[1] == 0 and self[2] == 0 then return Vector(-self[3], 0, 0) end
    if not vUp then vUp = vector_up end
    local vRet = self:Cross(self, vUp)
    vRet = self:Cross(vRet, self)
    vRet:Normalize()
    return vRet
end