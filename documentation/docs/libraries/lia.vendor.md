# Vendor Library

NPC vendor management system with editing and rarity support for the Lilia framework.

---

## Overview

The vendor library provides comprehensive functionality for managing NPC vendors in the Lilia framework.

It handles vendor configuration, editing, presets, and rarity systems for items sold by vendors.

The library operates on both server and client sides, with the server handling vendor data processing

and the client managing the editing interface. It includes support for vendor presets, item rarities,

stock management, pricing, faction/class restrictions, and visual customization. The library ensures

that vendors can be easily configured and managed through both code and in-game editing tools.

---

### addRarities

**Purpose**

Adds a new item rarity type with an associated color to the vendor system

**When Called**

During initialization or when defining custom item rarities for vendors

---

### addPreset

**Purpose**

Creates a vendor preset with predefined items and their configurations

**When Called**

During initialization or when defining vendor templates with specific item sets

---

### getPreset

**Purpose**

Retrieves a vendor preset by name for applying to vendors

**When Called**

When applying presets to vendors or checking if a preset exists

---

