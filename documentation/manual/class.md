# CLASS Example

```lua
CLASS.name = "Steve"
CLASS.desc = "The Steves of the Minecrafter Faction."
CLASS.isDefault = true
CLASS.faction = FACTION_MINECRAFTER
CLASS.color = Color(0, 255, 0)
CLASS.weapons = {"gold_pickaxe", "netherite_spade"}
CLASS.pay = 50
CLASS.payTimer = 3600
CLASS_STEVE = CLASS.index
```

[View source »](https://github.com/Lilia-Framework/Lilia/blob/main/lilia/modules/core/teams/libraries/server.lua#L110)

## CLASS Variables

- **CLASS.name**: The name of your class.

- **CLASS.desc**: A description of your class.

- **CLASS.isDefault**: Indicates whether this is the default class. Set to true if it's the default class, allowing anyone to join.

- **CLASS.color**: _(Optional)_ The color associated with your class. This can be used for class-specific coloring.

- **CLASS.weapons**: _(Optional)_ Weapons that players in this class can use. This can include weapon IDs or references to the weapons available to class members.

- **CLASS.pay**: _(Optional)_ The payment amount associated with the class. This represents any in-game currency or rewards tied to being a member of this class.

- **CLASS.payTimer**: _(Optional)_ The timer or schedule for payments. Specify the interval in seconds for payments to occur. For example, if payments are made every 30 minutes, set this value to 1800 (30 minutes \* 60 seconds).

- **CLASS.limit**: _(Optional)_ The limit of players in this class at a given time. This restricts how many players can be members of this class simultaneously.

- **CLASS.health**: _(Optional)_ This variable represents the default health of players in the class. You can set a numerical value, such as 100, to specify the default health. Players in this class will start with this amount of health unless modified by other in-game factors. **Default is 100**.

- **CLASS.armor**: _(Optional)_ Similar to health, this variable represents the default armor value of players in the class. Armor can provide additional protection against damage. Set a numerical value, such as 50, to determine the default armor value for class members. **Default is 0**.

- **CLASS.scale**: _(Optional)_ Scale affects the size of the player model. You can set a value like 1.2 to make class members slightly larger or 0.8 to make them smaller. This can be used for visual customization. **Default is 1**.

- **CLASS.runSpeed**: _(Optional)_ This variable determines the default running speed of players in the class. You can set a numerical value like 300 to specify the speed in units per second. **Default is lia.config.RunSpeed or 1 if multiplier is enabled**.

- **CLASS.runSpeedMultiplier**: _(Optional)_ When set to true, this indicates that the runSpeed value should be multiplied by the default speed set in the game configuration. When set to false, it means that the runSpeed value should directly set the running speed, overriding the game's default. **Default is false**.

- **CLASS.walkSpeed**: _(Optional)_ Similar to runSpeed, this variable sets the default walking speed of players in the class. You can set a numerical value like 150 to specify the walking speed in units per second. **Default is lia.config.WalkSpeed or 1 if multiplier is enabled**.

- **CLASS.walkSpeedMultiplier**: _(Optional)_ Like runSpeedMultiplier, when set to true, it multiplies the walkSpeed value by the default walk speed set in the game configuration. When set to false, it directly sets the walking speed. **Default is false**.

- **CLASS.jumpPower**: _(Optional)_ This variable determines the default jump power of players in the class. Jump power controls how high a player can jump. You can set a numerical value like 200 to specify the jump power. **Default is 160 or 1 if multiplier is enabled**.

- **CLASS.jumpPowerMultiplier**: _(Optional)_ When set to true, jumpPower is multiplied by the default jump power configured in the game. When set to false, it directly sets the jump power for class members. **Default is false**.

- **CLASS.bloodcolor**: _(Optional)_ This variable allows you to specify the blood color of players in the class when they take damage. You can use the blood enums provided by Garry's Mod, which are listed in [Blood Color ENUMS](https://wiki.facepunch.com/gmod/Enums/BLOOD_COLOR). For example, you can set it to BLOOD_COLOR_YELLOW to make the class's blood appear yellow when they are injured. **Default is BLOOD_COLOR_RED**.

- **CLASS.bodyGroups**: _(Optional)_ This variable allows you to define class-specific bodygroups for player models upon spawn. Bodygroups control the appearance and configuration of specific parts of the player model. You can specify the bodygroups using a table format. Each entry in the table represents a bodygroup and its corresponding value.

- **CLASS.model**: _(Optional)_ This variable allows you to define class-specific models that get set on spawn.

- **CLASS.index**: The Unique ID (UniqueID) of the class. This is a unique identifier used to distinguish this class from others.
