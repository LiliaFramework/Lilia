# lia.color

---

The `lia.color` library provides a set of utility functions for manipulating and handling colors within the Lilia framework. This includes adjusting color components, converting colors to hexadecimal strings, creating dynamic color effects like rainbows and color cycles, and blending colors. These functions are essential for creating visually appealing interfaces and effects in your schema.

**NOTE:** Always ensure that color values are within the valid range (0-255) to prevent unexpected behavior or errors.

---

### **lia.color.Adjust**

**Description:**  
Adjusts the components of a color by the specified offsets.

**Realm:**  
`Client`

**Parameters:**  

- `color` (`Color`): The color to adjust (expects a table with `r`, `g`, `b`, and optionally `a` values).
- `rOffset` (`number`): The offset to apply to the red component.
- `gOffset` (`number`): The offset to apply to the green component.
- `bOffset` (`number`): The offset to apply to the blue component.
- `aOffset` (`number`, optional, default `0`): The offset to apply to the alpha component.

**Returns:**  
`Color` - The adjusted color as a new color table.

**Example Usage:**
```lua
local originalColor = Color(100, 150, 200, 255)
local newColor = lia.color.Adjust(originalColor, 10, -20, 30)
print(newColor) -- Outputs: Color(110, 130, 230, 255)
```

---

### **lia.color.ColorToHex**

**Description:**  
Converts a color to a hexadecimal string.

**Realm:**  
`Client`

**Parameters:**  

- `color` (`Color`): The color to convert.

**Returns:**  
`string` - The hexadecimal color code.

**Example Usage:**
```lua
local color = Color(255, 0, 0)
local hex = lia.color.ColorToHex(color)
print(hex) -- Outputs: "0xFF0000"
```

---

### **lia.color.Lighten**

**Description:**  
Lightens a color by the specified amount.

**Realm:**  
`Client`

**Parameters:**  

- `color` (`Color`): The color to lighten.
- `amount` (`number`): The amount by which to lighten the color.

**Returns:**  
`Color` - The resulting lightened color.

**Example Usage:**
```lua
local darkColor = Color(50, 50, 50)
local lightColor = lia.color.Lighten(darkColor, 0.2)
print(lightColor) -- Outputs a lighter shade of the original color
```

---

### **lia.color.Rainbow**

**Description:**  
Returns a color that cycles through the hues of the HSV color spectrum.

**Realm:**  
`Client`

**Parameters:**  

- `frequency` (`number`): The speed at which the color cycles through hues.

**Returns:**  
`Color` - The color object with the current hue.

**Example Usage:**
```lua
hook.Add("Think", "RainbowColor", function()
    local rainbowColor = lia.color.Rainbow(30)
    surface.SetDrawColor(rainbowColor)
    surface.DrawRect(10, 10, 100, 100)
end)
```

---

### **lia.color.ColorCycle**

**Description:**  
Returns a color that smoothly transitions between two given colors.

**Realm:**  
`Client`

**Parameters:**  

- `col1` (`Color`): The first color.
- `col2` (`Color`): The second color.
- `freq` (`number`): The frequency of the color transition.

**Returns:**  
`Color` - The color resulting from the transition.

**Example Usage:**
```lua
hook.Add("Think", "ColorCycleExample", function()
    local cyclingColor = lia.color.ColorCycle(Color(255, 0, 0), Color(0, 0, 255), 1)
    surface.SetDrawColor(cyclingColor)
    surface.DrawRect(120, 10, 100, 100)
end)
```

---

### **lia.color.toText**

**Description:**  
Converts a color object to a string representation.

**Realm:**  
`Client`

**Parameters:**  

- `color` (`Color`): The color object to convert.

**Returns:**  
`string` - A string representation of the color in the format `"r,g,b,a"`.

**Example Usage:**
```lua
local color = Color(255, 255, 255, 255)
local colorText = lia.color.toText(color)
print(colorText) -- Outputs: "255,255,255,255"
```

---

### **lia.color.Darken**

**Description:**  
Darkens a color by the specified amount.

**Realm:**  
`Client`

**Parameters:**  

- `color` (`Color`): The color to darken.
- `amount` (`number`): The amount by which to darken the color.

**Returns:**  
`Color` - The resulting darkened color.

**Example Usage:**
```lua
local lightColor = Color(200, 200, 200)
local darkColor = lia.color.Darken(lightColor, 0.3)
print(darkColor) -- Outputs a darker shade of the original color
```

---

### **lia.color.Blend**

**Description:**  
Blends two colors together by a specified ratio.

**Realm:**  
`Client`

**Parameters:**  

- `color1` (`Color`): The first color.
- `color2` (`Color`): The second color.
- `ratio` (`number`): The blend ratio (`0.0` to `1.0`).

**Returns:**  
`Color` - The resulting blended color.

**Example Usage:**
```lua
local colorA = Color(255, 0, 0)
local colorB = Color(0, 0, 255)
local blendedColor = lia.color.Blend(colorA, colorB, 0.5)
print(blendedColor) -- Outputs: Color(127, 0, 127)
```

---

### **lia.color.rgb**

**Description:**  
Converts RGB values to a `Color` object.

**Realm:**  
`Client`

**Parameters:**  

- `r` (`integer`): The red component (`0-255`).
- `g` (`integer`): The green component (`0-255`).
- `b` (`integer`): The blue component (`0-255`).

**Returns:**  
`Color` - The resulting color.

**Example Usage:**
```lua
local color = lia.color.rgb(128, 64, 255)
print(color) -- Outputs: Color(128, 64, 255, 255)
```

---

### **lia.color.LerpColor**

**Description:**  
Linearly interpolates between two colors.

**Realm:**  
`Client`

**Parameters:**  

- `frac` (`number`): A fraction between `0` and `1` representing the interpolation amount.
- `from` (`Color`): The starting color (a table with `r`, `g`, `b`, and `a` fields).
- `to` (`Color`): The target color (a table with `r`, `g`, `b`, and `a` fields).

**Returns:**  
`Color` - The resulting interpolated color.

**Example Usage:**
```lua
local startColor = Color(255, 0, 0)
local endColor = Color(0, 0, 255)
local interpolatedColor = lia.color.LerpColor(0.5, startColor, endColor)
print(interpolatedColor) -- Outputs: Color(127.5, 0, 127.5, 255)
```

---

### **lia.color.ReturnMainAdjustedColors**

**Description:**  
Returns a table of adjusted colors based on a base color. This function calculates a set of colors for use in a UI, including background, sidebar, accent, text, hover, border, and highlight colors. These colors are derived by adjusting the provided base color using various offsets.

**Realm:**  
`Client`

**Returns:**  
`table` - A table containing the adjusted colors with the following keys:

- `background`: Adjusted background color.
- `sidebar`: Adjusted sidebar color.
- `accent`: Accent color (base color).
- `text`: Text color.
- `hover`: Adjusted hover color.
- `border`: Border color.
- `highlight`: Highlight color.

**Example Usage:**
```lua
local adjustedColors = lia.color.ReturnMainAdjustedColors()
surface.SetDrawColor(adjustedColors.background)
surface.DrawRect(0, 0, 200, 200)
```

---

### **lia.color.LerpHSV**

**Description:**  
Interpolates between two colors in the HSV color space.

**Realm:**  
`Client`

**Parameters:**  

- `start_color` (`Color`): The starting color.
- `end_color` (`Color`): The ending color.
- `maxValue` (`integer`): The maximum value to interpolate between (used for normalization).
- `currentValue` (`integer`): The current value to interpolate (used for normalization).
- `minValue` (`integer`, optional, default `0`): The minimum value to interpolate between (used for normalization).

**Returns:**  
`Color` - The resulting interpolated color.

**Example Usage:**
```lua
local startHSV = Color(255, 0, 0) -- Red
local endHSV = Color(0, 255, 0)   -- Green
local interpolatedColor = lia.color.LerpHSV(startHSV, endHSV, 100, 50)
print(interpolatedColor) -- Outputs a color halfway between red and green in HSV space
```

---