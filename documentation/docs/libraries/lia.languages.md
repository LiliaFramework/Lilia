# Languages Library

This page documents the functions for working with localization and language management.

---

## Overview

The languages library (`lia.lang`) provides a comprehensive system for managing multiple languages, localization, and text translation in the Lilia framework, enabling global accessibility and multilingual support for diverse player communities. This library handles sophisticated language management with support for dynamic language switching, context-aware translations, and automatic language detection based on player preferences or system settings. The system features advanced text translation capabilities with support for pluralization rules, gender-specific translations, and cultural localization that goes beyond simple text replacement to provide culturally appropriate content. It includes comprehensive language loading with support for multiple translation file formats, automatic updates, and fallback systems to ensure consistent user experience even with incomplete translations. The library provides robust localization functionality with support for right-to-left languages, different character encodings, and region-specific formatting for dates, numbers, and currency. Additional features include translation management tools for content creators, crowd-sourcing integration for community translations, and performance optimization for large translation databases, making it essential for creating inclusive and accessible roleplay experiences that welcome players from diverse linguistic backgrounds.

---

### loadFromDir

**Purpose**

Loads language files from a directory.

**Parameters**

* `directory` (*string*): The directory path to load from.

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Load languages from directory
local function loadLanguages(directory)
    lia.lang.loadFromDir(directory)
end

-- Use in a function
local function loadAllLanguages()
    lia.lang.loadFromDir("gamemode/languages/")
    print("All languages loaded from directory")
end

-- Use in a function
local function reloadLanguages()
    lia.lang.loadFromDir("gamemode/languages/")
    print("Languages reloaded")
end

-- Use in a hook
hook.Add("Initialize", "LoadLanguages", function()
    lia.lang.loadFromDir("gamemode/languages/")
end)
```

---

### AddTable

**Purpose**

Adds a language table to the language system.

**Parameters**

* `language` (*string*): The language code.
* `table*): The language table.

**Returns**

*None*

**Realm**

Shared.

**Example Usage**

```lua
-- Add language table
local function addLanguageTable(language, table)
    lia.lang.AddTable(language, table)
end

-- Use in a function
local function addEnglishTable()
    local englishTable = {
        ["welcome"] = "Welcome to the server!",
        ["goodbye"] = "Goodbye!",
        ["error"] = "An error occurred"
    }
    lia.lang.AddTable("en", englishTable)
    print("English language table added")
end

-- Use in a function
local function addSpanishTable()
    local spanishTable = {
        ["welcome"] = "¡Bienvenido al servidor!",
        ["goodbye"] = "¡Adiós!",
        ["error"] = "Ocurrió un error"
    }
    lia.lang.AddTable("es", spanishTable)
    print("Spanish language table added")
end

-- Use in a function
local function addFrenchTable()
    local frenchTable = {
        ["welcome"] = "Bienvenue sur le serveur!",
        ["goodbye"] = "Au revoir!",
        ["error"] = "Une erreur s'est produite"
    }
    lia.lang.AddTable("fr", frenchTable)
    print("French language table added")
end
```

---

### getLanguages

**Purpose**

Gets all available languages.

**Parameters**

*None*

**Returns**

* `languages` (*table*): Table of all available languages.

**Realm**

Shared.

**Example Usage**

```lua
-- Get all languages
local function getAllLanguages()
    return lia.lang.getLanguages()
end

-- Use in a function
local function showAllLanguages()
    local languages = lia.lang.getLanguages()
    print("Available languages:")
    for _, language in ipairs(languages) do
        print("- " .. language)
    end
end

-- Use in a function
local function getLanguageCount()
    local languages = lia.lang.getLanguages()
    return #languages
end

-- Use in a function
local function checkLanguageExists(languageCode)
    local languages = lia.lang.getLanguages()
    for _, lang in ipairs(languages) do
        if lang == languageCode then
            return true
        end
    end
    return false
end
```

---

### L

**Purpose**

Translates text using the current language.

**Parameters**

* `key` (*string*): The translation key.
* `...` (*any*): Optional parameters for string formatting.

**Returns**

* `translatedText` (*string*): The translated text.

**Realm**

Shared.

**Example Usage**

```lua
-- Translate text
local function translate(key, ...)
    return L(key, ...)
end

-- Use in a function
local function showWelcomeMessage(client)
    local message = L("welcome")
    client:notify(message)
end

-- Use in a function
local function showErrorMessage(client, errorCode)
    local message = L("error_" .. errorCode)
    client:notify(message)
end

-- Use in a function
local function showFormattedMessage(client, key, ...)
    local message = L(key, ...)
    client:notify(message)
end

-- Use in a function
local function showPlayerCount()
    local count = #player.GetAll()
    local message = L("player_count", count)
    print(message)
end

-- Use in a function
local function showTimeMessage()
    local time = os.time()
    local message = L("current_time", os.date("%H:%M:%S", time))
    print(message)
end
```









