# Vector Meta

This page documents methods available on the `Vector` meta table, representing 3D vectors in the Lilia framework.

---

## Overview

The `Vector` meta table extends Garry's Mod's base vector functionality with Lilia-specific utility methods for geometric calculations, transformations, and spatial operations. These methods provide enhanced vector manipulation capabilities for 3D positioning, rotation, and mathematical operations within the Lilia framework.

---

### Center

**Purpose**

Calculates the center point between this vector and another vector.

**Parameters**

* `vec2` (*Vector*): The second vector to calculate the center with.

**Returns**

* `center` (*Vector*): The center point between the two vectors.

**Realm**

Shared.

**Example Usage**

```lua
local function getCenterPoint(pos1, pos2)
    local center = pos1:Center(pos2)
    print("Center point: " .. tostring(center))
    return center
end

concommand.Add("get_center", function(ply)
    local pos1 = ply:GetPos()
    local pos2 = ply:GetPos() + Vector(100, 0, 0)
    getCenterPoint(pos1, pos2)
end)
```

---

### Distance

**Purpose**

Calculates the distance between this vector and another vector.

**Parameters**

* `vec2` (*Vector*): The second vector to calculate distance to.

**Returns**

* `distance` (*number*): The distance between the two vectors.

**Realm**

Shared.

**Example Usage**

```lua
local function calculateDistance(pos1, pos2)
    local distance = pos1:Distance(pos2)
    print("Distance: " .. distance .. " units")
    return distance
end

concommand.Add("calculate_distance", function(ply)
    local pos1 = ply:GetPos()
    local pos2 = ply:GetPos() + Vector(100, 50, 25)
    calculateDistance(pos1, pos2)
end)
```

---

### RotateAroundAxis

**Purpose**

Rotates the vector around a specified axis by a given angle in degrees.

**Parameters**

* `axis` (*Vector*): The axis vector to rotate around.
* `degrees` (*number*): The angle in degrees to rotate.

**Returns**

* `rotated` (*Vector*): The rotated vector.

**Realm**

Shared.

**Example Usage**

```lua
local function rotateVectorAroundAxis(vector, axis, degrees)
    local rotated = vector:RotateAroundAxis(axis, degrees)
    print("Original: " .. tostring(vector))
    print("Rotated: " .. tostring(rotated))
    return rotated
end

concommand.Add("rotate_vector", function(ply, cmd, args)
    local degrees = tonumber(args[1]) or 90
    local vector = ply:GetPos()
    local axis = Vector(0, 0, 1) -- Z-axis
    rotateVectorAroundAxis(vector, axis, degrees)
end)
```

---

### Right

**Purpose**

Gets the right vector perpendicular to this vector and the up vector.

**Parameters**

* `vUp` (*Vector|nil*): The up vector to use for calculation (default: vector_up).

**Returns**

* `right` (*Vector*): The right vector.

**Realm**

Shared.

**Example Usage**

```lua
local function getRightVector(direction, upVector)
    local right = direction:Right(upVector)
    print("Direction: " .. tostring(direction))
    print("Right vector: " .. tostring(right))
    return right
end

concommand.Add("get_right_vector", function(ply)
    local direction = ply:GetAimVector()
    local upVector = Vector(0, 0, 1)
    getRightVector(direction, upVector)
end)
```

---

### Up

**Purpose**

Gets the up vector perpendicular to this vector and the specified up vector.

**Parameters**

* `vUp` (*Vector|nil*): The up vector to use for calculation (default: vector_up).

**Returns**

* `up` (*Vector*): The up vector.

**Realm**

Shared.

**Example Usage**

```lua
local function getUpVector(direction, upVector)
    local up = direction:Up(upVector)
    print("Direction: " .. tostring(direction))
    print("Up vector: " .. tostring(up))
    return up
end

concommand.Add("get_up_vector", function(ply)
    local direction = ply:GetAimVector()
    local upVector = Vector(0, 0, 1)
    getUpVector(direction, upVector)
end)
```

---
