# Feature Map

Lilia provides the systems expected from a production Garry's Mod roleplay framework: persistent characters, inventory, factions, classes, chat, vendors, administration, protection, and customization hooks. Use this page as a planning map before deciding which systems to configure, extend, or replace with schema-specific logic.

## Characters

### Multi-Character Support

- Players can maintain multiple characters on the same server.
- Each character keeps separate identity, faction, class, inventory, money, progress, and administrative history.
- Servers can limit character slots globally and grant extra slots to specific players.
- Players can switch characters through the Lilia interface without leaving the server.

### Character Identity

- Names, descriptions, models, factions, classes, flags, attributes, money, and playtime persist across sessions.
- Factions define broad server roles such as civilian, police, medical, military, staff, or custom schema groups.
- Classes define specialized roles inside a faction, such as officer, chief, medic, technician, or event role.
- Character flags grant restricted access to commands, items, tools, or schema behavior.

### Recognition And Persistence

- Recognition can hide unknown character names until players are introduced.
- Unknown players can appear under generic labels, which supports disguise, investigation, and relationship-focused roleplay.
- Character data is saved automatically, including inventory, progress, administrative state, money, and stored fields.
- Staff can review and manage character records through administrative tools.

## Inventory And Items

### Grid Inventory

- Items occupy configurable inventory space through width and height values.
- Drag-and-drop movement makes storage management visual and predictable.
- Item dimensions and weight can be used to tune scarcity, logistics, and carrying capacity.
- Bags and containers can add extra inventory grids when your server needs storage progression.

### Item Behavior

- Items can be used, dropped, transferred, examined, equipped, or restricted through custom logic.
- Consumables can restore health, armor, stamina, or schema-specific resources.
- Weapons can be represented as inventory items that equip Garry's Mod SWEPs.
- Stackable items support supplies, scraps, crafting materials, currency-like objects, and resource economies.

### Storage

- Storage entities can persist world storage between restarts.
- Password-protected storage supports shared access without making every player an owner.
- Staff can spawn, inspect, and manage stored items when their permissions allow it.

## Factions, Classes, And Attributes

### Factions

- Factions organize the main playable groups in a schema.
- A faction can define name, description, color, models, weapons, whitelisting, limits, and default behavior.
- Whitelisting controls access to sensitive groups such as staff, police, military, or restricted story roles.
- Population limits help keep server balance under control during busy sessions.

### Classes

- Classes provide sub-roles inside a faction.
- A class can define name, description, models, weapons, bodygroups, sub-materials, limits, and permissions.
- Default classes give new faction members a stable fallback role.
- Class whitelisting supports leadership positions, specialist jobs, and progression systems.

### Attributes

- Attributes track character stats such as strength, endurance, intelligence, agility, medical skill, or custom schema values.
- Starting maximums and caps control character creation balance and long-term progression.
- Items, commands, modules, and schema logic can read attributes to shape gameplay.

## Communication

### Chat Channels

- In-character chat supports local speech.
- Whisper and yell ranges let players control how far messages travel.
- OOC chat can be enabled, disabled, and rate-limited.
- Admin, event, local event, and help channels support moderation and live roleplay operations.

### Chat Quality Of Life

- Rich text formatting improves roleplay readability.
- Command autocomplete helps players discover available actions.
- Chat history gives players and staff context during active scenes.
- Localization support keeps system messages consistent across supported languages.

## Doors, Vendors, And Economy

### Doors

- Players can buy, sell, lock, unlock, and share owned doors.
- Doors can be named and assigned to factions or classes.
- Map tools let staff configure door behavior in-game.
- Door data persists so map setup work survives restarts.

### Vendors

- NPC vendors can buy items, sell items, or do both.
- Vendors support custom inventories, stock limits, restock behavior, faction restrictions, class restrictions, and custom dialogue.
- Vendor presets let staff reuse shop configurations across maps and events.
- Transaction logging helps staff audit economy activity.

### Currency

- Money is stored per character.
- Currency display can be configured to match the server setting.
- Staff tools can adjust money for online and offline characters when permissions allow it.

## Gameplay Systems

### Spawns

- Spawn points can be configured for global, faction-specific, or class-specific use.
- Multiple spawn points support randomized spawn selection.
- Staff can place and remove spawn positions through supported in-game tools.

### Movement And Interaction

- Stamina can control sprinting and other movement-heavy actions.
- Regeneration and drain behavior can be tuned to match server pacing.
- Third-person support can be enabled and configured when the server wants it.
- Context-sensitive interaction menus expose different actions for doors, vendors, storage, players, and entities.

## Administration

### Staff Dashboards

- The admin tab centralizes staff workflows inside the main Lilia interface.
- Staff can review online staff, players, character records, faction access, flags, permanent-kill data, tickets, and warnings.
- Character management includes names, descriptions, models, money, flags, inventory, and administrative state.

### Moderation

- Warnings and support tickets provide persistent staff workflows.
- Sit rooms give staff controlled spaces for handling reports.
- Staff actions include kick, ban, mute, gag, jail, freeze, blind, god mode, cloak, noclip, teleport, and related moderation tools.
- Administrative logging records important staff actions for later review.

### World Tools

- Item spawning helps staff test and distribute schema items.
- Entity and map entity tools help diagnose setup issues and world state.
- The admin stick provides quick access to player, entity, and prop management workflows.

## Protection And Compatibility

### Anti-Abuse Systems

- Protection systems can detect suspicious behavior and alert staff.
- Spawn protection, anti-prop-kill behavior, anti-prop-surf behavior, and world entity protection reduce common sandbox abuse.
- Logging gives staff a trail for reviewing exploit attempts and risky addon behavior.

### Addon Compatibility

Lilia includes compatibility behavior for common Garry's Mod addons and admin frameworks. Review [Addon Compatibility](compatibility.md) before enabling high-impact addons such as admin suites, weapon bases, PAC3, duplication tools, or vehicle systems.

## Interface And Customization

### User Interface

- Lilia provides a themed Derma interface for character selection, inventory, settings, admin tools, and notifications.
- The main menu gives players access to character information, inventory, settings, and role-appropriate actions.
- The scoreboard can show player, character, faction, class, staff, and context-action information.

### Server Identity

- Server owners can configure colors, fonts, logos, language, keybinds, and client options.
- Localization support makes UI text and notifications translatable.
- Workshop integration helps deliver required content to connecting players.

## Build Faster With Generators

Use [Generator Overview](../generators/index.md) when you are ready to define schema content. Generators do not replace understanding the Lua files, but they reduce repetitive setup and keep common definitions consistent.
