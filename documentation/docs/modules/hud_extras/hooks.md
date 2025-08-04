# Hooks

Module-specific events raised by the HUD Extras module.

---

### `RefreshFonts`

**Purpose**

`Rebuilds HUD fonts whenever font configuration changes.`

**Parameters**

* *(None)*

**Realm**

`Client`

**Returns**

`nil` — `No return value.`

**Example**

```lua
hook.Add("RefreshFonts", "HUDExtrasFonts", function()
    surface.CreateFont("HUDFont", {font = lia.config.get("HUDExtrasFont"), size = 24})
end)
```

---

### `HUDExtrasPreDrawFPS`

**Purpose**

`Called before the FPS counter is drawn.`

**Parameters**

*None*

**Realm**

`Client`

**Returns**

`nil` — `Nothing.`

**Example**

```lua
hook.Add("HUDExtrasPreDrawFPS", "ChangeColor", function()
    surface.SetTextColor(255, 0, 0)
end)
```

---

### `HUDExtrasPostDrawFPS`

**Purpose**

`Runs after the FPS counter has been drawn.`

**Parameters**

*None*

**Realm**

`Client`

**Returns**

`nil` — `Nothing.`

**Example**

```lua
hook.Add("HUDExtrasPostDrawFPS", "ResetColor", function()
    surface.SetTextColor(255, 255, 255)
end)
```

---

### `HUDExtrasPreDrawVignette`

**Purpose**

`Called before the vignette overlay is drawn.`

**Parameters**

*None*

**Realm**

`Client`

**Returns**

`nil` — `Nothing.`

**Example**

```lua
hook.Add("HUDExtrasPreDrawVignette", "MyVignetteSettings", function()
    -- change draw color here
end)
```

---

### `HUDExtrasPostDrawVignette`

**Purpose**

`Runs after the vignette overlay has been drawn.`

**Parameters**

*None*

**Realm**

`Client`

**Returns**

`nil` — `Nothing.`

**Example**

```lua
hook.Add("HUDExtrasPostDrawVignette", "Cleanup", function()
    surface.SetDrawColor(255, 255, 255, 255)
end)
```

---

### `HUDExtrasPreDrawBlur`

**Purpose**

`Called before screen blur is drawn.`

**Parameters**

*None*

**Realm**

`Client`

**Returns**

`nil` — `Nothing.`

**Example**

```lua
hook.Add("HUDExtrasPreDrawBlur", "PrepareBlur", function()
    -- adjust materials or states
end)
```

---

### `HUDExtrasPostDrawBlur`

**Purpose**

`Runs after screen blur drawing finishes.`

**Parameters**

* `amount` (`number`): `Current blur strength.`

**Realm**

`Client`

**Returns**

`nil` — `Nothing.`

**Example**

```lua
hook.Add("HUDExtrasPostDrawBlur", "ShowAmount", function(amount)
    print("Blur amount:", amount)
end)
```

---

### `AdjustBlurAmount`

**Purpose**

`Allows modification of the blur value before drawing.`

**Parameters**

* `current` (`number`): `Blur value about to be applied.`

**Realm**

`Client`

**Returns**

`number` — `Amount to add to the blur.`

**Example**

```lua
hook.Add("AdjustBlurAmount", "DoubleBlur", function(current)
    return current * 0.5
end)
```

---

### `ShouldDrawBlur`

**Purpose**

`Determines if screen blur should be displayed.`

**Parameters**

*None*

**Realm**

`Client`

**Returns**

`boolean|nil` — `Return false to skip drawing.`

**Example**

```lua
hook.Add("ShouldDrawBlur", "DisableBlur", function()
    return false
end)
```

---

### `ShouldDrawWatermark`

**Purpose**

`Controls whether the watermark should be shown.`

**Parameters**

*None*

**Realm**

`Client`

**Returns**

`boolean|nil` — `Return false to hide the watermark.`

**Example**

```lua
hook.Add("ShouldDrawWatermark", "HideWatermark", function()
    return LocalPlayer():IsAdmin()
end)
```

---

### `HUDExtrasPreDrawWatermark`

**Purpose**

`Called right before the watermark is drawn.`

**Parameters**

*None*

**Realm**

`Client`

**Returns**

`nil` — `Nothing.`

**Example**

```lua
hook.Add("HUDExtrasPreDrawWatermark", "ChangeWatermarkColor", function()
    surface.SetDrawColor(0, 255, 0)
end)
```

---

### `HUDExtrasPostDrawWatermark`

**Purpose**

`Runs after the watermark has been drawn.`

**Parameters**

*None*

**Realm**

`Client`

**Returns**

`nil` — `Nothing.`

**Example**

```lua
hook.Add("HUDExtrasPostDrawWatermark", "ResetWatermarkColor", function()
    surface.SetDrawColor(255, 255, 255)
end)
```

---

