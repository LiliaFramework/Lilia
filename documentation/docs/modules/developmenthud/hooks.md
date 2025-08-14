# Hooks

Module-specific events raised by the Development HUD module.

---

### `RefreshFonts`

**Purpose**

Called when the Development HUD font option changes to allow custom fonts to be rebuilt.

**Parameters**

* *(None)*

**Realm**

`Client`

**Returns**

`nil` — nothing.

**Example**

```lua
hook.Add("RefreshFonts", "DevHUDFonts", function()
    surface.CreateFont("DevFont", {font = lia.config.get("DevHudFont"), size = 18})
end)
```

---

### `DevelopmentHUDPrePaint`

**Purpose**

Runs each frame before the default development HUD text is drawn.

**Parameters**

* `client` (`Player`): Local player the HUD is being drawn for.

**Realm**

`Client`

**Returns**

`nil` — nothing.

**Example**

```lua
hook.Add("DevelopmentHUDPrePaint", "AddExtraInfo", function(ply)
    draw.SimpleText("Custom Info", lia.config.get("DevHudFont"), 10, 10, color_white)
end)
```

---

### `DevelopmentHUDPaint`

**Purpose**

Called after the built-in development HUD drawing completes.

**Parameters**

* `client` (`Player`): Local player the HUD was drawn for.

**Realm**

`Client`

**Returns**

`nil` — nothing.

**Example**

```lua
hook.Add("DevelopmentHUDPaint", "PostHUD", function(ply)
    -- draw additional overlays here
end)
```

---

