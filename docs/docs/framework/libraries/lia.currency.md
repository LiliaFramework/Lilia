# lia.currency

---

The `lia.currency` library provides functions to manage in-game currency, including setting currency symbols and names, formatting currency amounts, spawning currency entities in the game world, and more. This library ensures consistent handling and display of currency across the framework.

**NOTE:** Ensure that currency settings are properly configured to match the desired in-game economy.

---

### **lia.currency.set**

**Description:**  
Sets the symbol, singular, and plural forms of the currency.

**Realm:**  
`Shared`

**Parameters:**  

- `symbol` (`string`): The currency symbol.
- `singular` (`string`): The singular form of the currency name.
- `plural` (`string`): The plural form of the currency name.

**Example Usage:**
```lua
lia.currency.set("$", "dollar", "dollars")
```

---

### **lia.currency.get**

**Description:**  
Retrieves the formatted currency string based on the amount.

**Realm:**  
`Shared`

**Parameters:**  

- `amount` (`integer`): The amount of currency.

**Returns:**  
`string` - The formatted currency string.

**Example Usage:**
```lua
local formattedCurrency = lia.currency.get(5)
print(formattedCurrency) -- Outputs: "$5 dollars"
```

---

### **lia.currency.spawn**

**Description:**  
Spawns a currency entity at the specified position with the given amount and angle.

**Realm:**  
`Server`

**Parameters:**  

- `pos` (`Vector`): The position where the currency entity will be spawned.
- `amount` (`integer`): The amount of currency for the spawned entity.
- `angle` (`Angle`, optional, default `Angle(0, 0, 0)`): The angle of the spawned entity.

**Returns:**  
`Entity|nil` - The spawned currency entity, or `nil` if spawning failed.

**Example Usage:**
```lua
local pos = Vector(100, 200, 300)
local moneyEntity = lia.currency.spawn(pos, 50)
if moneyEntity then
    print("Spawned currency entity with 50 dollars.")
end
```

---

## Variables

### **lia.currency.symbol**

**Description:**  
The symbol representing the currency (e.g., `$`).

**Realm:**  
`Shared`

**Type:**  
`string`

**Example Usage:**
```lua
print(lia.currency.symbol) -- Outputs: "$"
```

---

### **lia.currency.singular**

**Description:**  
The singular form of the currency name (e.g., "dollar").

**Realm:**  
`Shared`

**Type:**  
`string`

**Example Usage:**
```lua
print(lia.currency.singular) -- Outputs: "dollar"
```

---

### **lia.currency.plural**

**Description:**  
The plural form of the currency name (e.g., "dollars").

**Realm:**  
`Shared`

**Type:**  
`string`

**Example Usage:**
```lua
print(lia.currency.plural) -- Outputs: "dollars"
```

---