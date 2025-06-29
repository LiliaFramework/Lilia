# Feature List

---

This page provides an extensive overview of the core modules and libraries included with Lilia. Use it as a quick reference for the capabilities baked into the framework. The framework ships with numerous optional compatibility layers so popular Garry's Mod addons work seamlessly alongside these features. For a breakdown of those integrations see the [compatibility guide](./compatibility.md).

### Grid Inventory
- Drag-and-drop item placement using a grid layout
- Supports backpacks, lockers, vehicle trunks and other containers
- Weight limits and configurable width/height
- Virtual inventories for vendors and temporary storage
- Admin commands to resize or wipe inventories
- Item icons show stack counts, durability and custom overlays
- Hooks allow you to register new container types or layout rules
- Shift-click automatically moves items to the first open slot

### Recognition
- Manually recognize other players within whisper, talk or yell range
- Optional faction auto-recognition and global faction recognition
- Fake name support for disguises
- Hooks to check recognition and trigger events when recognized
- Adjustable distance multipliers for each speech level
- Friends list integration optionally grants automatic recognition
- Client-side popups notify players when new characters are recognized

### Attributes
- Character-bound statistics that affect gameplay
- Load attributes from schema folders at runtime
- Hooks for modifying attribute values on events
- Bonuses and penalties applied to relevant actions
- Admins can grant or remove attribute XP via commands
- Progress bars show growth toward the next level
- Supports dynamic maximums and configurable starting values

### F1 Menu
- Staff tools for teleporting to entities and viewing lists
- Access character sub-menus and module management
- Default tab can be configured
- Built-in help pages link to relevant documentation
- Admin options integrated with the scoreboard
- Modular tab system allows plugins to add new pages
- Search bar helps staff quickly locate commands or characters

### Scoreboard
- Roleplay-themed scoreboard with recognition integration
- Context menu for admin actions like kick or mute
- Quick ban or kick shortcuts via the context menu
- Player ping and playtime displayed next to names
- Width, height and background color can be configured
- Optionally show class logos and group headers
- Live player counts and faction sorting
- Warning icons appear next to a player nearing a ban
- Tooltips reveal full character names and SteamIDs

### Chatbox
- Customizable chat colors and message length limits
- Configurable message fade time for better readability
- OOC/LOOC delay timers and chat range controls
- Optional custom chat sounds
- Listen color highlighting when directly addressed
- Supports chat classes for radio channels and emotes
- Built-in commands like `/me` and `/roll`

### Main Menu
- Multi-column layout scales to widescreen resolutions
- Character selection and creation interface
- Supports custom background image and music
- Links to Discord and Workshop pages
- Optional centered logo and background input toggle
- Can display news or patch notes from a remote URL
- Remembers the last character and can auto-select it on join
- Quick equip slots for grenades or utilities

### Weapon Selector
- Radial weapon menu with smooth fade animations
- Obeys hooks to decide when it appears
- Works with weapon categories from the Easy Weapons system
- Displays ammo counts and active attachments
- Designed for quick weapon switching without blocking movement
- Map-based spawn overrides for special events

### Spawns
- Manage player spawn points per faction or class
- Loss of marked items on death by NPCs, players or the world
- Death popup explaining cause of death
- Staff on duty can spawn with god mode
- Faction-based weapon restrictions enforced on spawn
- Spawn points can be limited by time of day or player level
- Customizable respawn messages and effects

### Teams
- Faction and class management helpers
- Permanent classes saved on characters
- Optionally display class information above players
- Bind frequently used actions to hotkeys
- Hooks for custom team loadouts and spawns
- Supports sub-factions and dynamic rank titles

### Interaction Menu
- Quick-access radial menu for common actions
- Give money or change voice type directly from the menu
- Recognize characters from whisper/talk/yell range
- Extensible via `AddAction` and `AddInteraction`
- Dynamically builds options based on player context
- Plugin-defined actions can include custom icons and sounds
- Warns staff if server FPS drops too low

### Administration Utilities
- Central logging, warning history and ticket system
- Item spawner GUI for events and testing
- Permission management integrated with CAMI
- Searchable history of all player tickets and warns
- Camera spectate and teleport commands for staff
- Sitroom management commands let staff teleport players to holding areas

### Performance
- Libraries focused on optimizing heavy operations
- Useful for tracking tick rate and network performance
- Includes debug overlays for server load and network usage

### Protection
- Anti-exploitation features such as alting notifications
- Cooldowns on character switching after taking damage
- Delays for equipping, dropping and giving items
- Ragdoll options for explosions and vehicles
- Cleanup timers for dropped weapons
- Item filters can be saved as reusable presets
- Option to disable potentially dangerous console commands
- Monitors unusual damage events and logs suspicious behaviour

### Admin Stick
- Staff-only SWEP for quick moderation actions
- Department tags help route tickets to specialists
- Teleport, freeze and noclip functions
- Left-click freezes or unfreezes targeted players
- Right-click opens a menu of administrative shortcuts

### Item Spawner
- GUI interface to spawn any item
- Respects privilege checks before spawning
- Search and filter through items
- Permission profiles can be assigned to groups
- Spawn directly into a player's inventory or at their crosshair
- Supports specifying stack sizes for bulk spawns

### Tickets
- Players can submit tickets that staff can claim
- Search logs by keyword or SteamID
- Notifies staff members and records ticket history
- Ticket interface shows claim status and staff responses
- Players receive chat alerts when a ticket is answered

### Warns
- Issue warnings with reasons and durations
- Stores warning history for each player
- Registers attachments to keep weapons consistent
- Can automatically apply punishments after repeated infractions

### Permissions
- CAMI-based framework for defining privileges
- ESP tools and spawn menu restrictions configurable
- Supports privilege inheritance and group hierarchies
- Simple API to register new permissions from plugins
- Vehicle blacklist privileges restrict certain car spawns

### Logging
- Log server events with category filtering
- Configurable retention time and line limits
- Optional webhook integration for Discord or other services

### Easy Weapons
- Automatically generates items from installed weapons
- Vehicle mode keeps the camera locked behind the car
- Hold-type mapping defines item size and category
- Weapon overrides for custom names or models
- Blacklist unwanted weapons from registration
- Auto-generates kill icons and category images
- Compatible with attachment systems for model customization

### Doors
- Each container type can play unique open sounds
- Ownable doors with selling and price settings
- Faction or class based access control
- Lock and unlock using the key SWEP
- Configurable lock times and sell ratio
- Doors can auto-close after configurable delays
- Supports linked child doors
- Can mark doors as unownable for public spaces
- Property groups allow mass purchasing of connected doors
- Prices adjust dynamically based on supply

### Third Person
- Toggleable third-person view with camera options
- Adjustable distance, height and horizontal offset
- Wall-peek prevention and max view distance limits
- Classic mode option for old-school behaviour
- Supports resetting attribute progress on class change
- Keybind toggles shoulder view on the fly
- Automatically reverts to first person when aiming weapons

### Storage Containers
- Crates, lockers, fridges and more with predefined sizes
- Vehicle trunk storage supported
- Circular HUD bars can surround NPCs or players
- Optional open/close animations for certain models
- Uses grid inventories internally
- Can be locked and unlocked with keys or commands
- Persists contents between server restarts

### NPC Vendors
- Built-in squad roster management functions
- NPCs that buy and sell items using the inventory system
- Default money amount configurable
- Admin editing privileges for vendor stock
- Dialogue and camera view support
- Items can restock automatically on a timer
- Dialogue trees allow branching conversations
- Plugin hooks for chat preprocessing

### Attributes Library
- Manage character attribute values and levels
- Provides hooks for attribute setup and change events
- Automatically network attribute progress to clients
- Data persists between sessions and characters
- Salary or perk adjustments per class via hooks
- Supports value clamping and progression formulas

### Bars
- Draw health, armor and custom HUD bars
- Smooth animations and customizable colors
- Convert hex color strings to tables
- Register new bar types through a simple API
- 3D world overlays display information near entities
- Threshold colors make critical levels stand out

### Character Library
- Helper functions for accessing character data
- Transfer characters between players
- Save and load variables seamlessly
- Events allow pre and post character transfer logic
- Simplified APIs for retrieving online or offline characters

### Chatbox Library
- Building blocks for custom chat classes
- Utilities for sending formatted messages
- Overridable parsing for unique chat effects
- Supports icons, colors and markup tags
- Works with the recognition system for display names

### Classes Library
- Register player classes with spawn data and loadouts
- Integrates class logos into the scoreboard
- Handles class whitelisting and restrictions
- Nested class categories supported for organization
- Save new class definitions at runtime via commands

### Color Utilities
- Helper functions for color math and interpolation
- Convert between HSV and RGB color spaces
- Ease color transitions with preset curves
- Provides predefined palettes for common UI elements

- Convert hex codes to color tables

### Commands Library
- Register chat commands with syntax parsing
- Built-in access checks and argument extraction
- Hook support for custom command types
- Command descriptions support multiple languages
- Provides suggestions and detailed error messages
- Unified `execAdminCommand` helper simplifies running kick/ban commands

### Config Library
- Register server configs with categories and callbacks
- In-game menu for adjusting values
- Automatically network configs to clients
- Config hooks trigger when values are modified
- Schemas can define defaults and value ranges
- Supports sliders, checkboxes and text entry types

### Currency Library
- Format amounts with currency symbols
- Spawn money entities in the world
- Convert between currencies at configurable rates
- Hooks for payments and transactions
- Supports multiple currencies for different factions
- Integrates with banking and storage addons

### DarkRP Compatibility
- Replicates DarkRP door groups for compatibility
- Hooks for integrating with DarkRP wallets and systems
- Optionally sync lia.money with DarkRP balance
- Convert existing DarkRP jobs to Lilia factions
- Supports DarkRP shipments and custom job weapons

### Data Library
- Key/value storage wrappers with automatic serialization
- Supports default values and lazy loading
- Synchronous and asynchronous access helpers
- Optional caching layers reduce disk reads
- Data versioning prevents mismatched schemas

### Database Library
- Interface for saving characters and items asynchronously
- Abstraction layer for MySQL or SQLite backends
- Queues database actions to avoid blocking
- Automatically reconnects when the database drops
- Query builder simplifies complex statements
- Exposes queue length metrics for debugging

### Factions Library
- Create factions with colors, models and global recognition
- Manage faction whitelists and default classes
- Provide cross-faction communication hooks
- Support per-map faction spawnpoints
- Roster utilities list all members currently online
- Faction chat automatically uses the group's color

### Flags Library
- Permission flags assignable to players
- Flags can expire automatically after a set time
- Simple hasFlag helper for checks
- Combine with commands for fine-grained access
- Integrates with usergroups to restrict plugin functionality

### Fonts Library
- Outline and shadow options for crisp text
- Register custom fonts for the UI
- Scale fonts for different resolutions
- Preload fonts to avoid runtime hitches
- Fonts are cached clientside to minimize load times

### Inventory Library
- Shared logic for inventories including networking
- Supports weight limits and stack sizes
- Parent and child inventory relationships
- Drag-and-drop system for moving and splitting stacks

- Containers can hold other containers if allowed

### Item Library
- Framework for defining items with metadata and hooks
- Supports consumables, weapons and clothing types
- Easy creation of networked item instances
- Extensive hooks like `onUse` and `onDrop`
- Items can override rendering and interaction behaviour

- Items may expose custom networked fields

### Keybind Library
- Add custom client keybinds and save them per player
- Rebind keys through a menu interface
- Hook into press and release events
- Schemas can provide sensible default bindings
- Keybind contexts allow menu overrides

### Languages Library
- Multi-language phrase system with fallback support
- Merge phrases from schemas and plugins
- String interpolation with variables
- Right-to-left and accented character handling
- Phrase packs can load from Workshop addons

### Logger Library
- Simplified logging functions for modules
- Write formatted logs to disk with timestamps
- Configurable log levels and filters
- Old log files automatically rotated to prevent bloat
- Optionally color-code logs by severity
- Colored console output improves readability

### Markup Library
- Parse and render markup or BBCode text
- Supports images, icons and custom fonts
- Word wrap and measurement helpers
- Clickable links and icon embeds supported
- Preprocess templates for dynamic text

### Menu Helper
- Utility functions for building Derma menus
- Predefined button, slider and text entry helpers
- Layout features for tool panels
- Includes confirmation dialogs and contextual menus
- Wrap panels with standardized headers

### Modularity
- Dynamic loading and disabling of modules and plugins
- Hot-reload plugins without restarting the server
- Ordered search for schema-specific modules
- Automatically resolves dependencies between modules
- Modules declare dependencies to auto-load requirements

### Networking
- Netstream utilities for efficient communication
- Automatic compression for larger payloads
- Request/response pattern for RPC-style calls
- Built-in timeouts prevent stalled network requests

### Notice System
- On-screen notifications with queueing
- Custom icons and sound effects
- Fade animations and stacking behaviour
- Priorities let important messages override lesser ones

### Option Library
- Store player preferences using sliders and checkboxes
- Categorize options per module or plugin
- Network options to and from the server
- Preferences are saved server-side for persistence

### Salary System
- Periodic salary payouts for characters
- Configurable intervals and amounts
- Commands to set starting wages
- Supports bonuses based on rank or faction
- Logging tracks salary payouts for auditing

### Time Library
- Scheduler helpers and shared timers
- Real time to game time conversions
- Delay utilities for repeating tasks
- Timers can fire callbacks at map start
- Timers can persist across map changes if desired

### Util Library
- Miscellaneous helper functions used across modules
- String and table utilities for common patterns
- String pattern helpers simplify validation
- Math helpers for clamping and rounding
- Includes entity search and distance calculations

### Web Image
- Download and cache web images for the UI
- Resizes images to fit predetermined UI slots
- Verify image URLs before requesting them
- Save local copies to reduce bandwidth
- Cache directory can be customized per server

### Workshop
- Handles dependencies between Workshop collections
- Manage Steam Workshop downloads for clients
- Add resource packs from the configuration
- Update notifications for outdated addons
- Prompts admins to restart when addons update

### Configuration Options

- Modules load automatically when compatible addons are detected
The `config` library exposes numerous settings allowing you to control walk and run speeds, voice chat, crosshair usage, salary intervals, theme colors, workshop downloads, and much more. These options can be tweaked in game via the configuration menu.

### Addon Compatibility

Lilia includes built-in modules that expand support for many common Garry's Mod addons. These integrations cover administration suites, vehicle packs, and utility tools so you can drop your favorite addons in without conflicts. See the [compatibility guide](./compatibility.md) for details.

---
