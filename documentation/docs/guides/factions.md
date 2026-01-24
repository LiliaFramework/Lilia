# Factions

Factions are the main groups in your roleplay server. Every player character belongs to one faction. Examples include Citizens, Police, Medical, etc.

## Creating Factions

To create a faction for your schema, first create a `factions` folder in your gamemode's `schema` folder if it does not exist.

One faction corresponds to one file within the `factions` folder. The files in the factions folder should be named `sh_<identifier>.lua` where `<identifier>` is a string containing only alphanumeric characters and underscores. By convention, `<identifier>` should be lowercase as well.

When the file is loaded, a global table called `FACTION` is available. This is the table that contains information about your faction. The following keys are required:

```lua
FACTION.name = "Faction Name"
FACTION.desc = "A description of your faction"
FACTION.color = Color(255, 255, 255)
```

Then, you can add any other details you would like for your faction.

At the end of the file, you must include the following:

```lua
TEAM_EXAMPLE = FACTION.index
```

The `FACTION.index` is a numeric value that is the team ID for your faction. This is the ID that is used with the team library. So, here the ID is stored to a global variable for later use.

Now, your faction is done!

## Player Models

You can specify a list of available player models for your faction using `FACTION.models`. This should be a table containing strings. For example:

```lua
FACTION.models = {
    "models/player/Group01/male_01.mdl",
    "models/player/Group01/female_01.mdl"
}
```

### Skins

An entry in `FACTION.models` can have a specific skin set by using a table containing two values instead of a string. The first value in the table should be the model path as a string. The second value should be a number containing the skin number. For example:

```lua
FACTION.models = {
    -- Prisoner guard Combine soldier (red eyes).
    {"models/player/combine_soldier.mdl", 1},
    -- Normal Combine soldier (blue eyes).
    "models/player/combine_soldier.mdl"
}
```

### Bodygroups

Similarly, an entry in `FACTION.models` can have certain bodygroups set. Instead of having a table with only two values, a table with 3 values is used. The third value is either string where the ith digit represents the value for the ith bodygroup, or a table where each key is the bodygroup id, and the value is the bodygroup value. For example:

#### With String

```lua
FACTION.models = {
    -- Metropolice with a manhack.
    {"models/police.mdl", 0, "01"},
    -- Normal metropolice without a manhack.
    "models/police.mdl"
}
```

#### With Table

```lua
FACTION.models = {
    -- Metropolice with a manhack.
    {"models/police.mdl", 0,
        {
            [1] = 0, -- Bodygroup 1 (visor) set to 0
            [2] = 1  -- Bodygroup 2 (manhack) set to 1
        }
    },
    -- Normal metropolice without a manhack.
    "models/police.mdl"
}
```

## Salary

You can set a salary for your faction using `FACTION.pay`. This is the amount of money players in this faction will receive every paycheck. For example:

```lua
FACTION.pay = 100 -- $100 per paycheck
```

## Default Weapons

You can give players default weapons when they spawn using `FACTION.weapons`. This should be a table containing strings of weapon class names. For example:

```lua
FACTION.weapons = {
    "weapon_pistol",
    "weapon_stunstick"
}
```

## When do I _ when a player in my faction spawns?

You can use the `PlayerLoadout` hook to give players items when they spawn. This hook is called every time a player spawns. For example:

```lua
hook.Add("PlayerLoadout", "FactionLoadout", function(client)
    if (client:Team() == FACTION_CITIZEN) then
        client:Give("weapon_crowbar")
    end
end)
```

## Whitelists

You can restrict access to factions using whitelists. Set `FACTION.isDefault` to `false` to make the faction require whitelist approval. Players can then be whitelisted using the admin panel or commands.

```lua
FACTION.isDefault = false -- Requires whitelist
```

## Accessing Faction Data

You can access faction data using the `lia.faction.get` function. This returns the faction table for a given faction ID. For example:

```lua
local faction = lia.faction.get(TEAM_CITIZEN)
print(faction.name) -- "Citizens"
```

## Faction Properties

| Property | Purpose | Example |
|----------|---------|---------|
| `name` | Display name | `"Police Department"` |
| `desc` | Description | `"Law enforcement officers"` |
| `color` | UI color | `Color(0, 100, 255)` |
| `isDefault` | Joinable by players | `true` or `false` |
| `models` | Player models | `{"models/player/police.mdl"}` |
| `weapons` | Starting weapons | `{"weapon_pistol"}` |
| `pay` | Salary amount | `150` |
| `health` | Max health | `120` |
| `armor` | Armor value | `50` |

For more faction options, see the [Faction Guide](../definitions/faction.md).