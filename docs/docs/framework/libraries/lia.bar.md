# lia.bar

---

The `lia.bar` library is a helper library for generating and managing UI bars within the Lilia framework. Bars can represent various metrics or actions, enhancing the user interface and improving the roleplay experience. This library provides functions to add, retrieve, remove, and draw bars dynamically on the client side.

---

### **lia.bar.get**

**Description:**  
Retrieves information about a bar identified by its unique identifier.

**Realm:**  
`Client`

**Parameters:**  

- `identifier` (`String`): The unique identifier of the bar.

**Returns:**  
- `Table` | `nil`: The information about the bar if found; otherwise, `nil`.

**Example Usage:**
```lua
local barInfo = lia.bar.get("healthBar")
if barInfo then
    print("Health Bar Found:")
    PrintTable(barInfo)
else
    print("Health Bar does not exist.")
end
```

---

### **lia.bar.add**

**Description:**  
Adds a new bar or updates an existing one. Bars can display dynamic values and are rendered based on their priority in the draw order.

**Realm:**  
`Client`

**Parameters:**  

- `getValue` (`function`): A function that retrieves the current value of the bar (expected to return a number between 0 and 1).

- `color` (`Color`, optional): The color of the bar. Defaults to a random pastel color if not provided.

- `priority` (`Number`, optional): The priority of the bar in the draw order. Higher priority bars are drawn on top. Defaults to the next available priority.

- `identifier` (`String`, optional): The unique identifier of the bar. If provided and a bar with the same identifier exists, it will be updated.


**Returns:**  
- `Number`: The priority of the added or updated bar.

**Example Usage:**
```lua
lia.bar.add(function() return LocalPlayer():GetHealth() / LocalPlayer():GetMaxHealth() end, Color(255, 0, 0), 1, "healthBar")
```

---

### **lia.bar.remove**

**Description:**  
Removes a bar identified by its unique identifier.

**Realm:**  
`Client`

**Parameters:**  

- `identifier` (`String`): The unique identifier of the bar to remove.

**Example Usage:**
```lua
lia.bar.remove("healthBar")
```

---

### **lia.bar.draw**

**Description:**  
Draws a single bar with the specified parameters on the screen.

**Realm:**  
- `Client`

**Parameters:**  

- `x` (`Number`): The x-coordinate of the top-left corner of the bar.

- `y` (`Number`): The y-coordinate of the top-left corner of the bar.

- `w` (`Number`): The width of the bar.

- `h` (`Number`): The height of the bar.

- `value` (`Number`): The current value of the bar (ranging from 0 to 1).

- `color` (`Color`): The color of the bar.

**Example Usage:**
```lua
lia.bar.draw(50, 50, 200, 20, 0.75, Color(0, 255, 0))
```

---

### **lia.bar.drawAction**

**Description:**  
Draws the action bar, which displays ongoing actions with a progress indicator.

**Realm:**  
- `Client`

**Internal:**  
This function is intended for internal use and should not be called directly.
---

### **lia.bar.drawAll**

**Description:**  
Draws all active bars in the list, handling their rendering order and visibility based on their priorities and conditions.

**Realm:**  
- `Client`

**Internal:**  
This function is intended for internal use and should not be called directly.
---
