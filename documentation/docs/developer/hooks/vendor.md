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

# Vendor

This page documents the hooks defined by the vendor module.

---

<details class="realm-server" id="function-canplayeraccessvendor">
<summary><span class="summary-main"><a id="CanPlayerAccessVendor"></a>CanPlayerAccessVendor(client, vendor)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/vendor/module.lua#L1" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="canplayeraccessvendor"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Determines whether a player may open or continue using a vendor.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Vendor</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/player/">Player</a></span> <span class="parameter">client</span> The player attempting to access the vendor.</p>
<p><span class="types"><a class="type" href="/developer/meta/entity/">Entity</a></span> <span class="parameter">vendor</span> The vendor entity being accessed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean|nil</a></span> Return false to block vendor access.</p>
</div>

</div>
</details>

---

<details class="realm-server" id="function-canplayertradewithvendor">
<summary><span class="summary-main"><a id="CanPlayerTradeWithVendor"></a>CanPlayerTradeWithVendor(client, vendor, itemType, isSellingToVendor)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/vendor/module.lua#L25" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="canplayertradewithvendor"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Determines whether a player may buy or sell a specific item through a vendor.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Vendor</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/player/">Player</a></span> <span class="parameter">client</span> The player attempting the trade.</p>
<p><span class="types"><a class="type" href="/developer/meta/entity/">Entity</a></span> <span class="parameter">vendor</span> The vendor handling the trade.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">itemType</span> The item unique ID being traded.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">isSellingToVendor</span> Whether the player is selling the item to the vendor instead of buying it.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p>boolean|nil, string|nil, any Return false to block the trade. Additional return values may supply a localized reason and optional format parameter.</p>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-getpriceoverride">
<summary><span class="summary-main"><a id="GetPriceOverride"></a>GetPriceOverride(client, vendor, uniqueID, price, isSellingToVendor)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/vendor/module.lua#L55" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="getpriceoverride"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Allows code to override a vendor trade price for a player.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Vendor</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/player/">Player</a></span> <span class="parameter">client</span> The player receiving the quoted price.</p>
<p><span class="types"><a class="type" href="/developer/meta/entity/">Entity</a></span> <span class="parameter">vendor</span> The vendor entity pricing the trade.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">uniqueID</span> The item unique ID being priced.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">price</span> The default calculated price.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">isSellingToVendor</span> Whether the player is selling to the vendor.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number|nil</a></span> Return a replacement price.</p>
</div>

</div>
</details>

---

<details class="realm-server" id="function-onchartradevendor">
<summary><span class="summary-main"><a id="OnCharTradeVendor"></a>OnCharTradeVendor(client, vendor, item, isSellingToVendor, character, itemType, isFailed)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/vendor/module.lua#L88" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="onchartradevendor"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called after the vendor system processes a character trade attempt.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Vendor</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/player/">Player</a></span> <span class="parameter">client</span> The player trading with the vendor.</p>
<p><span class="types"><a class="type" href="/developer/meta/entity/">Entity</a></span> <span class="parameter">vendor</span> The vendor entity used for the trade.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">item</span> <span class="optional">optional</span> The traded item instance when available.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">isSellingToVendor</span> Whether the player sold to the vendor.</p>
<p><span class="types"><a class="type" href="/developer/libraries/char/">Character</a></span> <span class="parameter">character</span> The trading character.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">itemType</span> <span class="optional">optional</span> The item unique ID involved in the trade when no item instance was created.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">isFailed</span> <span class="optional">optional</span> Whether the trade attempt failed after validation.</p>
</div>

</div>
</details>

---

<details class="realm-client" id="function-onopenvendormenu">
<summary><span class="summary-main"><a id="OnOpenVendorMenu"></a>OnOpenVendorMenu(panelOwner, vendor)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/vendor/module.lua#L126" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="onopenvendormenu"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called on the client after the vendor UI is created.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Vendor</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">panelOwner</span> The vendor module instance opening the UI.</p>
<p><span class="types"><a class="type" href="/developer/meta/entity/">Entity</a></span> <span class="parameter">vendor</span> The vendor entity being shown.</p>
</div>

</div>
</details>

---

<details class="realm-server" id="function-onvendoredited">
<summary><span class="summary-main"><a id="OnVendorEdited"></a>OnVendorEdited(client, vendor, key)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/vendor/module.lua#L149" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="onvendoredited"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called after a player edits a vendor setting on the server.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Vendor</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/player/">Player</a></span> <span class="parameter">client</span> The player who edited the vendor.</p>
<p><span class="types"><a class="type" href="/developer/meta/entity/">Entity</a></span> <span class="parameter">vendor</span> The vendor that was edited.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">key</span> The edited property key.</p>
</div>

</div>
</details>

---

<details class="realm-server" id="function-playeraccessvendor">
<summary><span class="summary-main"><a id="PlayerAccessVendor"></a>PlayerAccessVendor(client, vendor)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/vendor/module.lua#L175" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="playeraccessvendor"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called after a player is granted access to a vendor and the open packets are sent.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Vendor</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/player/">Player</a></span> <span class="parameter">client</span> The player opening the vendor.</p>
<p><span class="types"><a class="type" href="/developer/meta/entity/">Entity</a></span> <span class="parameter">vendor</span> The vendor entity being opened.</p>
</div>

</div>
</details>

---

<details class="realm-client" id="function-vendorclassupdated">
<summary><span class="summary-main"><a id="VendorClassUpdated"></a>VendorClassUpdated(vendor, id, allowed)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/vendor/module.lua#L198" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="vendorclassupdated"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called on the client after a vendor class whitelist entry changes.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Vendor</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/entity/">Entity</a></span> <span class="parameter">vendor</span> The updated vendor.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">id</span> The class index that changed.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">allowed</span> Whether the class is now allowed.</p>
</div>

</div>
</details>

---

<details class="realm-client" id="function-vendoredited">
<summary><span class="summary-main"><a id="VendorEdited"></a>VendorEdited(vendor, key)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/vendor/module.lua#L224" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="vendoredited"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called on the client after a vendor edit synchronization updates a field.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Vendor</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/entity/">Entity</a></span> <span class="parameter">vendor</span> The edited vendor.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">key</span> The property key that changed.</p>
</div>

</div>
</details>

---

<details class="realm-client" id="function-vendorexited">
<summary><span class="summary-main"><a id="VendorExited"></a>VendorExited()</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/vendor/module.lua#L247" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="vendorexited"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called on the client after the vendor UI is closed by a networked exit event.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Vendor</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

</div>
</details>

---

<details class="realm-client" id="function-vendorfactionbuyscaleupdated">
<summary><span class="summary-main"><a id="VendorFactionBuyScaleUpdated"></a>VendorFactionBuyScaleUpdated(vendor, factionID, scale)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/vendor/module.lua#L266" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="vendorfactionbuyscaleupdated"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called on the client after a faction buy scale changes for a vendor.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Vendor</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/entity/">Entity</a></span> <span class="parameter">vendor</span> The updated vendor.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">factionID</span> The faction index whose buy scale changed.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">scale</span> The new buy scale value.</p>
</div>

</div>
</details>

---

<details class="realm-client" id="function-vendorfactionsellscaleupdated">
<summary><span class="summary-main"><a id="VendorFactionSellScaleUpdated"></a>VendorFactionSellScaleUpdated(vendor, factionID, scale)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/vendor/module.lua#L292" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="vendorfactionsellscaleupdated"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called on the client after a faction sell scale changes for a vendor.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Vendor</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/entity/">Entity</a></span> <span class="parameter">vendor</span> The updated vendor.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">factionID</span> The faction index whose sell scale changed.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">scale</span> The new sell scale value.</p>
</div>

</div>
</details>

---

<details class="realm-client" id="function-vendorfactionupdated">
<summary><span class="summary-main"><a id="VendorFactionUpdated"></a>VendorFactionUpdated(vendor, id, allowed)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/vendor/module.lua#L318" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="vendorfactionupdated"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called on the client after a vendor faction whitelist entry changes.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Vendor</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/entity/">Entity</a></span> <span class="parameter">vendor</span> The updated vendor.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">id</span> The faction index that changed.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">allowed</span> Whether the faction is now allowed.</p>
</div>

</div>
</details>

---

<details class="realm-client" id="function-vendoritembuypriceupdated">
<summary><span class="summary-main"><a id="VendorItemBuyPriceUpdated"></a>VendorItemBuyPriceUpdated(vendor, itemType, value)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/vendor/module.lua#L344" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="vendoritembuypriceupdated"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called on the client after a vendor item buy price changes.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Vendor</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/entity/">Entity</a></span> <span class="parameter">vendor</span> The updated vendor.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">itemType</span> The affected item unique ID.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">value</span> The new buy price.</p>
</div>

</div>
</details>

---

<details class="realm-client" id="function-vendoritemmaxstockupdated">
<summary><span class="summary-main"><a id="VendorItemMaxStockUpdated"></a>VendorItemMaxStockUpdated(vendor, itemType, value)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/vendor/module.lua#L370" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="vendoritemmaxstockupdated"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called on the client after a vendor item max stock value changes.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Vendor</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/entity/">Entity</a></span> <span class="parameter">vendor</span> The updated vendor.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">itemType</span> The affected item unique ID.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">value</span> The new max stock value.</p>
</div>

</div>
</details>

---

<details class="realm-client" id="function-vendoritemmodeupdated">
<summary><span class="summary-main"><a id="VendorItemModeUpdated"></a>VendorItemModeUpdated(vendor, itemType, value)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/vendor/module.lua#L396" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="vendoritemmodeupdated"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called on the client after a vendor item trade mode changes.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Vendor</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/entity/">Entity</a></span> <span class="parameter">vendor</span> The updated vendor.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">itemType</span> The affected item unique ID.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">value</span> The new vendor trade mode.</p>
</div>

</div>
</details>

---

<details class="realm-client" id="function-vendoritemsellpriceupdated">
<summary><span class="summary-main"><a id="VendorItemSellPriceUpdated"></a>VendorItemSellPriceUpdated(vendor, itemType, value)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/vendor/module.lua#L422" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="vendoritemsellpriceupdated"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called on the client after a vendor item sell price changes.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Vendor</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/entity/">Entity</a></span> <span class="parameter">vendor</span> The updated vendor.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">itemType</span> The affected item unique ID.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">value</span> The new sell price.</p>
</div>

</div>
</details>

---

<details class="realm-client" id="function-vendoritemstockupdated">
<summary><span class="summary-main"><a id="VendorItemStockUpdated"></a>VendorItemStockUpdated(vendor, itemType, value)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/vendor/module.lua#L448" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="vendoritemstockupdated"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called on the client after a vendor item stock count changes.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Vendor</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/entity/">Entity</a></span> <span class="parameter">vendor</span> The updated vendor.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">itemType</span> The affected item unique ID.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">value</span> The new stock count.</p>
</div>

</div>
</details>

---

<details class="realm-client" id="function-vendormessagesupdated">
<summary><span class="summary-main"><a id="VendorMessagesUpdated"></a>VendorMessagesUpdated(vendor)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/vendor/module.lua#L474" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="vendormessagesupdated"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called on the client after a vendor's message table is synchronized.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Vendor</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/entity/">Entity</a></span> <span class="parameter">vendor</span> The updated vendor.</p>
</div>

</div>
</details>

---

<details class="realm-client" id="function-vendoropened">
<summary><span class="summary-main"><a id="VendorOpened"></a>VendorOpened(vendor)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/vendor/module.lua#L494" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="vendoropened"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called on the client after vendor access opens the vendor UI.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Vendor</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/entity/">Entity</a></span> <span class="parameter">vendor</span> The vendor entity that was opened.</p>
</div>

</div>
</details>

---

<details class="realm-client" id="function-vendorpropertyupdated">
<summary><span class="summary-main"><a id="VendorPropertyUpdated"></a>VendorPropertyUpdated(vendor, propertyName, propertyValue)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/vendor/module.lua#L514" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="vendorpropertyupdated"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called on the client after a synchronized vendor property changes.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Vendor</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/entity/">Entity</a></span> <span class="parameter">vendor</span> The updated vendor.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">propertyName</span> The property key that changed.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">any</a></span> <span class="parameter">propertyValue</span> The synchronized property value.</p>
</div>

</div>
</details>

---

<details class="realm-client" id="function-vendorsynchronized">
<summary><span class="summary-main"><a id="VendorSynchronized"></a>VendorSynchronized(vendor)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/vendor/module.lua#L540" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="vendorsynchronized"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called on the client after a full vendor sync packet is applied.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Vendor</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/entity/">Entity</a></span> <span class="parameter">vendor</span> The vendor that was synchronized.</p>
</div>

</div>
</details>

---

<details class="realm-server" id="function-vendortradeevent">
<summary><span class="summary-main"><a id="VendorTradeEvent"></a>VendorTradeEvent(client, vendor, itemType, isSellingToVendor)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/vendor/module.lua#L560" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="vendortradeevent"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called when the vendor system begins processing a buy or sell transaction.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Vendor</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/player/">Player</a></span> <span class="parameter">client</span> The player trading with the vendor.</p>
<p><span class="types"><a class="type" href="/developer/meta/entity/">Entity</a></span> <span class="parameter">vendor</span> The vendor handling the trade.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">itemType</span> The item unique ID being traded.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">isSellingToVendor</span> Whether the player is selling to the vendor.</p>
</div>

</div>
</details>

---

