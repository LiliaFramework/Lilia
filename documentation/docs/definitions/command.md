# Command Fields

This document describes the table passed to `lia.command.add`.  Each key in the

table customizes how the command behaves, who can run it and how it appears in

admin utilities.

All fields are optional unless noted otherwise.

---

## Overview

When you register a command with `lia.command.add`, you provide a table of

fields controlling its name, permissions and execution.  Except for

`onRun`, every field is optional.

The command name itself is the first argument to `lia.command.add` and is stored in lowercase.

---

## Field Summary

| Field | Type | Default | Description |
|---|---|---|---|
| `alias` | `string` or `table` | `nil` | Alternative names for the command. |
| `adminOnly` | `boolean` | `false` | Restrict to admins (registers a CAMI privilege). |
| `superAdminOnly` | `boolean` | `false` | Restrict to superadmins (registers a CAMI privilege). |
| `privilege` | `string` | `nil` | Custom CAMI privilege name (defaults to command name). |
| `syntax` | `string` | `""` | Human-readable argument format shown in help. |
| `desc` | `string` | `""` | Short description shown in command lists and menus. |
| `AdminStick` | `table` | `nil` | Defines how the command appears in admin utilities. |
| `onRun(client, args)` | `function(client, table)` | **required** | Function executed when the command is invoked. |

---

## Field Details

### Aliases & Permissions

#### `alias`

**Type:**

`string` or `table`

**Description:**

One or more alternative command names that trigger the same behavior.

Aliases are automatically lower-cased and behave exactly like the main command name.

**Example Usage:**

```lua
-- as a single string
alias = "chargiveflag"

-- or multiple aliases
alias = {"chargiveflag", "giveflag"}
```

---

#### `adminOnly`

**Type:**

`boolean`

**Description:**

If `true`, only players with the generated CAMI privilege may run the command. The privilege name is automatically registered as `Commands - <privilege>`.

**Example Usage:**

```lua
adminOnly = true
```

---

#### `superAdminOnly`

**Type:**

`boolean`

**Description:**

If `true`, only superadmins with the automatically registered privilege `Commands - <privilege>` can use the command.

**Example Usage:**

```lua
superAdminOnly = true
```

---

#### `privilege`

**Type:**

`string`

**Description:**

Custom CAMI privilege name checked when running the command. If omitted, `adminOnly` or `superAdminOnly` register `Commands - <command name>`.

**Example Usage:**

```lua
privilege = "Manage Doors"
```

---

### Syntax & Description

#### `syntax`

**Type:**

`string`

**Description:**

Human-readable syntax string shown in help menus. Does not affect argument parsing.

You can use spaces in argument names for better readability.

The in-game prompt only appears when every argument follows the `[type Name]` format.

**Example Usage:**

```lua
syntax = "[string Target Name] [number Amount]"
```

Include the word `optional` inside the brackets to make an argument optional:

```lua
syntax = "[string Target Name] [number Amount optional]"
```

---

#### `desc`

**Type:**

`string`

**Description:**

Short description of what the command does, displayed in command lists and menus.

**Example Usage:**

```lua
desc = "Purchase a door if it is available and you can afford it."
```

---

### AdminStick Integration

#### `AdminStick`

**Type:**

`table`

**Description:**

Defines how the command appears in admin utility menus. Common keys:

All keys are optional; if omitted the command simply will not appear in the Admin Stick menu.

* `Name` (string) – Text shown on the menu button.

* `Category` (string) – Top-level grouping.

* `SubCategory` (string) – Secondary grouping under the main category.

* `Icon` (string) – 16×16 icon path.

* `TargetClass` (string) – Limit the command to a specific entity class when using the Admin Stick.

**Example Usage:**

```lua
AdminStick = {
    Name        = "Restock Vendor",
    Category    = "Vendors",
    SubCategory = "Management",
    Icon        = "icon16/box.png",
    TargetClass = "lia_vendor"
}
```

---

### Execution Hook

#### `onRun`

**Type:**

`function(client, table)`

**Description:**

Function called when the command is executed. `args` is a table of parsed arguments. Return a string to send a message back to the caller, or return nothing for silent execution.

Strings starting with `@` are interpreted as localization keys for `notifyLocalized`.

**Example Usage:**

```lua
onRun = function(client, arguments)
    local target = lia.util.findPlayer(client, arguments[1])
    if target then
        target:Kill()
    end
end
```

---

### Full Command Example

```lua
lia.command.add("restockvendor", {
    superAdminOnly = true,                -- restrict to super administrators
    privilege = "Manage Vendors",        -- custom privilege checked before run
    desc = "Restock the vendor you are looking at.", -- shown in command lists
    syntax = "[player Target]",          -- help text describing the argument
    alias = {"vendorrestock"},           -- other names that trigger the command
    AdminStick = {
        Name        = "Restock Vendor",  -- text on the Admin Stick button
        Category    = "Vendors",        -- top-level category
        SubCategory = "Management",     -- subcategory in the menu
        Icon        = "icon16/box.png",  -- icon displayed next to the entry
        TargetClass = "lia_vendor"       -- only usable when aiming at this class
    },
    onRun = function(client, args)
        -- grab the entity the admin is looking at
        local vendor = client:getTracedEntity()
        if IsValid(vendor) and vendor:GetClass() == "lia_vendor" then
            -- reset all purchasable item stock counts
            for id, itemData in pairs(vendor.items) do
                if itemData[2] and itemData[4] then
                    vendor.items[id][2] = itemData[4]
                end
            end
            client:notifyLocalized("vendorRestocked")
        else
            client:notifyLocalized("NotLookingAtValidVendor")
        end
    end
})
```

---

```lua
lia.command.add("goto", {
    adminOnly = true,                    -- only admins may run this command
    syntax = "[player Target]",         -- how the argument appears in help menus
    desc = "Teleport to the specified player.", -- short description
    onRun = function(client, args)
        -- look up the target player from the first argument
        local target = lia.util.findPlayer(client, args[1])
        if not target then
            return "@targetNotFound"     -- localization key sent when player missing
        end
        client:SetPos(target:GetPos())   -- move to the target's position
    end
})
```
