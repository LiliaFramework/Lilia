# Attribute Hooks

This document lists hooks related to attribute setup and changes.

---

## Overview

Each class can implement lifecycle hooks to control access, initialize settings, and respond to events such as joining, leaving, spawning, or being transferred. All hooks are optional; unspecified hooks will not alter default behavior.

---

### `lia.workshop.gather()`

    
    Description:
    Collects workshop IDs from installed addons and registered modules.
    
    Realm:
    Server
    
    Returns:
    ids (table) – Table of workshop IDs to download.
    
    Example Usage:
    -- This snippet demonstrates a common usage of lia.workshop.gather
    local ids = lia.workshop.gather()

### `lia.workshop.send(ply)`

    
    Description:
    Sends the collected workshop IDs to a connecting player.
    
    Parameters:
    ply (Player) – Player to send the download list to.
    
    Realm:
    Server
    
    Returns:
    None
    
    Example Usage:
    -- This snippet demonstrates a common usage of lia.workshop.send
    lia.workshop.send(ply)
