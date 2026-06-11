# Framework Overview

Lilia is an open-source Garry's Mod roleplay framework for servers that need persistent characters, structured factions, inventory-driven gameplay, administration tools, and room for custom schema logic. It is built for server owners who want a dependable production base and developers who want to spend their time on setting-specific systems instead of rebuilding common roleplay infrastructure.

This section is the orientation layer for the docs. Start here when you are planning a server, evaluating whether Lilia fits your addon stack, or preparing a schema project.

## Recommended Reading Order

<div class="card-grid">
  <a href="installation/" class="card">
    <span class="card-kicker">First server boot</span>
    <h3>Install Lilia</h3>
    <p>Add the workshop content, install a schema, configure the startup command, and assign your first administrator group.</p>
  </a>
  <a href="features/" class="card">
    <span class="card-kicker">System planning</span>
    <h3>Review the feature map</h3>
    <p>Understand the built-in character, inventory, faction, chat, economy, moderation, protection, and interface systems.</p>
  </a>
  <a href="compatibility/" class="card">
    <span class="card-kicker">Launch readiness</span>
    <h3>Check addon compatibility</h3>
    <p>Review how Lilia works with common admin mods, PAC3, weapon bases, vehicles, duplication tools, and sandbox addons.</p>
  </a>
</div>

## Start Paths

| Audience | Recommended path |
| --- | --- |
| First-time server owners | [Install Lilia](installation.md), then verify core systems in [Feature Map](features.md). |
| Schema developers | Read [Feature Map](features.md), then scaffold factions and classes from [Generator Overview](../generators/index.md). |
| Module and plugin developers | Review [Addon Compatibility](compatibility.md), then use the generator pages as references for Lilia data shapes. |

## What Belongs Here

- **Installation and launch checks** for getting Lilia running on a dedicated Garry's Mod server.
- **Framework capabilities** so owners can plan which systems to enable, customize, or extend.
- **Compatibility notes** for common addons that affect permissions, persistence, money, weapons, vehicles, or protection behavior.
- **Pointers into generator pages** when you are ready to create schema definitions.

After this section, move to [Generator Overview](../generators/index.md) to build the Lua files that make your schema feel like its own server rather than a blank framework install.
