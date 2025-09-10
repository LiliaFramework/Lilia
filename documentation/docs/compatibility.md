# Addon Compatibility

This page documents the optional compatibility libraries bundled with Lilia. These libraries greatly expand support for a variety of popular addons used across the Garry's Mod community.

---

## Overview

The compatibility layer provides seamless integration with popular Garry's Mod addons, covering administration suites, vehicle frameworks, outfit systems, and more. Installing these addons alongside Lilia will automatically enable the related integration without additional configuration.

---

## Compatibility Details

The following sections detail the specific compatibility features provided for each supported addon.

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

### DarkRP

**Purpose**

Provides utility shims and compatibility functions for addons designed for DarkRP.

**Features**

* Provides helper functions like `isEmpty`, `findEmptyPos`, and text wrapping
* Implements `formatMoney`, `createEntity`, and `createCategory` shims
* Recreates widely used DarkRP globals and utilities

**Technical Details**

Recreates widely used DarkRP globals and utilities so community & GMODStore addons can run under Lilia without modification.

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

Provides comprehensive integration with the SAM admin suite.

**Features**

* Recreates SAM chat commands via Lilia's command system
* Includes utilities such as playtime tracking and blind/unblind commands
* Checks staff privileges before executing sensitive commands
* Provides configuration options for admin-only notifications and staff enforcement
* Adds cleardecals command for server maintenance

**Technical Details**

Mirrors SAM commands and enforces Lilia's permission checks so admins can use familiar tools seamlessly. Includes additional configuration options and utility commands for enhanced server management.

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

Provides limited integration with the ULX admin suite.

**Warning**

ULX has limited compatibility with Lilia. While basic command integration is provided, ULX's version of CAMI is extremely old and may cause permission check issues.

**Features**

* Provides basic command bridging for admin functions
* Integrates with Lilia's permission system where possible

**Technical Details**

Limited integration is provided for ULX commands, but due to compatibility issues with ULX's outdated CAMI version, it's recommended to use Lilia's built-in admin menu or another modern admin suite like SAM instead.

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
