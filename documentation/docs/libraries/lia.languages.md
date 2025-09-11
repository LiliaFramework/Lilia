# Languages Library

This page documents the functions for working with localization and language management.

---

## Overview

The languages library (`lia.lang`) provides a comprehensive system for managing multiple languages, localization, and text translation in the Lilia framework, enabling global accessibility and multilingual support for diverse player communities. This library handles sophisticated language management with support for dynamic language switching, context-aware translations, and automatic language detection based on player preferences or system settings. The system features advanced text translation capabilities with support for pluralization rules, gender-specific translations, and cultural localization that goes beyond simple text replacement to provide culturally appropriate content. It includes comprehensive language loading with support for multiple translation file formats, automatic updates, and fallback systems to ensure consistent user experience even with incomplete translations. The library provides robust localization functionality with support for right-to-left languages, different character encodings, and region-specific formatting for dates, numbers, and currency. Additional features include translation management tools for content creators, crowd-sourcing integration for community translations, and performance optimization for large translation databases, making it essential for creating inclusive and accessible roleplay experiences that welcome players from diverse linguistic backgrounds.

---

### lia.lang.loadFromDir

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

### lia.lang.AddTable

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

### lia.lang.getLanguages

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

---

### lia.lang.setLanguage

**Purpose**

Sets the current language.

**Parameters**

* `language` (*string*): The language code to set.

**Returns**

*None*

**Realm**

Shared.

**Example Usage**

```lua
-- Set current language
local function setLanguage(language)
    lia.lang.setLanguage(language)
end

-- Use in a function
local function setEnglish()
    lia.lang.setLanguage("en")
    print("Language set to English")
end

-- Use in a function
local function setSpanish()
    lia.lang.setLanguage("es")
    print("Language set to Spanish")
end

-- Use in a function
local function setFrench()
    lia.lang.setLanguage("fr")
    print("Language set to French")
end

-- Use in a function
local function setLanguageFromConfig()
    local language = lia.config.get("Language") or "en"
    lia.lang.setLanguage(language)
    print("Language set from config: " .. language)
end
```

---

### lia.lang.getLanguage

**Purpose**

Gets the current language.

**Parameters**

*None*

**Returns**

* `language` (*string*): The current language code.

**Realm**

Shared.

**Example Usage**

```lua
-- Get current language
local function getCurrentLanguage()
    return lia.lang.getLanguage()
end

-- Use in a function
local function showCurrentLanguage()
    local language = lia.lang.getLanguage()
    print("Current language: " .. language)
end

-- Use in a function
local function checkLanguageSupport()
    local language = lia.lang.getLanguage()
    local supported = lia.lang.getLanguages()
    for _, lang in ipairs(supported) do
        if lang == language then
            print("Current language is supported")
            return true
        end
    end
    print("Current language is not supported")
    return false
end

-- Use in a function
local function getLanguageDisplayName()
    local language = lia.lang.getLanguage()
    local displayNames = {
        ["en"] = "English",
        ["es"] = "Spanish",
        ["fr"] = "French"
    }
    return displayNames[language] or language
end
```

---

### lia.lang.get

**Purpose**

Gets a translation for a specific language.

**Parameters**

* `language` (*string*): The language code.
* `key` (*string*): The translation key.

**Returns**

* `translatedText` (*string*): The translated text.

**Realm**

Shared.

**Example Usage**

```lua
-- Get translation for specific language
local function getTranslation(language, key)
    return lia.lang.get(language, key)
end

-- Use in a function
local function showTranslationInLanguage(language, key)
    local translation = lia.lang.get(language, key)
    if translation then
        print("Translation in " .. language .. ": " .. translation)
        return translation
    else
        print("Translation not found for " .. language .. ": " .. key)
        return nil
    end
end

-- Use in a function
local function compareTranslations(key)
    local languages = lia.lang.getLanguages()
    print("Translations for " .. key .. ":")
    for _, language in ipairs(languages) do
        local translation = lia.lang.get(language, key)
        if translation then
            print("- " .. language .. ": " .. translation)
        end
    end
end

-- Use in a function
local function getTranslationIfExists(language, key)
    local translation = lia.lang.get(language, key)
    if translation then
        return translation
    else
        -- Fallback to English
        return lia.lang.get("en", key) or key
    end
end
```

---

### lia.lang.exists

**Purpose**

Checks if a translation key exists.

**Parameters**

* `key` (*string*): The translation key to check.

**Returns**

* `exists` (*boolean*): True if the key exists.

**Realm**

Shared.

**Example Usage**

```lua
-- Check if translation key exists
local function translationExists(key)
    return lia.lang.exists(key)
end

-- Use in a function
local function checkTranslationKey(key)
    if lia.lang.exists(key) then
        print("Translation key exists: " .. key)
        return true
    else
        print("Translation key not found: " .. key)
        return false
    end
end

-- Use in a function
local function validateTranslationKeys(keys)
    local missing = {}
    for _, key in ipairs(keys) do
        if not lia.lang.exists(key) then
            table.insert(missing, key)
        end
    end
    if #missing > 0 then
        print("Missing translation keys: " .. table.concat(missing, ", "))
        return false
    else
        print("All translation keys exist")
        return true
    end
end

-- Use in a function
local function checkLanguageCompleteness(language)
    local keys = {"welcome", "goodbye", "error", "success"}
    local missing = {}
    for _, key in ipairs(keys) do
        if not lia.lang.get(language, key) then
            table.insert(missing, key)
        end
    end
    if #missing > 0 then
        print("Missing translations in " .. language .. ": " .. table.concat(missing, ", "))
        return false
    else
        print("Language " .. language .. " is complete")
        return true
    end
end
```

---

### lia.lang.add

**Purpose**

Adds a translation to the current language.

**Parameters**

* `key` (*string*): The translation key.
* `value` (*string*): The translation value.

**Returns**

*None*

**Realm**

Shared.

**Example Usage**

```lua
-- Add translation to current language
local function addTranslation(key, value)
    lia.lang.add(key, value)
end

-- Use in a function
local function addCustomTranslation(key, value)
    lia.lang.add(key, value)
    print("Translation added: " .. key .. " = " .. value)
end

-- Use in a function
local function addMultipleTranslations(translations)
    for key, value in pairs(translations) do
        lia.lang.add(key, value)
    end
    print("Multiple translations added")
end

-- Use in a function
local function addDynamicTranslation(key, value)
    lia.lang.add(key, value)
    print("Dynamic translation added: " .. key)
end
```

---

### lia.lang.remove

**Purpose**

Removes a translation from the current language.

**Parameters**

* `key` (*string*): The translation key to remove.

**Returns**

*None*

**Realm**

Shared.

**Example Usage**

```lua
-- Remove translation from current language
local function removeTranslation(key)
    lia.lang.remove(key)
end

-- Use in a function
local function removeCustomTranslation(key)
    lia.lang.remove(key)
    print("Translation removed: " .. key)
end

-- Use in a function
local function removeMultipleTranslations(keys)
    for _, key in ipairs(keys) do
        lia.lang.remove(key)
    end
    print("Multiple translations removed")
end

-- Use in a function
local function cleanupOldTranslations()
    local oldKeys = {"old_key1", "old_key2", "old_key3"}
    for _, key in ipairs(oldKeys) do
        lia.lang.remove(key)
    end
    print("Old translations cleaned up")
end
```

---

### lia.lang.clear

**Purpose**

Clears all translations from the current language.

**Parameters**

*None*

**Returns**

*None*

**Realm**

Shared.

**Example Usage**

```lua
-- Clear all translations
local function clearAllTranslations()
    lia.lang.clear()
end

-- Use in a function
local function resetLanguage()
    lia.lang.clear()
    print("Language reset")
end

-- Use in a function
local function reloadLanguage()
    lia.lang.clear()
    lia.lang.loadFromDir("gamemode/languages/")
    print("Language reloaded")
end

-- Use in a command
lia.command.add("resetlanguage", {
    privilege = "Admin Access",
    onRun = function(client, arguments)
        lia.lang.clear()
        client:notify("Language reset")
    end
})
```

---

### lia.lang.getTable

**Purpose**

Gets the translation table for a language.

**Parameters**

* `language` (*string*): The language code.

**Returns**

* `table*): The translation table.

**Realm**

Shared.

**Example Usage**

```lua
-- Get translation table for language
local function getTranslationTable(language)
    return lia.lang.getTable(language)
end

-- Use in a function
local function showLanguageTable(language)
    local table = lia.lang.getTable(language)
    if table then
        print("Translations for " .. language .. ":")
        for key, value in pairs(table) do
            print("- " .. key .. ": " .. value)
        end
        return table
    else
        print("Language table not found: " .. language)
        return nil
    end
end

-- Use in a function
local function getLanguageTableSize(language)
    local table = lia.lang.getTable(language)
    if table then
        local count = 0
        for _ in pairs(table) do
            count = count + 1
        end
        print("Language " .. language .. " has " .. count .. " translations")
        return count
    else
        print("Language table not found")
        return 0
    end
end

-- Use in a function
local function compareLanguageTables(language1, language2)
    local table1 = lia.lang.getTable(language1)
    local table2 = lia.lang.getTable(language2)
    if table1 and table2 then
        local count1 = 0
        local count2 = 0
        for _ in pairs(table1) do count1 = count1 + 1 end
        for _ in pairs(table2) do count2 = count2 + 1 end
        print("Language " .. language1 .. " has " .. count1 .. " translations")
        print("Language " .. language2 .. " has " .. count2 .. " translations")
        return count1, count2
    else
        print("One or both language tables not found")
        return 0, 0
    end
end
```

---

### lia.lang.setTable

**Purpose**

Sets the translation table for a language.

**Parameters**

* `language` (*string*): The language code.
* `table*): The translation table.

**Returns**

*None*

**Realm**

Shared.

**Example Usage**

```lua
-- Set translation table for language
local function setTranslationTable(language, table)
    lia.lang.setTable(language, table)
end

-- Use in a function
local function createCustomLanguage(language, translations)
    lia.lang.setTable(language, translations)
    print("Custom language created: " .. language)
end

-- Use in a function
local function updateLanguageTable(language, newTranslations)
    local currentTable = lia.lang.getTable(language) or {}
    for key, value in pairs(newTranslations) do
        currentTable[key] = value
    end
    lia.lang.setTable(language, currentTable)
    print("Language table updated: " .. language)
end

-- Use in a function
local function mergeLanguageTables(language, additionalTranslations)
    local currentTable = lia.lang.getTable(language) or {}
    for key, value in pairs(additionalTranslations) do
        currentTable[key] = value
    end
    lia.lang.setTable(language, currentTable)
    print("Language tables merged: " .. language)
end
```

---

### lia.lang.format

**Purpose**

Formats a translation with parameters.

**Parameters**

* `key` (*string*): The translation key.
* `...` (*any*): Parameters for formatting.

**Returns**

* `formattedText` (*string*): The formatted translation.

**Realm**

Shared.

**Example Usage**

```lua
-- Format translation with parameters
local function formatTranslation(key, ...)
    return lia.lang.format(key, ...)
end

-- Use in a function
local function showFormattedMessage(client, key, ...)
    local message = lia.lang.format(key, ...)
    client:notify(message)
end

-- Use in a function
local function showPlayerCountMessage()
    local count = #player.GetAll()
    local message = lia.lang.format("player_count", count)
    print(message)
end

-- Use in a function
local function showTimeMessage()
    local time = os.time()
    local message = lia.lang.format("current_time", os.date("%H:%M:%S", time))
    print(message)
end

-- Use in a function
local function showComplexMessage(client, key, ...)
    local message = lia.lang.format(key, ...)
    client:notify(message)
end
```