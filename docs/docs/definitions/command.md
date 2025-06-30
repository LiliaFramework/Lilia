# Command Fields


This document describes all configurable fields accepted by `lia.command.add`. Use these to define command behavior, permissions, help text, and admin utility integration.

All fields are optional unless noted otherwise.


---


## Overview


When you register a command with `lia.command.add`, you provide a table of fields that control its names, who can run it, how it appears in help menus or admin utilities, and what code runs when it’s invoked. All fields are optional unless noted otherwise.


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

| `onRun(client, args)` | `function(client, table)` | `nil` | Function executed when the command is invoked. |


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


* `Name` (string): Display text.

* `Category` (string): Top-level grouping.

* `SubCategory` (string): Secondary grouping.

* `Icon` (string): 16×16 icon path.


**Example Usage:**


```lua
AdminStick = {
    Name        = "Set Character Skin",
    Category    = "Player Information",
    SubCategory = "Set Attributes",
    Icon        = "icon16/user_gray.png"
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
