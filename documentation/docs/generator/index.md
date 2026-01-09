# Code Generators

Interactive tools to help you quickly generate Lilia framework definitions. These generators create properly formatted Lua code that you can copy and paste into your gamemode files.

---

## Available Generators

### 🎯 [Faction Generator](./faction.md)
Generate faction definitions with customizable properties like models, weapons, health, armor, and access controls.

### 👥 [Class Generator](./class.md)
Generate class definitions that belong to factions, with inheritance from parent factions and specialized properties.

### 📊 [Attribute Generator](./attribute.md)
Generate character attribute definitions that affect gameplay mechanics and character progression.

### 📦 [Item Generators](./items/)
Generate item definitions for different item types including weapons, stackable items, ammo, aid items, and outfits.

---

## How to Use

1. **Choose a generator** from the list above based on what you want to create
2. **Fill out the form fields** with your desired properties
3. **Click the generate button** to create the Lua code
4. **Copy the generated code** and paste it into the appropriate file in your gamemode
5. **Save and restart** your server for the changes to take effect

## Directory Structure

After generating your code, place the files in these directories:

- **Factions**: `gamemode/factions/your_faction.lua`
- **Classes**: `gamemode/classes/your_class.lua`
- **Attributes**: `gamemode/attributes/your_attribute.lua`
- **Items**: `gamemode/items/item_type/your_item.lua`

## Tips

- **Start with factions** - Create your factions first, then classes that belong to them
- **Use meaningful names** - Choose uniqueIDs that are descriptive and easy to reference
- **Test incrementally** - Generate one definition at a time and test it before creating more
- **Check inheritance** - Classes inherit properties from their parent factions unless overridden

---

*These generators are designed to get you started quickly. For advanced features and customization options, refer to the full documentation for each definition type.*