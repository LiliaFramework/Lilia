# Lilia Framework - Shared Hooks

Shared hook system for the Lilia framework.

---

## Overview

Shared hooks in the Lilia framework handle functionality available on both client and server, typically for data synchronization, shared utilities, and cross-realm features. They follow the Garry's Mod hook system and can be overridden or extended by addons and modules.

---

### AdjustStaminaOffset

**Purpose**

Allows modification of stamina regeneration/drain offset for a player

**When Called**

During stamina calculation, allowing custom stamina modifiers

**Parameters**

* `else` (*unknown*): - Drain

---

### CanOutfitChangeModel

**Purpose**

Called to check if an outfit can change model

**When Called**

When attempting to change a player's model via outfit

---

### CommandAdded

**Purpose**

Called when a command is added

**When Called**

When a new command is registered to the framework

---

### DoModuleIncludes

**Purpose**

Called when doing module includes

**When Called**

When a module is being loaded and files are being included

---

### GetDisplayedDescription

**Purpose**

Called to get displayed description

**When Called**

When showing a player's description

---

### GetDisplayedName

**Purpose**

Called to get displayed name in chat

**When Called**

When showing a player's name in chat

---

### GetDoorInfo

**Purpose**

Called to get door information

**When Called**

When retrieving door data

---

### GetModelGender

**Purpose**

Called to get model gender

**When Called**

When determining a model's gender

---

### InitializedConfig

**Purpose**

Called when configuration is initialized

**When Called**

When the configuration system has finished loading

---

### InitializedItems

**Purpose**

Called when items are initialized

**When Called**

When the item system has finished loading

---

### InitializedModules

**Purpose**

Called when modules are initialized

**When Called**

When the module system has finished loading

---

### InitializedSchema

**Purpose**

Called when schema is initialized

**When Called**

When the schema system has finished loading

---

### InventoryDataChanged

**Purpose**

Called when inventory data changes

**When Called**

When an inventory's data is modified

---

### InventoryInitialized

**Purpose**

Called when an inventory is initialized

**When Called**

When an inventory is first created and set up

---

### InventoryItemDataChanged

**Purpose**

Called when an item's data changes in an inventory

**When Called**

When an item's data is modified while in an inventory

---

### IsCharFakeRecognized

**Purpose**

Called to check if a character is fake recognized

**When Called**

When checking if a character appears recognized but isn't truly

---

### IsCharRecognized

**Purpose**

Called to check if a character is recognized

**When Called**

When checking if one character recognizes another

---

### IsRecognizedChatType

**Purpose**

Called to check if a chat type requires recognition

**When Called**

When determining if players need to be recognized to see names in chat

---

### IsValid

**Purpose**

Called to validate an entity

**When Called**

When checking if an entity reference is valid

---

### ItemDataChanged

**Purpose**

Called when an item's data changes

**When Called**

When an item's data is modified

---

### ItemDefaultFunctions

**Purpose**

Called to get default functions for an item

**When Called**

When building the default interaction functions for an item

---

### ItemInitialized

**Purpose**

Called when an item is initialized

**When Called**

When an item is first created and set up

---

### ItemQuantityChanged

**Purpose**

Called when an item's quantity changes

**When Called**

When the stack size of an item is modified

---

### LiliaLoaded

**Purpose**

Called when Lilia framework is fully loaded

**When Called**

After all Lilia systems are initialized

---

### NetVarChanged

**Purpose**

Called when a network variable changes

**When Called**

When an entity's netvar is modified

---

### OnItemRegistered

**Purpose**

Called when an item is registered

**When Called**

When a new item is added to the item system

---

### OnLoaded

**Purpose**

Called when the framework has finished loading

**When Called**

After all framework components have been initialized

---

### OnModuleTableCreated

**Purpose**

Called when a module table is created

**When Called**

When a new module table is registered in the framework

---

### OnModuleTableRemoved

**Purpose**

Called when a module table is removed

**When Called**

When a module is unregistered from the framework

---

### OnPrivilegeRegistered

**Purpose**

Called when a new privilege is registered

**When Called**

When a privilege is added to the system

---

### OnPrivilegeUnregistered

**Purpose**

Called when a privilege is unregistered

**When Called**

When a privilege is removed from the system

---

### OnQuestItemLoaded

**Purpose**

Called when a quest item is loaded

**When Called**

When a quest-related item is loaded into the game

---

### OptionChanged

**Purpose**

Called when a configuration option is changed

**When Called**

When a configuration value is modified

---

### OverrideFactionDesc

**Purpose**

Called to override a faction's description

**When Called**

When a faction description needs to be modified

---

### OverrideFactionModels

**Purpose**

Called to override a faction's models

**When Called**

When a faction's available models need to be modified

---

### OverrideFactionName

**Purpose**

Called to override a faction's name

**When Called**

When a faction name needs to be modified

---

### PlayerStaminaDepleted

**Purpose**

Called when player stamina is depleted

**When Called**

When a player runs out of stamina

---

### PlayerStaminaGained

**Purpose**

Called when player gains stamina

**When Called**

When a player's stamina increases

---

### PlayerStaminaLost

**Purpose**

Called when player loses stamina

**When Called**

When a player's stamina decreases

---

### PreLiliaLoaded

**Purpose**

Called before Lilia framework is loaded

**When Called**

Before Lilia systems are initialized

---

### calcStaminaChange

**Purpose**

Called to calculate stamina change

**When Called**

When calculating how much stamina should change

---

### getData

**Purpose**

Called to get persistent data

**When Called**

When retrieving stored data

---

