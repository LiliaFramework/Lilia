# lia.attribs
---

The lia.attribs library is used for managing attributes in the Lilia framework. Attributes represent roleplay-improving traits that can be dynamically loaded and customized through Lua files.

---

### **lia.attribs.loadFromDir**

**Description:**  
Loads attribute data from Lua files located in the specified directory.

**Realm:**  
` Shared`

**Parameters:**  

- `directory` (`String`): The directory path from which to load attribute files.

**Example Usage:**
```lua
lia.attribs.loadFromDir("schema/attributes")
```

---

### **lia.attribs.setup**

**Description:**  
Sets up attributes for a given character. Attributes can define custom behavior using the `OnSetup` function in their respective definitions.

**Realm:**  
`Server`

**Parameters:**  

- `client` (`Player`): The player for whom attributes are being set up.

**Example Usage:**
```lua
ATTRIBUTE.name = "Strength"
ATTRIBUTE.desc = "Strength Skill."

function ATTRIBUTE:OnSetup(client, value)
    if value > 5 then client:ChatPrint("You are very Strong!") end
end
```

---