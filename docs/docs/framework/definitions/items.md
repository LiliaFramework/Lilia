````markdown
# Item Fields

This document describes all configurable `ITEM` fields in the codebase. Use these to customize item behavior, appearance, interactions, and metadata.

---

## Table of Contents

1. [Overview](#overview)  
2. [Field Summary](#field-summary)  
3. [Field Details](#field-details)  
   - [Audio & Interaction](#audio--interaction)  
   - [Restrictions & Whitelists](#restrictions--whitelists)  
   - [Inventory & Stacking](#inventory--stacking)  
   - [Categorization & Metadata](#categorization--metadata)  
   - [Equipment & Stats](#equipment--stats)  
   - [Combat & Ammo](#combat--ammo)  
   - [Visuals & Models](#visuals--models)  
   - [Entity & Content](#entity--content)  
   - [Economic & Pricing](#economic--pricing)  
   - [Behavior & Hooks](#behavior--hooks)  

---

## Overview

The global `ITEM` table defines per-item settings such as sounds, inventory dimensions, restrictions, stats, and hooks. Unspecified fields will use sensible defaults.

---

## Field Summary

| Field                   | Type               | Description                                            |
|-------------------------|--------------------|--------------------------------------------------------|
| `BagSound`              | `table`            | Sound played when moving items to/from the bag.       |
| `DropOnDeath`           | `boolean`          | Deletes the item upon player death.                    |
| `FactionWhitelist`      | `number[]`         | Allowed faction indices for vendor interaction.        |
| `RequiredSkillLevels`   | `table`            | Skill requirements needed to use the item.             |
| `SteamIDWhitelist`      | `string[]`         | Allowed Steam IDs for vendor interaction.              |
| `UsergroupWhitelist`    | `string[]`         | Allowed user groups for vendor interaction.            |
| `VIPWhitelist`          | `boolean`          | Restricts usage to VIP players.                        |
| `VManipDisabled`        | `boolean`          | Disables VManip grabbing for the item.                 |
| `ammo`                  | `string`           | Ammo type provided.                                    |
| `ammoAmount`            | `number`           | Amount of ammo contained.                              |
| `armor`                 | `number`           | Armor value granted when equipped.                     |
| `attribBoosts`          | `table`            | Attribute boosts applied when equipped.                |
| `base`                  | `string`           | Base item this item derives from.                      |
| `canSplit`              | `boolean`          | Whether the item stack can be divided.                 |
| `category`              | `string`           | Inventory grouping category.                           |
| `class`                 | `string`           | Weapon entity class.                                   |
| `contents`              | `string`           | HTML contents of a readable book.                      |
| `desc`                  | `string`           | Short description shown to players.                    |
| `entityid`              | `string`           | Entity class spawned by the item.                      |
| `equipSound`            | `string`           | Sound played when equipping.                           |
| `flag`                  | `string`           | Flag required to purchase the item.                    |
| `functions`             | `table`            | Table of interaction functions.                        |
| `grenadeClass`          | `string`           | Class name used when spawning a grenade.               |
| `health`                | `number`           | Amount of health restored when used.                   |
| `height`                | `number`           | Height in inventory grid.                              |
| `id`                    | `any`              | Database identifier.                                   |
| `invHeight`             | `number`           | Internal bag inventory height.                         |
| `invWidth`              | `number`           | Internal bag inventory width.                          |
| `isBag`                 | `boolean`          | Marks the item as a bag providing extra inventory.     |
| `isBase`                | `boolean`          | Indicates the table is a base item.                    |
| `isOutfit`              | `boolean`          | Marks the item as an outfit.                           |
| `isStackable`           | `boolean`          | Allows stacking multiple quantities.                   |
| `isWeapon`              | `boolean`          | Marks the item as a weapon.                            |
| `maxQuantity`           | `number`           | Maximum stack size.                                    |
| `model`                 | `string`           | 3D model path for the item.                            |
| `name`                  | `string`           | Displayed name of the item.                            |
| `newSkin`               | `number`           | Skin index applied to the player model.                |
| `outfitCategory`        | `string`           | Slot or category for the outfit.                       |
| `pacData`               | `table`            | PAC3 customization information.                        |
| `postHooks`             | `table`            | Table of post-hook callbacks.                          |
| `price`                 | `number`           | Item cost for trading or selling.                      |
| `quantity`              | `number`           | Current amount in the item stack.                      |
| `rarity`                | `string`           | Rarity level affecting vendor color.                   |
| `replacements`          | `string`           | Model replacements when equipped.                      |
| `unequipSound`          | `string`           | Sound played when unequipping.                         |
| `uniqueID`              | `string`           | Overrides the automatically generated unique identifier.|
| `url`                   | `string`           | Web address opened when using the item.                |
| `visualData`            | `table`            | Table storing outfit visual information.               |
| `weaponCategory`        | `string`           | Slot category for the weapon.                          |
| `width`                 | `number`           | Width in inventory grid.                               |

---

## Field Details

### Audio & Interaction

#### `BagSound`
**Type:** `table`  
**Description:** Sound played when moving items to/from the bag; specified as `{path, volume}`.  
**Example:**
```lua
ITEM.BagSound = {"physics/cardboard/cardboard_box_impact_soft2.wav", 50}
````

#### `equipSound`

**Type:** `string`
**Description:** Sound played when equipping the item.
**Example:**

```lua
ITEM.equipSound = "items/ammo_pickup.wav"
```

#### `unequipSound`

**Type:** `string`
**Description:** Sound played when unequipping the item.
**Example:**

```lua
ITEM.unequipSound = "items/ammo_pickup.wav"
```

---

### Restrictions & Whitelists

#### `DropOnDeath`

**Type:** `boolean`
**Description:** Deletes the item upon player death.
**Example:**

```lua
ITEM.DropOnDeath = true
```

#### `FactionWhitelist`

**Type:** `number[]`
**Description:** Allowed faction indices for vendor interaction.
**Example:**

```lua
ITEM.FactionWhitelist = {FACTION_CITIZEN}
```

#### `RequiredSkillLevels`

**Type:** `table`
**Description:** Skill requirements needed to use the item.
**Example:**

```lua
ITEM.RequiredSkillLevels = {Strength = 5}
```

#### `SteamIDWhitelist`

**Type:** `string[]`
**Description:** Allowed Steam IDs for vendor interaction.
**Example:**

```lua
ITEM.SteamIDWhitelist = {"STEAM_0:1:123"}
```

#### `UsergroupWhitelist`

**Type:** `string[]`
**Description:** Allowed user groups for vendor interaction.
**Example:**

```lua
ITEM.UsergroupWhitelist = {"admin"}
```

#### `VIPWhitelist`

**Type:** `boolean`
**Description:** Restricts usage to VIP players.
**Example:**

```lua
ITEM.VIPWhitelist = true
```

#### `VManipDisabled`

**Type:** `boolean`
**Description:** Disables VManip grabbing for the item.
**Example:**

```lua
ITEM.VManipDisabled = true
```

---

### Inventory & Stacking

#### `isBag`

**Type:** `boolean`
**Description:** Marks the item as a bag providing extra inventory.
**Example:**

```lua
ITEM.isBag = true
```

#### `invWidth`

**Type:** `number`
**Description:** Internal bag inventory width.
**Example:**

```lua
ITEM.invWidth = 2
```

#### `invHeight`

**Type:** `number`
**Description:** Internal bag inventory height.
**Example:**

```lua
ITEM.invHeight = 2
```

#### `width`

**Type:** `number`
**Description:** Width in the external inventory grid.
**Example:**

```lua
ITEM.width = 2
```

#### `height`

**Type:** `number`
**Description:** Height in the external inventory grid.
**Example:**

```lua
ITEM.height = 1
```

#### `canSplit`

**Type:** `boolean`
**Description:** Whether the item stack can be divided.
**Example:**

```lua
ITEM.canSplit = true
```

#### `isStackable`

**Type:** `boolean`
**Description:** Allows stacking multiple quantities.
**Example:**

```lua
ITEM.isStackable = false
```

#### `maxQuantity`

**Type:** `number`
**Description:** Maximum stack size.
**Example:**

```lua
ITEM.maxQuantity = 10
```

#### `quantity`

**Type:** `number`
**Description:** Current amount in the item stack.
**Example:**

```lua
print(item:getQuantity())
```

---

### Categorization & Metadata

#### `base`

**Type:** `string`
**Description:** Base item this item derives from.
**Example:**

```lua
ITEM.base = "weapon"
```

#### `isBase`

**Type:** `boolean`
**Description:** Indicates the table is a base item.
**Example:**

```lua
ITEM.isBase = true
```

#### `category`

**Type:** `string`
**Description:** Inventory grouping category.
**Example:**

```lua
ITEM.category = "Storage"
```

#### `name`

**Type:** `string`
**Description:** Displayed name of the item.
**Example:**

```lua
ITEM.name = "Example Item"
```

#### `uniqueID`

**Type:** `string`
**Description:** Overrides the automatically generated unique identifier.
**Example:**

```lua
ITEM.uniqueID = "custom_unique_id"
```

#### `id`

**Type:** `any`
**Description:** Database identifier.
**Example:**

```lua
print(item.id)
```

---

### Equipment & Stats

#### `armor`

**Type:** `number`
**Description:** Armor value granted when equipped.
**Example:**

```lua
ITEM.armor = 50
```

#### `health`

**Type:** `number`
**Description:** Amount of health restored when used.
**Example:**

```lua
ITEM.health = 50
```

#### `attribBoosts`

**Type:** `table`
**Description:** Attribute boosts applied on equip.
**Example:**

```lua
ITEM.attribBoosts = {strength = 5}
```

#### `newSkin`

**Type:** `number`
**Description:** Skin index applied to the player model.
**Example:**

```lua
ITEM.newSkin = 1
```

#### `outfitCategory`

**Type:** `string`
**Description:** Slot or category for the outfit.
**Example:**

```lua
ITEM.outfitCategory = "body"
```

#### `visualData`

**Type:** `table`
**Description:** Table storing outfit visual information.
**Example:**

```lua
ITEM.visualData = {}
```

#### `pacData`

**Type:** `table`
**Description:** PAC3 customization information.
**Example:**

```lua
ITEM.pacData = {}
```

#### `replacements`

**Type:** `string`
**Description:** Model replacements when equipped.
**Example:**

```lua
ITEM.replacements = "models/player/combine_soldier.mdl"
```

---

### Combat & Ammo

#### `class`

**Type:** `string`
**Description:** Weapon entity class.
**Example:**

```lua
ITEM.class = "weapon_pistol"
```

#### `isWeapon`

**Type:** `boolean`
**Description:** Marks the item as a weapon.
**Example:**

```lua
ITEM.isWeapon = true
```

#### `grenadeClass`

**Type:** `string`
**Description:** Class name used when spawning a grenade.
**Example:**

```lua
ITEM.grenadeClass = "weapon_frag"
```

#### `ammo`

**Type:** `string`
**Description:** Ammo type provided.
**Example:**

```lua
ITEM.ammo = "pistol"
```

#### `ammoAmount`

**Type:** `number`
**Description:** Amount of ammo contained.
**Example:**

```lua
ITEM.ammoAmount = 30
```

#### `weaponCategory`

**Type:** `string`
**Description:** Slot category for the weapon.
**Example:**

```lua
ITEM.weaponCategory = "sidearm"
```

---

### Visuals & Models

#### `model`

**Type:** `string`
**Description:** 3D model path for the item.
**Example:**

```lua
ITEM.model = "models/props_c17/oildrum001.mdl"
```

---

### Entity & Content

#### `entityid`

**Type:** `string`
**Description:** Entity class spawned by the item.
**Example:**

```lua
ITEM.entityid = "item_suit"
```

#### `contents`

**Type:** `string`
**Description:** HTML contents of a readable book.
**Example:**

```lua
ITEM.contents = "<h1>Book</h1>"
```

---

### Economic & Pricing

#### `price`

**Type:** `number`
**Description:** Item cost for trading or selling.
**Example:**

```lua
ITEM.price = 100
```

#### `flag`

**Type:** `string`
**Description:** Flag required to purchase the item.
**Example:**

```lua
ITEM.flag = "Y"
```

#### `rarity`

**Type:** `string`
**Description:** Rarity level affecting vendor color.
**Example:**

```lua
ITEM.rarity = "Legendary"
```

#### `url`

**Type:** `string`
**Description:** Web address opened when using the item.
**Example:**

```lua
ITEM.url = "https://example.com"
```

---

### Behavior & Hooks

#### `functions`

**Type:** `table`
**Description:** Table of interaction functions.
**Example:**

```lua
ITEM.functions = {}
```

#### `postHooks`

**Type:** `table`
**Description:** Table of post-hook callbacks.
**Example:**

```lua
ITEM.postHooks = {}
```

```
```
