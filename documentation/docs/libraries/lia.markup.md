# Markup Library

This page documents the functions for working with markup text rendering and formatting.

---

## Overview

The markup library (`lia.markup`) provides a comprehensive text markup system for the Lilia framework, enabling rich text formatting and visual enhancement throughout all user-facing text elements. This library handles sophisticated markup processing with support for a wide range of formatting options including colors, fonts, images, custom styling, and interactive elements through an intuitive and powerful markup language. The system features advanced text rendering with support for complex layouts, multi-line formatting, and dynamic content generation that adapts to different screen sizes and UI contexts. It includes comprehensive markup validation with error handling, security filtering to prevent malicious content, and performance optimization for large text blocks to ensure smooth user experience. The library provides robust integration with the framework's UI system, offering seamless markup support for chat messages, item descriptions, tooltips, notifications, and other text elements. Additional features include custom markup tag support for specialized formatting needs, theme-aware styling that adapts to different UI themes, and accessibility features for players with visual impairments, making it essential for creating polished and professional user interfaces that enhance readability and user engagement.

---

### parse

**Purpose**

Parses markup text and creates a markup object for rendering. This is the core function that converts markup-formatted text into a renderable object with proper text blocks, colors, fonts, and images.

**Parameters**

* `ml` (*string*): The markup text to parse.
* `maxwidth` (*number*, optional): Maximum width for text wrapping. If not provided, text will not wrap.

**Returns**

* `markupObject` (*MarkupObject*): The parsed markup object ready for rendering.

**Realm**

Client.

**Example Usage**

```lua
-- Parse simple markup text
local function parseSimpleText()
    local markupObj = lia.markup.parse("Hello <color=red>World</color>!")
    return markupObj
end

-- Parse text with width constraint
local function parseTextWithWrapping()
    local markupObj = lia.markup.parse("This is a long text that should wrap when it reaches the maximum width.", 300)
    return markupObj
end

-- Parse complex markup with images and fonts
local function parseComplexMarkup()
    local markupText = [[
        <font=DermaLarge>Welcome to</font>
        <color=255,0,0>Lilia Framework</color>
        <img=icon16/information.png,16x16>
        <br>
        <font=DermaDefault>This is a test of the markup system.</font>
    ]]
    local markupObj = lia.markup.parse(markupText)
    return markupObj
end

-- Use in a panel paint function
local function createMarkupPanel(text, width)
    local panel = vgui.Create("DPanel")
    panel:SetSize(width, 100)

    panel.Paint = function(self, w, h)
        local markupObj = lia.markup.parse(text, w - 10)
        markupObj:draw(5, 5)
    end

    return panel
end
```

---

### MarkupObject

**Purpose**

The MarkupObject class represents parsed markup text that can be rendered on screen. It contains all the necessary information for drawing text blocks, images, and applying formatting.

**Methods**

#### create

Creates a new MarkupObject instance.

**Parameters**

*None*

**Returns**

* `markupObject` (*MarkupObject*): A new markup object instance.

**Realm**

Client.

**Example Usage**

```lua
-- Create a new markup object
local function createMarkupObject()
    local obj = lia.markup.MarkupObject:create()
    return obj
end
```

#### getWidth

Gets the total width of the rendered markup.

**Parameters**

*None*

**Returns**

* `width` (*number*): The total width in pixels.

**Realm**

Client.

**Example Usage**

```lua
-- Get markup width
local function getMarkupWidth(markupObj)
    local width = markupObj:getWidth()
    print("Markup width: " .. width .. " pixels")
    return width
end
```

#### getHeight

Gets the total height of the rendered markup.

**Parameters**

*None*

**Returns**

* `height` (*number*): The total height in pixels.

**Realm**

Client.

**Example Usage**

```lua
-- Get markup height
local function getMarkupHeight(markupObj)
    local height = markupObj:getHeight()
    print("Markup height: " .. height .. " pixels")
    return height
end
```

#### size

Gets both the width and height of the rendered markup.

**Parameters**

*None*

**Returns**

* `width` (*number*): The total width in pixels.
* `height` (*number*): The total height in pixels.

**Realm**

Client.

**Example Usage**

```lua
-- Get markup size
local function getMarkupSize(markupObj)
    local width, height = markupObj:size()
    print("Markup size: " .. width .. "x" .. height .. " pixels")
    return width, height
end
```

#### draw

Draws the markup object at the specified position with alignment options.

**Parameters**

* `xOffset` (*number*): The X position to draw at.
* `yOffset` (*number*): The Y position to draw at.
* `halign` (*number*, optional): Horizontal alignment (TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, TEXT_ALIGN_RIGHT).
* `valign` (*number*, optional): Vertical alignment (TEXT_ALIGN_TOP, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM).
* `alphaoverride` (*number*, optional): Alpha override for all elements (0-255).

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Draw markup at specific position
local function drawMarkupAtPosition(markupObj, x, y)
    markupObj:draw(x, y)
end

-- Draw centered markup
local function drawCenteredMarkup(markupObj, x, y)
    markupObj:draw(x, y, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

-- Draw markup with alpha override
local function drawFadedMarkup(markupObj, x, y, alpha)
    markupObj:draw(x, y, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, alpha)
end

-- Draw markup in a panel
local function createMarkupPanel(text, width, height)
    local panel = vgui.Create("DPanel")
    panel:SetSize(width, height)

    local markupObj = lia.markup.parse(text, width - 10)

    panel.Paint = function(self, w, h)
        markupObj:draw(5, 5, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end

    return panel
end
```

---

### liaMarkupPanel

**Purpose**

A VGUI panel that automatically handles markup text rendering. This panel simplifies the process of displaying markup text in the UI by automatically parsing and drawing the markup.

**Methods**

#### setMarkup

Sets the markup text for the panel and updates its size accordingly.

**Parameters**

* `text` (*string*): The markup text to display.
* `onDrawText` (*function*, optional): Optional callback function for custom text drawing.

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Create a markup panel
local function createMarkupPanel(text)
    local panel = vgui.Create("liaMarkupPanel")
    panel:setMarkup(text)
    return panel
end

-- Create markup panel with custom text drawing
local function createCustomMarkupPanel(text)
    local panel = vgui.Create("liaMarkupPanel")

    local function customDrawText(text, font, x, y, color, halign, valign, alphaoverride, block)
        -- Custom drawing logic here
        surface.SetFont(font)
        surface.SetTextColor(color.r, color.g, color.b, alphaoverride or color.a)
        surface.SetTextPos(x, y)
        surface.DrawText(text)
    end

    panel:setMarkup(text, customDrawText)
    return panel
end

-- Use in a larger UI
local function createInfoPanel()
    local frame = vgui.Create("DFrame")
    frame:SetSize(400, 300)
    frame:Center()
    frame:SetTitle("Information")

    local markupPanel = vgui.Create("liaMarkupPanel", frame)
    markupPanel:Dock(FILL)
    markupPanel:DockMargin(10, 10, 10, 10)

    local markupText = [[
        <font=DermaLarge>Server Information</font><br>
        <color=0,255,0>Players Online:</color> <color=255,255,0>]] .. #player.GetAll() .. [[</color><br>
        <color=0,255,0>Server Name:</color> <color=255,255,255>]] .. GetHostName() .. [[</color><br>
        <img=icon16/information.png,16x16> Welcome to our server!
    ]]

    markupPanel:setMarkup(markupText)

    frame:MakePopup()
    return frame
end
```

---

## Markup Syntax

The markup system supports various tags for formatting text:

### Color Tags
- `<color=name>` - Use predefined color names (red, blue, green, etc.)
- `<color=r,g,b>` - Use RGB values
- `<color=r,g,b,a>` - Use RGBA values
- `</color>` - Close color tag

### Font Tags
- `<font=fontname>` - Set font family
- `<face=fontname>` - Alternative font tag
- `</font>` or `</face>` - Close font tag

### Image Tags
- `<img=material,w>h>` - Insert image (e.g., `<img=icon16/user.png,16x16>`)
- `<img=material>` - Insert image with default size (16x16)

### Text Formatting
- `<br>` - Line break
- `\n` - Newline character
- `\t` - Tab character

### Special Characters
- `&lt;` - Less than symbol (`<`)
- `&gt;` - Greater than symbol (`>`)
- `&amp;` - Ampersand symbol (`&`)

**Example Markup:**

```markup
<font=DermaLarge>Welcome to <color=255,0,0>Lilia</color>!</font><br>
This is <color=0,255,0>green text</color> with <img=icon16/information.png,16x16> an icon.
<br><br>
<font=DermaDefault>Regular text with <color=255,255,0>yellow</color> highlights.</font>
```

---

## Supported Colors

The markup system includes predefined color names:

**Basic Colors:**
- black, white, red, green, blue, yellow, purple, cyan, turq

**Shades:**
- dkgrey/gray, grey/gray, ltgrey/gray (dark/medium/light variants)
- dkred/dkgreen/dkblue/dkyellow/dkpurple/dkcyan/dkturq
- ltred/ltgreen/ltblue/ltyellow/ltpurple/ltcyan/ltturq

**Usage:**
```markup
<color=red>Red text</color>
<color=dkblue>Dark blue text</color>
<color=ltgreen>Light green text</color>
```

---

