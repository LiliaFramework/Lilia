# Languages Library

This page explains how translations and phrases are loaded.

---

## Overview

The languages library loads localisation files from directories, resolves phrase keys to translated text, and supports runtime language switching. Language files live in `languages/<langname>.lua` inside schemas or modules; each file defines a `LANGUAGE` table of phrases. Loaded phrases are cached in `lia.lang.stored`, while user-facing language names are kept in `lia.lang.names`.

Language files may also set a global `NAME` variable containing the display name for that language. When `lia.lang.loadFromDir` includes such a file, the name is inserted into `lia.lang.names` alongside the phrases. The framework automatically loads its bundled translations from `gamemode/languages` during initialisation.

---

### lia.lang.loadFromDir

**Purpose**

Loads every Lua language file in a directory and merges their `LANGUAGE` tables into the cache.

**Parameters**

* `directory` (*string*): Path to the folder containing language files.

**Realm**

`Shared`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
-- Load language files bundled with the current schema
lia.lang.loadFromDir(SCHEMA.folder .. "/languages")
```

---

### lia.lang.AddTable

**Purpose**

Adds or merges key-value pairs into an existing language table.

**Parameters**

* `name` (*string*): Language identifier to update.

* `tbl` (*table*): Key-value pairs to insert or override.

**Realm**

`Shared`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

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

Returns the translated phrase for a key in the active language, using `string.format` with any additional arguments.

**Parameters**

* `key` (*string*): Localisation key.

* …: Values interpolated via `string.format`.

**Realm**

`Shared`

**Returns**

* *string*: Translated phrase, or the key itself if no translation exists.

**Example Usage**

```lua
print(L("vendorShowAll"))
```

---
