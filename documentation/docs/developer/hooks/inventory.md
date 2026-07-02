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

# Inventory

This page documents the hooks defined by the inventory module.

---

<details class="realm-client" id="function-inventoryclosed">
<summary><span class="summary-main"><a id="InventoryClosed"></a>InventoryClosed(panel, inventory)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/inventory/module.lua#L1" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="inventoryclosed"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called after an inventory panel is closed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Inventory</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/panel/">Panel</a></span> <span class="parameter">panel</span> The panel instance that was closed.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">inventory</span> The inventory represented by the panel.</p>
</div>

</div>
</details>

---

<details class="realm-client" id="function-inventoryopened">
<summary><span class="summary-main"><a id="InventoryOpened"></a>InventoryOpened(panel, inventory)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/inventory/module.lua#L24" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="inventoryopened"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called after an inventory panel is created and shown.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Inventory</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/panel/">Panel</a></span> <span class="parameter">panel</span> The panel instance that was opened.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">inventory</span> The inventory represented by the panel.</p>
</div>

</div>
</details>

---

<details class="realm-client" id="function-oncreatedualinventorypanels">
<summary><span class="summary-main"><a id="OnCreateDualInventoryPanels"></a>OnCreateDualInventoryPanels(panel1, panel2, inventory1, inventory2)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/inventory/module.lua#L47" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="oncreatedualinventorypanels"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called after the framework creates a paired inventory view for two inventories.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Inventory</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/panel/">Panel</a></span> <span class="parameter">panel1</span> The panel for the first inventory.</p>
<p><span class="types"><a class="type" href="/developer/meta/panel/">Panel</a></span> <span class="parameter">panel2</span> The panel for the second inventory.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">inventory1</span> The first inventory object.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">inventory2</span> The second inventory object.</p>
</div>

</div>
</details>

---

