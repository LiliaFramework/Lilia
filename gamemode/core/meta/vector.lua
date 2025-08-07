--[[
# Vector Library

This page documents the extended functions for working with Vector objects in the Lilia framework.

---

## Overview

The vector library extends the base Vector metatable with additional utility functions for common vector operations. These functions provide convenient methods for calculating distances, finding midpoints, rotating vectors, and other geometric operations that are commonly needed in game development.

All functions are available on both client and server realms and work with the standard Source engine Vector objects.
]]
local vectorMeta = FindMetaTable("Vector")
--[[
    Center

    Purpose:
        Returns the midpoint between this vector and another vector.

    Parameters:
        vec2 (Vector) - The other vector to find the center with.

    Returns:
        Vector - The center point between the two vectors.

    Realm:
        Shared.

    Example Usage:
        local midpoint = vec1:Center(vec2)
        print("Midpoint is: " .. tostring(midpoint))
]]
function vectorMeta:Center(vec2)
    return (self + vec2) / 2
end

--[[
    Distance

    Purpose:
        Calculates the Euclidean distance between this vector and another vector.

    Parameters:
        vec2 (Vector) - The other vector to measure distance to.

    Returns:
        number - The distance between the two vectors.

    Realm:
        Shared.

    Example Usage:
        local dist = vec1:Distance(vec2)
        print("Distance is: " .. dist)
]]
function vectorMeta:Distance(vec2)
    local x, y, z = self.x, self.y, self.z
    local x2, y2, z2 = vec2.x, vec2.y, vec2.z
    return math.sqrt((x - x2) ^ 2 + (y - y2) ^ 2 + (z - z2) ^ 2)
end

--[[
    RotateAroundAxis

    Purpose:
        Rotates this vector around a given axis by a specified number of degrees.

    Parameters:
        axis (Vector)   - The axis to rotate around.
        degrees (number) - The angle in degrees to rotate.

    Returns:
        Vector - The rotated vector.

    Realm:
        Shared.

    Example Usage:
        local rotated = vec:RotateAroundAxis(Vector(0,0,1), 90)
        print("Rotated vector: " .. tostring(rotated))
]]
function vectorMeta:RotateAroundAxis(axis, degrees)
    local rad = math.rad(degrees)
    local cosTheta = math.cos(rad)
    local sinTheta = math.sin(rad)
    return Vector(cosTheta * self.x + sinTheta * (axis.y * self.z - axis.z * self.y), cosTheta * self.y + sinTheta * (axis.z * self.x - axis.x * self.z), cosTheta * self.z + sinTheta * (axis.x * self.y - axis.y * self.x))
end

local right = Vector(0, -1, 0)
--[[
    Right

    Purpose:
        Returns the right vector (perpendicular) relative to this vector and an optional up vector.

    Parameters:
        vUp (Vector) - (Optional) The up vector to use. Defaults to global vector_up.

    Returns:
        Vector - The right vector.

    Realm:
        Shared.

    Example Usage:
        local rightVec = vec:Right()
        print("Right vector: " .. tostring(rightVec))
]]
function vectorMeta:Right(vUp)
    if self[1] == 0 and self[2] == 0 then return right end
    if not vUp then vUp = vector_up end
    local vRet = self:Cross(self, vUp)
    vRet:Normalize()
    return vRet
end

--[[
    Up

    Purpose:
        Returns the up vector (perpendicular) relative to this vector and an optional up vector.

    Parameters:
        vUp (Vector) - (Optional) The up vector to use. Defaults to global vector_up.

    Returns:
        Vector - The up vector.

    Realm:
        Shared.

    Example Usage:
        local upVec = vec:Up()
        print("Up vector: " .. tostring(upVec))
]]
function vectorMeta:Up(vUp)
    if self[1] == 0 and self[2] == 0 then return Vector(-self[3], 0, 0) end
    if not vUp then vUp = vector_up end
    local vRet = self:Cross(self, vUp)
    vRet = self:Cross(vRet, self)
    vRet:Normalize()
    return vRet
end
