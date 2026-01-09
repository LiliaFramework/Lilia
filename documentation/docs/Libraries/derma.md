# Derma Library

Advanced UI rendering and interaction system for the Lilia framework.

---

Overview

The derma library provides comprehensive UI rendering and interaction functionality for the Lilia framework. It handles advanced drawing operations including rounded rectangles, circles, shadows, blur effects, and gradients using custom shaders. The library offers a fluent API for creating complex UI elements with smooth animations, color pickers, player selectors, and various input dialogs. It includes utility functions for text rendering with shadows and outlines, entity text display, and menu positioning. The library operates primarily on the client side and provides both low-level drawing functions and high-level UI components for creating modern, visually appealing interfaces.

---

### lia.derma.dermaMenu

#### 📋 Purpose
Opens a fresh `liaDermaMenu` at the current cursor position and tracks it in `lia.gui.menuDermaMenu`.

#### ⏰ When Called
Use when you need a standard context menu for interaction options and want any previous one closed first.

#### ↩️ Returns
* Panel
The newly created `liaDermaMenu` panel.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    local menu = lia.derma.dermaMenu()
    menu:AddOption("Say hi", function() chat.AddText("hi") end)
    menu:Open()

```

---

### lia.derma.optionsMenu

#### 📋 Purpose
Builds and shows the configurable options/interaction menu, filtering and categorising provided options before rendering buttons.

#### ⏰ When Called
Use when presenting interaction, action, or custom options to the player, optionally tied to a targeted entity and network message.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `rawOptions` | **table** | Option definitions keyed by id or stored in an array; entries can include `type`, `range`, `target`, `shouldShow`, `callback`, and `onSelect`. |
| `config` | **table** | Optional settings such as `mode` ("interaction", "action", or "custom"), `entity`, `netMsg`, `preFiltered`, `registryKey`, sizing fields, and behaviour toggles like `closeOnSelect`. |

#### ↩️ Returns
* Panel|nil
The created frame when options are available; otherwise nil.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    lia.derma.optionsMenu({
        greet = {type = "action", callback = function(client) chat.AddText(client, " waves") end}
    }, {mode = "action"})

```

---

### lia.derma.requestColorPicker

#### 📋 Purpose
Displays a modal color picker window that lets the user pick a hue and saturation/value, then returns the chosen color.

#### ⏰ When Called
Use when you need the player to choose a color for a UI element or configuration field.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `func` | **function** | Callback invoked with the selected Color when the user confirms. |
| `colorStandard` | **Color** | Optional starting color; defaults to white. |

#### ↩️ Returns
* nil
Operates through UI side effects and the supplied callback.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    lia.derma.requestColorPicker(function(col) print("Picked", col) end, Color(0, 200, 255))

```

---

### lia.derma.radialMenu

#### 📋 Purpose
Spawns a radial selection menu using `liaRadialPanel` and stores the reference on `lia.gui.menu_radial`.

#### ⏰ When Called
Use for quick circular option pickers, such as pie-menu interactions.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `options` | **table** | Table passed directly to `liaRadialPanel:Init`, defining each radial entry. |

#### ↩️ Returns
* Panel
The created `liaRadialPanel` instance.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    lia.derma.radialMenu({{label = "Yes", callback = function() print("yes") end}})

```

---

### lia.derma.requestPlayerSelector

#### 📋 Purpose
Opens a player selector window listing all connected players and runs a callback when one is chosen.

#### ⏰ When Called
Use when an action needs the user to target a specific player from the current server list.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `doClick` | **function** | Called with the selected player entity after the user clicks a card. |

#### ↩️ Returns
* Panel
The created selector frame stored on `lia.gui.menuPlayerSelector`.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    lia.derma.requestPlayerSelector(function(pl) chat.AddText("Selected ", pl:Name()) end)

```

---

### lia.derma.draw

#### 📋 Purpose
Draws a rounded rectangle using the shader-based derma pipeline with the same radius on every corner.

#### ⏰ When Called
Use when rendering a simple rounded box with optional shape or blur flags.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `radius` | **number** | Corner radius to apply to all corners. |
| `x` | **number** | X position of the box. |
| `y` | **number** | Y position of the box. |
| `w` | **number** | Width of the box. |
| `h` | **number** | Height of the box. |
| `col` | **Color|nil** | Fill color; defaults to solid white if omitted. |
| `flags` | **number|nil** | Optional bitmask using `lia.derma` flag constants (shape, blur, corner suppression). |

#### ↩️ Returns
* nil
Draws directly to the screen.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    lia.derma.draw(8, 10, 10, 140, 48, Color(30, 30, 30, 220))

```

---

### lia.derma.drawOutlined

#### 📋 Purpose
Draws only the outline of a rounded rectangle with configurable thickness.

#### ⏰ When Called
Use when you need a stroked rounded box while leaving the interior transparent.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `radius` | **number** | Corner radius for all corners. |
| `x` | **number** | X position of the outline. |
| `y` | **number** | Y position of the outline. |
| `w` | **number** | Width of the outline box. |
| `h` | **number** | Height of the outline box. |
| `col` | **Color|nil** | Outline color; defaults to white when nil. |
| `thickness` | **number|nil** | Outline thickness in pixels; defaults to 1. |
| `flags` | **number|nil** | Optional bitmask using `lia.derma` flags. |

#### ↩️ Returns
* nil
Draws directly to the screen.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    lia.derma.drawOutlined(10, 20, 20, 180, 60, lia.color.theme.text, 2)

```

---

### lia.derma.drawTexture

#### 📋 Purpose
Draws a rounded rectangle filled with the provided texture.

#### ⏰ When Called
Use when you need a textured rounded box instead of a solid color.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `radius` | **number** | Corner radius for all corners. |
| `x` | **number** | X position. |
| `y` | **number** | Y position. |
| `w` | **number** | Width. |
| `h` | **number** | Height. |
| `col` | **Color|nil** | Modulation color for the texture; defaults to white. |
| `texture` | **ITexture** | Texture handle to apply to the rectangle. |
| `flags` | **number|nil** | Optional bitmask using `lia.derma` flags. |

#### ↩️ Returns
* nil
Draws directly to the screen.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    local tex = Material("vgui/gradient-u"):GetTexture("$basetexture")
    lia.derma.drawTexture(6, 50, 50, 128, 64, color_white, tex)

```

---

### lia.derma.drawMaterial

#### 📋 Purpose
Convenience wrapper that draws a rounded rectangle using the base texture from a material.

#### ⏰ When Called
Use when you have an `IMaterial` and want its base texture applied to a rounded box.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `radius` | **number** | Corner radius for all corners. |
| `x` | **number** | X position. |
| `y` | **number** | Y position. |
| `w` | **number** | Width. |
| `h` | **number** | Height. |
| `col` | **Color|nil** | Color modulation for the material. |
| `mat` | **IMaterial** | Material whose base texture will be drawn. |
| `flags` | **number|nil** | Optional bitmask using `lia.derma` flags. |

#### ↩️ Returns
* nil
Draws directly to the screen.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    lia.derma.drawMaterial(6, 80, 80, 100, 40, color_white, Material("vgui/gradient-d"))

```

---

### lia.derma.drawCircle

#### 📋 Purpose
Draws a filled circle using the rounded rectangle shader configured for circular output.

#### ⏰ When Called
Use when you need a smooth circle without manually handling radii or shapes.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `x` | **number** | Center X position. |
| `y` | **number** | Center Y position. |
| `radius` | **number** | Circle diameter; internally halved for corner radii. |
| `col` | **Color|nil** | Fill color; defaults to white. |
| `flags` | **number|nil** | Optional bitmask using `lia.derma` flags. |

#### ↩️ Returns
* nil
Draws directly to the screen.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    lia.derma.drawCircle(100, 100, 48, Color(200, 80, 80, 255))

```

---

### lia.derma.drawCircleOutlined

#### 📋 Purpose
Draws only the outline of a circle with configurable thickness.

#### ⏰ When Called
Use for circular strokes such as selection rings or markers.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `x` | **number** | Center X position. |
| `y` | **number** | Center Y position. |
| `radius` | **number** | Circle diameter. |
| `col` | **Color|nil** | Outline color. |
| `thickness` | **number|nil** | Outline thickness; defaults to 1. |
| `flags` | **number|nil** | Optional bitmask using `lia.derma` flags. |

#### ↩️ Returns
* nil
Draws directly to the screen.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    lia.derma.drawCircleOutlined(200, 120, 40, lia.color.theme.accent, 2)

```

---

### lia.derma.drawCircleTexture

#### 📋 Purpose
Draws a textured circle using a supplied texture handle.

#### ⏰ When Called
Use when you want a circular render that uses a specific texture rather than a solid color.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `x` | **number** | Center X position. |
| `y` | **number** | Center Y position. |
| `radius` | **number** | Circle diameter. |
| `col` | **Color|nil** | Color modulation for the texture. |
| `texture` | **ITexture** | Texture handle to apply. |
| `flags` | **number|nil** | Optional bitmask using `lia.derma` flags. |

#### ↩️ Returns
* nil
Draws directly to the screen.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    lia.derma.drawCircleTexture(64, 64, 32, color_white, Material("icon16/star.png"):GetTexture("$basetexture"))

```

---

### lia.derma.drawCircleMaterial

#### 📋 Purpose
Draws a textured circle using the base texture from an `IMaterial`.

#### ⏰ When Called
Use when you have a material and need to render its base texture within a circular mask.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `x` | **number** | Center X position. |
| `y` | **number** | Center Y position. |
| `radius` | **number** | Circle diameter. |
| `col` | **Color|nil** | Color modulation for the material. |
| `mat` | **IMaterial** | Material whose base texture will be drawn. |
| `flags` | **number|nil** | Optional bitmask using `lia.derma` flags. |

#### ↩️ Returns
* nil
Draws directly to the screen.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    lia.derma.drawCircleMaterial(48, 48, 28, color_white, Material("vgui/gradient-l"))

```

---

### lia.derma.drawBlur

#### 📋 Purpose
Renders a blurred rounded shape using the blur shader while respecting per-corner radii and optional outline thickness.

#### ⏰ When Called
Use to blur a rectangular region (or other supported shapes) without drawing a solid fill.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `x` | **number** | X position of the blurred region. |
| `y` | **number** | Y position of the blurred region. |
| `w` | **number** | Width of the blurred region. |
| `h` | **number** | Height of the blurred region. |
| `flags` | **number|nil** | Bitmask using `lia.derma` flags to control shape, blur, and disabled corners. |
| `tl` | **number|nil** | Top-left radius override. |
| `Top` | **unknown** | left radius override. |
| `Top` | **unknown** | left radius override. |
| `tr` | **number|nil** | Top-right radius override. |
| `Top` | **unknown** | right radius override. |
| `Top` | **unknown** | right radius override. |
| `bl` | **number|nil** | Bottom-left radius override. |
| `Bottom` | **unknown** | left radius override. |
| `Bottom` | **unknown** | left radius override. |
| `br` | **number|nil** | Bottom-right radius override. |
| `Bottom` | **unknown** | right radius override. |
| `Bottom` | **unknown** | right radius override. |
| `thickness` | **number|nil** | Optional outline thickness for partial arcs. |

#### ↩️ Returns
* nil
Draws directly to the screen.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    lia.derma.drawBlur(0, 0, 220, 80, lia.derma.BLUR, 12, 12, 12, 12)

```

---

### lia.derma.drawShadowsEx

#### 📋 Purpose
Draws a configurable drop shadow behind a rounded shape, optionally using blur and manual color control.

#### ⏰ When Called
Use when you want a soft shadow around a shape with fine control over radii, spread, intensity, and flags.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `x` | **number** | X position of the shape casting the shadow. |
| `y` | **number** | Y position of the shape casting the shadow. |
| `w` | **number** | Width of the shape. |
| `h` | **number** | Height of the shape. |
| `col` | **Color|nil|boolean** | Shadow color; pass `false` to skip color modulation. |
| `flags` | **number|nil** | Bitmask using `lia.derma` flags (shape, blur, corner suppression). |
| `tl` | **number|nil** | Top-left radius override. |
| `Top` | **unknown** | left radius override. |
| `Top` | **unknown** | left radius override. |
| `tr` | **number|nil** | Top-right radius override. |
| `Top` | **unknown** | right radius override. |
| `Top` | **unknown** | right radius override. |
| `bl` | **number|nil** | Bottom-left radius override. |
| `Bottom` | **unknown** | left radius override. |
| `Bottom` | **unknown** | left radius override. |
| `br` | **number|nil** | Bottom-right radius override. |
| `Bottom` | **unknown** | right radius override. |
| `Bottom` | **unknown** | right radius override. |
| `spread` | **number|nil** | Pixel spread of the shadow; defaults to 30. |
| `intensity` | **number|nil** | Shadow alpha scaling; defaults to `spread * 1.2`. |
| `thickness` | **number|nil** | Optional outline thickness when rendering arcs. |

#### ↩️ Returns
* nil
Draws directly to the screen.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    lia.derma.drawShadowsEx(40, 40, 200, 80, Color(0, 0, 0, 180), nil, 12, 12, 12, 12, 26, 32)

```

---

### lia.derma.drawShadows

#### 📋 Purpose
Convenience wrapper to draw a drop shadow with the same radius on every corner.

#### ⏰ When Called
Use when you need a uniform-radius shadow without manually specifying each corner.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `radius` | **number** | Radius applied to all corners. |
| `x` | **number** | X position. |
| `y` | **number** | Y position. |
| `w` | **number** | Width. |
| `h` | **number** | Height. |
| `col` | **Color|nil** | Shadow color. |
| `spread` | **number|nil** | Pixel spread of the shadow. |
| `intensity` | **number|nil** | Shadow alpha scaling. |
| `flags` | **number|nil** | Optional bitmask using `lia.derma` flags. |

#### ↩️ Returns
* nil
Draws directly to the screen.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    lia.derma.drawShadows(10, 60, 60, 180, 70, Color(0, 0, 0, 150))

```

---

### lia.derma.drawShadowsOutlined

#### 📋 Purpose
Convenience wrapper that draws only the shadow outline for a uniform-radius shape.

#### ⏰ When Called
Use when you need a stroked shadow ring around a rounded box.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `radius` | **number** | Radius applied to all corners. |
| `x` | **number** | X position. |
| `y` | **number** | Y position. |
| `w` | **number** | Width. |
| `h` | **number** | Height. |
| `col` | **Color|nil** | Shadow color. |
| `thickness` | **number|nil** | Outline thickness for the shadow. |
| `spread` | **number|nil** | Pixel spread of the shadow. |
| `intensity` | **number|nil** | Shadow alpha scaling. |
| `flags` | **number|nil** | Optional bitmask using `lia.derma` flags. |

#### ↩️ Returns
* nil
Draws directly to the screen.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    lia.derma.drawShadowsOutlined(12, 40, 40, 160, 60, Color(0, 0, 0, 180), 2)

```

---

### lia.derma.rect

#### 📋 Purpose
Starts a chainable rectangle draw builder using the derma shader helpers.

#### ⏰ When Called
Use when you want to configure a rectangle (radius, color, outline, blur, etc.) through a fluent API before drawing.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `x` | **number** | X position of the rectangle. |
| `y` | **number** | Y position of the rectangle. |
| `w` | **number** | Width of the rectangle. |
| `h` | **number** | Height of the rectangle. |

#### ↩️ Returns
* table
Chainable rectangle builder supporting methods like `:Rad`, `:Color`, `:Outline`, and `:Draw`.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    lia.derma.rect(12, 12, 220, 80):Rad(10):Color(Color(40, 40, 40, 220)):Shadow():Draw()

```

---

### lia.derma.circle

#### 📋 Purpose
Starts a chainable circle draw builder using the derma shader helpers.

#### ⏰ When Called
Use when you want to configure a circle (color, outline, blur, etc.) before drawing it.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `x` | **number** | Center X position. |
| `y` | **number** | Center Y position. |
| `r` | **number** | Circle diameter. |

#### ↩️ Returns
* table
Chainable circle builder supporting methods like `:Color`, `:Outline`, `:Shadow`, and `:Draw`.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    lia.derma.circle(100, 100, 50):Color(lia.color.theme.accent):Outline(2):Draw()

```

---

### lia.derma.setFlag

#### 📋 Purpose
Sets or clears a specific drawing flag on a bitmask using a flag value or named constant.

#### ⏰ When Called
Use when toggling derma drawing flags such as shapes or corner suppression.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `flags` | **number** | Current flag bitmask. |
| `flag` | **number|string** | Flag value or key in `lia.derma` (e.g., "BLUR"). |
| `bool` | **boolean** | Whether to enable (`true`) or disable (`false`) the flag. |

#### ↩️ Returns
* number
Updated flag bitmask.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    flags = lia.derma.setFlag(flags, "BLUR", true)

```

---

### lia.derma.setDefaultShape

#### 📋 Purpose
Updates the default shape flag used by the draw helpers (rectangles and circles) when no explicit flag is provided.

#### ⏰ When Called
Use to globally change the base rounding style (e.g., figma, iOS, circle) for subsequent draw calls.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `shape` | **number** | Shape flag constant such as `lia.derma.SHAPE_FIGMA`; defaults to `SHAPE_FIGMA` when nil. |

#### ↩️ Returns
* nil
Updates internal default state.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    lia.derma.setDefaultShape(lia.derma.SHAPE_IOS)

```

---

### lia.derma.shadowText

#### 📋 Purpose
Draws text with a single offset shadow before the main text for lightweight legibility.

#### ⏰ When Called
Use when you need a subtle shadow behind text without a full outline.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `text` | **string** | Text to draw. |
| `font` | **string** | Font name. |
| `x` | **number** | X position. |
| `y` | **number** | Y position. |
| `colortext` | **Color** | Foreground text color. |
| `colorshadow` | **Color** | Shadow color. |
| `dist` | **number** | Pixel offset for both X and Y shadow directions. |
| `xalign` | **number** | Horizontal alignment (`TEXT_ALIGN_*`). |
| `yalign` | **number** | Vertical alignment (`TEXT_ALIGN_*`). |

#### ↩️ Returns
* nil
Draws directly to the screen.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    lia.derma.shadowText("Hello", "LiliaFont.18", 200, 100, color_white, Color(0, 0, 0, 180), 1, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

```

---

### lia.derma.drawTextOutlined

#### 📋 Purpose
Draws text with a configurable outline by repeatedly rendering offset copies around the glyphs.

#### ⏰ When Called
Use when you need high-contrast text that stays legible on varied backgrounds.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `text` | **string** | Text to draw. |
| `font` | **string** | Font name. |
| `x` | **number** | X position. |
| `y` | **number** | Y position. |
| `colour` | **Color** | Main text color. |
| `xalign` | **number** | Horizontal alignment (`TEXT_ALIGN_*`). |
| `outlinewidth` | **number** | Total outline thickness in pixels. |
| `outlinecolour` | **Color** | Color applied to the outline renders. |

#### ↩️ Returns
* number
The value returned by `draw.DrawText` for the final text render.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    lia.derma.drawTextOutlined("Warning", "LiliaFont.16", 50, 50, color_white, TEXT_ALIGN_LEFT, 2, Color(0, 0, 0, 200))

```

---

### lia.derma.drawTip

#### 📋 Purpose
Draws a speech-bubble style tooltip with a triangular pointer and centered label.

#### ⏰ When Called
Use for lightweight tooltip rendering when you need a callout pointing to a position.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `x` | **number** | Left position of the bubble. |
| `y` | **number** | Top position of the bubble. |
| `w` | **number** | Bubble width. |
| `h` | **number** | Bubble height including pointer. |
| `text` | **string** | Text to display inside the bubble. |
| `font` | **string** | Font used for the text. |
| `textCol` | **Color** | Color of the label text. |
| `outlineCol` | **Color** | Color used to draw the bubble outline/fill. |

#### ↩️ Returns
* nil
Draws directly to the screen.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    lia.derma.drawTip(300, 200, 160, 60, "Hint", "LiliaFont.16", color_white, Color(20, 20, 20, 220))

```

---

### lia.derma.drawText

#### 📋 Purpose
Draws text with a subtle shadow using `draw.TextShadow`, defaulting to common derma font and colors.

#### ⏰ When Called
Use when rendering HUD/UI text that benefits from a small shadow for readability.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `text` | **string** | Text to render. |
| `x` | **number** | X position. |
| `y` | **number** | Y position. |
| `color` | **Color|nil** | Text color; defaults to white. |
| `alignX` | **number|nil** | Horizontal alignment (`TEXT_ALIGN_*`), defaults to left. |
| `alignY` | **number|nil** | Vertical alignment (`TEXT_ALIGN_*`), defaults to top. |
| `font` | **string|nil** | Font name; defaults to `LiliaFont.16`. |
| `alpha` | **number|nil** | Shadow alpha override; defaults to 57.5% of text alpha. |

#### ↩️ Returns
* number
Width returned by `draw.TextShadow`.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    lia.derma.drawText("Objective updated", 20, 20, lia.color.theme.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

```

---

### lia.derma.drawBoxWithText

#### 📋 Purpose
Renders a configurable blurred box with optional border and draws one or more text lines inside it.

#### ⏰ When Called
Use for notification overlays, labels, or caption boxes that need automatic sizing and padding.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `text` | **string|table** | Single string or table of lines to display. |
| `x` | **number** | Reference X coordinate. |
| `y` | **number** | Reference Y coordinate. |
| `options` | **table|nil** | Customisation table supporting `font`, `textColor`, `backgroundColor`, `borderColor`, `borderRadius`, `borderThickness`, `padding`, `blur`, `textAlignX`, `textAlignY`, `autoSize`, `width`, `height`, and `lineSpacing`. |

#### ↩️ Returns
* number, number
The final box width and height.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    local w, h = lia.derma.drawBoxWithText("Saved", ScrW() * 0.5, 120, {textAlignX = TEXT_ALIGN_CENTER})

```

---

### lia.derma.drawSurfaceTexture

#### 📋 Purpose
Draws a textured rectangle using either a supplied material or a material path.

#### ⏰ When Called
Use when you need to render a texture/material directly without rounded corners.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `material` | **IMaterial|string** | Material instance or path to the material. |
| `color` | **Color|nil** | Color modulation for the draw; defaults to white. |
| `x` | **number** | X position. |
| `y` | **number** | Y position. |
| `w` | **number** | Width. |
| `h` | **number** | Height. |

#### ↩️ Returns
* nil
Draws directly to the screen.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    lia.derma.drawSurfaceTexture("vgui/gradient-l", color_white, 10, 10, 64, 64)

```

---

### lia.derma.skinFunc

#### 📋 Purpose
Calls a named skin function on the panel's active skin (or the default skin) with the provided arguments.

#### ⏰ When Called
Use to defer drawing or layout to the current Derma skin implementation.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | **string** | Skin function name to invoke. |
| `panel` | **Panel|nil** | Target panel whose skin should be used; falls back to the default skin. |

#### ↩️ Returns
* any
Whatever the skin function returns, or nil if unavailable.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    lia.derma.skinFunc("PaintButton", someButton, w, h)

```

---

### lia.derma.approachExp

#### 📋 Purpose
Smoothly moves a value toward a target using an exponential approach based on delta time.

#### ⏰ When Called
Use for UI animations or interpolations that should ease toward a target without overshoot.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `current` | **number** | Current value. |
| `target` | **number** | Desired target value. |
| `speed` | **number** | Exponential speed factor. |
| `dt` | **number** | Frame delta time. |

#### ↩️ Returns
* number
The updated value after applying the exponential approach.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    scale = lia.derma.approachExp(scale, 1, 4, FrameTime())

```

---

### lia.derma.easeOutCubic

#### 📋 Purpose
Returns a cubic ease-out interpolation for values between 0 and 1.

#### ⏰ When Called
Use for easing animations that should start quickly and slow toward the end.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `t` | **number** | Normalized time between 0 and 1. |

#### ↩️ Returns
* number
Eased value.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    local eased = lia.derma.easeOutCubic(progress)

```

---

### lia.derma.easeInOutCubic

#### 📋 Purpose
Returns a cubic ease-in/ease-out interpolation for values between 0 and 1.

#### ⏰ When Called
Use when you want acceleration at the start and deceleration at the end of an animation.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `t` | **number** | Normalized time between 0 and 1. |

#### ↩️ Returns
* number
Eased value.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    local eased = lia.derma.easeInOutCubic(progress)

```

---

### lia.derma.animateAppearance

#### 📋 Purpose
Animates a panel from a scaled, transparent state to a target size/position with exponential easing and optional callback.

#### ⏰ When Called
Use to show panels with a smooth pop-in animation that scales and fades into place.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `panel` | **Panel** | Panel to animate. |
| `targetWidth` | **number** | Final width. |
| `targetHeight` | **number** | Final height. |
| `duration` | **number|nil** | Time in seconds for the size/position animation; defaults to 0.18s. |
| `alphaDuration` | **number|nil** | Time in seconds for the fade animation; defaults to the duration. |
| `callback` | **function|nil** | Called once the animation finishes. |
| `scaleFactor` | **number|nil** | Starting scale factor relative to the final size; defaults to 0.8. |

#### ↩️ Returns
* nil
Mutates the panel in-place and assigns a Think hook.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    local pnl = vgui.Create("DPanel")
    pnl:SetPos(100, 100)
    lia.derma.animateAppearance(pnl, 300, 200, 0.2, nil, function() pnl:SetMouseInputEnabled(true) end)

```

---

### lia.derma.clampMenuPosition

#### 📋 Purpose
Repositions a panel so it remains within the visible screen area with a small padding.

#### ⏰ When Called
Use after moving or resizing a popup to prevent it from clipping off-screen.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `panel` | **Panel** | Panel to clamp. |

#### ↩️ Returns
* nil
Mutates the panel position in-place.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    lia.derma.clampMenuPosition(myPanel)

```

---

### lia.derma.drawGradient

#### 📋 Purpose
Draws a rectangular gradient using common VGUI gradient materials and optional rounding.

#### ⏰ When Called
Use when you need a directional gradient fill without creating custom materials.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `x` | **number** | X position. |
| `y` | **number** | Y position. |
| `w` | **number** | Width. |
| `h` | **number** | Height. |
| `direction` | **number** | Gradient index (1 = up, 2 = down, 3 = left, 4 = right). |
| `colorShadow` | **Color** | Color modulation for the gradient texture. |
| `radius` | **number|nil** | Corner radius; defaults to 0. |
| `flags` | **number|nil** | Optional bitmask using `lia.derma` flags. |

#### ↩️ Returns
* nil
Draws directly to the screen.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    lia.derma.drawGradient(0, 0, 200, 40, 2, Color(0, 0, 0, 180), 6)

```

---

### lia.derma.wrapText

#### 📋 Purpose
Splits text into lines that fit within a maximum width using the specified font.

#### ⏰ When Called
Use before rendering multi-line text to avoid manual word wrapping.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `text` | **string** | Text to wrap. |
| `width` | **number** | Maximum line width in pixels. |
| `font` | **string|nil** | Font to measure with; defaults to `LiliaFont.16`. |

#### ↩️ Returns
* table, number
A table of wrapped lines and the widest measured width.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    local lines, maxW = lia.derma.wrapText("Hello world", 180, "LiliaFont.16")

```

---

### lia.derma.drawBlur

#### 📋 Purpose
Applies a screen-space blur behind the given panel by repeatedly sampling the blur material.

#### ⏰ When Called
Use when you want a translucent blurred background behind a Derma panel.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `panel` | **Panel** | Panel whose bounds define the blur area. |
| `amount` | **number|nil** | Blur strength multiplier; defaults to 5. |
| `passes` | **number|nil** | Number of blur passes; defaults to 0.2 steps up to 1. |
| `alpha` | **number|nil** | Alpha applied to the blur draw; defaults to 255. |

#### ↩️ Returns
* nil
Draws directly to the screen.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    lia.derma.drawBlur(myPanel, 4, 1, 200)

```

---

### lia.derma.drawBlackBlur

#### 📋 Purpose
Draws a blur behind a panel and overlays a dark tint to emphasize foreground elements.

#### ⏰ When Called
Use for modal backdrops or to dim the UI behind dialogs.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `panel` | **Panel** | Panel whose bounds define the blur and tint area. |
| `amount` | **number|nil** | Blur strength; defaults to 6. |
| `passes` | **number|nil** | Number of blur passes; defaults to 5. |
| `alpha` | **number|nil** | Alpha applied to the blur draw; defaults to 255. |
| `darkAlpha` | **number|nil** | Alpha of the dark overlay; defaults to 220. |

#### ↩️ Returns
* nil
Draws directly to the screen.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    lia.derma.drawBlackBlur(myPanel, 8, 4, 255, 180)

```

---

### lia.derma.drawBlurAt

#### 📋 Purpose
Applies a blur effect to a specific screen-space rectangle defined by coordinates and size.

#### ⏰ When Called
Use to blur a custom area of the screen that is not tied to a panel.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `x` | **number** | X position of the blur rectangle. |
| `y` | **number** | Y position of the blur rectangle. |
| `w` | **number** | Width of the blur rectangle. |
| `h` | **number** | Height of the blur rectangle. |
| `amount` | **number|nil** | Blur strength; defaults to 5. |
| `passes` | **number|nil** | Number of blur passes; defaults to 0.2 steps up to 1. |
| `alpha` | **number|nil** | Alpha applied to the blur draw; defaults to 255. |

#### ↩️ Returns
* nil
Draws directly to the screen.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    lia.derma.drawBlurAt(100, 100, 200, 120, 6, 1, 180)

```

---

### lia.derma.requestArguments

#### 📋 Purpose
Builds a dynamic argument entry form with typed controls and validates input before submission.

#### ⏰ When Called
Use when a command or action requires the player to supply multiple typed arguments.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `title` | **string|nil** | Title text key; defaults to `"enterArguments"`. |
| `argTypes` | **table** | Ordered list or map describing fields; entries can be `"string"`, `"boolean"`, `"number"/"int"`, `"table"` (dropdown), or `"player"`, optionally with data and default values. |
| `onSubmit` | **function|nil** | Callback receiving `(true, resultsTable)` on submit or `(false)` on cancel. |
| `defaults` | **table|nil** | Default values keyed by field name. |

#### ↩️ Returns
* nil
Operates through UI side effects and the provided callback.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    lia.derma.createTableUI("Players", {
        {name = "name", field = "name"},
        {name = "steamid", field = "steamid"}
    }, playerRows)

```

---

### lia.derma.createTableUI

#### 📋 Purpose
Builds a full-screen table UI with optional context actions, populating rows from provided data and column definitions.

#### ⏰ When Called
Use when you need to display tabular data (e.g., admin lists) with right-click options and copy support.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `title` | **string|nil** | Title text key; defaults to localized table list title. |
| `columns` | **table** | Array of column definitions `{name = <lang key>, field = <data key>, width = <optional>}`. |
| `data` | **table** | Array of row tables keyed by column fields. |
| `options` | **table|nil** | Optional array of context menu option tables with `name`, `net`, and optional `ExtraFields`. |
| `charID` | **number|nil** | Character identifier forwarded to network options. |

#### ↩️ Returns
* Panel, Panel
The created frame and the underlying `DListView`.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    lia.derma.createTableUI("Players", {
        {name = "name", field = "name"},
        {name = "steamid", field = "steamid"}
    }, playerRows)

```

---

### lia.derma.openOptionsMenu

#### 📋 Purpose
Opens a compact options window from either a keyed table or an array of `{name, callback}` entries.

#### ⏰ When Called
Use for lightweight choice prompts where each option triggers a callback and then closes the window.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `title` | **string|nil** | Localized title text key; defaults to `"options"`. |
| `options` | **table** | Either an array of option tables `{name=<text>, callback=<fn>}` or a map of `name -> callback`. |

#### ↩️ Returns
* Panel
The created options frame.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    lia.derma.openOptionsMenu("Actions", {
        {name = "Heal", callback = function() net.Start("Heal") net.SendToServer() end}
    })

```

---

### lia.derma.drawEntText

#### 📋 Purpose
Draws floating text above an entity with distance-based fade and easing, caching per-entity scales.

#### ⏰ When Called
Use to display labels or names above entities that appear when nearby.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ent` | **Entity** | Target entity to label. |
| `text` | **string** | Text to display. |
| `posY` | **number|nil** | Vertical offset for the text; defaults to 0. |
| `alphaOverride` | **number|nil** | Optional alpha multiplier or raw alpha value. |

#### ↩️ Returns
* nil
Draws directly to the screen and tracks internal fade state.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("PostDrawTranslucentRenderables", "DrawNames", function()
        for _, ent in ipairs(ents.FindByClass("npc_*")) do
            lia.derma.drawEntText(ent, ent:GetClass(), 0)
        end
    end)

```

---

### lia.derma.requestDropdown

#### 📋 Purpose
Shows a modal dropdown prompt and returns the selected entry through a callback.

#### ⏰ When Called
Use when you need the player to choose a single option from a list with optional default selection.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `title` | **string|nil** | Title text key; defaults to `"selectOption"`. |
| `options` | **table** | Array of options, either strings or `{text, data}` tables. |
| `callback` | **function|nil** | Invoked with `selectedText` and optional `selectedData`, or `false` if cancelled. |
| `defaultValue` | **any|table|nil** | Optional default selection value or `{text, data}` pair. |

#### ↩️ Returns
* Panel
The created dropdown frame.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    lia.derma.requestDropdown("Choose color", {"Red", "Green", "Blue"}, function(choice) print("Picked", choice) end)

```

---

### lia.derma.requestString

#### 📋 Purpose
Prompts the user for a single line of text with an optional description and default value.

#### ⏰ When Called
Use for simple text input such as renaming or entering custom values.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `title` | **string|nil** | Title text key; defaults to `"enterText"`. |
| `description` | **string|nil** | Helper text displayed above the entry field. |
| `callback` | **function|nil** | Invoked with the entered string, or `false` when cancelled. |
| `defaultValue` | **any|nil** | Pre-filled value for the input field. |
| `Pre` | **unknown** | filled value for the input field. |
| `Pre` | **unknown** | filled value for the input field. |
| `maxLength` | **number|nil** | Optional character limit. |

#### ↩️ Returns
* Panel
The created input frame.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    lia.derma.requestString("Rename", "Enter a new name:", function(val) if val then print("New name", val) end end, "Default")

```

---

### lia.derma.requestOptions

#### 📋 Purpose
Presents multiple selectable options, supporting dropdowns and checkboxes, and returns the chosen set.

#### ⏰ When Called
Use for multi-field configuration prompts where each option can be a boolean or a list of choices.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `title` | **string|nil** | Title text key; defaults to `"selectOptions"`. |
| `options` | **table** | Array where each entry is either a value or `{display, data}` table; tables create dropdowns, values create checkboxes. |
| `callback` | **function|nil** | Invoked with a table of selected values or `false` when cancelled. |
| `defaults` | **table|nil** | Default selections; for dropdowns this can map option names to selected values. |

#### ↩️ Returns
* Panel
The created options frame.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    lia.derma.requestOptions("Permissions", {{"Rank", {"User", "Admin"}}, "CanKick"}, function(result) PrintTable(result) end)

```

---

### lia.derma.requestBinaryQuestion

#### 📋 Purpose
Displays a yes/no style modal dialog with customizable labels and forwards the response.

#### ⏰ When Called
Use when you need explicit confirmation from the player before executing an action.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `title` | **string|nil** | Title text key; defaults to `"question"`. |
| `question` | **string|nil** | Prompt text; defaults to `"areYouSure"`. |
| `callback` | **function|nil** | Invoked with `true` for yes, `false` for no. |
| `yesText` | **string|nil** | Custom text for the affirmative button; defaults to `"yes"`. |
| `noText` | **string|nil** | Custom text for the negative button; defaults to `"no"`. |

#### ↩️ Returns
* Panel
The created dialog frame.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    lia.derma.requestBinaryQuestion("Confirm", "Delete item?", function(ok) if ok then print("Deleted") end end)

```

---

### lia.derma.requestButtons

#### 📋 Purpose
Creates a dialog with a list of custom buttons and optional description, forwarding clicks to provided callbacks.

#### ⏰ When Called
Use for multi-action prompts where each button can perform custom logic and optionally prevent auto-close by returning false.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `title` | **string|nil** | Title text key; defaults to `"selectOption"`. |
| `buttons` | **table** | Array of button definitions; each can be a string or a table with `text`, `callback`, and optional `icon`. |
| `callback` | **function|nil** | Fallback invoked with `(index, buttonText)` when a button lacks its own callback; returning false keeps the dialog open. |
| `description` | **string|nil** | Optional descriptive text shown above the buttons. |

#### ↩️ Returns
* Panel, table
The created frame and a table of created button panels.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    lia.derma.requestButtons("Choose action", {"Heal", "Damage"}, function(_, text) print("Pressed", text) end, "Pick an effect:")

```

---

### lia.derma.requestPopupQuestion

#### 📋 Purpose
Shows a small popup question with custom buttons, closing automatically unless a button callback prevents it.

#### ⏰ When Called
Use for quick confirmation prompts that need more than a binary choice.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `question` | **string|nil** | Prompt text; defaults to `"areYouSure"`. |
| `buttons` | **table** | Array of button definitions; each can be a string or `{text, callback}` table. |

#### ↩️ Returns
* Panel
The created popup frame.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    lia.derma.requestPopupQuestion("Teleport where?", {{"City", function() net.Start("tp_city") net.SendToServer() end}, "Cancel"})

```

---

