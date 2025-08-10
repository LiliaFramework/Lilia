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
| `noDrop` | `boolean` | `false` | Prevents dropping or giving the item. |
| `FactionWhitelist` | `table` | `nil` | Allowed faction indices for vendor interaction. |
| `RequiredSkillLevels` | `table` | `nil` | Skill requirements needed to use the item. |
| `SteamIDWhitelist` | `table` | `nil` | Allowed Steam IDs for vendor interaction. |
| `UsergroupWhitelist` | `table` | `nil` | Allowed user groups for vendor interaction. |
| `VIPWhitelist` | `boolean` | `false` | Restricts usage to VIP players. |
| `ammo` | `string` | `""` | Ammo type provided. |
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
| `useSound` | `string` | `""` | Sound played when using the item. |
| `flag` | `string` | `""` | Flag required to purchase the item. |
| `forceRender` | `boolean` | `false` | Always regenerate the spawn icon. |
| `functions` | `table` | `DefaultFunctions` | Table of interaction functions. |
| `health` | `number` | `0` | Amount of health restored when used. |
| `height` | `number` | `1` | Height in inventory grid. |
| `id` | `any` | `0` | Database identifier. |
| `iconCam` | `table` | `nil` | Custom spawn icon camera settings. |
| `invHeight` | `number` | `0` | Internal bag inventory height. |
| `invWidth` | `number` | `0` | Internal bag inventory width. |
| `isBag` | `boolean` | `false` | Marks the item as a bag providing extra inventory. |
| `isBase` | `boolean` | `false` | Indicates the table is a base item. |
| `isOutfit` | `boolean` | `false` | Marks the item as an outfit. |
| `isStackable` | `boolean` | `false` | Enables stacking and merging of item quantities. |
| `isWeapon` | `boolean` | `false` | Marks the item as a weapon. |
| `maxQuantity` | `number` | `1` | Maximum stack size for stackable items. |
| `model` | `string` | `""` | 3D model path for the item. |
| `name` | `string` | `"INVALID NAME"` | Displayed name of the item. |
| `newSkin` | `number` | `0` | Skin index applied to the player model. |
| `outfitCategory` | `string` | `""` | Slot or category for the outfit. |
| `pacData` | `table` | `{}` | PAC3 customization information. |
| `visualData` | `table` | `{}` | Model, skin, and bodygroup overrides for outfits. |
| `bodyGroups` | `table` | `nil` | Bodygroup values applied when equipped. |
| `hooks` | `table` | `{}` | Table of hook callbacks. |
| `postHooks` | `table` | `{}` | Table of post-hook callbacks. |
| `price` | `number` | `0` | Item cost for trading or selling. |
| `quantity` | `number` | `1` | Current amount in the item stack. |
| `rarity` | `string` | `""` | Rarity level affecting vendor color. |
| `replacements` | `string` | `""` | Model replacements when equipped. |
| `unequipSound` | `string` | `""` | Sound played when unequipping. |
| `uniqueID` | `string` | `"undefined"` | Overrides the automatically generated unique identifier. |
| `url` | `string` | `""` | Web address opened when using the item. |
| `weaponCategory` | `string` | `""` | Slot category for the weapon. |
| `width` | `number` | `1` | Width in inventory grid. |

---

## Field Details

### Audio & Interaction

#### `BagSound`

**Type:**

`table`

**Description:**

Sound played when moving items to/from the bag; specified as `{path, volume}`.

**Example Usage:**

```lua
ITEM.BagSound = {"physics/cardboard/cardboard_box_impact_soft2.wav", 50}
```

---

#### `equipSound`

**Type:**

`string`

**Description:**

Sound played when equipping the item.

**Example Usage:**

```lua
ITEM.equipSound = "items/ammo_pickup.wav"
```

---

#### `unequipSound`

**Type:**

`string`

**Description:**

Sound played when unequipping the item.

**Example Usage:**

```lua
ITEM.unequipSound = "items/ammo_pickup.wav"
```

---

#### `useSound`

**Type:**

`string`

**Description:**

Sound played when using the item.

**Example Usage:**

```lua
ITEM.useSound = "items/ammo_pickup.wav"
```

---

### Restrictions & Whitelists

#### `DropOnDeath`

**Type:**

`boolean`

**Description:**

Deletes the item upon player death.

**Example Usage:**

```lua
ITEM.DropOnDeath = true
```

---

#### `noDrop`

**Type:**

`boolean`

**Description:**

Prevents the item from being dropped or given to another player.

**Example Usage:**

```lua
ITEM.noDrop = true
```

---

#### `FactionWhitelist`

**Type:**

`table`

**Description:**

Allowed faction indices for vendor interaction.

**Example Usage:**

```lua
ITEM.FactionWhitelist = {FACTION_CITIZEN}
```

---

#### `RequiredSkillLevels`

**Type:**

`table`

**Description:**

Skill requirements needed to use the item.

**Example Usage:**

```lua
ITEM.RequiredSkillLevels = {Strength = 5}
```

---

#### `SteamIDWhitelist`

**Type:**

`table`

**Description:**

Allowed Steam IDs for vendor interaction.

**Example Usage:**

```lua
ITEM.SteamIDWhitelist = {"STEAM_0:1:123"}
```

---

#### `UsergroupWhitelist`

**Type:**

`table`

**Description:**

Allowed user groups for vendor interaction.

**Example Usage:**

```lua
ITEM.UsergroupWhitelist = {"admin"}
```

---

#### `VIPWhitelist`

**Type:**

`boolean`

**Description:**

Restricts usage to VIP players.

**Example Usage:**

```lua
ITEM.VIPWhitelist = true
```

---

### Inventory & Stacking

#### `isBag`

**Type:**

`boolean`

**Description:**

Marks the item as a bag providing extra inventory.

**Example Usage:**

```lua
ITEM.isBag = true
```

---

#### `invWidth`

**Type:**

`number`

**Description:**

Internal bag inventory width.

**Example Usage:**

```lua
ITEM.invWidth = 2
```

---

#### `invHeight`

**Type:**

`number`

**Description:**

Internal bag inventory height.

**Example Usage:**

```lua
ITEM.invHeight = 2
```

---

#### `width`

**Type:**

`number`

**Description:**

Width in the external inventory grid.

**Example Usage:**

```lua
ITEM.width = 2
```

---

#### `height`

**Type:**

`number`

**Description:**

Height in the external inventory grid.

**Example Usage:**

```lua
ITEM.height = 1
```

---

#### `canSplit`

**Type:**

`boolean`

**Description:**

Whether the item stack can be divided.

**Example Usage:**

```lua
ITEM.canSplit = true
```

---

#### `isStackable`

**Type:**

`boolean`

**Description:**

Enables stacking of the item. Combine with `maxQuantity` to cap the stack size and `canSplit` to allow dividing stacks.

**Example Usage:**

```lua
ITEM.isStackable = true
```

---

#### `maxQuantity`

**Type:**

`number`

**Description:**

Maximum stack size for stackable items.

**Example Usage:**

```lua
ITEM.maxQuantity = 10
```

---

#### `quantity`

**Type:**

`number`

**Description:**

Current amount in the item stack; managed with `item:getQuantity()` and `item:setQuantity()`.

**Example Usage:**

```lua
print(item:getQuantity())
```

---

### Categorization & Metadata

#### `base`

**Type:**

`string`

**Description:**

Base item this item derives from.

**Example Usage:**

```lua
ITEM.base = "base_weapons"
```

When loading items from a folder such as `items/weapons/`, the framework

automatically sets `ITEM.base` to match that folder (e.g. `base_weapons`).

Ideally you should organize item files under directories named after the base

they inherit from so this assignment happens automatically.

---

#### `isBase`

**Type:**

`boolean`

**Description:**

Indicates the table is a base item.

**Example Usage:**

```lua
ITEM.isBase = true
```

---

#### `category`

**Type:**

`string`

**Description:**

Inventory grouping category.

**Example Usage:**

```lua
ITEM.category = "Storage"
```

---

#### `name`

**Type:**

`string`

**Description:**

Displayed name of the item.

**Example Usage:**

```lua
ITEM.name = "Example Item"
```

---

#### `desc`

**Type:**

`string`

**Description:**

Short description shown to players.

**Example Usage:**

```lua
ITEM.desc = "An example item"
```

---

#### `uniqueID`

**Type:**

`string`

**Description:**

String identifier used to register the item. When omitted it is derived

from the file path, but you may override it to provide a custom ID.

**Example Usage:**

```lua
ITEM.uniqueID = "custom_unique_id"
```

---

#### `id`

**Type:**

`any`

**Description:**

Unique numeric identifier assigned by the inventory system. Instances

use this to reference the item in the database and it should not be

manually set.

**Example Usage:**

```lua
print(item.id)
```

---

### Equipment & Stats

#### `armor`

**Type:**

`number`

**Description:**

Armor value granted when equipped.

**Example Usage:**

```lua
ITEM.armor = 50
```

---

#### `health`

**Type:**

`number`

**Description:**

Amount of health restored when used.

**Example Usage:**

```lua
ITEM.health = 50
```

---

#### `attribBoosts`

**Type:**

`table`

**Description:**

Attribute boosts applied on equip.

**Example Usage:**

```lua
ITEM.attribBoosts = {strength = 5}
```

---

#### `isOutfit`

**Type:**

`boolean`

**Description:**

Marks the item as an outfit.

**Example Usage:**

```lua
ITEM.isOutfit = true
```

---

#### `newSkin`

**Type:**

`number`

**Description:**

Skin index applied to the player model.

**Example Usage:**

```lua
ITEM.newSkin = 1
```

---

#### `outfitCategory`

**Type:**

`string`

**Description:**

Slot or category for the outfit.

**Example Usage:**

```lua
ITEM.outfitCategory = "body"
```

---

#### `pacData`

**Type:**

`table`

**Description:**

PAC3 customization information.

**Example Usage:**

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

#### `visualData`

**Type:**

`table`

**Description:**

Model, skin, and bodygroup overrides applied when an outfit is equipped. The table is populated automatically and normally does not need manual editing.

**Example Usage:**

```lua
ITEM.visualData = {
    model = {},
    skin = {},
    bodygroups = {}
}
```

---

#### `bodyGroups`

**Type:**

`table`

**Description:**

Bodygroup values applied when the outfit is equipped.

**Example Usage:**

```lua
ITEM.bodyGroups = { head = 1, torso = 2 }
```

---

#### `replacements`

**Type:**

`string`

**Description:**

Model replacements when equipped.

**Example Usage:**

```lua
-- This will change a certain part of the model.
ITEM.replacements = {"group01", "group02"}
-- This will change the player's model completely.
ITEM.replacements = "models/manhack.mdl"
-- This will have multiple replacements.
ITEM.replacements = {
	{"male", "female"},
	{"group01", "group02"}
}```

---

### Combat & Ammo

#### `class`

**Type:**

`string`

**Description:**

Weapon entity class. Also used by grenade items to determine the weapon entity spawned.

**Example Usage:**

```lua

ITEM.class = "weapon_pistol"

```

---

#### `isWeapon`

**Type:**

`boolean`

**Description:**

Marks the item as a weapon.

**Example Usage:**

```lua

ITEM.isWeapon = true

```

---


#### `ammo`

**Type:**

`string`

**Description:**

Ammo type provided.

**Example Usage:**

```lua

ITEM.ammo = "pistol"

```
---


#### `weaponCategory`

**Type:**

`string`

**Description:**

Slot category for the weapon.

**Example Usage:**

```lua

ITEM.weaponCategory = "sidearm"

```

---

### Visuals & Models

#### `model`

**Type:**

`string`

**Description:**

3D model path for the item.

**Example Usage:**

```lua

ITEM.model = "models/props_c17/oildrum001.mdl"

```

#### `iconCam`

**Type:**

`table`

**Description:**

Custom camera parameters used when rendering the item's spawn icon. Contains `pos`, `ang`, and `fov` keys.

**Example Usage:**

```lua

ITEM.iconCam = {

    pos = Vector(0, 0, 32),

    ang = Angle(0, 180, 0),

    fov = 45

}

```

#### `forceRender`

**Type:**

`boolean`

**Description:**

When `true`, forces the spawn icon to regenerate even if an icon for the model already exists.

**Example Usage:**

```lua

ITEM.forceRender = true

```

---

### Entity & Content

#### `entityid`

**Type:**

`string`

**Description:**

Entity class spawned by the item.

**Example Usage:**

```lua

ITEM.entityid = "item_suit"

```

---

#### `contents`

**Type:**

`string`

**Description:**

HTML contents of a readable book.

**Example Usage:**

```lua

ITEM.contents = "<h1>Book</h1>"

```

---

### Economic & Pricing

#### `price`

**Type:**

`number`

**Description:**

Item cost for trading or selling.

**Example Usage:**

```lua

ITEM.price = 100

```

---

#### `flag`

**Type:**

`string`

**Description:**

Flag required to purchase the item.

**Example Usage:**

```lua

ITEM.flag = "Y"

```

---

#### `rarity`

**Type:**

`string`

**Description:**

Rarity level affecting vendor color.

**Example Usage:**

```lua

ITEM.rarity = "Legendary"

```

---

#### `url`

**Type:**

`string`

**Description:**

Web address opened when using the item.

**Example Usage:**

```lua

ITEM.url = "https://example.com"

```

---

### Behavior & Hooks

#### `functions`

**Type:**

`table`

**Description:**

Table mapping action names to definitions. Each function entry controls
button text, icons and behavior when the action is triggered.

The `name` and `tip` fields for each action are automatically passed through
the `L()` localization helper when an item is registered. Provide translation
keys instead of raw strings.

**Example Usage:**

```lua

ITEM.functions = {}

```
#### `hooks`

**Type:**

`table`

**Description:**

Callbacks triggered on specific item events. Use `ITEM:hook("event", func)` to attach them.

**Example Usage:**

```lua

ITEM:hook("drop", function(itm)

    print(itm.name .. " was dropped")

end)

```


---

#### `postHooks`

**Type:**

`table`

**Description:**

Table of post-hook callbacks.

**Example Usage:**

```lua

-- Defined in base_weapons

function ITEM.postHooks:drop(result)

    local ply = self.player

    if ply:HasWeapon(self.class) then

        ply:StripWeapon(self.class)

    end

end

```

Additional post hooks can be registered dynamically using `ITEM:postHook`:

```lua

ITEM:postHook("drop", function(itm, res)

    print("Post drop result: " .. tostring(res))

end)

```

---
## Base Item Functions

### Aid

- `ITEM.functions.use.onRun(item)`
  - Heals the item owner up to their maximum health using `ITEM.health`.
- `ITEM.functions.target.onRun(item)`
  - Heals the player's traced entity when it is a living player; otherwise notifies of an invalid target.
  - `ITEM.functions.target.onCanRun(item)`
    - Shows the option only when the player is looking at a valid entity.

### Ammo

- `ITEM.functions.use.onRun(item)`
  - Loads ammunition into the player and plays `ITEM.useSound`.
  - Provides multi-options to load all or fixed amounts (5, 10, or 30 rounds) when enough quantity is available.
  - Returns `true` when the stack is depleted.
- `ITEM:getDesc()` → `string`
  - Returns a localized description including the current stack quantity.
- `ITEM:paintOver(item)`
  - Draws the remaining quantity on the item icon.

### Bag

- `ITEM:onInstanced()`
  - Creates the bag's internal inventory and applies access rules.
- `ITEM:onRestored()`
  - Reloads the bag's internal inventory after server restarts.
- `ITEM:onRemoved()`
  - Deletes the bag's inventory when the item is removed.
- `ITEM:getInv()`
  - Returns the bag's internal inventory instance.
- `ITEM:onSync(recipient)`
  - Sends the internal inventory to the given player.
- `ITEM.postHooks:drop()`
  - Clears the bag inventory data when dropped.
- `ITEM:onCombine(other)`
  - Attempts to transfer the other item into the bag's inventory.

### Stackable

Items that track quantity and can merge with other stacks of the same type. Setting `isStackable` to `true` enables this behavior and allows stacks to combine or split as needed.

- `ITEM:getDesc()` → `string`
  - Returns a localized description including the current stack quantity.
- `ITEM:paintOver(item)`
  - Displays the stack quantity on the item icon.
- `ITEM:onCombine(other)` → `boolean`
  - Merges another stack of the same item. Removes the other stack if fully combined and returns `true`.

### Weapons

- `ITEM:hook("drop", function(item))`
  - When dropped, saves ammo, strips the weapon, and clears equipped data if necessary.
- `ITEM.functions.Unequip.onRun(item)`
  - Strips the weapon, stores remaining ammo, plays `ITEM.unequipSound`, and clears the equip state.
  - `ITEM.functions.Unequip.onCanRun(item)`
    - Available only when the weapon is equipped and not placed in the world.
- `ITEM.functions.Equip.onRun(item)`
  - Gives the weapon to the player if the slot is free, restores saved ammo, marks it equipped, and plays `ITEM.equipSound`.
  - `ITEM.functions.Equip.onCanRun(item)`
    - Blocks equipping if already equipped, the slot is occupied, or the player is ragdolled.
- `ITEM.postHooks:drop()`
  - Strips the weapon from the player if they still carry it after dropping the item.
- `ITEM:OnCanBeTransfered(_, newInventory)` → `boolean`
  - Blocks transferring the item while it is equipped.
- `ITEM:onLoadout()`
  - Gives the weapon and restores its ammo when the player spawns with the item equipped.
- `ITEM:OnSave()`
  - Stores the weapon's current clip in the item data.
- `ITEM:getName()` *(client)* → `string`
  - Uses the weapon's `PrintName` if available.
- `ITEM:paintOver(item, w, h)` *(client)*
  - Marks the item as equipped.

### Outfit

- `ITEM:hook("drop", function(item))`
  - Automatically calls `removeOutfit` if the item is dropped while equipped.
- `ITEM.functions.Unequip.onRun(item)`
  - Calls `removeOutfit` to revert model, skin, armor, PAC parts, and boosts.
  - `ITEM.functions.Unequip.onCanRun(item)`
    - Available only when the outfit is equipped and not in the world.
- `ITEM.functions.Equip.onRun(item)`
  - Equips the outfit after ensuring the category slot is free and applies model, skin, bodygroups, armor, PAC parts, and boosts.
  - `ITEM.functions.Equip.onCanRun(item)`
    - Disabled when already equipped or the item exists as an entity.
- `ITEM:removeOutfit(client)`
  - Reverts the player's model, skin, bodygroups, armor, PAC parts, and attribute boosts. Triggers `onTakeOff`.
- `ITEM:wearOutfit(client, isForLoadout)`
  - Applies armor, PAC parts, and attribute boosts. Triggers `onWear`.
- `ITEM:OnCanBeTransfered(_, newInventory)` → `boolean`
  - Blocks transferring the item while it is equipped.
- `ITEM:onLoadout()`
  - Reapplies the outfit on spawn if equipped.
- `ITEM:onRemoved()`
  - Automatically unequips the outfit when the item is removed.
- `ITEM:paintOver(item, w, h)` *(client)*
  - Shows an equipped indicator.

### PAC Outfit

- `ITEM:hook("drop", function(item))`
  - Removes the PAC part if the item is dropped while equipped.
- `ITEM.functions.Unequip.onRun(item)`
  - Calls `removePart` to detach the PAC part and remove boosts.
  - `ITEM.functions.Unequip.onCanRun(item)`
    - Available only when the item is equipped and not placed in the world.
- `ITEM.functions.Equip.onRun(item)`
  - Attaches the PAC part after verifying no conflicting outfit is equipped and applies attribute boosts.
  - `ITEM.functions.Equip.onCanRun(item)`
    - Blocks equipping when already equipped or the item exists in the world.
- `ITEM:removePart(client)`
  - Removes the PAC part and any attribute boosts.
- `ITEM:onCanBeTransfered(_, newInventory)` → `boolean`
  - Blocks transferring the item while it is equipped.
- `ITEM:onLoadout()`
  - Reapplies the PAC part on spawn if equipped.
- `ITEM:onRemoved()`
  - Automatically unequips the part when the item is removed.
- `ITEM:paintOver(item, w, h)` *(client)*
  - Shows an equipped indicator.

### Book

- `ITEM.functions.Read.onClick(item)`
  - Opens a window displaying `ITEM.contents`.
- `ITEM.functions.Read.onRun()` → `boolean`
  - Always returns `false` to prevent the item from being consumed.

### Entity Spawner

- `ITEM.functions.Place.onRun(item)` → `boolean`
  - Spawns `ITEM.entityid` at the player's aim position and returns `true` on success.
- `ITEM.functions.Place.onCanRun(item)` → `boolean`
  - Only allows placement when the item is not already spawned into the world.

### Grenade

- `ITEM.functions.Use.onRun(item)` → `boolean`
  - Gives the grenade weapon specified by `ITEM.class` if the player doesn't already have it. Returns `true` when granted.

### URL Item

- `ITEM.functions.use.onRun()` → `boolean`
  - Opens `ITEM.url` in the player's browser on the client and returns `false`.

---
## Item Type Examples

Minimal definitions for each built-in item type are shown below.


### Weapon

```lua

ITEM.name = "Sub Machine Gun"

ITEM.model = "models/weapons/w_smg1.mdl"

ITEM.class = "weapon_smg1"

ITEM.weaponCategory = "primary"

ITEM.isWeapon = true

```

### Ammo

```lua

ITEM.name = "Pistol Ammo"

ITEM.model = "models/items/357ammo.mdl"

ITEM.ammo = "pistol"

ITEM.maxQuantity = 30

```

### Stackable

A minimal definition for an item that can be stacked and split.

```lua

ITEM.name = "Stack of Metal"

ITEM.model = "models/props_junk/cardboard_box001a.mdl"

ITEM.isStackable = true

ITEM.maxQuantity = 10

ITEM.canSplit = true

```

### Bag

```lua
ITEM.name = "Suitcase"
ITEM.model = "models/props_c17/suitcase001a.mdl"
ITEM.isBag = true
ITEM.invWidth = 2
ITEM.invHeight = 2
ITEM.BagSound = {"physics/cardboard/cardboard_box_impact_soft2.wav", 50}
```

### Outfit

```lua

ITEM.name = "Combine Armor"

ITEM.model = "models/props_c17/BriefCase001a.mdl"

ITEM.outfitCategory = "body"

ITEM.replacements = "models/player/combine_soldier.mdl"

ITEM.newSkin = 1

```

### PAC Outfit

```lua

ITEM.name = "Skull Mask"

ITEM.outfitCategory = "hat"

ITEM.pacData = { ... }

```

### Aid Item

```lua

ITEM.name = "Bandages"

ITEM.model = "models/weapons/w_package.mdl"

ITEM.health = 50

```

### Book

```lua

ITEM.name = "Example"

ITEM.contents = "<h1>An Example</h1>"

```

### URL Item

```lua

ITEM.name = "Hi Barbie"

ITEM.url = "https://www.youtube.com/watch?v=9ezbBugUQiQ"

```

### Entity Spawner

```lua

ITEM.name = "Item Suit"

ITEM.entityid = "item_suit"

```

### Grenade

```lua

ITEM.name = "Grenade"

ITEM.class = "weapon_frag"

ITEM.DropOnDeath = true

```
