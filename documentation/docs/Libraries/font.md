# Font Library

Comprehensive font management system for the Lilia framework.

---

Overview

The font library provides comprehensive functionality for managing custom fonts in the Lilia framework. It handles font registration, loading, and automatic font creation for UI elements throughout the gamemode. The library operates on both server and client sides, with the server storing font metadata and the client handling actual font creation and rendering. It includes automatic font generation for various sizes and styles, dynamic font loading based on configuration, and intelligent font name parsing for automatic font creation. The library ensures consistent typography across all UI elements and provides easy access to predefined font variants for different use cases.

---

### lia.font.loadFonts

#### 📋 Purpose
Create all registered fonts on the client and count successes/failures.

#### ⏰ When Called
After registration or config load to ensure fonts exist before drawing.

#### ↩️ Returns
* nil

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    hook.Add("RefreshFonts", "ReloadAllFonts", function()
        lia.font.loadFonts()
    end)

```

---

### lia.font.register

#### 📋 Purpose
Register a single font definition and create it clientside if possible.

#### ⏰ When Called
During font setup or dynamically when encountering unknown font names.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `fontName` | **string** | Unique font identifier. |
| `fontData` | **table** | surface.CreateFont data table. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    lia.font.register("liaDialogHeader", {
        font = "Montserrat Bold",
        size = 28,
        weight = 800,
        antialias = true
    })

```

---

### lia.font.getAvailableFonts

#### 📋 Purpose
List all registered font identifiers.

#### ⏰ When Called
Populate dropdowns or config options for font selection.

#### ↩️ Returns
* table
Sorted array of font names.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    for _, name in ipairs(lia.font.getAvailableFonts()) do
        print("Font:", name)
    end

```

---

### lia.font.getBoldFontName

#### 📋 Purpose
Convert a base font name to its bold variant.

#### ⏰ When Called
When auto-registering bold/shadow variants of LiliaFont entries.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `fontName` | **string** | Base font name. |

#### ↩️ Returns
* string
Best-effort bold font name.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local boldName = lia.font.getBoldFontName("Montserrat Medium")
    lia.font.register("DialogTitle", {font = boldName, size = 26, weight = 800})

```

---

### lia.font.registerFonts

#### 📋 Purpose
Register the full suite of Lilia fonts (regular, bold, italic, sizes).

#### ⏰ When Called
On config load or when switching the base font setting.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `fontName` | **string|nil** | Base font name; defaults to config Font. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    concommand.Add("lia_reload_fonts", function()
        local base = lia.config.get("Font", "Montserrat Medium")
        lia.font.registerFonts(base)
        timer.Simple(0.1, lia.font.loadFonts)
    end)

```

---

