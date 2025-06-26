local vectorMeta = FindMetaTable("Vector")

--[[
    vectorMeta:Center(vec2)

    Description:
        Returns the midpoint between this vector and the supplied vector.

    Parameters:
        vec2 (Vector) – The vector to average with this vector.

    Realm:
        Shared

    Returns:
        Vector – The center point of the two vectors.

    Example Usage:
        local midpoint = vector_origin:Center(Vector(10, 10, 10))
        print(midpoint) -- Vector(5, 5, 5)
]]
function vectorMeta:Center(vec2)
    return (self + vec2) / 2
end

--[[
    vectorMeta:Distance(vec2)

    Description:
        Calculates the distance between this vector and another vector.

    Parameters:
        vec2 (Vector) – The other vector.

    Realm:
        Shared

    Returns:
        number – The distance between the two vectors.

    Example Usage:
        local dist = vector_origin:Distance(Vector(3, 4, 0))
        print(dist) -- 5
]]
function vectorMeta:Distance(vec2)
    local x, y, z = self.x, self.y, self.z
    local x2, y2, z2 = vec2.x, vec2.y, vec2.z
    return math.sqrt((x - x2) ^ 2 + (y - y2) ^ 2 + (z - z2) ^ 2)
end

--[[
    vectorMeta:RotateAroundAxis(axis, degrees)

    Description:
        Rotates the vector around an axis by the specified degrees and returns the new vector.

    Parameters:
        axis (Vector) – Axis to rotate around.
        degrees (number) – Angle in degrees.

    Realm:
        Shared

    Returns:
        Vector – The rotated vector.

    Example Usage:
        local rotated = Vector(1, 0, 0):RotateAroundAxis(Vector(0, 0, 1), 90)
        print(rotated) -- Vector(0, 1, 0)
]]
function vectorMeta:RotateAroundAxis(axis, degrees)
    local rad = math.rad(degrees)
    local cosTheta = math.cos(rad)
    local sinTheta = math.sin(rad)
    return Vector(
        cosTheta * self.x + sinTheta * (axis.y * self.z - axis.z * self.y),
        cosTheta * self.y + sinTheta * (axis.z * self.x - axis.x * self.z),
        cosTheta * self.z + sinTheta * (axis.x * self.y - axis.y * self.x)
    )
end

local right = Vector(0, -1, 0)

--[[
    vectorMeta:Right(vUp)

    Description:
        Returns a normalized right-direction vector relative to this vector.

    Parameters:
        vUp (Vector, optional) – Up direction to compare against. Defaults to vector_up.

    Realm:
        Shared

    Returns:
        Vector – The calculated right vector.

    Example Usage:
        local rightVec = Vector(0, 1, 0):Right()
        print(rightVec)
]]
function vectorMeta:Right(vUp)
    if self[1] == 0 and self[2] == 0 then return right end
    if not vUp then vUp = vector_up end
    local vRet = self:Cross(self, vUp)
    vRet:Normalize()
    return vRet
end

--[[
    vectorMeta:Up(vUp)

    Description:
        Returns a normalized up-direction vector relative to this vector.

    Parameters:
        vUp (Vector, optional) – Up direction to compare against. Defaults to vector_up.

    Realm:
        Shared

    Returns:
        Vector – The calculated up vector.

    Example Usage:
        local upVec = Vector(1, 0, 0):Up()
        print(upVec)
]]
function vectorMeta:Up(vUp)
    if self[1] == 0 and self[2] == 0 then return Vector(-self[3], 0, 0) end
    if not vUp then vUp = vector_up end
    local vRet = self:Cross(self, vUp)
    vRet = self:Cross(vRet, self)
    vRet:Normalize()
    return vRet
end
