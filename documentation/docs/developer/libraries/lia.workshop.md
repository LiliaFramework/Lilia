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

# Workshop

Workshop downloader helpers for Lilia server content discovery, synchronization, download prompts, and clientside addon mounting.

---

<h3 style="margin-bottom: 5px;">Overview</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
The workshop library centralizes Workshop collection under `lia.workshop`. It registers server-required Workshop IDs, gathers IDs from mounted addons and module WorkshopContent entries, caches the resulting list for clients, sends workshop metadata to joining players, detects missing client content, requests missing downloads, and displays available server Workshop addons in the information menu.
</div>

---

<details class="realm-server" id="function-liaworkshopaddworkshop">
<summary><span class="summary-main"><a id="lia.workshop.addWorkshop"></a>lia.workshop.addWorkshop(id)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/workshop.lua#L29" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liaworkshopaddworkshop"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Registers a Steam Workshop addon ID as required server content.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string|number</a></span> <span class="parameter">id</span> The Steam Workshop file ID to register.</p>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liaworkshopgather">
<summary><span class="summary-main"><a id="lia.workshop.gather"></a>lia.workshop.gather()</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/workshop.lua#L56" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liaworkshopgather"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Collects all known server Workshop IDs from registered resources, mounted addons, and loaded module WorkshopContent definitions.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> A table keyed by Workshop ID strings with true values for each required addon.</p>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liaworkshopsend">
<summary><span class="summary-main"><a id="lia.workshop.send"></a>lia.workshop.send(ply)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/workshop.lua#L93" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liaworkshopsend"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Sends the cached Workshop ID table to a player through the Workshop downloader start network message.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/player/">Player</a></span> <span class="parameter">ply</span> The player receiving the cached Workshop content list.</p>
</div>

</div>
</details>

---

<details class="realm-client" id="function-liaworkshophascontenttodownload">
<summary><span class="summary-main"><a id="lia.workshop.hasContentToDownload"></a>lia.workshop.hasContentToDownload()</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/workshop.lua#L162" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liaworkshophascontenttodownload"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Checks whether the client is missing any server-required Workshop content that is not already mounted locally.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> True when at least one required Workshop addon still needs to be downloaded or mounted, otherwise false.</p>
</div>

</div>
</details>

---

<details class="realm-client" id="function-liaworkshopmountcontent">
<summary><span class="summary-main"><a id="lia.workshop.mountContent"></a>lia.workshop.mountContent()</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/workshop.lua#L176" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liaworkshopmountcontent"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Prompts the client to download and mount missing server-required Workshop content after calculating the total download size.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

</div>
</details>

---

