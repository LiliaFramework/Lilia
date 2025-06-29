# Addons with Improved Compatibility

This page details the optional compatibility libraries bundled with Lilia. Each section below is a standalone sub-section named after the addon, with its URL, key compatibility highlights, and a brief explanation.

## [Advanced Duplicator](https://steamcommunity.com/sharedfiles/filedetails/?id=163806212)

**Compatibility Highlights:**

* Prevents duplication of entities flagged as `NoDuplicate`.
* Rejects dupes containing props scaled to excessive sizes.
* Logs attempted exploits and notifies the offending player.

**Detailed Explanation:**

Hooks into dupe placement checks to stop players from spawning unstable or restricted entities. Oversized props can crash a server, so this layer validates models before allowing a dupe to spawn.

---

## [Advanced Duplicator 2](https://steamcommunity.com/sharedfiles/filedetails/?id=773402917)

**Compatibility Highlights:**

* Performs the same safety checks as the original dupe compatibility library.
* Respects AD2’s internal entity lists when validating dupes.

**Detailed Explanation:**

Integrates with AD2’s duplication data system while still blocking problematic entities and scaling exploits.

---

## [DarkRP](https://github.com/FPtje/DarkRP)

**Compatibility Highlights:**

* Provides helper functions like `isEmpty`, `findEmptyPos`, and text wrapping.
* Recreates monetary helpers so other DarkRP addons can function.

**Detailed Explanation:**

Recreates widely used DarkRP globals and utilities so community addons run under Lilia without modification.

---

## [LVS (Simfphys Vehicles)](https://steamcommunity.com/sharedfiles/filedetails/?id=771487490)

**Compatibility Highlights:**

* Filters out self-inflicted damage from the player’s own vehicle.

**Detailed Explanation:**

Prevents players from being damaged by their own high-speed vehicle collisions or explosions during normal gameplay.

---

## [PAC3](https://steamcommunity.com/workshop/filedetails/?id=104691717)

**Compatibility Highlights:**

* Networks player outfit parts reliably between server and clients.
* Adds commands for repairing, enabling, and disabling PAC3.

**Detailed Explanation:**

Exposes helper methods and network messages to synchronize PAC3 outfits, preventing missing or broken parts on clients.

---

## [PermaProps](https://steamcommunity.com/sharedfiles/filedetails/?id=220336312)

**Compatibility Highlights:**

* Blocks saving Lilia’s persistent entities or map-created props as permanent.

**Detailed Explanation:**

Prevents PermaProps from saving entities that would conflict with Lilia’s persistence system, avoiding errors on future loads.

---

## [Prone Mod](https://github.com/gspetrou/Prone-Mod)

**Compatibility Highlights:**

* Forces players out of prone when they die or change character.

**Detailed Explanation:**

Listens for death and character-switch events, automatically exiting prone to avoid players being stuck on respawn.

---

## [SAM](https://www.gmodstore.com/market/view/sam)

**Compatibility Highlights:**

* Recreates SAM chat commands via Lilia’s command system.
* Checks staff privileges before executing sensitive commands.

**Detailed Explanation:**

Mirrors SAM commands and enforces Lilia’s permission checks so admins can use familiar tools seamlessly.

---

## [ServerGuard](https://www.gmodstore.com/market/view/serverguard)

**Compatibility Highlights:**

* Disables the built-in restrictions plugin so Lilia can manage permissions.

**Detailed Explanation:**

Turns off ServerGuard’s restriction module to ensure a single consistent permission system while retaining other features.

---

## [Simfphys Vehicles](https://steamcommunity.com/sharedfiles/filedetails/?id=771487490)

**Compatibility Highlights:**

* Applies crash damage to drivers on vehicle collisions.
* Adds configuration options for seat damage and entry delays.
* Registers a privilege for editing vehicles.

**Detailed Explanation:**

Enhances Simfphys with realistic crash damage, configurable behavior, and ties vehicle editing to an admin privilege.

---

## [Sit Anywhere](https://steamcommunity.com/sharedfiles/filedetails/?id=108176967)

**Compatibility Highlights:**

* Sets recommended console variables on load.
* Prevents sitting on players or vehicles.
* Enables seat damage by default.

**Detailed Explanation:**

Adjusts console settings and seat interactions to prevent trolling while maintaining roleplay utility.

---

## [ULX](https://steamcommunity.com/sharedfiles/filedetails/?id=557962280)

**Compatibility Highlights:**

* Removes obsolete hooks that conflict with recent versions of CAMI.
* Synchronizes CAMI groups and privileges with ULX.

**Detailed Explanation:**

Keeps CAMI and ULX in sync so admin ranks and permissions behave correctly within Lilia.

---

## [VCMod Main](https://www.gmodstore.com/market/view/vcmod-main)

**Compatibility Highlights:**

* Redirects VCMod money hooks to a character’s funds.

**Detailed Explanation:**

Forwards vehicle purchase and upgrade transactions to the roleplay money system, ensuring consistency with character finances.

---

## [VJBase](https://steamcommunity.com/workshop/filedetails/?id=131759821)

**Compatibility Highlights:**

* Blocks dangerous network messages.
* Applies safer default settings and removes heavy hooks.

**Detailed Explanation:**

Intercepts exploitable VJBase network messages and disables resource-intensive hooks to maintain server security and performance.