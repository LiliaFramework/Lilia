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

### Example Languages

Here are the default language localization files of Lilia:

#### English

- **ID**: ``"english```
- [File Location](https://github.com/Lilia-Framework/Lilia/tree/main/lilia/libraries/languages/config/languages/english.lua)

#### Portuguese

- **ID**: ``"portuguese```
- [File Location](https://github.com/Lilia-Framework/Lilia/tree/main/lilia/libraries/languages/config/languages/portuguese.lua)

#### French

- **ID**: ``"french```
- [File Location](https://github.com/Lilia-Framework/Lilia/tree/main/lilia/libraries/languages/config/languages/french.lua)

#### Polish

- **ID**: ``"polish```
- [File Location](https://github.com/Lilia-Framework/Lilia/tree/main/lilia/libraries/languages/config/languages/polish.lua)

#### Russian

- **ID**: ```"russian````
- [File Location](https://github.com/Lilia-Framework/Lilia/tree/main/lilia/libraries/languages/config/languages/russian.lua)

#### Dutch

- **ID**: ``"dutch```
- [File Location](https://github.com/Lilia-Framework/Lilia/tree/main/lilia/libraries/languages/config/languages/dutch.lua)

#### Spanish

- **ID**: ``"spanish```
- [File Location](https://github.com/Lilia-Framework/Lilia/tree/main/lilia/libraries/languages/config/languages/spanish.lua)

These Language Locations provide translations for the variables used in the Lua script, allowing the application or game to support multiple languages
