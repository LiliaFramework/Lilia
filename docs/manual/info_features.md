# Improves & Fixes
- Fixed Vendor Crash Exploit that used Item Spawning Spam.

- Limited Commands to Permissions, rather than just [IsAdmin](https://wiki.facepunch.com/gmod/Player:IsAdmin) or [IsSuperAdmin](https://wiki.facepunch.com/gmod/Player:IsSuperAdmin).

- Added Several New Commands, both for utility as well as administration.

- Added New Chat Types.

- Made Config Hardcoded, avoiding any potential lack of sync on configuration.

- Improved Logging System, adding a log viewing menu.

- Moved all permissions to CAMI, tying them with UserGroups by doing so.

- Made PlayerModel animations default, instead of Citizen animations, effectively making all models with player animations work by default.

- Improved F1 Menu and Main Menu, allowing for extreme customization by simply modifying your config files.

- Rewrote Notification Derma.

- Expanded on Faction and Classes System, by adding several new parameters for customization. Check [Faction Structure](https://liliaframework.github.io/manual/structure_faction/) and [Class Structure](https://liliaframework.github.io/manual/structure_class/) for more information.

- Fixed Several Exploits within the Inventory, like equipping weapons within inventories that aren't directly connected to the player.

- Added Multiple Player, Character, and Entity Meta to allow for simpler coding.

- Improved Recognition, adding the ability to use Fake Names.

- Adding Voice Tones, allowing for you to Yell, Whisper, and Talk normally over Voice Chat.

- Added an Interaction Menu, allowing players to run customizable tasks by simply walking up to a player and holding tab.

- Improved Scoreboard, adding Players Online, Staff on Duty Online, and Staff Online.

- Added a Crash Screen.

- Added Multi-Faction Support to Doors.

- Added a Third-Person Bind.

- Added a Weapon Item Generator.

- Bettered Protection towards several exploits, both originally on the forked framework as well as on GMOD.

- Categorized Permissions, allowing for stuff like limiting PhysGun Pickups to certain entities or using certain tools.

- Added an Anti-Alting System.

- Added an Anti-Cheat.

- Improved Clientside Performance by Tweaking Rendering.

- Improved Serverside Performance by Optimizing several functions, as well as loops.

- Limited Vendor Editing to Permissions.

- Added Blacklisting and Whitelisting.

- Added Workshop Downloader.

- Added NetMessage Logging.

- Added Console Command Logging.

- Added Downtime Notifier.

- Added Modules Configuration explanations to wiki.

- Added Command List to wiki.

- Added new item bases. Check [Item Structure](https://liliaframework.github.io/manual/structure_items/) for more information.

- Created an extremely detailed wiki so that even the average joe can understand the framework easily.

### Addons with Improved Compatibility

#### Prone Mod

- **Addon URL:** [Prone Mod](https://github.com/gspetrou/Prone-Mod)

- **Compatibility Added:** Made animations reset at proper times.

#### ULX

- **Addon URL:** [ULX](https://steamcommunity.com/sharedfiles/filedetails/?id=557962280)

- **Compatibility Added:** Removed obsolete hooks.

#### SAM

- **Addon URL:** [SAM](https://www.gmodstore.com/market/view/sam)

- **Compatibility Added:** Implemented an auto administrator setter and fixed prop limits to work with SAM.

#### Serverguard

- **Addon URL:** [Serverguard](https://www.gmodstore.com/market/view/serverguard)

- **Compatibility Added:** Allowed CAMI (permissions system) to work with Lilia and Serverguard.

#### Advanced Dupe 2

- **Addon URL:** [Advanced Dupe 2](https://steamcommunity.com/sharedfiles/filedetails/?id=773402917)

- **Compatibility Added:** Fixed several crashing exploits.

#### Advanced Dupe 1

- **Addon URL:** [Advanced Dupe 1](https://steamcommunity.com/sharedfiles/filedetails/?id=163806212)

- **Compatibility Added:** Fixed several crashing exploits.

#### PermaProps

- **Addon URL:** [PermaProps](https://steamcommunity.com/sharedfiles/filedetails/?id=220336312)

- **Compatibility Added:** Removed the ability to PermaProp certain restricted entities.

#### PAC3

- **Addon URL:** [PAC3](https://steamcommunity.com/workshop/filedetails/?id=104691717)

- **Compatibility Added:** Restricted PAC to a flag and permission, and made it reset when needed.

#### Simfphys Vehicles

- **Addon URL:** [Simfphys Vehicles](https://steamcommunity.com/sharedfiles/filedetails/?id=771487490)

- **Compatibility Added:** Added car crash damage and implemented some console commands for performance.

#### Sit Anywhere

- **Addon URL:** [Sit Anywhere](https://steamcommunity.com/sharedfiles/filedetails/?id=108176967)

- **Compatibility Added:** Removed the ability to sit on certain mingy locations and added damage on seats by default.

#### Stormfox 2

- **Addon URL:** [Stormfox 2](https://steamcommunity.com/workshop/filedetails/?id=2447774443)

- **Compatibility Added:** Improved SF2 lighting reload.

#### 3D Stream Radio

- **Addon URL:** [3D Stream Radio](https://steamcommunity.com/sharedfiles/filedetails/?id=246756300)

- **Compatibility Added:** Added ability for radios to save on the map.

#### VCMod

- **Addon URL:** [VCMod Main](https://www.gmodstore.com/market/view/vcmod-main)

- **Compatibility Added:** Added monetary compatibility.

#### VJBase

- **Addon URL:** [VJBase](https://steamcommunity.com/workshop/filedetails/?id=131759821)

- **Compatibility Added:** Made the server enable certain settings by default, improving performance, and removed some harmful hooks.