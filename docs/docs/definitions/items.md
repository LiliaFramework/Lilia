# Item Fields

This document describes all configurable `ITEM` fields in the codebase. Use these to customize item behavior, appearance, interactions, and metadata.
Unspecified fields will use sensible defaults.

---

## Overview

The global `ITEM` table defines per-item settings such as sounds, inventory dimensions, restrictions, stats, and hooks. Unspecified fields will use sensible defaults.

---

## Field Summary

| Field | Type | Default | Description |
|---|---|---|---|
| `BagSound` | `table` | `nil` | Sound played when moving items to/from the bag. |
| `DropOnDeath` | `boolean` | `false` | Deletes the item upon player death. |
| `FactionWhitelist` | `table` | `nil` | Allowed faction indices for vendor interaction. |
| `RequiredSkillLevels` | `table` | `nil` | Skill requirements needed to use the item. |
| `SteamIDWhitelist` | `table` | `nil` | Allowed Steam IDs for vendor interaction. |
| `UsergroupWhitelist` | `table` | `nil` | Allowed user groups for vendor interaction. |
| `VIPWhitelist` | `boolean` | `false` | Restricts usage to VIP players. |
| `ammo` | `string` | `""` | Ammo type provided. |
| `ammoAmount` | `number` | `0` | Amount of ammo contained. |
| `armor` | `number` | `0` | Armor value granted when equipped. |
| `attribBoosts` | `table` | `{}` | Attribute boosts applied when equipped. |
| `base` | `string` | `""` | Base item this item derives from. |
| `canSplit` | `boolean` | `true` | Whether the item stack can be divided. |
| `category` | `string` | `"Miscellaneous"` | Inventory grouping category. |
| `class` | `string` | `""` | Weapon entity class. |
| `contents` | `string` | `""` | HTML contents of a readable book. |
| `desc` | `string` | `"No Description"` | Short description shown to players. |
| `entityid` | `string` | `""` | Entity class spawned by the item. |
| `equipSound` | `string` | `""` | Sound played when equipping. |
| `flag` | `string` | `""` | Flag required to purchase the item. |
| `functions` | `table` | `DefaultFunctions` | Table of interaction functions. |
| `grenadeClass` | `string` | `""` | Class name used when spawning a grenade. |
| `health` | `number` | `0` | Amount of health restored when used. |
| `height` | `number` | `1` | Height in inventory grid. |
| `id` | `any` | `0` | Database identifier. |
| `invHeight` | `number` | `0` | Internal bag inventory height. |
| `invWidth` | `number` | `0` | Internal bag inventory width. |
| `isBag` | `boolean` | `false` | Marks the item as a bag providing extra inventory. |
| `isBase` | `boolean` | `false` | Indicates the table is a base item. |
| `isOutfit` | `boolean` | `false` | Marks the item as an outfit. |
| `isStackable` | `boolean` | `false` | Allows stacking multiple quantities. |
| `isWeapon` | `boolean` | `false` | Marks the item as a weapon. |
| `maxQuantity` | `number` | `1` | Maximum stack size. |
| `model` | `string` | `""` | 3D model path for the item. |
| `name` | `string` | `"INVALID NAME"` | Displayed name of the item. |
| `newSkin` | `number` | `0` | Skin index applied to the player model. |
| `outfitCategory` | `string` | `""` | Slot or category for the outfit. |
| `pacData` | `table` | `{}` | PAC3 customization information. |
| `postHooks` | `table` | `{}` | Table of post-hook callbacks. |
| `price` | `number` | `0` | Item cost for trading or selling. |
| `quantity` | `number` | `1` | Current amount in the item stack. |
| `rarity` | `string` | `""` | Rarity level affecting vendor color. |
| `replacements` | `string` | `""` | Model replacements when equipped. |
| `unequipSound` | `string` | `""` | Sound played when unequipping. |
| `uniqueID` | `string` | `"undefined"` | Overrides the automatically generated unique identifier. |
| `url` | `string` | `""` | Web address opened when using the item. |
| `visualData` | `table` | `{}` | Table storing outfit visual information. |
| `weaponCategory` | `string` | `""` | Slot category for the weapon. |
| `width` | `number` | `1` | Width in inventory grid. |

---

## Field Details

### Audio & Interaction

#### `BagSound`
**Type:** `table`
**Description:** Sound played when moving items to/from the bag; specified as `{path, volume}`.
**Example:**
```lua
ITEM.BagSound = {"physics/cardboard/cardboard_box_impact_soft2.wav", 50}
```

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

**Type:** `table`
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

**Type:** `table`
**Description:** Allowed Steam IDs for vendor interaction.
**Example:**

```lua
ITEM.SteamIDWhitelist = {"STEAM_0:1:123"}
```

#### `UsergroupWhitelist`

**Type:** `table`
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

#### `desc`

**Type:** `string`
**Description:** Short description shown to players.
**Example:**
```lua
ITEM.desc = "An example item"
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

#### `isOutfit`

**Type:** `boolean`
**Description:** Marks the item as an outfit.
**Example:**
```lua
ITEM.isOutfit = true
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
-- This attaches an HGIBS gib model to the player’s eyes bone
ITEM.pacData = {
	[1] = {
		["children"] = {
			[1] = {
				["children"] = {
				},
				["self"] = {
					["Angles"] = Angle(12.919322967529, 6.5696062847564e-006, -1.0949343050015e-005),
					["Position"] = Vector(-2.099609375, 0.019973754882813, 1.0180969238281),
					["UniqueID"] = "4249811628",
					["Size"] = 1.25,
					["Bone"] = "eyes",
					["Model"] = "models/Gibs/HGIBS.mdl",
					["ClassName"] = "model",
				},
			},
		},
		["self"] = {
			["ClassName"] = "group",
			["UniqueID"] = "907159817",
			["EditorExpand"] = true,
		},
	},
}
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
