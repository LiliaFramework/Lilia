# Items

Items are the core of your roleplay server's economy and gameplay. They can be weapons, consumables, outfits, and more. Every item in Lilia is defined using the ITEM table.

## Creating Items

To create an item for your schema, first create an `items` folder in your gamemode's `schema` folder if it does not exist. You can also create items in modules.

One item corresponds to one file within the items folder. The files should be named appropriately for their type (e.g., `weapons`, `consumables`, etc.).

When the file is loaded, a global table called `ITEM` is available. This is the table that contains information about your item. The following keys are required:

```lua
ITEM.name = "Item Name"
ITEM.desc = "A description of your item"
ITEM.category = "Category"
ITEM.model = "models/item.mdl"
```

Then, you can add any other details you would like for your item.

At the end of the file, you must include the following:

```lua
lia.item.list["item_unique_id"] = ITEM
```

Now, your item is done!

## Item Types

### Weapons

Weapon items are equippable weapons that can be given to players. They support ammo tracking, weapon categories, and visual indicators.

**Key Properties:**
- `class`: The weapon class name (e.g., "weapon_pistol")
- `isWeapon`: Set to true for weapon items
- `DropOnDeath`: Whether the weapon drops when the player dies

```lua
ITEM.name = "9mm Pistol"
ITEM.desc = "A standard police sidearm"
ITEM.category = "Weapons"
ITEM.model = "models/weapons/w_pistol.mdl"
ITEM.class = "weapon_pistol"
ITEM.width = 2
ITEM.height = 2
ITEM.isWeapon = true
ITEM.DropOnDeath = true
```

### Consumables

Consumable items can be used once and then are removed from the player's inventory.

**Key Properties:**
- `functions`: Table of functions that can be performed on the item
- `Use`: Function called when the item is used

```lua
ITEM.name = "Health Kit"
ITEM.desc = "Restores 50 health points"
ITEM.category = "Medical"
ITEM.model = "models/items/healthkit.mdl"
ITEM.functions = {
    Use = {
        name = "Use",
        tip = "useTip",
        icon = "icon16/heart.png",
        onRun = function(item)
            local client = item.player
            client:SetHealth(math.min(client:Health() + 50, 100))
            return true -- Remove item after use
        end
    }
}
```

### Stackable Items

Stackable items can have multiple quantities in a single inventory slot.

**Key Properties:**
- `maxQuantity`: Maximum number of items that can stack
- `quantity`: Current quantity (automatically managed)

```lua
ITEM.name = "Wood Planks"
ITEM.desc = "Building material"
ITEM.category = "Materials"
ITEM.model = "models/props_debris/wood_board04a.mdl"
ITEM.maxQuantity = 10
ITEM.width = 2
ITEM.height = 1
```

### Outfits

Outfit items change the player's appearance using PAC3 or player models.

**Key Properties:**
- `outfitCategory`: Category for outfit organization
- `bodyGroups`: Bodygroup settings for the outfit

```lua
ITEM.name = "Police Uniform"
ITEM.desc = "Standard police officer uniform"
ITEM.category = "Clothing"
ITEM.model = "models/player/police.mdl"
ITEM.outfitCategory = "uniforms"
ITEM.bodyGroups = {
    [1] = 0, -- Bodygroup settings
    [2] = 1
}
```

## Item Properties

| Property | Purpose | Example |
|----------|---------|---------|
| `name` | Display name | `"9mm Pistol"` |
| `desc` | Description | `"Standard police sidearm"` |
| `category` | Inventory category | `"Weapons"` |
| `model` | 3D model path | `"models/weapons/w_pistol.mdl"` |
| `width` | Inventory width | `2` |
| `height` | Inventory height | `2` |
| `price` | Shop price | `500` |
| `flag` | Required permission flag | `"p"` |
| `maxQuantity` | Max stack size | `10` |
| `functions` | Item functions | `{Use = {...}}` |

## Item Categories

Items are organized into categories for better inventory management:

- **Weapons**: Guns, melee weapons, explosives
- **Medical**: Health kits, bandages, medicine
- **Food**: Consumables that restore hunger/thirst
- **Clothing**: Outfits, hats, accessories
- **Materials**: Building materials, crafting components
- **Tools**: Utility items, tools
- **Miscellaneous**: Items that don't fit other categories

## Advanced Item Features

### Custom Functions

You can add custom functions to items that appear in the right-click menu:

```lua
ITEM.functions = {
    Use = {
        name = "Consume",
        tip = "useTip",
        icon = "icon16/cup.png",
        onRun = function(item)
            -- Function logic here
            return true -- Return true to remove item
        end
    },
    Custom = {
        name = "Custom Action",
        tip = "customTip",
        icon = "icon16/wrench.png",
        onRun = function(item)
            -- Custom logic
        end
    }
}
```

### Permission Flags

Restrict items to certain players using flags:

```lua
ITEM.flag = "p" -- Requires police flag
```

### Dynamic Pricing

Items can have dynamic prices based on server economy:

```lua
ITEM.price = 100
ITEM.maxPrice = 200  -- Maximum price
ITEM.minPrice = 50   -- Minimum price
```

## Item Placement

**Schema Items:**
```
garrysmod/gamemodes/YOUR_SCHEMA/schema/items/
├── weapons/
│   ├── pistol.lua
│   └── rifle.lua
├── consumables/
│   ├── medkit.lua
│   └── food.lua
└── outfits/
    └── uniform.lua
```

**Module Items:**
```
garrysmod/gamemodes/YOUR_SCHEMA/modules/YOUR_MODULE/items/
└── special_weapon.lua
```

For more item options, see the [Item Documentation](../libraries/item.md).