# Definition Reference

Use this section as the API-style reference for Lilia definition files. Each page follows the same pattern: overview, reference entries, callback details, and complete examples where available.

<section class="reference-hero">
  <p class="home-eyebrow">Lilia Reference</p>
  <h2>Schema, item, module, and UI definitions in one browseable tree</h2>
  <p>Start with the definition type you are editing, then use the field and callback entries as a checklist while writing Lua.</p>
</section>

## Core

<div class="home-grid">
  <a href="attributes/" class="home-card">
    <span class="card-kicker">Characters</span>
    <h3>Attributes</h3>
    <p>Character stats, creation limits, maximum values, and setup callbacks.</p>
  </a>
  <a href="faction/" class="home-card">
    <span class="card-kicker">Groups</span>
    <h3>Factions</h3>
    <p>Top-level playable organizations, models, loadouts, restrictions, limits, and spawn behavior.</p>
  </a>
  <a href="class/" class="home-card">
    <span class="card-kicker">Roles</span>
    <h3>Classes</h3>
    <p>Faction sub-roles with inherited defaults, whitelist rules, loadouts, and lifecycle callbacks.</p>
  </a>
  <a href="module/" class="home-card">
    <span class="card-kicker">Modules</span>
    <h3>Module Metadata</h3>
    <p>Author info, dependencies, privileges, network strings, Workshop content, and module lifecycle.</p>
  </a>
</div>

## Items

<div class="home-grid">
  <a href="items/weapons/" class="home-card"><h3>Weapons</h3><p>Weapon class binding, equip state, ammo persistence, and drop behavior.</p></a>
  <a href="items/outfit/" class="home-card"><h3>Outfits</h3><p>Wearable item metadata, inventory sizing, outfit categories, and PAC data.</p></a>
  <a href="items/pacoutfit/" class="home-card"><h3>PAC3 Outfits</h3><p>PAC part setup, removal, loadout behavior, and transfer checks.</p></a>
  <a href="items/arccw_att/" class="home-card"><h3>ArcCW Attachments</h3><p>Attachment item metadata, equip state, inventory protection, and ArcCW sync behavior.</p></a>
  <a href="items/stackable/" class="home-card"><h3>Stackables</h3><p>Quantity limits, splitting behavior, and stack metadata.</p></a>
  <a href="items/aid/" class="home-card"><h3>Aid Items</h3><p>Medical and support item structure.</p></a>
  <a href="items/ammo/" class="home-card"><h3>Ammo</h3><p>Ammunition item metadata and inventory presentation.</p></a>
  <a href="items/books/" class="home-card"><h3>Books and Notes</h3><p>Readable item content, descriptions, and models.</p></a>
  <a href="items/entities/" class="home-card"><h3>Entity Items</h3><p>World entity bindings and item entity behavior.</p></a>
  <a href="items/grenade/" class="home-card"><h3>Grenades</h3><p>Throwable weapon item fields, class binding, and death-drop behavior.</p></a>
  <a href="items/url/" class="home-card"><h3>URL Items</h3><p>External URL metadata for web-backed items.</p></a>
</div>

## Interface

<div class="home-grid">
  <a href="panels/" class="home-card">
    <span class="card-kicker">Interface</span>
    <h3>VGUI Panels</h3>
    <p>Implemented Lilia panel names, purposes, and common usage contexts.</p>
  </a>
</div>

## Authoring Pattern

| Section | What it answers |
| --- | --- |
| Overview | What this definition controls and where it fits in the framework. |
| Purpose | What a field or callback changes. |
| When Called | When Lilia reads the field or invokes the callback. |
| Realm | Whether the callback is server, client, or shared. |
| Parameters | The values passed into callbacks. |
| Returns | Expected callback return values. |
| Example | Minimal Lua showing the field or callback in context. |
