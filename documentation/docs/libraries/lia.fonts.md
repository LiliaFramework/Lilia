# Font Library

Comprehensive font management system for the Lilia framework.

---

Overview

The font library provides comprehensive functionality for managing custom fonts in the Lilia framework. It handles font registration, loading, and automatic font creation for UI elements throughout the gamemode. The library operates on both server and client sides, with the server storing font metadata and the client handling actual font creation and rendering. It includes automatic font generation for various sizes and styles, dynamic font loading based on configuration, and intelligent font name parsing for automatic font creation. The library ensures consistent typography across all UI elements and provides easy access to predefined font variants for different use cases.

---

### lia.font.loadFonts

#### 📋 Purpose
Loads all registered fonts into the game's font system by iterating through stored fonts and creating them

#### ⏰ When Called
Called during initialization after font registration and during font refresh operations

#### ↩️ Returns
* None

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Load all fonts after registration
    lia.font.loadFonts()

```

#### 📊 Medium Complexity
```lua
    -- Medium: Load fonts after a delay to ensure config is ready
    timer.Simple(0.2, function()
        lia.font.loadFonts()
    end)

```

#### ⚙️ High Complexity
```lua
    -- High: Refresh fonts when configuration changes
    hook.Add("ConfigUpdated", "ReloadFonts", function(key)
        if key == "Font" then
            lia.font.registerFonts()
            timer.Simple(0.1, function()
                lia.font.loadFonts()
                hook.Run("RefreshFonts")
            end)
        end
    end)

```

---

### lia.font.register

#### 📋 Purpose
Registers a custom font with the framework's font system

#### ⏰ When Called
Called when defining new fonts for UI elements or during font initialization

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `fontName` | **string** | The unique identifier for the font |
| `fontData` | **table** | Font configuration table containing font properties (font, size, weight, etc.) |

#### ↩️ Returns
* None (calls lia.error if parameters are invalid)

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Register a basic font
    lia.font.register("MyFont", {
        font = "Roboto",
        size = 16
    })

```

#### 📊 Medium Complexity
```lua
    -- Medium: Register a font with multiple properties
    lia.font.register("MyCustomFont", {
        font     = "Arial",
        size     = 20,
        weight   = 600,
        antialias = true,
        extended = true
    })

```

#### ⚙️ High Complexity
```lua
    -- High: Register multiple fonts with different styles
    local fontConfig = {
        {name = "MenuTitle", size = 32, weight = 700},
        {name = "MenuText", size = 18, weight = 400},
        {name = "MenuSmall", size = 14, weight = 300}
    }
    for _, config in ipairs(fontConfig) do
        lia.font.register(config.name, {
            font      = "Montserrat",
            size      = config.size,
            weight    = config.weight,
            extended  = true,
            antialias = true
        })
    end

```

---

### lia.font.getAvailableFonts

#### 📋 Purpose
Retrieves a sorted list of all registered font names in the framework

#### ⏰ When Called
Used for populating font selection menus or displaying available fonts to users

#### ↩️ Returns
* list (table)
An alphabetically sorted table of font name strings

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Get all available fonts
    local fonts = lia.font.getAvailableFonts()
    print(table.concat(fonts, ", "))

```

#### 📊 Medium Complexity
```lua
    -- Medium: Populate a dropdown menu with available fonts
    local fontList = lia.font.getAvailableFonts()
    local dropdown = vgui.Create("DComboBox")
    for _, fontName in ipairs(fontList) do
        dropdown:AddChoice(fontName)
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Create a font preview panel with all available fonts
    local fonts = lia.font.getAvailableFonts()
    local panel = vgui.Create("DScrollPanel")
    for i, fontName in ipairs(fonts) do
        local label = panel:Add("DLabel")
        label:SetText(fontName .. " - Preview Text")
        label:SetFont(fontName)
        label:Dock(TOP)
        label:DockMargin(5, 5, 5, 0)
    end

```

---

### lia.font.getBoldFontName

#### 📋 Purpose
Converts a font name to its bold variant by replacing Medium with Bold in the name

#### ⏰ When Called
Used when registering bold font variants or dynamically generating bold fonts

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `fontName` | **string** | The base font name to convert to bold |

#### ↩️ Returns
* (string)
The bold variant of the font name

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Get bold version of a font
    local boldFont = lia.font.getBoldFontName("Montserrat Medium")
    -- Returns: "Montserrat Bold"

```

#### 📊 Medium Complexity
```lua
    -- Medium: Register both normal and bold variants
    local baseFontName = "Montserrat Medium"
    lia.font.register("NormalText", {font = baseFontName, size = 16})
    lia.font.register("BoldText", {font = lia.font.getBoldFontName(baseFontName), size = 16, weight = 700})

```

#### ⚙️ High Complexity
```lua
    -- High: Create matching pairs of normal and bold fonts for multiple sizes
    local baseFontName = "Montserrat Medium"
    local sizes = {14, 18, 24, 32}
    for _, size in ipairs(sizes) do
        -- Normal variant
        lia.font.register("CustomFont" .. size, {
            font   = baseFontName,
            size   = size,
            weight = 500
        })
        -- Bold variant
        lia.font.register("CustomFont" .. size .. "Bold", {
            font   = lia.font.getBoldFontName(baseFontName),
            size   = size,
            weight = 700
        })
    end

```

---

### lia.font.registerFonts

#### 📋 Purpose
Registers all default fonts used by the Lilia framework including size variants, bold, and italic styles

#### ⏰ When Called
Called during initialization and when the font configuration changes

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `fontName` | **string, optional** | The base font name to use. If not provided, uses the configured font setting |

#### ↩️ Returns
* None

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Register default fonts
    lia.font.registerFonts()

```

#### 📊 Medium Complexity
```lua
    -- Medium: Register fonts with a custom base font
    lia.font.registerFonts("Roboto")

```

#### ⚙️ High Complexity
```lua
    -- High: Register fonts and hook into completion
    lia.font.registerFonts("Montserrat Medium")
    hook.Add("PostLoadFonts", "MyFontHook", function(mainFont, configuredFont)
        print("Fonts loaded with: " .. mainFont)
        -- Perform additional font-related setup
        for i = 10, 50, 2 do
            lia.font.register("MyCustomFont" .. i, {
                font      = mainFont,
                size      = i,
                extended  = true,
                antialias = true
            })
        end
    end)

```

---

