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

If `true`, only players with the registered CAMI admin privilege (automatically created) may run the command.

**Example Usage:**

```lua
adminOnly = true
```

---

#### `superAdminOnly`

**Type:**

`boolean`

**Description:**

If `true`, restricts usage to super administrators (automatically registers a CAMI privilege).

**Example Usage:**

```lua
superAdminOnly = true
```

---

#### `privilege`

**Type:**

`string`

**Description:**

Custom CAMI privilege name checked when running the command. Defaults to the command’s primary name if omitted.
This field is normally used alongside `adminOnly` or `superAdminOnly` to
register a privilege with a custom name.

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

#### `onRun(client, args)`

**Type:**

`function(client, table)`

**Description:**

Function called when the command is executed. `args` is a table of parsed arguments. Return a string to send a message back to the caller, or return nothing for silent execution.

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
    superAdminOnly = true,
    privilege = "Manage Vendors",
    desc = "Restock the vendor you are looking at.",
    syntax = "[player Target]",
    alias = {"vendorrestock"},
    AdminStick = {
        Name        = "Restock Vendor",
        Category    = "Vendors",
        SubCategory = "Management",
        Icon        = "icon16/box.png",
        TargetClass = "lia_vendor"
    },
    onRun = function(client, args)
        local vendor = client:getTracedEntity()
        if IsValid(vendor) and vendor:GetClass() == "lia_vendor" then
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
