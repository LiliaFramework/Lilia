# Workshop Library

Steam Workshop addon downloading, mounting, and management system for the Lilia framework.

---

Overview

The workshop library provides comprehensive functionality for managing Steam Workshop addons in the Lilia framework. It handles automatic downloading, mounting, and management of workshop content required by the gamemode and its modules. The library operates on both server and client sides, with the server gathering workshop IDs from modules and mounted addons, while the client handles downloading and mounting of required content. It includes user interface elements for download progress tracking and addon information display. The library ensures that all required workshop content is available before gameplay begins.

---

<details class="realm-server">
<summary><a id=lia.workshop.addWorkshop></a>lia.workshop.addWorkshop(id)</summary>
<a id="liaworkshopaddworkshop"></a>
<p>Queue a workshop addon for download and notify the admin UI.</p>
<p>During module initialization or whenever a new workshop dependency is registered.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string|number</a></span> <span class="parameter">id</span> Workshop addon ID to download (will be converted to string).</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    -- Register a workshop addon dependency
    lia.workshop.addWorkshop("3527535922")
    lia.workshop.addWorkshop(1234567890) -- Also accepts numbers
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=lia.workshop.gather></a>lia.workshop.gather()</summary>
<a id="liaworkshopgather"></a>
<p>Gather every known workshop ID from mounted addons and registered modules.</p>
<p>Once modules are initialized to cache which workshop addons are needed.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> Set of workshop IDs that should be downloaded/mounted.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    -- Gather all workshop IDs that need to be downloaded
    local workshopIds = lia.workshop.gather()
    lia.workshop.cache = workshopIds
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=lia.workshop.send></a>lia.workshop.send(ply)</summary>
<a id="liaworkshopsend"></a>
<p>Send the cached workshop IDs to a player so the client knows what to download.</p>
<p>Automatically when a player initially spawns.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">ply</span> The player entity to notify.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    -- Send workshop cache to a specific player
    lia.workshop.send(player.GetByID(1))
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=lia.workshop.hasContentToDownload></a>lia.workshop.hasContentToDownload()</summary>
<a id="liaworkshophascontenttodownload"></a>
<p>Determine whether there is any extra workshop content the client needs to download.</p>
<p>Before prompting the player to download server workshop addons.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> true if the client is missing workshop content that needs to be fetched.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    -- Check if client needs to download workshop content
    if lia.workshop.hasContentToDownload() then
        -- Show download prompt to player
    end
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=lia.workshop.mountContent></a>lia.workshop.mountContent()</summary>
<a id="liaworkshopmountcontent"></a>
<p>Initiate mounting (downloading) of server-required workshop addons.</p>
<p>When the player explicitly asks to install missing workshop content from the info panel.</p>
<h3>Example Usage:</h3>
<pre><code class="language-lua">    -- Start downloading missing workshop content
    lia.workshop.mountContent()
</code></pre>
</details>

---

