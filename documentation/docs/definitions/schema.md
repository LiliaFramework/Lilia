# Schema Definitions

`SCHEMA` is the active schema table that Lilia prepares while loading `schema/schema.lua`. It behaves like the schema-level version of `MODULE`: it carries metadata about the current gamemode, exposes lifecycle callbacks as hooks, and gives schema code a stable place to store shared runtime data.

The loader creates `SCHEMA` before including your schema core file, then continues loading schema folders such as `schema/definitions`, `schema/libraries`, `schema/hooks`, `schema/items`, and related content.

## Placement

Define schema metadata in:

```text
garrysmod/gamemodes/[schema folder]/schema/schema.lua
```

Use the global `SCHEMA` table directly in that file.

## Reference

| Field | Type | Purpose |
| --- | --- | --- |
| `name` | `string` | Display name for the schema. It is used in UI, server description helpers, and loader output. |
| `desc` | `string` | Human-readable schema description. The loader seeds this with the default no-description token until you override it. |
| `author` | `string` | Author metadata for the schema. |
| `icon` | `string` | Optional material path used by menu and scoreboard UI for schema branding. |
| `changelog` | `string` or `table` | Optional changelog data shown by the main menu changelog panel. |

## Common Fields

### `name`

Set `name` to the friendly title players should see in menus and server-facing UI.

```lua
SCHEMA.name = "Mojave Reborn"
```

### `icon`

`icon` should point at a material path that the UI can load for places like the F1 menu and scoreboard.

```lua
SCHEMA.icon = "materials/mymod/schema_logo.png"
```

### `changelog`

Use `changelog` when you want the main menu to show update notes for the schema. It supports a plain multiline string, a simple list of strings, and structured release entries.

Simple list:

```lua
SCHEMA.changelog = {
    "Added a new wasteland outpost",
    "Rebalanced starter equipment",
    "Improved faction spawn flow"
}
```

Multiline string:

```lua
SCHEMA.changelog = [[
- Added a new wasteland outpost
- Rebalanced starter equipment
- Improved faction spawn flow
]]
```

Structured releases:

```lua
SCHEMA.changelog = {
    {
        version = "1.2.0",
        date = "2026-07-11",
        changes = {
            "Added a new outpost",
            "Improved faction spawn flow"
        }
    },
    {
        title = "Hotfix",
        changes = "[Fixed] Resolved a startup error for new characters"
    }
}
```

Keyed versions also work:

```lua
SCHEMA.changelog = {
    ["1.2.0"] = {
        date = "2026-07-11",
        changes = {
            "Added a new outpost",
            "Improved faction spawn flow"
        }
    },
    ["1.1.5"] = {
        "Fixed inventory sync",
        "Adjusted starter loadout"
    }
}
```

## Lifecycle Callbacks

Because schema loading runs through the module loader, schema functions are attached as hooks after loading finishes. That means schema files can define the same kind of callback-style functions that modules use.

```lua
function SCHEMA:InitializedConfig()
    print(self.name .. " finished config initialization")
end
```

## Example

```lua
SCHEMA.name = "A Lilia Schema"
SCHEMA.author = "Lilia Team"
SCHEMA.desc = "A roleplay gamemode."
SCHEMA.icon = "materials/mymod/schema_logo.png"

SCHEMA.changelog = {
    {
        version = "1.0.0",
        date = "2026-07-11",
        changes = {
            "Added a new ranger checkpoint",
            "Updated early-game jobs",
            "Improved starter item balance"
        }
    }
}

function SCHEMA:InitializedSchema()
    print(self.name .. " schema loaded")
end
```
