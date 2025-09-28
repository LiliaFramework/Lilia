# RNDX (Advanced Rendering) Library

This page documents the advanced 2D rendering functions for creating rounded rectangles, circles, shadows, blur effects, and other visual elements with modern styling.

---

## Overview

The RNDX library (`lia.rndx`) provides a comprehensive set of functions for advanced 2D rendering in the Lilia framework, offering GPU-accelerated drawing with support for rounded corners, shadows, blur effects, textures, materials, and custom shapes. This library replaces traditional surface drawing methods with optimized shader-based rendering that provides smooth, high-quality visual elements. The system features sophisticated shape rendering with support for multiple corner radius configurations, advanced shadow effects with customizable spread and intensity, and GPU-accelerated blur effects for modern UI styling. It includes comprehensive material and texture support with automatic shader compilation, performance optimization through batching and caching, and flexible flag-based configuration for different rendering modes. The library provides seamless integration with the framework's UI system, offering consistent rendering across different screen resolutions and accessibility requirements. Additional features include outline rendering, rotation support, clipping capabilities, and extensive customization options that make it essential for creating polished, modern user interfaces with professional visual design.

---

## Drawing Functions

### Draw

**Purpose**

Draws a rounded rectangle with the specified parameters.

**Parameters**

* `r` (*number*): The radius for all corners (0 for square corners).
* `x` (*number*): The x position to draw at.
* `y` (*number*): The y position to draw at.
* `w` (*number*): The width of the rectangle.
* `h` (*number*): The height of the rectangle.
* `col` (*Color*): The color to draw with.
* `flags` (*number*): Optional flags to modify the drawing behavior.

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Draw a simple rounded rectangle
lia.rndx.Draw(8, 100, 100, 200, 100, Color(255, 0, 0))

-- Draw with custom flags
lia.rndx.Draw(12, 50, 50, 150, 80, Color(0, 255, 0), lia.rndx.SHAPE_IOS)

-- Draw without color (uses theme color)
lia.rndx.Draw(16, 10, 10, 100, 50, nil, lia.rndx.BLUR)
```

---

### DrawOutlined

**Purpose**

Draws an outlined rounded rectangle with the specified parameters.

**Parameters**

* `r` (*number*): The radius for all corners.
* `x` (*number*): The x position to draw at.
* `y` (*number*): The y position to draw at.
* `w` (*number*): The width of the rectangle.
* `h` (*number*): The height of the rectangle.
* `col` (*Color*): The color to draw with.
* `thickness` (*number*): The thickness of the outline.
* `flags` (*number*): Optional flags to modify the drawing behavior.

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Draw an outlined rectangle
lia.rndx.DrawOutlined(8, 100, 100, 200, 100, Color(255, 255, 0), 2)

-- Draw a thick outline
lia.rndx.DrawOutlined(12, 50, 50, 150, 80, Color(0, 0, 255), 5, lia.rndx.SHAPE_CIRCLE)

-- Draw with blur effect
lia.rndx.DrawOutlined(6, 25, 25, 100, 60, Color(255, 0, 255), 1, bit.bor(lia.rndx.BLUR, lia.rndx.SHAPE_IOS))
```

---

### DrawTexture

**Purpose**

Draws a texture within a rounded rectangle.

**Parameters**

* `r` (*number*): The radius for all corners.
* `x` (*number*): The x position to draw at.
* `y` (*number*): The y position to draw at.
* `w` (*number*): The width of the rectangle.
* `h` (*number*): The height of the rectangle.
* `col` (*Color*): The color tint to apply to the texture.
* `texture` (*string*): The texture to draw.
* `flags` (*number*): Optional flags to modify the drawing behavior.

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Draw a texture with rounded corners
lia.rndx.DrawTexture(8, 100, 100, 200, 100, Color(255, 255, 255), "path/to/texture")

-- Draw with custom shape
lia.rndx.DrawTexture(12, 50, 50, 150, 80, Color(255, 255, 255, 128), "materials/icon.png", lia.rndx.SHAPE_CIRCLE)

-- Draw with blur effect
lia.rndx.DrawTexture(6, 25, 25, 100, 60, Color(255, 255, 255), "materials/background.jpg", lia.rndx.BLUR)
```

---

### DrawMaterial

**Purpose**

Draws a material within a rounded rectangle.

**Parameters**

* `r` (*number*): The radius for all corners.
* `x` (*number*): The x position to draw at.
* `y` (*number*): The y position to draw at.
* `w` (*number*): The width of the rectangle.
* `h` (*number*): The height of the rectangle.
* `col` (*Color*): The color tint to apply to the material.
* `mat` (*IMaterial*): The material to draw.
* `flags` (*number*): Optional flags to modify the drawing behavior.

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Draw a material
local mat = Material("materials/my_material")
lia.rndx.DrawMaterial(8, 100, 100, 200, 100, Color(255, 255, 255), mat)

-- Draw with custom flags
lia.rndx.DrawMaterial(12, 50, 50, 150, 80, Color(255, 0, 0, 128), mat, lia.rndx.SHAPE_IOS)
```

---

### DrawCircle

**Purpose**

Draws a circle with the specified parameters.

**Parameters**

* `x` (*number*): The x position of the center.
* `y` (*number*): The y position of the center.
* `r` (*number*): The radius of the circle.
* `col` (*Color*): The color to draw with.
* `flags` (*number*): Optional flags to modify the drawing behavior.

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Draw a simple circle
lia.rndx.DrawCircle(100, 100, 50, Color(255, 0, 0))

-- Draw with blur effect
lia.rndx.DrawCircle(200, 150, 75, Color(0, 255, 0), lia.rndx.BLUR)

-- Draw with custom shape (creates oval effect)
lia.rndx.DrawCircle(300, 200, 60, Color(0, 0, 255), lia.rndx.SHAPE_IOS)
```

---

### DrawCircleOutlined

**Purpose**

Draws an outlined circle with the specified parameters.

**Parameters**

* `x` (*number*): The x position of the center.
* `y` (*number*): The y position of the center.
* `r` (*number*): The radius of the circle.
* `col` (*Color*): The color to draw with.
* `thickness` (*number*): The thickness of the outline.
* `flags` (*number*): Optional flags to modify the drawing behavior.

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Draw an outlined circle
lia.rndx.DrawCircleOutlined(100, 100, 50, Color(255, 255, 0), 2)

-- Draw a thick outline
lia.rndx.DrawCircleOutlined(200, 150, 75, Color(255, 0, 255), 5)

-- Draw with blur effect
lia.rndx.DrawCircleOutlined(300, 200, 60, Color(0, 255, 255), 1, lia.rndx.BLUR)
```

---

### DrawCircleTexture

**Purpose**

Draws a texture within a circle.

**Parameters**

* `x` (*number*): The x position of the center.
* `y` (*number*): The y position of the center.
* `r` (*number*): The radius of the circle.
* `col` (*Color*): The color tint to apply to the texture.
* `texture` (*string*): The texture to draw.
* `flags` (*number*): Optional flags to modify the drawing behavior.

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Draw a texture in a circle
lia.rndx.DrawCircleTexture(100, 100, 50, Color(255, 255, 255), "materials/avatar.png")

-- Draw with blur effect
lia.rndx.DrawCircleTexture(200, 150, 75, Color(255, 255, 255, 128), "materials/logo.png", lia.rndx.BLUR)
```

---

### DrawCircleMaterial

**Purpose**

Draws a material within a circle.

**Parameters**

* `x` (*number*): The x position of the center.
* `y` (*number*): The y position of the center.
* `r` (*number*): The radius of the circle.
* `col` (*Color*): The color tint to apply to the material.
* `mat` (*IMaterial*): The material to draw.
* `flags` (*number*): Optional flags to modify the drawing behavior.

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Draw a material in a circle
local mat = Material("materials/circular_material")
lia.rndx.DrawCircleMaterial(100, 100, 50, Color(255, 255, 255), mat)

-- Draw with blur effect
lia.rndx.DrawCircleMaterial(200, 150, 75, Color(255, 255, 255, 128), mat, lia.rndx.BLUR)
```

---

### DrawBlur

**Purpose**

Draws a blurred rounded rectangle with the specified parameters.

**Parameters**

* `x` (*number*): The x position to draw at.
* `y` (*number*): The y position to draw at.
* `w` (*number*): The width of the rectangle.
* `h` (*number*): The height of the rectangle.
* `flags` (*number*): Optional flags to modify the drawing behavior.
* `tl` (*number*): Top-left corner radius.
* `tr` (*number*): Top-right corner radius.
* `bl` (*number*): Bottom-left corner radius.
* `br` (*number*): Bottom-right corner radius.
* `thickness` (*number*): The blur thickness.

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Draw a simple blur effect
lia.rndx.DrawBlur(100, 100, 200, 100)

-- Draw with custom corner radii
lia.rndx.DrawBlur(50, 50, 150, 80, nil, 10, 10, 0, 0, 2)

-- Draw with different flags
lia.rndx.DrawBlur(25, 25, 100, 60, lia.rndx.SHAPE_CIRCLE, 8, 8, 8, 8, 1)
```

---

### DrawShadows

**Purpose**

Draws a rounded rectangle with shadow effect.

**Parameters**

* `r` (*number*): The radius for all corners.
* `x` (*number*): The x position to draw at.
* `y` (*number*): The y position to draw at.
* `w` (*number*): The width of the rectangle.
* `h` (*number*): The height of the rectangle.
* `col` (*Color*): The shadow color.
* `spread` (*number*): The shadow spread distance.
* `intensity` (*number*): The shadow intensity.
* `flags` (*number*): Optional flags to modify the drawing behavior.

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Draw a rectangle with shadow
lia.rndx.DrawShadows(8, 100, 100, 200, 100, Color(0, 0, 0, 128), 10, 20)

-- Draw with custom shape
lia.rndx.DrawShadows(12, 50, 50, 150, 80, Color(0, 0, 0, 100), 5, 15, lia.rndx.SHAPE_CIRCLE)

-- Draw with blur effect
lia.rndx.DrawShadows(6, 25, 25, 100, 60, Color(0, 0, 0, 80), 8, 12, bit.bor(lia.rndx.BLUR, lia.rndx.SHAPE_IOS))
```

---

### DrawShadowsEx

**Purpose**

Draws a rounded rectangle with advanced shadow effect with individual corner radius control.

**Parameters**

* `x` (*number*): The x position to draw at.
* `y` (*number*): The y position to draw at.
* `w` (*number*): The width of the rectangle.
* `h` (*number*): The height of the rectangle.
* `col` (*Color*): The shadow color.
* `flags` (*number*): Optional flags to modify the drawing behavior.
* `tl` (*number*): Top-left corner radius.
* `tr` (*number*): Top-right corner radius.
* `bl` (*number*): Bottom-left corner radius.
* `br` (*number*): Bottom-right corner radius.
* `spread` (*number*): The shadow spread distance.
* `intensity` (*number*): The shadow intensity.
* `thickness` (*number*): The outline thickness.

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Draw advanced shadow with individual corners
lia.rndx.DrawShadowsEx(100, 100, 200, 100, Color(0, 0, 0, 128), nil, 10, 20, 5, 15, 8, 16, 1)

-- Draw with custom flags and shape
lia.rndx.DrawShadowsEx(50, 50, 150, 80, Color(0, 0, 0, 100), lia.rndx.SHAPE_CIRCLE, 12, 12, 0, 0, 5, 10, 2)
```

---

### DrawShadowsOutlined

**Purpose**

Draws an outlined rounded rectangle with shadow effect.

**Parameters**

* `r` (*number*): The radius for all corners.
* `x` (*number*): The x position to draw at.
* `y` (*number*): The y position to draw at.
* `w` (*number*): The width of the rectangle.
* `h` (*number*): The height of the rectangle.
* `col` (*Color*): The shadow color.
* `thickness` (*number*): The outline thickness.
* `spread` (*number*): The shadow spread distance.
* `intensity` (*number*): The shadow intensity.
* `flags` (*number*): Optional flags to modify the drawing behavior.

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Draw outlined rectangle with shadow
lia.rndx.DrawShadowsOutlined(8, 100, 100, 200, 100, Color(0, 0, 0, 128), 2, 10, 20)

-- Draw with custom shape and blur
lia.rndx.DrawShadowsOutlined(12, 50, 50, 150, 80, Color(0, 0, 0, 100), 3, 5, 15, lia.rndx.SHAPE_IOS)
```

---

## Utility Functions

### SetFlag

**Purpose**

Sets or unsets a flag in a flags value using bitwise operations.

**Parameters**

* `flags` (*number*): The current flags value.
* `flag` (*number* or *string*): The flag to set/unset.
* `bool` (*boolean*): Whether to set (true) or unset (false) the flag.

**Returns**

* `newFlags` (*number*): The modified flags value.

**Realm**

Client.

**Example Usage**

```lua
-- Set a flag
local flags = lia.rndx.SetFlag(0, lia.rndx.BLUR, true)

-- Unset a flag
flags = lia.rndx.SetFlag(flags, lia.rndx.SHAPE_CIRCLE, false)

-- Set multiple flags
flags = lia.rndx.SetFlag(flags, lia.rndx.NO_TL, true)
flags = lia.rndx.SetFlag(flags, lia.rndx.NO_TR, true)

-- Set flag by string name
flags = lia.rndx.SetFlag(flags, "BLUR", true)
```

---

### SetDefaultShape

**Purpose**

Sets the default shape used when drawing without explicit shape flags.

**Parameters**

* `shape` (*number*): The shape constant to use as default.

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Set default shape to iOS-style
lia.rndx.SetDefaultShape(lia.rndx.SHAPE_IOS)

-- Set default shape to circle
lia.rndx.SetDefaultShape(lia.rndx.SHAPE_CIRCLE)

-- Reset to default (Figma-style)
lia.rndx.SetDefaultShape(lia.rndx.SHAPE_FIGMA)
```

---

## Advanced Usage

### Method Chaining

The RNDX library supports method chaining for complex drawing operations:

```lua
-- Create a rectangle with multiple properties
lia.rndx.Rect(100, 100, 200, 100)
    :Radii(10, 20, 10, 20)
    :Color(Color(255, 0, 0))
    :Shadow(15, 30)
    :Blur(2)
    :Outline(2)
    :Draw()

-- Create a circle with custom properties
lia.rndx.Circle(200, 200, 50)
    :Color(Color(0, 255, 0))
    :Shadow(10, 20)
    :Texture("materials/pattern.png")
    :Draw()
```

### Custom Shapes and Effects

```lua
-- Draw with custom corner radii
lia.rndx.Draw(0, 100, 100, 200, 100, Color(255, 0, 0),
    bit.bor(lia.rndx.NO_TL, lia.rndx.NO_BR), 0, 20, 0, 20)

-- Draw with rotation and clipping
lia.rndx.Rect(100, 100, 200, 100)
    :Color(Color(0, 0, 255))
    :Rotation(45)
    :Clip(panel)
    :Draw()
```

### Performance Optimization

```lua
-- Batch multiple drawing operations
local function drawComplexUI()
    -- Draw background with shadow
    lia.rndx.DrawShadows(8, 0, 0, ScrW(), 50, Color(0, 0, 0, 100), 5, 10)

    -- Draw multiple buttons efficiently
    for i = 1, 10 do
        local x = (i - 1) * 60
        lia.rndx.Draw(4, x, 10, 50, 30, Color(100, 100, 100),
            i == 5 and lia.rndx.SHAPE_CIRCLE or 0)
    end
end
```

---

## Constants

### Shape Constants

* `lia.rndx.SHAPE_CIRCLE` - Perfect circle shape
* `lia.rndx.SHAPE_FIGMA` - Figma-style rounded corners (default)
* `lia.rndx.SHAPE_IOS` - iOS-style rounded corners

### Corner Constants

* `lia.rndx.NO_TL` - No top-left corner radius
* `lia.rndx.NO_TR` - No top-right corner radius
* `lia.rndx.NO_BL` - No bottom-left corner radius
* `lia.rndx.NO_BR` - No bottom-right corner radius

### Effect Constants

* `lia.rndx.BLUR` - Enable blur effect
* `lia.rndx.MANUAL_COLOR` - Use manual color mode
