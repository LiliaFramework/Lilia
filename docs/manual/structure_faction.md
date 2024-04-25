# Structure - Faction

```lua
FACTION.name = "Minecrafters"
FACTION.desc = "Surviving and crafting in the blocky world."
FACTION.isDefault = false
FACTION.color = Color(0, 255, 0)
FACTION.models = {"minecraft_model_1.mdl", "minecraft_model_2.mdl", "minecraft_model_3.mdl",}
FACTION.weapons = {"stone_sword", "iron_pickaxe"}
FACTION.pay = 50
FACTION.payTimer = 3600
FACTION_MINECRAFTER = FACTION.index
```

#Faction Variables

- **FACTION.name**: The name of your faction.

- **FACTION.desc**: A description or lore for your faction.

- **FACTION.isDefault**: Indicates whether this is the default faction. Set to true if it's the default faction; otherwise, set to false. Using isDefault removes the need for a whitelist.

- **FACTION.color**: The color associated with your faction. This can be used for faction-specific coloring or theming. 

- **FACTION.models**: Models that players in this faction can use. These are the character models available to faction members.

- **FACTION.weapons**: Weapons that players in this faction can use. This can include weapon IDs or references to the weapons available to faction members. **Optional**

- **FACTION.pay**: The payment amount associated with the faction. This represents any in-game currency or rewards tied to being a member of this faction. **Optional**

- **FACTION.payTimer**: The timer or schedule for payments. Specify the interval in seconds for payments to occur. For example, if payments are made every 30 minutes, set this value to 1800 (30 minutes \* 60 seconds). **Optional**

- **FACTION.limit**: The limit of players in this faction at a given time. This restricts how many players can be members of this faction simultaneously. **Optional**

- **FACTION.oneCharOnly**: Adds a limit that prevents a player from having more than one character in a faction when being transferred. **Optional**

- **FACTION.health**: This variable represents the default health of players in the faction. You can set a numerical value, such as 100, to specify the default health. Players in this faction will start with this amount of health unless modified by other in-game factors. **Optional**

- **FACTION.armor**: Similar to health, this variable represents the default armor value of players in the faction. Armor can provide additional protection against damage. Set a numerical value, such as 50, to determine the default armor value for faction members. **Optional**

- **FACTION.scale**: Scale affects the size of the player model. You can set a value like 1.2 to make faction members slightly larger or 0.8 to make them smaller. This can be used for visual customization. **Optional**
- **FACTION.runSpeed**: This variable determines the default running speed of players in the faction. You can set a numerical value like 300 to specify the speed in units per second. **Optional**

- **FACTION.runSpeedMultiplier**: When set to true, this indicates that the runSpeed value should be multiplied by the default speed set in the game configuration. When set to false, it means that the runSpeed value should directly set the running speed, overriding the game's default. **Optional**

- **FACTION.walkSpeed**: Similar to runSpeed, this variable sets the default walking speed of players in the faction. You can set a numerical value like 150 to specify the walking speed in units per second. **Optional**

- **FACTION.walkSpeedMultiplier**: Like runSpeedMultiplier, when set to true, it multiplies the walkSpeed value by the default walk speed set in the game configuration. When set to false, it directly sets the walking speed. **Optional**

- **FACTION.jumpPower**: This variable determines the default jump power of players in the faction. Jump power controls how high a player can jump. You can set a numerical value like 200 to specify the jump power.**Optional**

- **FACTION.jumpPowerMultiplier**: When set to true, jumpPower is multiplied by the default jump power configured in the game. When set to false, it directly sets the jump power for faction members. **Optional**

- **FACTION.bloodcolor**: This variable allows you to specify the blood color of players in the faction when they take damage. You can use the blood enums provided by Garry's Mod, which are listed in [Blood Color ENUMS](https://wiki.facepunch.com/gmod/Enums/BLOOD_COLOR). For example, you can set it to BLOOD_COLOR_YELLOW to make the faction's blood appear yellow when they are injured. **Optional**

- **FACTION.bodyGroups**: This variable allows you to define faction-specific bodygroups for player models upon spawn. Bodygroups control the appearance and configuration of specific parts of the player model. You can specify the bodygroups using a table format. Each entry in the table represents a bodygroup and its corresponding value. **Optional**

- **FACTION.index**: The Unique ID (UniqueID) of the faction. This is a unique identifier used to distinguish this faction from others. It corresponds to a Garry's Mod team index or identifier.
