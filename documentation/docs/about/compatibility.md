# Addon Compatibility

Lilia includes compatibility behavior for common Garry's Mod admin systems, weapon bases, vehicle addons, PAC3, duplication tools, roleplay addons, and sandbox systems. These integrations help protect Lilia's permissions, persistence, character money, HUD behavior, and anti-abuse systems.

Compatibility can still vary by addon version and server configuration. Test admin commands, economy purchases, vehicle damage, PAC3 outfits, weapon HUD behavior, and duplication tools before opening a live server.

## Admin And Permission Systems

<details class="realm-shared no-icon">
<summary>CAMI</summary>
<div class="details-content">

- Lets other admin addons recognize Lilia staff ranks.
- Helps synchronize rank changes with Lilia's database-backed permissions.
- Reduces permission conflicts when multiple addons use CAMI checks.

</div>
</details>

<details class="realm-shared no-icon">
<summary>SAM</summary>
<div class="details-content">

- Allows SAM commands to work while respecting Lilia permissions.
- Synchronizes staff ranks between SAM and Lilia.
- Adds support for staff actions such as blind and unblind.
- Keeps moderation hierarchy checks aligned so staff cannot act above their rank.

</div>
</details>

<details class="realm-shared no-icon">
<summary>SAdmin</summary>
<div class="details-content">

- Lets SAdmin menus and commands use Lilia rank data.
- Applies permission checks to administrative actions such as kicking and banning.
- Synchronizes usergroups automatically.

</div>
</details>

<details class="realm-shared no-icon">
<summary>ServerGuard</summary>
<div class="details-content">

- Links ServerGuard ranks with Lilia's permission system.
- Allows ServerGuard commands to run alongside Lilia administration.

</div>
</details>

<details class="realm-shared no-icon">
<summary>ULX</summary>
<div class="details-content">

- Allows ULX commands and menus to work with Lilia.
- Synchronizes admin and superadmin groups.
- Ensures ULX actions respect Lilia permission rules where compatibility hooks apply.

</div>
</details>

## Roleplay And Economy Addons

<details class="realm-shared no-icon">
<summary>DarkRP-oriented addons</summary>
<div class="details-content">

- Provides bridge behavior for many addons originally written around DarkRP-style assumptions.
- Maintains compatibility for money, jobs, and entities where supported.
- Reduces common errors when DarkRP-adjacent addons expect roleplay framework functions.

</div>
</details>

<details class="realm-shared no-icon">
<summary>VCMod</summary>
<div class="details-content">

- Uses character money when players purchase vehicles or upgrades.
- Prevents purchases when the active character cannot afford the cost.

</div>
</details>

## Weapons, PAC, And Player Presentation

<details class="realm-shared no-icon">
<summary>ArcCW</summary>
<div class="details-content">

- Hides the default ArcCW HUD when it conflicts with Lilia's interface.
- Adjusts weapon dropping and attachment behavior for roleplay servers.
- Applies compatibility settings intended to reduce avoidable performance issues.

</div>
</details>

<details class="realm-shared no-icon">
<summary>PAC3</summary>
<div class="details-content">

- Helps synchronize player outfits so other clients see them correctly.
- Adds behavior for fixing or disabling problematic outfits.
- Blocks external outfit loading where required for security.
- Applies outfits to ragdolls when characters die.

Use the [PAC3 outfit generator](../generators/items/pacoutfit.md) to scaffold PAC-backed item definitions.

</div>
</details>

## Vehicles And Seating

<details class="realm-shared no-icon">
<summary>LVS</summary>
<div class="details-content">

- Prevents players from accidentally damaging themselves with their own vehicle weapons or collisions.

</div>
</details>

<details class="realm-shared no-icon">
<summary>Simfphys Vehicles</summary>
<div class="details-content">

- Applies crash damage behavior for drivers.
- Prevents players from abusing seats on top of vehicles.
- Adds trunk storage support where configured.
- Allows vehicle editing to be restricted to administrators.

</div>
</details>

<details class="realm-shared no-icon">
<summary>Sit Anywhere</summary>
<div class="details-content">

- Prevents players from sitting on each other or on moving vehicles.
- Reduces seat-based wall and position exploits.

</div>
</details>

<details class="realm-shared no-icon">
<summary>Prone Mod</summary>
<div class="details-content">

- Automatically returns players to a standing state when they die or switch characters.

</div>
</details>

## Building And Duplication Tools

<details class="realm-shared no-icon">
<summary>Advanced Duplicator</summary>
<div class="details-content">

- Blocks problematic or restricted duplications.
- Prevents very large props from causing server instability.
- Alerts administrators when suspicious duplications are attempted.

</div>
</details>

<details class="realm-shared no-icon">
<summary>Advanced Duplicator 2</summary>
<div class="details-content">

- Stops lag-heavy or crash-prone duplications.
- Respects server blacklist settings.

</div>
</details>

<details class="realm-shared no-icon">
<summary>PermaProps</summary>
<div class="details-content">

- Prevents PermaProps from interfering with Lilia's persistence behavior.
- Warns when a prop is already saved by Lilia.

</div>
</details>

<details class="realm-shared no-icon">
<summary>Wiremod</summary>
<div class="details-content">

- Restricts potentially dangerous Expression 2 uploads.
- Limits advanced Wiremod features to appropriate ranks such as administrators or donors.
- Keeps Wiremod behavior aligned with Lilia save and protection systems.

</div>
</details>

## NPC And Sandbox Systems

<details class="realm-shared no-icon">
<summary>VJ Base</summary>
<div class="details-content">

- Disables lag-prone or insecure behavior where compatibility hooks apply.
- Prevents players from spawning game-breaking NPCs.
- Adjusts settings based on player count to reduce avoidable load.

</div>
</details>

## Launch Checklist

| Area | What to verify |
| --- | --- |
| Permissions | Your admin system recognizes Lilia ranks and respects hierarchy checks. |
| Economy | Addons that charge money read and write character money correctly. |
| Weapons | Weapon bases do not duplicate HUD elements or bypass inventory expectations. |
| PAC3 | Outfits apply, replicate, unequip, and appear on ragdolls as expected. |
| Vehicles | Purchase, damage, trunk, and seat behavior do not bypass roleplay rules. |
| Duplication tools | Ordinary duplications work while large or blacklisted duplications are blocked. |
| Logs | Server logs stay clean after testing the highest-risk addon workflows. |
