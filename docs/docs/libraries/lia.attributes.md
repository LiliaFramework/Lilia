# Attribute Hooks

This document lists hooks related to attribute setup and changes.

---

## Overview

Each class can implement lifecycle hooks to control access, initialize settings, and respond to events such as joining, leaving, spawning, or being transferred. All hooks are optional; unspecified hooks will not alter default behavior.

---

### `lia.attribs.loadFromDir(directory)`

    
    Description:
    Loads attribute definitions from the given folder. Files prefixed
    with "sh_" are treated as shared and loaded on both client and
    server. The ATTRIBUTE table returned from each file is stored in
    lia.attribs.list using the filename, without prefix or extension,
    as the key.
    
    Parameters:
    directory (string) – Path to the folder containing attribute Lua files.
    
    Realm:
    Shared
    
    Returns:
    nil
    
    Example Usage:
    -- This snippet demonstrates a common usage of lia.attribs.loadFromDir
    lia.attribs.loadFromDir("schema/attributes")

### `lia.attribs.setup(client)`

    
    Description:
    Initializes attribute data for a client's character. Each attribute in
    lia.attribs.list is read from the character and, if the attribute has
    an OnSetup callback, it is executed with the current value.
    
    Parameters:
    client (Player) – The player whose character attributes should be set up.
    
    Realm:
    Server
    
    Returns:
    None
    
    Example Usage:
    -- This snippet demonstrates a common usage of lia.attribs.setup
    lia.attribs.setup(client)
