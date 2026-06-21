<style>
details > summary {
    position: relative;
    display: flex;
    align-items: center;
    min-height: 70px;
    padding-right: 180px;
}

details > summary .summary-main {
    min-width: 0;
}

details > summary .source-link-button--summary {
    position: absolute;
    right: 56px;
    top: 50%;
    transform: translateY(-50%);
    white-space: nowrap;
    z-index: 2;
}
</style>

# Libraries

Reference pages for documented Lilia libraries and module library helpers.

<div class="card-grid">
  <a href="./lia.attribs/" class="card">
    <h3>Attributes</h3>
    <p>Attribute helpers for loading, registering, and setting up character attributes.</p>
  </a>
  <a href="./lia.bar/" class="card">
    <h3>Bar</h3>
    <p>HUD bar helpers for registering, retrieving, removing, drawing, and displaying temporary action progress bars.</p>
  </a>
  <a href="./lia.camera/" class="card">
    <h3>Camera</h3>
    <p>Camera helpers for Lilia third-person view, realistic first-person view, freelook input, and local-player visibility handling.</p>
  </a>
  <a href="./lia.char/" class="card">
    <h3>Character</h3>
    <p>Character helpers for Lilia character creation, lookup, loading, caching, variable registration, persistence, and cleanup.</p>
  </a>
  <a href="./lia.chat/" class="card">
    <h3>Chat</h3>
    <p>Chat helpers for registering chat classes, parsing player messages, formatting timestamps, and sending chat messages to eligible recipients.</p>
  </a>
  <a href="./lia.class/" class="card">
    <h3>Class</h3>
    <p>Character class helpers for registering, loading, retrieving, counting, validating, and resolving playable classes.</p>
  </a>
  <a href="./lia.color/" class="card">
    <h3>Color</h3>
    <p>Color and theme helpers for Lilia UI colors, named color lookup, theme registration, active theme application, and clientside theme transitions.</p>
  </a>
  <a href="./lia.command/" class="card">
    <h3>Command</h3>
    <p>Command registration, parsing, permissions, argument prompts, and network dispatch helpers for Lilia commands.</p>
  </a>
  <a href="./lia.config/" class="card">
    <h3>Configuration</h3>
    <p>Configuration helpers for registering, retrieving, localizing, synchronizing, saving, and editing Lilia configuration values.</p>
  </a>
  <a href="./lia.currency/" class="card">
    <h3>Currency</h3>
    <p>Currency helpers for formatting in-game money values and spawning physical money entities.</p>
  </a>
  <a href="./lia.darkrp/" class="card">
    <h3>DarkRP</h3>
    <p>DarkRP compatibility helpers for Lilia, including spawn position checks, DarkRP-style notifications, currency formatting, entity item generation, command registration adapters, door keyvalue handli...</p>
  </a>
  <a href="./lia.data/" class="card">
    <h3>Data</h3>
    <p>Data persistence helpers for Lilia serialized data storage, map equivalency, entity persistence, and runtime data lookup.</p>
  </a>
  <a href="./lia.database/" class="card">
    <h3>Database</h3>
    <p>Database helpers for Lilia storage module setup, schema creation, SQL value conversion, table queries, migrations, transactions, and snapshot import/export.</p>
  </a>
  <a href="./lia.derma/" class="card">
    <h3>Derma</h3>
    <p>Clientside Derma helpers for Lilia menu creation, request dialogs, rounded drawing, blur, shadows, text rendering, and UI animation.</p>
  </a>
  <a href="./lia.dialog/" class="card">
    <h3>Dialog</h3>
    <p>Dialog helpers for Lilia NPC conversations, generated dialog trees, NPC configuration menus, and client synchronization.</p>
  </a>
  <a href="./lia.doors/" class="card">
    <h3>Doors</h3>
    <p>Door data helpers for storing, syncing, validating, and extending map door configuration.</p>
  </a>
  <a href="./lia.faction/" class="card">
    <h3>Faction</h3>
    <p>Faction helpers for registering factions, loading faction definitions, resolving models, validating character customization, and querying faction membership data.</p>
  </a>
  <a href="./lia.flag/" class="card">
    <h3>Flags</h3>
    <p>Flag helpers for registering character permission flags, storing flag metadata, reapplying flag callbacks on player spawn, and displaying available flags in the character information menu.</p>
  </a>
  <a href="./lia.font/" class="card">
    <h3>Font</h3>
    <p>Font registration and loading helpers for Lilia UI and HUD text.</p>
  </a>
  <a href="./lia.inventory/" class="card">
    <h3>Inventory</h3>
    <p>Inventory helpers for registering inventory types, creating and loading inventory instances, managing persistent storage definitions, and opening inventory panels.</p>
  </a>
  <a href="./lia.item/" class="card">
    <h3>Item</h3>
    <p>Item definition, registration, instancing, inventory helper, rarity, and generated weapon/ammunition item utilities for Lilia.</p>
  </a>
  <a href="./lia.keybind/" class="card">
    <h3>Keybind</h3>
    <p>Keybind helpers for Lilia action registration, configurable key assignment, keybind persistence, reserved-key handling, and keybind configuration UI integration.</p>
  </a>
  <a href="./lia.lang/" class="card">
    <h3>Language</h3>
    <p>Language helpers for loading localization files, registering translation tables, resolving localized strings, and caching formatted localization output.</p>
  </a>
  <a href="./lia.loader/" class="card">
    <h3>Loader</h3>
    <p>Core loading and bootstrap helpers for Lilia files, directories, entities, updates, compatibility, and hot reload flow.</p>
  </a>
  <a href="./lia.log/" class="card">
    <h3>Log</h3>
    <p>Server log helpers for registering log types, formatting log messages, dispatching log hooks, printing log output, and saving log entries to the database.</p>
  </a>
  <a href="./lia.menu/" class="card">
    <h3>Menu</h3>
    <p>Clientside helpers for world-anchored interaction menus.</p>
  </a>
  <a href="./lia.module/" class="card">
    <h3>Module</h3>
    <p>Module loading helpers for Lilia schemas, modules, submodules, dependencies, permissions, and module-provided assets.</p>
  </a>
  <a href="./lia.net/" class="card">
    <h3>Net</h3>
    <p>Networking helpers for Lilia networked variables, chunked table transfer, lightweight send caching, and network traffic profiling.</p>
  </a>
  <a href="./lia.notices/" class="card">
    <h3>Notices</h3>
    <p>Notice helpers for sending, receiving, localizing, displaying, and routing Lilia notification messages.</p>
  </a>
  <a href="./lia.option/" class="card">
    <h3>Option</h3>
    <p>Option helpers for Lilia user settings, including registration, lookup, localization, persistence, and configuration menu display.</p>
  </a>
  <a href="./lia.playerinteract/" class="card">
    <h3>Player Interactions</h3>
    <p>Player interaction and personal action helpers for registering, syncing, categorizing, and opening interaction menu options.</p>
  </a>
  <a href="./lia.time/" class="card">
    <h3>Time</h3>
    <p>Time and date helpers for localized timestamps, elapsed-time text, and duration formatting.</p>
  </a>
  <a href="./lia.util/" class="card">
    <h3>Utility</h3>
    <p>General-purpose helpers for Lilia bodygroups, player lookup, entity ownership queries, world-space placement, string formatting, cached materials, table UI handling, and clientside drawing utilities.</p>
  </a>
  <a href="./lia.webimage/" class="card">
    <h3>Web Image</h3>
    <p>Web image helpers for downloading remote PNG and JPEG assets, caching them under the data folder, resolving registered image names, and allowing Material and DImage to load web-backed images.</p>
  </a>
  <a href="./lia.websound/" class="card">
    <h3>WebSound</h3>
    <p>Web sound helpers for registering, downloading, caching, and playing remote audio through Lilia.</p>
  </a>
  <a href="./lia.workshop/" class="card">
    <h3>Workshop</h3>
    <p>Workshop downloader helpers for Lilia server content discovery, synchronization, download prompts, and clientside addon mounting.</p>
  </a>
</div>

