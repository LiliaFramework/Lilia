## lia.keybind

---

The `lia.keybind` library allows developers to register key bindings along with associated callback functions for both key press and release events. It maps string-based key identifiers (using the predefined `KeysData` table) to their corresponding key codes and stores them alongside descriptions and callback functions. This makes it simple to add custom keybind functionality in your application.

**NOTE:** Make sure the key identifier passed to `lia.keybind.add` is either a valid string (case-insensitive) from the `KeysData` table or a valid key code. Incorrect key identifiers may result in the keybind not being registered.

---

### **lia.keybind.add**

**Description:**  
Registers a new keybind by associating a key with a description and callback functions. When the key is pressed or released, the corresponding callback function is executed.

**Realm:**  

`Shared`

**Parameters:**  

- `key` (`string` or `number`): The key identifier (as a string matching an entry in the `KeysData` table) or the numeric key code.

- `desc` (`string`): A description of what the keybind does.

- `callback` (`function`): The function to call when the key is pressed.

- `releaseCallback` (`function`, optional): The function to call when the key is released.

**Example Usage:**
```lua
-- Register a keybind for the "F" key
lia.keybind.add(KEY_F, "Activate feature", function(ply)
    print("Feature activated!")
end, function(ply)
    print("Feature deactivated!")
end)
```
---
