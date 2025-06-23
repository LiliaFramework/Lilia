# lia.flag

---

The `lia.flag` library provides a system for granting and managing abilities or permissions for characters within the Lilia framework. Flags are represented by single alphanumeric characters and allow for fine-grained control over what actions a character can perform, such as spawning props or using specific tools. This system is essential for enforcing role-based permissions and ensuring server-side validation of player actions.

**NOTE:** Flags should be unique single alphanumeric characters to avoid conflicts and ensure proper functionality.

---

### **lia.flag.add**

**Description:**  
Creates a new flag that can be assigned to characters. This function should be called in a shared context to ensure that both the server and client are aware of the flag's existence.

**Realm:**  
`Shared`

**Parameters:**  

- `flag` (`string`): A single alphanumeric character representing the flag.
- `desc` (`string`): A description of what the flag does.
- `callback` (`function`): A function to be called when the flag is given or taken from a player. The function receives two arguments:
  - `client` (`Player`): The player to whom the flag is being assigned or removed.
  - `bGiven` (`boolean`): `true` if the flag is being given, `false` if it is being taken.

**Example Usage:**
```lua
lia.flag.add("z", "Grants the ability to fly.", function(client, bGiven)
    if bGiven then
        client:EnableFlight()
    else
        client:DisableFlight()
    end
end)
```

---