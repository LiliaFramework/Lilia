# Classes

Classes are specialized roles within factions. Think of them as sub-factions or regiments - specialized units within a larger organization.

Examples:

- Police Department: Officer, Detective, SWAT, Chief
- Army: Infantry, Sniper, Medic, Tank Commander
- Galactic Empire: Stormtrooper, Scout Trooper, Imperial Officer, Dark Trooper

Skip this if you only need basic factions. Classes work well for military, law enforcement, or complex organizational structures.

## Creating Classes

To create a class for your schema, first create a `classes` folder in your gamemode's `schema` folder if it does not exist.

One class corresponds to one file within the `classes` folder. The files in the classes folder should be named `sh_<identifier>.lua` where `<identifier>` is a string containing only alphanumeric characters and underscores. By convention, `<identifier>` should be lowercase as well.

When the file is loaded, a global table called `CLASS` is available. This is the table that contains information about your class. The following keys are required:

```lua
CLASS.name = "Class Name"
CLASS.desc = "A description of your class"
CLASS.faction = FACTION_CITIZEN
```

Then, you can add any other details you would like for your class.

At the end of the file, you must include the following:

```lua
CLASS_POLICE = CLASS.index
```

The `CLASS.index` is a numeric value that is the class ID for your class. This is the ID that is used with the class library. So, here the ID is stored to a global variable for later use.

Now, your class is done!

## Player Models

You can specify a specific player model for your class using `CLASS.model`. This should be a string containing the model path. For example:

```lua
CLASS.model = "models/player/police.mdl"
```

## Skins

You can set a specific skin for your class model using `CLASS.skin`. This should be a number containing the skin index. For example:

```lua
CLASS.skin = 1
```

## Bodygroups

You can set specific bodygroups for your class model using `CLASS.bodygroups`. This should be a table where each key is the bodygroup id, and the value is the bodygroup value. For example:

```lua
CLASS.bodygroups = {
    [1] = 0, -- Bodygroup 1 (visor) set to 0
    [2] = 1  -- Bodygroup 2 (manhack) set to 1
}
```

## Salary

You can set a salary for your class using `CLASS.pay`. This is the amount of money players in this class will receive every paycheck. For example:

```lua
CLASS.pay = 150 -- $150 per paycheck
```

## Default Weapons

You can give players default weapons when they spawn using `CLASS.weapons`. This should be a table containing strings of weapon class names. For example:

```lua
CLASS.weapons = {
    "weapon_pistol",
    "weapon_stunstick",
    "weapon_police_baton"
}
```

## Health and Armor

You can set custom health and armor values for your class using `CLASS.health` and `CLASS.armor`. For example:

```lua
CLASS.health = 120  -- Higher health than default
CLASS.armor = 50    -- Standard police armor
```

## Movement Properties

You can customize movement properties for your class using `CLASS.runSpeed`, `CLASS.walkSpeed`, and `CLASS.jumpPower`. For example:

```lua
CLASS.runSpeed = 280  -- Slightly slower than default for tactical movement
CLASS.walkSpeed = 150 -- Standard walking speed
CLASS.jumpPower = 200 -- Standard jump power
```

## NPC Relationships

You can set NPC relationships for your class using `CLASS.NPCRelations`. This overrides the faction's NPC relationships. For example:

```lua
CLASS.NPCRelations = {
    ["npc_metropolice"] = D_LI,  -- Liked by metropolice
    ["npc_citizen"] = D_NU,      -- Neutral to citizens
    ["npc_rebel"] = D_HT         -- Hated by rebels
}
```

## When to Use Classes

Use classes for specialized units within factions:

- Military regiments: Infantry, Snipers, Medics, Engineers, Tank Commanders
- Law enforcement units: Patrol Officers, Detectives, SWAT, K-9 Units
- Medical divisions: Doctors, Surgeons, EMTs, Specialists
- Criminal organizations: Enforcers, Lieutenants, Capos, Bosses
- Sci-fi factions: Stormtroopers, Scout Troopers, Imperial Officers, Elite Guards

## Faction vs Class

| Level | Purpose | Example | Scope |
|-------|---------|---------|-------|
| Faction | Main organization | "United States Army" | Broad group everyone belongs to |
| Class | Specialized regiment | "Sniper Regiment" | Elite/specialized role within faction |
| Faction | Government | "Galactic Empire" | Large overarching group |
| Class | Military branch | "Stormtrooper Corps" | Specific military unit type |

Classes are sub-factions that inherit from their parent faction but can have unique abilities, equipment, and restrictions.

## Class Properties

| Property | Purpose | Example |
|----------|---------|---------|
| `name` | Display name | `"Police Officer"` |
| `desc` | Description | `"Law enforcement officer"` |
| `faction` | Parent faction | `FACTION_CITY` |
| `limit` | Maximum players | `8` |
| `isWhitelisted` | Requires whitelist | `true` |
| `model` | Player model | `"models/player/police.mdl"` |
| `skin` | Model skin | `1` |
| `bodygroups` | Model bodygroups | `{[1] = 0, [2] = 1}` |
| `pay` | Salary amount | `150` |
| `weapons` | Starting weapons | `{"weapon_pistol"}` |
| `health` | Max health | `120` |
| `armor` | Armor value | `50` |
| `runSpeed` | Run speed | `280` |
| `walkSpeed` | Walk speed | `150` |
| `jumpPower` | Jump power | `200` |

For more class options, see the [Class Guide](../definitions/class.md).