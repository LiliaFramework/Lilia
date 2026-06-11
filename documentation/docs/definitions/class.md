# Class Definitions

Classes are faction-specific roles that characters can join. A class controls who is allowed to join, what model they can use, what they spawn with, how they appear on the scoreboard, and what happens when they enter or leave the class.

Classes inherit their parent faction's general behavior, but if both the class and the faction set the same loadout-style field, the class version takes priority, including `pay` and `payTimer`.

## Placement

Use the normal `CLASS` form in class definition files loaded by the class loader, such as `schema/classes/[class_id].lua` or `modules/[module]/classes/[class_id].lua`.

Use `lia.class.register` from a shared Lua file when you want to define and register a class in one call instead of relying on the loader's shared `CLASS` table. Direct registration is useful for framework code, generated definitions, or module-level registrations that already run from shared code.

## Reference

| Field | Type | Purpose |
| --- | --- | --- |
| `index` | `number` | The class's internal number used by the framework. |
| `uniqueID` | `string` | The class's permanent internal ID used for lookups and saved data. |
| `name` | `string` | Display name shown in class menus, logs, notifications, and UI. |
| `desc` | `string` | The text players read when they view this class. |
| `faction` | `number` | The faction this class belongs to. |
| `limit` | `number` | Sets how many players can be in this class at once. `0` means unlimited. |
| `isDefault` | `boolean` | Makes this the default class for its faction. |
| `isWhitelisted` | `boolean` | Makes players need to be whitelisted before they can join this class. |
| `color` | `Color` | Optional color used for this class in menus and the scoreboard. |
| `logo` | `string` | A material path or web URL used for this class's logo in menus and the scoreboard. |
| [`model`](#model-models-field) | `string` | Sets one static model for this class. This fixed model is always applied. |
| [`models`](#model-models-field) | `table` | Sets a list of model options that can be used by this class. |
| `skin` | `number` | Default skin number used for this class. |
| [`bodyGroups`](#bodygroups-field) | `table` | Default bodygroup setup for this class. |
| [`bodygroups`](#bodygroups-field) | `table` | Lowercase version of `bodyGroups`. It works the same way. |
| [`subMaterials`](#submaterials-field) | `table` | Default material overrides used by this class's preview model. |
| `health` | `number` | Health this class spawns with. |
| `armor` | `number` | Armor this class spawns with. |
| `weapons` | `string` or `table` | Weapons this class receives on spawn. |
| `scale` | `number` | Changes the size of characters in this class. |
| `runSpeed` | `number` | Changes run speed. `1` means normal speed. |
| `walkSpeed` | `number` | Changes walk speed. `1` means normal speed. |
| `jumpPower` | `number` | Changes jump height. `1` means normal jump power. |
| `bloodcolor` | `number` | Changes the blood color used by this class. |
| `NPCRelations` | `table` | Changes how NPCs react to this class. |
| `pay` | `number` | How much this class gets paid each paycheck. This overrides the faction's pay if both are set. |
| `payTimer` | `number` | How often this class gets paid. This overrides the faction's `payTimer` if both are set. |
| `scoreboardHidden` | `boolean` | Hides this class from class sections on the scoreboard. |
| `commands` | `table` | Command names members of this class are allowed to use. |
| `canInviteToFaction` | `boolean` | Lets members of this class invite players to the faction. |
| `canInviteToClass` | `boolean` | Lets members of this class invite players to classes. |

## Callback Fields

| Callback | Purpose |
| --- | --- |
| `OnCanBe(client)` | Runs when a player tries to join this class. Return `true` to allow or `false` to deny. |
| `OnSet(client)` | Runs when a player joins this class. |
| `OnTransferred(client, oldClass)` | Runs when a player switches from another class into this one. |
| `OnLeave(client)` | Runs when a player leaves this class. |
| `OnSpawn(client)` | Runs after the class's normal spawn values have been applied. |

## Field Notes

### <a id="model-models-field"></a>`model` and `models`

Lilia supports both `model` and `models`, but they are not the same thing.

- Use `model` for one static model path. This is the fixed class model that gets applied directly.
- Use `models` for a list of model options. This is the class's selectable model pool.

If you want a class to always use one exact model, set `model`.

If you want a class to offer multiple possible models, set `models`.

Examples:

```lua
CLASS.model = "models/player/police.mdl"
```

```lua
CLASS.models = {
    "models/player/police.mdl",
    "models/player/police_fem.mdl"
}
```

### <a id="bodygroups-field"></a>`bodyGroups` and `bodygroups`

Both field names are accepted. Use whichever one fits your file style best.

Examples:

```lua
CLASS.bodyGroups = {
    [1] = 2,
    [2] = 1
}
```

```lua
CLASS.bodygroups = {
    helmet = 1
}
```

### <a id="submaterials-field"></a>`subMaterials`

This is mainly used by the class preview model in menus. Each slot matches a submaterial slot on the model.

```lua
CLASS.subMaterials = {
    [1] = "models/debug/debugwhite"
}
```

## Normal Class File Example

This example uses `models`, which gives the class a list of available model options:

This example matches a typical class definition file loaded from a schema's classes directory:

```lua
CLASS.name = "Police Officer"
CLASS.desc = "A frontline law enforcement officer."
CLASS.faction = FACTION_POLICE
CLASS.limit = 6
CLASS.isWhitelisted = true
CLASS.color = Color(45, 105, 215)
CLASS.models = {
    "models/player/police.mdl",
    "models/player/police_fem.mdl"
}
CLASS.skin = 0
CLASS.bodyGroups = {
    [1] = 1
}
CLASS.logo = "materials/ui/class/police.png"
CLASS.health = 125
CLASS.armor = 50
CLASS.weapons = {"weapon_pistol", "weapon_stunstick"}
CLASS.pay = 100
CLASS.payTimer = 180
CLASS.scoreboardHidden = false
CLASS.canInviteToFaction = true
CLASS.canInviteToClass = true

function CLASS:OnCanBe(client)
    return client:getChar() ~= nil
end

function CLASS:OnSet(client)
    client:notify("You joined the Police Officer class.")
end

function CLASS:OnLeave(client)
    client:notify("You left the Police Officer class.")
end
```

## Direct Registration Example

This example uses `model`, which keeps the class on one fixed model:

Use `lia.class.register` when you want to define and register a class in one place instead of relying on the loader's shared `CLASS` table:

```lua
CLASS_POLICEOFFICER = lia.class.register("policeofficer", {
    name = "Police Officer",
    desc = "A frontline law enforcement officer.",
    faction = FACTION_POLICE,
    limit = 6,
    isWhitelisted = true,
    color = Color(45, 105, 215),
    model = "models/player/police.mdl",
    skin = 0,
    bodyGroups = {
        [1] = 1
    },
    weapons = {"weapon_pistol", "weapon_stunstick"},
    pay = 100,
    payTimer = 180,
    OnCanBe = function(self, client)
        return client:getChar() ~= nil
    end,
    OnSet = function(self, client)
        client:notify("You joined the Police Officer class.")
    end
})
```
