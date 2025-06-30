# Vector Meta


Vector utilities expand Garry's Mod's math library. This document describes additional operations for 3D vectors.


---


## Overview


Vector meta functions provide calculations such as midpoints, distances, and axis rotations to support movement, physics, and placement tasks.


---


### Center(vec2)


**Description:**


Returns the midpoint between this vector and the supplied vector.


**Parameters:**


* `vec2` (`Vector`) – The vector to average with this vector.


**Realm:**


* Shared


**Returns:**


* `Vector` – The center point of the two vectors.


**Example Usage:**


```lua
-- Average two vectors to find the midpoint
local midpoint = vector_origin:Center(Vector(10, 10, 10))
print(midpoint) -- Vector(5, 5, 5)
```

---


### Distance(vec2)


**Description:**


Calculates the distance between this vector and another vector.


**Parameters:**


* `vec2` (`Vector`) – The other vector.


**Realm:**


* Shared


**Returns:**


* `number` – The distance between the two vectors.


**Example Usage:**


```lua
-- Measure the distance between two points
local dist = vector_origin:Distance(Vector(3, 4, 0))
print(dist) -- 5
```

---


### RotateAroundAxis(axis, degrees)


**Description:**


Rotates the vector around an axis by the specified degrees and returns the new vector.


**Parameters:**


* `axis` (`Vector`) – Axis to rotate around.


* `degrees` (`number`) – Angle in degrees.


**Realm:**


* Shared


**Returns:**


* `Vector` – The rotated vector.


**Example Usage:**


```lua
-- Rotate a vector 90 degrees around the Z axis
local rotated = Vector(1, 0, 0):RotateAroundAxis(Vector(0, 0, 1), 90)
print(rotated) -- Vector(0, 1, 0)
```

---


### Right(vUp)


**Description:**


Returns a normalized right-direction vector relative to this vector.


**Parameters:**


* `vUp` (`Vector`, optional) – Up direction to compare against. Defaults to `vector_up`.


**Realm:**


* Shared


**Returns:**


* `Vector` – The calculated right vector.


**Example Usage:**


```lua
-- Get the right direction vector
local rightVec = Vector(0, 1, 0):Right()
print(rightVec)
```

---


### Up(vUp)


**Description:**


Returns a normalized up-direction vector relative to this vector.


**Parameters:**


* `vUp` (`Vector`, optional) – Up direction to compare against. Defaults to `vector_up`.


**Realm:**


* Shared


**Returns:**


* `Vector` – The calculated up vector.


**Example Usage:**


```lua
-- Get the up direction vector
local upVec = Vector(1, 0, 0):Up()
print(upVec)
```
