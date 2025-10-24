# Addon Compatibility

This page documents the optional compatibility libraries bundled with Lilia. These libraries greatly expand support for a variety of popular addons used across the Garry's Mod community.

---

## Overview

The compatibility system provides seamless integration between Lilia and popular Garry's Mod addons. It automatically detects installed addons, handles version compatibility, and provides API bridging to ensure smooth operation without manual configuration. The system prevents addon conflicts with intelligent override management, maps functions and events between Lilia and addon systems, and provides detailed logging with automatic disable mechanisms to maintain stability. This enables you to use your favorite addons with Lilia while maintaining framework integrity and server performance.

---

## Compatibility Details

The following sections detail the specific compatibility features provided for each supported addon.

### DarkRP

**Purpose**

Provides comprehensive compatibility for DarkRP and most DarkRP addons, ensuring they work out of the box with Lilia.

**Features**

* Provides helper functions like `isEmpty`, `findEmptyPos`, and text wrapping
* Implements `formatMoney`, `createEntity`, and `createCategory` shims
* Recreates widely used DarkRP globals and utilities
* **Most DarkRP addons work out of the box** without any modifications required
* Seamless integration with DarkRP's job system, money system, and core mechanics

**Technical Details**

Recreates widely used DarkRP globals and utilities so community & GMODStore addons can run under Lilia without modification. The compatibility layer is designed to be comprehensive, covering the vast majority of DarkRP addons and ensuring they function identically to how they would on a standard DarkRP server.

---

### Advanced Duplicator

**Purpose**

Provides security and stability improvements for the Advanced Duplicator addon.

**Features**

* Prevents duplication of entities flagged as `NoDuplicate`
* Rejects dupes containing props scaled to excessive sizes
* Logs attempted exploits and notifies the offending player

**Technical Details**

Hooks into dupe placement checks to stop players from spawning unstable or restricted entities. Oversized props can crash a server, so this layer validates models before allowing a dupe to spawn.

---

### Advanced Duplicator 2

**Purpose**

Provides security and stability improvements for the Advanced Duplicator 2 addon.

**Features**

* Performs the same safety checks as the original dupe compatibility library
* Respects AD2's internal entity lists when validating dupes

**Technical Details**

Integrates with AD2's duplication data system while still blocking problematic entities and scaling exploits.

---

### ARCCW

**Purpose**

Configures ARCCW weapon framework for optimal roleplay compatibility.

**Features**

* Disables ARCCW's HUD and crosshair overrides to prevent conflicts with Lilia's UI
* Configures weapon dropping, attachment inventory, and malfunction settings
* Sets recommended console variables for optimal integration

**Technical Details**

Automatically configures ARCCW console variables to work seamlessly with Lilia's roleplay framework, ensuring weapons behave appropriately in a roleplay environment.

---

### CAMI

**Purpose**

Provides integration between CAMI permission system and Lilia's administrator framework.

**Features**

* Integrates CAMI permission system with Lilia's administrator framework
* Handles privilege registration and usergroup management automatically
* Provides compatibility for addons that rely on CAMI for permission checks

**Technical Details**

Bridges CAMI's permission system with Lilia's built-in administrator system, allowing addons that depend on CAMI to function properly while maintaining Lilia's permission structure.

---

### LVS

**Purpose**

Provides safety improvements for the LVS vehicle framework.

**Features**

* Filters out self-inflicted damage from the player's own vehicle

**Technical Details**

Stops collisions or weapons fired from your own LVS vehicle from injuring you. Drivers can still take damage if an impact occurs close to their seat.

---

### PAC3

**Purpose**

Provides comprehensive integration with the PAC3 outfit system.

**Features**

* Networks player outfit parts reliably between server and clients
* Adds commands for repairing, enabling, and disabling PAC3
* Honors the `BlockPackURLoad` configuration to restrict loading outfits from URLs
* Registers the "Staff Permissions - Can Use PAC3" privilege and the `P` flag for access control

**Technical Details**

Exposes helper methods and network messages to synchronize PAC3 outfits, preventing missing or broken parts on clients.

---

### PermaProps

**Purpose**

Provides management and safety features for the PermaProps persistence addon.

**Features**

* Blocks saving Lilia's persistent entities or map-created props as permanent
* Warns about overlapping saves and logs who saved each PermaProp

**Technical Details**

Prevents PermaProps from saving entities that would conflict with Lilia's persistence system, avoiding errors on future loads.

---

### Prone Mod

**Purpose**

Provides automatic recovery features for the Prone Mod addon.

**Features**

* Forces players out of prone when they die or change character

**Technical Details**

Listens for death and character-switch events, automatically exiting prone to avoid players being stuck on respawn.

---

### SAM

**Purpose**

Provides comprehensive integration with the SAM admin suite, combining SAM's powerful admin tools with Lilia's admin system for full compatibility.

**Features**

* Recreates SAM chat commands via Lilia's command system
* **Full integration with Lilia's admin system** - SAM and Lilia work together seamlessly
* Includes utilities such as playtime tracking and blind/unblind commands
* Checks staff privileges before executing sensitive commands
* Provides configuration options for admin-only notifications and staff enforcement
* Adds cleardecals command for server maintenance
* **Combines the best of both systems** - SAM's advanced admin features with Lilia's modern framework

**Technical Details**

Mirrors SAM commands and enforces Lilia's permission checks so admins can use familiar tools seamlessly. The integration layer ensures that SAM's powerful admin capabilities work perfectly with Lilia's permission system, character management, and modern architecture. This provides administrators with the full feature set of both systems working in harmony.

---

### Simfphys Vehicles

**Purpose**

Provides comprehensive integration with the Simfphys vehicle framework.

**Features**

* Applies crash damage to drivers on vehicle collisions
* Blocks Sit Anywhere seating on Simfphys vehicles
* Adds configuration options for seat damage and entry delays
* Requires privilege for editing vehicles
* Enables trunk functionality for Simfphys vehicles

**Technical Details**

Drivers only take damage when the vehicle is struck near their seat and a configurable delay is applied before entering cars. Vehicle editing requires the "canEditSimfphysCars" privilege, and vehicles are automatically configured to work with Lilia's trunk system.

---

### Sit Anywhere

**Purpose**

Provides safety and anti-abuse features for the Sit Anywhere addon.

**Features**

* Sets recommended console variables on load
* Prevents sitting on players or vehicles
* Applies anti-prop-surf and tool-abuse protections
* Enables seat damage by default

**Technical Details**

Adjusts console settings and seat interactions to prevent trolling while maintaining roleplay utility.

---

### ServerGuard

**Purpose**

Provides integration between ServerGuard admin suite and Lilia's administrator framework.

**Features**

* Integrates ServerGuard permission system with Lilia's administrator framework
* Provides command bridging for admin functions between the two systems
* Handles privilege registration and permission management automatically

**Technical Details**

Bridges ServerGuard's admin system with Lilia's built-in administrator framework, allowing seamless integration of ServerGuard commands and permissions while maintaining Lilia's permission structure.

---

### ULX

**Purpose**

Provides integration with the ULX admin suite, combining ULX's admin tools with Lilia's admin system for enhanced functionality.

**Features**

* **Full integration with Lilia's admin system** - ULX and Lilia work together seamlessly
* Provides comprehensive command bridging for admin functions
* Integrates with Lilia's permission system for unified admin management
* **Combines ULX's proven admin tools with Lilia's modern framework**
* Maintains ULX's familiar command structure while leveraging Lilia's advanced features

**Technical Details**

The integration layer ensures that ULX's admin capabilities work perfectly with Lilia's permission system, character management, and modern architecture. While ULX's CAMI version may be older, the compatibility layer bridges these differences to provide a seamless experience. This allows administrators to use ULX's familiar interface while benefiting from Lilia's enhanced admin system and modern framework features.

---

### VCMod

**Purpose**

Provides financial integration for the VCMod vehicle framework.

**Features**

* Redirects VCMod money hooks to a character's funds
* Checks vehicle purchases against the character's wallet

**Technical Details**

Forwards vehicle purchase and upgrade transactions to the roleplay money system, ensuring consistency with character finances.

---

### VJBase

**Purpose**

Provides security and performance improvements for the VJBase NPC framework.

**Features**

* Removes unprotected VJBase spawners and flags NPCs notarget
* Blocks dangerous network messages
* Applies safer default settings and removes heavy hooks
* Registers privilege for VJBase NPC properties
* Optimizes processing time based on player count

**Technical Details**

Intercepts exploitable VJBase network messages and disables resource-intensive hooks to maintain server security and performance. Automatically removes dangerous spawners and optimizes performance based on server population.
