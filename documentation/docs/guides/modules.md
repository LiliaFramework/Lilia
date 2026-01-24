# Modules

Modules are plugins that add new features to your server. They are self-contained systems that extend Lilia's functionality with specific features like inventory management, chat systems, or gameplay mechanics.

## Installing Modules

### From the Repository

1. Browse the modules at [Lilia Modules Documentation](https://liliaframework.github.io/modules/)
2. Find the module you want and click on it to go to its "About" page
3. Click the "DOWNLOAD HERE" link to download the specific module ZIP
4. Extract the ZIP file
5. Upload the module folder to `garrysmod/gamemodes/YOUR_SCHEMA/modules/`
6. Restart your server

### Manual Installation

1. Create a new folder in `garrysmod/gamemodes/YOUR_SCHEMA/modules/`
2. Create the required files for your module (see Creating Modules below)
3. Restart your server

## Creating Modules

To create a module for your schema, create a new folder in your gamemode's `modules` folder. Each module should have its own folder.

When creating a module, you need at least a `module.lua` file. This file contains the MODULE table that defines your module.

```lua
MODULE.name = "My Custom Module"
MODULE.author = "Your Name"
MODULE.desc = "A description of what this module does"
MODULE.uniqueID = "my_custom_module"
```

### Module Structure

```
modules/
└── my_module/
    ├── module.lua          # Main module definition
    ├── libraries/          # Optional libraries
    │   ├── client.lua
    │   └── server.lua
    ├── derma/             # Optional UI elements
    ├── entities/          # Optional entities
    ├── items/             # Optional items
    └── languages/         # Optional translations
```

### Module Properties

| Property | Purpose | Example |
|----------|---------|---------|
| `name` | Display name | `"Inventory System"` |
| `author` | Module author | `"Samael"` |
| `desc` | Description | `"Advanced inventory management"` |
| `uniqueID` | Unique identifier | `"inventory_system"` |
| `version` | Version string | `"1.0.0"` |
| `enabled` | Enable/disable | `true` |

### Dependencies and Privileges

Modules can specify dependencies and required privileges:

```lua
MODULE.dependencies = {
    "another_module",
    "required_system"
}

MODULE.Privileges = {
    "CanUseModule",
    "AdminAccess"
}
```

### Network Strings

If your module needs network communication:

```lua
MODULE.NetworkStrings = {
    "MyModuleData",
    "ModuleUpdate"
}
```

### Module Lifecycle

Modules have several lifecycle hooks:

```lua
function MODULE:ModuleLoaded()
    -- Called when the module is loaded
    print("My module has been loaded!")
end

function MODULE:OnReloaded()
    -- Called when the module is reloaded
end

function MODULE:OnLoad()
    -- Called during module initialization
end

function MODULE:OnUnload()
    -- Called when the module is unloaded
end
```

## Module Libraries

Modules can include their own libraries that extend Lilia's functionality:

```lua
-- modules/my_module/libraries/shared.lua
function MODULE:MyFunction()
    return "Hello from my module!"
end
```

## Module Items

Modules can define their own items:

```lua
-- modules/my_module/items/special_item.lua
ITEM.name = "Special Item"
ITEM.desc = "An item from my module"
ITEM.category = "Special"
ITEM.model = "models/item.mdl"
```

## Module Configuration

Modules can have configuration options:

```lua
-- In module.lua
MODULE.ConfigEnabled = lia.config.add("MyModuleEnabled", true, "Enable my custom module", nil, {
    category = "My Module"
})

MODULE.ConfigValue = lia.config.add("MyModuleValue", 100, "Some value for my module", nil, {
    category = "My Module",
    min = 0,
    max = 1000
})
```

## Module Hooks

Modules can add their own hooks:

```lua
-- In module.lua
function MODULE:PlayerSpawn(client)
    -- Custom spawn logic
end

function MODULE:PlayerDeath(client)
    -- Custom death logic
end
```

## Module Commands

Modules can register chat commands:

```lua
lia.command.add("mycommand", {
    description = "A command from my module",
    adminOnly = false,
    onRun = function(client, arguments)
        -- Command logic here
    end
})
```

## Best Practices

### Module Organization
- Keep module-specific code within the module folder
- Use clear, descriptive names for files and functions
- Document your module with comments

### Performance
- Avoid running expensive operations in frequently called hooks
- Use caching where appropriate
- Clean up timers and hooks when the module unloads

### Compatibility
- Check for existing modules that might conflict
- Use unique identifiers to avoid naming conflicts
- Follow Lilia's coding conventions

### Error Handling
- Add proper error checking in your code
- Use pcall for potentially failing operations
- Log errors appropriately

## Module Development

When developing modules:

1. **Start Simple**: Begin with basic functionality
2. **Test Thoroughly**: Test on a development server
3. **Document**: Add comments and documentation
4. **Version Control**: Use Git for version control
5. **Share**: Consider sharing your module with the community

## Example Module

Here's a simple example module that adds a custom command:

```lua
-- modules/example/module.lua
MODULE.name = "Example Module"
MODULE.author = "Developer"
MODULE.desc = "A simple example module"
MODULE.uniqueID = "example_module"

function MODULE:OnLoad()
    lia.command.add("hello", {
        description = "Say hello",
        onRun = function(client)
            client:notify("Hello from the example module!")
        end
    })
end
```

For more module options, see the [Module Guide](../definitions/module.md).