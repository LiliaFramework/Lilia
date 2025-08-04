# Addons with Improved Compatibility

This page details the optional compatibility libraries bundled with Lilia. These libraries greatly expand support for a variety of popular addons used across the Garry's Mod community. Each section below is a standalone sub-section named after the addon, with its URL, key compatibility highlights, and a brief explanation.

The compatibility layer covers administration suites such as SAM, vehicle frameworks like **LVS**, **Simfphys**, and **VCMod**, outfit systems including PAC3, and more. Installing these addons alongside Lilia will automatically enable the related integration.

In recent releases the compatibility set has grown even larger. Popular community addons now work out of the box:

- **Advanced Duplicator 2** and **Advanced Duplicator** integration

- **PAC3** outfit synchronization

- **SAM** admin suite

- **PermaProps** management helpers

- **Prone Mod** automatic recovery

- **DarkRP** utility shims

- **Sit Anywhere** seat protections

- **LVS**, **Simfphys**, and **VCMod** vehicle frameworks

- **VJBase** NPC base improvements

Simply install these addons and the matching compatibility layer will load automatically.

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

* Implements `formatMoney`, `createEntity`, and `createCategory` shims so other addons can function.

**Detailed Explanation:**

Recreates widely used DarkRP globals and utilities so community addons run under Lilia without modification.

---

## [LVS](https://steamcommunity.com/workshop/browse/?appid=4000&searchtext=LVS+Base)

**Compatibility Highlights:**

* Filters out self-inflicted damage from the player's own vehicle.

**Detailed Explanation:**

Stops collisions or weapons fired from your own LVS vehicle from injuring you. Drivers can still take damage if an impact occurs close to their seat.

---

## [PAC3](https://steamcommunity.com/workshop/filedetails/?id=104691717)

**Compatibility Highlights:**

* Networks player outfit parts reliably between server and clients.

* Adds commands for repairing, enabling, and disabling PAC3.

* Honors the `BlockPackURLoad` configuration to restrict loading outfits from URLs.

* Registers the "Staff Permissions - Can Use PAC3" privilege and the `P` flag for access control.

**Detailed Explanation:**

Exposes helper methods and network messages to synchronize PAC3 outfits, preventing missing or broken parts on clients.

---

## [PermaProps](https://steamcommunity.com/sharedfiles/filedetails/?id=220336312)

**Compatibility Highlights:**

* Blocks saving Lilia’s persistent entities or map-created props as permanent.

* Warns about overlapping saves and logs who saved each PermaProp.

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

* Includes utilities such as playtime tracking and blind commands.

* Checks staff privileges before executing sensitive commands.

**Detailed Explanation:**

Mirrors SAM commands and enforces Lilia’s permission checks so admins can use familiar tools seamlessly.


## [Simfphys Vehicles](https://steamcommunity.com/sharedfiles/filedetails/?id=771487490)

**Compatibility Highlights:**

* Applies crash damage to drivers on vehicle collisions.

* Blocks Sit Anywhere seating on Simfphys vehicles.

* Adds configuration options for seat damage and entry delays.

* Registers a privilege for editing vehicles.

**Detailed Explanation:**

Drivers only take damage when the vehicle is struck near their seat and a configurable delay is applied before entering cars. Vehicle editing remains gated behind an admin privilege.

---

## [Sit Anywhere](https://steamcommunity.com/sharedfiles/filedetails/?id=108176967)

**Compatibility Highlights:**

* Sets recommended console variables on load.

* Prevents sitting on players or vehicles.

* Applies anti-prop-surf and tool-abuse protections.

* Enables seat damage by default.

**Detailed Explanation:**

Adjusts console settings and seat interactions to prevent trolling while maintaining roleplay utility.

---

## ULX

> **Warning**

> ULX is not compatible with Lilia because its version of CAMI is extremely old and breaks permission checks.

Use Lilia's built-in admin menu or another modern admin suite like SAM instead.

## [VCMod Main](https://www.gmodstore.com/market/view/vcmod-main)

**Compatibility Highlights:**

* Redirects VCMod money hooks to a character’s funds.

* Checks vehicle purchases against the character's wallet.

**Detailed Explanation:**

Forwards vehicle purchase and upgrade transactions to the roleplay money system, ensuring consistency with character finances.

---

## [VJBase](https://steamcommunity.com/workshop/filedetails/?id=131759821)

**Compatibility Highlights:**

* Removes unprotected VJBase spawners and flags NPCs notarget.

* Blocks dangerous network messages.

* Applies safer default settings and removes heavy hooks.

**Detailed Explanation:**

Intercepts exploitable VJBase network messages and disables resource-intensive hooks to maintain server security and performance.

---
