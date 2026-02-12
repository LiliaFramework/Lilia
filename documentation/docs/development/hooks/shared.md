# Shared

This page documents the functions and methods in the meta table.

---

<h3 style="margin-bottom: 5px;">Overview</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
Shared hooks in the Lilia framework handle functionality available on both client and server, typically for data synchronization, shared utilities, and cross-realm features. They follow the Garry's Mod hook system and can be overridden or extended by addons and modules.
</div>

---

<details class="realm-shared" id="function-adjustcreationdata">
<summary><a id="AdjustCreationData"></a>AdjustCreationData(client, data, newData, originalData)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="adjustcreationdata"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Let schemas modify validated character creation data before it is saved.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After creation data is sanitized and validated in `liaCharCreate`, before the final table is merged and written.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player creating the character.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">data</span> Sanitized values for registered character variables.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">newData</span> Table you can populate with overrides that will be merged into `data`.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">originalData</span> Copy of the raw client payload prior to sanitation.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("AdjustCreationData", "ForcePrefix", function(client, data, newData)
      if data.faction == FACTION_STAFF then newData.name = "[STAFF] " .. (newData.name or data.name) end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-adjustpacpartdata">
<summary><a id="AdjustPACPartData"></a>AdjustPACPartData(wearer, id, data)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="adjustpacpartdata"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Allow items or modules to tweak PAC3 part data before it is attached.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client-side when PAC3 builds part data for an outfit id before `AttachPart` runs.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">wearer</span> Entity that will wear the PAC part.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">id</span> Unique part identifier, usually an item uniqueID.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">data</span> PAC3 data table that can be edited.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table|nil</a></span> Return a replacement data table, or nil to keep the modified `data`.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("AdjustPACPartData", "TintPoliceVisors", function(wearer, id, data)
      if wearer:Team() == FACTION_POLICE and data.Material then data.Material = "models/shiny" end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-adjuststaminaoffset">
<summary><a id="AdjustStaminaOffset"></a>AdjustStaminaOffset(client, offset)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="adjuststaminaoffset"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Change the stamina delta applied on a tick.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Each stamina update before the offset is clamped and written to the player.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player whose stamina is being processed.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">offset</span> Positive regen or negative drain calculated from movement.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number|nil</a></span> Override for the stamina offset; nil keeps the existing value.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("AdjustStaminaOffset", "HeavyArmorTax", function(client, offset)
      if client:GetNWBool("HeavyArmor") then return offset - 1 end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-advdupe_finishpasting">
<summary><a id="AdvDupe_FinishPasting"></a>AdvDupe_FinishPasting(tbl)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="advdupe_finishpasting"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>React when an Advanced Dupe 2 paste finishes under BetterDupe.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After AdvDupe2 completes the paste queue so compatibility state can be reset.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">tbl</span> Paste context provided by AdvDupe2 (first entry is the player).</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("AdvDupe_FinishPasting", "ClearTempState", function(info)
      local ply = info[1] and info[1].Player
      if IsValid(ply) then ply.tempBetterDupe = nil end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-attachpart">
<summary><a id="AttachPart"></a>AttachPart(client, id)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="attachpart"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Notify when a PAC3 part is attached to a player.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client-side after PAC3 part data is retrieved and before it is tracked locally.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player receiving the PAC part.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">id</span> Identifier of the part or outfit.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("AttachPart", "TrackPACAttachment", function(client, id)
      lia.log.add(client, "pacAttach", id)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-baginventoryready">
<summary><a id="BagInventoryReady"></a>BagInventoryReady(bagItem, inventory)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="baginventoryready"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Respond when a bag item finishes creating or loading its child inventory.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After a bag instance allocates an inventory (on instancing or restore) and access rules are applied.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/libraries/item/">Item</a></span> <span class="parameter">bagItem</span> The bag item that owns the inventory.</p>
<p><span class="types"><a class="type" href="/development/libraries/inventory/">Inventory</a></span> <span class="parameter">inventory</span> Child inventory created for the bag.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("BagInventoryReady", "AutoLabelBag", function(bagItem, inventory)
      inventory:setData("bagName", bagItem:getName())
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-baginventoryremoved">
<summary><a id="BagInventoryRemoved"></a>BagInventoryRemoved(bagItem, inventory)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="baginventoryremoved"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>React when a bag's inventory is being removed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Before a bag item deletes its child inventory (e.g., on item removal).</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/libraries/item/">Item</a></span> <span class="parameter">bagItem</span> Bag being removed.</p>
<p><span class="types"><a class="type" href="/development/libraries/inventory/">Inventory</a></span> <span class="parameter">inventory</span> Child inventory scheduled for deletion.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("BagInventoryRemoved", "DropBagContents", function(bagItem, inv)
      for _, item in pairs(inv:getItems()) do item:transfer(nil, nil, nil, nil, true) end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-calcstaminachange">
<summary><a id="CalcStaminaChange"></a>CalcStaminaChange(client)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="calcstaminachange"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Calculate the stamina change for a player on a tick.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>From the stamina timer in the attributes module every 0.25s and on client prediction.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player being processed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> Positive regen or negative drain applied to the player's stamina pool.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  function MODULE:CalcStaminaChange(client)
      local offset = self.BaseClass.CalcStaminaChange(self, client)
      if client:IsAdmin() then offset = offset + 1 end
      return offset
  end
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-calcstaminachange">
<summary><a id="CalcStaminaChange"></a>CalcStaminaChange(client)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="calcstaminachange"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Calculate the stamina change for a player on a tick.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>From the stamina timer in the attributes module every 0.25s and on client prediction.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player being processed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> Positive regen or negative drain applied to the player's stamina pool.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  function MODULE:CalcStaminaChange(client)
      local offset = self.BaseClass.CalcStaminaChange(self, client)
      if client:IsAdmin() then offset = offset + 1 end
      return offset
  end
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-cancharbetransfered">
<summary><a id="CanCharBeTransfered"></a>CanCharBeTransfered(tChar, faction, arg3)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="cancharbetransfered"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Decide whether a character can be transferred to a new faction or class.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Before character transfer commands/classes move a character to another faction/class.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/libraries/char/">Character</a></span> <span class="parameter">tChar</span> Character being transferred.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number|string</a></span> <span class="parameter">faction</span> Target faction or class identifier.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number|string</a></span> <span class="parameter">arg3</span> Current faction or class being left.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p>boolean, string|nil Return false and an optional reason to block the transfer.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("CanCharBeTransfered", "PreventDuplicateFaction", function(char, factionID)
      if lia.faction.indices[factionID] and lia.faction.indices[factionID].oneCharOnly then
          for _, other in pairs(lia.char.getAll()) do
              if other.steamID == char.steamID and other:getFaction() == factionID then
                  return false, L("charAlreadyInFaction")
              end
          end
      end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-caninvitetoclass">
<summary><a id="CanInviteToClass"></a>CanInviteToClass(client, target)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="caninvitetoclass"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Control whether a player can invite another player into a class.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Before sending a class invite through the team management menu.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player issuing the invite.</p>
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">target</span> Player being invited.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p>boolean, string|nil Return false (optionally with reason) to block the invite.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("CanInviteToClass", "RestrictByRank", function(client, target)
      if not client:IsAdmin() then return false, L("insufficientPermissions") end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-caninvitetofaction">
<summary><a id="CanInviteToFaction"></a>CanInviteToFaction(client, target)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="caninvitetofaction"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Control whether a player can invite another player into their faction.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When a player tries to invite someone to join their faction in the team menu.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player issuing the invite.</p>
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">target</span> Player being invited.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p>boolean, string|nil Return false to deny the invitation with an optional message.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("CanInviteToFaction", "BlockFullFaction", function(client, target)
      local faction = lia.faction.indices[client:Team()]
      if faction and faction.memberLimit and faction.memberLimit &lt;= faction:countMembers() then
          return false, L("limitFaction")
      end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-canoutfitchangemodel">
<summary><a id="CanOutfitChangeModel"></a>CanOutfitChangeModel(item)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="canoutfitchangemodel"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Decide whether an outfit item is allowed to change a player's model.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Before an outfit applies its model change during equip or removal.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/libraries/item/">Item</a></span> <span class="parameter">item</span> Outfit attempting to change the player's model.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> Return false to prevent the outfit from changing the model.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("CanOutfitChangeModel", "RestrictModelSwap", function(item)
      return not item.player:getNetVar("NoModelChange", false)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-canperformvendoredit">
<summary><a id="CanPerformVendorEdit"></a>CanPerformVendorEdit(client, vendor)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="canperformvendoredit"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Determine if a player can edit a vendor's configuration.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When opening the vendor editor or applying vendor changes through the UI.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player attempting to edit.</p>
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">vendor</span> Vendor entity being edited.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p>boolean, string|nil Return false to block edits with an optional reason.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("CanPerformVendorEdit", "AdminOnlyVendors", function(client, vendor)
      if not client:IsAdmin() then return false, L("insufficientPermissions") end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-canpickupmoney">
<summary><a id="CanPickupMoney"></a>CanPickupMoney(activator, moneyEntity)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="canpickupmoney"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Allow or prevent a player from picking up a money entity.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When a player uses a `lia_money` entity to collect currency.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">activator</span> Entity attempting to pick up the money (usually a Player).</p>
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">moneyEntity</span> Money entity being collected.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p>boolean, string|nil Return false to block pickup with an optional message.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("CanPickupMoney", "RespectWantedStatus", function(client, money)
      if client:getNetVar("isWanted") then return false, L("cannotPickupWhileWanted") end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-canplayerchooseweapon">
<summary><a id="CanPlayerChooseWeapon"></a>CanPlayerChooseWeapon(weapon)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="canplayerchooseweapon"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Filter which weapons appear as selectable in the weapon selector.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When building the client weapon selection UI before allowing a weapon choice.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Weapon">Weapon</a></span> <span class="parameter">weapon</span> Weapon entity being considered.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> Return false to hide or block selection of the weapon.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("CanPlayerChooseWeapon", "HideUnsafeWeapons", function(weapon)
      if weapon:GetClass():find("admin") then return false end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-canplayercreatechar">
<summary><a id="CanPlayerCreateChar"></a>CanPlayerCreateChar(client, data)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="canplayercreatechar"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Allow schemas to veto or validate a character creation attempt.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>On the server when a player submits the creation form and before processing begins.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player creating the character.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">data</span> Raw creation data received from the client.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p>boolean, string|nil Return false and an optional message to deny creation.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("CanPlayerCreateChar", "LimitByPlaytime", function(client)
      if not client:playTimeGreaterThan(3600) then return false, L("needMorePlaytime") end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-canplayerjoinclass">
<summary><a id="CanPlayerJoinClass"></a>CanPlayerJoinClass(client, class, info)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="canplayerjoinclass"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Decide if a player may join a given class.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Before assigning a class in the class library and character selection.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player requesting the class.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">class</span> Target class index.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">info</span> Class data table for convenience.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p>boolean, string|nil Return false to block the class switch with an optional reason.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("CanPlayerJoinClass", "WhitelistCheck", function(client, class, info)
      if info.requiresWhitelist and not client:getChar():getClasswhitelists()[class] then
          return false, L("noWhitelist")
      end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-canplayerknock">
<summary><a id="CanPlayerKnock"></a>CanPlayerKnock(arg1, arg2)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="canplayerknock"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Control whether a player can knock on a door with their hands.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When the hands SWEP secondary attack is used on a door entity.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">arg1</span> Player attempting to knock.</p>
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">arg2</span> Door entity being knocked on.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> Return false to prevent the knock action.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("CanPlayerKnock", "BlockPoliceDoors", function(client, door)
      if door.isPoliceDoor then return false end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-canplayermodifyconfig">
<summary><a id="CanPlayerModifyConfig"></a>CanPlayerModifyConfig(client, key)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="canplayermodifyconfig"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Gate whether a player can change a configuration variable.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client- and server-side when a config edit is attempted through the admin tools or config UI.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player attempting the change.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">key</span> Config key being modified.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p>boolean, string|nil Return false to deny the modification with an optional message.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("CanPlayerModifyConfig", "SuperAdminOnly", function(client)
      if not client:IsSuperAdmin() then return false, L("insufficientPermissions") end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-canplayerrotateitem">
<summary><a id="CanPlayerRotateItem"></a>CanPlayerRotateItem(client, item)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="canplayerrotateitem"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Determine if a player may rotate an item in an inventory grid.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When handling the client drag/drop rotate action for an item slot.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player requesting the rotation.</p>
<p><span class="types"><a class="type" href="/development/libraries/item/">Item</a></span> <span class="parameter">item</span> Item instance being rotated.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p>boolean, string|nil Return false to block rotation with an optional error message.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("CanPlayerRotateItem", "LockQuestItems", function(client, item)
      if item:getData("questLocked") then return false, L("itemLocked") end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-canplayerthrowpunch">
<summary><a id="CanPlayerThrowPunch"></a>CanPlayerThrowPunch(client)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="canplayerthrowpunch"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Gate whether a player is allowed to throw a punch.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Before the hands SWEP starts a punch, after playtime and stamina checks.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player attempting to punch.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean|string|nil</a></span> Return false to stop the punch; optionally return a reason string.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("CanPlayerThrowPunch", "DisallowTiedPlayers", function(client)
      if client:getNetVar("tied") then return false, L("cannotWhileTied") end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-canplayerusecommand">
<summary><a id="CanPlayerUseCommand"></a>CanPlayerUseCommand(client, command)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="canplayerusecommand"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Decide if a player can execute a specific console/chat command.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Each time a command is run through the command library before execution.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player running the command.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">command</span> Command definition table.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p>boolean, string|nil Return false to block the command with an optional reason.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("CanPlayerUseCommand", "RestrictNonStaff", function(client, command)
      if command.adminOnly and not client:IsAdmin() then return false, L("insufficientPermissions") end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-canrunitemaction">
<summary><a id="CanRunItemAction"></a>CanRunItemAction(tempItem, key)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="canrunitemaction"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Control whether an item action should be available.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>While building item action menus both client-side (UI) and server-side (validation).</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/libraries/item/">Item</a></span> <span class="parameter">tempItem</span> Item being acted on.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">key</span> Action identifier (e.g., "equip", "drop").</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> Return false to hide or block the action.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("CanRunItemAction", "NoDropQuestItems", function(item, action)
      if action == "drop" and item:getData("questLocked") then return false end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-charforcerecognized">
<summary><a id="CharForceRecognized"></a>CharForceRecognized(ply, range)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="charforcerecognized"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Force a character to recognize others within a range.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When the recognition module sets recognition for every character around a player.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">ply</span> Player whose character will recognize others.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string|number</a></span> <span class="parameter">range</span> Range preset ("whisper", "normal", "yell") or numeric distance.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("CharForceRecognized", "AlwaysRecognizeStaff", function(ply)
      if ply:IsAdmin() then ply:getChar():giveAllRecognition() end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-charhasflags">
<summary><a id="CharHasFlags"></a>CharHasFlags(client, flags)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="charhasflags"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Override how character flag checks are evaluated.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Whenever `playerMeta:hasFlags` is queried to determine character permissions.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player whose character is being checked.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">flags</span> Flag string to test.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> Return true to force pass, false to force fail, or nil to defer to default logic.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("CharHasFlags", "HonorVIP", function(client, flags)
      if client:IsUserGroup("vip") and flags:find("V") then return true end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-chatparsed">
<summary><a id="ChatParsed"></a>ChatParsed(client, chatType, message, anonymous)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="chatparsed"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Modify chat metadata before it is dispatched.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After chat parsing but before the chat type and message are sent to recipients.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Speaker.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">chatType</span> Parsed chat command (ic, ooc, etc.).</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">message</span> Original chat text.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">anonymous</span> Whether the message is anonymous.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p>string, string, boolean|nil Optionally return a replacement chatType, message, and anonymous flag.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("ChatParsed", "AddOOCPrefix", function(client, chatType, message, anonymous)
      if chatType == "ooc" then return chatType, "[GLOBAL] " .. message, anonymous end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-commandadded">
<summary><a id="CommandAdded"></a>CommandAdded(command, data)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="commandadded"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>React when a new chat/console command is registered.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Immediately after a command is added to the command library.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">command</span> Command identifier.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">data</span> Command definition table.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("CommandAdded", "LogCommands", function(name, data)
      print("Command registered:", name, "adminOnly:", data.adminOnly)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-configchanged">
<summary><a id="ConfigChanged"></a>ConfigChanged(key, value, oldValue, client)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="configchanged"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Run logic after a configuration value changes.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When a config entry is updated via admin tools or code on the server.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">key</span> Config key that changed.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">any</a></span> <span class="parameter">value</span> New value.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">any</a></span> <span class="parameter">oldValue</span> Previous value.</p>
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> <span class="optional">optional</span> Player who made the change, if any.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("ConfigChanged", "BroadcastChange", function(key, value, old, client)
      if SERVER then lia.log.add(client, "configChanged", key, tostring(old), tostring(value)) end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-domoduleincludes">
<summary><a id="DoModuleIncludes"></a>DoModuleIncludes(path, MODULE)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="domoduleincludes"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Customize how module files are included.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>During module loading in the modularity library for each include path.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">path</span> Path of the file being included.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">MODULE</span> Module table receiving the include.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("DoModuleIncludes", "TrackModuleIncludes", function(path, MODULE)
      MODULE.loadedFiles = MODULE.loadedFiles or {}
      table.insert(MODULE.loadedFiles, path)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-forcerecognizerange">
<summary><a id="ForceRecognizeRange"></a>ForceRecognizeRange(ply, range, fakeName)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="forcerecognizerange"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Force a character to recognize everyone within a given chat range.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>By recognition commands to mark nearby characters as recognized.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">ply</span> Player whose recognition list is being updated.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string|number</a></span> <span class="parameter">range</span> Range preset ("whisper", "normal", "yell") or numeric distance.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">fakeName</span> <span class="optional">optional</span> Optional fake name to record for recognition.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("ForceRecognizeRange", "LogForcedRecognition", function(ply, range)
      lia.log.add(ply, "charRecognizeRange", tostring(range))
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-getattributemax">
<summary><a id="GetAttributeMax"></a>GetAttributeMax(client, id)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="getattributemax"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Override the maximum level a character can reach for a given attribute.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Whenever attribute caps are checked, such as when spending points or granting boosts.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player whose attribute cap is being queried.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">id</span> Attribute identifier.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number|nil</a></span> Maximum allowed level (defaults to infinity).</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("GetAttributeMax", "HardCapEndurance", function(client, id)
      if id == "end" then return 50 end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-getattributestartingmax">
<summary><a id="GetAttributeStartingMax"></a>GetAttributeStartingMax(client, attribute)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="getattributestartingmax"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Define the maximum starting value for an attribute during character creation.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>While allocating starting attribute points to limit each stat.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player creating the character.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">attribute</span> Attribute identifier.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number|nil</a></span> Maximum value allowed at creation; nil falls back to default limits.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("GetAttributeStartingMax", "LowStartForStrength", function(client, attribute)
      if attribute == "str" then return 5 end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-getcharmaxstamina">
<summary><a id="GetCharMaxStamina"></a>GetCharMaxStamina(char)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="getcharmaxstamina"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Specify a character's maximum stamina pool.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Whenever stamina is clamped, restored, or initialized.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/libraries/char/">Character</a></span> <span class="parameter">char</span> Character whose stamina cap is being read.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number|nil</a></span> Max stamina value; defaults to `DefaultStamina` config when nil.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("GetCharMaxStamina", "PerkBonus", function(char)
      if char:hasFlags("S") then return lia.config.get("DefaultStamina", 100) + 25 end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-getdefaultchardesc">
<summary><a id="GetDefaultCharDesc"></a>GetDefaultCharDesc(client, arg2, data)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="getdefaultchardesc"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Provide a default character description for a faction.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>During creation validation and adjustment for the `desc` character variable.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player creating the character.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">arg2</span> Faction index being created.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">data</span> Creation payload.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p>string, boolean|nil Description text and a flag indicating whether to override the player's input.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("GetDefaultCharDesc", "StaffDesc", function(client, faction)
      if faction == FACTION_STAFF then return L("staffCharacterDiscordSteamID", "n/a", client:SteamID()), true end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-getdefaultcharname">
<summary><a id="GetDefaultCharName"></a>GetDefaultCharName(client, faction, data)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="getdefaultcharname"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Provide a default character name for a faction.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>During creation validation and adjustment for the `name` character variable.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player creating the character.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">faction</span> Target faction index.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">data</span> Creation payload.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p>string, boolean|nil Name text and a flag indicating whether to override the player's input.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("GetDefaultCharName", "StaffTemplate", function(client, faction, data)
      if faction == FACTION_STAFF then return "Staff - " .. client:SteamName(), true end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-getdefaultinventorysize">
<summary><a id="GetDefaultInventorySize"></a>GetDefaultInventorySize(client, char)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="getdefaultinventorysize"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Override the default inventory dimensions a character starts with.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>During inventory setup on character creation and load.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player owning the character.</p>
<p><span class="types"><a class="type" href="/development/libraries/char/">Character</a></span> <span class="parameter">char</span> Character whose inventory size is being set.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p>number, number|nil Inventory width and height; nil values fall back to config defaults.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("GetDefaultInventorySize", "LargeBagsForStaff", function(client, char)
      if client:IsAdmin() then return 8, 6 end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-getdisplayedname">
<summary><a id="GetDisplayedName"></a>GetDisplayedName(client, chatType)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="getdisplayedname"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Decide what name is shown for a player in chat based on recognition.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client-side when rendering chat messages to resolve a display name.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Speaker whose name is being displayed.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">chatType</span> Chat channel identifier.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string|nil</a></span> Name to display; nil lets the default recognition logic run.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("GetDisplayedName", "ShowAliasInWhisper", function(client, chatType)
      if chatType == "w" then return client:getChar():getData("alias") end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-gethandsattackspeed">
<summary><a id="GetHandsAttackSpeed"></a>GetHandsAttackSpeed(arg1, arg2)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="gethandsattackspeed"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Adjust the delay between punches for the hands SWEP.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Each time the fists are swung to determine the next attack delay.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">arg1</span> Player punching.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">arg2</span> Default delay before the next punch.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number|nil</a></span> Replacement delay; nil keeps the default.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("GetHandsAttackSpeed", "FasterCombatDrugs", function(client, defaultDelay)
      if client:getNetVar("combatStim") then return defaultDelay * 0.75 end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-getitemdropmodel">
<summary><a id="GetItemDropModel"></a>GetItemDropModel(itemTable, itemEntity)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="getitemdropmodel"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Override the model used when an item spawns as a world entity.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When an item entity is created server-side to set its model.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">itemTable</span> Item definition table.</p>
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">itemEntity</span> Spawned item entity.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string|nil</a></span> Model path to use; nil keeps the item's configured model.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("GetItemDropModel", "IconicMoneyBag", function(itemTable)
      if itemTable.uniqueID == "moneycase" then return "models/props_c17/briefcase001a.mdl" end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-getmaxplayerchar">
<summary><a id="GetMaxPlayerChar"></a>GetMaxPlayerChar(client)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="getmaxplayerchar"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Override the maximum number of characters a player may create.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When rendering the character list and validating new character creation.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player whose limit is being checked.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number|nil</a></span> Maximum character slots; nil falls back to `MaxCharacters` config.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("GetMaxPlayerChar", "VIPExtraSlot", function(client)
      if client:IsUserGroup("vip") then return (lia.config.get("MaxCharacters") or 5) + 1 end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-getmaxstartingattributepoints">
<summary><a id="GetMaxStartingAttributePoints"></a>GetMaxStartingAttributePoints(client, count)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="getmaxstartingattributepoints"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Set the total attribute points available during character creation.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>On the creation screen when allocating starting attributes.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player creating the character.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">count</span> Default maximum points.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number|nil</a></span> Maximum points allowed; nil keeps the default.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("GetMaxStartingAttributePoints", "PerkBonusPoints", function(client, count)
      if client:IsAdmin() then return count + 5 end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-getmodelgender">
<summary><a id="GetModelGender"></a>GetModelGender(model)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="getmodelgender"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Identify the gender classification for a player model.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When entity meta needs to know if a model is treated as female for voice/animations.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">model</span> Model path being inspected.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string|nil</a></span> "female" to treat as female, or nil for default male handling.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("GetModelGender", "CustomFemaleModels", function(model)
      if model:find("female_custom") then return "female" end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-getmoneymodel">
<summary><a id="GetMoneyModel"></a>GetMoneyModel(arg1)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="getmoneymodel"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Pick the world model used by a money entity based on its amount.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When a `lia_money` entity initializes and sets its model.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">arg1</span> Amount of currency the entity holds.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string|nil</a></span> Model path override; nil falls back to `MoneyModel` config.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("GetMoneyModel", "HighValueCash", function(amount)
      if amount &gt;= 1000 then return "models/props_lab/box01a.mdl" end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-getnpcdialogoptions">
<summary><a id="GetNPCDialogOptions"></a>GetNPCDialogOptions(arg1, arg2, arg3)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="getnpcdialogoptions"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Supply additional dialog options for an NPC conversation.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When the client requests dialog options for an NPC and builds the menu.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">arg1</span> Player interacting with the NPC.</p>
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">arg2</span> NPC being talked to.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">arg3</span> Whether the NPC supports customization options.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table|nil</a></span> Extra dialog options keyed by unique id; nil keeps defaults only.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("GetNPCDialogOptions", "AddShopGreeting", function(client, npc)
      return {special = {name = "Ask about wares", callback = function() net.Start("npcShop") net.SendToServer() end}}
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-getplayerpunchdamage">
<summary><a id="GetPlayerPunchDamage"></a>GetPlayerPunchDamage(arg1, arg2, arg3)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="getplayerpunchdamage"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Adjust fist damage output for a punch.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Just before a punch trace applies damage in the hands SWEP.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">arg1</span> Punching player.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">arg2</span> Default damage.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">arg3</span> Context table you may mutate (e.g., `context.damage`).</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number|nil</a></span> New damage value; nil uses `context.damage` or the original.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("GetPlayerPunchDamage", "StrengthAffectsPunch", function(client, damage, ctx)
      local char = client:getChar()
      if char then ctx.damage = ctx.damage + char:getAttrib("str", 0) * 0.2 end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-getplayerpunchragdolltime">
<summary><a id="GetPlayerPunchRagdollTime"></a>GetPlayerPunchRagdollTime(arg1, arg2)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="getplayerpunchragdolltime"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Set how long a target is ragdolled when nonlethal punches knock them down.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When a punch would kill a player while lethality is disabled.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">arg1</span> Attacker.</p>
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">arg2</span> Target player being knocked out.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number|nil</a></span> Ragdoll duration in seconds; nil uses `PunchRagdollTime` config.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("GetPlayerPunchRagdollTime", "ShorterKO", function(client, target)
      if target:IsAdmin() then return 5 end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-getpriceoverride">
<summary><a id="GetPriceOverride"></a>GetPriceOverride(vendor, uniqueID, price, isSellingToVendor)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="getpriceoverride"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Override a vendor's buy/sell price for an item.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When a vendor calculates price for buying from or selling to a player.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">vendor</span> Vendor entity.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">uniqueID</span> Item unique ID being priced.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">price</span> Base price before modifiers.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">isSellingToVendor</span> True if the player is selling an item to the vendor.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number|nil</a></span> Replacement price; nil keeps the existing calculation.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("GetPriceOverride", "FactionDiscount", function(vendor, uniqueID, price, selling)
      if vendor.factionDiscount and not selling then return math.Round(price * vendor.factionDiscount) end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-getragdolltime">
<summary><a id="GetRagdollTime"></a>GetRagdollTime(client, time)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="getragdolltime"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Set the ragdoll duration when a player is knocked out.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Whenever `playerMeta:setRagdolled` determines the ragdoll time.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player being ragdolled.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">time</span> Proposed ragdoll time.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number|nil</a></span> Replacement time; nil keeps the proposed duration.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("GetRagdollTime", "ShorterStaffRagdoll", function(client, time)
      if client:IsAdmin() then return math.min(time, 5) end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-getvendorsalescale">
<summary><a id="GetVendorSaleScale"></a>GetVendorSaleScale(vendor)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="getvendorsalescale"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Apply a global sale/markup scale to vendor transactions.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When vendors compute sale or purchase totals.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">vendor</span> Vendor entity performing the sale.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number|nil</a></span> Multiplier applied to prices (e.g., 0.9 for 10% off); nil keeps vendor defaults.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("GetVendorSaleScale", "HappyHour", function(vendor)
      if vendor:GetNWBool("happyHour") then return 0.8 end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-getweaponname">
<summary><a id="GetWeaponName"></a>GetWeaponName(weapon)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="getweaponname"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Override the display name derived from a weapon when creating an item or showing UI.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When generating item data from a weapon or showing weapon names in selectors.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">weapon</span> Weapon entity whose name is being resolved.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string|nil</a></span> Custom weapon name; nil falls back to print name.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("GetWeaponName", "PrettySWEPNames", function(weapon)
      return language.GetPhrase(weapon:GetClass() .. "_friendly") or weapon:GetPrintName()
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-initializestorage">
<summary><a id="InitializeStorage"></a>InitializeStorage(entity)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="initializestorage"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Initialize a storage entity's inventory rules or data.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After a storage entity is created or loaded and before player interaction.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">entity</span> Storage entity being prepared.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("InitializeStorage", "SetTrunkOwner", function(ent)
      if ent:isVehicle() then ent:setNetVar("storageOwner", ent:GetNWString("owner")) end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-initializedconfig">
<summary><a id="InitializedConfig"></a>InitializedConfig()</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="initializedconfig"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Signal that configuration definitions have been loaded client-side.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After the administration config UI finishes building available options.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("InitializedConfig", "BuildConfigUI", function()
      lia.config.buildList()
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-initializeditems">
<summary><a id="InitializedItems"></a>InitializedItems()</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="initializeditems"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Notify that all items have been registered.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After item scripts finish loading during initialization.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("InitializedItems", "CacheItemIDs", function()
      lia.itemIDCache = table.GetKeys(lia.item.list)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-initializedkeybinds">
<summary><a id="InitializedKeybinds"></a>InitializedKeybinds()</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="initializedkeybinds"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Signal that keybind definitions are loaded.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After keybinds are registered during initialization.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("InitializedKeybinds", "RegisterCustomBind", function()
      lia.key.addBind("ToggleHUD", KEY_F6, "Toggle HUD", function(client) hook.Run("ToggleHUD") end)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-initializedmodules">
<summary><a id="InitializedModules"></a>InitializedModules()</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="initializedmodules"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Announce that all modules have finished loading.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After module include phase completes, including reloads.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("InitializedModules", "WarmWorkshopCache", function()
      lia.workshop.cache = lia.workshop.gather()
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-initializedoptions">
<summary><a id="InitializedOptions"></a>InitializedOptions()</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="initializedoptions"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Notify that all options have been registered and loaded.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After the option library finishes loading saved values on the client.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("InitializedOptions", "ApplyThemeOption", function()
      hook.Run("OnThemeChanged", lia.option.get("Theme", "Teal"), false)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-initializedschema">
<summary><a id="InitializedSchema"></a>InitializedSchema()</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="initializedschema"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Fire once the schema finishes loading.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After schema initialization completes; useful for schema-level setup.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("InitializedSchema", "SetupSchemaData", function()
      lia.schema.setupComplete = true
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-inventorydatachanged">
<summary><a id="InventoryDataChanged"></a>InventoryDataChanged(instance, key, oldValue, value)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="inventorydatachanged"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>React to inventory metadata changes.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When an inventory's data key is updated and replicated to clients.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/libraries/inventory/">Inventory</a></span> <span class="parameter">instance</span> Inventory whose data changed.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">key</span> Data key.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">any</a></span> <span class="parameter">oldValue</span> Previous value.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">any</a></span> <span class="parameter">value</span> New value.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("InventoryDataChanged", "UpdateBagLabel", function(inv, key, old, new)
      if key == "bagName" then inv:getOwner():notify("Bag renamed to " .. tostring(new)) end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-inventoryinitialized">
<summary><a id="InventoryInitialized"></a>InventoryInitialized(instance)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="inventoryinitialized"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Signal that an inventory has finished initializing on the client.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After an inventory is created or received over the network.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/libraries/inventory/">Inventory</a></span> <span class="parameter">instance</span> Inventory that is ready.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("InventoryInitialized", "ShowInventoryUI", function(inv)
      if inv:getOwner() == LocalPlayer() then lia.inventory.show(inv) end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-inventoryitemadded">
<summary><a id="InventoryItemAdded"></a>InventoryItemAdded(inventory, item)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="inventoryitemadded"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>React when an item is added to an inventory.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After an item successfully enters an inventory, both server- and client-side.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/libraries/inventory/">Inventory</a></span> <span class="parameter">inventory</span> Inventory receiving the item.</p>
<p><span class="types"><a class="type" href="/development/libraries/item/">Item</a></span> <span class="parameter">item</span> Item instance added.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("InventoryItemAdded", "PlayPickupSound", function(inv, item)
      local owner = inv:getOwner()
      if IsValid(owner) then owner:EmitSound("items/ammocrate_open.wav", 60) end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-inventoryitemremoved">
<summary><a id="InventoryItemRemoved"></a>InventoryItemRemoved(inventory, instance, preserveItem)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="inventoryitemremoved"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>React when an item leaves an inventory.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After an item is removed from an inventory, optionally preserving the instance.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/libraries/inventory/">Inventory</a></span> <span class="parameter">inventory</span> Inventory losing the item.</p>
<p><span class="types"><a class="type" href="/development/libraries/item/">Item</a></span> <span class="parameter">instance</span> Item removed.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">preserveItem</span> True if the item instance is kept alive (e.g., dropped) instead of deleted.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("InventoryItemRemoved", "LogRemoval", function(inv, item, preserve)
      lia.log.add(inv:getOwner(), "itemRemoved", item.uniqueID, preserve and "preserved" or "deleted")
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-ischarfakerecognized">
<summary><a id="IsCharFakeRecognized"></a>IsCharFakeRecognized(character, id)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="ischarfakerecognized"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Decide if a character is recognized under a fake name.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When checking recognition with fake names enabled.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/libraries/char/">Character</a></span> <span class="parameter">character</span> Character performing the recognition check.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">id</span> Target character ID.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> Return true if recognized via fake name, false otherwise.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("IsCharFakeRecognized", "AlwaysRecognizeSelf", function(character, id)
      if character.id == id then return true end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-ischarrecognized">
<summary><a id="IsCharRecognized"></a>IsCharRecognized(a, arg2)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="ischarrecognized"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Override whether one character recognizes another.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Whenever recognition checks are performed for chat or display logic.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/libraries/char/">Character</a></span> <span class="parameter">a</span> Character performing the check.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">arg2</span> Target character ID.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> Return false to force unrecognized, true to force recognized, or nil to use default logic.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("IsCharRecognized", "FactionAutoRecognize", function(character, id)
      local other = lia.char.getCharacter(id, character:getPlayer())
      if other and other:getFaction() == character:getFaction() then return true end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-isrecognizedchattype">
<summary><a id="IsRecognizedChatType"></a>IsRecognizedChatType(chatType)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="isrecognizedchattype"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Declare which chat types should hide names when unrecognized.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client-side when choosing to display `[Unknown]` instead of a name.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">chatType</span> Chat channel identifier.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> Return true to treat the chat type as requiring recognition.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("IsRecognizedChatType", "RecognizedEmote", function(chatType)
      if chatType == "me" then return true end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-issuitablefortrunk">
<summary><a id="IsSuitableForTrunk"></a>IsSuitableForTrunk(ent)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="issuitablefortrunk"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Check if an entity can host a storage trunk.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Before creating or opening storage tied to an entity (e.g., vehicles).</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">ent</span> Entity being evaluated.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> Return false to disallow trunk storage on this entity.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("IsSuitableForTrunk", "AllowSpecificVehicles", function(vehicle)
      if vehicle:isSimfphysCar() then return true end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-itemdatachanged">
<summary><a id="ItemDataChanged"></a>ItemDataChanged(item, key, oldValue, newValue)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="itemdatachanged"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>React when persistent data on an item changes.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When an item's data key is updated via networking and propagated to clients.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/libraries/item/">Item</a></span> <span class="parameter">item</span> Item whose data changed.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">key</span> Data key.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">any</a></span> <span class="parameter">oldValue</span> Previous value.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">any</a></span> <span class="parameter">newValue</span> Updated value.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("ItemDataChanged", "UpdateDurabilityUI", function(item, key, old, new)
      if key == "durability" then item:refreshPanels() end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-itemdefaultfunctions">
<summary><a id="ItemDefaultFunctions"></a>ItemDefaultFunctions(arg1)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="itemdefaultfunctions"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Inject or modify the default function set applied to every item.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>During item registration when the base functions table is copied to a new item.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">arg1</span> Functions table for the item being registered.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("ItemDefaultFunctions", "AddInspect", function(funcs)
      funcs.Inspect = {
          name = "inspect",
          onRun = function(item) item.player:notify(item:getDesc()) end
      }
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-iteminitialized">
<summary><a id="ItemInitialized"></a>ItemInitialized(item)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="iteminitialized"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Notify that an item instance has been initialized client-side.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When item data is received over the network and the item is constructed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/libraries/item/">Item</a></span> <span class="parameter">item</span> Newly initialized item instance.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("ItemInitialized", "PrimeItemPanels", function(item)
      if item.panel then item.panel:Refresh() end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-itemquantitychanged">
<summary><a id="ItemQuantityChanged"></a>ItemQuantityChanged(item, oldValue, quantity)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="itemquantitychanged"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>React when an item's quantity changes.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After quantity is updated and replicated to clients.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/libraries/item/">Item</a></span> <span class="parameter">item</span> Item whose quantity changed.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">oldValue</span> Previous quantity.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">quantity</span> New quantity.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("ItemQuantityChanged", "UpdateStackLabel", function(item, old, new)
      if item.panel then item.panel:SetStack(new) end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-lilialoaded">
<summary><a id="LiliaLoaded"></a>LiliaLoaded()</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="lilialoaded"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Signal that the Lilia client has finished loading.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After pre-load hooks complete on the client startup sequence.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("LiliaLoaded", "OpenHUD", function()
      lia.hud.init()
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-netvarchanged">
<summary><a id="NetVarChanged"></a>NetVarChanged(client, key, oldValue, value)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="netvarchanged"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Respond to networked variable changes on entities, players, or characters.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Whenever a netVar is updated via `setNetVar` on players, entities, or characters.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">client</span> Entity whose netVar changed (player or entity).</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">key</span> NetVar key.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">any</a></span> <span class="parameter">oldValue</span> Previous value.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">any</a></span> <span class="parameter">value</span> New value.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("NetVarChanged", "TrackStamina", function(entity, key, old, new)
      if key == "stamina" and entity:IsPlayer() then entity.lastStamina = new end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-onadminsystemloaded">
<summary><a id="OnAdminSystemLoaded"></a>OnAdminSystemLoaded(arg1, arg2)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="onadminsystemloaded"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Signal that the admin system integration has loaded.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After administration modules finish initializing and privileges are available.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">arg1</span> <span class="optional">optional</span> Admin integration data, if provided.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">arg2</span> <span class="optional">optional</span> Additional metadata from the admin system.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnAdminSystemLoaded", "RegisterCustomPrivileges", function()
      lia.admin.addPrivilege("spawnVehicles", "Spawn Vehicles")
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-onchargetup">
<summary><a id="OnCharGetup"></a>OnCharGetup(target, entity)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="onchargetup"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Notify when a ragdolled character finishes getting up.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After a get-up action completes and the ragdoll entity is removed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">target</span> Player whose character stood up.</p>
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">entity</span> Ragdoll entity that was removed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnCharGetup", "ClearRagdollState", function(player, ragdoll)
      player:setLocalVar("brth", nil)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-oncharvarchanged">
<summary><a id="OnCharVarChanged"></a>OnCharVarChanged(character, varName, oldVar, newVar)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="oncharvarchanged"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>React whenever a character variable changes.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After a char var setter updates a value and broadcasts it.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/libraries/char/">Character</a></span> <span class="parameter">character</span> Character whose variable changed.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">varName</span> Variable key.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">any</a></span> <span class="parameter">oldVar</span> Previous value.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">any</a></span> <span class="parameter">newVar</span> New value.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnCharVarChanged", "FlagChangeNotice", function(char, key, old, new)
      if key == "flags" then lia.log.add(char:getPlayer(), "flagsChanged", tostring(old), tostring(new)) end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-onconfigupdated">
<summary><a id="OnConfigUpdated"></a>OnConfigUpdated(key, oldValue, value)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="onconfigupdated"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>React on the client when a config value updates.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client-side after a config entry changes and is broadcast.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">key</span> Config key.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">any</a></span> <span class="parameter">oldValue</span> Previous value.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">any</a></span> <span class="parameter">value</span> New value.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnConfigUpdated", "ReloadLanguage", function(key, old, new)
      if key == "Language" then lia.lang.clearCache() end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-onitemadded">
<summary><a id="OnItemAdded"></a>OnItemAdded(owner, item)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="onitemadded"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Handle server-side logic when an item is added to an inventory.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After an item successfully enters an inventory on the server.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">owner</span> <span class="optional">optional</span> Owner player of the inventory, if applicable.</p>
<p><span class="types"><a class="type" href="/development/libraries/item/">Item</a></span> <span class="parameter">item</span> Item instance that was added.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnItemAdded", "NotifyPickup", function(owner, item)
      if IsValid(owner) then owner:notifyLocalized("itemAdded", item:getName()) end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-onitemcreated">
<summary><a id="OnItemCreated"></a>OnItemCreated(itemTable, itemEntity)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="onitemcreated"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>React when an item entity is spawned into the world.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When `lia_item` entities are created for dropped or spawned items.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">itemTable</span> Static item definition.</p>
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">itemEntity</span> Spawned entity representing the item.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnItemCreated", "EnableGlow", function(itemTable, entity)
      if itemTable.rare then entity:SetRenderFX(kRenderFxHologram) end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-onitemoverridden">
<summary><a id="OnItemOverridden"></a>OnItemOverridden(item, overrides)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="onitemoverridden"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Inspect or modify item override data during registration.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When overrides are applied to an item definition at load time.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">item</span> Item definition being overridden.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">overrides</span> Table of override values.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnItemOverridden", "EnsureCategory", function(item, overrides)
      if overrides.category == nil then overrides.category = "misc" end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-onitemregistered">
<summary><a id="OnItemRegistered"></a>OnItemRegistered(ITEM)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="onitemregistered"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Run logic immediately after an item type is registered.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>At the end of `lia.item.register` once the item table is stored.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">ITEM</span> Registered item definition.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnItemRegistered", "CollectWeaponItems", function(item)
      if item.isWeapon then lia.weaponItems = lia.weaponItems or {} table.insert(lia.weaponItems, item.uniqueID) end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-onlocalizationloaded">
<summary><a id="OnLocalizationLoaded"></a>OnLocalizationLoaded()</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="onlocalizationloaded"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Notify that localization files have finished loading.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After language files and cached phrases are loaded/cleared.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnLocalizationLoaded", "RefreshLanguageDependentUI", function()
      if IsValid(lia.menu.panel) then lia.menu.panel:InvalidateLayout(true) end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-onpac3parttransfered">
<summary><a id="OnPAC3PartTransfered"></a>OnPAC3PartTransfered(part)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="onpac3parttransfered"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Handle PAC3 parts being reassigned to a ragdoll.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When a player's PAC parts transfer to their ragdoll entity during rendering.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity|table</a></span> <span class="parameter">part</span> PAC3 part being transferred.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnPAC3PartTransfered", "DisableRagdollPAC", function(part)
      part:SetNoDraw(true)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-onplayerpurchasedoor">
<summary><a id="OnPlayerPurchaseDoor"></a>OnPlayerPurchaseDoor(client, door, arg3)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="onplayerpurchasedoor"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>React when a player purchases or sells a door.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>During door buy/sell commands after payment/ownership changes are processed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player performing the transaction.</p>
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">door</span> Door entity involved.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">arg3</span> True if selling/refunding, false if buying.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnPlayerPurchaseDoor", "LogDoorSale", function(client, door, selling)
      lia.log.add(client, selling and "doorSold" or "doorBought", tostring(door))
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-onplayerdroppeditem">
<summary><a id="OnPlayerDroppedItem"></a>OnPlayerDroppedItem(client, spawnedItem)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="onplayerdroppeditem"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called when a player drops an item from their inventory.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After an item has been successfully dropped from a player's inventory.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> The player who dropped the item.</p>
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">spawnedItem</span> The spawned item entity that was created.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnPlayerDroppedItem", "LogItemDrop", function(client, spawnedItem)
      print(client:Name() .. " dropped an item")
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-onplayerrotateitem">
<summary><a id="OnPlayerRotateItem"></a>OnPlayerRotateItem(arg1, item, newRot)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="onplayerrotateitem"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called when a player rotates an item in their inventory.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After an item has been successfully rotated in a player's inventory.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">arg1</span> The player who rotated the item.</p>
<p><span class="types"><a class="type" href="/development/libraries/item/">Item</a></span> <span class="parameter">item</span> The item that was rotated.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">newRot</span> The new rotation value.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnPlayerRotateItem", "LogItemRotation", function(client, item, newRot)
      print(client:Name() .. " rotated " .. item:getName() .. " to " .. newRot)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-onplayertakeitem">
<summary><a id="OnPlayerTakeItem"></a>OnPlayerTakeItem(client, item)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="onplayertakeitem"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called when a player takes an item into their inventory.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After an item has been successfully taken into a player's inventory.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> The player who took the item.</p>
<p><span class="types"><a class="type" href="/development/libraries/item/">Item</a></span> <span class="parameter">item</span> The item that was taken.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnPlayerTakeItem", "LogItemPickup", function(client, item)
      print(client:Name() .. " took " .. item:getName())
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-onprivilegeregistered">
<summary><a id="OnPrivilegeRegistered"></a>OnPrivilegeRegistered(arg1, arg2, arg3, arg4)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="onprivilegeregistered"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>React when an admin privilege is registered.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When CAMI/compatibility layers add a new privilege.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">arg1</span> CAMI privilege table or simplified privilege data.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">any</a></span> <span class="parameter">arg2</span> Optional extra data from the source integration.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">any</a></span> <span class="parameter">arg3</span> Optional extra data from the source integration.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">any</a></span> <span class="parameter">arg4</span> Optional extra data from the source integration.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnPrivilegeRegistered", "SyncPrivileges", function(priv)
      print("Privilege added:", priv.Name or priv.name)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-onprivilegeunregistered">
<summary><a id="OnPrivilegeUnregistered"></a>OnPrivilegeUnregistered(arg1, arg2)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="onprivilegeunregistered"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>React when an admin privilege is removed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When CAMI/compatibility layers unregister a privilege.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">arg1</span> Privilege data being removed.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">any</a></span> <span class="parameter">arg2</span> Optional extra data.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnPrivilegeUnregistered", "CleanupPrivilegeCache", function(priv)
      lia.admin.cache[priv.Name] = nil
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-onthemechanged">
<summary><a id="OnThemeChanged"></a>OnThemeChanged(themeName, useTransition)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="onthemechanged"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Notify clients that the active UI theme changed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After a theme is applied or a transition completes.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">themeName</span> Name of the theme applied.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">useTransition</span> True if the theme is transitioning over time.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnThemeChanged", "RefreshPanels", function(name)
      for _, panel in ipairs(vgui.GetWorldPanel():GetChildren()) do if panel.RefreshTheme then panel:RefreshTheme() end end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-ontransferred">
<summary><a id="OnTransferred"></a>OnTransferred(target)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="ontransferred"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Respond after a character is transferred between factions or classes.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Immediately after transfer logic completes in team management.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">target</span> Player whose character was transferred.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnTransferred", "StripOldClassWeapons", function(client)
      client:StripWeapons()
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-onusergroupcreated">
<summary><a id="OnUsergroupCreated"></a>OnUsergroupCreated(groupName, arg2)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="onusergroupcreated"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>React when a new usergroup is created in the admin system.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When an admin integration registers a new group.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">groupName</span> Name of the new group.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">any</a></span> <span class="parameter">arg2</span> Optional extra data (e.g., privilege list).</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnUsergroupCreated", "CacheNewGroup", function(name)
      lia.admin.refreshGroupCache(name)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-onusergroupremoved">
<summary><a id="OnUsergroupRemoved"></a>OnUsergroupRemoved(groupName)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="onusergroupremoved"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>React when a usergroup is removed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When an admin integration deletes a group.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">groupName</span> Name of the removed group.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnUsergroupRemoved", "PurgeRemovedGroup", function(name)
      lia.admin.groups[name] = nil
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-onusergrouprenamed">
<summary><a id="OnUsergroupRenamed"></a>OnUsergroupRenamed(oldName, newName)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="onusergrouprenamed"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>React when a usergroup is renamed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After the admin system renames an existing group.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">oldName</span> Previous group name.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">newName</span> Updated group name.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnUsergroupRenamed", "UpdateGroupCache", function(oldName, newName)
      lia.admin.groups[newName] = lia.admin.groups[oldName]
      lia.admin.groups[oldName] = nil
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-optionadded">
<summary><a id="OptionAdded"></a>OptionAdded(key, name, option)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="optionadded"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Notify that a new option has been registered.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Immediately after `lia.option.add` stores an option.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">key</span> Option key.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">name</span> Stored option table (name is the localized display name).</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">option</span> Option metadata table.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OptionAdded", "InvalidateQuickOptions", function(key, opt)
      if opt.isQuick or (opt.data and opt.data.isQuick) then lia.option.invalidateCache() end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-optionchanged">
<summary><a id="OptionChanged"></a>OptionChanged(key, old, value)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="optionchanged"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Handle updates to option values.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After `lia.option.set` changes a value (client or server).</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">key</span> Option key.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">any</a></span> <span class="parameter">old</span> Previous value.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">any</a></span> <span class="parameter">value</span> New value.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OptionChanged", "ApplyHUDScale", function(key, old, new)
      if key == "HUDScale" then lia.hud.setScale(new) end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-overridefactiondesc">
<summary><a id="OverrideFactionDesc"></a>OverrideFactionDesc(uniqueID, arg2)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="overridefactiondesc"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Override the description shown for a faction.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>During faction registration/loading while assembling faction data.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">uniqueID</span> Faction unique identifier.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">arg2</span> Current description.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string|nil</a></span> Replacement description; nil keeps the existing text.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OverrideFactionDesc", "CustomStaffDesc", function(id, desc)
      if id == "staff" then return "Lilia staff team" end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-overridefactionmodels">
<summary><a id="OverrideFactionModels"></a>OverrideFactionModels(uniqueID, arg2)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="overridefactionmodels"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Override the model list for a faction.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>During faction registration/loading while choosing models.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">uniqueID</span> Faction identifier.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">arg2</span> Default models table.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table|nil</a></span> Replacement models table; nil keeps defaults.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OverrideFactionModels", "SwapCitizenModels", function(id, models)
      if id == "citizen" then return {"models/player/alyx.mdl"} end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-overridefactionname">
<summary><a id="OverrideFactionName"></a>OverrideFactionName(uniqueID, arg2)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="overridefactionname"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Override the display name for a faction.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>During faction registration/loading before teams are created.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">uniqueID</span> Faction identifier.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">arg2</span> Default faction name.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string|nil</a></span> Replacement name; nil keeps the default.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OverrideFactionName", "RenameCombine", function(id, name)
      if id == "combine" then return "Civil Protection" end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-overridespawntime">
<summary><a id="OverrideSpawnTime"></a>OverrideSpawnTime(ply, baseTime)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="overridespawntime"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Adjust the respawn timer for a player.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When calculating respawn delay on client and server.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">ply</span> Player that will respawn.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">baseTime</span> Base respawn time in seconds.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number|nil</a></span> New respawn time; nil keeps the base value.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OverrideSpawnTime", "VIPFastRespawn", function(ply, base)
      if ply:IsUserGroup("vip") then return math.max(base * 0.5, 1) end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-playerthrowpunch">
<summary><a id="PlayerThrowPunch"></a>PlayerThrowPunch(client)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="playerthrowpunch"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Perform post-punch logic such as stamina consumption.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After a punch trace completes in the hands SWEP.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player who just punched.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("PlayerThrowPunch", "TrackPunches", function(client)
      client.punchesThrown = (client.punchesThrown or 0) + 1
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-prelilialoaded">
<summary><a id="PreLiliaLoaded"></a>PreLiliaLoaded()</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="prelilialoaded"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Run right before the client finishes loading Lilia.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>At the start of the client load sequence before `LiliaLoaded`.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("PreLiliaLoaded", "SetupFonts", function()
      lia.util.createFont("liaBig", 32)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-removepart">
<summary><a id="RemovePart"></a>RemovePart(client, id)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="removepart"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Notify when a PAC3 part should be removed from a player.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client-side when a part id is marked for removal from a player.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> Player losing the part.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">id</span> Identifier of the part to remove.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("RemovePart", "ClearCachedPart", function(client, id)
      if client.liaPACParts then client.liaPACParts[id] = nil end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-setupbaginventoryaccessrules">
<summary><a id="SetupBagInventoryAccessRules"></a>SetupBagInventoryAccessRules(inventory)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="setupbaginventoryaccessrules"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Apply standard access rules to a bag's child inventory.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Immediately after a bag inventory is created or loaded.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/libraries/inventory/">Inventory</a></span> <span class="parameter">inventory</span> Bag inventory being configured.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("SetupBagInventoryAccessRules", "CustomBagRule", function(inventory)
      inventory:addAccessRule(function(_, action) if action == "transfer" then return true end end, 2)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-setuppacdatafromitems">
<summary><a id="SetupPACDataFromItems"></a>SetupPACDataFromItems()</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="setuppacdatafromitems"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Build PAC3 data from equipped items and push it to clients.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shortly after PAC compatibility initializes to rebuild outfit data.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("SetupPACDataFromItems", "AddCustomPAC", function()
      for _, client in player.Iterator() do client:syncParts() end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-tryviewmodel">
<summary><a id="TryViewModel"></a>TryViewModel(entity)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="tryviewmodel"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Allows overriding the view model entity for PAC compatibility.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When determining the view model entity for PAC events.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">entity</span> The potential view model entity.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> The corrected view model entity, or the original if no correction needed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("TryViewModel", "PACViewModelFix", function(entity)
      if entity == pac.LocalPlayer:GetViewModel() then
          return pac.LocalPlayer
      end
      return entity
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-registerfeaturepositiontypes">
<summary><a id="RegisterFeaturePositionTypes"></a>RegisterFeaturePositionTypes(arg1)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="registerfeaturepositiontypes"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Allows modules to react to or modify the list of registered feature position types.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Every time MODULE:SetPositionCallback is called to register a new position feature.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">arg1</span> The list of current feature position types (lia.featurePositionTypes).</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("RegisterFeaturePositionTypes", "MonitorPositions", function(types)
      PrintTable(types)
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-setpositioncallback">
<summary><a id="SetPositionCallback"></a>SetPositionCallback(name, data, onRun, onSelect, color, HUDPaint, serverOnly)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="setpositioncallback"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Registers a callback for setting and managing world positions via the admin position tool.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Typically during module initialization to define new selectable position types in the admin tool.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">name</span> The display name of the position type (e.g., “Faction Spawn Adder”).</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">data</span> A table containing configuration:</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">function</a></span> <span class="parameter">onRun</span> Called when a position is set. Arguments: (pos, client, typeId).</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">function</a></span> <span class="parameter">onSelect</span> Called when the type is selected. Arguments: (client, callback).</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Color, optional</a></span> <span class="parameter">color</span> UI accent color.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">function, optional</a></span> <span class="parameter">HUDPaint</span> Extra HUD rendering.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">boolean, optional</a></span> <span class="parameter">serverOnly</span> If true, logic runs server-side.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  MODULE:SetPositionCallback("My Custom Point", {
      onRun = function(pos, client) -- ... end,
      onSelect = function(client, callback) -- ... end
  })
</code></pre>
</div>

</div>
</details>

---

