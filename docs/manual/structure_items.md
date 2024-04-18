# Structure - Items

Items with a specific base must be organized within a folder named after that base. For example, if you have a weapon that uses the 'weapons' base, you should save it under 'items/weapons/ItemID.lua'. If an item is not found within a corresponding base folder or if its base is missing, it will default to the basic item base, which only allows for dropping

### Default Item Example:

```lua
ITEM.name = "Test Item" -- The name of the item
ITEM.desc = "A test item!" -- A brief description of the item
ITEM.model = "models/props_c17/oildrum001.mdl" -- The 3D model for the item
```

### Vehicles Item Example:

```lua
ITEM.name = "A Vehicle" -- The name of the vehicle
ITEM.desc = "A Vehicle" -- A brief description of the vehicle
ITEM.model = "models/props_c17/BriefCase001a.mdl" -- The 3D model for the vehicle
ITEM.category = "Vehicles" -- The category of the vehicle
ITEM.vehicleid = "VehicleID" -- The identifier for the vehicle
```

### Outfit Item Example:

```lua
ITEM.name = "Combine Armor" -- The name of the outfit
ITEM.desc = "Protects your insides from the outsides" -- A brief description of the outfit
ITEM.model = "models/props_c17/BriefCase001a.mdl" -- The 3D model for the outfit
ITEM.width = 2 -- The width of the outfit in inventory
ITEM.height = 2 -- The height of the outfit in inventory
ITEM.replacements = "models/player/combine_soldier.mdl" -- Model replacement for the player wearing the outfit
```

### Entities Item Example:

```lua
ITEM.name = "Item Suit" -- The name of the entities item
ITEM.desc = "An HL2 Item Suit" -- A brief description of the entities item
ITEM.model = "models/props_c17/BriefCase001a.mdl" -- The 3D model for the entities item
ITEM.category = "Entities" -- The category of the entities item
ITEM.entityid = "item_suit" -- The identifier for the entities item
```

### Books Item Example:

```lua
ITEM.name = "Example" -- The name of the book
ITEM.desc = "An Example" -- A brief description of the book
ITEM.contents = [[
<h1>An Example</h1>
<h3>By Example</h3>
<p>
EXAMPLE PARA.
EXAMPLE PARA.
EXAMPLE PARAGRAPH.
EXAMPLE PARAGRAH!
</p>
]] -- The contents of the book, in HTML format
```

### Ammo Item Example:

```lua
ITEM.name = ".357 Ammo" -- The name of the ammo
ITEM.model = "models/items/357ammo.mdl" -- The 3D model for the ammo
ITEM.ammo = "357" -- The type of ammo
ITEM.ammoAmount = 12 -- The amount of ammo in the box
ITEM.ammoDesc = "A Box that contains %s of .357 Ammo" -- Description of the ammo box
```

### Weapons Item Example:

```lua
ITEM.name = "AR2" -- The name of the weapon
ITEM.desc = "A Weapon." -- A brief description of the weapon
ITEM.model = "models/weapons/w_IRifle.mdl" -- The 3D model for the weapon
ITEM.class = "weapon_ar2" -- The class used to spawn this weapon
ITEM.weaponCategory = "primary" -- The category of the weapon
ITEM.width = 4 -- The width of the weapon in inventory
ITEM.height = 2 -- The height of the weapon in inventory
```

If you don't wish to manually code weapons, you can enable [this](https://github.com/LiliaFramework/Lilia/blob/main/lilia/modules/utilities/wepgenerator/config/shared.lua#L1)