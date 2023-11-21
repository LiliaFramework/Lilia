## Module Example
```lua
--------------------------------------------------------------------------------------------------------------------------
MODULE.name = "Skills"
--------------------------------------------------------------------------------------------------------------------------
MODULE.author = "@liliaplayer > Discord"
--------------------------------------------------------------------------------------------------------------------------
MODULE.desc = "Adds Skills."
--------------------------------------------------------------------------------------------------------------------------
MODULE.DevMode = false
--------------------------------------------------------------------------------------------------------------------------
lia.util.include("sh_config.lua")
--------------------------------------------------------------------------------------------------------------------------
lia.util.include("cl_module.lua")
--------------------------------------------------------------------------------------------------------------------------
```
[View source »](https://github.com/Lilia-Framework/Lilia/blob/2.0/lilia/modules/roleplay/modules/skills/sh_module.lua)


## Module Configuration

- **`MODULE.name`**: Specifies the name of the module, which is "Skills" in this case. This variable identifies the module.

- **`MODULE.author`**: Indicates the author of the module. It can be a STEAMID or Name. Replace "STEAM_0:1:176123778" with the actual author information.

- **`MODULE.desc`**: Provides a brief description of the module's purpose. In this case, it states that the module adds skills functionality to the framework.

- **`MODULE.DevMode`**: An example variable tied to this specific module. It's currently set to `false`.

- **`lia.util.include("sh_config.lua")`**: Demonstrates an example of file inclusion. This line includes the 'sh_config.lua' file for this module.

- **[Default Module List](https://github.com/Lilia-Framework/Lilia/wiki/Module-List)**: This link directs you to the Module List.
