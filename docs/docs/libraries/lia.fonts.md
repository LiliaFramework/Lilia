# Attribute Hooks

This document lists hooks related to attribute setup and changes.

---

## Overview

Each class can implement lifecycle hooks to control access, initialize settings, and respond to events such as joining, leaving, spawning, or being transferred. All hooks are optional; unspecified hooks will not alter default behavior.

---

### `lia.font.register(fontName, fontData)`

    
    Description:
    Creates and stores a font using surface.CreateFont for later refresh.
    
    Parameters:
    fontName (string) – Font identifier.
    fontData (table) – Font properties table.
    
    Realm:
    Client
    
    Returns:
    None
    
    Example Usage:
    -- This snippet demonstrates a common usage of lia.font.register
    lia.font.register("MyFont", {font = "Arial", size = 16})

### `lia.font.getAvailableFonts()`

    
    Description:
    Returns a sorted list of font names that have been registered.
    
    Parameters:
    None
    
    Returns:
    table – Array of font name strings.
    
    Realm:
    Client
    
    Example Usage:
    -- This snippet demonstrates a common usage of lia.font.getAvailableFonts
    local fonts = lia.font.getAvailableFonts()
    PrintTable(fonts)

### `lia.font.refresh()`

    
    Description:
    Recreates all stored fonts. Called when font related config values change.
    
    Parameters:
    None
    
    Returns:
    None
    
    Realm:
    Client
    
    Example Usage:
    -- This snippet demonstrates a common usage of lia.font.refresh
    lia.font.refresh()
