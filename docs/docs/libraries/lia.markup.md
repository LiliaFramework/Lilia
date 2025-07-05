# Markup Library

This page covers markup parsing helpers.

---

## Overview

The markup library parses a subset of HTML-like tags for drawing rich text in chat panels. It handles basic color, size, and font formatting.

---

### lia.markup.parse

**Description:**

Parses the provided markup text and returns a markup object representing

the formatted content. When maxwidth is provided, the text will

automatically wrap at that width.

The returned object exposes helper methods such as `getWidth`, `getHeight`, `size`, and `draw` for measuring and rendering the text.

**Parameters:**

* `text` (`string`) – String containing markup to be parsed.


* `maxwidth` (`number|nil`) – Optional maximum width for wrapping.


**Realm:**

* Client


**Returns:**

* MarkupObject – The parsed markup object with size information.


**Example Usage:**

```lua
-- Parse a short colored string that wraps at 200px
local object = lia.markup.parse("<color=255,0,0>Hello world!</color>", 200)
print(object:getWidth(), object:getHeight())
```

### MarkupObject:create

**Description:**

Creates a blank markup object. You generally will not call this

directly—instead, `lia.markup.parse` returns one for you.

**Parameters:**

* None

**Realm:**

* Client

**Returns:**

* MarkupObject – Newly constructed object with zero size.

### MarkupObject Fields

`MarkupObject` instances returned from `lia.markup.parse` expose a few useful properties:

* `totalWidth` (number) – Total width in pixels of all text blocks.

* `totalHeight` (number) – Overall height in pixels.

* `blocks` (table) – Internal table describing each parsed block.

* `onDrawText` (function|nil) – Callback used by `:draw` when set.

### MarkupObject:getWidth

**Description:**

Returns the pixel width of the parsed markup text.

**Parameters:**

* None

**Realm:**

* Client

**Returns:**

* number – Width in pixels.

**Example Usage:**

```lua
local obj = lia.markup.parse("<font=liaBigFont>Hello</font>")
print(obj:getWidth())
```

### MarkupObject:getHeight

**Description:**

Returns the pixel height of the parsed markup text.

**Parameters:**

* None

**Realm:**

* Client

**Returns:**

* number – Height in pixels.

**Example Usage:**

```lua
local obj = lia.markup.parse("<font=liaBigFont>Hello</font>")
print(obj:getHeight())
```

### MarkupObject:size

**Description:**

Returns both width and height of the markup object.

**Parameters:**

* None

**Realm:**

* Client

**Returns:**

* number, number – Width and height in pixels.

**Example Usage:**

```lua
local obj = lia.markup.parse("<font=liaBigFont>Hello</font>")
local w, h = obj:size()
```

### MarkupObject:draw

**Description:**

Draws the markup object at the specified position. Alignment

constants from Garry's Mod (`TEXT_ALIGN_*`) may be supplied and

`alpha` overrides the block alpha values.

**Parameters:**

* `x` (`number`) – X position on the screen.

* `y` (`number`) – Y position on the screen.

* `halign` (`number|nil`) – Horizontal text alignment.

* `valign` (`number|nil`) – Vertical text alignment.

* `alpha` (`number|nil`) – Optional alpha override.

**Realm:**

* Client

**Returns:**

* None

**Example Usage:**

```lua
local obj = lia.markup.parse("<color=0,255,0>Welcome</color>", 300)
hook.Add("HUDPaint", "DrawWelcome", function()
    -- Center the text and draw it with 75% opacity
    obj:draw(ScrW() / 2, ScrH() / 2, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 200)
end)
```

### liaMarkupPanel:setMarkup

**Description:**

Configures a `liaMarkupPanel` to display markup text. The panel

adjusts its height automatically and uses `onDrawText` as a callback

for custom drawing if provided.

**Parameters:**

* `text` (`string`) – Markup text to render.

* `onDrawText` (`function|nil`) – Called before each text block is drawn.

**Realm:**

* Client

**Returns:**

* None

**Example Usage:**

```lua
local panel = vgui.Create("liaMarkupPanel")
panel:SetWide(300)
panel:setMarkup("<font=liaMediumFont>Hi there!</font>", function(text, font, x, y, color)
    draw.SimpleText(text, font, x, y, color)
end)
```
