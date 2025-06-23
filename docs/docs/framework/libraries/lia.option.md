# lia.option

---

The `lia.option` module manages user-specific options within your schema. It allows clients to define, retrieve, and persist various option settings tailored to individual players. Options can have different data types such as booleans, numbers, colors, and generic text fields. Additionally, options support callbacks for reacting to changes and can be categorized for better organization.

---

### **lia.option.add**

**Description:**  
Adds a new option to the system.

**Realm:**  
`Client`

**Parameters:**  

- `key` (`string`): The unique identifier for the option.
- `name` (`string`): The display name of the option.
- `desc` (`string`): A description of what the option does.
- `default` (`any`): The default value of the option.
- `callback` (`function`, optional): A function to call when the option value changes.
- `data` (`table`): A table containing additional data for the option.
  - `min` (`number`, optional): The minimum value for numerical options. Defaults to half of the default for `Int` and `Float` types.
  - `max` (`number`, optional): The maximum value for numerical options. Defaults to double the default for `Int` and `Float` types.

**Option Types:**

- `"Boolean"`: A true/false option.
- `"Int"`: An integer option.
- `"Float"`: A floating-point number option.
- `"Color"`: A color option with `r`, `g`, and `b` values.
- `"Generic"`: A text field.

**Example Usage:**
```lua
-- Adding a new option on the client side
lia.option.add("ShowHUD", "Show HUD", "Toggle the visibility of the HUD.", true, nil, {
})
```

---

### **lia.option.set**

**Description:**  
Sets the value of an existing option and handles callbacks and saving.

**Realm:**  
`Client`

**Parameters:**  

- `key` (`string`): The unique identifier of the option.
- `value` (`any`): The new value to set for the option.

**Example Usage:**
```lua
-- Setting an option value on the client side
lia.option.set("ShowHUD", false)
```

---

### **lia.option.get**

**Description:**  
Retrieves the current value of an option, falling back to the default if not set.

**Realm:**  
`Client`

**Parameters:**  

- `key` (`string`): The unique identifier of the option.
- `default` (`any`, optional): The default value to return if the option is not set.

**Returns:**  
`any`: The current value of the option or the default value.

**Example Usage:**
```lua
local showHUD = lia.option.get("ShowHUD", true)
print("HUD Visibility:", showHUD)
```

---

### **lia.option.save**

**Description:**  
Saves all current option values to persistent storage based on the client's IP and active gamemode.

**Realm:**  
`Client`

**Example Usage:**
```lua
lia.option.save()
```

---

### **lia.option.load**

**Description:**  
Loads all option values from persistent storage. If no saved options are found, it saves the current options as defaults.

**Realm:**  
`Client`

**Example Usage:**
```lua
lia.option.load()
```

---

## Usage Example

```lua
-- Adding a new option on the client side
lia.option.add("MusicVolume", "Music Volume", "Adjust the background music volume.", 75, function(oldValue, newValue)
    print("MusicVolume changed from", oldValue, "to", newValue)
end, {
    min = 0,
    max = 100,
})
```
---
