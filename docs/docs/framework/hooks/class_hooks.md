# Class Hooks

Class hooks allow you to manage and respond to various events related to player classes in your game. Similar to **Factions**, each **Class** has its own set of hooks that are triggered when players join, leave, switch, or spawn within a class. These hooks are specifically designed to be used within class tables created in `schema/classes/classname.lua` and are not interchangeable with regular gamemode hooks.

---

## **OnCanBe**

**Description**

Determines whether a player is allowed to switch to a specific class. This hook is evaluated before a class switch occurs, allowing you to enforce restrictions based on player attributes or roles.

**Parameters**

- **client** (`Player`): The player attempting to switch to the class.

**Returns**

- **bool**: `true` if the player is permitted to switch to the class, `false` otherwise.

**Example**

```lua
function CLASS:OnCanBe(client)
    -- Allow switch if the player is staff or has the "Z" flag
    return client:isStaff() or client:getChar():hasFlags("Z")
end
```

*In this example, only staff members or players with the "Z" flag can switch to this class.*

---

## **OnLeave**

**Description**

Triggered when a player leaves the current class and joins a different one. This hook allows you to perform actions such as resetting models or other class-specific attributes when a player exits a class.

**Realm**

`Server`

**Parameters**

- **client** (`Player`): The player who has left the class.

**Example**

```lua
function CLASS:OnLeave(client)
    local character = client:getChar()
    -- Change the player's model to Alyx when they leave the class
    character:setModel("models/player/alyx.mdl")
end
```

*This example changes the player's model to "Alyx" upon leaving the class.*

---

## **OnSet**

**Description**

Called when a player successfully joins a class. Use this hook to initialize class-specific settings, such as setting the player's model or other attributes upon joining.

**Realm**

`Server`

**Parameters**

- **client** (`Player`): The player who has joined the class.

**Example**

```lua
function CLASS:OnSet(client)
    -- Set the player's model to a police model when they join the class
    client:setModel("models/police.mdl")
end
```

*Here, the player's model is set to a police model upon joining the class.*

---

## **OnSpawn**

**Description**

Invoked when a player in the class spawns into the world. This hook is useful for setting spawn-specific attributes like health, weapons, or other spawn-related properties.

**Realm**

`Server`

**Parameters**

- **client** (`Player`): The player who has just spawned.

**Example**

```lua
function CLASS:OnSpawn(client)
    -- Set the player's maximum and current health to 500 upon spawning
    client:SetMaxHealth(500)
    client:SetHealth(500)
end
```

*In this example, the player's maximum and current health are both set to 500 when they spawn.*

---

## **OnTransferred**

- **Description:**  
  Executes actions when a character is transferred to the class

- **Realm:**  

  `Server`

- **Parameters:**
  - `character` (`Character`): The character that was transferred.

- **Example Usage:**
  ```lua
  function CLASS:OnTransferred(character)
      local randomModelIndex = math.random(1, #self.models)
      character:setModel(self.models[randomModelIndex])
  end
  ```

---