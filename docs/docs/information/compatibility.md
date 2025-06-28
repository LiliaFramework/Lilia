# Addons with Improved Compatibility

This page details the optional compatibility libraries bundled with Lilia. Each section lists the addon, a brief description of what the library does, and a link to the original addon.

---
## Advanced Duplicator
- **Addon URL:** [Advanced Duplicator](https://steamcommunity.com/sharedfiles/filedetails/?id=163806212)
- **Compatibility Highlights:**
  - Prevents duplication of entities flagged as `NoDuplicate`.
  - Rejects dupes containing props scaled to excessive sizes.
  - Logs attempted exploits and notifies the offending player.

### Explanation
This library hooks into dupe placement checks to stop players from spawning unstable or restricted entities. Oversized props can crash a server, so the compatibility layer validates models before allowing a dupe to spawn.

---
## Advanced Duplicator 2
- **Addon URL:** [Advanced Duplicator 2](https://steamcommunity.com/sharedfiles/filedetails/?id=773402917)
- **Compatibility Highlights:**
  - Performs the same safety checks as the original dupe compatibility library.
  - Respects AD2's internal entity lists when validating dupes.

### Explanation
Advanced Duplicator 2 stores duplication data slightly differently from the original tool. Lilia's library integrates with those systems while still blocking problematic entities and scaling exploits.

---
## DarkRP
- **Addon URL:** [DarkRP](https://github.com/FPtje/DarkRP)
- **Compatibility Highlights:**
  - Provides common helper functions such as `isEmpty`, `findEmptyPos` and text wrapping.
  - Recreates monetary helpers so other DarkRP addons can function.

### Explanation
Some community addons expect DarkRP specific globals or utility functions. This library recreates the most widely used helpers so those addons can run in Lilia without modification.

---
## LVS
- **Addon URL:** [Simfphys Vehicles](https://steamcommunity.com/sharedfiles/filedetails/?id=771487490)
- **Compatibility Highlights:**
  - Filters out self-inflicted damage from the player's own vehicle.

### Explanation
LVS allows players to use high‑speed vehicles. Collisions or explosions from a driver's own vehicle can sometimes damage them unexpectedly. The compatibility hook prevents such self‑damage during normal gameplay.

---
## PAC3
- **Addon URL:** [PAC3](https://steamcommunity.com/workshop/filedetails/?id=104691717)
- **Compatibility Highlights:**
  - Networks player outfit parts reliably between server and clients.
  - Adds commands for repairing, enabling and disabling PAC3.

### Explanation
PAC3 outfits need to be synchronized carefully to avoid missing or broken parts. This library exposes helper methods to add, remove, or reset parts and registers network messages to keep every client in sync.

---
## PermaProps
- **Addon URL:** [PermaProps](https://steamcommunity.com/sharedfiles/filedetails/?id=220336312)
- **Compatibility Highlights:**
  - Blocks saving Lilia's persistent entities or map-created props as permanent.

### Explanation
Permanent props can conflict with Lilia's own persistence system. The compatibility hook checks the target entity and prevents PermaProps from saving anything that could break future loads.

---
## Prone Mod
- **Addon URL:** [Prone Mod](https://github.com/gspetrou/Prone-Mod)
- **Compatibility Highlights:**
  - Forces players out of prone when they die or change character.

### Explanation
Without this patch, players could remain stuck in the prone state when they respawn or switch characters. The library listens for these events and exits prone automatically.

---
## SAM
- **Addon URL:** [SAM](https://www.gmodstore.com/market/view/sam)
- **Compatibility Highlights:**
  - Recreates SAM chat commands through Lilia's command system.
  - Checks staff privileges before executing sensitive commands.

### Explanation
Lilia integrates SAM so that existing SAM commands work alongside the framework's permission system. By mirroring SAM commands and verifying permissions, server admins can continue using familiar tools.

---
## ServerGuard
- **Addon URL:** [ServerGuard](https://www.gmodstore.com/market/view/serverguard)
- **Compatibility Highlights:**
  - Disables the built-in restrictions plugin so Lilia can manage permissions.

### Explanation
ServerGuard's restriction plugin can conflict with Lilia's access controls. Turning it off ensures a single consistent permission system while still allowing the rest of ServerGuard to operate.

---
## Simfphys
- **Addon URL:** [Simfphys Vehicles](https://steamcommunity.com/sharedfiles/filedetails/?id=771487490)
- **Compatibility Highlights:**
  - Applies crash damage to drivers when vehicles collide.
  - Adds configuration options for seat damage and entry delays.
  - Registers a privilege for editing vehicles.

### Explanation
Simfphys provides an extensive vehicle system. Lilia's library adds more realistic crash damage and exposes configuration variables to fine‑tune vehicle behavior. It also ties advanced editing to a specific admin privilege.

---
## Sit Anywhere
- **Addon URL:** [Sit Anywhere](https://steamcommunity.com/sharedfiles/filedetails/?id=108176967)
- **Compatibility Highlights:**
  - Sets recommended console variables on load.
  - Prevents sitting on players or vehicles.
  - Enables seat damage by default.

### Explanation
These adjustments keep Sit Anywhere from being exploited for trolling. By limiting where players can sit and enabling damage, seats remain balanced while still useful for roleplay scenarios.

---
## ULX
- **Addon URL:** [ULX](https://steamcommunity.com/sharedfiles/filedetails/?id=557962280)
- **Compatibility Highlights:**
  - Removes obsolete hooks that conflict with CAMI.
  - Synchronizes CAMI groups and privileges with ULX.

### Explanation
ULX uses the CAMI system for permissions. The compatibility layer keeps CAMI and ULX in sync so admin ranks and privileges behave as expected in Lilia.

---
## VCMod
- **Addon URL:** [VCMod Main](https://www.gmodstore.com/market/view/vcmod-main)
- **Compatibility Highlights:**
  - Redirects VCMod money hooks to a character's funds.

### Explanation
Vehicle purchases and upgrades in VCMod should use the player's roleplay money. This library forwards all money checks and transactions to the character system.

---
## VJBase
- **Addon URL:** [VJBase](https://steamcommunity.com/workshop/filedetails/?id=131759821)
- **Compatibility Highlights:**
  - Blocks dangerous network messages.
  - Applies safer default settings and removes heavy hooks.

### Explanation
VJBase NPCs can send network messages that are exploitable on unprotected servers. By intercepting those messages and disabling costly hooks, the library keeps VJBase stable and secure.

---
