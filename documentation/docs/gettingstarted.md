# Getting Started

This step-by-step guide will help you set up your first Lilia roleplay server. We'll start with the basics and build up to advanced features. Each section includes simple instructions and examples.

---

## Step 1: Install Lilia Framework

Lilia is the framework that powers your roleplay server. It requires a roleplay schema (gamemode) to function.

### Basic Installation

1. **Subscribe to Lilia on Steam Workshop**
   - Visit the [Lilia Workshop page](https://steamcommunity.com/sharedfiles/filedetails/?id=3527535922)
   - Click "Subscribe" to download it
   - Workshop ID: `3527535922`

2. **Create Workshop Collection**
   - In Steam Workshop, create a collection
   - Add Lilia Framework to the collection
   - Note the collection ID number

3. **Configure Server Startup**
   - Add this to your server startup parameters:
     ```
     +host_workshop_collection YOUR_COLLECTION_ID
     ```
     (Replace `YOUR_COLLECTION_ID` with your collection ID)

### Download a Schema

Lilia requires a schema to function. Start with the Skeleton Schema:

1. Visit [Skeleton Schema on GitHub](https://github.com/LiliaFramework/Skeleton)
2. Click "Code" → "Download ZIP"
3. Extract the ZIP file
4. Upload the `skeleton` folder to `garrysmod/gamemodes/`

### Launch Server

Add this to your server startup parameters:
```
+gamemode skeleton
```

Example complete startup command:
```
+host_workshop_collection 123456789 +gamemode skeleton
```

### Verify Installation

Start your server and check the console for:
```
[Lilia] [Bootstrap] Loaded successfully after X seconds.
```

---

## Step 2: Set Up Admin Access

To manage your server, you need administrator permissions.

### Basic Admin Setup

1. Join your server as a regular player
2. Open the console by pressing the `~` key (usually above Tab)
3. Enter this command:
   ```
   plysetgroup YOUR_NAME superadmin
   ```
   (Replace `YOUR_NAME` with your exact player name)

### Alternative Methods

If you have admin systems installed:

- SAM: Use the SAM interface to set your rank

- ULX: Use ULX commands or interface to set your usergroup

- ServerGuard: Use ServerGuard's rank management

### Permission Levels

Lilia has three permission levels:

- User: Basic player permissions

- Admin: Moderation and basic administrative commands

- Super Admin: Full server control (recommended for owners)

---

## Step 3: Create Your First Faction

Factions are the main groups in your roleplay server. Every player character belongs to one faction. Examples include Citizens, Police, Medical, etc.

### File Location

Place faction files in your schema folder:
```
garrysmod/gamemodes/YOUR_SCHEMA/schema/factions/
```

Use simple filenames like `citizen.lua`, `police.lua`, `doctor.lua`.

### Create a Citizen Faction

1. Create a new file named `citizen.lua` in your factions folder
2. Add this code to the file:

```lua
-- Citizen Faction
FACTION.name = "Citizens"
FACTION.desc = "Regular people living in the city"
FACTION.color = Color(100, 150, 100)

-- Access Control
FACTION.isDefault = true  -- Allow players to join
FACTION.oneCharOnly = false  -- Players can have multiple citizen characters
FACTION.limit = 0  -- Unlimited players

-- Visual Properties
FACTION.models = {
    "models/player/Group01/male_01.mdl",
    "models/player/Group01/female_01.mdl"
}
FACTION.scale = 1.0  -- Normal model scale
FACTION.bloodcolor = BLOOD_COLOR_RED

-- Gameplay Properties
FACTION.health = 100  -- Default health
FACTION.armor = 0    -- No armor

-- Weapons (given when spawning)
FACTION.weapons = {
    -- No default weapons for citizens
}

-- Starting Items (given when character is created)
FACTION.items = {
    "item_wallet"
}

-- Movement Properties
FACTION.runSpeed = 300  -- Default run speed
FACTION.walkSpeed = 150  -- Default walk speed
FACTION.jumpPower = 200  -- Default jump power

-- NPC Relationships
FACTION.NPCRelations = {
    ["npc_metropolice"] = D_NU,  -- Neutral to metropolice
    ["npc_citizen"] = D_LI       -- Liked by citizens
}

FACTION.index = 0  -- Index that you can call during code calls
```

3. Save the file and restart your server
4. Test by joining and creating a character - "Citizens" should appear as an option

### Faction Properties

| Property | Purpose | Example |
|----------|---------|---------|
| `name` | Display name | `"Police Department"` |
| `desc` | Description | `"Law enforcement officers"` |
| `color` | UI color | `Color(0, 100, 255)` |
| `isDefault` | Joinable by players | `true` or `false` |
| `models` | Player models | `{"models/player/police.mdl"}` |
| `weapons` | Starting weapons | `{"weapon_pistol"}` |
| `items` | Starting items | `{"item_badge"}` |
| `health` | Max health | `120` |
| `armor` | Armor value | `50` |

### Expanding Your Server

After basic factions work, you can add:
- Additional factions (police, medical, etc.)
- Weapons for specific factions
- Custom health/armor values
- Faction size limits

For more faction options, see the [Faction Guide](definitions/faction.md).

---

## Step 4: Create Classes

Classes are specialized roles within factions. Think of them as sub-factions or regiments - specialized units within a larger organization.

Examples:

- Police Department: Officer, Detective, SWAT, Chief

- Army: Infantry, Sniper, Medic, Tank Commander

- Galactic Empire: Stormtrooper, Scout Trooper, Imperial Officer, Dark Trooper

Skip this if you only need basic factions. Classes work well for military, law enforcement, or complex organizational structures.

### File Location

Place class files in your schema folder:
```
garrysmod/gamemodes/YOUR_SCHEMA/schema/classes/
```

### Create a Police Officer Class

First create a police faction, then add this class file:

```lua
-- Police Officer Class
CLASS.name = "Police Officer"
CLASS.desc = "A law enforcement officer responsible for maintaining order and protecting citizens"
CLASS.faction = FACTION_CITY

-- Access Control
CLASS.limit = 8  -- Maximum 8 officers
CLASS.isWhitelisted = true  -- Requires whitelist
CLASS.isDefault = false  -- Not the default class for the faction

-- Visual Properties
CLASS.model = "models/player/police.mdl"
CLASS.Color = Color(0, 100, 255)  -- Blue color for police
CLASS.scale = 1.0  -- Normal model scale
CLASS.bloodcolor = BLOOD_COLOR_RED

-- Gameplay Properties
CLASS.health = 120  -- Higher health than default
CLASS.armor = 50    -- Standard police armor
CLASS.pay = 150     -- $150 salary per paycheck

-- Weapons (given when spawning)
CLASS.weapons = {
    "weapon_pistol",
    "weapon_stunstick",
    "weapon_police_baton"
}

-- Movement Properties
CLASS.runSpeed = 280  -- Slightly slower than default for tactical movement
CLASS.walkSpeed = 150  -- Standard walking speed
CLASS.jumpPower = 200  -- Standard jump power

-- NPC Relationships (overrides faction settings)
CLASS.NPCRelations = {
    ["npc_metropolice"] = D_LI,  -- Liked by metropolice
    ["npc_citizen"] = D_NU,      -- Neutral to citizens
    ["npc_rebel"] = D_HT         -- Hated by rebels
}

CLASS.index = CLASS_POLICE -- Index that you can call during code calls
```

### When to Use Classes

Use classes for specialized units within factions:

- Military regiments: Infantry, Snipers, Medics, Engineers, Tank Commanders
- Law enforcement units: Patrol Officers, Detectives, SWAT, K-9 Units
- Medical divisions: Doctors, Surgeons, EMTs, Specialists
- Criminal organizations: Enforcers, Lieutenants, Capos, Bosses
- Sci-fi factions: Stormtroopers, Scout Troopers, Imperial Officers, Elite Guards

### Faction vs Class

| Level | Purpose | Example | Scope |
|-------|---------|---------|-------|
| Faction | Main organization | "United States Army" | Broad group everyone belongs to |
| Class | Specialized regiment | "Sniper Regiment" | Elite/specialized role within faction |
| Faction | Government | "Galactic Empire" | Large overarching group |
| Class | Military branch | "Stormtrooper Corps" | Specific military unit type |

Classes are sub-factions that inherit from their parent faction but can have unique abilities, equipment, and restrictions.

For more class options, see the [Class Guide](definitions/class.md).

---

## Step 5: Customize Weapons

Weapon customization changes how weapons appear in inventories, shops, and gameplay. Most servers can skip this initially.

### Why Customize Weapons

- Change weapon names (e.g., "Pistol" → "Beretta 92FS")
- Set prices for buying/selling
- Control weapon access
- Adjust inventory space usage

### File Location

1. **Create libraries folder**

   Add this code to your schema's `libraries/shared.lua` file:

   ```
   garrysmod/gamemodes/YOUR_SCHEMA/schema/libraries/shared.lua
   ```

### Create Weapon Overrides

1. Create or edit your schema's `libraries/shared.lua` file
2. Add this code to customize weapons:

```lua
-- Customize pistol
lia.item.addWeaponOverride("weapon_pistol", {
    name = "9mm Pistol",
    price = 500,
    desc = "A standard police sidearm"
})

-- Make shotgun expensive
lia.item.addWeaponOverride("weapon_shotgun", {
    name = "Combat Shotgun",
    price = 2500,
    flag = "s"
})
```

3. Save the file and restart your server
4. Test by checking weapon names and prices in shops/inventories

### Weapon Properties

| Property | Purpose | Example |
|----------|---------|---------|
| `name` | Display name | `"Police Pistol"` |
| `desc` | Description | `"Standard issue firearm"` |
| `price` | Shop price | `1000` |
| `flag` | Required permission | `"p"` |
| `width`/`height` | Inventory size | `width = 3, height = 2` |
| `ammo` | Ammo type | `"pistol"` |
| `ammoAmount` | Magazine size | `17` |

### Expanding Weapon Customization

After basic weapon overrides work, you can add:
- Additional weapon customizations
- Flag-based access restrictions
- Custom ammo types and amounts
- Unique weapon descriptions

For more weapon options, see the [Weapon Guide](definitions/items/weapons.md).

---

## Step 6: Add Extra Features with Modules

Modules are plugins that add new features to your server.

### Installing a Module

1. Browse the modules at [Lilia Modules Documentation](https://liliaframework.github.io/modules/)
2. Find the module you want and click on it to go to its "About" page
3. Click the "DOWNLOAD HERE" link to download the specific module ZIP
4. Extract the ZIP file
5. Upload the module folder to `garrysmod/gamemodes/YOUR_SCHEMA/modules/`
6. Restart your server

Browse all available modules in the [Modules Section](modules/).

---

### Troubleshooting

**Common Issues:**
- Server not starting: Check console for error messages
- Features not working: Ensure server restart after changes
- Players can't join factions: Verify `isDefault = true`

**Resources:**
- [Complete Documentation](index.md) - Detailed guides
- [Discord Community](https://discord.gg/esCRH5ckbQ) - Support and discussion
- [GitHub Issues](https://github.com/LiliaFramework/Lilia/issues) - Bug reports