# Languages Library

This page explains how translations and phrases are loaded.

---

## Overview

The languages library loads localization files from directories. It resolves phrase keys to translated text and allows runtime language switching. Language files live in `languages/langname.lua` within schemas or modules and contain tables of localized phrases.
---

### lia.lang.loadFromDir(directory)

    
**Description:**
Loads all Lua language files (*.lua) from the specified directory,
includes them as shared files, and merges any defined LANGUAGE table
into the stored language data. If a language name (NAME) is provided in the file,
it is registered in lia.lang.names.
**Parameters:**
* directory (string) – The path to the directory containing language files.
**Returns:**
* nil
**Realm:**
* Shared
    Internal Function:
    true
    
**Example:**
```lua
-- This snippet demonstrates a common usage of lia.lang.loadFromDir
lia.lang.loadFromDir("languages")
```

### lia.lang.AddTable(name, tbl)

    
**Description:**
Adds or merges a table of language key-value pairs into the stored language table
for a specified language. If the language already exists in the storage, the new values
will be merged with the existing ones.
**Parameters:**
* name (string) – The name of the language to update.
* tbl (table) – A table containing language key-value pairs to add.
**Returns:**
* nil
**Realm:**
* Shared
**Example:**
```lua
-- This snippet demonstrates a common usage of lia.lang.AddTable
lia.lang.AddTable("english", {greeting = "Hello"})
```
