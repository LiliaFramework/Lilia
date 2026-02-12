# Vendor

NPC vendor management system with editing and rarity support for the Lilia framework.

---

<h3 style="margin-bottom: 5px;">Overview</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
The vendor library provides comprehensive functionality for managing NPC vendors in the Lilia framework. It handles vendor configuration, editing, presets, and rarity systems for items sold by vendors. The library operates on both server and client sides, with the server handling vendor data processing and the client managing the editing interface. It includes support for vendor presets, item rarities, stock management, pricing, faction/class restrictions, and visual customization. The library ensures that vendors can be easily configured and managed through both code and in-game editing tools.
</div>

---

<details class="realm-shared" id="function-liavendoraddpreset">
<summary><a id="lia.vendor.addPreset"></a>lia.vendor.addPreset(name, items)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liavendoraddpreset"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Register a reusable vendor item preset with validated entries.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>During initialization to define canned loadouts for vendors (e.g., weapon dealer, medic).</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">name</span> Unique preset name.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">items</span> Map of item uniqueIDs to tables with pricing/stock metadata.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  -- Define a preset and apply it dynamically based on map location.
  lia.vendor.addPreset("gunsmith", {
      ar15 = {stock = 3, price = 3500},
      akm = {stock = 2, price = 3200},
      ["9mm"] = {stock = 50, price = 30}
  })
  hook.Add("OnVendorSpawned", "SetupMapVendors", function(vendorEnt)
      if vendorEnt:GetClass() ~= "lia_vendor" then return end
      local zone = lia.zones and lia.zones.getNameAtPos(vendorEnt:GetPos()) or "default"
      if zone == "Armory" then
          vendorEnt:applyPreset("gunsmith")
          vendorEnt:setFactionAllowed(FACTION_POLICE, true)
      end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liavendorgetpreset">
<summary><a id="lia.vendor.getPreset"></a>lia.vendor.getPreset(name)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liavendorgetpreset"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Retrieve a preset definition by name.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>While applying presets to vendors or inspecting available vendor templates.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">name</span> Preset identifier (case-insensitive).</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table|nil</a></span> Item definition table if present.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  -- Clone and tweak a preset before applying to a specific vendor.
  local preset = table.Copy(lia.vendor.getPreset("gunsmith") or {})
  if preset then
      preset["9mm"].price = 25
      preset["akm"] = nil -- remove AKM for this vendor
      vendor:applyPreset("gunsmith") -- base preset
      for item, data in pairs(preset) do
          vendor:setItemPrice(item, data.price)
          if data.stock then vendor:setMaxStock(item, data.stock) end
      end
  end
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liavendorgetvendorproperty">
<summary><a id="lia.vendor.getVendorProperty"></a>lia.vendor.getVendorProperty(entity, property)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liavendorgetvendorproperty"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Fetch a vendor property from cache with default fallback.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Anywhere vendor state is read (pricing, stock, model, etc.).</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">entity</span> Vendor NPC entity.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">property</span> Property key from `lia.vendor.defaults`.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">any</a></span> Cached property value or default.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  -- Build a UI row with live vendor state (including defaults).
  local function addVendorRow(list, vendorEnt)
      local name = lia.vendor.getVendorProperty(vendorEnt, "name")
      local cash = lia.vendor.getVendorProperty(vendorEnt, "money") or 0
      local items = lia.vendor.getVendorProperty(vendorEnt, "items")
      list:AddLine(name, cash, table.Count(items or {}))
  end
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liavendorsetvendorproperty">
<summary><a id="lia.vendor.setVendorProperty"></a>lia.vendor.setVendorProperty(entity, property, value)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liavendorsetvendorproperty"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Mutate a vendor property, pruning defaults to keep network/state lean.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>During vendor edits (net messages) or when scripting dynamic vendor behavior.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">entity</span> Vendor NPC entity.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">property</span> Key to update.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">any</a></span> <span class="parameter">value</span> New value to store; default-equivalent values clear the entry.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  -- Dynamically flip vendor inventory for an event and prune defaults.
  hook.Add("EventStarted", "StockEventVendors", function()
      for _, vendorEnt in ipairs(ents.FindByClass("lia_vendor")) do
          lia.vendor.setVendorProperty(vendorEnt, "items", {
              ["event_ticket"] = {stock = 100, price = 0},
              ["rare_crate"] = {stock = 5, price = 7500}
          })
      end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liavendorsyncvendorproperty">
<summary><a id="lia.vendor.syncVendorProperty"></a>lia.vendor.syncVendorProperty(entity, property, value, isDefault)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liavendorsyncvendorproperty"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Broadcast a vendor property update to all clients.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server-side after mutating vendor properties to keep clients in sync.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">entity</span> Vendor NPC entity.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">property</span> Key being synchronized.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">any</a></span> <span class="parameter">value</span> New value for the property.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">isDefault</span> Whether the property should be cleared (uses defaults clientside).</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  -- Force sync after a server-side rebuild of vendor data.
  local function rebuildVendor(vendorEnt)
      lia.vendor.setVendorProperty(vendorEnt, "name", "Quartermaster")
      lia.vendor.setVendorProperty(vendorEnt, "factionSellScales", { [FACTION_POLICE] = 0.8 })
      lia.vendor.syncVendorProperty(vendorEnt, "name", "Quartermaster", false)
      lia.vendor.syncVendorProperty(vendorEnt, "factionSellScales", { [FACTION_POLICE] = 0.8 }, false)
  end
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liavendorgetallvendordata">
<summary><a id="lia.vendor.getAllVendorData"></a>lia.vendor.getAllVendorData(entity)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liavendorgetallvendordata"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Build a full vendor state table with defaults applied.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Before serializing vendor data for saving or sending to clients.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">entity</span> Vendor NPC entity.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> Key-value table covering every defaulted vendor property.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  -- Serialize full vendor state for a persistence layer.
  net.Receive("RequestVendorSnapshot", function(_, ply)
      local ent = net.ReadEntity()
      local data = lia.vendor.getAllVendorData(ent)
      if not data then return end
      lia.data.set("vendor_" .. ent:EntIndex(), data)
      net.Start("SendVendorSnapshot")
      net.WriteTable(data)
      net.Send(ply)
  end)
</code></pre>
</div>

</div>
</details>

---

