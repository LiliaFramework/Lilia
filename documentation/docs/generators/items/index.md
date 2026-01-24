# Item Generators

Interactive tools to help you quickly generate Lilia item definitions for different item types using `lia.item.registerItem()` for programmatic item registration.

---

## Available Item Generators

### 🔫 [Weapons Generator](./weapons.md)
Generate weapon item definitions with ammo tracking, skill requirements, and drop settings.

### 📦 [Stackable Items Generator](./stackable.md)
Generate stackable item definitions for resources, materials, and consumables that can pile up.

### 🔋 [Ammo Generator](./ammo.md)
Generate ammunition item definitions for different weapon types and capacities.

### 🏥 [Aid Items Generator](./aid.md)
Generate health and armor restoration item definitions for medical supplies.

### 👔 [Outfit Generator](./outfit.md)
Generate clothing and outfit item definitions with bodygroup and PAC3 support.

### 💥 [Grenade Generator](./grenade.md)
Generate explosive grenade item definitions with throw physics and sound effects.

### 📚 [Books Generator](./books.md)
Generate readable book item definitions with skill requirements and reading mechanics.

---

## How to Use

1. **Choose an item type** from the list above based on what you want to create
2. **Fill out the form fields** with your desired item properties
3. **Click the generate button** to create the Lua code
4. **Copy the generated code** and paste it into any Lua file that loads during gamemode initialization
5. **Save and restart** your server for the changes to take effect

## Directory Structure

After generating your code, place the code in any Lua file that loads during initialization:

- **Recommended locations**:
  - `gamemode/sh_items.lua` (shared items file)
  - `gamemode/items/init.lua` (items initialization file)
  - Any existing items file in your gamemode

- **Alternative approach**: You can organize items by type in separate files:
  - `gamemode/items/weapons.lua`
  - `gamemode/items/stackable.lua`
  - `gamemode/items/ammo.lua`
  - `gamemode/items/aid.lua`
  - `gamemode/items/outfit.lua`

## Tips

- **Start with basics** - Weapons and aid items are great for new servers
- **Use consistent naming** - Keep unique IDs descriptive and lowercase with underscores
- **Test inventory space** - Different item sizes affect how they fit in player inventories
- **Balance values** - Consider your server's economy and gameplay balance
- **Organize your code** - Group related items together in logical files for easier maintenance

---

*These generators create basic item templates. For advanced features and customization options, refer to the full documentation for each item type.*