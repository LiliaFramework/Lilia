# Addon Compatibility

Lilia includes built-in support for many common Garry's Mod admin systems, weapon bases, vehicle addons, PAC3, duplication tools, roleplay addons, and sandbox systems. These integrations help keep permissions, saved data, money, HUD behavior, and anti-abuse features working as expected.

Compatibility can still change depending on addon version and server setup. Before going live, test things like admin commands, purchases, vehicle damage, PAC3 outfits, weapon HUDs, and duplication tools on your own server.

Use this page as a quick guide: find the addons you rely on, see what Lilia already handles, and then test the matching workflow on your server.

## Admin And Permission Systems

<details class="realm-shared no-icon">
<summary>CAMI</summary>
<div class="details-content">

<ul>
  <li>Lets other admin addons recognize Lilia staff ranks.</li>
  <li>Helps synchronize rank changes with Lilia's database-backed permissions.</li>
  <li>Reduces permission conflicts when multiple addons use CAMI checks.</li>
</ul>

</div>
</details>

<details class="realm-shared no-icon">
<summary>SAM</summary>
<div class="details-content">

<ul>
  <li>Allows SAM commands to work while respecting Lilia permissions.</li>
  <li>Synchronizes staff ranks between SAM and Lilia.</li>
  <li>Adds support for staff actions such as blind and unblind.</li>
  <li>Keeps moderation hierarchy checks aligned so staff cannot act above their rank.</li>
</ul>

</div>
</details>

<details class="realm-shared no-icon">
<summary>SAdmin</summary>
<div class="details-content">

<ul>
  <li>Lets SAdmin menus and commands use Lilia rank data.</li>
  <li>Applies permission checks to administrative actions such as kicking and banning.</li>
  <li>Synchronizes usergroups automatically.</li>
</ul>

</div>
</details>

<details class="realm-shared no-icon">
<summary>ServerGuard</summary>
<div class="details-content">

<ul>
  <li>Links ServerGuard ranks with Lilia's permission system.</li>
  <li>Allows ServerGuard commands to run alongside Lilia administration.</li>
</ul>

</div>
</details>

<details class="realm-shared no-icon">
<summary>ULX</summary>
<div class="details-content">

<ul>
  <li>Allows ULX commands and menus to work with Lilia.</li>
  <li>Synchronizes admin and superadmin groups.</li>
  <li>Ensures ULX actions respect Lilia permission rules where compatibility hooks apply.</li>
</ul>

</div>
</details>

## Roleplay And Economy Addons

<details class="realm-shared no-icon">
<summary>DarkRP-oriented addons</summary>
<div class="details-content">

<ul>
  <li>Provides bridge behavior for many addons originally written around DarkRP-style assumptions.</li>
  <li>Maintains compatibility for money, jobs, and entities where supported.</li>
  <li>Reduces common errors when DarkRP-adjacent addons expect roleplay framework functions.</li>
</ul>

</div>
</details>

<details class="realm-shared no-icon">
<summary>VCMod</summary>
<div class="details-content">

<ul>
  <li>Uses character money when players purchase vehicles or upgrades.</li>
  <li>Prevents purchases when the active character cannot afford the cost.</li>
</ul>

</div>
</details>

## Weapons, PAC, And Player Presentation

<details class="realm-shared no-icon">
<summary>ArcCW</summary>
<div class="details-content">

<ul>
  <li>Hides the default ArcCW HUD when it conflicts with Lilia's interface.</li>
  <li>Adjusts weapon dropping and attachment behavior for roleplay servers.</li>
  <li>Applies compatibility settings intended to reduce avoidable performance issues.</li>
</ul>

</div>
</details>

<details class="realm-shared no-icon">
<summary>PAC3</summary>
<div class="details-content">

<ul>
  <li>Helps synchronize player outfits so other clients see them correctly.</li>
  <li>Adds behavior for fixing or disabling problematic outfits.</li>
  <li>Blocks external outfit loading where required for security.</li>
  <li>Applies outfits to ragdolls when characters die.</li>
</ul>

Use the [PAC3 outfit generator](../generators/items/pacoutfit.md) to scaffold PAC-backed item definitions.

</div>
</details>

## Vehicles And Seating

<details class="realm-shared no-icon">
<summary>LVS</summary>
<div class="details-content">

<ul>
  <li>Prevents players from accidentally damaging themselves with their own vehicle weapons or collisions.</li>
</ul>

</div>
</details>

<details class="realm-shared no-icon">
<summary>Simfphys Vehicles</summary>
<div class="details-content">

<ul>
  <li>Applies crash damage behavior for drivers.</li>
  <li>Prevents players from abusing seats on top of vehicles.</li>
  <li>Adds trunk storage support where configured.</li>
  <li>Allows vehicle editing to be restricted to administrators.</li>
</ul>

</div>
</details>

<details class="realm-shared no-icon">
<summary>Sit Anywhere</summary>
<div class="details-content">

<ul>
  <li>Prevents players from sitting on each other or on moving vehicles.</li>
  <li>Reduces seat-based wall and position exploits.</li>
</ul>

</div>
</details>

<details class="realm-shared no-icon">
<summary>Prone Mod</summary>
<div class="details-content">

<ul>
  <li>Automatically returns players to a standing state when they die or switch characters.</li>
</ul>

</div>
</details>

## Building And Duplication Tools

<details class="realm-shared no-icon">
<summary>Advanced Duplicator</summary>
<div class="details-content">

<ul>
  <li>Blocks problematic or restricted duplications.</li>
  <li>Prevents very large props from causing server instability.</li>
  <li>Alerts administrators when suspicious duplications are attempted.</li>
</ul>

</div>
</details>

<details class="realm-shared no-icon">
<summary>Advanced Duplicator 2</summary>
<div class="details-content">

<ul>
  <li>Stops lag-heavy or crash-prone duplications.</li>
  <li>Respects server blacklist settings.</li>
</ul>

</div>
</details>

<details class="realm-shared no-icon">
<summary>PermaProps</summary>
<div class="details-content">

<ul>
  <li>Prevents PermaProps from interfering with Lilia's persistence behavior.</li>
  <li>Warns when a prop is already saved by Lilia.</li>
</ul>

</div>
</details>

<details class="realm-shared no-icon">
<summary>Wiremod</summary>
<div class="details-content">

<ul>
  <li>Restricts potentially dangerous Expression 2 uploads.</li>
  <li>Limits advanced Wiremod features to appropriate ranks such as administrators or donors.</li>
  <li>Keeps Wiremod behavior aligned with Lilia save and protection systems.</li>
</ul>

</div>
</details>

## NPC And Sandbox Systems

<details class="realm-shared no-icon">
<summary>VJ Base</summary>
<div class="details-content">

<ul>
  <li>Disables lag-prone or insecure behavior where compatibility hooks apply.</li>
  <li>Prevents players from spawning game-breaking NPCs.</li>
  <li>Adjusts settings based on player count to reduce avoidable load.</li>
</ul>

</div>
</details>
