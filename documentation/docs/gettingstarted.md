# Getting Started

This step-by-step guide will help you set up your first Lilia roleplay server. We'll start with the basics and build up to advanced features. Each section includes simple instructions and examples.

---

## Step 1: Installation

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

### Quick Setup

1. Create a `factions` folder in `garrysmod/gamemodes/YOUR_SCHEMA/schema/factions/`
2. Create `citizen.lua` with basic faction code
3. Restart your server

For comprehensive faction creation instructions, see the [Factions Guide](guides/factions.md).

---

## Step 4: Create Classes (Optional)

Classes are specialized roles within factions. Think of them as sub-factions or regiments - specialized units within a larger organization.

Skip this if you only need basic factions. Classes work well for military, law enforcement, or complex organizational structures.

For detailed class creation instructions, see the [Classes Guide](guides/classes.md).

---

## Step 5: Add Items

Items are the core of your roleplay server's economy and gameplay. Create weapons, consumables, outfits, and more.

### Quick Setup

1. Create an `items` folder in `garrysmod/gamemodes/YOUR_SCHEMA/schema/items/`
2. Create item files for your server
3. Restart your server

For comprehensive item creation instructions, see the [Items Guide](guides/items.md).

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

For module development instructions, see the [Modules Guide](guides/modules.md).

---

## Step 7: Configure Compatibility (Optional)

Lilia includes compatibility libraries for popular addons like DarkRP, ULX, PAC3, and more.

For compatibility setup instructions, see the [Compatibility Guide](guides/compatibility.md).

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