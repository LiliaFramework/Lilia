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

**Description:**

Loads all Lua language files (*.lua) from the specified directory,

includes them as shared files, and merges any defined LANGUAGE table

into the stored language data. If a language name (NAME) is provided in the file,

it is registered in lia.lang.names. Once all files have been processed, the `OnLocalizationLoaded` hook is triggered.

**Parameters:**

* `directory` (`string`) – The path to the directory containing language files.


**Realm:**

* Shared

**Returns:**

* None


**Example Usage:**

```lua
    -- Load language files bundled with the current schema
    lia.lang.loadFromDir(SCHEMA.folder .. "/languages")
```

---

### lia.lang.AddTable

**Description:**

Adds or merges a table of language key-value pairs into the stored language table

for a specified language. If the language already exists in the storage, the new values

will be merged with the existing ones.

**Parameters:**

* `name` (`string`) – The name of the language to update.


* `tbl` (`table`) – A table containing language key-value pairs to add.


**Realm:**

* Shared


**Returns:**

* None


**Example Usage:**

```lua
    -- Add or override phrases for English
lia.lang.AddTable("english", {
        greeting = "Hello",
        farewell = "Goodbye"
    })
```

---

### L

**Description:**

Looks up the phrase associated with `key` in the language selected by the `Language`
configuration option. Additional arguments are inserted using `string.format`.
If the key has no translation, the key itself is returned.

**Parameters:**

* `key` (`string`) – Localization key.

* ... (vararg) – Values to format into the phrase.

**Realm:**

* Shared

**Returns:**

* string – The translated phrase or the key when missing.

**Example Usage:**

```lua
    print(L("vendorShowAll")) -- prints "Show All" in the active language
```
