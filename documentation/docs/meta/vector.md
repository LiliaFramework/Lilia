# Vector Meta

Vector utilities expand Garry's Mod's math library.

This document describes additional operations for 3D vectors.

---

## Overview

Vector meta functions provide calculations such as midpoints, distances and axis rotations to support movement, physics and placement tasks.

`Center`, `Distance` and `RotateAroundAxis` return new vectors without changing their inputs. `Right` and `Up` modify the vector they are called on and also return it.

### Example Hook Usage

These helpers may be called from either client or server code.

The following snippet demonstrates rotating a camera offset every frame inside a `CalcView` hook:

```lua
hook.Add("CalcView", "TiltView", function(ply, pos, angles, fov)
    local offset = Vector(30, 0, 10):RotateAroundAxis(vector_up, 45)
    return {origin = pos + offset, angles = angles, fov = fov}
end)
```

---

### Center

**Purpose**

Returns the midpoint between this vector and the supplied vector.

**Parameters**

* `vec2` (*Vector*): The vector to average with this vector.

**Realm**

`Shared`

**Returns**

* *Vector*: The center point of the two vectors.

**Example Usage**

```lua
-- Average two vectors to find the midpoint
local a = vector_origin
local b = Vector(10, 10, 10)
local result = a:Center(b)
print(result)
```

---

### Distance

**Purpose**

Calculates the distance between this vector and another vector.

**Parameters**

* `vec2` (*Vector*): The other vector.

**Realm**

`Shared`

**Returns**

* *number*: The distance between the two vectors.

**Example Usage**

```lua
-- Measure the distance between two points
local p1 = vector_origin
local p2 = Vector(3, 4, 0)
local result = p1:Distance(p2)
print(result)
```

---

### RotateAroundAxis

**Purpose**

Rotates the vector around an axis by the specified degrees and returns the new vector.

**Parameters**

* `axis` (*Vector*): Axis to rotate around.

* `degrees` (*number*): Angle in degrees.

**Realm**

`Shared`

**Returns**

* *Vector*: The rotated vector.

**Example Usage**

```lua
-- Rotate a vector 90 degrees around the Z axis
local axis = Vector(0, 0, 1)
local result = Vector(1, 0, 0):RotateAroundAxis(axis, 90)
print(result)
```

---

### Right

**Purpose**

Calculates the cross product of this vector and the provided up reference to derive a right-direction vector.

The vector is overwritten via `self:Cross(self, vUp)` and then normalized,

yielding a direction perpendicular to both inputs. This means the method

modifies the calling vector and returns it.

If this vector has no horizontal component it defaults to `Vector(0, -1, 0)`.

**Parameters**

* `vUp` (*Vector*, optional): Up direction to compare against. Defaults to `vector_up`.

**Realm**

`Shared`

**Returns**

* *Vector*: The calculated right vector.

**Example Usage**

```lua
-- Get the right direction vector
local forward = Vector(1, 0, 0)
local result = forward:Right()
print(result)
```

---

### Up

**Purpose**

Uses two cross products to determine an up-direction vector that is perpendicular to both this vector and the given up reference.

First, the vector is overwritten with the cross product of itself and `vUp` using `self:Cross(self, vUp)`. This intermediate value, stored in `vRet`, is crossed with the original vector via `self:Cross(vRet, self)` to produce the final up direction. The method therefore modifies the calling vector before returning it.

When this vector lacks a horizontal component the fallback value is `Vector(-self.z, 0, 0)`.

**Parameters**

* `vUp` (*Vector*, optional): Up direction to compare against. Defaults to `vector_up`.

**Realm**

`Shared`

**Returns**

* *Vector*: The calculated up vector.

**Example Usage**

```lua
-- Get the up direction vector
local forward = Vector(1, 0, 0)
local result = forward:Up()
print(result)
```

---
