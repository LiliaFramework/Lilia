# Hooks

Module-specific events raised by the Custom Cursor module.

---

### `PreRenderCursor`

**Purpose**

Called immediately before the custom cursor is drawn.

**Parameters**

* `material` (`string`): Material name of the cursor texture.

**Realm**

`Client`

**Returns**

`nil` — nothing.

**Example**

```lua
hook.Add("PreRenderCursor", "ChangeColor", function(mat)
    surface.SetDrawColor(255, 0, 0)
end)
```

---

### `PostRenderCursor`

**Purpose**

Runs right after the cursor texture has been drawn.

**Parameters**

* `material` (`string`): Material name of the cursor texture.

**Realm**

`Client`

**Returns**

`nil` — nothing.

**Example**

```lua
hook.Add("PostRenderCursor", "ResetColor", function()
    surface.SetDrawColor(255, 255, 255)
end)
```

---

### `PreCursorThink`

**Purpose**

Executed every frame before the hovered panel has its cursor style changed.

**Parameters**

* `panel` (`Panel`): The panel currently under the mouse.

**Realm**

`Client`

**Returns**

`nil` — nothing.

**Example**

```lua
hook.Add("PreCursorThink", "BlockCursor", function(panel)
    if panel.NoCursor then return false end
end)
```

---

### `CursorThink`

**Purpose**

Called each frame after the cursor style has been set to blank.

**Parameters**

* `panel` (`Panel`): The panel currently under the mouse.

**Realm**

`Client`

**Returns**

`nil` — nothing.

**Example**

```lua
hook.Add("CursorThink", "Example", function(panel)
    -- custom panel hover logic here
end)
```

---

