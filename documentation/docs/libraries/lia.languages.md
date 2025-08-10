# Languages Library

This page documents translation loading and retrieval.

---

## Overview

The languages library loads localisation files from directories, resolves phrase keys to translated text, and supports runtime language switching. Language files live in `languages/<identifier>.lua` inside schemas or modules; each file defines a global `LANGUAGE` table of phrases and may define a global `NAME` for display. Loaded phrases are cached in `lia.lang.stored`, while display names are kept in `lia.lang.names`. During start-up the framework automatically loads its bundled translations from `lilia/gamemode/languages` and then fires the `OnLocalizationLoaded` hook.

---

### lia.lang.loadFromDir

**Purpose**

Loads every `.lua` language file in a directory and merges its `LANGUAGE` table into the cache. File names prefixed with `sh_` have the prefix removed and the remainder lowercased to form the language identifier. Keys and values from `LANGUAGE` are coerced to strings before merging, existing phrases are overwritten, and an optional global `NAME` is stored in `lia.lang.names`. Files that do not define `LANGUAGE` are ignored. After processing each file the globals `LANGUAGE` and `NAME` are cleared.

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

Adds or merges key–value pairs into a language table. The language name is lowercased and a new table is created if it does not already exist. Keys and values are converted to strings and existing entries are overwritten.

**Parameters**

* `name` (*string*): Language identifier to update.
* `tbl` (*table*): Key–value pairs to insert or override.

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

### lia.lang.getLanguages

**Purpose**

Returns an alphabetically sorted list of the identifiers for all loaded languages with their first letter capitalised. Display names stored in `lia.lang.names` are not used.

**Parameters**

*None*

**Realm**

`Shared`

**Returns**

* `table`: Alphabetically sorted language names.

**Example Usage**

```lua
for _, lang in ipairs(lia.lang.getLanguages()) do
    print(lang)
end
```

---

### L

**Purpose**

Returns the translated phrase for a key in the active language, formatting it with `string.format`. The active language is read from `lia.config.get("Language", "english")` if available; otherwise it defaults to `"english"`. Translations are looked up in `lia.lang.stored` using a lowercase language identifier and the key as provided. If no translation exists the key itself is returned. All additional arguments are converted to strings. The function counts the number of `%s` placeholders in the translation: missing arguments are replaced with empty strings, while extra arguments are ignored by `string.format`.

**Parameters**

* `key` (*string*): Localisation key.
* `...` (*string*): Values interpolated via `string.format`.

**Realm**

`Shared`

**Returns**

* `string`: Translated phrase, or the key itself if no translation exists.

**Example Usage**

```lua
print(L("vendorShowAll"))
print(L("unknownKey")) -- missing translation returns "unknownKey"

-- assuming LANGUAGE.greeting = "Hello %s %s"
print(L("greeting", "John")) -- outputs "Hello John "
```

---
