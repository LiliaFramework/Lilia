# lia.config

---

The `lia.config` module manages configuration settings within your schema. It allows you to define, retrieve, and modify various configuration options that control different aspects of your game or application. Configurations can be global or schema-specific, and they support different data types such as booleans, numbers, colors, and generic text fields.

---

### **lia.config.add**

**Description:**  
Adds a new configuration option to the system.

**Realm:**  
`Shared`

**Parameters:**  

- `key` (`string`): The unique identifier for the configuration option.
- `name` (`string`): The display name of the configuration option.
- `value` (`any`): The default value of the configuration option.
- `callback` (`function`, optional): A function to call when the configuration value changes.
- `data` (`table`): A table containing additional data for the configuration option.
  - `desc` (`string`): A description of the configuration option.
  - `category` (`string`, optional): The category under which the configuration option falls. Defaults to `"General"`.
  - `noNetworking` (`boolean`, optional): If `true`, the configuration change won't be networked to clients. Defaults to `false`.
  - `schemaOnly` (`boolean`, optional): If `true`, the configuration is only available within the schema. Defaults to `false`.
  - `isGlobal` (`boolean`, optional): If `true`, the configuration is global. Defaults to `false`.
  - `type` (`string`, optional): The type of the configuration. Defaults based on the value provided. `"Generic"` is a text field.

**Example Usage:**
```lua
lia.config.add("MoneyModel", "Money Model", "models/props_lab/box01a.mdl", nil, {
    desc = "Defines the model used for representing money in the game.",
    category = "Money",
    noNetworking = false,
    schemaOnly = false,
    isGlobal = true,
    type = "Generic"
})
```

---

### **lia.config.setDefault**

**Description:**  
Sets the default value for a configuration option.

**Realm:**  
`Shared`

**Parameters:**  

- `key` (`string`): The unique identifier of the configuration option.
- `value` (`any`): The default value to set.

**Example Usage:**
```lua
lia.config.setDefault("MoneyModel", "models/props_lab/box01a.mdl")
```

---

### **lia.config.forceSet**

**Description:**  
Forces the configuration option to a specific value, optionally preventing it from being saved.

**Realm:**  
`Shared`

**Parameters:**  

- `key` (`string`): The unique identifier of the configuration option.
- `value` (`any`): The value to set.
- `noSave` (`boolean`, optional): If `true`, the change won't be saved. Defaults to `false`.

**Example Usage:**
```lua
lia.config.forceSet("MaxPlayers", 100, true)
```

---

### **lia.config.set**

**Description:**  
Sets the value of a configuration option and handles networking and callbacks if on the server.

**Realm:**  
`Shared`

**Parameters:**  

- `key` (`string`): The unique identifier of the configuration option.
- `value` (`any`): The new value to set.

**Example Usage:**
```lua
lia.config.set("MoneyModel", "models/props_c17/briefcase001a.mdl")
```

---

### **lia.config.get**

**Description:**  
Retrieves the current value of a configuration option, falling back to the default if not set.

**Realm:**  
`Shared`

**Parameters:**  

- `key` (`string`): The unique identifier of the configuration option.
- `default` (`any`, optional): The default value to return if the configuration is not set.

**Returns:**  
`any`: The current value of the configuration option or the default value.

**Example Usage:**
```lua
local moneyModel = lia.config.get("MoneyModel", "models/props_lab/box01a.mdl")
print("Current Money Model:", moneyModel)
```

---

### **lia.config.load**

**Description:**  
Loads all configuration options from storage. Should be called during initialization.

**Realm:**  
`Shared`

**Example Usage:**
```lua
lia.config.load()
```

---

### **lia.config.getChangedValues**

**Description:**  
Retrieves all configuration options that have been changed from their default values.

**Realm:**  
`Server`

**Returns:**  
`table`: A table containing key-value pairs of changed configuration options.

**Example Usage:**
```lua
local changedConfigs = lia.config.getChangedValues()
for key, value in pairs(changedConfigs) do
    print(key, value)
end
```

---

### **lia.config.send**

**Description:**  
Sends the changed configuration values to a specific client.

**Realm:**  
`Server`

**Parameters:**  

- `client` (`Player`): The client to send the configuration data to.

**Example Usage:**
```lua
lia.config.send(somePlayer)
```

---

### **lia.config.save**

**Description:**  
Saves all changed configuration options to persistent storage.

**Realm:**  
`Server`

**Example Usage:**
```lua
lia.config.save()
```

---