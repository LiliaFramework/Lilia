# Generator Overview

Lilia's generators create starter Lua definitions for the files schema developers write most often. They are useful for fast prototyping, consistent boilerplate, and avoiding small structural mistakes while building factions, classes, attributes, and inventory items.

Generated code should still be reviewed before it reaches a live server. Treat these tools as scaffolding: rename paths, balance values, verify models and weapons, add hooks, and connect the output to your schema's permissions and gameplay rules.

## Core

<div class="card-grid">
  <a href="faction/" class="card">
    <span class="card-kicker">Character creation</span>
    <h3>Faction Generator</h3>
    <p>Create the major playable groups for your schema, including colors, models, whitelists, limits, weapons, and starting items.</p>
  </a>
  <a href="class/" class="card">
    <span class="card-kicker">Role structure</span>
    <h3>Class Generator</h3>
    <p>Create specialized roles inside a faction with their own models, bodygroups, weapons, limits, permissions, and spawn behavior.</p>
  </a>
  <a href="attribute/" class="card">
    <span class="card-kicker">Progression</span>
    <h3>Attribute Generator</h3>
    <p>Create persistent character stats such as endurance, strength, intelligence, crafting skill, or schema-specific abilities.</p>
  </a>
</div>

## Items

<div class="card-grid">
  <a href="items/weapons/" class="card">
    <span class="card-kicker">Equipment</span>
    <h3>Weapons</h3>
    <p>Create inventory-backed weapon items for SWEPs and override automatic weapon-item generation.</p>
  </a>
  <a href="items/outfit/" class="card">
    <span class="card-kicker">Wearables</span>
    <h3>Outfits</h3>
    <p>Create clothing or armor that changes player models and can apply protection or movement values.</p>
  </a>
  <a href="items/pacoutfit/" class="card">
    <span class="card-kicker">PAC3</span>
    <h3>PAC3 Outfits</h3>
    <p>Create wearable PAC3 items that apply PAC parts on equip and remove them on unequip.</p>
  </a>
  <a href="items/bags/" class="card">
    <span class="card-kicker">Storage</span>
    <h3>Bags</h3>
    <p>Create containers that open their own inventory grid and expand what a character can carry.</p>
  </a>
  <a href="items/aid/" class="card">
    <span class="card-kicker">Consumables</span>
    <h3>Aid Items</h3>
    <p>Create medical, survival, or utility consumables that restore health, armor, stamina, or related resources.</p>
  </a>
  <a href="items/ammo/" class="card">
    <span class="card-kicker">Supplies</span>
    <h3>Ammo Items</h3>
    <p>Create ammunition items that pair inventory objects with Garry's Mod ammo types.</p>
  </a>
  <a href="items/books/" class="card">
    <span class="card-kicker">Readable objects</span>
    <h3>Books And Notes</h3>
    <p>Create books, papers, manuals, rulesheets, lore notes, and other readable in-world documents.</p>
  </a>
  <a href="items/stackable/" class="card">
    <span class="card-kicker">Economy</span>
    <h3>Stackable Items</h3>
    <p>Create supplies, resources, scraps, crafting materials, or currency-like items with stack limits.</p>
  </a>
  <a href="items/grenade/" class="card">
    <span class="card-kicker">Utilities</span>
    <h3>Grenades</h3>
    <p>Create throwable explosive or utility items backed by grenade or weapon entities.</p>
  </a>
</div>

## Placement Guide

| Definition | Typical location |
| --- | --- |
| Attribute | `garrysmod/gamemodes/[schema]/schema/definitions/sh_attributes.lua` |
| Class | `garrysmod/gamemodes/[schema]/schema/classes/[class_name].lua` |
| Faction | `garrysmod/gamemodes/[schema]/schema/definitions/sh_factions.lua` |
| Item | `garrysmod/gamemodes/[schema]/schema/items/[item_id].lua` |
| PAC3 outfit item | `garrysmod/gamemodes/[schema]/schema/items/pacoutfit/[item_id].lua` |

## Review Before Shipping

- Confirm generated IDs are unique and match your naming conventions.
- Replace example models, weapons, colors, and descriptions with production values.
- Test every generated item in inventory, vendors, storage, death, drop, and transfer flows.
- Check faction and class limits with real player counts, not just local testing.
- Keep generated files under source control so schema changes can be reviewed before deployment.
