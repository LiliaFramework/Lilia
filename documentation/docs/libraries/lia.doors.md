# lia.doors

The door management system for Lilia provides functionality for door ownership, access control, and preset configurations.

## Overview

The `lia.doors` library handles all door-related functionality including ownership, access permissions, and preset configurations that allow server administrators to define default door settings for specific maps. Door presets are automatically loaded when the doors module initializes and are applied to doors that don't have existing database entries.

## Functions

### lia.doors.AddPreset(mapName, presetData)

Creates a preset configuration for doors on a specific map.

#### Parameters

- `mapName` (string) - The name of the map (e.g., "gm_flatgrass")
- `presetData` (table) - A table where keys are door IDs and values are door configuration tables

#### Door Configuration Properties

Each door configuration can contain the following properties:

| Property | Type | Description |
|----------|------|-------------|
| `name` | string | Custom name displayed for the door |
| `price` | number | Purchase price for the door (0 = free) |
| `locked` | boolean | Whether the door starts locked |
| `disabled` | boolean | Whether the door is disabled/unusable |
| `hidden` | boolean | Whether the door is hidden from the UI |
| `noSell` | boolean | Whether the door cannot be purchased by players |
| `factions` | table | Array of faction uniqueIDs that can access this door |
| `classes` | table | Array of class uniqueIDs that can access this door |

#### Example

```lua
lia.doors.AddPreset("gm_flatgrass", {
    [123] = {
        name = "House Door",
        price = 500,
        locked = false,
        disabled = false,
        hidden = false,
        noSell = false,
        factions = {},
        classes = {}
    },

    [124] = {
        name = "Police Station",
        price = 0,
        locked = true,
        disabled = false,
        hidden = false,
        noSell = true,
        factions = {},
        classes = {"police", "sheriff"}
    },

    [125] = {
        name = "Shop Entrance",
        price = 1000,
        locked = false,
        disabled = false,
        hidden = false,
        noSell = false,
        factions = {"citizen"},
        classes = {}
    }
})
```

### lia.doors.GetPreset(mapName)

Retrieves the preset configuration for a specific map.

#### Parameters

- `mapName` (string) - The name of the map

#### Returns

- `table` - The preset data for the map, or `nil` if no preset exists

#### Example

```lua
local preset = lia.doors.GetPreset("gm_flatgrass")
if preset then
    print("Preset exists for gm_flatgrass")
    for doorID, config in pairs(preset) do
        print("Door " .. doorID .. ": " .. config.name)
    end
end
```

## Preset System

### How It Works

1. **Loading Process**: Door presets are loaded from `gamemode/modules/doors/door_presets.lua` when the doors module initializes
2. **Application Logic**: When doors are loaded from the database, the system checks if presets exist for the current map and applies them to doors that don't have existing database entries
3. **Priority**: Database entries take precedence over presets - presets only affect doors that are "new" (no database record exists)
4. **Automatic Integration**: Presets are applied automatically during the door loading process, but only for doors without existing data

### Important Notes

- **Presets are defaults**: They only apply to doors that haven't been configured before
- **Database overrides presets**: Once a door has database entries, presets are ignored for that door
- **Admin commands override both**: Administrator changes via commands override both presets and database values
- **Per-map configuration**: Presets are defined per map, allowing different configurations for different maps

### Finding Door IDs

To create presets, you need to know the door IDs on your map. Use these admin commands:

#### /doorid
Shows the door ID of the door you're currently looking at.

```
Usage: Look at a door and type /doorid
Example output: "Door ID: 123 | Position: 512, 256, 128"
```

#### /listdoorids
Lists all door IDs on the current map with their positions and models.

```
Usage: Type /listdoorids anywhere
Output: Opens a table UI showing all doors with IDs, positions, and models
```

### Preset File Structure

Presets are defined in `gamemode/modules/doors/door_presets.lua`. This file is automatically loaded when the doors module initializes.

#### Basic Structure

```lua
-- Door presets for specific maps
-- This file contains preset configurations for doors on different maps

-- Example preset for gm_flatgrass
lia.doors.AddPreset("gm_flatgrass", {
    -- Door ID as key, door configuration as value
    -- Replace the numbers below with actual door IDs from your map

    [123] = {
        name = "House Door",
        price = 500,
        locked = false,
        disabled = false,
        hidden = false,
        noSell = false,
        factions = {},
        classes = {}
    },

    [124] = {
        name = "Shop Entrance",
        price = 1000,
        locked = false,
        disabled = false,
        hidden = false,
        noSell = false,
        factions = {"citizen"},
        classes = {}
    }
})

-- Add presets for other maps
lia.doors.AddPreset("rp_downtown_v2", {
    [456] = {
        name = "Apartment Building",
        price = 750,
        locked = true,
        disabled = false,
        hidden = false,
        noSell = false,
        factions = {},
        classes = {}
    }
})
```

#### Minimal Configuration

You don't need to specify all properties - only the ones you want to configure:

```lua
lia.doors.AddPreset("gm_flatgrass", {
    [123] = {
        name = "Police Station",
        price = 0,
        noSell = true  -- Cannot be purchased
    },

    [124] = {
        name = "Shop",
        price = 1000
    }
})
```

## Door Properties

### Basic Properties

- **name**: Custom display name for the door
- **price**: Cost to purchase the door (set to 0 for free doors)
- **locked**: Initial lock state (true = locked, false = unlocked)
- **disabled**: Makes the door unusable (true = disabled, false = enabled)
- **hidden**: Hides the door from the door management UI
- **noSell**: Prevents players from purchasing the door

### Access Control

#### Factions
Control which factions can access the door by specifying faction uniqueIDs:

```lua
factions = {"citizen", "police"}  -- Only citizens and police can access
factions = {}                     -- No faction restrictions
```

#### Classes
Control which character classes can access the door by specifying class uniqueIDs:

```lua
classes = {"police", "medic"}     -- Only police and medic classes can access
classes = {}                      -- No class restrictions
```

## Setup and Usage

### 1. Setting Up Presets

1. **Find Door IDs**: Use `/listdoorids` or `/doorid` commands to identify door IDs on your map
2. **Edit Preset File**: Open `gamemode/modules/doors/door_presets.lua`
3. **Add Your Map**: Create a new preset entry for your map
4. **Configure Doors**: Add door configurations using the IDs you found
5. **Restart Server**: Restart the server or reload the doors module for changes to take effect

### 2. Finding Door IDs

```lua
-- Method 1: Use the command while looking at doors
/doorid

-- Method 2: List all doors on the map
/listdoorids
```

### 3. Testing Presets

1. **Load the map** on your server
2. **Use `/listdoorids`** to verify door IDs match your preset
3. **Check door properties** by looking at doors (name, price should show)
4. **Test purchasing** doors to ensure prices work
5. **Test access control** with different factions/classes

## Best Practices

### 1. Map-Specific Presets
Create separate presets for each map to ensure proper door configurations:

```lua
-- Good: Map-specific presets
lia.doors.AddPreset("gm_flatgrass", { ... })
lia.doors.AddPreset("rp_downtown_v2", { ... })
```

### 2. Use Descriptive Names
Give doors meaningful names to help with identification:

```lua
-- Good: Descriptive names
name = "Police Station Main Entrance"
name = "Apartment 3B"
name = "Shop Storage Room"
```

### 3. Balance Pricing
Set reasonable prices based on door location and importance:

```lua
-- Residential doors
price = 500

-- Commercial doors
price = 1000

-- Government/important doors
price = 0, noSell = true
```

### 4. Use Minimal Configurations
Only specify properties you want to change:

```lua
-- Good: Only specify what you need
[123] = {
    name = "Police Station",
    noSell = true  -- Only government doors can't be bought
}

-- Avoid: Specifying unnecessary defaults
[123] = {
    name = "Police Station",
    price = 0,
    locked = false,     -- Unnecessary if false is default
    disabled = false,   -- Unnecessary if false is default
    hidden = false,     -- Unnecessary if false is default
    noSell = true,
    factions = {},      -- Unnecessary if empty
    classes = {}        -- Unnecessary if empty
}
```

## Integration with Database

### How Presets Interact with Database

The door system uses a hierarchical approach where database entries take precedence over presets:

#### Loading Process
1. **Server Start**: Door presets are loaded from `door_presets.lua`
2. **Map Load**: The server queries the database for existing door configurations
3. **Preset Application**: For doors without database entries, presets are applied
4. **Database Override**: Doors with existing database records ignore presets

#### Priority Order (Highest to Lowest)
1. **Admin Commands**: Changes made via admin commands (e.g., `/doorsetprice`) override everything
2. **Database Entries**: Existing door configurations stored in the database
3. **Presets**: Default configurations defined in `door_presets.lua`
4. **System Defaults**: Built-in default values

#### When Presets Are Applied
- **New Maps**: When loading a map for the first time with no database entries
- **New Doors**: When doors are added to a map that weren't previously configured
- **Reset Doors**: When door data is manually cleared from the database

#### When Presets Are Ignored
- **Existing Doors**: Doors that already have database entries
- **Modified Doors**: Doors that have been changed by administrators
- **Different Maps**: Each map has its own preset configuration

### Database Schema

Doors are stored in the `lia_doors` table with these fields:

- `gamemode`: The gamemode name
- `map`: The map name
- `id`: The door's map creation ID
- `factions`: JSON array of faction uniqueIDs
- `classes`: JSON array of class uniqueIDs
- `disabled`: Boolean (1 = disabled, 0 = enabled)
- `hidden`: Boolean (1 = hidden, 0 = visible)
- `ownable`: Boolean (0 = not ownable, 1 = ownable)
- `name`: Custom door name
- `price`: Door purchase price
- `locked`: Boolean (1 = locked, 0 = unlocked)

## Troubleshooting

### Common Issues

#### 1. Presets Not Applying
**Problem**: Door presets aren't being applied to doors on your map.

**Solutions**:
- Check that you're using the correct map name in `lia.doors.AddPreset("your_map_name", ...)`
- Use `/listdoorids` to verify door IDs match your preset configuration
- Ensure doors don't already have database entries (presets only apply to new doors)
- Check server console for error messages about preset loading

#### 2. Wrong Door IDs
**Problem**: The door IDs in your preset don't match the actual doors.

**Solutions**:
- Use `/listdoorids` to get accurate door IDs for your map
- Use `/doorid` while looking at specific doors
- Door IDs are generated by the map and can vary between different map versions

#### 3. Preset Not Loading
**Problem**: Your preset file isn't being loaded.

**Solutions**:
- Check that the file is at `gamemode/modules/doors/door_presets.lua`
- Ensure there are no syntax errors in your preset file
- Restart the server after making changes to presets
- Check server console for "Added door preset for map" messages

#### 4. Access Control Not Working
**Problem**: Faction or class restrictions aren't working.

**Solutions**:
- Verify faction/class names match exactly (case-sensitive)
- Check that factions/classes exist in your gamemode
- Use empty arrays `{}` to remove all restrictions
- Test with `/listdoorids` to see current door configuration

### Debug Commands

```lua
-- Check if presets loaded
lua_run PrintTable(lia.doors.presets)

-- Check specific map presets
lua_run PrintTable(lia.doors.GetPreset("your_map_name"))

-- Check door information
lua_run for k,v in pairs(ents.FindByClass("prop_door_rotating")) do print(v:MapCreationID(), v:GetPos()) end
```

### Getting Help

If you're still having issues:

1. Check the server console for error messages
2. Use the debug commands above to inspect your configuration
3. Verify your preset syntax with a Lua validator
4. Test on a simple map first before complex configurations

## Error Handling

The preset system includes comprehensive error handling:

- Invalid map names are rejected
- Missing preset data shows clear error messages
- Invalid door configurations are logged but don't break the system
- Database connection issues are properly handled

## Complete Example

Here's a complete example of setting up door presets for a roleplay server:

### 1. Find Door IDs
```
1. Load your map on the server
2. Use /listdoorids to see all doors
3. Note down the door IDs you want to configure
```

### 2. Create Preset File
**File**: `gamemode/modules/doors/door_presets.lua`

```lua
-- Door presets for RP Server
-- Residential Area
lia.doors.AddPreset("rp_city17_build210", {
    -- Apartment Building Entrance
    [123] = {
        name = "Apartment Building",
        price = 500,
        locked = false,
        disabled = false,
        hidden = false,
        noSell = false,
        factions = {},
        classes = {}
    },

    -- Apartment 1A
    [124] = {
        name = "Apartment 1A",
        price = 250,
        locked = true,
        disabled = false,
        hidden = false,
        noSell = false,
        factions = {},
        classes = {}
    },

    -- Apartment 1B
    [125] = {
        name = "Apartment 1B",
        price = 250,
        locked = true,
        disabled = false,
        hidden = false,
        noSell = false,
        factions = {},
        classes = {}
    }
})

-- Commercial District
lia.doors.AddPreset("rp_city17_build210", {
    -- Grocery Store
    [456] = {
        name = "City Grocery",
        price = 1500,
        locked = false,
        disabled = false,
        hidden = false,
        noSell = false,
        factions = {"citizen"},
        classes = {}
    },

    -- Pharmacy
    [457] = {
        name = "Medical Center",
        price = 2000,
        locked = false,
        disabled = false,
        hidden = false,
        noSell = false,
        factions = {},
        classes = {"medic"}
    }
})

-- Government Buildings
lia.doors.AddPreset("rp_city17_build210", {
    -- Police Station
    [789] = {
        name = "Civil Protection HQ",
        price = 0,
        locked = true,
        disabled = false,
        hidden = false,
        noSell = true,  -- Cannot be purchased
        factions = {},
        classes = {"police", "administrator"}
    },

    -- City Hall
    [790] = {
        name = "City Administration",
        price = 0,
        locked = true,
        disabled = false,
        hidden = false,
        noSell = true,
        factions = {},
        classes = {"administrator"}
    }
})
```

### 3. Test Your Setup

```lua
-- 1. Restart server or reload doors module
-- 2. Load the map
-- 3. Use /listdoorids to verify door IDs
-- 4. Check that door names and prices appear correctly
-- 5. Test purchasing doors as different classes/factions
```

## Logging

The doors module includes extensive logging for:

- Preset application
- Door purchases
- Access control changes
- Administrative actions
- Database operations

All logs use the standard Lilia logging system and can be found in server console and log files.
