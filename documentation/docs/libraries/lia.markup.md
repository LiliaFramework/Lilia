# Markup Library

This page covers helpers for parsing and drawing lightweight markup.

---

## Overview

The markup library parses a small set of HTML-like tags for drawing rich text in chat panels. It handles basic colour, font and image formatting.

---

### lia.markup.parse

**Purpose**

Parses markup text and returns a markup object that handles wrapping and drawing.

**Parameters**

* `ml` (*string*): Markup string to parse.
* `maxwidth` (*number | nil*): Maximum width in pixels for wrapping; `nil` disables wrapping.

**Realm**

`Client`

**Returns**

* *MarkupObject*: Parsed markup object with size information.

**Example Usage**

```lua
local object = lia.markup.parse("<color=255,0,0>Hello world!</color>", 200)
print(object:getWidth(), object:getHeight())
```

*Supports `<color>`/`<colour>`, `<font>`/`<face>`, and `<img=path,widthxheight>` tags. Named colours such as `red` or `ltgrey` are recognised via an internal table. Text defaults to white (`255,255,255,255`) in the `DermaDefault` font. HTML entities `&lt;`, `&gt;`, and `&amp;` are automatically decoded. When `maxwidth` is provided the text wraps automatically; images default to `16x16` pixels if no size is specified.*

---

### MarkupObject:create

**Purpose**

Constructs an empty markup object (usually returned by `lia.markup.parse`).

**Parameters**

* *None*

**Realm**

`Client`

**Returns**

* *MarkupObject*: Newly constructed object with zero size.

**Example Usage**

```lua
-- Usually markup objects are created via lia.markup.parse
local obj = lia.markup.parse("")
```

---

### MarkupObject fields

* `totalWidth` (*number*) – Total width in pixels of all text blocks, defaults to `0`.
* `totalHeight` (*number*) – Overall height in pixels, defaults to `0`.
* `blocks` (*table*) – Internal table describing each parsed block.
* `onDrawText` (*function | nil*) – Callback used by `:draw` when set.

The `onDrawText` callback receives `(text, font, x, y, colour, halign, valign, alphaoverride, block)`.

---

### MarkupObject:getWidth

**Purpose**

Returns the pixel width of the parsed markup text.

**Parameters**

* *None*

**Realm**

`Client`

**Returns**

* *number*: Width in pixels.

**Example Usage**

```lua
local obj = lia.markup.parse("<font=liaBigFont>Hello</font>")
print(obj:getWidth())
```

---

### MarkupObject:getHeight

**Purpose**

Returns the pixel height of the parsed markup text.

**Parameters**

* *None*

**Realm**

`Client`

**Returns**

* *number*: Height in pixels.

**Example Usage**

```lua
local obj = lia.markup.parse("<font=liaBigFont>Hello</font>")
print(obj:getHeight())
```

---

### MarkupObject:size

**Purpose**

Returns both width and height of the markup object.

**Parameters**

* *None*

**Realm**

`Client`

**Returns**

* *number*, *number*: Width and height in pixels.

**Example Usage**

```lua
local obj = lia.markup.parse("<font=liaBigFont>Hello</font>")
local w, h = obj:size()
```

---

### MarkupObject:draw

**Purpose**

Draws the markup object at the specified screen position.

**Parameters**

* `xOffset` (*number*): X position.
* `yOffset` (*number*): Y position.
* `halign` (*number | nil*): Horizontal alignment (`1` centre, `2` right). Defaults to left.
* `valign` (*number | nil*): Vertical alignment (`1` centre, `3` bottom). Defaults to top.
* `alphaoverride` (*number | nil*): Override the alpha channel. *Optional*.

**Realm**

`Client`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
local obj = lia.markup.parse("<color=0,255,0>Welcome</color>", 300)

hook.Add("HUDPaint", "DrawWelcome", function()
    obj:draw(
        ScrW() / 2,
        ScrH() / 2,
        TEXT_ALIGN_CENTER,
        TEXT_ALIGN_CENTER,
        200
    )
end)
```

---

### liaMarkupPanel:setMarkup

**Purpose**

Configures a `liaMarkupPanel` to display markup text with an optional custom draw callback.

**Parameters**

* `text` (*string*): Markup to render.
* `onDrawText` (*function | nil*): Callback executed before each block is drawn. *Optional*.

**Realm**

`Client`

**Returns**

* *nil*: This function does not return a value.

The panel's width is used as the wrapping width and its height is automatically resized to fit the content.

**Example Usage**

```lua
local panel = vgui.Create("liaMarkupPanel")
panel:SetWide(300)

panel:setMarkup(
    "<font=liaMediumFont>Hi there!</font>",
    function(text, font, x, y, colour, halign, valign, alphaoverride, block)
        draw.SimpleText(text, font, x, y, colour)
    end
)
```

---
