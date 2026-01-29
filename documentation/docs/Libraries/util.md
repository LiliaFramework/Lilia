# Utility Library

Common operations and helper functions for the Lilia framework.

---

Overview

The utility library provides comprehensive functionality for common operations and helper functions used throughout the Lilia framework. It contains a wide range of utilities for player management, string processing, entity handling, UI operations, and general purpose calculations. The library is divided into server-side functions for game logic and data management, and client-side functions for user interface, visual effects, and player interaction. These utilities simplify complex operations, provide consistent behavior across the framework, and offer reusable components for modules and plugins. The library handles everything from player identification and spatial queries to advanced UI animations and text processing, ensuring robust and efficient operations across both server and client environments.

---

<details class="realm-shared">
<summary><a id=lia.util.findPlayersInBox></a>lia.util.findPlayersInBox(mins, maxs)</summary>
<a id="liautilfindplayersinbox"></a>
<p>Finds all players within an axis-aligned bounding box.</p>
<p>Use when you need the players contained inside specific world bounds (e.g. triggers or zones).</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Vector">Vector</a></span> <span class="parameter">mins</span> Minimum corner of the search box.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Vector">Vector</a></span> <span class="parameter">maxs</span> Maximum corner of the search box.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> List of player entities inside the box.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local players = lia.util.findPlayersInBox(Vector(-128, -128, 0), Vector(128, 128, 128))
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.util.getBySteamID></a>lia.util.getBySteamID(steamID)</summary>
<a id="liautilgetbysteamid"></a>
<p>Locates a connected player by SteamID or SteamID64 and requires an active character.</p>
<p>Use when commands or systems need to resolve a Steam identifier to a live player with a character loaded.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">steamID</span> SteamID (e.g. "STEAM_0:1:12345") or SteamID64; empty/invalid strings are ignored.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player|nil</a></span> The matching player with a loaded character, or nil if not found/invalid input.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local ply = lia.util.getBySteamID("76561198000000000")
    if ply then print("Found", ply:Name()) end
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.util.findPlayersInSphere></a>lia.util.findPlayersInSphere(origin, radius)</summary>
<a id="liautilfindplayersinsphere"></a>
<p>Returns all players inside a spherical radius from a point.</p>
<p>Use to gather players near a position for proximity-based effects or checks.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Vector">Vector</a></span> <span class="parameter">origin</span> Center of the search sphere.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">radius</span> Radius of the search sphere.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> Players whose positions are within the given radius.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    for _, ply in ipairs(lia.util.findPlayersInSphere(pos, 256)) do
        ply:ChatPrint("You feel a nearby pulse.")
    end
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.util.findPlayer></a>lia.util.findPlayer(client, identifier)</summary>
<a id="liautilfindplayer"></a>
<p>Resolves a player from various identifiers and optionally informs the caller on failure.</p>
<p>Use in admin/command handlers that accept flexible player identifiers (SteamID, SteamID64, name, "^", "@").</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> <span class="optional">optional</span> The player requesting the lookup; used for localized error notifications.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">identifier</span> Identifier to match: SteamID, SteamID64, "^" (self), "@" (trace target), or partial name.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player|nil</a></span> Matched player or nil when no match is found/identifier is invalid.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local target = lia.util.findPlayer(caller, args[1])
    if not target then return end
    target:kick("Example")
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.util.findPlayerItems></a>lia.util.findPlayerItems(client)</summary>
<a id="liautilfindplayeritems"></a>
<p>Collects all spawned item entities created by a specific player.</p>
<p>Use when cleaning up or inspecting items a player has spawned into the world.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> Player whose created item entities should be found.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> List of item entities created by the player.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    for _, ent in ipairs(lia.util.findPlayerItems(ply)) do
        ent:Remove()
    end
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.util.findPlayerItemsByClass></a>lia.util.findPlayerItemsByClass(client, class)</summary>
<a id="liautilfindplayeritemsbyclass"></a>
<p>Collects spawned item entities from a player filtered by item class.</p>
<p>Use when you need only specific item classes (by netvar "id") created by a player.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> Player whose item entities are being inspected.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">class</span> Item class/netvar id to match.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> Item entities created by the player that match the class.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local ammo = lia.util.findPlayerItemsByClass(ply, "ammo_9mm")
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.util.findPlayerEntities></a>lia.util.findPlayerEntities(client, class)</summary>
<a id="liautilfindplayerentities"></a>
<p>Finds entities created by or associated with a player, optionally by class.</p>
<p>Use to track props or scripted entities a player spawned or owns.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> Player whose entities should be matched.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">class</span> <span class="optional">optional</span> Optional entity class filter; nil includes all classes.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> Entities created by or linked via entity.client to the player that match the class filter.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local ragdolls = lia.util.findPlayerEntities(ply, "prop_ragdoll")
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.util.stringMatches></a>lia.util.stringMatches(a, b)</summary>
<a id="liautilstringmatches"></a>
<p>Performs case-insensitive equality and substring comparison between two strings.</p>
<p>Use for loose name matching where exact case is not important.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">a</span> First string to compare.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">b</span> Second string to compare.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> True if the strings are equal (case-insensitive) or one contains the other; otherwise false.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    if lia.util.stringMatches(ply:Name(), "john") then print("Matched player") end
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.util.getAdmins></a>lia.util.getAdmins()</summary>
<a id="liautilgetadmins"></a>
<p>Returns all connected staff members.</p>
<p>Use when broadcasting staff notifications or iterating over staff-only recipients.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> Players that pass `isStaff()`.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    for _, admin in ipairs(lia.util.getAdmins()) do
        admin:notify("Server restart in 5 minutes.")
    end
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.util.findPlayerBySteamID64></a>lia.util.findPlayerBySteamID64(SteamID64)</summary>
<a id="liautilfindplayerbysteamid64"></a>
<p>Resolves a player from a SteamID64 wrapper around `findPlayerBySteamID`.</p>
<p>Use when you have a 64-bit SteamID and need the corresponding player entity.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">SteamID64</span> SteamID64 to resolve.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player|nil</a></span> Matching player or nil when none is found/SteamID64 is invalid.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local ply = lia.util.findPlayerBySteamID64(steamID64)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.util.findPlayerBySteamID></a>lia.util.findPlayerBySteamID(SteamID)</summary>
<a id="liautilfindplayerbysteamid"></a>
<p>Searches connected players for a matching SteamID.</p>
<p>Use when you need to map a SteamID string to the in-game player.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">SteamID</span> SteamID in legacy format (e.g. "STEAM_0:1:12345").</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player|nil</a></span> Player whose SteamID matches, or nil if none.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local ply = lia.util.findPlayerBySteamID("STEAM_0:1:12345")
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.util.canFit></a>lia.util.canFit(pos, mins, maxs, filter)</summary>
<a id="liautilcanfit"></a>
<p>Checks whether a bounding hull can fit at a position without collisions.</p>
<p>Use before spawning or teleporting entities to ensure the space is clear.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Vector">Vector</a></span> <span class="parameter">pos</span> Position to test.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Vector">Vector</a></span> <span class="parameter">mins</span> Hull minimums; defaults to Vector(16, 16, 0) mirrored if positive.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Vector">Vector</a></span> <span class="parameter">maxs</span> <span class="optional">optional</span> Hull maximums; defaults to mins when nil.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Entity">Entity|table</a></span> <span class="parameter">filter</span> <span class="optional">optional</span> Entity or filter list to ignore in the trace.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> True if the hull does not hit anything solid, false otherwise.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    if lia.util.canFit(pos, Vector(16, 16, 0)) then
        ent:SetPos(pos)
    end
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.util.playerInRadius></a>lia.util.playerInRadius(pos, dist)</summary>
<a id="liautilplayerinradius"></a>
<p>Finds all players within a given radius.</p>
<p>Use for proximity-based logic such as AoE effects or notifications.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Vector">Vector</a></span> <span class="parameter">pos</span> Center position for the search.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">dist</span> Radius to search, in units.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> Players whose distance squared to pos is less than dist^2.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    for _, ply in ipairs(lia.util.playerInRadius(pos, 512)) do
        ply:notify("You are near the beacon.")
    end
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.util.formatStringNamed></a>lia.util.formatStringNamed(format)</summary>
<a id="liautilformatstringnamed"></a>
<p>Formats a string using named placeholders or positional arguments.</p>
<p>Use to substitute tokens in a template string with table keys or ordered arguments.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">format</span> Template containing placeholders like "{name}".</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> The formatted string with placeholders replaced.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.util.formatStringNamed("Hello {who}", {who = "world"})
    lia.util.formatStringNamed("{1} + {2}", 1, 2)
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.util.getMaterial></a>lia.util.getMaterial(materialPath, materialParameters)</summary>
<a id="liautilgetmaterial"></a>
<p>Retrieves and caches a material by path and parameters.</p>
<p>Use whenever drawing materials repeatedly to avoid recreating them.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">materialPath</span> Path to the material.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">materialParameters</span> <span class="optional">optional</span> Optional material creation parameters.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/IMaterial">IMaterial</a></span> Cached or newly created material instance.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local blurMat = lia.util.getMaterial("pp/blurscreen")
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.util.findFaction></a>lia.util.findFaction(client, name)</summary>
<a id="liautilfindfaction"></a>
<p>Resolves a faction table by name or unique ID and notifies the caller on failure.</p>
<p>Use in commands or UI when users input a faction identifier.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> Player to notify on invalid faction.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">name</span> Faction name or uniqueID to search for.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table|nil</a></span> Matching faction table, or nil if not found.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local faction = lia.util.findFaction(ply, "combine")
    if faction then print(faction.name) end
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.util.generateRandomName></a>lia.util.generateRandomName(firstNames, lastNames)</summary>
<a id="liautilgeneraterandomname"></a>
<p>Generates a random full name from provided or default name lists.</p>
<p>Use when creating placeholder or randomized character names.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">firstNames</span> <span class="optional">optional</span> Optional list of first names to draw from; defaults to built-in list when nil/empty.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">lastNames</span> <span class="optional">optional</span> Optional list of last names to draw from; defaults to built-in list when nil/empty.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> Concatenated first and last name.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local name = lia.util.generateRandomName()
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=lia.util.sendTableUI></a>lia.util.sendTableUI(client, title, columns, data, options, characterID)</summary>
<a id="liautilsendtableui"></a>
<p>Sends a localized table UI payload to a client.</p>
<p>Use when the server needs to present tabular data/options to a specific player.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> Recipient player.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">title</span> <span class="optional">optional</span> Localization key for the window title; defaults to "tableListTitle".</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">columns</span> Column definitions; names are localized if present.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">data</span> Row data to display.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">options</span> <span class="optional">optional</span> Optional menu options to accompany the table.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">characterID</span> <span class="optional">optional</span> Optional character identifier to send with the payload.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.util.sendTableUI(ply, "staffList", columns, rows, options, charID)
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=lia.util.findEmptySpace></a>lia.util.findEmptySpace(entity, filter, spacing, size, height, tolerance)</summary>
<a id="liautilfindemptyspace"></a>
<p>Finds nearby empty positions around an entity using grid sampling.</p>
<p>Use when spawning items or players near an entity while avoiding collisions and the void.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Entity">Entity</a></span> <span class="parameter">entity</span> Origin entity to search around.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Entity">Entity|table</a></span> <span class="parameter">filter</span> <span class="optional">optional</span> Optional trace filter to ignore certain entities; defaults to the origin entity.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">spacing</span> Grid spacing between samples; defaults to 32.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">size</span> Number of steps in each direction from the origin; defaults to 3.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">height</span> Hull height used for traces; defaults to 36.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">tolerance</span> Upward offset to avoid starting inside the ground; defaults to 5.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> Sorted list of valid origin positions, nearest to farthest from the entity.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local spots = lia.util.findEmptySpace(ent, nil, 24)
    local pos = spots[1]
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=lia.util.animateAppearance></a>lia.util.animateAppearance(panel, targetWidth, targetHeight, duration, alphaDuration, callback, scaleFactor)</summary>
<a id="liautilanimateappearance"></a>
<p>Animates a panel appearing from a scaled, transparent state to its target size and opacity.</p>
<p>Use when showing popups or menus that should ease into view.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Panel">Panel</a></span> <span class="parameter">panel</span> Panel to animate.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">targetWidth</span> Final width of the panel.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">targetHeight</span> Final height of the panel.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">duration</span> <span class="optional">optional</span> Duration for size/position easing; defaults to 0.18 seconds.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">alphaDuration</span> <span class="optional">optional</span> Duration for alpha easing; defaults to duration.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.6">function</a></span> <span class="parameter">callback</span> <span class="optional">optional</span> Called when the animation finishes.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">scaleFactor</span> <span class="optional">optional</span> Initial size scale relative to target; defaults to 0.8.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.util.animateAppearance(panel, 300, 200)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=lia.util.clampMenuPosition></a>lia.util.clampMenuPosition(panel)</summary>
<a id="liautilclampmenuposition"></a>
<p>Keeps a menu panel within the screen bounds, respecting the character logo space.</p>
<p>Use after positioning a menu to prevent it from going off-screen.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Panel">Panel</a></span> <span class="parameter">panel</span> Menu panel to clamp.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.util.clampMenuPosition(menu)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=lia.util.drawGradient></a>lia.util.drawGradient(x, y, w, h, direction, colorShadow, radius, flags)</summary>
<a id="liautildrawgradient"></a>
<p>Draws a directional gradient rectangle.</p>
<p>Use in panel paints when you need simple gradient backgrounds.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">x</span> X position of the gradient.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">y</span> Y position of the gradient.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">w</span> Width of the gradient.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">h</span> Height of the gradient.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">direction</span> Gradient direction index (1 up, 2 down, 3 left, 4 right).</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Color">Color</a></span> <span class="parameter">colorShadow</span> Color tint for the gradient.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">radius</span> <span class="optional">optional</span> Corner radius for drawing helper; defaults to 0.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">flags</span> <span class="optional">optional</span> Optional draw flags passed to `drawMaterial`.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.util.drawGradient(0, 0, w, h, 2, Color(0, 0, 0, 180))
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=lia.util.wrapText></a>lia.util.wrapText(text, width, font)</summary>
<a id="liautilwraptext"></a>
<p>Wraps text to a maximum width using a specified font.</p>
<p>Use when drawing text that must fit inside a set horizontal space.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">text</span> Text to wrap.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">width</span> Maximum width in pixels.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">font</span> <span class="optional">optional</span> Font name to measure with; defaults to "LiliaFont.16".</p>

<p><h3>Returns:</h3>
table, number Array of wrapped lines and the widest line width.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local lines = lia.util.wrapText(description, 300, "LiliaFont.17")
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=lia.util.drawBlur></a>lia.util.drawBlur(panel, amount, passes, alpha)</summary>
<a id="liautildrawblur"></a>
<p>Draws a blurred background behind a panel.</p>
<p>Use inside a panel's Paint hook to soften the content behind it.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Panel">Panel</a></span> <span class="parameter">panel</span> Panel whose screen area will be blurred.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">amount</span> <span class="optional">optional</span> Blur strength; defaults to 5.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">passes</span> <span class="optional">optional</span> Unused; kept for signature compatibility.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">alpha</span> <span class="optional">optional</span> Draw color alpha; defaults to 255.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.util.drawBlur(self, 4)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=lia.util.drawBlackBlur></a>lia.util.drawBlackBlur(panel, amount, passes, alpha, darkAlpha)</summary>
<a id="liautildrawblackblur"></a>
<p>Draws a blurred background with a dark overlay in a panel's bounds.</p>
<p>Use for modal overlays where both blur and darkening are desired.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Panel">Panel</a></span> <span class="parameter">panel</span> Panel area to blur.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">amount</span> <span class="optional">optional</span> Blur strength; defaults to 6.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">passes</span> <span class="optional">optional</span> Number of blur passes; defaults to 5.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">alpha</span> <span class="optional">optional</span> Blur draw alpha; defaults to 255.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">darkAlpha</span> <span class="optional">optional</span> Alpha for the black overlay; defaults to 220.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.util.drawBlackBlur(self, 6, 4, 255, 200)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=lia.util.drawBlurAt></a>lia.util.drawBlurAt(x, y, w, h, amount, passes, alpha)</summary>
<a id="liautildrawblurat"></a>
<p>Draws a blur effect over a specific rectangle on the screen.</p>
<p>Use when you need a localized blur that is not tied to a panel.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">x</span> X coordinate of the rectangle.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">y</span> Y coordinate of the rectangle.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">w</span> Width of the rectangle.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">h</span> Height of the rectangle.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">amount</span> <span class="optional">optional</span> Blur strength; defaults to 5.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">passes</span> <span class="optional">optional</span> Number of blur samples; defaults to 0.2 steps when nil.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">alpha</span> <span class="optional">optional</span> Draw alpha; defaults to 255.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.util.drawBlurAt(100, 100, 200, 150, 4)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=lia.util.requestEntityInformation></a>lia.util.requestEntityInformation(entity, argTypes, callback)</summary>
<a id="liautilrequestentityinformation"></a>
<p>Prompts the user for entity information and forwards the result.</p>
<p>Use when a client must supply additional data for an entity action.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Entity">Entity</a></span> <span class="parameter">entity</span> Entity that the information pertains to; removed if the request fails.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">argTypes</span> Argument descriptors passed to `requestArguments`.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.6">function</a></span> <span class="parameter">callback</span> <span class="optional">optional</span> Invoked with the collected information on success.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.util.requestEntityInformation(ent, argTypes, function(info) print(info) end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=lia.util.createTableUI></a>lia.util.createTableUI(title, columns, data, options, charID)</summary>
<a id="liautilcreatetableui"></a>
<p>Builds and displays a table UI on the client.</p>
<p>Use when the client needs to view tabular data with optional menu actions.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">title</span> <span class="optional">optional</span> Localization key for the frame title; defaults to "tableListTitle".</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">columns</span> Column definitions with `name`, `width`, `align`, and `sortable` fields.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">data</span> Row data keyed by column field names.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">options</span> <span class="optional">optional</span> Optional menu options with callbacks or net names.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">charID</span> <span class="optional">optional</span> Character identifier forwarded with net options.</p>

<p><h3>Returns:</h3>
Panel, Panel The created frame and table list view.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local frame, list = lia.util.createTableUI("myData", cols, rows)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=lia.util.openOptionsMenu></a>lia.util.openOptionsMenu(title, options)</summary>
<a id="liautilopenoptionsmenu"></a>
<p>Displays a simple options menu with clickable entries.</p>
<p>Use to quickly prompt the user with a list of named actions.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">title</span> <span class="optional">optional</span> Title text to show at the top of the menu; defaults to "options".</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">options</span> Either an array of {name, callback} or a map of name -> callback.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Panel">Panel|nil</a></span> The created frame, or nil if no valid options exist.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.util.openOptionsMenu("choose", {{"Yes", onYes}, {"No", onNo}})
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=lia.util.drawEntText></a>lia.util.drawEntText(ent, text, posY, alphaOverride)</summary>
<a id="liautildrawenttext"></a>
<p>Draws floating text above an entity that eases in based on distance.</p>
<p>Use in HUD painting to label world entities when nearby.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Entity">Entity</a></span> <span class="parameter">ent</span> Entity to draw text above.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">text</span> Text to display.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">posY</span> <span class="optional">optional</span> Vertical offset in screen space; defaults to 0.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">alphaOverride</span> <span class="optional">optional</span> Optional alpha multiplier (0-1 or 0-255).</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("HUDPaint", "DrawEntLabels", function()
        lia.util.drawEntText(ent, "Storage")
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=lia.util.drawLookText></a>lia.util.drawLookText(text, posY, Screen, Screen, alphaOverride, maxDist)</summary>
<a id="liautildrawlooktext"></a>
<p>Draws text at the player's look position with distance-based easing.</p>
<p>Use to display contextual prompts or hints where the player is aiming.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">text</span> Text to render at the hit position.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">posY</span> <span class="optional">optional</span> Screen-space vertical offset; defaults to 0.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">unknown</a></span> <span class="parameter">Screen</span> space vertical offset; defaults to 0.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">unknown</a></span> <span class="parameter">Screen</span> space vertical offset; defaults to 0.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">alphaOverride</span> <span class="optional">optional</span> Optional alpha multiplier (0-1 or 0-255).</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">maxDist</span> <span class="optional">optional</span> Maximum trace distance; defaults to 380 units.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.util.drawLookText("Press E to interact")
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=lia.util.setFeaturePosition></a>lia.util.setFeaturePosition(pos, typeId)</summary>
<a id="liautilsetfeatureposition"></a>
<p>Sets a feature position using the position tool callback system.</p>
<p>Called by the position tool when a player sets a position (left-click or Shift+R).</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Vector">Vector</a></span> <span class="parameter">pos</span> The world position to set.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">typeId</span> The type ID of the position callback (e.g., "faction_spawn_adder", "sit_room").</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.util.setFeaturePosition(Vector(0, 0, 0), "faction_spawn_adder")
</code></pre>
</details>

---

