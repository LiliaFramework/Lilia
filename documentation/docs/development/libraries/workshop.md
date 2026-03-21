# Workshop

Steam Workshop addon downloading, mounting, and management system for the Lilia framework.

---

<details class="realm-server" id="function-liaworkshopaddworkshop">
<summary><a id="lia.workshop.addWorkshop"></a>lia.workshop.addWorkshop(id)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liaworkshopaddworkshop"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Add a workshop ID to the list of required addons.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">id</span> Workshop addon ID to add.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.workshop.addWorkshop("123456789")
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liaworkshopgather">
<summary><a id="lia.workshop.gather"></a>lia.workshop.gather()</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liaworkshopgather"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Gather every known workshop ID from mounted addons and registered modules.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Once modules are initialized to cache which workshop addons are needed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> Set of workshop IDs that should be downloaded/mounted.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  -- Gather all workshop IDs that need to be downloaded
  local workshopIds = lia.workshop.gather()
  lia.workshop.cache = workshopIds
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liaworkshopsend">
<summary><a id="lia.workshop.send"></a>lia.workshop.send(ply)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liaworkshopsend"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Send the cached workshop IDs to a player so the client knows what to download.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Automatically when a player initially spawns.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">ply</span> The player entity to notify.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  -- Send workshop cache to a specific player
  lia.workshop.send(player.GetByID(1))
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-liaworkshophascontenttodownload">
<summary><a id="lia.workshop.hasContentToDownload"></a>lia.workshop.hasContentToDownload()</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liaworkshophascontenttodownload"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Determine whether there is any extra workshop content the client needs to download.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Before prompting the player to download server workshop addons.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> true if the client is missing workshop content that needs to be fetched.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  -- Check if client needs to download workshop content
  if lia.workshop.hasContentToDownload() then
      -- Show download prompt to player
  end
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-liaworkshopmountcontent">
<summary><a id="lia.workshop.mountContent"></a>lia.workshop.mountContent()</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liaworkshopmountcontent"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Initiate mounting (downloading) of server-required workshop addons.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When the player explicitly asks to install missing workshop content from the info panel.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  -- Start downloading missing workshop content
  lia.workshop.mountContent()
</code></pre>
</div>

</div>
</details>

---

