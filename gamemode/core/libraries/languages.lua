--[[
    Languages Library

    Internationalization (i18n) and localization system for the Lilia framework.
]]
--[[
    Overview:
    The languages library provides comprehensive internationalization (i18n) functionality for the Lilia framework.
    It handles loading, storing, and retrieving localized strings from language files, supporting multiple languages
    with fallback mechanisms. The library automatically loads language files from directories, processes them into
    a unified storage system, and provides string formatting with parameter substitution. It includes functions
    for adding custom language tables, retrieving available languages, and getting localized strings with proper
    error handling. The library operates on both server and client sides, ensuring consistent localization across
    the entire gamemode. It supports dynamic language switching and provides the global L() function for easy
    access to localized strings throughout the codebase.
]]
lia.lang = lia.lang or {}
lia.lang.names = lia.lang.names or {}
lia.lang.stored = lia.lang.stored or {}
--[[
    Purpose: Loads language files from a specified directory and processes them into the language storage system
    When Called: During gamemode initialization or when manually loading language files
    Parameters: directory (string) - The directory path containing language files
    Returns: None
    Realm: Server/Client
    Example Usage:

    Low Complexity:
    ```lua
    -- Simple: Load languages from default directory
    lia.lang.loadFromDir("lilia/gamemode/languages")
    ```

    Medium Complexity:
    ```lua
    -- Medium: Load languages from custom module directory
    local moduleDir = "lilia/gamemode/modules/mymodule/languages"
    if file.Exists(moduleDir, "LUA") then
        lia.lang.loadFromDir(moduleDir)
    end
    ```

    High Complexity:
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
]]
function lia.lang.loadFromDir(directory)
    for _, v in ipairs(file.Find(directory .. "/*.lua", "LUA")) do
        local niceName
        if v:sub(1, 3) == "sh_" then
            niceName = v:sub(4, -5):lower()
        else
            niceName = v:sub(1, -5):lower()
        end

        lia.loader.include(directory .. "/" .. v, "shared")
        if LANGUAGE then
            if NAME then
                lia.lang.names[niceName] = NAME
                NAME = nil
            end

            local formatted = {}
            for k, val in pairs(LANGUAGE) do
                formatted[tostring(k)] = tostring(val)
            end

            lia.lang.stored[niceName] = table.Merge(lia.lang.stored[niceName] or {}, formatted)
            LANGUAGE = nil
        end
    end
end

--[[
    Purpose: Adds a custom language table to the language storage system
    When Called: When manually adding language strings or when modules need to register their own translations
    Parameters: name (string) - The language name/key, tbl (table) - Table containing key-value pairs of translations
    Returns: None
    Realm: Server/Client
    Example Usage:

    Low Complexity:
    ```lua
    -- Simple: Add basic language strings
    lia.lang.addTable("english", {
        hello = "Hello",
        goodbye = "Goodbye"
    })
    ```

    Medium Complexity:
    ```lua
    -- Medium: Add module-specific language strings
    local moduleLang = {
        moduleTitle = "My Module",
        moduleDescription = "This is a custom module",
        moduleError = "An error occurred: %s"
    }
    lia.lang.addTable("english", moduleLang)
    ```

    High Complexity:
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
]]
function lia.lang.addTable(name, tbl)
    local lowerName = tostring(name):lower()
    lia.lang.stored[lowerName] = lia.lang.stored[lowerName] or {}
    for k, v in pairs(tbl) do
        lia.lang.stored[lowerName][tostring(k)] = tostring(v)
    end
end

--[[
    Purpose: Retrieves a sorted list of all available language names
    When Called: When building language selection menus or when checking available languages
    Parameters: None
    Returns: table - Sorted array of language names with proper capitalization
    Realm: Server/Client
    Example Usage:

    Low Complexity:
    ```lua
    -- Simple: Get list of available languages
    local languages = lia.lang.getLanguages()
    print("Available languages:", table.concat(languages, ", "))
    ```

    Medium Complexity:
    ```lua
    -- Medium: Create language selection menu
    local languages = lia.lang.getLanguages()
    local menu = vgui.Create("DFrame")
    local combo = vgui.Create("DComboBox", menu)

    for _, lang in ipairs(languages) do
        combo:AddChoice(lang)
    end
    ```

    High Complexity:
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
]]
function lia.lang.getLanguages()
    local languages = {}
    for key, _ in pairs(lia.lang.stored) do
        local displayName = key:sub(1, 1):upper() .. key:sub(2)
        table.insert(languages, displayName)
    end

    table.sort(languages)
    return languages
end

--[[
    Purpose: Retrieves a localized string with parameter substitution and formatting
    When Called: When displaying text to users or when any localized string is needed
    Parameters: key (string) - The language key to look up, ... (variadic) - Parameters for string formatting
    Returns: string - The localized and formatted string, or the key if not found
    Realm: Server/Client
    Example Usage:

    Low Complexity:
    ```lua
    -- Simple: Get basic localized string
    local message = lia.lang.getLocalizedString("hello")
    print(message) -- Outputs: "Hello" (in current language)
    ```

    Medium Complexity:
    ```lua
    -- Medium: Get localized string with parameters
    local playerName = "John"
    local welcomeMsg = lia.lang.getLocalizedString("welcomePlayer", playerName)
    print(welcomeMsg) -- Outputs: "Welcome, John!" (if template is "Welcome, %s!")
    ```

    High Complexity:
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
]]
function lia.lang.getLocalizedString(key, ...)
    local lang = lia.config and lia.config.get("Language", "english") or "english"
    local langTable = lia.lang.stored and lia.lang.stored[lang:lower()]
    local template = langTable and langTable[key]
    if not template then return tostring(key) end
    local count = select("#", ...)
    local args = {}
    for i = 1, count do
        local arg = select(i, ...)
        if istable(arg) then
            args[i] = table.concat(arg, ", ")
        else
            args[i] = tostring(arg or "")
        end
    end

    local needed = select(2, template:gsub("%%[^%%]", ""))
    for i = count + 1, needed do
        args[i] = ""
    end

    local success, result = pcall(string.format, template, unpack(args))
    if not success then
        lia.error(L("formatErrorInLocalizationString") .. " '" .. tostring(key) .. "': " .. result)
        return tostring(key)
    end
    return result
end

--[[
    Purpose: Global alias for lia.lang.getLocalizedString for convenient access to localized strings
    When Called: Anywhere in the codebase when a localized string is needed
    Parameters: key (string) - The language key to look up, ... (variadic) - Parameters for string formatting
    Returns: string - The localized and formatted string, or the key if not found
    Realm: Server/Client
    Example Usage:

    Low Complexity:
    ```lua
    -- Simple: Use global L function for basic strings
    print(L("hello")) -- Outputs: "Hello" (in current language)
    ```

    Medium Complexity:
    ```lua
    -- Medium: Use L function with parameters in chat
    local function onPlayerChat(ply, text)
        local welcomeMsg = L("playerSays", ply:Name(), text)
        chat.AddText(Color(255, 255, 255), welcomeMsg)
    end
    ```

    High Complexity:
    ```lua
    -- High: Use L function in complex UI with multiple languages
    local function updateUI()
        local currentLang = lia.config.get("Language", "english")
        local title = L("menuTitle")
        local description = L("menuDescription")
        local buttonText = L("confirmButton")

        if IsValid(self.titleLabel) then
            self.titleLabel:SetText(title)
        end
        if IsValid(self.descLabel) then
            self.descLabel:SetText(description)
        end
        if IsValid(self.confirmBtn) then
            self.confirmBtn:SetText(buttonText)
        end
    end
    ```
]]
L = lia.lang.getLocalizedString
lia.lang.loadFromDir("lilia/gamemode/languages")
hook.Run("OnLocalizationLoaded")
