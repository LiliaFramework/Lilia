# Install Lilia

Use this guide to bring up a Lilia Garry's Mod server, attach the required workshop content, install a starter schema, and give yourself administrator access. Hosting panels differ, but the required files and startup values are the same.

## Requirements

| Requirement | Why it matters |
| --- | --- |
| Garry's Mod dedicated server | Lilia runs as a Garry's Mod gamemode and expects the normal server folder layout. |
| Lilia workshop content | Clients need the shared materials, icons, interface assets, and framework resources. |
| A Lilia schema | The schema is the gamemode folder the server actually boots into. |
| Server console access | Needed for the first owner or superadmin assignment. |

## Add Workshop Content

Add the Lilia workshop addon to your server collection or resource configuration.

| Field | Value |
| --- | --- |
| Workshop ID | `3527535922` |
| Workshop page | [Lilia Framework content](https://steamcommunity.com/sharedfiles/filedetails/?id=3527535922) |

If your host uses a Steam Workshop collection, include the Lilia addon in that collection. Missing workshop content usually shows up as broken materials, missing icons, or incomplete interface assets when clients join.

## Install a Schema

Lilia needs a schema folder to run. New projects should start from the Skeleton schema because it provides a clean baseline without forcing a finished setting.

1. Download the [Skeleton schema release](https://github.com/LiliaFramework/Skeleton/releases/download/release/skeleton.zip).
2. Extract the archive.
3. Place the `skeleton` folder in `garrysmod/gamemodes/`.
4. Set the server startup command to boot that schema:

```text
+gamemode skeleton
```

The final folder layout should look like this:

```text
garrysmod/
  gamemodes/
    skeleton/
      gamemode/
      schema/
```

!!! tip "Rename later, not first"
    Keep the Skeleton folder name while confirming your first boot. Rename the schema only after the server starts cleanly and you know your startup command, folder path, and workshop content are correct.

## Assign Owner Access

Run this from the server console after the server starts:

```text
plysetgroup "YOUR_STEAMID" "superadmin"
```

Replace `YOUR_STEAMID` with your SteamID, such as `STEAM_0:1:12345678`. Lilia can work with external admin systems such as SAM, ULX, and ServerGuard, but the initial console assignment is the most direct way to unlock in-game staff tools.

## Confirm the Install

Before adding custom addons or schema changes, join the server and check the basics:

- The server loads the schema selected by `+gamemode`.
- Lilia interface assets appear without missing materials.
- Character creation works for the default faction.
- Your account can open staff or admin tools after receiving `superadmin`.
- Server logs do not show repeated Lua errors during connect, character creation, or spawn.

## Next Steps

<div class="card-grid">
  <a href="../features/" class="card">
    <h3>Review systems</h3>
    <p>Plan which built-in Lilia features your server will use before you begin layering custom content.</p>
  </a>
  <a href="../../generators/faction/" class="card">
    <h3>Create factions</h3>
    <p>Generate the major playable groups that define character creation and server access.</p>
  </a>
  <a href="../../generators/class/" class="card">
    <h3>Create classes</h3>
    <p>Generate specialized roles inside a faction, including models, limits, weapons, and permissions.</p>
  </a>
  <a href="../../generators/items/weapons/" class="card">
    <h3>Create items</h3>
    <p>Generate weapon, outfit, bag, consumable, stackable, readable, and utility item definitions.</p>
  </a>
</div>
