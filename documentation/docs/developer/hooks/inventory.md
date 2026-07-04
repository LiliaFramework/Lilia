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

This page documents hooks in the inventory category.

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
  <p>Inventory</p>
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

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("BagInventoryReady", "liaExampleBagInventoryReady", function(item, inventory)
      print("[MyModule] handled BagInventoryReady")
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-baginventoryremoved">
<summary><span class="summary-main"><a id="BagInventoryRemoved"></a>BagInventoryRemoved(item, inventory)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/inventory/types/gridinv/module.lua#L31" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="baginventoryremoved"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called when a bag item's nested inventory is removed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Inventory</p>
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

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("BagInventoryRemoved", "liaExampleBagInventoryRemoved", function(item, inventory)
      print("[MyModule] handled BagInventoryRemoved")
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-canplayerspawnstorage">
<summary><span class="summary-main"><a id="CanPlayerSpawnStorage"></a>CanPlayerSpawnStorage(client, entity, info)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/inventory/types/gridinv/submodules/storage/module.lua#L1" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="canplayerspawnstorage"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Determines whether a player may convert an entity into storage.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Inventory</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/player/">Player</a></span> <span class="parameter">client</span> The player trying to create the storage entity.</p>
<p><span class="types"><a class="type" href="/developer/meta/entity/">Entity</a></span> <span class="parameter">entity</span> The target entity being turned into storage.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">info</span> The requested storage configuration data.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean|nil</a></span> Return false to block storage creation.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("CanPlayerSpawnStorage", "liaExampleCanPlayerSpawnStorage", function(client, entity, info)
      if IsValid(client) and client:IsAdmin() then
          return true
      end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-cansavedata">
<summary><span class="summary-main"><a id="CanSaveData"></a>CanSaveData(ent, inventory)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/inventory/types/gridinv/submodules/storage/module.lua#L37" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="cansavedata"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Determines whether a storage entity's inventory data should be persisted.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Inventory</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/entity/">Entity</a></span> <span class="parameter">ent</span> The storage entity being saved.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">inventory</span> The inventory attached to the storage entity.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean|nil</a></span> Return false to skip saving this storage inventory.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("CanSaveData", "liaExampleCanSaveData", function(ent, inventory)
      return true
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-getinventorymaxweight">
<summary><span class="summary-main"><a id="GetInventoryMaxWeight"></a>GetInventoryMaxWeight(inventory, maxWeight)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/inventory/types/weightinv/module.lua#L1" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="getinventorymaxweight"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Allows code to override the computed maximum carry weight for a weight inventory.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Inventory</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">inventory</span> The inventory whose maximum weight is being calculated.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">maxWeight</span> The default maximum weight before overrides are applied.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number|nil</a></span> Return a replacement max weight to override the default value.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("GetInventoryMaxWeight", "liaExampleGetInventoryMaxWeight", function(inventory, maxWeight)
      return (maxWeight or 0) + 5
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-initializestorage">
<summary><span class="summary-main"><a id="InitializeStorage"></a>InitializeStorage(entity)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/inventory/types/gridinv/submodules/storage/module.lua#L68" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="initializestorage"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called when the storage system initializes a storage-capable entity.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Inventory</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/entity/">Entity</a></span> <span class="parameter">entity</span> The storage entity being initialized.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("InitializeStorage", "liaExampleInitializeStorage", function(entity)
      print("[MyModule] handled InitializeStorage")
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-interceptclickitemicon">
<summary><span class="summary-main"><a id="InterceptClickItemIcon"></a>InterceptClickItemIcon(panel, itemIcon, keyCode)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/inventory/types/gridinv/module.lua#L61" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="interceptclickitemicon"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Allows clientside code to intercept clicks on a grid inventory item icon before default handling runs.</p>
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
<p><span class="types"><a class="type" href="/developer/meta/panel/">Panel</a></span> <span class="parameter">panel</span> The grid inventory panel receiving the click.</p>
<p><span class="types"><a class="type" href="/developer/meta/panel/">Panel</a></span> <span class="parameter">itemIcon</span> The clicked item icon panel.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">keyCode</span> The mouse key or button code that was pressed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean|nil</a></span> Return true to indicate the click was fully handled and skip default processing.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("InterceptClickItemIcon", "liaExampleInterceptClickItemIcon", function(panel, itemIcon, keyCode)
      return true
  end)
</code></pre>
</div>

</div>
</details>

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

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("InventoryClosed", "liaExampleInventoryClosed", function(panel, inventory)
      if not IsValid(panel) then return end
      panel:SetTooltip("InventoryClosed handled by MyModule")
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-inventoryitemiconcreated">
<summary><span class="summary-main"><a id="InventoryItemIconCreated"></a>InventoryItemIconCreated(icon, item, panel)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/inventory/types/gridinv/module.lua#L95" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="inventoryitemiconcreated"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called after a grid inventory item icon panel is created.</p>
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
<p><span class="types"><a class="type" href="/developer/meta/panel/">Panel</a></span> <span class="parameter">icon</span> The newly created item icon panel.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">item</span> The inventory item represented by the icon.</p>
<p><span class="types"><a class="type" href="/developer/meta/panel/">Panel</a></span> <span class="parameter">panel</span> The parent grid inventory panel.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("InventoryItemIconCreated", "liaExampleInventoryItemIconCreated", function(icon, item, panel)
      if not IsValid(panel) then return end
      panel:SetTooltip("InventoryItemIconCreated handled by MyModule")
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-inventoryopened">
<summary><span class="summary-main"><a id="InventoryOpened"></a>InventoryOpened(panel, inventory)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/inventory/module.lua#L32" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
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

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("InventoryOpened", "liaExampleInventoryOpened", function(panel, inventory)
      if not IsValid(panel) then return end
      panel:SetTooltip("InventoryOpened handled by MyModule")
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-inventorypanelcreated">
<summary><span class="summary-main"><a id="InventoryPanelCreated"></a>InventoryPanelCreated(panel, inventory, parent)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/inventory/types/gridinv/module.lua#L129" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="inventorypanelcreated"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called after a grid inventory panel is created.</p>
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
<p><span class="types"><a class="type" href="/developer/meta/panel/">Panel</a></span> <span class="parameter">panel</span> The created inventory panel.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">inventory</span> The inventory assigned to the panel.</p>
<p><span class="types"><a class="type" href="/developer/meta/panel/">Panel</a></span> <span class="parameter">parent</span> <span class="optional">optional</span> The parent panel, if one was provided.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("InventoryPanelCreated", "liaExampleInventoryPanelCreated", function(panel, inventory, parent)
      if not IsValid(panel) then return end
      panel:SetTooltip("InventoryPanelCreated handled by MyModule")
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-itemcombine">
<summary><span class="summary-main"><a id="ItemCombine"></a>ItemCombine(client, item, target)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/inventory/types/gridinv/module.lua#L163" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="itemcombine"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Allows code to handle combining one item with another before default transfer behavior continues.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Inventory</p>
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

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("ItemCombine", "liaExampleItemCombine", function(client, item, target)
      if IsValid(client) and client:IsAdmin() then
          return true
      end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-oncreatedualinventorypanels">
<summary><span class="summary-main"><a id="OnCreateDualInventoryPanels"></a>OnCreateDualInventoryPanels(panel1, panel2, inventory1, inventory2)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/inventory/module.lua#L63" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
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

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnCreateDualInventoryPanels", "liaExampleOnCreateDualInventoryPanels", function(panel1, panel2, inventory1, inventory2)
      print("[MyModule] handled OnCreateDualInventoryPanels")
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-oncreatestoragepanel">
<summary><span class="summary-main"><a id="OnCreateStoragePanel"></a>OnCreateStoragePanel(localInvPanel, storageInvPanel, storage)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/inventory/types/gridinv/submodules/storage/module.lua#L95" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="oncreatestoragepanel"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called after the client creates the paired inventory panels for a storage UI.</p>
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
<p><span class="types"><a class="type" href="/developer/meta/panel/">Panel</a></span> <span class="parameter">localInvPanel</span> The local player's inventory panel.</p>
<p><span class="types"><a class="type" href="/developer/meta/panel/">Panel</a></span> <span class="parameter">storageInvPanel</span> The storage inventory panel.</p>
<p><span class="types"><a class="type" href="/developer/meta/entity/">Entity</a></span> <span class="parameter">storage</span> The storage entity being viewed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnCreateStoragePanel", "liaExampleOnCreateStoragePanel", function(localInvPanel, storageInvPanel, storage)
      print("[MyModule] handled OnCreateStoragePanel")
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-onplayerloststackitem">
<summary><span class="summary-main"><a id="OnPlayerLostStackItem"></a>OnPlayerLostStackItem(itemTypeOrItem)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/inventory/types/gridinv/module.lua#L199" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="onplayerloststackitem"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called when the grid inventory stack restore flow fails to recover an item.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Inventory</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string|table</a></span> <span class="parameter">itemTypeOrItem</span> The item type or item reference that could not be restored.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnPlayerLostStackItem", "liaExampleOnPlayerLostStackItem", function(itemTypeOrItem)
      print("[MyModule] handled OnPlayerLostStackItem")
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-onrequestitemtransfer">
<summary><span class="summary-main"><a id="OnRequestItemTransfer"></a>OnRequestItemTransfer(panel, itemID, inventoryID, x, y)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/inventory/types/gridinv/module.lua#L226" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="onrequestitemtransfer"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called on the client when a grid inventory panel requests an item transfer.</p>
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
<p><span class="types"><a class="type" href="/developer/meta/panel/">Panel</a></span> <span class="parameter">panel</span> The panel that initiated the transfer request.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">itemID</span> The item ID being transferred.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">inventoryID</span> <span class="optional">optional</span> The target inventory ID, if applicable.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">x</span> The requested destination X slot.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">y</span> The requested destination Y slot.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnRequestItemTransfer", "liaExampleOnRequestItemTransfer", function(panel, itemID, inventoryID, x, y)
      if not IsValid(panel) then return end
      panel:SetTooltip("OnRequestItemTransfer handled by MyModule")
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-setupbaginventoryaccessrules">
<summary><span class="summary-main"><a id="SetupBagInventoryAccessRules"></a>SetupBagInventoryAccessRules(inventory)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/inventory/types/gridinv/module.lua#L266" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="setupbaginventoryaccessrules"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Allows code to configure access rules on a newly created bag inventory.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Inventory</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">inventory</span> The bag inventory being initialized.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("SetupBagInventoryAccessRules", "liaExampleSetupBagInventoryAccessRules", function(inventory)
      print("[MyModule] handled SetupBagInventoryAccessRules")
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-storagecantransferitem">
<summary><span class="summary-main"><a id="StorageCanTransferItem"></a>StorageCanTransferItem(client, storage, item)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/inventory/types/gridinv/submodules/storage/module.lua#L128" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="storagecantransferitem"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Determines whether a player may transfer a specific item through a storage interaction.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Inventory</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/player/">Player</a></span> <span class="parameter">client</span> The player attempting the transfer.</p>
<p><span class="types"><a class="type" href="/developer/meta/entity/">Entity</a></span> <span class="parameter">storage</span> The storage entity involved in the transfer.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">item</span> The item being moved.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean|nil</a></span> Return false to block the item transfer.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("StorageCanTransferItem", "liaExampleStorageCanTransferItem", function(client, storage, item)
      if IsValid(client) and client:IsAdmin() then
          return true
      end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-storageentityremoved">
<summary><span class="summary-main"><a id="StorageEntityRemoved"></a>StorageEntityRemoved(entity, inventory)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/inventory/types/gridinv/submodules/storage/module.lua#L164" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="storageentityremoved"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called when a storage entity is removed and its attached inventory is being cleaned up.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Inventory</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/entity/">Entity</a></span> <span class="parameter">entity</span> The storage entity being removed.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">inventory</span> The inventory attached to the entity.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("StorageEntityRemoved", "liaExampleStorageEntityRemoved", function(entity, inventory)
      print("[MyModule] handled StorageEntityRemoved")
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-storageinventoryset">
<summary><span class="summary-main"><a id="StorageInventorySet"></a>StorageInventorySet(entity, inventory, isCar)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/inventory/types/gridinv/submodules/storage/module.lua#L194" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="storageinventoryset"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called after a storage entity is assigned an inventory.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Inventory</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/entity/">Entity</a></span> <span class="parameter">entity</span> The storage entity receiving the inventory.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">inventory</span> The inventory assigned to the entity.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">isCar</span> Whether the storage entity is a vehicle trunk.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("StorageInventorySet", "liaExampleStorageInventorySet", function(entity, inventory, isCar)
      print("[MyModule] handled StorageInventorySet")
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-storagerestored">
<summary><span class="summary-main"><a id="StorageRestored"></a>StorageRestored(ent, inventory)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/inventory/types/gridinv/submodules/storage/module.lua#L227" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="storagerestored"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called after persisted storage data is restored onto an entity.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Inventory</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/entity/">Entity</a></span> <span class="parameter">ent</span> The storage entity that was restored.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">inventory</span> The restored inventory.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("StorageRestored", "liaExampleStorageRestored", function(ent, inventory)
      print("[MyModule] handled StorageRestored")
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-storageunlockprompt">
<summary><span class="summary-main"><a id="StorageUnlockPrompt"></a>StorageUnlockPrompt(entity)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/inventory/types/gridinv/submodules/storage/module.lua#L257" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="storageunlockprompt"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called on the client when a storage unlock prompt should be shown.</p>
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
<p><span class="types"><a class="type" href="/developer/meta/entity/">Entity</a></span> <span class="parameter">entity</span> The locked storage entity requesting unlock input.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("StorageUnlockPrompt", "liaExampleStorageUnlockPrompt", function(entity)
      print("[MyModule] handled StorageUnlockPrompt")
  end)
</code></pre>
</div>

</div>
</details>

---

