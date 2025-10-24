# Font Library

Comprehensive font management system for the Lilia framework.

---

## Overview

The font library provides comprehensive functionality for managing custom fonts in the Lilia framework.

It handles font registration, loading, and automatic font creation for UI elements throughout the

gamemode. The library operates on both server and client sides, with the server storing font

metadata and the client handling actual font creation and rendering. It includes automatic font

generation for various sizes and styles, dynamic font loading based on configuration, and intelligent

font name parsing for automatic font creation. The library ensures consistent typography across

all UI elements and provides easy access to predefined font variants for different use cases.

---

### loadFonts

**Purpose**

Loads all registered fonts into the game's font system by iterating through stored fonts and creating them

**When Called**

Called during initialization after font registration and during font refresh operations

---

### register

**Purpose**

Registers a custom font with the framework's font system

**When Called**

Called when defining new fonts for UI elements or during font initialization

**Parameters**

* `fontName` (*string*): The unique identifier for the font
* `fontData` (*table*): Font configuration table containing font properties (font, size, weight, etc.)

---

### getAvailableFonts

**Purpose**

Retrieves a sorted list of all registered font names in the framework

**When Called**

Used for populating font selection menus or displaying available fonts to users

**Parameters**

* `list` (*table*): An alphabetically sorted table of font name strings

---

### getBoldFontName

**Purpose**

Converts a font name to its bold variant by replacing Medium with Bold in the name

**When Called**

Used when registering bold font variants or dynamically generating bold fonts

**Parameters**

* `fontName` (*string*): The base font name to convert to bold

---

### registerFonts

**Purpose**

Registers all default fonts used by the Lilia framework including size variants, bold, and italic styles

**When Called**

Called during initialization and when the font configuration changes

**Parameters**

* `fontName` (*string, optional*): The base font name to use. If not provided, uses the configured font setting

---

### lia.surface.SetFont

**Purpose**

Registers all default fonts used by the Lilia framework including size variants, bold, and italic styles

**When Called**

Called during initialization and when the font configuration changes

**Parameters**

* `fontName` (*string, optional*): The base font name to use. If not provided, uses the configured font setting

---

