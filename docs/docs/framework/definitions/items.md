---

## Global Item Functions

Below is a comprehensive list of global functions and properties used to define items. Each function/property is detailed with its purpose, type, and examples to guide you in creating and managing items effectively.

| **Function/Property**        | **Purpose**                                                                                  | **Type**    | **Example**                                           |
|------------------------------|----------------------------------------------------------------------------------------------|-------------|-------------------------------------------------------|
| `ITEM.name`                  | Sets the name of the item.                                                                   | `String`    | `ITEM.name = "Radio Antenna"`                         |
| `ITEM.model`                 | Specifies the 3D model used for the item.                                                    | `String`    | `ITEM.model = "models/props_lab/antenna.mdl"`         |
| `ITEM.desc`                  | Provides a short description of the item.                                                    | `String`    | `ITEM.desc = "A deployable radio antenna."`           |
| `ITEM.category`              | Groups the item into a specific category.                                                    | `String`    | `ITEM.category = "Electronics"`                       |
| `ITEM.width` & `ITEM.height` | Define the size of the item in the inventory grid.                                           | `Number`    | `ITEM.width = 2`, `ITEM.height = 1`                   |
| `ITEM.price`                 | Sets the item's price for trading or selling.                                               | `Number`    | `ITEM.price = 100`                                     |
| `ITEM.VManipDisabled`        | Disables VManip grabbing functionality for the item.                                       | `Boolean`      | `ITEM.VManipDisabled = true`                           |
| `ITEM.uniqueID`              | Overrides the default unique ID, usually derived from the file name.                        | `String`    | `ITEM.uniqueID = "custom_unique_id"`                   |
| `ITEM.SteamIDWhitelist`      | Specifies a whitelist of Steam IDs allowed to interact with the item in vendors.            | `Table`     | `ITEM.SteamIDWhitelist = {"STEAM_0:1:12345678"}`       |
| `ITEM.FactionWhitelist`      | Specifies a whitelist of factions allowed to interact with the item in vendors.             | `Table`     | `ITEM.FactionWhitelist = {FACTION_CITIZEN, FACTION_POLICE}` |
| `ITEM.UsergroupWhitelist`    | Specifies a whitelist of user groups allowed to interact with the item in vendors.          | `Table`     | `ITEM.UsergroupWhitelist = {"admin", "moderator"}`    |
| `ITEM.VIPWhitelist`          | Specifies whether the item is restricted to VIP players.                                   | `Boolean`      | `ITEM.VIPWhitelist = true`                             |
| `ITEM.rarity`                | Specifies the rarity level of the item, determining its color in vendor displays.           | `String`    | `ITEM.rarity = "Legendary"`                            |
| `ITEM.RequiredSkillLevels`   | Specifies the required skill levels to use the item.                                       | `Table`     | `ITEM.RequiredSkillLevels = {Survival = 5}`            |
| `ITEM.flag`                  | Specifies the necessary flag to buy an item.                                               | `String`    | `ITEM.flag = "Y"`                                       |
| `ITEM.DropOnDeath`           | Deletes the item upon the player's death.                                                  | `Boolean`      | `ITEM.DropOnDeath = true`                               |

---

## Item Examples

Below are various item types with corresponding Lua examples and explanations to illustrate how to utilize the global item functions effectively.

### 1. Baseless Item Example

A simple item without additional functionalities.

```lua
ITEM.name = "Example Item"
ITEM.desc = "A example item!"
ITEM.model = "models/props_c17/oildrum001.mdl"
```

**Explanation:**

- **`ITEM.name`**: Sets the name of the item.

- **`ITEM.desc`**: Provides a short description.

- **`ITEM.model`**: Specifies the 3D model for the item.

---

### 2. Aid Item Example

An item that provides health restoration.

```lua
ITEM.name = "Bandages"
ITEM.desc = "Gives you 50 HP."
ITEM.model = "models/weapons/w_package.mdl"
ITEM.width = 1
ITEM.height = 1
ITEM.health = 50
```

**Explanation:**

- **`ITEM.name`**: Name of the aid item.

- **`ITEM.desc`**: Description indicating the health restored.

- **`ITEM.model`**: 3D model representing the item.

- **`ITEM.width` & `ITEM.height`**: Size in the inventory grid.

- **`ITEM.health`**: Amount of health restored when used.

---

### 3. Ammo Example

Defines ammunition for a specific weapon.

```lua
ITEM.name = ".357 Ammo"
ITEM.model = "models/items/357ammo.mdl"
ITEM.ammo = "357"
ITEM.ammoAmount = 12
ITEM.desc = "Contains 12 rounds of .357 Ammo"
ITEM.price = 10
```

**Explanation:**

- **`ITEM.name`**: Name of the ammo type.

- **`ITEM.model`**: 3D model representing the ammo.

- **`ITEM.ammo`**: Type of ammo compatible with weapons.

- **`ITEM.ammoAmount`**: Number of ammo units per item.

- **`ITEM.desc`**: Description detailing the ammo quantity.

- **`ITEM.price`**: Cost for trading or selling.

---

### 4. Bag Example

A storage item that can hold other items.

```lua
ITEM.name = "Small Bag"
ITEM.desc = "A small bag."
ITEM.model = "models/props_c17/suitcase001a.mdl"
ITEM.category = "Storage"
ITEM.isBag = true
ITEM.invWidth = 2
ITEM.invHeight = 2
ITEM.BagSound = {"physics/cardboard/cardboard_box_impact_soft2.wav", 50}
ITEM.pacData = {}
```

**Explanation:**

- **`ITEM.name`**: Name of the bag.

- **`ITEM.desc`**: Description of the bag.

- **`ITEM.model`**: 3D model representing the bag.

- **`ITEM.category`**: Category grouping.

- **`ITEM.isBag`**: Indicates it has storage functionality.

- **`ITEM.invWidth` & `ITEM.invHeight`**: Size of the bag's internal inventory.

- **`ITEM.BagSound`**: Sound played when interacting with the bag.

- **`ITEM.pacData`**: PAC3 customization data.

---

### 5. Book Example

An item containing readable content.

```lua
ITEM.name = "Example Book"
ITEM.desc = "An Example"
ITEM.model = "models/props_lab/binderblue.mdl"
ITEM.contents = [[
<h1>An Example</h1>
<h3>By Example</h3>
<p>
EXAMPLE PARA.<br>
EXAMPLE PARA.<br>
EXAMPLE PARAGRAPH.<br>
EXAMPLE PARAGRAPH!
</p>
]]
```

**Explanation:**

- **`ITEM.name`**: Name of the book.

- **`ITEM.desc`**: Description of the book.

- **`ITEM.model`**: 3D model representing the book.

- **`ITEM.contents`**: HTML content displayed when reading the book.

---

### 6. Entities Example

An item that spawns a specific entity in the game world.

```lua
ITEM.name = "Item Suit"
ITEM.desc = "An HL2 Item Suit"
ITEM.model = "models/props_c17/BriefCase001a.mdl"
ITEM.category = "Entities"
ITEM.entityid = "item_suit"
```

**Explanation:**

- **`ITEM.name`**: Name of the entity item.

- **`ITEM.desc`**: Description of the entity.

- **`ITEM.model`**: 3D model representing the entity item.

- **`ITEM.category`**: Category grouping.

- **`ITEM.entityid`**: The class name of the entity to spawn.

---

### 7. Clothing Example

An outfit that modifies player appearance and attributes.

```lua
ITEM.name = "Combine Armor"
ITEM.desc = "Protects your insides from the outsides."
ITEM.model = "models/props_c17/BriefCase001a.mdl"
ITEM.category = "Clothing"
ITEM.width = 2
ITEM.height = 2
ITEM.outfitCategory = "body"
ITEM.replacements = "models/player/combine_soldier.mdl"
ITEM.newSkin = 1
ITEM.armor = 50
ITEM.attribBoosts = {
    strength = 5,
    agility = 3
}
ITEM.RequiredSkillLevels = {
    strength = 10
}
ITEM.pacData = {
    [1] = {
        name = "combine_armor",
        model = "models/props_c17/BriefCase001a.mdl"
    }
}
```

**Explanation:**

- **`ITEM.name`**: Name of the clothing item.

- **`ITEM.desc`**: Description of the clothing.

- **`ITEM.model`**: 3D model representing the clothing.

- **`ITEM.category`**: Category grouping.

- **`ITEM.width` & `ITEM.height`**: Size in the inventory grid.

- **`ITEM.outfitCategory`**: Category of the outfit (e.g., "body").

- **`ITEM.replacements`**: Player model or adjustments when equipped.

- **`ITEM.newSkin`**: New skin index for the player's model.

- **`ITEM.armor`**: Armor value provided by the outfit.

- **`ITEM.attribBoosts`**: Attribute boosts granted when equipped.

- **`ITEM.RequiredSkillLevels`**: Skill requirements to use the outfit.

- **`ITEM.pacData`**: PAC3 customization data for visual effects.

---

### 8. Gun Example

An item representing a weapon that players can equip and use.

```lua
ITEM.name = ".357 Revolver"
ITEM.desc = "A sidearm utilizing .357 Caliber ammunition."
ITEM.model = "models/weapons/w_357.mdl"
ITEM.class = "weapon_357"
ITEM.weaponCategory = "sidearm"
ITEM.width = 2
ITEM.height = 1
ITEM.equipSound = "items/ammo_pickup.wav"
ITEM.unequipSound = "items/ammo_pickup.wav"
```

**Explanation:**

- **`ITEM.name`**: Name of the gun.

- **`ITEM.desc`**: Description of the gun.

- **`ITEM.model`**: 3D model representing the gun.

- **`ITEM.class`**: Weapon class identifier.

- **`ITEM.weaponCategory`**: Category of the weapon (e.g., "sidearm").

- **`ITEM.width` & `ITEM.height`**: Size in the inventory grid.

- **`ITEM.equipSound`**: Sound played when the weapon is equipped.

- **`ITEM.unequipSound`**: Sound played when the weapon is unequipped.

---
