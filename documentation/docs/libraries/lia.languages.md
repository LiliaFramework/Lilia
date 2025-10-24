# Languages Library

Internationalization (i18n) and localization system for the Lilia framework.

---

## Overview

The languages library provides comprehensive internationalization (i18n) functionality for the Lilia framework.

It handles loading, storing, and retrieving localized strings from language files, supporting multiple languages

with fallback mechanisms. The library automatically loads language files from directories, processes them into

a unified storage system, and provides string formatting with parameter substitution. It includes functions

for adding custom language tables, retrieving available languages, and getting localized strings with proper

error handling. The library operates on both server and client sides, ensuring consistent localization across

the entire gamemode. It supports dynamic language switching and provides the global L() function for easy

access to localized strings throughout the codebase.

---

### loadFromDir

**Purpose**

Loads language files from a specified directory and processes them into the language storage system

**When Called**

During gamemode initialization or when manually loading language files

---

### addTable

**Purpose**

Adds a custom language table to the language storage system

**When Called**

When manually adding language strings or when modules need to register their own translations

---

### getLanguages

**Purpose**

Retrieves a sorted list of all available language names

**When Called**

When building language selection menus or when checking available languages

---

### getLocalizedString

**Purpose**

Retrieves a localized string with parameter substitution and formatting

**When Called**

When displaying text to users or when any localized string is needed

**Parameters**

* `print(message)` (*- Outputs*): "Hello" (in current language)
* `print(welcomeMsg)` (*- Outputs*): "Welcome, John!" (if template is "Welcome, %s!")

---

