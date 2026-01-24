# Compatibility

This guide covers the optional compatibility libraries bundled with Lilia. These libraries greatly expand support for a variety of popular addons used across the Garry's Mod community.

## Overview

The compatibility system provides seamless integration between Lilia and popular Garry's Mod addons. It automatically detects installed addons, handles version compatibility, and provides API bridging to ensure smooth operation without manual configuration.

## Supported Addons

### DarkRP

**Purpose:** Provides comprehensive compatibility for DarkRP and most DarkRP addons.

**Features:**
- Provides helper functions like `isEmpty`, `findEmptyPos`, and text wrapping
- Implements `formatMoney`, `createEntity`, and `createCategory` shims
- Recreates widely used DarkRP globals and utilities
- **Most DarkRP addons work out of the box** without any modifications required

**Installation:** Install DarkRP alongside Lilia. The compatibility layer will automatically activate.

### Advanced Duplicator

**Purpose:** Provides security and stability improvements for the Advanced Duplicator addon.

**Features:**
- Prevents duplication of entities flagged as `NoDuplicate`
- Rejects dupes containing props scaled to excessive sizes
- Logs attempted exploits and notifies the offending player

**Installation:** Install Advanced Duplicator. Compatibility is automatic.

### Advanced Duplicator 2

**Purpose:** Provides security and stability improvements for Advanced Duplicator 2.

**Features:**
- Performs the same safety checks as the original dupe compatibility library
- Respects AD2's internal entity lists when validating dupes

**Installation:** Install Advanced Duplicator 2. Compatibility is automatic.

### ARCCW

**Purpose:** Configures ARCCW weapon framework for optimal roleplay compatibility.

**Features:**
- Disables ARCCW's HUD and crosshair overrides to prevent conflicts with Lilia's UI
- Configures weapon dropping, attachment inventory, and malfunction settings
- Sets recommended console variables for optimal integration

**Installation:** Install ARCCW. Lilia will automatically configure it for roleplay use.

### CAMI

**Purpose:** Provides comprehensive integration between CAMI permission system and Lilia's administrator framework.

**Features:**
- Integrates CAMI permission system with Lilia's administrator framework
- Implements performance caching mechanisms for optimized group level lookups
- Handles automatic privilege registration and usergroup management
- Provides compatibility for addons that rely on CAMI for permission checks

**Installation:** Install any addon that uses CAMI. The integration will activate automatically.

### LVS

**Purpose:** Provides safety improvements for the LVS vehicle framework.

**Features:**
- Filters out self-inflicted damage from the player's own vehicle

**Installation:** Install LVS vehicles. Compatibility is automatic.

### PAC3

**Purpose:** Provides comprehensive integration with the PAC3 outfit system.

**Features:**
- Networks player outfit parts reliably between server and clients
- Adds commands for repairing, enabling, and disabling PAC3
- Honors the `BlockPackURLoad` configuration to restrict loading outfits from URLs
- Registers the "Staff Permissions - Can Use PAC3" privilege and the `P` flag for access control
- Transfers PAC3 outfits to player ragdolls for consistent appearance
- Integrates with Lilia's item system for automatic PAC part equipping

**Installation:** Install PAC3. Lilia will enhance it with roleplay features.

### PermaProps

**Purpose:** Provides management and safety features for the PermaProps persistence addon.

**Features:**
- Blocks saving Lilia's persistent entities or map-created props as permanent
- Warns about overlapping saves and logs who saved each PermaProp

**Installation:** Install PermaProps. Compatibility is automatic.

### Prone Mod

**Purpose:** Provides automatic recovery features for the Prone Mod addon.

**Features:**
- Forces players out of prone when they die or change character

**Installation:** Install Prone Mod. Compatibility is automatic.

### SAM

**Purpose:** Provides comprehensive integration with the SAM admin suite.

**Features:**
- Recreates SAM chat commands via Lilia's command system
- **Full integration with Lilia's admin system** - SAM and Lilia work together seamlessly
- Includes utilities such as playtime tracking and blind/unblind commands
- Checks staff privileges before executing sensitive commands

**Installation:** Install SAM alongside Lilia. Both admin systems will work together.

### SAdmin

**Purpose:** Provides comprehensive integration with the SAdmin admin suite.

**Features:**
- Recreates SAdmin chat commands via Lilia's command system
- Provides command mapping for kick, ban, mute, gag, freeze, slay, and other administrative actions
- Checks staff privileges before executing sensitive commands
- **Combines SAdmin's proven admin tools with Lilia's modern framework**

**Installation:** Install SAdmin. Lilia will integrate it seamlessly.

### Simfphys Vehicles

**Purpose:** Provides comprehensive integration with the Simfphys vehicle framework.

**Features:**
- Applies crash damage to drivers on vehicle collisions
- Blocks Sit Anywhere seating on Simfphys vehicles
- Adds configuration options for seat damage and entry delays
- Requires privilege for editing vehicles
- Enables trunk functionality for Simfphys vehicles

**Installation:** Install Simfphys. Lilia will enhance it with roleplay features.

### Sit Anywhere

**Purpose:** Provides safety and anti-abuse features for the Sit Anywhere addon.

**Features:**
- Sets recommended console variables on load
- Prevents sitting on players or vehicles
- Applies anti-prop-surf and tool-abuse protections
- Enables seat damage by default

**Installation:** Install Sit Anywhere. Lilia will configure it safely.

### ServerGuard

**Purpose:** Provides integration between ServerGuard admin suite and Lilia's administrator framework.

**Features:**
- Integrates ServerGuard permission system with Lilia's administrator framework
- Provides command bridging for admin functions between the two systems

**Installation:** Install ServerGuard. Lilia will bridge the permission systems.

### ULX

**Purpose:** Provides integration with the ULX admin suite.

**Features:**
- **Full integration with Lilia's admin system** - ULX and Lilia work together seamlessly
- Provides comprehensive command bridging for admin functions
- **Combines ULX's proven admin tools with Lilia's modern framework**

**Installation:** Install ULX. Lilia will integrate it seamlessly.

### VCMod

**Purpose:** Provides financial integration for the VCMod vehicle framework.

**Features:**
- Redirects VCMod money hooks to a character's funds
- Checks vehicle purchases against the character's wallet

**Installation:** Install VCMod. Lilia will handle vehicle purchases through character wallets.

### VJBase

**Purpose:** Provides security and performance improvements for the VJBase NPC framework.

**Features:**
- Removes unprotected VJBase spawners and flags NPCs notarget
- Blocks dangerous network messages
- Applies safer default settings and removes heavy hooks
- Registers privilege for VJBase NPC properties
- Optimizes processing time based on player count

**Installation:** Install VJBase. Lilia will secure and optimize it.

### Wiremod

**Purpose:** Provides security and access control measures for the Wiremod addon.

**Features:**
- Implements upload restrictions for Expression 2 (E2) chip code
- Restricts E2 uploads to administrators and donators only
- Validates upload targets and provides proper error handling

**Installation:** Install Wiremod. Lilia will add security restrictions.

## Configuration

Most compatibility features work automatically once the addons are installed. However, some addons have configuration options:

- **PAC3**: Configure `BlockPackURLoad` in Lilia's config to restrict URL outfit loading
- **ARCCW**: Weapon settings are automatically configured for roleplay
- **VJBase**: NPC privileges can be configured through Lilia's admin system

## Troubleshooting

**Common Issues:**

- **Addon not working:** Ensure the addon is properly installed and compatible with your Garry's Mod version
- **Conflicts:** Some addons may conflict with each other. Check console for error messages
- **Performance issues:** Disable unused compatibility libraries if experiencing performance problems

**Resources:**
- [Complete Compatibility Documentation](compatibility.md)
- [Discord Community](https://discord.gg/esCRH5ckbQ) - Support and discussion
- [GitHub Issues](https://github.com/LiliaFramework/Lilia/issues) - Bug reports