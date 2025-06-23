# lia.lang

---

Multi-language phrase support.

The `lia.lang` library provides robust support for multiple languages within the Lilia Framework. It allows developers to load, manage, and retrieve localized phrases, enabling seamless integration of multi-language features in schemas, plugins, and other components. By leveraging this system, developers can ensure that their applications cater to a diverse audience, enhancing user experience through dynamic language support.

---
## Functions

### **lia.lang.loadFromDir**

**Description:**  
Loads language files from a specified directory. It processes each Lua file within the directory, extracting language names and their corresponding phrases. The function ensures that all phrases are correctly stored and accessible for localization purposes.

**Realm:**  
`Shared`

**Parameters:**  

- `directory` (`string`):  
  The directory path from which to load language files.

**Example Usage:**
```lua
-- Load all language files from the specified directory
lia.lang.loadFromDir("lilia/gamemode/languages")
```

---
### **lia.lang.AddTable**

**Description:**  
Adds a table of phrases to a specified language. This function merges the provided phrases into the existing language table, allowing for dynamic updates and additions to language support.

**Realm:**  
`Shared`

**Parameters:**  

- `name` (`string`):  
  The name of the language to add the phrases to.

- `tbl` (`table`):  
  A table containing key-value pairs where the key is the phrase ID and the value is the translated string.

**Example Usage:**
```lua
-- Add new phrases to the French language
lia.lang.AddTable("french", {
    welcomeMessage = "Bienvenue dans le jeu!",
    gameOver = "Fin du jeu! Vous avez gagné!",
    victory = "%s a remporté la victoire!",
})
```