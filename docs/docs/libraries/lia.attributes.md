# Attributes Library

This page documents the functions for working with character attributes.

---

## Overview

The attributes library loads attribute definitions from Lua files, keeps track of character values, and provides helper methods for modifying them. It also exposes hooks for registering new attributes and controlling how they progress.

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
