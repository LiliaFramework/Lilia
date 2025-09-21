# Configuration & Modules

This page documents the hooks for configuration management, module initialization, and system events in the Lilia framework.

---

## Overview

The configuration and modules system forms the backbone of Lilia's framework architecture, providing comprehensive control over game settings, module management, system initialization, and framework lifecycle events. These hooks enable developers to customize every aspect of the framework's behavior, from basic configuration management to complex module loading and system integration.

The configuration and modules system in Lilia is built around a sophisticated architecture that supports dynamic configuration, modular design, and extensive customization capabilities. The hooks cover several critical areas:

**Configuration Management**: Hooks like `CanPlayerModifyConfig`, `ConfigChanged`, and `InitializedConfig` provide complete control over the configuration system, allowing for custom permission checks, real-time configuration updates, and validation mechanisms. The system supports various data types and includes automatic synchronization between server and client.

**Module System Architecture**: The modular architecture is managed through hooks such as `DoModuleIncludes`, `InitializedModules`, and `LiliaLoaded`, enabling dynamic loading, dependency resolution, and custom module behavior. Modules can be enabled or disabled without affecting the core framework, and they can depend on other modules to create complex feature hierarchies.

**System Initialization Lifecycle**: Multiple initialization hooks (`PreLiliaLoaded`, `InitializedItems`, `InitializedOptions`, `InitializedSchema`, `InitializedKeybinds`) fire at different stages of the loading process, allowing developers to set up custom functionality at the most appropriate time, whether it's before the framework loads, during module initialization, or after everything is ready.

**Option and Setting Management**: Client-side options and settings are handled through `liaOptionChanged`, `liaOptionReceived`, and `SetupQuickMenu` hooks, providing a robust system for managing user preferences, UI customization, and client-server synchronization of settings.

**Web Resource Management**: Hooks like `WebImageDownloaded` and `WebSoundDownloaded` enable dynamic content management, allowing servers to download and manage remote resources such as images, sounds, and other media files for use in the gamemode.

**Discord Integration**: The system includes comprehensive Discord integration through `DiscordRelaySend`, `DiscordRelayed`, and `DiscordRelayUnavailable` hooks, enabling real-time communication between the game server and Discord channels for logging, notifications, and community management.

**User Interface Customization**: Menu and UI customization hooks such as `CreateMenuButtons`, `DrawLiliaModelView`, `GetMainMenuPosition`, and various F1 menu hooks provide extensive control over the user interface, enabling developers to create unique and immersive UI experiences.

**Command and Event System**: Command registration and execution are managed through `liaCommandAdded` and `liaCommandRan` hooks, while various system events provide comprehensive logging, monitoring, and response capabilities for administrative and debugging purposes.

**Character and Player Management**: Hooks for character creation, attribute management, faction systems, and player permissions provide extensive control over character-related functionality, enabling complex roleplay systems and player progression mechanics.

**Localization and Internationalization**: The system includes hooks for language management (`OnLocalizationLoaded`), font handling (`RefreshFonts`), and UI skin management (`DermaSkinChanged`), supporting multi-language gamemodes and customizable visual themes.

This comprehensive hook system ensures that developers have complete control over every aspect of the Lilia framework, from low-level configuration management to high-level user interface customization, enabling the creation of sophisticated and unique roleplay gamemodes.

---

### CanPlayerModifyConfig

**Purpose**

Determines if a player can modify configuration settings.

**When Called**

This hook is triggered when:
- A player attempts to modify configuration settings
- Configuration changes are being validated
- Before configuration modifications are applied
- During configuration permission checks

**Parameters**

* `client` (*Player*): Player attempting to modify config.

**Returns**

* `canModify` (*boolean*): False to prevent modification, true to allow.

**Realm**

**Server**

**Example Usage**

```lua
-- This example demonstrates how to control who can modify configuration settings.
-- Configuration settings control various aspects of the gamemode's behavior.
-- This hook allows you to implement custom permission systems for config modification.

-- Restrict config modification to admins only
hook.Add("CanPlayerModifyConfig", "ConfigRestrict", function(client)
    -- Only allow admins to modify configuration
    return client:IsAdmin()
end)

-- Allow specific usergroups to modify config
hook.Add("CanPlayerModifyConfig", "UsergroupConfig", function(client)
    -- Allow admins and moderators to modify config
    return client:IsAdmin() or client:IsUserGroup("moderator")
end)

-- Check for specific permission
hook.Add("CanPlayerModifyConfig", "PermissionCheck", function(client)
    -- Check if player has specific config permission
    return lia.administrator.hasAccess(client, "modifyConfig")
end)
```

---

### ConfigChanged

**Purpose**

Fires when configuration is changed and allows you to respond to configuration updates.

**When Called**

This hook is triggered when:
- A configuration value is modified
- Configuration changes are being processed
- After configuration validation and processing
- During configuration updates

**Parameters**

* `key` (*string*): Configuration key that changed.
* `oldValue` (*any*): Previous value before the change.
* `newValue` (*any*): New value after the change.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Shared**

**Example Usage**

```lua
-- This example demonstrates how to respond when configuration settings are changed.
-- Configuration changes can affect various aspects of the gamemode's behavior.
-- This hook is useful for logging changes, updating server settings, and notifying players.

-- Log all configuration changes
hook.Add("ConfigChanged", "ConfigLog", function(key, oldValue, newValue)
    -- Log configuration changes to console
    print("Config updated:", key, "from", oldValue, "to", newValue)
end)

-- Handle specific configuration changes
hook.Add("ConfigChanged", "HandleSpecificConfig", function(key, oldValue, newValue)
    -- Handle specific configuration changes
    if key == "maxPlayers" then
        -- Update server settings when max players changes
        game.SetMaxPlayers(newValue)
        print("Max players updated to:", newValue)
    elseif key == "serverName" then
        -- Update server name when it changes
        RunConsoleCommand("hostname", newValue)
        print("Server name updated to:", newValue)
    end
end)

-- Notify players of important config changes
hook.Add("ConfigChanged", "NotifyPlayers", function(key, oldValue, newValue)
    -- Notify all players of important configuration changes
    if key == "serverRules" then
        for _, ply in pairs(player.GetAll()) do
            ply:ChatPrint("Server rules have been updated!")
        end
    end
end)
```

---

### InitializedConfig

**Purpose**

Fires when configuration is initialized and ready for use.

**When Called**

This hook is triggered when:
- The configuration system is being initialized
- Configuration data is being loaded from files
- After configuration validation and processing
- During system startup

**Parameters**

* `nil` (*nil*): This function does not return a value.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Shared**

**Example Usage**

```lua
-- This example demonstrates how to respond when configuration is initialized and ready for use.
-- Configuration initialization happens early in the framework loading process.
-- This hook is useful for setting up custom configuration options and validating settings.

-- Log when configuration is initialized
hook.Add("InitializedConfig", "PostConfigInit", function()
    -- Configuration is now available for use
    print("Configuration initialized")
end)

-- Set up custom configuration after initialization
hook.Add("InitializedConfig", "SetupCustomConfig", function()
    -- Add custom configuration options
    lia.config.add("customSetting", "defaultValue", "Custom setting description")
    print("Custom configuration added")
end)

-- Validate configuration after initialization
hook.Add("InitializedConfig", "ValidateConfig", function()
    -- Check if required configuration values are set
    if not lia.config.get("serverName") then
        print("Warning: Server name not configured!")
    end
end)
```

---

### InitializedItems

**Purpose**

Called when items are initialized and ready for use.

**When Called**

This hook is triggered when:
- The item system is being initialized
- Item data is being loaded and processed
- After item validation and registration
- During system startup

**Parameters**

* `nil` (*nil*): This function does not return a value.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Shared**

**Example Usage**

```lua
-- This example demonstrates how to respond when items are initialized and ready for use.
-- Items are the basic building blocks of the inventory system.
-- This hook is useful for setting up custom item properties and validating item configuration.

-- Log when items are initialized
hook.Add("InitializedItems", "PostItemInit", function()
    -- Items are now available for use
    print("Items initialized")
end)

-- Set up custom item data after initialization
hook.Add("InitializedItems", "SetupCustomItems", function()
    -- Add custom item properties or modify existing ones
    for uniqueID, item in pairs(lia.item.list) do
        if item.category == "weapons" then
            -- Add custom weapon properties
            item.customProperty = "customValue"
        end
    end
    print("Custom item properties added")
end)

-- Validate item configuration
hook.Add("InitializedItems", "ValidateItems", function()
    -- Check if all required items are properly configured
    local requiredItems = {"item_weapon", "item_ammo"}
    for _, itemID in pairs(requiredItems) do
        if not lia.item.list[itemID] then
            print("Warning: Required item", itemID, "not found!")
        end
    end
end)
```

---

### InitializedModules

**Purpose**

Fires when modules are initialized and ready for use.

**When Called**

This hook is triggered when:
- The module system is being initialized
- Modules are being loaded and processed
- After module validation and registration
- During system startup

**Parameters**

* `nil` (*nil*): This function does not return a value.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Shared**

**Example Usage**

```lua
-- This example demonstrates how to respond when modules are initialized and ready for use.
-- Modules provide additional functionality to the framework.
-- This hook is useful for setting up module dependencies and initializing custom features.

-- Log when modules are initialized
hook.Add("InitializedModules", "PostModuleInit", function()
    -- Modules are now available for use
    print("Modules initialized")
end)

-- Set up module dependencies after initialization
hook.Add("InitializedModules", "SetupModuleDeps", function()
    -- Check if required modules are loaded
    if lia.module.get("inventory") then
        print("Inventory module loaded successfully")
    else
        print("Warning: Inventory module not found!")
    end
end)

-- Initialize custom module features
hook.Add("InitializedModules", "InitCustomFeatures", function()
    -- Set up custom features that depend on modules
    if lia.module.get("chatbox") then
        -- Add custom chat commands
        lia.command.add("customcmd", "Custom command", function(client, arguments)
            client:ChatPrint("Custom command executed!")
        end)
    end
end)
```

---

### InitializedOptions

**Purpose**

Called when options are initialized and ready for use.

**When Called**

This hook is triggered when:
- The options system is being initialized
- Option data is being loaded and processed
- After option validation and registration
- During system startup

**Parameters**

* `nil` (*nil*): This function does not return a value.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Shared**

**Example Usage**

```lua
-- Log when options are initialized
hook.Add("InitializedOptions", "PostOptionInit", function()
    -- Options are now available for use
    print("Options initialized")
end)

-- Set up custom options after initialization
hook.Add("InitializedOptions", "SetupCustomOptions", function()
    -- Add custom client options
    lia.option.add("customOption", "defaultValue", "Custom option description")
    print("Custom options added")
end)

-- Validate option configuration
hook.Add("InitializedOptions", "ValidateOptions", function()
    -- Check if critical options are properly set
    if not lia.option.get("language") then
        print("Warning: Language option not set!")
    end
end)
```

---

### InitializedSchema

**Purpose**

Fires when schema is initialized and ready for use.

**When Called**

This hook is triggered when:
- The schema system is being initialized
- Schema data is being loaded and processed
- After schema validation and registration
- During system startup

**Parameters**

* `nil` (*nil*): This function does not return a value.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Shared**

**Example Usage**

```lua
-- Log when schema is initialized
hook.Add("InitializedSchema", "PostSchemaInit", function()
    -- Schema is now available for use
    print("Schema initialized")
end)

-- Set up schema-specific features
hook.Add("InitializedSchema", "SetupSchemaFeatures", function()
    -- Initialize schema-specific functionality
    if SCHEMA then
        -- Set up custom schema data
        SCHEMA.customData = {}
        print("Schema features initialized")
    end
end)

-- Validate schema configuration
hook.Add("InitializedSchema", "ValidateSchema", function()
    -- Check if schema is properly configured
    if not SCHEMA or not SCHEMA.name then
        print("Warning: Schema not properly configured!")
    end
end)
```

---

### InitializedKeybinds

**Purpose**

Fires when keybinds are initialized and ready for use.

**When Called**

This hook is triggered when:
- The keybind system is being initialized
- Keybind data is being loaded and processed
- After keybind validation and registration
- During system startup

**Parameters**

* `nil` (*nil*): This function does not return a value.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Shared**

**Example Usage**

```lua
-- Log when keybinds are initialized
hook.Add("InitializedKeybinds", "PostKeybindInit", function()
    -- Keybinds are now available for use
    print("Keybinds initialized")
end)

-- Set up custom keybinds after initialization
hook.Add("InitializedKeybinds", "SetupCustomKeybinds", function()
    -- Add custom keybinds
    lia.keybind.add("customKey", "Custom Key", function(client)
        client:ChatPrint("Custom key pressed!")
    end)
    print("Custom keybinds added")
end)

-- Validate keybind configuration
hook.Add("InitializedKeybinds", "ValidateKeybinds", function()
    -- Check if essential keybinds are configured
    local essentialKeys = {"charMenu", "inventory"}
    for _, key in pairs(essentialKeys) do
        if not lia.keybind.list[key] then
            print("Warning: Essential keybind", key, "not found!")
        end
    end
end)
```

---

### DoModuleIncludes

**Purpose**

Called during module inclusion process to allow custom handling of module loading.

**When Called**

This hook is triggered when:
- A module is being included/loaded
- Module loading process is being executed
- Before module initialization
- During module inclusion

**Parameters**

* `moduleName` (*string*): Name of the module being included.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Shared**

**Example Usage**

```lua
-- Log module inclusion process
hook.Add("DoModuleIncludes", "LogIncludes", function(moduleName)
    -- Track which modules are being loaded
    print("Including module:", moduleName)
end)

-- Handle specific module loading
hook.Add("DoModuleIncludes", "HandleSpecificModules", function(moduleName)
    -- Add custom logic for specific modules
    if moduleName == "inventory" then
        print("Loading inventory module with custom settings...")
        -- Set up custom inventory settings
    elseif moduleName == "chatbox" then
        print("Loading chatbox module...")
        -- Set up custom chat settings
    end
end)

-- Validate module dependencies
hook.Add("DoModuleIncludes", "ValidateDependencies", function(moduleName)
    -- Check if required dependencies are available
    if moduleName == "banking" and not lia.module.get("inventory") then
        print("Warning: Banking module requires inventory module!")
    end
end)
```

---

### PreLiliaLoaded

**Purpose**

Runs before the Lilia framework finishes loading, allowing for pre-initialization setup.

**When Called**

This hook is triggered when:
- The Lilia framework is about to finish loading
- Pre-initialization setup is being performed
- Before the main framework initialization
- During system startup

**Parameters**

* `nil` (*nil*): This function does not return a value.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Shared**

**Example Usage**

```lua
-- Log Lilia loading process
hook.Add("PreLiliaLoaded", "PreInit", function()
    -- Lilia is about to finish loading
    print("Lilia is loading...")
end)

-- Set up pre-loading configuration
hook.Add("PreLiliaLoaded", "PreLoadSetup", function()
    -- Set up configuration before Lilia finishes loading
    lia.config.add("preloadSetting", "value", "Pre-load setting")
    print("Pre-loading configuration set up")
end)

-- Validate system requirements
hook.Add("PreLiliaLoaded", "ValidateRequirements", function()
    -- Check system requirements before Lilia finishes loading
    if not file.Exists("lua/lia/", "GAME") then
        print("Warning: Lilia core files not found!")
    end
end)
```

---

### LiliaLoaded

**Purpose**

Runs after the Lilia framework has finished loading, allowing for post-initialization setup.

**When Called**

This hook is triggered when:
- The Lilia framework has finished loading
- Post-initialization setup is being performed
- After the main framework initialization
- During system startup completion

**Parameters**

* `nil` (*nil*): This function does not return a value.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Shared**

**Example Usage**

```lua
-- Log successful Lilia loading
hook.Add("LiliaLoaded", "PostInit", function()
    -- Lilia has finished loading successfully
    print("Lilia has finished loading")
end)

-- Set up post-loading features
hook.Add("LiliaLoaded", "PostLoadSetup", function()
    -- Set up features that require Lilia to be fully loaded
    lia.command.add("test", "Test command", function(client, arguments)
        client:ChatPrint("Lilia is fully loaded!")
    end)
    print("Post-loading features set up")
end)

-- Initialize custom systems
hook.Add("LiliaLoaded", "InitCustomSystems", function()
    -- Initialize custom systems that depend on Lilia
    if lia.module.get("inventory") then
        -- Set up custom inventory features
        print("Custom inventory features initialized")
    end
end)
```

---

### liaOptionChanged

**Purpose**

Triggered whenever `lia.option.set` modifies an option value, allowing you to respond to option changes.

**When Called**

This hook is triggered when:
- An option value is modified using lia.option.set
- Option changes are being processed
- After option validation and processing
- During option updates

**Parameters**

* `key` (*string*): Option identifier that was changed.
* `oldValue` (*any*): Previous value before the change.
* `newValue` (*any*): New assigned value.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Shared**

**Example Usage**

```lua
-- Log all option changes
hook.Add("liaOptionChanged", "LogOptionChange", function(key, oldValue, newValue)
    -- Log option changes for debugging
    print(key .. " changed from " .. tostring(oldValue) .. " to " .. tostring(newValue))
end)

-- Handle specific option changes
hook.Add("liaOptionChanged", "HandleSpecificOptions", function(key, oldValue, newValue)
    -- Handle specific option changes
    if key == "language" then
        -- Reload language when it changes
        lia.localization.load(newValue)
        print("Language changed to:", newValue)
    elseif key == "thirdPersonEnabled" then
        -- Update third person view when option changes
        if CLIENT then
            LocalPlayer():SetThirdPerson(newValue)
        end
    end
end)

-- Validate option changes
hook.Add("liaOptionChanged", "ValidateOptions", function(key, oldValue, newValue)
    -- Validate option values
    if key == "maxHealth" and newValue < 1 then
        print("Warning: Max health cannot be less than 1!")
        -- Reset to old value
        lia.option.set(key, oldValue)
    end
end)
```

---

### liaOptionReceived

**Purpose**

Called when an option is received from the server, allowing you to handle server-sent option updates.

**When Called**

This hook is triggered when:
- An option is received from the server
- Server-sent option updates are being processed
- After option synchronization from server to client
- During option network transmission

**Parameters**

* `key` (*string*): Option key that was received.
* `value` (*any*): Option value from the server.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
-- Log received options
hook.Add("liaOptionReceived", "OptionLog", function(key, value)
    -- Log options received from server
    print("Option received:", key, "=", value)
end)

-- Handle specific received options
hook.Add("liaOptionReceived", "HandleReceivedOptions", function(key, value)
    -- Handle specific options received from server
    if key == "serverName" then
        -- Update server name display
        print("Server name updated to:", value)
    elseif key == "maxPlayers" then
        -- Update max players display
        print("Max players set to:", value)
    end
end)

-- Update UI when options are received
hook.Add("liaOptionReceived", "UpdateUI", function(key, value)
    -- Update UI elements when options are received
    if key == "theme" then
        -- Update theme when received from server
        UpdateTheme(value)
    end
end)
```

---

### WebImageDownloaded

**Purpose**

Triggered after a remote image finishes downloading to the data folder, allowing you to handle downloaded images.

**When Called**

This hook is triggered when:
- A remote image finishes downloading
- Image download is completed successfully
- After image validation and storage
- During web resource management

**Parameters**

* `name` (*string*): Saved file name including extension.
* `path` (*string*): Local `data/` path to the image.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
-- Log downloaded images
hook.Add("WebImageDownloaded", "ImageLog", function(name, path)
    -- Log when images are downloaded
    print("Image downloaded:", name, "at", path)
end)

-- Handle specific downloaded images
hook.Add("WebImageDownloaded", "HandleImages", function(name, path)
    -- Handle specific image downloads
    if string.find(name, "avatar") then
        -- Update avatar when downloaded
        UpdatePlayerAvatar(name, path)
        print("Avatar image downloaded:", name)
    elseif string.find(name, "logo") then
        -- Update logo when downloaded
        UpdateServerLogo(name, path)
        print("Logo image downloaded:", name)
    end
end)

-- Preload downloaded images
hook.Add("WebImageDownloaded", "PreloadImages", function(name, path)
    -- Preload the downloaded image
    local material = Material(path)
    if material and not material:IsError() then
        print("Image preloaded successfully:", name)
    else
        print("Failed to preload image:", name)
    end
end)
```

---

### WebSoundDownloaded

**Purpose**

Triggered after a remote sound file finishes downloading to the data folder, allowing you to handle downloaded sounds.

**When Called**

This hook is triggered when:
- A remote sound file finishes downloading
- Sound download is completed successfully
- After sound validation and storage
- During web resource management

**Parameters**

* `name` (*string*): Saved file name including extension.
* `path` (*string*): Local `data/` path to the sound file.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
-- Log downloaded sounds
hook.Add("WebSoundDownloaded", "SoundLog", function(name, path)
    -- Log when sounds are downloaded
    print("Sound downloaded:", name, "at", path)
end)

-- Handle specific downloaded sounds
hook.Add("WebSoundDownloaded", "HandleSounds", function(name, path)
    -- Handle specific sound downloads
    if string.find(name, "notification") then
        -- Update notification sound when downloaded
        UpdateNotificationSound(path)
        print("Notification sound downloaded:", name)
    elseif string.find(name, "music") then
        -- Update background music when downloaded
        UpdateBackgroundMusic(path)
        print("Background music downloaded:", name)
    end
end)

-- Preload downloaded sounds
hook.Add("WebSoundDownloaded", "PreloadSounds", function(name, path)
    -- Preload the downloaded sound
    if file.Exists(path, "DATA") then
        -- Sound file exists, can be used
        print("Sound file ready:", name)
    else
        print("Sound file not found:", name)
    end
end)
```

---

### DiscordRelaySend

**Purpose**

Called just before an embed is posted to the configured Discord webhook, allowing you to log or monitor Discord messages.

**When Called**

This hook is triggered when:
- A Discord embed is about to be sent to the webhook
- Discord relay is processing outgoing messages
- Before Discord message transmission
- During Discord integration operations

**Parameters**

* `embed` (*table*): The embed object that will be sent to Discord.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
-- Log Discord messages before sending
hook.Add("DiscordRelaySend", "PrintLog", function(embed)
    -- Log the embed being sent to Discord
    print("Sending to Discord:", embed.title or "Untitled")
    print("Description:", embed.description or "No description")
end)

-- Monitor specific Discord messages
hook.Add("DiscordRelaySend", "MonitorMessages", function(embed)
    -- Monitor specific types of messages
    if embed.title and string.find(embed.title, "Player") then
        print("Player-related message being sent to Discord")
    elseif embed.title and string.find(embed.title, "Admin") then
        print("Admin action being sent to Discord")
    end
end)

-- Validate Discord messages
hook.Add("DiscordRelaySend", "ValidateMessages", function(embed)
    -- Validate embed content before sending
    if not embed.title or embed.title == "" then
        print("Warning: Discord embed has no title!")
    end
    if not embed.description or embed.description == "" then
        print("Warning: Discord embed has no description!")
    end
end)
```

---

### DiscordRelayed

**Purpose**

Runs after an embed has been successfully sent through the webhook, allowing you to confirm successful delivery.

**Parameters**

* `embed` (*table*): The embed object that was sent to Discord.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
-- Log successful Discord relay
hook.Add("DiscordRelayed", "PrintRelayed", function(embed)
    -- Confirm successful delivery to Discord
    print("Successfully relayed to Discord:", embed.title or "Untitled")
end)

-- Track Discord message statistics
hook.Add("DiscordRelayed", "TrackStats", function(embed)
    -- Track statistics for Discord messages
    if not DiscordStats then
        DiscordStats = { totalMessages = 0, playerMessages = 0 }
    end
    
    DiscordStats.totalMessages = DiscordStats.totalMessages + 1
    
    if embed.title and string.find(embed.title, "Player") then
        DiscordStats.playerMessages = DiscordStats.playerMessages + 1
    end
    
    print("Discord stats - Total:", DiscordStats.totalMessages, "Player:", DiscordStats.playerMessages)
end)

-- Notify administrators of successful relay
hook.Add("DiscordRelayed", "NotifyAdmins", function(embed)
    -- Notify online admins of successful Discord relay
    for _, ply in pairs(player.GetAll()) do
        if ply:IsAdmin() then
            ply:ChatPrint("Message successfully sent to Discord: " .. (embed.title or "Untitled"))
        end
    end
end)
```

---

### DiscordRelayUnavailable

**Purpose**

Fires when the CHTTP binary module is missing and relaying cannot be performed, allowing you to handle the error.

**Parameters**

* `nil` (*nil*): This function does not return a value.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
-- Log Discord relay unavailability
hook.Add("DiscordRelayUnavailable", "NotifyMissing", function()
    -- Log when Discord relay is unavailable
    print("Discord relay module unavailable.")
end)

-- Notify administrators of Discord issues
hook.Add("DiscordRelayUnavailable", "NotifyAdmins", function()
    -- Notify online admins about Discord relay issues
    for _, ply in pairs(player.GetAll()) do
        if ply:IsAdmin() then
            ply:ChatPrint("Warning: Discord relay is unavailable!")
        end
    end
end)

-- Set up fallback logging
hook.Add("DiscordRelayUnavailable", "FallbackLogging", function()
    -- Set up fallback logging when Discord is unavailable
    print("Setting up fallback logging system...")
    -- Could implement file logging or other fallback methods here
end)
```

---

### CreateMenuButtons

**Purpose**

Executed during menu creation allowing you to define custom tabs and insert additional tabs into the F1 menu.

**When Called**

This hook is triggered when:
- The F1 menu is being created and initialized
- Menu tabs are being prepared for display
- Before the F1 menu is shown to players
- During F1 menu setup and preparation

**Parameters**

* `tabs` (*table*): Table to add menu definitions to.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
-- Add a custom help tab to the F1 menu
hook.Add("CreateMenuButtons", "AddHelpTab", function(tabs)
    -- Create a help tab with command list
    tabs.help = {
        text = "Help",
        panel = function()
            -- Create the help panel
            local pnl = vgui.Create("DPanel")
            pnl:Dock(FILL)
            
            -- Create label for commands
            local label = vgui.Create("DLabel", pnl)
            local commands = {}
            
            -- Collect all available commands
            for k in pairs(lia.command.list) do
                commands[#commands + 1] = k
            end
            
            -- Set command list text
            label:SetText(table.concat(commands, "\n"))
            label:Dock(FILL)
            label:SetFont("DermaDefault")
            
            return pnl
        end,
    }
end)

-- Add a custom settings tab
hook.Add("CreateMenuButtons", "AddSettingsTab", function(tabs)
    -- Create a settings tab
    tabs.settings = {
        text = "Settings",
        panel = function()
            -- Create settings panel
            local pnl = vgui.Create("DPanel")
            pnl:Dock(FILL)
            
            -- Add settings controls here
            local label = vgui.Create("DLabel", pnl)
            label:SetText("Custom Settings")
            label:Dock(TOP)
            label:SetFont("DermaDefault")
            
            return pnl
        end,
    }
end)

-- Add a custom information tab
hook.Add("CreateMenuButtons", "AddInfoTab", function(tabs)
    -- Create an information tab
    tabs.info = {
        text = "Info",
        panel = function()
            -- Create info panel
            local pnl = vgui.Create("DPanel")
            pnl:Dock(FILL)
            
            -- Add server information
            local label = vgui.Create("DLabel", pnl)
            label:SetText("Server Information\nPlayers: " .. #player.GetAll() .. "/" .. game.MaxPlayers())
            label:Dock(FILL)
            label:SetFont("DermaDefault")
            
            return pnl
        end,
    }
end)
```

---

### DrawLiliaModelView

**Purpose**

Runs every frame when the character model panel draws, allowing you to draw custom elements over the model view used in character menus.

**When Called**

This hook is triggered when:
- The character model panel is being drawn/rendered
- Character model view is being displayed in menus
- Every frame during character model rendering
- During character selection and creation interfaces

**Parameters**

* `panel` (*Panel*): The model panel being drawn.
* `entity` (*Entity*): Model entity displayed.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
-- Display character name over model view
hook.Add("DrawLiliaModelView", "ShowName", function(panel, entity)
    -- Get the local player's character
    local char = LocalPlayer():getChar()
    if not char then
        return
    end
    
    -- Draw character name with outline
    draw.SimpleTextOutlined(
        char:getName(),
        "Trebuchet24",
        panel:GetWide() / 2,
        8,
        color_white,
        TEXT_ALIGN_CENTER,
        TEXT_ALIGN_TOP,
        1,
        color_black
    )
end)

-- Display character information
hook.Add("DrawLiliaModelView", "ShowCharInfo", function(panel, entity)
    local char = LocalPlayer():getChar()
    if not char then
        return
    end
    
    -- Draw character level
    local level = char:getData("level", 1)
    draw.SimpleTextOutlined(
        "Level: " .. level,
        "DermaDefault",
        panel:GetWide() / 2,
        32,
        Color(255, 255, 0),
        TEXT_ALIGN_CENTER,
        TEXT_ALIGN_TOP,
        1,
        color_black
    )
    
    -- Draw character faction
    local faction = char:getFaction()
    if faction then
        draw.SimpleTextOutlined(
            "Faction: " .. faction,
            "DermaDefault",
            panel:GetWide() / 2,
            48,
            Color(0, 255, 255),
            TEXT_ALIGN_CENTER,
            TEXT_ALIGN_TOP,
            1,
            color_black
        )
    end
end)

-- Add custom effects to model view
hook.Add("DrawLiliaModelView", "CustomEffects", function(panel, entity)
    -- Draw a custom border around the model
    local x, y = panel:GetPos()
    local w, h = panel:GetSize()
    
    -- Draw border
    surface.SetDrawColor(255, 255, 255, 100)
    surface.DrawOutlinedRect(x, y, w, h)
    
    -- Draw corner decorations
    surface.SetDrawColor(255, 0, 0, 150)
    surface.DrawRect(x, y, 4, 4)
    surface.DrawRect(x + w - 4, y, 4, 4)
    surface.DrawRect(x, y + h - 4, 4, 4)
    surface.DrawRect(x + w - 4, y + h - 4, 4, 4)
end)
```

---

### GetMainMenuPosition

**Purpose**

Returns the camera position and angle for the main menu character preview, allowing you to customize the camera view.

**When Called**

This hook is triggered when:
- The main menu character preview is being set up
- Camera position is being determined for character display
- Before the character model is rendered in the main menu
- During main menu character preview initialization

**Parameters**

* `character` (*Character*): Character being viewed.

**Returns**

* `position` (*Vector*): Camera position for the character preview.
* `angle` (*Angle*): Camera angle for the character preview.

**Realm**

**Client**

**Example Usage**

```lua
-- Set custom camera position for character preview
hook.Add("GetMainMenuPosition", "OffsetCharView", function(character)
    -- Return custom position and angle
    return Vector(30, 10, 60), Angle(0, 30, 0)
end)

-- Different camera positions based on character faction
hook.Add("GetMainMenuPosition", "FactionBasedView", function(character)
    local faction = character:getFaction()
    
    -- Different camera positions for different factions
    if faction == "citizen" then
        return Vector(20, 5, 50), Angle(0, 0, 0)
    elseif faction == "police" then
        return Vector(40, 15, 70), Angle(0, 45, 0)
    elseif faction == "medic" then
        return Vector(25, 10, 55), Angle(0, -30, 0)
    else
        -- Default position
        return Vector(30, 10, 60), Angle(0, 30, 0)
    end
end)

-- Dynamic camera position based on character data
hook.Add("GetMainMenuPosition", "DynamicView", function(character)
    -- Get character data
    local level = character:getData("level", 1)
    local height = character:getData("height", 1)
    
    -- Adjust position based on character properties
    local basePos = Vector(30, 10, 60)
    local baseAng = Angle(0, 30, 0)
    
    -- Adjust height based on character height
    basePos.z = basePos.z + (height - 1) * 10
    
    -- Adjust distance based on level
    basePos.x = basePos.x + level * 2
    
    return basePos, baseAng
end)
```

---

### liaCommandAdded

**Purpose**

Fires when a new command is registered, allowing you to track and respond to command registration.

**When Called**

This hook is triggered when:
- A new command is registered in the system
- Command system processes command registration
- After command validation and processing
- During command system initialization

**Parameters**

* `command` (*table*): The command that was added.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Shared**

**Example Usage**

```lua
-- Log when commands are added
hook.Add("liaCommandAdded", "CommandLog", function(command)
    -- Log command registration
    print("Command added:", command.name)
end)

-- Track command statistics
hook.Add("liaCommandAdded", "CommandStats", function(command)
    -- Track command statistics
    if not CommandStats then
        CommandStats = { totalCommands = 0, adminCommands = 0 }
    end
    
    CommandStats.totalCommands = CommandStats.totalCommands + 1
    
    -- Count admin commands
    if command.adminOnly then
        CommandStats.adminCommands = CommandStats.adminCommands + 1
    end
    
    print("Command stats - Total:", CommandStats.totalCommands, "Admin:", CommandStats.adminCommands)
end)

-- Validate command registration
hook.Add("liaCommandAdded", "ValidateCommands", function(command)
    -- Validate command properties
    if not command.name or command.name == "" then
        print("Warning: Command added without name!")
    end
    
    if not command.callback or type(command.callback) ~= "function" then
        print("Warning: Command", command.name, "has no valid callback!")
    end
end)
```

---

### liaCommandRan

**Purpose**

Called when a command is executed, allowing you to track and respond to command usage.

**When Called**

This hook is triggered when:
- A player executes a command
- Command system processes command execution
- After command validation and processing
- During command execution

**Parameters**

* `client` (*Player*): Player who ran the command.
* `command` (*table*): Command that was run.
* `arguments` (*table*): Arguments passed to the command.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
-- Log command usage
hook.Add("liaCommandRan", "CommandUsageLog", function(client, command, arguments)
    -- Log command execution
    print(client:Nick(), "ran command:", command.name)
    if #arguments > 0 then
        print("Arguments:", table.concat(arguments, " "))
    end
end)

-- Track command usage statistics
hook.Add("liaCommandRan", "CommandUsageStats", function(client, command, arguments)
    -- Track command usage statistics
    if not CommandUsageStats then
        CommandUsageStats = {}
    end
    
    if not CommandUsageStats[command.name] then
        CommandUsageStats[command.name] = { count = 0, users = {} }
    end
    
    CommandUsageStats[command.name].count = CommandUsageStats[command.name].count + 1
    CommandUsageStats[command.name].users[client:SteamID()] = true
    
    print("Command", command.name, "used", CommandUsageStats[command.name].count, "times")
end)

-- Log admin command usage
hook.Add("liaCommandRan", "AdminCommandLog", function(client, command, arguments)
    -- Log admin command usage
    if command.adminOnly then
        print("Admin command used by", client:Nick(), ":", command.name)
        
        -- Log to file or database
        local logEntry = {
            timestamp = os.time(),
            admin = client:Nick(),
            command = command.name,
            arguments = arguments
        }
        
        -- Save to file
        file.Append("admin_commands.txt", util.TableToJSON(logEntry) .. "\n")
    end
end)
```

---

### SetupQuickMenu

**Purpose**

Fill the Quick Settings panel with options using the provided panel helpers, allowing you to add custom settings to the quick menu.

**When Called**

This hook is triggered when:
- The quick settings panel is being initialized
- Quick menu options are being prepared for display
- Before the quick settings menu is shown to players
- During quick settings panel setup

**Parameters**

* `panel` (*Panel*): The `liaQuick` panel. Use `addCategory`, `addButton`, `addSlider`, `addCheck`.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
-- Add basic quick settings
hook.Add("SetupQuickMenu", "QuickToggles", function(panel)
    -- Add general category
    panel:addCategory(L("categoryGeneral"))
    
    -- Add third person toggle
    panel:addCheck(L("thirdPerson"), function(_, v) 
        lia.option.set("thirdPersonEnabled", v) 
    end, lia.option.get("thirdPersonEnabled", false))
    
    -- Add language selection
    panel:addButton(L("language"), function()
        -- Open language selection menu
        OpenLanguageMenu()
    end)
end)

-- Add advanced quick settings
hook.Add("SetupQuickMenu", "AdvancedSettings", function(panel)
    -- Add graphics category
    panel:addCategory("Graphics")
    
    -- Add graphics quality slider
    panel:addSlider("Graphics Quality", function(_, v)
        lia.option.set("graphicsQuality", v)
        UpdateGraphicsSettings(v)
    end, lia.option.get("graphicsQuality", 5), 1, 10)
    
    -- Add FPS counter toggle
    panel:addCheck("Show FPS", function(_, v)
        lia.option.set("showFPS", v)
    end, lia.option.get("showFPS", false))
    
    -- Add audio category
    panel:addCategory("Audio")
    
    -- Add master volume slider
    panel:addSlider("Master Volume", function(_, v)
        lia.option.set("masterVolume", v)
        SetMasterVolume(v / 100)
    end, lia.option.get("masterVolume", 100), 0, 100)
end)

-- Add custom quick actions
hook.Add("SetupQuickMenu", "CustomActions", function(panel)
    -- Add custom category
    panel:addCategory("Custom Actions")
    
    -- Add custom button
    panel:addButton("Reset Settings", function()
        -- Reset all settings to default
        ResetAllSettings()
        panel:ChatPrint("Settings reset to default!")
    end)
    
    -- Add custom slider
    panel:addSlider("Custom Setting", function(_, v)
        lia.option.set("customSetting", v)
        print("Custom setting set to:", v)
    end, lia.option.get("customSetting", 50), 0, 100)
end)
```

---

### liaOptionChanged

**Purpose**

Triggered whenever `lia.option.set` modifies an option value.

**Parameters**

* `key` (*string*): Option identifier.
* `oldValue` (*any*): Previous value before the change.
* `newValue` (*any*): New assigned value.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Shared**

**Example Usage**

```lua
hook.Add("liaOptionChanged", "LogOptionChange", function(k, oldV, newV)
    print(k .. " changed from " .. tostring(oldV) .. " to " .. tostring(newV))
end)
```

---

### liaOptionReceived

**Purpose**

Called when an option is received from the server.

**Parameters**

* `key` (*string*): Option key.
* `value` (*any*): Option value.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
hook.Add("liaOptionReceived", "OptionLog", function(key, value)
    print("Option received:", key, "=", value)
end)
```

---

### OnLocalizationLoaded

**Purpose**

Called when localization is loaded.

**When Called**

This hook is triggered when:
- The localization system is being initialized
- Language files are being loaded and processed
- After localization data is validated and ready
- During system startup

**Parameters**

* `nil` (*nil*): This function does not return a value.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Shared**

**Example Usage**

```lua
hook.Add("OnLocalizationLoaded", "LocalizationReady", function()
    print("Localization loaded")
end)
```

---

### RefreshFonts

**Purpose**

Fires when fonts need to be refreshed.

**When Called**

This hook is triggered when:
- Font system needs to be refreshed
- Custom fonts are being reloaded
- After font changes are applied
- During font system updates

**Parameters**

* `nil` (*nil*): This function does not return a value.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
hook.Add("RefreshFonts", "FontRefresh", function()
    -- Refresh custom fonts
end)
```

---

### DermaSkinChanged

**Purpose**

Called when the Derma skin changes.

**When Called**

This hook is triggered when:
- The Derma skin is being changed
- UI skin system processes skin changes
- After skin validation and processing
- During skin system updates

**Parameters**

* `skin` (*string*): New skin name.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
hook.Add("DermaSkinChanged", "SkinLog", function(skin)
    print("Derma skin changed to:", skin)
end)
```

---

### AddTextField

**Purpose**

Allows adding custom text fields to the HUD.

**Parameters**

* `client` (*Player*): Player to add text field for.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
hook.Add("AddTextField", "CustomField", function(client)
    local char = client:getChar()
    if char then
        return {text = "Level: " .. char:getData("level", 1), color = Color(255, 255, 255)}
    end
end)
```

---

### F1OnAddTextField

**Purpose**

Called when adding text fields to the F1 menu.

**When Called**

This hook is triggered when:
- Text fields are being added to the F1 menu
- F1 menu is being populated with player information
- Before text fields are displayed in the F1 menu
- During F1 menu field setup

**Parameters**

* `client` (*Player*): Player to add text field for.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
hook.Add("F1OnAddTextField", "F1Field", function(client)
    -- Add text field to F1 menu
end)
```

---

### F1OnAddBarField

**Purpose**

Called when adding bar fields to the F1 menu.

**When Called**

This hook is triggered when:
- Bar fields are being added to the F1 menu
- F1 menu is being populated with player information
- Before bar fields are displayed in the F1 menu
- During F1 menu field setup

**Parameters**

* `client` (*Player*): Player to add bar field for.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
hook.Add("F1OnAddBarField", "F1Bar", function(client)
    -- Add bar field to F1 menu
end)
```

---

### AddBarField

**Purpose**

Allows adding custom fields to the HUD bars.

**When Called**

This hook is triggered when:
- HUD bars are being set up for a player
- Bar fields are being prepared for display
- Before HUD bars are shown to the player
- During HUD bar initialization

**Parameters**

* `client` (*Player*): Player whose bars are being set up.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
hook.Add("AddBarField", "HungerBar", function(ply)
    local char = ply:getChar()
    if char then
        local hunger = char:getData("hunger", 0)
        return {name = "Hunger", value = hunger, max = 100, color = Color(255, 100, 100)}
    end
end)
```

---

### AddSection

**Purpose**

Allows adding custom sections to the F1 menu.

**Parameters**

* `panel` (*Panel*): F1 menu panel.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
hook.Add("AddSection", "CustomSection", function(panel)
    local section = panel:addSection("Custom")
    section:addButton("Custom Button", function()
        -- Custom button logic
    end)
end)
```

---

### F1OnAddSection

**Purpose**

Called when adding sections to the F1 menu.

**When Called**

This hook is triggered when:
- Sections are being added to the F1 menu
- F1 menu is being populated with content
- Before sections are displayed in the F1 menu
- During F1 menu section setup

**Parameters**

* `panel` (*Panel*): F1 menu panel.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
hook.Add("F1OnAddSection", "F1Section", function(panel)
    -- Add custom section to F1 menu
end)
```

---

### CreateInformationButtons

**Purpose**

Allows adding custom information buttons to the main menu.

**When Called**

This hook is triggered when:
- Information buttons are being created for the main menu
- Main menu is being populated with buttons
- Before information buttons are displayed
- During main menu button setup

**Parameters**

* `panel` (*Panel*): Main menu panel.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
hook.Add("CreateInformationButtons", "CustomButton", function(panel)
    panel:addButton("Custom Info", function()
        -- Custom button logic
    end)
end)
```

---

### PopulateConfigurationButtons

**Purpose**

Called to populate configuration buttons.

**When Called**

This hook is triggered when:
- Configuration buttons are being populated
- Configuration panel is being set up
- Before configuration buttons are displayed
- During configuration panel initialization

**Parameters**

* `panel` (*Panel*): Configuration panel.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
hook.Add("PopulateConfigurationButtons", "ConfigButtons", function(panel)
    -- Add configuration buttons
end)
```

---

### PopulateAdminTabs

**Purpose**

Populate the Admin tab in the F1 menu. Mutate the provided `pages` array and insert page descriptors.

**When Called**

This hook is triggered when:
- The F1 admin menu is being initialized
- Admin tabs are being prepared for display
- Before the admin menu is shown to administrators
- During admin panel setup

**Parameters**

* `pages` (*table*): Insert items like `{ name = string, icon = string, drawFunc = function(panel) end }`.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
hook.Add("PopulateAdminTabs", "AddOnlineList", function(pages)
    pages[#pages + 1] = {
        name = "onlinePlayers",
        icon = "icon16/user.png",
        drawFunc = function(panel)
            -- build UI here
        end
    }
end)
```

---

### getOOCDelay

**Purpose**

Returns the delay between OOC messages.

**Parameters**

* `client` (*Player*): Player to get delay for.

**Returns**

* `delay` (*number*): Delay in seconds.

**Realm**

**Shared**

**Example Usage**

```lua
hook.Add("getOOCDelay", "CustomDelay", function(client)
    return client:IsAdmin() and 0 or 30
end)
```

---

### OnChatReceived

**Purpose**

Called when a chat message is received.

**Parameters**

* `speaker` (*Player*): Player who sent the message.
* `text` (*string*): Message text.
* `chatType` (*string*): Type of chat.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
hook.Add("OnChatReceived", "ProcessReceived", function(speaker, text, chatType)
    -- Process received chat message
end)
```

---

### getAdjustedPartData

**Purpose**

Allows adjustment of PAC part data.

**When Called**

This hook is triggered when:
- PAC part data is being adjusted for a player
- PAC system processes part data modifications
- Before PAC parts are applied to the player
- During PAC part data processing

**Parameters**

* `client` (*Player*): Player whose PAC data is being adjusted.
* `partData` (*table*): Current part data.

**Returns**

* `adjustedData` (*table*): Adjusted part data.

**Realm**

**Client**

**Example Usage**

```lua
hook.Add("getAdjustedPartData", "AdjustPAC", function(client, partData)
    -- Adjust PAC part data
    return partData
end)
```

---

### AdjustPACPartData

**Purpose**

Called to adjust PAC part data.

**When Called**

This hook is triggered when:
- PAC part data is being adjusted for a player
- PAC system processes part data modifications
- Before PAC parts are applied to the player
- During PAC part data processing

**Parameters**

* `client` (*Player*): Player whose PAC data is being adjusted.
* `partData` (*table*): Current part data.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
hook.Add("AdjustPACPartData", "PACAdjust", function(client, partData)
    -- Adjust PAC part data
end)
```

---

### attachPart

**Purpose**

Fires when a PAC part is attached.

**When Called**

This hook is triggered when:
- A PAC part is being attached to a player
- PAC system processes part attachment
- After part attachment validation and processing
- During PAC part attachment

**Parameters**

* `client` (*Player*): Player attaching the part.
* `part` (*table*): Part being attached.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
hook.Add("attachPart", "PartAttach", function(client, part)
    print("Part attached:", part.name)
end)
```

---

### removePart

**Purpose**

Called when a PAC part is removed.

**Parameters**

* `client` (*Player*): Player removing the part.
* `part` (*table*): Part being removed.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
hook.Add("removePart", "PartRemove", function(client, part)
    print("Part removed:", part.name)
end)
```

---

### OnPAC3PartTransfered

**Purpose**

Fires when a PAC3 part is transferred.

**When Called**

This hook is triggered when:
- A PAC3 part is being transferred to a player
- PAC3 system processes part transfer
- After part transfer validation and processing
- During PAC3 part transfer

**Parameters**

* `client` (*Player*): Player whose part is being transferred.
* `part` (*table*): Part being transferred.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
hook.Add("OnPAC3PartTransfered", "PartTransfer", function(client, part)
    print("PAC3 part transferred:", part.name)
end)
```

---

### DrawPlayerRagdoll

**Purpose**

Allows custom drawing of player ragdolls.

**When Called**

This hook is triggered when:
- A player ragdoll is being drawn/rendered
- Ragdoll entities are being displayed
- Every frame during ragdoll rendering
- During player death and ragdoll display

**Parameters**

* `client` (*Player*): Player whose ragdoll is being drawn.
* `entity` (*Entity*): Ragdoll entity.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
hook.Add("DrawPlayerRagdoll", "CustomRagdoll", function(client, entity)
    -- Custom ragdoll drawing
end)
```

---

### setupPACDataFromItems

**Purpose**

Called to set up PAC data from items.

**When Called**

This hook is triggered when:
- PAC data is being set up from player items
- Item-based PAC parts are being processed
- Before PAC parts are applied from items
- During PAC data initialization from items

**Parameters**

* `client` (*Player*): Player to set up PAC data for.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
hook.Add("setupPACDataFromItems", "PACFromItems", function(client)
    -- Set up PAC data from items
end)
```

---

### TryViewModel

**Purpose**

Allows modification of viewmodel handling.

**When Called**

This hook is triggered when:
- Viewmodel handling is being processed
- Weapon viewmodels are being set up
- Before viewmodel is applied to the player
- During viewmodel system processing

**Parameters**

* `client` (*Player*): Player whose viewmodel is being handled.
* `weapon` (*Weapon*): Weapon whose viewmodel is being handled.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
hook.Add("TryViewModel", "CustomViewModel", function(client, weapon)
    -- Custom viewmodel handling
end)
```

---

### WeaponCycleSound

**Purpose**

Called when weapon cycling sound should play.

**When Called**

This hook is triggered when:
- A player cycles through weapons
- Weapon cycling sound is being played
- During weapon switching animations
- When weapon cycling occurs

**Parameters**

* `client` (*Player*): Player cycling weapons.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
hook.Add("WeaponCycleSound", "CycleSound", function(client)
    -- Play custom cycle sound
end)
```

---

### WeaponSelectSound

**Purpose**

Fires when weapon selection sound should play.

**When Called**

This hook is triggered when:
- A player selects a weapon
- Weapon selection sound is being played
- During weapon selection animations
- When weapon selection occurs

**Parameters**

* `client` (*Player*): Player selecting weapon.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
hook.Add("WeaponSelectSound", "SelectSound", function(client)
    -- Play custom select sound
end)
```

---

### ShouldDrawWepSelect

**Purpose**

Determines if weapon selection should be drawn.

**When Called**

This hook is triggered when:
- Weapon selection UI is being prepared for display
- Before weapon selection is shown to the player
- During weapon selection rendering checks
- When weapon selection visibility is being determined

**Parameters**

* `client` (*Player*): Player to check.

**Returns**

- boolean: False to hide weapon selection

**Realm**

**Client**

**Example Usage**

```lua
hook.Add("ShouldDrawWepSelect", "HideWepSelect", function(client)
    return not client:getNetVar("hideWepSelect", false)
end)
```

---

### CanPlayerChooseWeapon

**Purpose**

Checks if a player can choose a weapon.

**When Called**

This hook is triggered when:
- A player attempts to choose a weapon
- Weapon selection is being validated
- Before weapon choice is allowed
- During weapon selection permission checks

**Parameters**

* `client` (*Player*): Player attempting to choose weapon.
* `weapon` (*string*): Weapon class.

**Returns**

- boolean: False to prevent weapon choice

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("CanPlayerChooseWeapon", "RestrictWeapons", function(client, weapon)
    if weapon == "weapon_rpg" and not client:IsAdmin() then
        return false
    end
end)
```

---

### OverrideSpawnTime

**Purpose**

Allows overriding the spawn time for entities.

**When Called**

This hook is triggered when:
- An entity is being spawned
- Spawn time is being calculated for an entity
- Before entity spawn time is applied
- During entity spawning process

**Parameters**

* `entity` (*Entity*): Entity being spawned.

**Returns**

* `spawnTime` (*number*): Custom spawn time.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("OverrideSpawnTime", "CustomSpawnTime", function(entity)
    if entity:GetClass() == "npc_headcrab" then
        return 60 -- Custom spawn time
    end
end)
```

---

### ShouldRespawnScreenAppear

**Purpose**

Determines if the respawn screen should appear.

**When Called**

This hook is triggered when:
- A player dies and respawn screen is being checked
- Respawn screen visibility is being determined
- Before respawn screen is shown to the player
- During respawn screen display checks

**Parameters**

* `client` (*Player*): Player who died.

**Returns**

- boolean: False to hide respawn screen

**Realm**

**Client**

**Example Usage**

```lua
hook.Add("ShouldRespawnScreenAppear", "CustomRespawn", function(client)
    return client:getNetVar("customRespawn", true)
end)
```

---

### PlayerSpawnPointSelected

**Purpose**

Called when a player selects a spawn point.

**When Called**

This hook is triggered when:
- A player selects a spawn point
- Spawn point selection is being processed
- After spawn point validation and processing
- During spawn point selection

**Parameters**

* `client` (*Player*): Player selecting spawn point.
* `spawnPoint` (*Entity*): Selected spawn point.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("PlayerSpawnPointSelected", "SpawnLog", function(client, spawnPoint)
    print(client:Nick(), "selected spawn point", spawnPoint)
end)
```

---

### VoiceToggled

**Purpose**

Fires when voice chat is toggled.

**When Called**

This hook is triggered when:
- A player toggles voice chat on or off
- Voice chat state is being changed
- During voice chat activation/deactivation
- When voice chat settings are modified

**Parameters**

* `client` (*Player*): Player who toggled voice.
* `state` (*boolean*): New voice state.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Shared**

**Example Usage**

```lua
hook.Add("VoiceToggled", "VoiceLog", function(client, state)
    print(client:Nick(), state and "enabled" or "disabled", "voice chat")
end)
```

---

### thirdPersonToggled

**Purpose**

Fires when third-person view is toggled.

**When Called**

This hook is triggered when:
- A player toggles third-person view on or off
- Third-person view state is being changed
- During third-person view activation/deactivation
- When third-person view settings are modified

**Parameters**

* `client` (*Player*): Player who toggled third-person.
* `state` (*boolean*): New third-person state.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
hook.Add("thirdPersonToggled", "ToggleLog", function(client, state)
    print("Third-person", state and "enabled" or "disabled")
end)
```

---

### AdjustCreationData

**Purpose**

Allows adjustment of character creation data.

**When Called**

This hook is triggered when:
- Character creation data is being processed
- Character creation form is being validated
- Before character creation data is saved
- During character creation process

**Parameters**

* `client` (*Player*): Player creating character.
* `data` (*table*): Creation data.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
hook.Add("AdjustCreationData", "AdjustData", function(client, data)
    -- Adjust character creation data
end)
```

---

### CanCharBeTransfered

**Purpose**

Determines if a character can be transferred.

**When Called**

This hook is triggered when:
- A character transfer is being attempted
- Character transfer permissions are being checked
- Before character transfer is allowed
- During character transfer validation

**Parameters**

* `character` (*Character*): Character to transfer.
* `newPlayer` (*Player*): New player to transfer to.

**Returns**

- boolean: False to prevent transfer

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("CanCharBeTransfered", "TransferRestrict", function(character, newPlayer)
    return newPlayer:IsAdmin()
end)
```

---

### CanInviteToFaction

**Purpose**

Checks if a player can invite others to a faction.

**When Called**

This hook is triggered when:
- A player attempts to invite someone to a faction
- Faction invitation permissions are being checked
- Before faction invitation is allowed
- During faction invitation validation

**Parameters**

* `inviter` (*Player*): Player attempting to invite.
* `target` (*Player*): Target player.
* `faction` (*string*): Faction to invite to.

**Returns**

- boolean: False to prevent invitation

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("CanInviteToFaction", "InviteRestrict", function(inviter, target, faction)
    return inviter:getChar():getFaction() == faction
end)
```

---

### CanInviteToClass

**Purpose**

Determines if a player can invite others to a class.

**When Called**

This hook is triggered when:
- A player attempts to invite someone to a class
- Class invitation permissions are being checked
- Before class invitation is allowed
- During class invitation validation

**Parameters**

* `inviter` (*Player*): Player attempting to invite.
* `target` (*Player*): Target player.
* `class` (*string*): Class to invite to.

**Returns**

- boolean: False to prevent invitation

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("CanInviteToClass", "ClassInviteRestrict", function(inviter, target, class)
    return inviter:getChar():getClass() == "leader"
end)
```

---

### CanPlayerUseChar

**Purpose**

Checks if a player can use a character.

**When Called**

This hook is triggered when:
- A player attempts to use a character
- Character usage permissions are being checked
- Before character is loaded/used
- During character usage validation

**Parameters**

* `client` (*Player*): Player attempting to use character.
* `character` (*Character*): Character to use.

**Returns**

- boolean: False to prevent character use

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("CanPlayerUseChar", "CharRestrict", function(client, character)
    return character:getData("banned", false) == false
end)
```

---

### CanPlayerSwitchChar

**Purpose**

Determines if a player can switch characters.

**When Called**

This hook is triggered when:
- A player attempts to switch characters
- Character switching permissions are being checked
- Before character switch is allowed
- During character switching validation

**Parameters**

* `client` (*Player*): Player attempting to switch.

**Returns**

- boolean: False to prevent switching

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("CanPlayerSwitchChar", "SwitchRestrict", function(client)
    return not client:getNetVar("switchCooldown", false)
end)
```

---

### GetMaxStartingAttributePoints

**Purpose**

Returns the maximum starting attribute points.

**When Called**

This hook is triggered when:
- Character creation attribute points are being calculated
- Starting attribute points are being determined
- Before character creation attribute allocation
- During character creation process

**Parameters**

* `client` (*Player*): Player creating character.

**Returns**

* `points` (*number*): Maximum points.

**Realm**

**Client**

**Example Usage**

```lua
hook.Add("GetMaxStartingAttributePoints", "CustomPoints", function(client)
    return 50
end)
```

---

### GetAttributeStartingMax

**Purpose**

Returns the starting maximum for an attribute.

**When Called**

This hook is triggered when:
- Character creation attribute maximums are being calculated
- Starting attribute maximums are being determined
- Before character creation attribute allocation
- During character creation process

**Parameters**

* `client` (*Player*): Player creating character.
* `attribute` (*string*): Attribute name.

**Returns**

* `max` (*number*): Starting maximum.

**Realm**

**Client**

**Example Usage**

```lua
hook.Add("GetAttributeStartingMax", "AttributeMax", function(client, attribute)
    return 20
end)
```

---

### GetAttributeMax

**Purpose**

Returns the maximum value for an attribute.

**When Called**

This hook is triggered when:
- Attribute maximum values are being calculated
- Attribute limits are being determined
- Before attribute values are validated
- During attribute system processing

**Parameters**

* `client` (*Player*): Player to check.
* `attribute` (*string*): Attribute name.

**Returns**

* `max` (*number*): Maximum value.

**Realm**

**Shared**

**Example Usage**

```lua
hook.Add("GetAttributeMax", "AttributeLimit", function(client, attribute)
    return 100
end)
```

---

### OnCharAttribBoosted

**Purpose**

Fires when a character's attribute is boosted.

**When Called**

This hook is triggered when:
- A character's attribute is being boosted
- Attribute boost is being applied
- After attribute boost validation and processing
- During attribute boost operations

**Parameters**

* `character` (*Character*): Character whose attribute was boosted.
* `attribute` (*string*): Attribute that was boosted.
* `amount` (*number*): Amount boosted.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("OnCharAttribBoosted", "BoostLog", function(character, attribute, amount)
    print("Attribute", attribute, "boosted by", amount)
end)
```

---

### OnCharAttribUpdated

**Purpose**

Called when a character's attribute is updated.

**When Called**

This hook is triggered when:
- A character's attribute is being updated
- Attribute changes are being applied
- After attribute update validation and processing
- During attribute update operations

**Parameters**

* `character` (*Character*): Character whose attribute was updated.
* `attribute` (*string*): Attribute that was updated.
* `oldValue` (*number*): Previous value.
* `newValue` (*number*): New value.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Shared**

**Example Usage**

```lua
hook.Add("OnCharAttribUpdated", "UpdateLog", function(character, attribute, oldValue, newValue)
    print("Attribute", attribute, "changed from", oldValue, "to", newValue)
end)
```

---

### OnCharFlagsGiven

**Purpose**

Fires when character flags are given.

**When Called**

This hook is triggered when:
- Character flags are being given to a character
- Flag assignment is being processed
- After flag assignment validation and processing
- During flag assignment operations

**Parameters**

* `character` (*Character*): Character receiving flags.
* `flags` (*string*): Flags given.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("OnCharFlagsGiven", "FlagLog", function(character, flags)
    print("Flags given:", flags)
end)
```

---

### OnCharFlagsTaken

**Purpose**

Called when character flags are taken.

**When Called**

This hook is triggered when:
- Character flags are being taken from a character
- Flag removal is being processed
- After flag removal validation and processing
- During flag removal operations

**Parameters**

* `character` (*Character*): Character losing flags.
* `flags` (*string*): Flags taken.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("OnCharFlagsTaken", "FlagRemoveLog", function(character, flags)
    print("Flags taken:", flags)
end)
```

---

### OnCheaterStatusChanged

**Purpose**

Fires when a player's cheater status changes.

**When Called**

This hook is triggered when:
- A player's cheater status is being changed
- Cheater status update is being processed
- After cheater status validation and processing
- During cheater status operations

**Parameters**

* `client` (*Player*): Player whose status changed.
* `isCheater` (*boolean*): New cheater status.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("OnCheaterStatusChanged", "StatusLog", function(client, isCheater)
    print(client:Nick(), "cheater status:", isCheater)
end)
```

---

### OnConfigUpdated

**Purpose**

Called when configuration is updated.

**When Called**

This hook is triggered when:
- Configuration values are being updated
- Config changes are being processed
- After configuration validation and processing
- During configuration updates

**Parameters**

* `key` (*string*): Configuration key that was updated.
* `oldValue` (*any*): Previous value.
* `newValue` (*any*): New value.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Shared**

**Example Usage**

```lua
hook.Add("OnConfigUpdated", "ConfigUpdateLog", function(key, oldValue, newValue)
    print("Config updated:", key, "from", oldValue, "to", newValue)
end)
```

---

### OnOOCMessageSent

**Purpose**

Fires when an out-of-character message is sent.

**When Called**

This hook is triggered when:
- A player sends an OOC message
- OOC messages are being processed by the system
- After OOC message validation and filtering
- During OOC message handling

**Parameters**

* `client` (*Player*): Player who sent the message.
* `text` (*string*): Message content.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("OnOOCMessageSent", "OOCMsgLog", function(client, text)
    print("OOC message from", client:Nick(), ":", text)
end)
```

---

### OnSalaryGive

**Purpose**

Called when salary is given to a player.

**When Called**

This hook is triggered when:
- Salary is being given to a player
- Salary payment is being processed
- After salary validation and processing
- During salary payment operations

**Parameters**

* `client` (*Player*): Player receiving salary.
* `amount` (*number*): Salary amount.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("OnSalaryGive", "SalaryLog", function(client, amount)
    print(client:Nick(), "received salary:", amount)
end)
```

---

### OnTicketClaimed

**Purpose**

Fires when a ticket is claimed.

**When Called**

This hook is triggered when:
- A ticket is being claimed by an administrator
- Ticket claiming is being processed
- After ticket claim validation and processing
- During ticket assignment

**Parameters**

* `ticket` (*table*): Ticket that was claimed.
* `claimer` (*Player*): Player who claimed the ticket.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("OnTicketClaimed", "TicketClaimLog", function(ticket, claimer)
    print("Ticket", ticket.id, "claimed by", claimer:Nick())
end)
```

---

### OnTicketClosed

**Purpose**

Called when a ticket is closed.

**When Called**

This hook is triggered when:
- A ticket is being closed by an administrator
- Ticket closure is being processed
- After ticket close validation and processing
- During ticket completion

**Parameters**

* `ticket` (*table*): Ticket that was closed.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("OnTicketClosed", "TicketCloseLog", function(ticket)
    print("Ticket", ticket.id, "closed")
end)
```

---

### OnTicketCreated

**Purpose**

Fires when a ticket is created.

**When Called**

This hook is triggered when:
- A player creates a new ticket
- Ticket creation is being processed
- After ticket validation and processing
- During ticket submission

**Parameters**

* `ticket` (*table*): Ticket that was created.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("OnTicketCreated", "TicketCreateLog", function(ticket)
    print("Ticket", ticket.id, "created")
end)
```

---

### OnVendorEdited

**Purpose**

Called when a vendor is edited.

**When Called**

This hook is triggered when:
- A vendor's settings are being modified
- Vendor editing is being processed
- After vendor edit validation and processing
- During vendor management operations

**Parameters**

* `vendor` (*Entity*): Vendor that was edited.
* `client` (*Player*): Player who edited the vendor.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("OnVendorEdited", "VendorEditLog", function(vendor, client)
    print("Vendor edited by", client:Nick())
end)
```

---

### WarningIssued

**Purpose**

Fires when a warning is issued to a player.

**When Called**

This hook is triggered when:
- An administrator issues a warning to a player
- Warning system processes a warning
- After warning validation and processing
- During warning administration

**Parameters**

* `target` (*Player*): Player receiving the warning.
* `issuer` (*Player*): Player issuing the warning.
* `reason` (*string*): Warning reason.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("WarningIssued", "WarningLog", function(target, issuer, reason)
    print("Warning issued to", target:Nick(), "by", issuer:Nick(), ":", reason)
end)
```

---

### WarningRemoved

**Purpose**

Called when a warning is removed from a player.

**When Called**

This hook is triggered when:
- An administrator removes a warning from a player
- Warning removal is being processed
- After warning removal validation and processing
- During warning cleanup

**Parameters**

* `target` (*Player*): Player whose warning was removed.
* `remover` (*Player*): Player removing the warning.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("WarningRemoved", "RemoveLog", function(target, remover)
    print("Warning removed from", target:Nick(), "by", remover:Nick())
end)
```

---

### PlayerGagged

**Purpose**

Fires when a player is gagged.

**When Called**

This hook is triggered when:
- An administrator gags a player
- Gag system processes a gag
- After gag validation and processing
- During gag administration

**Parameters**

* `target` (*Player*): Player who was gagged.
* `gagger` (*Player*): Player who gagged them.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("PlayerGagged", "GagLog", function(target, gagger)
    print(target:Nick(), "was gagged by", gagger:Nick())
end)
```

---

### PlayerUngagged

**Purpose**

Called when a player is ungagged.

**When Called**

This hook is triggered when:
- An administrator ungags a player
- Gag system processes ungagging
- After ungag validation and processing
- During gag removal

**Parameters**

* `target` (*Player*): Player who was ungagged.
* `ungagger` (*Player*): Player who ungagged them.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("PlayerUngagged", "UngagLog", function(target, ungagger)
    print(target:Nick(), "was ungagged by", ungagger:Nick())
end)
```

---

### PlayerMuted

**Purpose**

Fires when a player is muted.

**When Called**

This hook is triggered when:
- An administrator mutes a player
- Mute system processes a mute
- After mute validation and processing
- During mute administration

**Parameters**

* `target` (*Player*): Player who was muted.
* `muter` (*Player*): Player who muted them.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("PlayerMuted", "MuteLog", function(target, muter)
    print(target:Nick(), "was muted by", muter:Nick())
end)
```

---

### PlayerUnmuted

**Purpose**

Called when a player is unmuted.

**When Called**

This hook is triggered when:
- An administrator unmutes a player
- Mute system processes unmuting
- After unmute validation and processing
- During mute removal

**Parameters**

* `target` (*Player*): Player who was unmuted.
* `unmuter` (*Player*): Player who unmuted them.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("PlayerUnmuted", "UnmuteLog", function(target, unmuter)
    print(target:Nick(), "was unmuted by", unmuter:Nick())
end)
```

---

### PlayerCheatDetected

**Purpose**

Fires when cheat detection is triggered.

**When Called**

This hook is triggered when:
- A player is detected using cheats
- Anti-cheat system processes cheat detection
- After cheat detection validation and processing
- During cheat detection operations

**Parameters**

* `client` (*Player*): Player detected cheating.
* `cheatType` (*string*): Type of cheat detected.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("PlayerCheatDetected", "CheatLog", function(client, cheatType)
    print("Cheat detected:", client:Nick(), cheatType)
end)
```

---

### OnCheaterCaught

**Purpose**

Called when a cheater is caught.

**When Called**

This hook is triggered when:
- A cheater is caught by the system
- Cheat detection processes cheater capture
- After cheater validation and processing
- During cheater handling operations

**Parameters**

* `client` (*Player*): Player caught cheating.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("OnCheaterCaught", "CheaterLog", function(client)
    print("Cheater caught:", client:Nick())
end)
```

---

### TicketSystemCreated

**Purpose**

Fires when a ticket is created in the ticket system.

**When Called**

This hook is triggered when:
- A player creates a new ticket
- Ticket system processes ticket creation
- After ticket validation and processing
- During ticket submission

**Parameters**

* `ticket` (*table*): Ticket that was created.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("TicketSystemCreated", "TicketLog", function(ticket)
    print("Ticket created:", ticket.id)
end)
```

---

### TicketSystemClaim

**Purpose**

Called when a ticket is claimed.

**When Called**

This hook is triggered when:
- An administrator claims a ticket
- Ticket system processes ticket claiming
- After ticket claim validation and processing
- During ticket assignment

**Parameters**

* `ticket` (*table*): Ticket that was claimed.
* `claimer` (*Player*): Player who claimed the ticket.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("TicketSystemClaim", "ClaimLog", function(ticket, claimer)
    print("Ticket", ticket.id, "claimed by", claimer:Nick())
end)
```

---

### TicketSystemClose

**Purpose**

Fires when a ticket is closed.

**When Called**

This hook is triggered when:
- An administrator closes a ticket
- Ticket system processes ticket closure
- After ticket close validation and processing
- During ticket completion

**Parameters**

* `ticket` (*table*): Ticket that was closed.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("TicketSystemClose", "CloseLog", function(ticket)
    print("Ticket", ticket.id, "closed")
end)
```

