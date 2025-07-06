# Languages Library

This page explains how translations and phrases are loaded.

---

## Overview

The languages library loads localization files from directories. It resolves phrase

keys to translated text and allows runtime language switching. Language files live

in `languages/langname.lua` within schemas or modules and contain tables of

localized phrases. Loaded phrases are stored in `lia.lang.stored` while display

names are kept in `lia.lang.names`.

---

### lia.lang.loadFromDir

**Purpose**

Loads all Lua language files from the given directory and merges their `LANGUAGE` tables.

**Parameters**

* `directory` (*string*): Path to the folder containing language files.

**Realm**

`Shared`

**Returns**

* `nil`: Nothing.

**Example**

```lua
-- Load language files bundled with the current schema
lia.lang.loadFromDir(SCHEMA.folder .. "/languages")
```

---

### lia.lang.AddTable

**Purpose**

Adds or merges language key-value pairs into the stored table.

**Parameters**

* `name` (*string*): Language identifier to update.
* `tbl` (*table*): Key-value pairs to insert or merge.

**Realm**

`Shared`

**Returns**

* `nil`: Nothing.

**Example**

```lua
-- Add or override phrases for English
lia.lang.AddTable("english", {
    greeting = "Hello",
    farewell = "Goodbye"
})
```

---

### L

**Purpose**

Retrieves the translated text for the given key in the active language.

**Parameters**

* `key` (*string*): Localization key.
* ...: Additional values inserted with `string.format`.

**Realm**

`Shared`

**Returns**

* `string`: The translated phrase or the key if missing.

**Example**

```lua
print(L("Show All"))
```

