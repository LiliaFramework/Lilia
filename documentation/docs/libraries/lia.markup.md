# Markup Library

This page documents the functions for working with markup text rendering and formatting.

---

## Overview

The markup library (`lia.markup`) provides a comprehensive text markup system for the Lilia framework. It supports rich text formatting with colors, fonts, images, and custom styling through a simple markup language. The system is used throughout the framework for chat messages, item descriptions, UI elements, and other text rendering needs.

---

### lia.markup.parse

**Purpose**

Parses markup text and returns a markup object that can be used for rendering.

**Parameters**

* `ml` (*string*): The markup text to parse.
* `maxwidth` (*number*): The maximum width for text wrapping.

**Returns**

* `markupObject` (*table*): A markup object containing parsed blocks and rendering information.

**Realm**

Client.

**Example Usage**

```lua
-- Parse simple markup text
local markup = lia.markup.parse("<color=255,0,0>Red text</color>", 300)
markup:draw(10, 10)

-- Parse complex markup with multiple elements
local complexMarkup = [[
<font=liaBigFont>
<color=255,255,0>Welcome to the server!</color>
<color=255,255,255>This is <color=0,255,0>green text</color> inside white text.</color>
<img=icon16/information.png,16x16>
</font>
]]

local parsed = lia.markup.parse(complexMarkup, 400)
parsed:draw(50, 50)

-- Parse markup for item descriptions
local itemDesc = "<font=liaItemDescFont><color=200,200,200>This is a <color=255,215,0>rare</color> item with special properties.</color></font>"
local itemMarkup = lia.markup.parse(itemDesc, ScrW() * 0.5)
itemMarkup:draw(100, 200)

-- Parse chat message markup
local chatMarkup = "<color=255,255,255>Player: <color=0,255,0>Hello world!</color></color>"
local chatParsed = lia.markup.parse(chatMarkup, 300)
chatParsed:draw(10, 10)
```

---

### lia.markup.parse (with custom onDrawText)

**Purpose**

Parses markup text with a custom text drawing function for special rendering effects.

**Parameters**

* `ml` (*string*): The markup text to parse.
* `maxwidth` (*number*): The maximum width for text wrapping.
* `onDrawText` (*function*): Custom function for drawing text blocks.

**Returns**

* `markupObject` (*table*): A markup object with custom text rendering.

**Realm**

Client.

**Example Usage**

```lua
-- Custom text drawing function
local function customDrawText(text, x, y, color, font)
    -- Add shadow effect
    draw.SimpleText(text, font, x + 1, y + 1, Color(0, 0, 0, color.a), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    draw.SimpleText(text, font, x, y, color, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
end

-- Parse with custom drawing
local markup = lia.markup.parse("<color=255,255,0>Shadowed text</color>", 300, customDrawText)
markup:draw(10, 10)

-- Parse for chat with custom effects
local chatMarkup = "<font=liaChatFont><color=255,255,255>Special chat message</color></font>"
local chatParsed = lia.markup.parse(chatMarkup, 400, function(text, x, y, color, font)
    -- Add glow effect
    for i = 1, 3 do
        local glowColor = Color(color.r, color.g, color.b, color.a / 3)
        draw.SimpleText(text, font, x + i, y + i, glowColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end
    draw.SimpleText(text, font, x, y, color, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
end)
chatParsed:draw(50, 50)
```
