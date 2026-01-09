# Languages Library

Internationalization (i18n) and localization system for the Lilia framework.

---

Overview

The languages library provides comprehensive internationalization (i18n) functionality for the Lilia framework. It handles loading, storing, and retrieving localized strings from language files, supporting multiple languages with fallback mechanisms. The library automatically loads language files from directories, processes them into a unified storage system, and provides string formatting with parameter substitution. It includes functions for adding custom language tables, retrieving available languages, and getting localized strings with proper error handling. The library operates on both server and client sides, ensuring consistent localization across the entire gamemode. It supports dynamic language switching and provides the global L() function for easy access to localized strings throughout the codebase.

---

### lia.lang.loadFromDir

#### 📋 Purpose
Load language files from a directory and merge them into storage.

#### ⏰ When Called
During startup to load built-in and schema-specific localization.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `directory` | **string** | Path containing language Lua files. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    -- Load base languages and a custom pack.
    lia.lang.loadFromDir("lilia/gamemode/languages")
    lia.lang.loadFromDir("schema/languages")

```

---

### lia.lang.addTable

#### 📋 Purpose
Merge a table of localized strings into a named language.

#### ⏰ When Called
When adding runtime localization or extending a language.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | **string** | Language id (e.g., "english"). |
| `tbl` | **table** | Key/value pairs to merge. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    lia.lang.addTable("english", {
        customGreeting = "Hello, %s!",
        adminOnly = "You must be an admin."
    })

```

---

### lia.lang.getLanguages

#### 📋 Purpose
List available languages by display name.

#### ⏰ When Called
When populating language selection menus or config options.

#### ↩️ Returns
* table
Sorted array of language display names.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    for _, langName in ipairs(lia.lang.getLanguages()) do
        print("Language option:", langName)
    end

```

---

### lia.lang.generateCacheKey

#### 📋 Purpose
Build a cache key for a localized string with parameters.

#### ⏰ When Called
Before caching formatted localization results.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `lang` | **string** |  |
| `key` | **string** | ... (vararg) |

#### ↩️ Returns
* string

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local cacheKey = lia.lang.generateCacheKey("english", "hello", "John")

```

---

### lia.lang.cleanupCache

#### 📋 Purpose
Evict half of the cached localization entries when over capacity.

#### ⏰ When Called
Automatically from getLocalizedString when cache exceeds maxSize.

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    if lia.lang.cache.currentSize > lia.lang.cache.maxSize then
        lia.lang.cleanupCache()
    end

```

---

### lia.lang.clearCache

#### 📋 Purpose
Reset the localization cache to its initial state.

#### ⏰ When Called
When changing languages or when flushing cached strings.

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    hook.Add("OnConfigUpdated", "ClearLangCache", function(key, old, new)
        if key == "Language" and old ~= new then
            lia.lang.clearCache()
        end
    end)

```

---

### lia.lang.getLocalizedString

#### 📋 Purpose
Resolve and format a localized string with caching and fallbacks.

#### ⏰ When Called
Every time L() is used to display text with parameters.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `key` | **string** | Localization key. |

#### ↩️ Returns
* string
Formatted localized string or key when missing.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local msg = lia.lang.getLocalizedString("welcomeUser", ply:Name(), os.date())
    chat.AddText(msg)

```

---

