# Panel Meta

Panel management system for the Lilia framework.

---

Overview

The panel meta table provides comprehensive functionality for managing VGUI panels, UI interactions, and panel operations in the Lilia framework. It handles panel event listening, inventory synchronization, UI updates, and panel-specific operations. The meta table operates primarily on the client side, with the server providing data that panels can listen to and display. It includes integration with the inventory system for inventory change notifications, character system for character data display, network system for data synchronization, and UI system for panel management. The meta table ensures proper panel event handling, inventory synchronization, UI updates, and comprehensive panel lifecycle management from creation to destruction.

---

### liaListenForInventoryChanges

#### 📋 Purpose
Sets up event listeners for inventory changes on a panel

#### ⏰ When Called
When a UI panel needs to respond to inventory modifications, typically during panel initialization

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `inventory` | **Inventory** | The inventory object to listen for changes on |

#### ↩️ Returns
* Nothing

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Set up inventory listening for a basic panel
    panel:liaListenForInventoryChanges(playerInventory)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Set up inventory listening with conditional setup
    if playerInventory then
        characterPanel:liaListenForInventoryChanges(playerInventory)
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Set up inventory listening for multiple panels with error handling
    local panels = {inventoryPanel, characterPanel, equipmentPanel}
    for _, pnl in ipairs(panels) do
        if IsValid(pnl) and playerInventory then
            pnl:liaListenForInventoryChanges(playerInventory)
        end
    end

```

---

### liaDeleteInventoryHooks

#### 📋 Purpose
Removes inventory change event listeners from a panel

#### ⏰ When Called
When a panel no longer needs to listen to inventory changes, during cleanup, or when switching inventories

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | **number** | The specific inventory ID to remove hooks for, or nil to remove all hooks |

#### ↩️ Returns
* Nothing

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Remove hooks for a specific inventory
    panel:liaDeleteInventoryHooks(inventoryID)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Clean up hooks when closing a panel
    if IsValid(panel) then
        panel:liaDeleteInventoryHooks()
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Clean up multiple panels with different inventory IDs
    local panels = {inventoryPanel, equipmentPanel, storagePanel}
    local inventoryIDs = {playerInvID, equipmentInvID, storageInvID}
    for i, pnl in ipairs(panels) do
        if IsValid(pnl) then
            pnl:liaDeleteInventoryHooks(inventoryIDs[i])
        end
    end

```

---

### setScaledPos

#### 📋 Purpose
Sets the position of a panel with automatic screen scaling

#### ⏰ When Called
When positioning UI elements that need to adapt to different screen resolutions

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `x` | **number** | The horizontal position value to be scaled |
| `y` | **number** | The vertical position value to be scaled |

#### ↩️ Returns
* Nothing

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Position a button at scaled coordinates
    button:setScaledPos(100, 50)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Position panel based on screen dimensions
    local x = ScrW() * 0.5 - 200
    local y = ScrH() * 0.3
    panel:setScaledPos(x, y)

```

#### ⚙️ High Complexity
```lua
    -- High: Position multiple panels with responsive layout
    local panels = {mainPanel, sidePanel, footerPanel}
    local positions = {
        {ScrW() * 0.1, ScrH() * 0.1},
        {ScrW() * 0.7, ScrH() * 0.1},
        {ScrW() * 0.1, ScrH() * 0.8}
    }
    for i, pnl in ipairs(panels) do
        if IsValid(pnl) then
            pnl:setScaledPos(positions[i][1], positions[i][2])
        end
    end

```

---

### setScaledSize

#### 📋 Purpose
Sets the size of a panel with automatic screen scaling

#### ⏰ When Called
When sizing UI elements that need to adapt to different screen resolutions

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `w` | **number** | The width value to be scaled |
| `h` | **number** | The height value to be scaled |

#### ↩️ Returns
* Nothing

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Set panel size with scaled dimensions
    panel:setScaledSize(400, 300)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Set size based on screen proportions
    local w = ScrW() * 0.8
    local h = ScrH() * 0.6
    panel:setScaledSize(w, h)

```

#### ⚙️ High Complexity
```lua
    -- High: Set sizes for multiple panels with responsive layout
    local panels = {mainPanel, sidePanel, footerPanel}
    local sizes = {
        {ScrW() * 0.7, ScrH() * 0.6},
        {ScrW() * 0.25, ScrH() * 0.6},
        {ScrW() * 0.95, ScrH() * 0.1}
    }
    for i, pnl in ipairs(panels) do
        if IsValid(pnl) then
            pnl:setScaledSize(sizes[i][1], sizes[i][2])
        end
    end

```

---

### On

#### 📋 Purpose
Sets the size of a panel with automatic screen scaling

#### ⏰ When Called
When sizing UI elements that need to adapt to different screen resolutions

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `w` | **number** | The width value to be scaled |
| `h` | **number** | The height value to be scaled |

#### ↩️ Returns
* Nothing

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Set panel size with scaled dimensions
    panel:setScaledSize(400, 300)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Set size based on screen proportions
    local w = ScrW() * 0.8
    local h = ScrH() * 0.6
    panel:setScaledSize(w, h)

```

#### ⚙️ High Complexity
```lua
    -- High: Set sizes for multiple panels with responsive layout
    local panels = {mainPanel, sidePanel, footerPanel}
    local sizes = {
        {ScrW() * 0.7, ScrH() * 0.6},
        {ScrW() * 0.25, ScrH() * 0.6},
        {ScrW() * 0.95, ScrH() * 0.1}
    }
    for i, pnl in ipairs(panels) do
        if IsValid(pnl) then
            pnl:setScaledSize(sizes[i][1], sizes[i][2])
        end
    end

```

---

### SetupTransition

#### 📋 Purpose
Sets the size of a panel with automatic screen scaling

#### ⏰ When Called
When sizing UI elements that need to adapt to different screen resolutions

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `w` | **number** | The width value to be scaled |
| `h` | **number** | The height value to be scaled |

#### ↩️ Returns
* Nothing

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Set panel size with scaled dimensions
    panel:setScaledSize(400, 300)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Set size based on screen proportions
    local w = ScrW() * 0.8
    local h = ScrH() * 0.6
    panel:setScaledSize(w, h)

```

#### ⚙️ High Complexity
```lua
    -- High: Set sizes for multiple panels with responsive layout
    local panels = {mainPanel, sidePanel, footerPanel}
    local sizes = {
        {ScrW() * 0.7, ScrH() * 0.6},
        {ScrW() * 0.25, ScrH() * 0.6},
        {ScrW() * 0.95, ScrH() * 0.1}
    }
    for i, pnl in ipairs(panels) do
        if IsValid(pnl) then
            pnl:setScaledSize(sizes[i][1], sizes[i][2])
        end
    end

```

---

### FadeHover

#### 📋 Purpose
Adds a fade hover effect to a panel that transitions opacity based on hover state

#### ⏰ When Called
When initializing a panel that should have a visual hover effect with opacity transition

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `col` | **Color, optional** | The color to use for the hover effect. Defaults to Color(255, 255, 255, 30) |
| `speed` | **number, optional** | The transition speed for the fade effect. Defaults to 6 |
| `rad` | **number, optional** | The border radius for rounded corners. If provided, uses rounded box drawing |

#### ↩️ Returns
* Nothing

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Add basic fade hover effect
    button:FadeHover()

```

#### 📊 Medium Complexity
```lua
    -- Medium: Add fade hover with custom color and speed
    panel:FadeHover(Color(100, 150, 255, 50), 8)

```

#### ⚙️ High Complexity
```lua
    -- High: Add fade hover with rounded corners and custom styling
    panel:FadeHover(Color(255, 200, 0, 40), 10, 8)

```

---

### BarHover

#### 📋 Purpose
Adds a horizontal bar hover effect that expands from the center when hovered

#### ⏰ When Called
When initializing a panel that should display a bottom bar indicator on hover

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `col` | **Color, optional** | The color of the hover bar. Defaults to Color(255, 255, 255, 255) |
| `height` | **number, optional** | The height of the hover bar in pixels. Defaults to 2 |
| `speed` | **number, optional** | The transition speed for the bar expansion. Defaults to 6 |

#### ↩️ Returns
* Nothing

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Add basic bar hover effect
    button:BarHover()

```

#### 📊 Medium Complexity
```lua
    -- Medium: Add bar hover with custom color and height
    panel:BarHover(Color(0, 150, 255), 3, 8)

```

#### ⚙️ High Complexity
```lua
    -- High: Add bar hover with custom styling
    panel:BarHover(Color(255, 100, 0), 4, 10)

```

---

### FillHover

#### 📋 Purpose
Adds a fill hover effect that expands from a specified direction when hovered

#### ⏰ When Called
When initializing a panel that should have a directional fill effect on hover

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `col` | **Color, optional** | The color of the fill effect. Defaults to Color(255, 255, 255, 30) |
| `dir` | **number, optional** | The direction for the fill effect (LEFT, TOP, RIGHT, BOTTOM). Defaults to LEFT |
| `speed` | **number, optional** | The transition speed for the fill expansion. Defaults to 8 |
| `mat` | **Material, optional** | Optional material to use for the fill instead of solid color |

#### ↩️ Returns
* Nothing

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Add basic fill hover from left
    button:FillHover()

```

#### 📊 Medium Complexity
```lua
    -- Medium: Add fill hover from bottom with custom color
    panel:FillHover(Color(100, 200, 255), BOTTOM, 10)

```

#### ⚙️ High Complexity
```lua
    -- High: Add fill hover with material texture
    panel:FillHover(Color(255, 255, 255), RIGHT, 8, gradientMaterial)

```

---

### Background

#### 📋 Purpose
Sets a background color for a panel with optional rounded corners

#### ⏰ When Called
When initializing a panel that needs a colored background

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `col` | **Color** | The background color to use |
| `rad` | **number, optional** | The border radius for rounded corners. If 0 or nil, uses square corners |
| `rtl` | **boolean, optional** | Top-left corner rounding. If nil, all corners use rad |
| `Top` | **unknown** | left corner rounding. If nil, all corners use rad |
| `Top` | **unknown** | left corner rounding. If nil, all corners use rad |
| `rtr` | **boolean, optional** | Top-right corner rounding |
| `Top` | **unknown** | right corner rounding |
| `Top` | **unknown** | right corner rounding |
| `rbl` | **boolean, optional** | Bottom-left corner rounding |
| `Bottom` | **unknown** | left corner rounding |
| `Bottom` | **unknown** | left corner rounding |
| `rbr` | **boolean, optional** | Bottom-right corner rounding |
| `Bottom` | **unknown** | right corner rounding |
| `Bottom` | **unknown** | right corner rounding |

#### ↩️ Returns
* Nothing

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Add solid background color
    panel:Background(Color(40, 40, 40))

```

#### 📊 Medium Complexity
```lua
    -- Medium: Add rounded background
    panel:Background(Color(50, 50, 60), 8)

```

#### ⚙️ High Complexity
```lua
    -- High: Add background with custom corner rounding
    panel:Background(Color(30, 30, 40), 10, true, true, false, false)

```

---

### Material

#### 📋 Purpose
Sets a material texture as the panel background

#### ⏰ When Called
When initializing a panel that should display a material texture

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `mat` | **Material** | The material to display |
| `col` | **Color, optional** | The color tint to apply to the material. Defaults to Color(255, 255, 255) |

#### ↩️ Returns
* Nothing

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Add material background
    panel:Material(Material("icon16/user.png"))

```

#### 📊 Medium Complexity
```lua
    -- Medium: Add material with color tint
    panel:Material(Material("icon16/star.png"), Color(255, 200, 0))

```

#### ⚙️ High Complexity
```lua
    -- High: Add material with custom color and effects
    panel:Material(customMaterial, Color(100, 150, 255, 200))

```

---

### TiledMaterial

#### 📋 Purpose
Sets a tiled material texture that repeats across the panel background

#### ⏰ When Called
When initializing a panel that should display a repeating tiled texture

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `mat` | **Material** | The material to tile |
| `tw` | **number** | The tile width in pixels |
| `th` | **number** | The tile height in pixels |
| `col` | **Color, optional** | The color tint to apply. Defaults to Color(255, 255, 255, 255) |

#### ↩️ Returns
* Nothing

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Add tiled material
    panel:TiledMaterial(Material("tile.png"), 64, 64)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Add tiled material with color tint
    panel:TiledMaterial(Material("pattern.png"), 32, 32, Color(200, 200, 200))

```

#### ⚙️ High Complexity
```lua
    -- High: Add tiled material with custom styling
    panel:TiledMaterial(customPattern, 16, 16, Color(150, 150, 255, 180))

```

---

### Outline

#### 📋 Purpose
Adds an outline border around the panel

#### ⏰ When Called
When initializing a panel that needs a visible border outline

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `col` | **Color, optional** | The color of the outline. Defaults to Color(255, 255, 255, 255) |
| `width` | **number, optional** | The width of the outline in pixels. Defaults to 1 |

#### ↩️ Returns
* Nothing

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Add basic outline
    panel:Outline()

```

#### 📊 Medium Complexity
```lua
    -- Medium: Add outline with custom color and width
    panel:Outline(Color(100, 150, 255), 2)

```

#### ⚙️ High Complexity
```lua
    -- High: Add thick outline with custom color
    panel:Outline(Color(255, 200, 0), 3)

```

---

### LinedCorners

#### 📋 Purpose
Adds corner line decorations to the panel (L-shaped corners)

#### ⏰ When Called
When initializing a panel that needs decorative corner lines

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `col` | **Color, optional** | The color of the corner lines. Defaults to Color(255, 255, 255, 255) |
| `cornerLen` | **number, optional** | The length of each corner line segment. Defaults to 15 |

#### ↩️ Returns
* Nothing

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Add corner lines
    panel:LinedCorners()

```

#### 📊 Medium Complexity
```lua
    -- Medium: Add corner lines with custom color
    panel:LinedCorners(Color(0, 150, 255), 20)

```

#### ⚙️ High Complexity
```lua
    -- High: Add corner lines with custom styling
    panel:LinedCorners(Color(255, 200, 0), 25)

```

---

### SideBlock

#### 📋 Purpose
Adds a colored block on a specific side of the panel

#### ⏰ When Called
When initializing a panel that needs a side indicator or accent block

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `col` | **Color, optional** | The color of the side block. Defaults to Color(255, 255, 255, 255) |
| `size` | **number, optional** | The size/thickness of the block. Defaults to 3 |
| `side` | **number, optional** | The side to place the block (LEFT, TOP, RIGHT, BOTTOM). Defaults to LEFT |

#### ↩️ Returns
* Nothing

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Add side block on left
    panel:SideBlock()

```

#### 📊 Medium Complexity
```lua
    -- Medium: Add side block on bottom with custom color
    panel:SideBlock(Color(0, 255, 0), 5, BOTTOM)

```

#### ⚙️ High Complexity
```lua
    -- High: Add side block with custom styling
    panel:SideBlock(Color(255, 100, 0), 4, RIGHT)

```

---

### Text

#### 📋 Purpose
Adds text rendering to a panel with optional styling

#### ⏰ When Called
When initializing a panel that should display text

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `text` | **string** | The text to display |
| `font` | **string, optional** | The font to use. Defaults to "Trebuchet24" |
| `col` | **Color, optional** | The text color. Defaults to Color(255, 255, 255, 255) |
| `alignment` | **number, optional** | Text alignment (TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, TEXT_ALIGN_RIGHT). Defaults to TEXT_ALIGN_CENTER |
| `ox` | **number, optional** | Horizontal offset. Defaults to 0 |
| `oy` | **number, optional** | Vertical offset. Defaults to 0 |
| `paint` | **boolean, optional** | If true, forces Paint hook instead of using SetText methods |

#### ↩️ Returns
* Nothing

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Add text
    panel:Text("Hello World")

```

#### 📊 Medium Complexity
```lua
    -- Medium: Add text with custom font and color
    panel:Text("Title", "DermaDefault", Color(255, 200, 0))

```

#### ⚙️ High Complexity
```lua
    -- High: Add text with full customization
    panel:Text("Label", "CustomFont", Color(100, 150, 255), TEXT_ALIGN_LEFT, 10, -5)

```

---

### DualText

#### 📋 Purpose
Adds two lines of text to a panel, one on top and one on bottom

#### ⏰ When Called
When initializing a panel that should display two text lines vertically

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `toptext` | **string** | The top text to display |
| `topfont` | **string, optional** | The font for the top text. Defaults to "Trebuchet24" |
| `topcol` | **Color, optional** | The color for the top text. Defaults to Color(0, 127, 255, 255) |
| `bottomtext` | **string** | The bottom text to display |
| `bottomfont` | **string, optional** | The font for the bottom text. Defaults to "Trebuchet18" |
| `bottomcol` | **Color, optional** | The color for the bottom text. Defaults to Color(255, 255, 255, 255) |
| `alignment` | **number, optional** | Text alignment. Defaults to TEXT_ALIGN_CENTER |
| `centerSpacing` | **number, optional** | Spacing between the two text lines. Defaults to 0 |

#### ↩️ Returns
* Nothing

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Add dual text
    panel:DualText("Title", nil, nil, "Subtitle", nil, nil)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Add dual text with custom colors
    panel:DualText("Name", nil, Color(255, 200, 0), "Description", nil, Color(200, 200, 200))

```

#### ⚙️ High Complexity
```lua
    -- High: Add dual text with full customization
    panel:DualText("Top", "CustomFont1", Color(100, 150, 255), "Bottom", "CustomFont2", Color(255, 255, 255), TEXT_ALIGN_LEFT, 5)

```

---

### Blur

#### 📋 Purpose
Adds a blur effect to the panel background

#### ⏰ When Called
When initializing a panel that should have a blurred background effect

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `amount` | **number, optional** | The blur intensity. Defaults to 8 |

#### ↩️ Returns
* Nothing

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Add blur effect
    panel:Blur()

```

#### 📊 Medium Complexity
```lua
    -- Medium: Add blur with custom intensity
    panel:Blur(12)

```

#### ⚙️ High Complexity
```lua
    -- High: Add strong blur effect
    panel:Blur(15)

```

---

### CircleClick

#### 📋 Purpose
Adds a circular ripple effect that appears when the panel is clicked

#### ⏰ When Called
When initializing a panel that should show a click ripple animation

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `col` | **Color, optional** | The color of the ripple effect. Defaults to Color(255, 255, 255, 50) |
| `speed` | **number, optional** | The animation speed of the ripple. Defaults to 5 |
| `trad` | **number, optional** | The target radius for the ripple. Defaults to panel width |

#### ↩️ Returns
* Nothing

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Add click ripple
    button:CircleClick()

```

#### 📊 Medium Complexity
```lua
    -- Medium: Add click ripple with custom color
    panel:CircleClick(Color(100, 150, 255, 80), 8)

```

#### ⚙️ High Complexity
```lua
    -- High: Add click ripple with full customization
    panel:CircleClick(Color(255, 200, 0, 100), 10, 200)

```

---

### CircleHover

#### 📋 Purpose
Adds a circular hover effect that follows the cursor position

#### ⏰ When Called
When initializing a panel that should show a circular hover effect

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `col` | **Color, optional** | The color of the hover circle. Defaults to Color(255, 255, 255, 30) |
| `speed` | **number, optional** | The transition speed. Defaults to 6 |
| `trad` | **number, optional** | The target radius for the circle. Defaults to panel width |

#### ↩️ Returns
* Nothing

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Add circle hover
    button:CircleHover()

```

#### 📊 Medium Complexity
```lua
    -- Medium: Add circle hover with custom color
    panel:CircleHover(Color(100, 150, 255, 50), 8)

```

#### ⚙️ High Complexity
```lua
    -- High: Add circle hover with full customization
    panel:CircleHover(Color(255, 200, 0, 40), 10, 150)

```

---

### SquareCheckbox

#### 📋 Purpose
Styles a checkbox panel with a square design and animated checkmark

#### ⏰ When Called
When initializing a checkbox panel that should have a square style

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `inner` | **Color, optional** | The color of the inner checkmark. Defaults to Color(0, 255, 0, 255) |
| `outer` | **Color, optional** | The color of the outer border. Defaults to Color(255, 255, 255, 255) |
| `speed` | **number, optional** | The animation speed for the checkmark. Defaults to 14 |

#### ↩️ Returns
* Nothing

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Add square checkbox style
    checkbox:SquareCheckbox()

```

#### 📊 Medium Complexity
```lua
    -- Medium: Add square checkbox with custom colors
    checkbox:SquareCheckbox(Color(0, 200, 255), Color(200, 200, 200), 10)

```

#### ⚙️ High Complexity
```lua
    -- High: Add square checkbox with full customization
    checkbox:SquareCheckbox(Color(100, 255, 100), Color(255, 255, 255), 16)

```

---

### CircleCheckbox

#### 📋 Purpose
Styles a checkbox panel with a circular design and animated checkmark

#### ⏰ When Called
When initializing a checkbox panel that should have a circular style

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `inner` | **Color, optional** | The color of the inner checkmark. Defaults to Color(0, 255, 0, 255) |
| `outer` | **Color, optional** | The color of the outer border. Defaults to Color(255, 255, 255, 255) |
| `speed` | **number, optional** | The animation speed for the checkmark. Defaults to 14 |

#### ↩️ Returns
* Nothing

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Add circle checkbox style
    checkbox:CircleCheckbox()

```

#### 📊 Medium Complexity
```lua
    -- Medium: Add circle checkbox with custom colors
    checkbox:CircleCheckbox(Color(0, 200, 255), Color(200, 200, 200), 10)

```

#### ⚙️ High Complexity
```lua
    -- High: Add circle checkbox with full customization
    checkbox:CircleCheckbox(Color(100, 255, 100), Color(255, 255, 255), 16)

```

---

### AvatarMask

#### 📋 Purpose
Creates an avatar image with a custom mask shape

#### ⏰ When Called
When initializing a panel that should display a masked avatar image

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `mask` | **function** | A function that draws the mask shape: function(panel, width, height) |

#### ↩️ Returns
* Nothing

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Add avatar mask with circle
    panel:AvatarMask(function(_, w, h) drawCircle(w/2, h/2, w/2) end)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Add avatar mask with custom shape
    panel:AvatarMask(function(_, w, h) draw.RoundedBox(8, 0, 0, w, h, color_white) end)

```

#### ⚙️ High Complexity
```lua
    -- High: Add avatar mask with complex shape
    panel:AvatarMask(function(_, w, h)
        -- Custom mask drawing code
    end)

```

---

### CircleAvatar

#### 📋 Purpose
Creates a circular avatar image panel

#### ⏰ When Called
When initializing a panel that should display a circular avatar

#### ↩️ Returns
* Nothing

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Add circular avatar
    panel:CircleAvatar()

```

#### 📊 Medium Complexity
```lua
    -- Medium: Add circular avatar and set player
    panel:CircleAvatar()
    panel:SetPlayer(LocalPlayer(), 64)

```

#### ⚙️ High Complexity
```lua
    -- High: Add circular avatar with full setup
    panel:CircleAvatar()
    panel:SetPlayer(targetPlayer, 128)

```

---

### Circle

#### 📋 Purpose
Draws a filled circle on the panel

#### ⏰ When Called
When initializing a panel that should display a circle shape

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `col` | **Color, optional** | The color of the circle. Defaults to Color(255, 255, 255, 255) |

#### ↩️ Returns
* Nothing

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Add circle
    panel:Circle()

```

#### 📊 Medium Complexity
```lua
    -- Medium: Add circle with custom color
    panel:Circle(Color(100, 150, 255))

```

#### ⚙️ High Complexity
```lua
    -- High: Add circle with custom styling
    panel:Circle(Color(255, 200, 0, 200))

```

---

### CircleFadeHover

#### 📋 Purpose
Adds a circular fade hover effect that transitions opacity on hover

#### ⏰ When Called
When initializing a panel that should have a circular fade hover effect

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `col` | **Color, optional** | The color of the hover circle. Defaults to Color(255, 255, 255, 30) |
| `speed` | **number, optional** | The transition speed. Defaults to 6 |

#### ↩️ Returns
* Nothing

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Add circle fade hover
    button:CircleFadeHover()

```

#### 📊 Medium Complexity
```lua
    -- Medium: Add circle fade hover with custom color
    panel:CircleFadeHover(Color(100, 150, 255, 50), 8)

```

#### ⚙️ High Complexity
```lua
    -- High: Add circle fade hover with full customization
    panel:CircleFadeHover(Color(255, 200, 0, 40), 10)

```

---

### CircleExpandHover

#### 📋 Purpose
Adds a circular hover effect that expands from the center on hover

#### ⏰ When Called
When initializing a panel that should have an expanding circle hover effect

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `col` | **Color, optional** | The color of the hover circle. Defaults to Color(255, 255, 255, 30) |
| `speed` | **number, optional** | The transition speed. Defaults to 6 |

#### ↩️ Returns
* Nothing

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Add circle expand hover
    button:CircleExpandHover()

```

#### 📊 Medium Complexity
```lua
    -- Medium: Add circle expand hover with custom color
    panel:CircleExpandHover(Color(100, 150, 255, 50), 8)

```

#### ⚙️ High Complexity
```lua
    -- High: Add circle expand hover with full customization
    panel:CircleExpandHover(Color(255, 200, 0, 40), 10)

```

---

### Gradient

#### 📋 Purpose
Adds a gradient effect to the panel background

#### ⏰ When Called
When initializing a panel that should have a gradient background

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `col` | **Color** | The gradient color |
| `dir` | **number, optional** | The gradient direction (LEFT, TOP, RIGHT, BOTTOM). Defaults to BOTTOM |
| `frac` | **number, optional** | The gradient fraction (0-1). Defaults to 1 |
| `op` | **boolean, optional** | If true, reverses the gradient direction |

#### ↩️ Returns
* Nothing

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Add gradient
    panel:Gradient(Color(0, 0, 0, 200))

```

#### 📊 Medium Complexity
```lua
    -- Medium: Add gradient with direction
    panel:Gradient(Color(0, 0, 0, 150), TOP, 0.5)

```

#### ⚙️ High Complexity
```lua
    -- High: Add gradient with full customization
    panel:Gradient(Color(100, 150, 255, 180), RIGHT, 0.8, true)

```

---

### SetOpenURL

#### 📋 Purpose
Sets the panel to open a URL when clicked

#### ⏰ When Called
When initializing a panel that should open a URL on click

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `url` | **string** | The URL to open when the panel is clicked |

#### ↩️ Returns
* Nothing

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Open URL on click
    button:SetOpenURL("https://example.com")

```

#### 📊 Medium Complexity
```lua
    -- Medium: Open URL with validation
    if url then
        panel:SetOpenURL(url)
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Open URL with multiple conditions
    panel:SetOpenURL("https://example.com/page?id=" .. id)

```

---

### NetMessage

#### 📋 Purpose
Sets the panel to send a network message when clicked

#### ⏰ When Called
When initializing a panel that should send network data on click

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | **string** | The network message name to send |
| `data` | **function, optional** | A function that prepares the network message: function(panel) |

#### ↩️ Returns
* Nothing

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Send network message
    button:NetMessage("liaButtonClick")

```

#### 📊 Medium Complexity
```lua
    -- Medium: Send network message with data
    panel:NetMessage("liaAction", function(pnl)
        net.WriteString("action_name")
    end)

```

#### ⚙️ High Complexity
```lua
    -- High: Send network message with complex data
    panel:NetMessage("liaComplexAction", function(pnl)
        net.WriteString(pnl.actionType)
        net.WriteEntity(pnl.target)
        net.WriteTable(pnl.data)
    end)

```

---

### Stick

#### 📋 Purpose
Docks the panel to its parent with optional margin

#### ⏰ When Called
When initializing a panel that should be docked to its parent

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `dock` | **number, optional** | The dock direction (FILL, LEFT, TOP, RIGHT, BOTTOM). Defaults to FILL |
| `margin` | **number, optional** | The margin size in pixels. Defaults to 0 |
| `dontInvalidate` | **boolean, optional** | If true, doesn't invalidate the parent layout |

#### ↩️ Returns
* Nothing

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Dock panel to fill
    panel:Stick()

```

#### 📊 Medium Complexity
```lua
    -- Medium: Dock with margin
    panel:Stick(FILL, 5)

```

#### ⚙️ High Complexity
```lua
    -- High: Dock with custom settings
    panel:Stick(TOP, 10, true)

```

---

### DivTall

#### 📋 Purpose
Sets the panel height to a fraction of the target panel's height

#### ⏰ When Called
When initializing a panel that should be a fraction of another panel's height

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `frac` | **number, optional** | The fraction to divide by. Defaults to 2 (half height) |
| `target` | **Panel, optional** | The target panel to measure from. Defaults to parent panel |

#### ↩️ Returns
* Nothing

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Set to half height of parent
    panel:DivTall()

```

#### 📊 Medium Complexity
```lua
    -- Medium: Set to third height
    panel:DivTall(3)

```

#### ⚙️ High Complexity
```lua
    -- High: Set to fraction of specific panel
    panel:DivTall(4, targetPanel)

```

---

### DivWide

#### 📋 Purpose
Sets the panel width to a fraction of the target panel's width

#### ⏰ When Called
When initializing a panel that should be a fraction of another panel's width

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `frac` | **number, optional** | The fraction to divide by. Defaults to 2 (half width) |
| `target` | **Panel, optional** | The target panel to measure from. Defaults to parent panel |

#### ↩️ Returns
* Nothing

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Set to half width of parent
    panel:DivWide()

```

#### 📊 Medium Complexity
```lua
    -- Medium: Set to third width
    panel:DivWide(3)

```

#### ⚙️ High Complexity
```lua
    -- High: Set to fraction of specific panel
    panel:DivWide(4, targetPanel)

```

---

### SquareFromHeight

#### 📋 Purpose
Sets the panel width to match its height, making it square

#### ⏰ When Called
When initializing a panel that should be square based on height

#### ↩️ Returns
* Nothing

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Make panel square from height
    panel:SquareFromHeight()

```

#### 📊 Medium Complexity
```lua
    -- Medium: Set height then make square
    panel:SetTall(64)
    panel:SquareFromHeight()

```

#### ⚙️ High Complexity
```lua
    -- High: Make square with calculated height
    panel:SetTall(ScrH() * 0.1)
    panel:SquareFromHeight()

```

---

### SquareFromWidth

#### 📋 Purpose
Sets the panel height to match its width, making it square

#### ⏰ When Called
When initializing a panel that should be square based on width

#### ↩️ Returns
* Nothing

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Make panel square from width
    panel:SquareFromWidth()

```

#### 📊 Medium Complexity
```lua
    -- Medium: Set width then make square
    panel:SetWide(64)
    panel:SquareFromWidth()

```

#### ⚙️ High Complexity
```lua
    -- High: Make square with calculated width
    panel:SetWide(ScrW() * 0.1)
    panel:SquareFromWidth()

```

---

### SetRemove

#### 📋 Purpose
Sets the panel to remove a target panel when clicked

#### ⏰ When Called
When initializing a panel that should remove another panel on click

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `target` | **Panel, optional** | The panel to remove. Defaults to self |

#### ↩️ Returns
* Nothing

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Remove self on click
    button:SetRemove()

```

#### 📊 Medium Complexity
```lua
    -- Medium: Remove parent on click
    button:SetRemove(parentPanel)

```

#### ⚙️ High Complexity
```lua
    -- High: Remove specific panel with validation
    if IsValid(targetPanel) then
        button:SetRemove(targetPanel)
    end

```

---

### FadeIn

#### 📋 Purpose
Animates the panel to fade in from transparent

#### ⏰ When Called
When initializing a panel that should fade in on creation

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `time` | **number, optional** | The fade in duration in seconds. Defaults to 0.2 |
| `alpha` | **number, optional** | The target alpha value. Defaults to 255 |

#### ↩️ Returns
* Nothing

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Fade in panel
    panel:FadeIn()

```

#### 📊 Medium Complexity
```lua
    -- Medium: Fade in with custom time
    panel:FadeIn(0.5)

```

#### ⚙️ High Complexity
```lua
    -- High: Fade in with custom time and alpha
    panel:FadeIn(0.3, 200)

```

---

### HideVBar

#### 📋 Purpose
Hides the vertical scrollbar of a scrollable panel

#### ⏰ When Called
When initializing a scrollable panel that should hide its scrollbar

#### ↩️ Returns
* Nothing

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Hide scrollbar
    scrollPanel:HideVBar()

```

#### 📊 Medium Complexity
```lua
    -- Medium: Hide scrollbar after setup
    local scroll = vgui.Create("DScrollPanel")
    scroll:HideVBar()

```

#### ⚙️ High Complexity
```lua
    -- High: Hide scrollbar with custom panel
    customScrollPanel:HideVBar()

```

---

### SetTransitionFunc

#### 📋 Purpose
Sets a custom transition function for SetupTransition

#### ⏰ When Called
When setting up a panel that needs a custom transition condition

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `fn` | **function** | The transition function: function(panel) returns boolean |

#### ↩️ Returns
* Nothing

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Set transition function
    panel:SetTransitionFunc(function(s) return s:IsHovered() end)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Set transition with custom condition
    panel:SetTransitionFunc(function(s) return s.value > 0 end)

```

#### ⚙️ High Complexity
```lua
    -- High: Set transition with complex condition
    panel:SetTransitionFunc(function(s)
        return s:IsHovered() and s.enabled
    end)

```

---

### SetTransitionFunc

#### 📋 Purpose
Sets a custom transition function for SetupTransition

#### ⏰ When Called
When setting up a panel that needs a custom transition condition

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `fn` | **function** | The transition function: function(panel) returns boolean |

#### ↩️ Returns
* Nothing

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Set transition function
    panel:SetTransitionFunc(function(s) return s:IsHovered() end)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Set transition with custom condition
    panel:SetTransitionFunc(function(s) return s.value > 0 end)

```

#### ⚙️ High Complexity
```lua
    -- High: Set transition with complex condition
    panel:SetTransitionFunc(function(s)
        return s:IsHovered() and s.enabled
    end)

```

---

### ClearTransitionFunc

#### 📋 Purpose
Clears the custom transition function

#### ⏰ When Called
When removing a custom transition function from a panel

#### ↩️ Returns
* Nothing

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Clear transition function
    panel:ClearTransitionFunc()

```

#### 📊 Medium Complexity
```lua
    -- Medium: Clear after disabling feature
    if not useTransitions then
        panel:ClearTransitionFunc()
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Clear with state management
    panel:ClearTransitionFunc()
    panel.transitionEnabled = false

```

---

### ClearTransitionFunc

#### 📋 Purpose
Clears the custom transition function

#### ⏰ When Called
When removing a custom transition function from a panel

#### ↩️ Returns
* Nothing

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Clear transition function
    panel:ClearTransitionFunc()

```

#### 📊 Medium Complexity
```lua
    -- Medium: Clear after disabling feature
    if not useTransitions then
        panel:ClearTransitionFunc()
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Clear with state management
    panel:ClearTransitionFunc()
    panel.transitionEnabled = false

```

---

### SetAppendOverwrite

#### 📋 Purpose
Sets a custom append overwrite function for the On method

#### ⏰ When Called
When setting up a panel that needs custom hook name modification

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `fn` | **string or function** | The hook name to use instead of the default |

#### ↩️ Returns
* Nothing

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Set append overwrite
    panel:SetAppendOverwrite("PaintOver")

```

#### 📊 Medium Complexity
```lua
    -- Medium: Set with conditional
    panel:SetAppendOverwrite(usePaintOver and "PaintOver" or "Paint")

```

#### ⚙️ High Complexity
```lua
    -- High: Set with dynamic name
    panel:SetAppendOverwrite(customHookName)

```

---

### ClearAppendOverwrite

#### 📋 Purpose
Clears the custom append overwrite function

#### ⏰ When Called
When removing a custom append overwrite from a panel

#### ↩️ Returns
* Nothing

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Clear append overwrite
    panel:ClearAppendOverwrite()

```

#### 📊 Medium Complexity
```lua
    -- Medium: Clear after disabling feature
    if not useCustomHook then
        panel:ClearAppendOverwrite()
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Clear with state management
    panel:ClearAppendOverwrite()
    panel.customHookEnabled = false

```

---

### ClearPaint

#### 📋 Purpose
Removes the Paint function from the panel

#### ⏰ When Called
When initializing a panel that should not have custom painting

#### ↩️ Returns
* Nothing

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Clear paint function
    panel:ClearPaint()

```

#### 📊 Medium Complexity
```lua
    -- Medium: Clear paint conditionally
    if not useCustomPaint then
        panel:ClearPaint()
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Clear paint with state management
    panel:ClearPaint()
    panel.hasCustomPaint = false

```

---

### ClearPaint

#### 📋 Purpose
Removes the Paint function from the panel

#### ⏰ When Called
When initializing a panel that should not have custom painting

#### ↩️ Returns
* Nothing

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Clear paint function
    panel:ClearPaint()

```

#### 📊 Medium Complexity
```lua
    -- Medium: Clear paint conditionally
    if not useCustomPaint then
        panel:ClearPaint()
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Clear paint with state management
    panel:ClearPaint()
    panel.hasCustomPaint = false

```

---

### ReadyTextbox

#### 📋 Purpose
Prepares a textbox panel with custom styling and transition setup

#### ⏰ When Called
When initializing a textbox that should have custom styling

#### ↩️ Returns
* Nothing

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Prepare textbox
    textbox:ReadyTextbox()

```

#### 📊 Medium Complexity
```lua
    -- Medium: Prepare textbox with setup
    local textbox = vgui.Create("DTextEntry")
    textbox:ReadyTextbox()

```

#### ⚙️ High Complexity
```lua
    -- High: Prepare textbox with full setup
    local textbox = vgui.Create("DTextEntry")
    textbox:SetSize(200, 30)
    textbox:ReadyTextbox()

```

---

