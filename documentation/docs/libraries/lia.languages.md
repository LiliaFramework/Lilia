# Languages Library

Internationalization (i18n) and localization system for the Lilia framework.

---

## Overview

The languages library provides comprehensive internationalization (i18n) functionality for the Lilia framework. It handles loading, storing, and retrieving localized strings from language files, supporting multiple languages with fallback mechanisms. The library automatically loads language files from directories, processes them into a unified storage system, and provides string formatting with parameter substitution. It includes functions for adding custom language tables, retrieving available languages, and getting localized strings with proper error handling. The library operates on both server and client sides, ensuring consistent localization across the entire gamemode. It supports dynamic language switching and provides the global L() function for easy access to localized strings throughout the codebase.

---

### loadFromDir

**Purpose**

Loads language files from a specified directory and processes them into the language storage system

**When Called**

During gamemode initialization or when manually loading language files

**Returns**

* None

**Realm**

Server/Client

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Load languages from default directory
lia.lang.loadFromDir("lilia/gamemode/languages")

```

**Medium Complexity:**
```lua
-- Medium: Load languages from custom module directory
local moduleDir = "lilia/gamemode/modules/mymodule/languages"
if file.Exists(moduleDir, "LUA") then
    lia.lang.loadFromDir(moduleDir)
end

```

**High Complexity:**
```lua
-- High: Load languages from multiple directories with validation
local languageDirs = {
    "lilia/gamemode/languages",
    "lilia/gamemode/modules/custom/languages",
    "addons/mycustomaddon/languages"
}
for _, dir in ipairs(languageDirs) do
    if file.Exists(dir, "LUA") then
        lia.lang.loadFromDir(dir)
    end
end

```

---

### addTable

**Purpose**

Adds a custom language table to the language storage system

**When Called**

When manually adding language strings or when modules need to register their own translations

**Returns**

* None

**Realm**

Server/Client

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Add basic language strings
lia.lang.addTable("english", {
    hello = "Hello",
    goodbye = "Goodbye"
})

```

**Medium Complexity:**
```lua
-- Medium: Add module-specific language strings
local moduleLang = {
    moduleTitle = "My Module",
    moduleDescription = "This is a custom module",
    moduleError = "An error occurred: %s"
}
lia.lang.addTable("english", moduleLang)

```

**High Complexity:**
```lua
-- High: Add multiple language tables with validation
local languages = {
    english = { title = "Title", desc = "Description" },
    spanish = { title = "Título", desc = "Descripción" },
    french = { title = "Titre", desc = "Description" }
}
for lang, strings in pairs(languages) do
    if type(strings) == "table" then
        lia.lang.addTable(lang, strings)
    end
end

```

---

### getLanguages

**Purpose**

Retrieves a sorted list of all available language names

**When Called**

When building language selection menus or when checking available languages

**Returns**

* table - Sorted array of language names with proper capitalization

**Realm**

Server/Client

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Get list of available languages
local languages = lia.lang.getLanguages()
print("Available languages:", table.concat(languages, ", "))

```

**Medium Complexity:**
```lua
-- Medium: Create language selection menu
local languages = lia.lang.getLanguages()
local menu = vgui.Create("DFrame")
local combo = vgui.Create("DComboBox", menu)
for _, lang in ipairs(languages) do
    combo:AddChoice(lang)
end

```

**High Complexity:**
```lua
-- High: Validate language selection with fallback
local function setLanguage(langName)
    local languages = lia.lang.getLanguages()
    local found = false
    for _, lang in ipairs(languages) do
        if lang:lower() == langName:lower() then
            found = true
            break
        end
    end
    if found then
        lia.config.set("Language", langName:lower())
    else
        lia.notice.add("Invalid language selected, using English", NOTIFY_ERROR)
        lia.config.set("Language", "english")
    end
end

```

---

### getLocalizedString

**Purpose**

Retrieves a localized string with parameter substitution and formatting

**When Called**

When displaying text to users or when any localized string is needed

**Returns**

* string - The localized and formatted string, or the key if not found

**Realm**

Server/Client

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Get basic localized string
local message = lia.lang.getLocalizedString("hello")
print(message) -- Outputs: "Hello" (in current language)

```

**Medium Complexity:**
```lua
-- Medium: Get localized string with parameters
local playerName = "John"
local welcomeMsg = lia.lang.getLocalizedString("welcomePlayer", playerName)
print(welcomeMsg) -- Outputs: "Welcome, John!" (if template is "Welcome, %s!")

```

**High Complexity:**
```lua
-- High: Complex localized string with multiple parameters and error handling
local function displayItemInfo(itemName, quantity, price)
    local lang = lia.config and lia.config.get("Language", "english") or "english"
    local langTable = lia.lang.stored and lia.lang.stored[lang:lower()]
    local template = langTable and langTable["itemInfo"] or "itemInfo"
    if template then
        local message = lia.lang.getLocalizedString("itemInfo", itemName, "No description available")
        lia.notice.add(message, NOTIFY_GENERIC)
    else
        lia.notice.add("Item: " .. itemName .. " x" .. quantity .. " - $" .. price, NOTIFY_GENERIC)
    end
end

```

---

