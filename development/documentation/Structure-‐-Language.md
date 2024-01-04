# Language Localization in Lua Script

Language localization is a crucial aspect of lilia as that it allows content to be presented in different languages, if such is what you aim to have. Here's how it works:

## Defining the Language ID

The `NAME` variable is used to define the ID of the language being localized.

## Variable Translations

The `LANGUAGE` table is used to map variables to their translations. Each variable represents a piece of content that needs to be displayed in multiple languages, and its value is set to the translation in the desired language.

For example:

- `enchant_event` might be mapped to "Enchanter" in French while in English it is Enchant.
- `discover_event` might be mapped to "Découvrir" in French while in English it is Discover.
- ...

This allows for lilia to dynamically retrieve the correct translation based on the clientside language ID, ensuring that the framework displays content in the user's preferred language.

### Example Language Locations

Here are the default language localization files of Lilia:

#### English Language Location

- Language ID: `"english"`
- File: [English Language Location](https://github.com/Lilia-Framework/Lilia/tree/main/lilia/libraries/languages/config/languages/english.lua)

#### Portuguese Language Location

- Language ID: `"portuguese"`
- File: [Portuguese Language Location](https://github.com/Lilia-Framework/Lilia/tree/main/lilia/libraries/languages/config/languages/portuguese.lua)

#### French Language Location

- Language ID: `"french"`
- File: [French Language Location](https://github.com/Lilia-Framework/Lilia/tree/main/lilia/libraries/languages/config/languages/french.lua)

#### Polish Language Location

- Language ID: `"polish"`
- File: [Polish Language Location](https://github.com/Lilia-Framework/Lilia/tree/main/lilia/libraries/languages/config/languages/polish.lua)

#### Russian Language Location

- Language ID: `"russian"`
- File: [Russian Language Location](https://github.com/Lilia-Framework/Lilia/tree/main/lilia/libraries/languages/config/languages/russian.lua)

#### Dutch Language Location

- Language ID: `"dutch"`
- File: [Dutch Language Location](https://github.com/Lilia-Framework/Lilia/tree/main/lilia/libraries/languages/config/languages/dutch.lua)

#### Spanish Language Location

- Language ID: `"spanish"`
- File: [Spanish Language Location](https://github.com/Lilia-Framework/Lilia/tree/main/lilia/libraries/languages/config/languages/spanish.lua)

These Language Locations provide translations for the variables used in the Lua script, allowing the application or game to support multiple languages.
