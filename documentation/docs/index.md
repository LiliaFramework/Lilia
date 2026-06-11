# Lilia Framework Documentation

Welcome to the Lilia docs portal. The site is organized around a fast reference tree on the left, with guides and generators kept close by for implementation work.

<section class="home-hero">
  <p class="home-eyebrow">Developer Portal</p>
  <h1>Reference-first docs for Lilia schema and server development</h1>
  <p>Browse definitions, generate schema files, and map framework systems without losing context. Lilia keeps the flexible roleplay foundation; these docs make the moving parts easier to reach.</p>
  <div class="hero-actions">
    <a href="definitions/" class="hero-action hero-action--primary">Open Reference</a>
    <a href="generators/" class="hero-action">Use Generators</a>
    <a href="about/installation/" class="hero-action">Install Lilia</a>
  </div>
</section>

## Quick Entry

<div class="home-grid home-grid--paths">
  <a href="definitions/" class="home-card">
    <span class="card-kicker">Reference</span>
    <h3>Definition Index</h3>
    <p>Start from a clean map of schema, item, module, and panel definitions.</p>
  </a>
  <a href="definitions/faction/" class="home-card">
    <span class="card-kicker">Schema</span>
    <h3>Factions and Classes</h3>
    <p>Define playable groups, inheritance, access rules, loadouts, and lifecycle callbacks.</p>
  </a>
  <a href="definitions/items/weapons/" class="home-card">
    <span class="card-kicker">Items</span>
    <h3>Items</h3>
    <p>Document weapons, outfits, stackables, aid items, books, ammo, entities, and URL items.</p>
  </a>
  <a href="definitions/module/" class="home-card">
    <span class="card-kicker">Modules</span>
    <h3>Module Metadata</h3>
    <p>Use consistent fields for dependencies, privileges, network strings, Workshop content, and lifecycle hooks.</p>
  </a>
</div>

## Build Paths

<div class="card-grid">
  <a href="about/installation/" class="card">
    <h3>Launch a Server</h3>
    <p>Install workshop content, add a schema, set the startup gamemode, assign owner access, and confirm the first join flow.</p>
  </a>
  <a href="about/features/" class="card">
    <h3>Map Framework Systems</h3>
    <p>Review characters, inventories, administration, protection, compatibility, and operational features before committing to a server design.</p>
  </a>
  <a href="generators/" class="card">
    <h3>Generate Definition Files</h3>
    <p>Create starter Lua for attributes, factions, classes, weapons, outfits, books, ammo, aid items, PAC3 outfits, stackables, and grenades.</p>
  </a>
  <a href="about/compatibility/" class="card">
    <h3>Validate Addons</h3>
    <p>Check admin systems, PAC3, weapon bases, vehicles, duplication tools, and sandbox behavior before a live launch.</p>
  </a>
</div>

## Reference Map

| Need | Start here |
| --- | --- |
| Find every supported definition type | [Definition Index](definitions/index.md) |
| Define character stats | [Attribute Definitions](definitions/attributes.md) |
| Build factions and jobs/classes | [Faction Definitions](definitions/faction.md), [Class Definitions](definitions/class.md) |
| Create inventory content | [Items](definitions/index.md#items) |
| Document module metadata | [Module Definitions](definitions/module.md) |
| Generate starter Lua | [Generators](generators/index.md) |

## Project Links

<div class="home-grid">
  <a href="https://github.com/LiliaFramework/Lilia/" class="home-card">
    <h3>GitHub</h3>
    <p>Read source code, follow changes, report issues, and contribute improvements to the framework.</p>
  </a>
  <a href="https://discord.gg/esCRH5ckbQ" class="home-card">
    <h3>Discord</h3>
    <p>Ask questions, coordinate schema work, share modules, and follow community development.</p>
  </a>
  <a href="https://wiki.facepunch.com/gmod/" class="home-card">
    <h3>Garry's Mod Wiki</h3>
    <p>Use the official Lua and entity reference alongside Lilia-specific guidance.</p>
  </a>
</div>
