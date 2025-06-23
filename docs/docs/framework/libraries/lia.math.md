# lia.math

---

Various useful mathematical functions.

The `lia.math` library provides a collection of utility functions for performing common mathematical operations within the Lilia Framework. These functions facilitate unit conversions, probability checks, value biasing and gaining, value approaching, range checking, angle clamping, and value remapping. By utilizing these utilities, developers can streamline mathematical computations and enhance the functionality of their schemas and plugins.

---

## Functions

### **lia.math.UnitsToInches**

**Description:**  
Converts units to inches.

**Realm:**  
`Shared`

**Parameters:**  

- `units` (`number`):  
  The units to convert.

**Returns:**  
`number` - The equivalent measurement in inches.

**Example Usage:**
```lua
local inches = lia.math.UnitsToInches(10)
print("10 units is equal to", inches, "inches.")
-- Output: 10 units is equal to 7.5 inches.
```

---

### **lia.math.UnitsToCentimeters**

**Description:**  
Converts units to centimeters.

**Realm:**  
`Shared`

**Parameters:**  

- `units` (`number`):  
  The units to convert.

**Returns:**  
`number` - The equivalent measurement in centimeters.

**Example Usage:**
```lua
local centimeters = lia.math.UnitsToCentimeters(10)
print("10 units is equal to", centimeters, "centimeters.")
-- Output: 10 units is equal to 19.05 centimeters.
```

---

### **lia.math.UnitsToMeters**

**Description:**  
Converts units to meters.

**Realm:**  
`Shared`

**Parameters:**  

- `units` (`number`):  
  The units to convert.

**Returns:**  
`number` - The equivalent measurement in meters.

**Example Usage:**
```lua
local meters = lia.math.UnitsToMeters(10)
print("10 units is equal to", meters, "meters.")
-- Output: 10 units is equal to 0.1905 meters.
```

---

### **lia.math.chance**

**Description:**  
Determines success based on a given probability.

**Realm:**  
`Shared`

**Parameters:**  

- `chance` (`number`):  
  The probability of success in percentage.

**Returns:**  
`bool` - `True` if the chance is successful, `false` otherwise.

**Example Usage:**
```lua
if lia.math.chance(25) then
    print("Success!")
else
    print("Failure!")
end
```

---

### **lia.math.Bias**

**Description:**  
Applies a bias to a value based on a specified amount.

**Realm:**  
`Shared`

**Parameters:**  

- `x` (`number`):  
  The value to bias.

- `amount` (`number`):  
  The bias amount.

**Returns:**  
`number` - The biased value.

**Example Usage:**
```lua
local biasedValue = lia.math.Bias(2, 0.5)
print("Biased Value:", biasedValue)
```

---

### **lia.math.Gain**

**Description:**  
Applies a gain to a value based on a specified amount.

**Realm:**  
`Shared`

**Parameters:**  

- `x` (`number`):  
  The value to apply gain to.

- `amount` (`number`):  
  The gain amount.

**Returns:**  
`number` - The value with applied gain.

**Example Usage:**
```lua
local gainedValue = lia.math.Gain(0.3, 0.7)
print("Gained Value:", gainedValue)
```

---

### **lia.math.ApproachSpeed**

**Description:**  
Approaches a value towards a target value at a specified speed.

**Realm:**  
`Shared`

**Parameters:**  

- `start` (`number`):  
  The starting value.

- `dest` (`number`):  
  The target value.

- `speed` (`number`):  
  The speed at which to approach the target.

**Returns:**  
`number` - The approached value.

**Example Usage:**
```lua
local newValue = lia.math.ApproachSpeed(10, 20, 2)
print("Approached Value:", newValue)
```

---

### **lia.math.ApproachVectorSpeed**

**Description:**  
Approaches a vector towards a target vector at a specified speed.

**Realm:**  
`Shared`

**Parameters:**  

- `start` (`Vector`):  
  The starting vector.

- `dest` (`Vector`):  
  The target vector.

- `speed` (`number`):  
  The speed at which to approach the target.

**Returns:**  
`Vector` - The approached vector.

**Example Usage:**
```lua
local newVector = lia.math.ApproachVectorSpeed(Vector(0, 0, 0), Vector(10, 10, 10), 5)
print("Approached Vector:", newVector)
```

---

### **lia.math.ApproachAngleSpeed**

**Description:**  
Approaches an angle towards a target angle at a specified speed.

**Realm:**  
`Shared`

**Parameters:**  

- `start` (`Angle`):  
  The starting angle.

- `dest` (`Angle`):  
  The target angle.

- `speed` (`number`):  
  The speed at which to approach the target.

**Returns:**  
`Angle` - The approached angle.

**Example Usage:**
```lua
local newAngle = lia.math.ApproachAngleSpeed(Angle(0, 0, 0), Angle(90, 90, 90), 10)
print("Approached Angle:", newAngle)
```

---

### **lia.math.InRange**

**Description:**  
Checks if a value is within a specified range.

**Realm:**  
`Shared`

**Parameters:**  

- `val` (`number`):  
  The value to check.

- `min` (`number`):  
  The minimum value of the range.

- `max` (`number`):  
  The maximum value of the range.

**Returns:**  
`bool` - `True` if the value is within the range, `false` otherwise.

**Example Usage:**
```lua
if lia.math.InRange(5, 1, 10) then
    print("Value is within range.")
else
    print("Value is out of range.")
end
```

---

### **lia.math.ClampAngle**

**Description:**  
Clamps an angle to a specified range.

**Realm:**  
`Shared`

**Parameters:**  

- `val` (`Angle`):  
  The angle to clamp.

- `min` (`Angle`):  
  The minimum angle of the range.

- `max` (`Angle`):  
  The maximum angle of the range.

**Returns:**  
`Angle` - The clamped angle.

**Example Usage:**
```lua
local clampedAngle = lia.math.ClampAngle(Angle(100, 200, 300), Angle(0, 0, 0), Angle(90, 180, 270))
print("Clamped Angle:", clampedAngle)
```

---

### **lia.math.ClampedRemap**

**Description:**  
Remaps a value from one range to another and clamps it.

**Realm:**  
`Shared`

**Parameters:**  

- `val` (`number`):  
  The value to remap.

- `frommin` (`number`):  
  The minimum value of the original range.

- `frommax` (`number`):  
  The maximum value of the original range.

- `tomin` (`number`):  
  The minimum value of the target range.

- `tomax` (`number`):  
  The maximum value of the target range.

**Returns:**  
`number` - The remapped and clamped value.

**Example Usage:**
```lua
local remappedValue = lia.math.ClampedRemap(50, 0, 100, 0, 1)
print("Remapped Value:", remappedValue)
```

---
