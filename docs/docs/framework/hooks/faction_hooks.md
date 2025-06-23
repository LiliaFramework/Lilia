# Faction Hooks

This page details the various hooks associated with a **Faction** in your schema. These hooks define specific behaviors and actions that occur during different stages of a faction member's lifecycle, such as character creation, spawning, and transfer. Proper implementation of these hooks allows for customized and dynamic interactions within factions.

---

## **GetDefaultName**

- **Description:**  
  Retrieves the default name for a character upon initial creation within the faction.

- **Realm:**  

  `Shared`

- **Parameters:**
  - `client` (`Player`): The client for whom the default name is being retrieved.

- **Returns:**  
  `String`: The default name for the newly created character.

- **Example Usage:**
  ```lua
  function FACTION:GetDefaultName(client)
      return "CT-" .. math.random(111111, 999999)
  end
  ```

---

## **GetDefaultDesc**

- **Description:**  
  Retrieves the default description for a character upon initial creation within the faction.

- **Realm:**  

  `Shared`

- **Parameters:**
  - `client` (`Player`): The client for whom the default description is being retrieved.

  - `faction` (`Number`): The faction ID for which the default description is being retrieved.

- **Returns:**  
  `String`: The default description for the newly created character.

- **Example Usage:**
  ```lua
  function FACTION:GetDefaultDesc(client, faction)
      return "A police officer"
  end
  ```

---

## **OnCharCreated**

- **Description:**  
  Executes actions when a character is created and assigned to the faction. Typically used to initialize character-specific data or inventory.

- **Realm:**  
- `Server`

- **Parameters:**
  - `client` (`Player`): The client that owns the character.
  
  - `character` (`Character`): The character that has been created.

- **Example Usage:**
  ```lua
  function FACTION:OnCharCreated(client, character)
      local inventory = character:getInv()
      inventory:add("fancy_suit")
  end
  ```

---

## **OnSpawn**

- **Description:**  
  Executes actions when a faction member spawns in the game world. Useful for setting up player-specific settings or notifications.

- **Realm:**  

  `Server`

- **Parameters:**
  - `client` (`Player`): The player that has just spawned.

- **Example Usage:**
  ```lua
  function FACTION:OnSpawn(client)
      client:ChatPrint("You have spawned!")
  end
  ```

---

## **OnTransferred**

- **Description:**  
  Executes actions when a character is transferred to the faction.

- **Realm:**  

  `Server`

- **Parameters:**
  - `character` (`Character`): The character that was transferred.

- **Example Usage:**
  ```lua
  function FACTION:OnTransferred(character)
      local randomModelIndex = math.random(1, #self.models)
      character:setModel(self.models[randomModelIndex])
  end
  ```

---