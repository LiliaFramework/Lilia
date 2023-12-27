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

### Example Language Files

Here are the default language localization files of Lilia:
#### English Language File
- Language ID: `"english"`
- File: [English Language File](https://github.com/Lilia-Framework/Lilia/tree/2.0/lilia/modules/core/languages/sh_english.lua)

#### Portuguese Language File
- Language ID: `"portuguese"`
- File: [Portuguese Language File](https://github.com/Lilia-Framework/Lilia/tree/2.0/lilia/modules/core/languages/sh_portuguese.lua)

#### French Language File
- Language ID: `"french"`
- File: [French Language File](https://github.com/Lilia-Framework/Lilia/tree/2.0/lilia/modules/core/languages/sh_french.lua)

#### Polish Language File
- Language ID: `"polish"`
- File: [Polish Language File](https://github.com/Lilia-Framework/Lilia/tree/2.0/lilia/modules/core/languages/sh_polish.lua)

#### Russian Language File
- Language ID: `"russian"`
- File: [Russian Language File](https://github.com/Lilia-Framework/Lilia/tree/2.0/lilia/modules/core/languages/sh_russian.lua)

#### Dutch Language File
- Language ID: `"dutch"`
- File: [Dutch Language File](https://github.com/Lilia-Framework/Lilia/tree/2.0/lilia/modules/core/languages/sh_dutch.lua)

#### Spanish Language File
- Language ID: `"spanish"`
- File: [Spanish Language File](https://github.com/Lilia-Framework/Lilia/tree/2.0/lilia/modules/core/languages/sh_spanish.lua)

These language files provide translations for the variables used in the Lua script, allowing the application or game to support multiple languages.
