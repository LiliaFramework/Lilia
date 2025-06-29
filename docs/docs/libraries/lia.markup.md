# Markup Library

This page covers markup parsing helpers.

---

## Overview

The markup library parses a subset of HTML-like tags for drawing rich text in chat panels. It handles basic color, size, and font formatting.

---

### lia.markup.parse(text, maxwidth)

    
**Description:**
Parses the provided markup text and returns a markup object representing
the formatted content. When maxwidth is provided, the text will
automatically wrap at that width.
**Parameters:**
* text (string) – String containing markup to be parsed.
* maxwidth (number|nil) – Optional maximum width for wrapping.
**Realm:**
* Client
**Returns:**
* MarkupObject – The parsed markup object with size information.
**Example:**
```lua
    -- This snippet demonstrates a common usage of lia.markup.parse
    local object = lia.markup.parse("<color=255,0,0>Hello</color>", 200)
```
