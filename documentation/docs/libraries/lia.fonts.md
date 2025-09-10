# Fonts Library

This page documents the functions for working with custom fonts and text rendering.

---

## Overview

The fonts library (`lia.font`) provides a comprehensive system for managing custom fonts, font registration, and text rendering in the Lilia framework. It includes font loading, caching, and rendering functionality.

---

### lia.font.register

**Purpose**

Registers a new font with the font system.

**Parameters**

* `fontName` (*string*): The name of the font.
* `fontData` (*table*): The font data table containing font, size, weight, etc.

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Register a basic font
lia.font.register("MyFont", {
    font = "Arial",
    size = 16,
    weight = 500
})

-- Register a font with more options
lia.font.register("CustomFont", {
    font = "Roboto",
    size = 24,
    weight = 700,
    antialias = true,
    outline = true,
    shadow = true
})

-- Register a font with custom properties
lia.font.register("TitleFont", {
    font = "Impact",
    size = 32,
    weight = 900,
    antialias = true,
    outline = true,
    outlineSize = 2,
    shadow = true,
    shadowOffset = 2
})

-- Use in a function
local function createFont(name, font, size, weight)
    lia.font.register(name, {
        font = font,
        size = size,
        weight = weight or 500
    })
    print("Font registered: " .. name)
end
```

---

### lia.font.getAvailableFonts

**Purpose**

Gets a list of all available fonts.

**Parameters**

*None*

**Returns**

* `fonts` (*table*): Table of available font names.

**Realm**

Client.

**Example Usage**

```lua
-- Get available fonts
local function getAvailableFonts()
    return lia.font.getAvailableFonts()
end

-- Use in a function
local function showAvailableFonts()
    local fonts = lia.font.getAvailableFonts()
    print("Available fonts:")
    for _, font in ipairs(fonts) do
        print("- " .. font)
    end
end

-- Use in a function
local function getFontCount()
    local fonts = lia.font.getAvailableFonts()
    return #fonts
end

-- Use in a function
local function checkFontExists(fontName)
    local fonts = lia.font.getAvailableFonts()
    for _, font in ipairs(fonts) do
        if font == fontName then
            return true
        end
    end
    return false
end
```

---

### lia.font.refresh

**Purpose**

Refreshes the font system and reloads all fonts.

**Parameters**

*None*

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Refresh font system
local function refreshFonts()
    lia.font.refresh()
    print("Font system refreshed")
end

-- Use in a function
local function reloadFonts()
    lia.font.refresh()
    print("All fonts reloaded")
end

-- Use in a function
local function resetFontSystem()
    lia.font.refresh()
    print("Font system reset")
end

-- Use in a command
lia.command.add("refreshfonts", {
    onRun = function(client, arguments)
        lia.font.refresh()
        client:notify("Font system refreshed")
    end
})
```

---

### lia.font.get

**Purpose**

Gets a font by name.

**Parameters**

* `fontName` (*string*): The name of the font to get.

**Returns**

* `font` (*Font*): The font object or nil.

**Realm**

Client.

**Example Usage**

```lua
-- Get a font
local function getFont(fontName)
    return lia.font.get(fontName)
end

-- Use in a function
local function drawTextWithFont(text, fontName, x, y, color)
    local font = lia.font.get(fontName)
    if font then
        draw.SimpleText(text, font, x, y, color)
    else
        draw.SimpleText(text, "Default", x, y, color)
    end
end

-- Use in a function
local function checkFontLoaded(fontName)
    local font = lia.font.get(fontName)
    if font then
        print("Font loaded: " .. fontName)
        return true
    else
        print("Font not loaded: " .. fontName)
        return false
    end
end

-- Use in a function
local function getFontSize(fontName)
    local font = lia.font.get(fontName)
    if font then
        return font:GetTall()
    end
    return 0
end
```

---

### lia.font.create

**Purpose**

Creates a new font with the given parameters.

**Parameters**

* `fontName` (*string*): The name of the font to create.
* `fontData` (*table*): The font data table.

**Returns**

* `font` (*Font*): The created font object.

**Realm**

Client.

**Example Usage**

```lua
-- Create a font
local function createFont(fontName, fontData)
    return lia.font.create(fontName, fontData)
end

-- Use in a function
local function createCustomFont(name, font, size)
    local fontData = {
        font = font,
        size = size,
        weight = 500
    }
    return lia.font.create(name, fontData)
end

-- Use in a function
local function createTitleFont()
    local fontData = {
        font = "Impact",
        size = 48,
        weight = 900,
        antialias = true,
        outline = true
    }
    return lia.font.create("TitleFont", fontData)
end

-- Use in a function
local function createUIFont()
    local fontData = {
        font = "Arial",
        size = 14,
        weight = 400,
        antialias = true
    }
    return lia.font.create("UIFont", fontData)
end
```

---

### lia.font.remove

**Purpose**

Removes a font from the font system.

**Parameters**

* `fontName` (*string*): The name of the font to remove.

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Remove a font
local function removeFont(fontName)
    lia.font.remove(fontName)
end

-- Use in a function
local function removeOldFont(fontName)
    lia.font.remove(fontName)
    print("Font removed: " .. fontName)
end

-- Use in a function
local function cleanupFonts()
    local oldFonts = {"OldFont1", "OldFont2", "OldFont3"}
    for _, font in ipairs(oldFonts) do
        lia.font.remove(font)
    end
    print("Old fonts cleaned up")
end

-- Use in a function
local function removeUnusedFonts()
    local fonts = lia.font.getAvailableFonts()
    for _, font in ipairs(fonts) do
        if not lia.font.isUsed(font) then
            lia.font.remove(font)
        end
    end
end
```

---

### lia.font.clear

**Purpose**

Clears all fonts from the font system.

**Parameters**

*None*

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Clear all fonts
local function clearAllFonts()
    lia.font.clear()
end

-- Use in a function
local function resetFontSystem()
    lia.font.clear()
    print("All fonts cleared")
end

-- Use in a function
local function reloadAllFonts()
    lia.font.clear()
    -- Re-register default fonts
    lia.font.register("Default", {font = "Arial", size = 16})
    lia.font.register("Title", {font = "Impact", size = 32})
    print("Font system reloaded")
end

-- Use in a command
lia.command.add("clearfonts", {
    onRun = function(client, arguments)
        lia.font.clear()
        client:notify("All fonts cleared")
    end
})
```

---

### lia.font.isLoaded

**Purpose**

Checks if a font is loaded.

**Parameters**

* `fontName` (*string*): The name of the font to check.

**Returns**

* `isLoaded` (*boolean*): True if the font is loaded.

**Realm**

Client.

**Example Usage**

```lua
-- Check if font is loaded
local function isFontLoaded(fontName)
    return lia.font.isLoaded(fontName)
end

-- Use in a function
local function checkFontStatus(fontName)
    if lia.font.isLoaded(fontName) then
        print("Font is loaded: " .. fontName)
        return true
    else
        print("Font is not loaded: " .. fontName)
        return false
    end
end

-- Use in a function
local function ensureFontLoaded(fontName)
    if not lia.font.isLoaded(fontName) then
        lia.font.refresh()
        if lia.font.isLoaded(fontName) then
            print("Font loaded after refresh: " .. fontName)
        else
            print("Failed to load font: " .. fontName)
        end
    end
end

-- Use in a function
local function checkAllFontsLoaded()
    local fonts = lia.font.getAvailableFonts()
    for _, font in ipairs(fonts) do
        if not lia.font.isLoaded(font) then
            print("Font not loaded: " .. font)
        end
    end
end
```

---

### lia.font.getSize

**Purpose**

Gets the size of a font.

**Parameters**

* `fontName` (*string*): The name of the font.

**Returns**

* `size` (*number*): The font size.

**Realm**

Client.

**Example Usage**

```lua
-- Get font size
local function getFontSize(fontName)
    return lia.font.getSize(fontName)
end

-- Use in a function
local function showFontInfo(fontName)
    local size = lia.font.getSize(fontName)
    print("Font: " .. fontName .. " Size: " .. size)
end

-- Use in a function
local function compareFontSizes(font1, font2)
    local size1 = lia.font.getSize(font1)
    local size2 = lia.font.getSize(font2)
    if size1 > size2 then
        print(font1 .. " is larger than " .. font2)
    elseif size1 < size2 then
        print(font1 .. " is smaller than " .. font2)
    else
        print("Both fonts are the same size")
    end
end

-- Use in a function
local function getLargestFont()
    local fonts = lia.font.getAvailableFonts()
    local largest = nil
    local maxSize = 0
    for _, font in ipairs(fonts) do
        local size = lia.font.getSize(font)
        if size > maxSize then
            maxSize = size
            largest = font
        end
    end
    return largest
end
```

---

### lia.font.getHeight

**Purpose**

Gets the height of a font.

**Parameters**

* `fontName` (*string*): The name of the font.

**Returns**

* `height` (*number*): The font height.

**Realm**

Client.

**Example Usage**

```lua
-- Get font height
local function getFontHeight(fontName)
    return lia.font.getHeight(fontName)
end

-- Use in a function
local function calculateTextHeight(text, fontName)
    local height = lia.font.getHeight(fontName)
    return height
end

-- Use in a function
local function drawMultilineText(text, fontName, x, y, color)
    local height = lia.font.getHeight(fontName)
    local lines = string.Explode("\n", text)
    for i, line in ipairs(lines) do
        draw.SimpleText(line, fontName, x, y + (i - 1) * height, color)
    end
end

-- Use in a function
local function centerTextVertically(text, fontName, y, height)
    local fontHeight = lia.font.getHeight(fontName)
    local centerY = y + (height - fontHeight) / 2
    return centerY
end
```

---

### lia.font.getWidth

**Purpose**

Gets the width of text in a font.

**Parameters**

* `text` (*string*): The text to measure.
* `fontName` (*string*): The name of the font.

**Returns**

* `width` (*number*): The text width.

**Realm**

Client.

**Example Usage**

```lua
-- Get text width
local function getTextWidth(text, fontName)
    return lia.font.getWidth(text, fontName)
end

-- Use in a function
local function centerTextHorizontally(text, fontName, x, width)
    local textWidth = lia.font.getWidth(text, fontName)
    local centerX = x + (width - textWidth) / 2
    return centerX
end

-- Use in a function
local function wrapText(text, fontName, maxWidth)
    local words = string.Explode(" ", text)
    local lines = {}
    local currentLine = ""
    
    for _, word in ipairs(words) do
        local testLine = currentLine .. (currentLine == "" and "" or " ") .. word
        local width = lia.font.getWidth(testLine, fontName)
        
        if width > maxWidth then
            table.insert(lines, currentLine)
            currentLine = word
        else
            currentLine = testLine
        end
    end
    
    if currentLine ~= "" then
        table.insert(lines, currentLine)
    end
    
    return lines
end

-- Use in a function
local function truncateText(text, fontName, maxWidth)
    local width = lia.font.getWidth(text, fontName)
    if width <= maxWidth then
        return text
    end
    
    local truncated = text
    while lia.font.getWidth(truncated .. "...", fontName) > maxWidth and #truncated > 0 do
        truncated = string.sub(truncated, 1, -2)
    end
    
    return truncated .. "..."
end
```

---

### lia.font.draw

**Purpose**

Draws text using a specific font.

**Parameters**

* `text` (*string*): The text to draw.
* `fontName` (*string*): The name of the font.
* `x` (*number*): The x position.
* `y` (*number*): The y position.
* `color` (*Color*): The text color.

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Draw text with font
local function drawText(text, fontName, x, y, color)
    lia.font.draw(text, fontName, x, y, color)
end

-- Use in a function
local function drawCenteredText(text, fontName, x, y, color)
    local width = lia.font.getWidth(text, fontName)
    local height = lia.font.getHeight(fontName)
    lia.font.draw(text, fontName, x - width / 2, y - height / 2, color)
end

-- Use in a function
local function drawOutlinedText(text, fontName, x, y, color, outlineColor)
    lia.font.draw(text, fontName, x, y, color)
    lia.font.draw(text, fontName, x + 1, y, outlineColor)
    lia.font.draw(text, fontName, x - 1, y, outlineColor)
    lia.font.draw(text, fontName, x, y + 1, outlineColor)
    lia.font.draw(text, fontName, x, y - 1, outlineColor)
end

-- Use in a function
local function drawShadowedText(text, fontName, x, y, color, shadowColor)
    lia.font.draw(text, fontName, x + 2, y + 2, shadowColor)
    lia.font.draw(text, fontName, x, y, color)
end
```