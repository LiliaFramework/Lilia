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

# Inventory - Types/Gridinv

This page documents the hooks defined by the types/gridinv submodule in the inventory module.

---

<details class="realm-server" id="function-baginventoryready">
<summary><span class="summary-main"><a id="BagInventoryReady"></a>BagInventoryReady(item, inventory)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/inventory/types/gridinv/module.lua#L1" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="baginventoryready"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called after a bag item finishes creating or restoring its nested inventory.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Inventory - Grid</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">item</span> The bag item that owns the nested inventory.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">inventory</span> The nested bag inventory that is now ready.</p>
</div>

</div>
</details>

---

<details class="realm-server" id="function-baginventoryremoved">
<summary><span class="summary-main"><a id="BagInventoryRemoved"></a>BagInventoryRemoved(item, inventory)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/inventory/types/gridinv/module.lua#L24" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="baginventoryremoved"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called when a bag item's nested inventory is removed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Inventory - Grid</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">item</span> The bag item losing its nested inventory.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">inventory</span> The nested inventory being removed.</p>
</div>

</div>
</details>

---

<details class="realm-client" id="function-interceptclickitemicon">
<summary><span class="summary-main"><a id="InterceptClickItemIcon"></a>InterceptClickItemIcon(panel, itemIcon, keyCode)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/inventory/types/gridinv/module.lua#L47" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="interceptclickitemicon"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Allows clientside code to intercept clicks on a grid inventory item icon before default handling runs.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Inventory - Grid</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/panel/">Panel</a></span> <span class="parameter">panel</span> The grid inventory panel receiving the click.</p>
<p><span class="types"><a class="type" href="/developer/meta/panel/">Panel</a></span> <span class="parameter">itemIcon</span> The clicked item icon panel.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">keyCode</span> The mouse key or button code that was pressed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean|nil</a></span> Return true to indicate the click was fully handled and skip default processing.</p>
</div>

</div>
</details>

---

<details class="realm-client" id="function-inventoryitemiconcreated">
<summary><span class="summary-main"><a id="InventoryItemIconCreated"></a>InventoryItemIconCreated(icon, item, panel)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/inventory/types/gridinv/module.lua#L74" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="inventoryitemiconcreated"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called after a grid inventory item icon panel is created.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Inventory - Grid</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/panel/">Panel</a></span> <span class="parameter">icon</span> The newly created item icon panel.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">item</span> The inventory item represented by the icon.</p>
<p><span class="types"><a class="type" href="/developer/meta/panel/">Panel</a></span> <span class="parameter">panel</span> The parent grid inventory panel.</p>
</div>

</div>
</details>

---

<details class="realm-client" id="function-inventorypanelcreated">
<summary><span class="summary-main"><a id="InventoryPanelCreated"></a>InventoryPanelCreated(panel, inventory, parent)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/inventory/types/gridinv/module.lua#L100" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="inventorypanelcreated"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called after a grid inventory panel is created.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Inventory - Grid</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/panel/">Panel</a></span> <span class="parameter">panel</span> The created inventory panel.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">inventory</span> The inventory assigned to the panel.</p>
<p><span class="types"><a class="type" href="/developer/meta/panel/">Panel</a></span> <span class="parameter">parent</span> <span class="optional">optional</span> The parent panel, if one was provided.</p>
</div>

</div>
</details>

---

<details class="realm-server" id="function-itemcombine">
<summary><span class="summary-main"><a id="ItemCombine"></a>ItemCombine(client, item, target)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/inventory/types/gridinv/module.lua#L126" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="itemcombine"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Allows code to handle combining one item with another before default transfer behavior continues.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Inventory - Grid</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/player/">Player</a></span> <span class="parameter">client</span> The player attempting the combine action.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">item</span> The item being moved or used.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">target</span> The item being combined with.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean|nil</a></span> Return true when the combine action was handled successfully.</p>
</div>

</div>
</details>

---

<details class="realm-server" id="function-onplayerloststackitem">
<summary><span class="summary-main"><a id="OnPlayerLostStackItem"></a>OnPlayerLostStackItem(itemTypeOrItem)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/inventory/types/gridinv/module.lua#L153" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="onplayerloststackitem"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called when the grid inventory stack restore flow fails to recover an item.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Inventory - Grid</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string|table</a></span> <span class="parameter">itemTypeOrItem</span> The item type or item reference that could not be restored.</p>
</div>

</div>
</details>

---

<details class="realm-client" id="function-onrequestitemtransfer">
<summary><span class="summary-main"><a id="OnRequestItemTransfer"></a>OnRequestItemTransfer(panel, itemID, inventoryID, x, y)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/inventory/types/gridinv/module.lua#L173" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="onrequestitemtransfer"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called on the client when a grid inventory panel requests an item transfer.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Inventory - Grid</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/panel/">Panel</a></span> <span class="parameter">panel</span> The panel that initiated the transfer request.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">itemID</span> The item ID being transferred.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">inventoryID</span> <span class="optional">optional</span> The target inventory ID, if applicable.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">x</span> The requested destination X slot.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">y</span> The requested destination Y slot.</p>
</div>

</div>
</details>

---

<details class="realm-server" id="function-setupbaginventoryaccessrules">
<summary><span class="summary-main"><a id="SetupBagInventoryAccessRules"></a>SetupBagInventoryAccessRules(inventory)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/inventory/types/gridinv/module.lua#L205" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="setupbaginventoryaccessrules"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Allows code to configure access rules on a newly created bag inventory.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Inventory - Grid</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">inventory</span> The bag inventory being initialized.</p>
</div>

</div>
</details>

---

