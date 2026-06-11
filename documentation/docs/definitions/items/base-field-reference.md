# Item Base Field Reference

This reference is derived only from the Lua item bases in [`gamemode/items/base`](/d:/GMOD/Server/garrysmod/gamemodes/Lilia/gamemode/items/base). Defaults below are the values defined by each base itself. Fields are listed when they are either assigned directly on `ITEM` or clearly read as configuration by the base logic.

## `base_aid`

| Field | Type | Description | Default |
| --- | --- | --- | --- |
| `name` | `string` | Display name. | `"aidName"` |
| `desc` | `string` | Short item description. | `"aidDesc"` |
| `model` | `string` | World and inventory model. | `"models/weapons/w_package.mdl"` |
| `width` | `number` | Inventory width in slots. | `1` |
| `height` | `number` | Inventory height in slots. | `1` |
| `health` | `number` | Total health restored on use. | `0` |
| `armor` | `number` | Armor restored on use. | `0` |
| `stamina` | `number` | Stamina restored on use. | `0` |
| `healTime` | `number` | Total duration for timed healing; `0` heals instantly. | `0` |
| `healInterval` | `number` | Seconds between healing ticks when `healTime` is used. | `1` |

## `base_ammo`

| Field | Type | Description | Default |
| --- | --- | --- | --- |
| `name` | `string` | Display name. | `"ammoName"` |
| `model` | `string` | World and inventory model. | `"models/props_c17/SuitCase001a.mdl"` |
| `width` | `number` | Inventory width in slots. | `1` |
| `height` | `number` | Inventory height in slots. | `1` |
| `ammo` | `string` | Ammo type granted when used. | `"pistol"` |
| `category` | `string` | Inventory category. | `"itemCatAmmunition"` |
| `useSound` | `string` | Optional sound used when loading ammo; falls back to the built-in ammo pickup sound. | None |

## `base_arccw_att`

| Field | Type | Description | Default |
| --- | --- | --- | --- |
| `name` | `string` | Display name. | `"arccwAttachment"` |
| `desc` | `string` | Short item description. | `"arccwAttachmentDesc"` |
| `category` | `string` | Inventory category. | `"attachments"` |
| `model` | `string` | World and inventory model. | `"models/Items/BoxSRounds.mdl"` |
| `width` | `number` | Inventory width in slots. | `1` |
| `height` | `number` | Inventory height in slots. | `1` |
| `att` | `string` | ArcCW attachment ID given and removed by the item. | `""` |

## `base_books`

| Field | Type | Description | Default |
| --- | --- | --- | --- |
| `name` | `string` | Display name. | `"booksName"` |
| `desc` | `string` | Short item description. | `"booksDesc"` |
| `category` | `string` | Inventory category. | `"itemCatLiterature"` |
| `model` | `string` | World and inventory model. | `"models/props_lab/bindergraylabel01b.mdl"` |
| `contents` | `string` | Readable HTML/text content shown by the item. | `""` |

## `base_entities`

| Field | Type | Description | Default |
| --- | --- | --- | --- |
| `name` | `string` | Display name. | `"entitiesName"` |
| `model` | `string` | World and inventory model. | `""` |
| `desc` | `string` | Short item description. | `"entitiesDesc"` |
| `category` | `string` | Inventory category. | `"entities"` |
| `entityid` | `string` | Entity class spawned when the item is placed. | `""` |

## `base_grenade`

| Field | Type | Description | Default |
| --- | --- | --- | --- |
| `name` | `string` | Display name. | `"grenadeName"` |
| `desc` | `string` | Short item description. | `"grenadeDesc"` |
| `category` | `string` | Inventory category. | `"itemCatGrenades"` |
| `model` | `string` | World and inventory model. | `"models/weapons/w_eq_fraggrenade.mdl"` |
| `class` | `string` | Weapon class granted by the item. | `"weapon_frag"` |
| `width` | `number` | Inventory width in slots. | `1` |
| `height` | `number` | Inventory height in slots. | `1` |
| `DropOnDeath` | `boolean` | Whether the grenade item should drop on death. | `true` |

## `base_outfit`

| Field | Type | Description | Default |
| --- | --- | --- | --- |
| `name` | `string` | Display name. | `"outfit"` |
| `desc` | `string` | Short item description. | `"outfitDesc"` |
| `category` | `string` | Inventory category. | `"outfit"` |
| `model` | `string` | World and inventory model. | `"models/props_c17/BriefCase001a.mdl"` |
| `width` | `number` | Inventory width in slots. | `1` |
| `height` | `number` | Inventory height in slots. | `1` |
| `outfitCategory` | `string` | Conflict group used to stop multiple outfits of the same type from equipping together. | `"model"` |
| `pacData` | `table` | PAC data associated with the outfit. | `{}` |
| `isOutfit` | `boolean` | Marks the item as an outfit item. | `true` |
| `armor` | `number` | Armor added on equip and removed on unequip. | None |
| `newSkin` | `number` | Skin index applied while equipped. | None |
| `bodyGroups` | `table` | Bodygroup values applied while equipped. | None |
| `attribBoosts` | `table` | Attribute boosts applied while equipped. | None |
| `replacement` | `string` | Replacement model path used when equipping, if present. | None |
| `replacements` | `string \| table` | Replacement model rule or rule list used when equipping, if present. | None |

## `base_pacoutfit`

| Field | Type | Description | Default |
| --- | --- | --- | --- |
| `name` | `string` | Display name. | `"pacoutfitName"` |
| `desc` | `string` | Short item description. | `"pacoutfitDesc"` |
| `category` | `string` | Inventory category. | `"outfit"` |
| `model` | `string` | World and inventory model. | `"models/Gibs/HGIBS.mdl"` |
| `width` | `number` | Inventory width in slots. | `1` |
| `height` | `number` | Inventory height in slots. | `1` |
| `outfitCategory` | `string` | Conflict group used to stop multiple PAC outfits of the same type from equipping together. | `"hat"` |
| `pacData` | `table` | PAC3 part data tied to the item. | `{}` |
| `attribBoosts` | `table` | Attribute boosts applied while equipped. | None |

## `base_stackable`

| Field | Type | Description | Default |
| --- | --- | --- | --- |
| `name` | `string` | Display name. | `"stackableName"` |
| `model` | `string` | World and inventory model. | `"models/props_junk/cardboard_box001a.mdl"` |
| `width` | `number` | Inventory width in slots. | `1` |
| `height` | `number` | Inventory height in slots. | `1` |
| `isStackable` | `boolean` | Marks the item as using stack quantity behavior. | `true` |
| `maxQuantity` | `number` | Maximum units allowed in one stack. | `10` |
| `canSplit` | `boolean` | Whether players can split the stack. | `true` |

## `base_url`

| Field | Type | Description | Default |
| --- | --- | --- | --- |
| `name` | `string` | Display name. | `"urlName"` |
| `desc` | `string` | Short item description. | `"urlDesc"` |
| `model` | `string` | World and inventory model. | `"models/props_interiors/pot01a.mdl"` |
| `url` | `string` | URL opened by the item. | `""` |

## `base_weapons`

| Field | Type | Description | Default |
| --- | --- | --- | --- |
| `name` | `string` | Display name. | `"weaponsName"` |
| `desc` | `string` | Short item description. | `"weaponsDesc"` |
| `category` | `string` | Inventory category. | `"weapons"` |
| `model` | `string` | World and inventory model. | `"models/weapons/w_pistol.mdl"` |
| `class` | `string` | SWEP class granted and restored by the item. | `"weapon_pistol"` |
| `width` | `number` | Inventory width in slots. | `2` |
| `height` | `number` | Inventory height in slots. | `2` |
| `isWeapon` | `boolean` | Marks the item as a weapon item. | `true` |
| `RequiredSkillLevels` | `table` | Table of required skill levels. | `{}` |
| `DropOnDeath` | `boolean` | Whether the weapon item should drop on death. | `true` |
| `weaponCategory` | `string` | Optional slot/category key used to block equipping another weapon item with the same category. | None |
| `equipSound` | `string` | Optional sound played when equipping; falls back to the built-in ammo pickup sound. | None |
| `unequipSound` | `string` | Optional sound played when unequipping or dropping an equipped weapon; falls back to the built-in ammo pickup sound. | None |
