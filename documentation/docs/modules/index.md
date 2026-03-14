# Modules

Comprehensive collection of official and community-built modules for the Lilia framework.

---

<h3 style="margin-bottom: 5px; font-weight: 700;">Overview</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Modules are self-contained extensions that add new features or modify existing behavior in the Lilia framework. They allow for easy organization and distribution of custom code without modifying core gamemode files.</p>
  <p>For server owners and developers looking to add custom functionality, modules should be placed in the following directory relative to your server installation:</p>
  <code style="display: block; padding: 12px; background: rgba(0, 0, 0, 0.05); border-left: 4px solid #46a9ff; margin-top: 10px; font-family: 'JetBrains Mono', monospace;">garrysmod/gamemodes/[schema folder]/modules/[module folder]</code>
</div>

---

<div class="card-grid">
  <a href="./advertisements/" class="card">
    <h3>Advertisements</h3>
    <p>Implements a paid /advert command for server-wide announcements. Messages are colored, logged, and throttled by a cooldown to curb spam.</p>
  </a>
  <a href="./afk-protection/" class="card">
    <h3>AFK Protection</h3>
    <p>Comprehensive AFK protection system that automatically detects inactive players, prevents exploitation of AFK players, and integrates with restraint systems. Features configurable AFK detection, admin commands, multi-language support, and protection against various player actions.</p>
  </a>
  <a href="./alcoholism/" class="card">
    <h3>Alcoholism</h3>
    <p>Adds drinkable alcohol that increases a player&#39;s intoxication level. High BAC blurs vision and slows movement until the effect wears off.</p>
  </a>
  <a href="./anonymous-rumors/" class="card">
    <h3>Anonymous Rumors</h3>
    <p>Adds an anonymous rumour chat command, hiding of the sender&#39;s identity, encouragement for roleplay intrigue, a cooldown to prevent spam, and admin logging of rumour messages.</p>
  </a>
  <a href="./auto-restarter/" class="card">
    <h3>Auto Restarter</h3>
    <p>Schedules automatic server restarts at set intervals. Players see a countdown so they can prepare before the map changes.</p>
  </a>
  <a href="./bodygroup-closet/" class="card">
    <h3>BodyGroup Closet</h3>
    <p>Spawns a bodygroup closet where players can edit their model&#39;s bodygroups. Admins may inspect others and configure the closet&#39;s model.</p>
  </a>
  <a href="./broadcasts/" class="card">
    <h3>Broadcasts</h3>
    <p>Allows staff to broadcast messages to chosen factions or classes. Every broadcast is logged and controlled through CAMI privileges.</p>
  </a>
  <a href="./captions/" class="card">
    <h3>Captions</h3>
    <p>Offers an API for timed on-screen captions suited for tutorials or story events. Captions can be triggered from the server or client and last for a chosen duration.</p>
  </a>
  <a href="./cards/" class="card">
    <h3>Cards</h3>
    <p>Adds a full deck of playing cards that can be shuffled and drawn. Card draws sync to all players for simple in-game minigames.</p>
  </a>
  <a href="./chat-messages/" class="card">
    <h3>Chat Messages</h3>
    <p>Periodically posts automated advert messages in chat on a timer. Keeps players informed with rotating tips even when staff are offline.</p>
  </a>
  <a href="./cinematic-text/" class="card">
    <h3>Cinematic Text</h3>
    <p>Adds displays of cinematic splash text overlays, screen darkening with letterbox bars, support for scripted scenes, timed fades for dramatic effect, and customizable text fonts.</p>
  </a>
  <a href="./climbing/" class="card">
    <h3>Climbing</h3>
    <p>Adds the ability to climb ledges using movement keys, custom climbing animations, and hooks for climb attempts.</p>
  </a>
  <a href="./code-utilities/" class="card">
    <h3>Code Utilities</h3>
    <p>Adds extra helper functions in lia.util, simplified utilities for common scripting tasks, a central library used by other modules, utilities for networking data, and shared constants for modules.</p>
  </a>
  <a href="./community-commands/" class="card">
    <h3>Community Commands</h3>
    <p>Adds chat commands to open community links, easy sharing of workshop and docs, configurable commands via settings, localization for command names, and the ability to add custom URLs.</p>
  </a>
  <a href="./cursor/" class="card">
    <h3>Cursor</h3>
    <p>Adds a toggleable custom cursor for the UI, a purely client-side implementation, improved menu navigation, a hotkey to quickly show or hide the cursor, and compatibility with other menu modules.</p>
  </a>
  <a href="./cutscenes/" class="card">
    <h3>Cutscenes</h3>
    <p>Adds a framework for simple cutscene playback, scenes defined through tables, syncing of camera movement across clients, commands to trigger cutscenes, and the ability for players to skip.</p>
  </a>
  <a href="./damage-numbers/" class="card">
    <h3>Damage Numbers</h3>
    <p>Adds floating combat text when hitting targets, different colors for damage types, display of damage dealt and received, scaling text based on damage amount, and client option to disable numbers.</p>
  </a>
  <a href="./development-hud/" class="card">
    <h3>Development HUD</h3>
    <p>Adds a staff-only development HUD, font customization via DevHudFont, a requirement for the CAMI privilege, real-time server performance metrics, and a toggle command to show or hide the HUD.</p>
  </a>
  <a href="./development-server/" class="card">
    <h3>Development Server</h3>
    <p>Adds a development server mode for testing, the ability to run special development functions, a toggle via configuration, an environment flag for dev commands, and logging of executed dev actions.</p>
  </a>
  <a href="./donator/" class="card">
    <h3>Donator</h3>
    <p>Adds libraries to manage donor perks, tracking for donor ranks and perks, configurable perks by tier, and commands to adjust character slots.</p>
  </a>
  <a href="./door-kick/" class="card">
    <h3>Door Kick</h3>
    <p>Adds the ability to kick doors open with an animation, logging of door kick events, and a fun breach mechanic with physics force to fling doors open.</p>
  </a>
  <a href="./extended-descriptions/" class="card">
    <h3>Extended Descriptions</h3>
    <p>Adds support for long item descriptions, localization for multiple languages, better RP text display, automatic line wrapping, and fallback to short descriptions.</p>
  </a>
  <a href="./first-person-effects/" class="card">
    <h3>First Person Effects</h3>
    <p>Adds head bob and view sway, camera motion synced to actions, a realistic first-person feel, and adjustable intensity via config.</p>
  </a>
  <a href="./flashlight/" class="card">
    <h3>Flashlight</h3>
    <p>Adds a serious flashlight with dynamic light, darkening of surroundings when turned off, adjustable brightness, and keybind toggle support.</p>
  </a>
  <a href="./free-look/" class="card">
    <h3>Free Look</h3>
    <p>Adds the ability to look around without turning the body, a toggle key similar to EFT, movement direction preservation, and adjustable sensitivity while freelooking.</p>
  </a>
  <a href="./gamemaster-points/" class="card">
    <h3>Gamemaster Points</h3>
    <p>Adds teleport points for game masters, quick navigation across large maps, saving of locations for reuse, a command to list saved points, and sharing of points with other staff.</p>
  </a>
  <a href="./hospitals/" class="card">
    <h3>Hospitals</h3>
    <p>Adds respawning of players at hospitals with support for multiple hospital spawn locations on different maps.</p>
  </a>
  <a href="./hud-extras/" class="card">
    <h3>HUD Extras</h3>
    <p>Adds extra HUD elements like an FPS counter, fonts configurable with FPSHudFont, hooks so other modules can extend, performance stats display, and toggles for individual HUD elements.</p>
  </a>
  <a href="./instakill/" class="card">
    <h3>Instakill</h3>
    <p>Adds instant kill on headshots, lethality configurable per weapon, extra tension to combat, and integration with damage numbers.</p>
  </a>
  <a href="./join-leave-messages/" class="card">
    <h3>Join Leave Messages</h3>
    <p>Adds announcements when players join, notifications on disconnect, improved community awareness, relay of messages to Discord, and per-player toggle to hide messages.</p>
  </a>
  <a href="./load-messages/" class="card">
    <h3>Load Messages</h3>
    <p>Adds faction-based load messages, execution when players first load a character, customizable message text, color-coded formatting options, and per-faction enable toggles.</p>
  </a>
  <a href="./loyalism/" class="card">
    <h3>Loyalism</h3>
    <p>Adds a loyalty tier system for players, the /partytier command access, permission control through flags, automatic tier progression, and customizable rewards per tier.</p>
  </a>
  <a href="./map-cleaner/" class="card">
    <h3>Map Cleaner</h3>
    <p>Adds periodic cleaning of map debris, a configurable interval, reduced server lag, a whitelist for protected entities, and manual cleanup commands.</p>
  </a>
  <a href="./model-pay/" class="card">
    <h3>Model Pay</h3>
    <p>Adds payment to characters based on model, custom wage definitions, integration into the economy, config to exclude certain models, and logs of wages issued.</p>
  </a>
  <a href="./model-tweaker/" class="card">
    <h3>Model Tweaker</h3>
    <p>Adds an entity to tweak prop models, adjustments for scale and rotation, easy UI controls, saving of tweaked props between restarts, and undo support for recent tweaks.</p>
  </a>
  <a href="./npc-drop/" class="card">
    <h3>NPC Drop</h3>
    <p>Adds NPCs that drop items on death, DropTable to define probabilities, encouragement for looting, editable drop tables per NPC type, and weighted chances for rare items.</p>
  </a>
  <a href="./npc-money/" class="card">
    <h3>NPC Money</h3>
    <p>Adds NPCs that give money to players on death, MoneyTable to define rewards, editable money amounts per NPC type, and configurable default values.</p>
  </a>
  <a href="./npc-spawner/" class="card">
    <h3>NPC Spawner</h3>
    <p>Adds automatic NPC spawns at points, the ability for admins to force spawns, logging of spawn actions, and configuration for spawn intervals.</p>
  </a>
  <a href="./perma-remove/" class="card">
    <h3>Perma Remove</h3>
    <p>Adds ability to permanently delete map entities, logging for each removed entity, an admin-only command, confirmation prompts before removal, and restore list to undo mistakes.</p>
  </a>
  <a href="./radio/" class="card">
    <h3>Radio</h3>
    <p>Adds a radio chat channel for players, font configuration via RadioFont, workshop models for radios, frequency channels for groups, and handheld radio items.</p>
  </a>
  <a href="./raised-weapons/" class="card">
    <h3>Raised Weapons</h3>
    <p>Adds auto-lowering of weapons when running, a raise delay set by WeaponRaiseSpeed, prevention of accidental fire, a toggle to keep weapons lowered, and compatibility with melee weapons.</p>
  </a>
  <a href="./realistic-view/" class="card">
    <h3>Realistic View</h3>
    <p>Adds a first-person view that shows the full body, immersive camera transitions, compatibility with animations, smooth leaning animations, and optional third-person override.</p>
  </a>
  <a href="./shoot-lock/" class="card">
    <h3>Shoot Lock</h3>
    <p>Adds the ability to shoot door locks to open them, a quick breach alternative, a loud action that may alert others, and chance-based lock destruction.</p>
  </a>
  <a href="./simple-lockpicking/" class="card">
    <h3>Simple Lockpicking</h3>
    <p>Adds a simple lockpick tool for doors, logging of successful picks, brute-force style gameplay, configurable pick time, and chance for tools to break.</p>
  </a>
  <a href="./slot-machine/" class="card">
    <h3>Slot Machine</h3>
    <p>Adds a slot machine minigame, a workshop model for the machine, handling of payouts to winners, customizable payout odds, and sound and animation effects.</p>
  </a>
  <a href="./slow-weapons/" class="card">
    <h3>Slow Weapons</h3>
    <p>Adds slower movement while holding heavy weapons, speed penalties defined per weapon, encouragement for strategic choices, customizable weapon speed table, and automatic speed restore when switching.</p>
  </a>
  <a href="./steam-group-rewards/" class="card">
    <h3>Steam Group Rewards</h3>
    <p>Provides Steam group membership rewards system that automatically checks group membership and gives money rewards to players who join your Steam group.</p>
  </a>
  <a href="./view-manipulation/" class="card">
    <h3>View Manipulation</h3>
    <p>Adds VManip animation support, hand gestures for items, functionality within Lilia, API for custom gesture triggers, and fallback animations when VManip is missing.</p>
  </a>
  <a href="./war-table/" class="card">
    <h3>War Table</h3>
    <p>Adds an interactive 3D war table, the ability to plan operations on a map, a workshop model, marker placement for strategies, and support for multiple map layouts.</p>
  </a>
  <a href="./word-filter/" class="card">
    <h3>Word Filter</h3>
    <p>Adds chat word filtering, blocking of banned phrases, an easy-to-extend list, and admin commands to modify the list.</p>
  </a>
</div>

