# Getting Started with Lilia

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

FACTION.isDefault = true  -- Allow players to join

FACTION.models = {
    "models/player/Group01/male_01.mdl",
    "models/player/Group01/female_01.mdl"
}

FACTION.items = {
    "item_wallet"
}

lia.faction.register("citizen", FACTION)
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
CLASS.desc = "A basic law enforcement officer"
CLASS.faction = FACTION_POLICE

CLASS.model = "models/player/police.mdl"

CLASS.health = 120  -- More health than citizens
CLASS.armor = 50    -- Police armor

CLASS.weapons = {
    "weapon_pistol",
    "weapon_stunstick"
}

lia.class.register("police_officer", CLASS)
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

### Basic Customization

Add this code to your schema's `sh_init.lua` file:

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

Add this code before `lia.item.generateWeapons()` is called.

### Available Options

| Property | Purpose | Example |
|----------|---------|---------|
| `name` | Display name | `"Police Pistol"` |
| `desc` | Description | `"Standard issue firearm"` |
| `price` | Shop price | `1000` |
| `flag` | Required permission | `"p"` |
| `width`/`height` | Inventory size | `width = 3, height = 2` |
| `ammo` | Ammo type | `"pistol"` |
| `ammoAmount` | Magazine size | `17` |

For more weapon options, see the [Weapon Guide](definitions/items/weapons.md).

---

## Step 6: Add Extra Features with Modules

Modules are plugins that add new features to your server.

### Installing a Module

1. Visit [Lilia Modules](https://github.com/LiliaFramework/Modules)
2. Find the module you want
3. Click "Code" → "Download ZIP"
4. Extract the ZIP file
5. Upload the module folder to `garrysmod/gamemodes/YOUR_SCHEMA/modules/`
6. Restart your server

### Verify Installation

- Check server console for success messages
- Test new features in-game
- Review module documentation for additional setup

### Module Guidelines

- Start with a few modules rather than installing everything
- Read module instructions for any special setup requirements
- Ensure compatibility with your schema
- Back up your server before adding modules

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

### Best Practices

- Start with basic features before adding complex ones
- Back up your server before making changes
- Test new features regularly
- Listen to player feedback for improvements