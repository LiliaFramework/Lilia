# Attribute Hooks

This document lists hooks related to attribute setup and changes.

---

## Overview

Each class can implement lifecycle hooks to control access, initialize settings, and respond to events such as joining, leaving, spawning, or being transferred. All hooks are optional; unspecified hooks will not alter default behavior.

---

### `lia.markup.parse(text, maxwidth)`

    
    Description:
    Parses the provided markup text and returns a markup object representing
    the formatted content. When maxwidth is provided, the text will
    automatically wrap at that width.
    
    Parameters:
    text (string) – String containing markup to be parsed.
    maxwidth (number|nil) – Optional maximum width for wrapping.
    
    Realm:
    Client
    
    Returns:
    MarkupObject – The parsed markup object with size information.
    
    Example Usage:
    -- This snippet demonstrates a common usage of lia.markup.parse
    local object = lia.markup.parse("<color=255,0,0>Hello</color>", 200)
