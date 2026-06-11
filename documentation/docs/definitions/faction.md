# Faction Definitions

Character factions are the main groups that characters belong to in Lilia. A faction decides who can create that kind of character, what models they can use, what they spawn with, how they appear on the scoreboard, how they are recognized, and what default class behavior they get.

Classes sit under factions. If both the faction and the class set the same loadout-style field, the class version takes priority, including `pay` and `payTimer`.

## Placement

Use the normal `FACTION` form in faction definition files loaded by the faction loader, such as `schema/factions/[faction_id].lua` or `modules/[module]/factions/[faction_id].lua`.

Use `lia.faction.register` from a shared Lua file when you want to define and register a faction in one place instead of relying on the loader's shared `FACTION` table. Direct registration is useful for framework code, generated definitions, or module-level registrations that already run from shared code.

## Reference

| Field | Type | Purpose |
| --- | --- | --- |
| `index` | `number` | The faction's internal team number. This is what the game uses to identify the faction behind the scenes. |
| `uniqueID` | `string` | The faction's permanent internal ID. It is used for things like whitelists, saved character data, and transfers. |
| `name` | `string` | Display name shown in menus, logs, notifications, and team labels. |
| `desc` | `string` | The text players read when they view this faction. |
| `color` | `Color` | The color used for this faction in places like menus and the scoreboard. |
| [`models`](#models-field) | `table` | The player models available to this faction. |
| `isDefault` | `boolean` | Lets players create this faction without needing to be whitelisted first. |
| `skinAllowed` | `boolean` | Lets players choose a skin number when creating a character in this faction. |
| `bodygroupsAllowed` | `boolean` | Lets players choose bodygroup options when creating a character in this faction. |
| `allowedSkins` | `table` | Limits skin choice to specific skin numbers. |
| [`allowedBodygroups`](#allowedbodygroups-field) | `table` | Limits which bodygroup values players are allowed to choose. |
| `items` | `table` | Items new characters in this faction start with. |
| `oneCharOnly` | `boolean` | Stops a player from owning more than one character in this faction. |
| `limit` | `number` | Sets how many players can be in this faction at once. `0` means unlimited. Values below `1` act like a percentage of online players. |
| [`spawns`](#spawns-field) | `table` | Custom spawn points for this faction, usually grouped by map name. |
| `NPCRelations` | `table` | Changes how NPCs react to members of this faction. |
| `health` | `number` | Health characters in this faction spawn with. |
| `armor` | `number` | Armor characters in this faction spawn with. |
| `weapons` | `string` or `table` | Weapons characters in this faction receive on spawn. |
| `scale` | `number` | Changes the size of characters in this faction. |
| `runSpeed` | `number` | Changes run speed. `1` means normal speed. |
| `walkSpeed` | `number` | Changes walk speed. `1` means normal speed. |
| `jumpPower` | `number` | Changes jump height. `1` means normal jump power. |
| `bloodcolor` | `number` | Changes the blood color used by this faction. |
| `pay` | `number` | How much this faction gets paid each paycheck, unless a class overrides it. |
| `payTimer` | `number` | How often this faction gets paid. This acts as the fallback interval when the active class does not define its own `payTimer`. |
| `logo` | `string` | A material path or web URL used for this faction's logo in places like the scoreboard. |
| `commands` | `table` | Command names members of this faction are allowed to use. |
| `RecognizesGlobally` | `boolean` | Makes members of this faction automatically recognize everyone. |
| `isGloballyRecognized` | `boolean` | Makes everyone automatically recognize members of this faction. |
| `MemberToMemberAutoRecognition` | `boolean` | Makes members of this faction automatically recognize each other. |
| `scoreboardHidden` | `boolean` | Hides this faction from the scoreboard. |
| `scoreboardPriority` | `number` | Changes where this faction appears on the scoreboard. Lower numbers appear first. |
| `scoreboardClassesPublic` | `boolean` | Lets everyone see this faction's classes on the scoreboard. |
| `scoreboardSeeAllClasses` | `boolean` | Lets members of this faction see every faction's classes on the scoreboard. |
| [`mainMenuPosition`](#mainmenuposition-field) | `Vector` or `table` | Sets where this faction's character preview appears in the main menu. |

## Callback Fields

| Callback | Purpose |
| --- | --- |
| `NameTemplate(info, client)` | Builds a default name suggestion during character creation. |
| `GetDefaultName(client)` | Gives the character a default name when one is needed. |
| `GetDefaultDesc(client)` | Gives the character a default description when one is needed. |
| `OnCheckLimitReached(character, client)` | Lets you decide yourself whether this faction is full. Return `true` to block access, `false` to allow it. |
| `OnTransferred(client, oldFaction)` | Runs after a character is moved into this faction. |
| `OnSpawn(client)` | Runs after the faction's normal spawn values have been applied. |

## Field Notes

### <a id="models-field"></a>`models`

`models` supports more than a simple list of strings. You can use a basic list for simple setups, or a more advanced table if you want grouped model choices.

Example:

```lua
FACTION.models = {
    male = {
        {"models/player/group01/male_01.mdl", "Male 01", {0, 1, 0}}
    },
    female = {
        {"models/player/group01/female_01.mdl", "Female 01", {0, 0, 0}}
    }
}
```

### <a id="allowedbodygroups-field"></a>`allowedBodygroups`

Rules can be keyed by bodygroup number or bodygroup name. A rule value can be:

- `true` to allow any value
- `false` to block all values
- a table of allowed bodygroup values

Example:

```lua
FACTION.allowedBodygroups = {
    [1] = {0, 1, 2},
    helmet = {0, 1}
}
```

### <a id="spawns-field"></a>`spawns`

Faction spawn tables are usually grouped by map name so the same faction can spawn in different places on different maps.

```lua
FACTION.spawns = {
    gm_construct = {
        {position = Vector(0, 0, 0), angles = Angle(0, 90, 0)},
        {position = Vector(128, 64, 0), angles = Angle(0, 180, 0)}
    }
}
```

### <a id="mainmenuposition-field"></a>`mainMenuPosition`

This field supports several accepted shapes, depending on how simple or map-specific you want the preview setup to be.

```lua
FACTION.mainMenuPosition = Vector(0, 0, 0)
```

```lua
FACTION.mainMenuPosition = {
    position = Vector(0, 0, 0),
    angles = Angle(0, 90, 0)
}
```

```lua
FACTION.mainMenuPosition = {
    gm_construct = {
        position = Vector(0, 0, 0),
        angles = Angle(0, 90, 0)
    }
}
```

## Normal Faction File Example

This example matches a typical faction definition file loaded from a schema's factions directory:

```lua
FACTION.name = "Police Department"
FACTION.desc = "City law enforcement."
FACTION.color = Color(45, 105, 215)
FACTION.models = {
    "models/player/police.mdl",
    "models/player/police_fem.mdl"
}
FACTION.isDefault = false
FACTION.oneCharOnly = true
FACTION.limit = 0.15
FACTION.skinAllowed = true
FACTION.allowedSkins = {0, 1}
FACTION.items = {"badge", "radio"}
FACTION.weapons = {"weapon_pistol", "weapon_stunstick"}
FACTION.health = 125
FACTION.armor = 50
FACTION.runSpeed = 1
FACTION.walkSpeed = 1
FACTION.jumpPower = 1
FACTION.pay = 75
FACTION.payTimer = 300
FACTION.logo = "materials/ui/faction/police.png"
FACTION.scoreboardPriority = 25
FACTION.mainMenuPosition = {
    gm_construct = {
        position = Vector(0, 0, 0),
        angles = Angle(0, 90, 0)
    }
}

function FACTION:OnTransferred(client, oldFaction)
    client:notify("Welcome to the Police Department.")
end

function FACTION:OnSpawn(client)
    client:Give("weapon_pistol")
end

FACTION_POLICE = FACTION.index
```

## Direct Registration Example

Use `lia.faction.register` when you want to define and register a faction in one place instead of relying on the loader's shared `FACTION` table:

```lua
local FACTION_POLICE = lia.faction.register("police", {
    name = "Police Department",
    desc = "City law enforcement.",
    color = Color(45, 105, 215),
    models = {
        "models/player/police.mdl",
        "models/player/police_fem.mdl"
    },
    isDefault = false,
    limit = 0.15,
    items = {"badge", "radio"},
    weapons = {"weapon_pistol", "weapon_stunstick"},
    pay = 75,
    OnSpawn = function(self, client)
        client:Give("weapon_pistol")
    end
})
```
