# Dialog

Comprehensive NPC dialog management system for the Lilia framework.

---

<h3 style="margin-bottom: 5px;">Overview</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
The dialog library provides comprehensive functionality for managing NPC conversations and dialog systems in the Lilia framework. It handles NPC registration, conversation filtering, client synchronization, and provides both server-side data management and client-side UI interactions. The library supports complex conversation trees with conditional options, server-only callbacks, and dynamic NPC customization. It includes automatic data sanitization, conversation filtering based on player permissions, and seamless integration with the framework's networking system. The library ensures secure and efficient dialog handling across both server and client realms.
</div>

---

<details class="realm-shared" id="function-liadialogistableequal">
<summary><a id="lia.dialog.isTableEqual"></a>lia.dialog.isTableEqual(tbl1, tbl2, checked)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadialogistableequal"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Performs a deep comparison of two tables to detect changes, avoiding infinite loops from circular references.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Before syncing dialog data to clients to prevent unnecessary network traffic.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">tbl1</span> First table to compare.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">tbl2</span> Second table to compare.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">checked</span> <span class="optional">optional</span> Internal table used to track visited references and prevent cycles.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> True if tables are identical, false otherwise.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  if not lia.dialog.isTableEqual(oldData, newData) then
      lia.dialog.syncDialogs()
  end
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liadialogregisterconfiguration">
<summary><a id="lia.dialog.registerConfiguration"></a>lia.dialog.registerConfiguration(uniqueID, data)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadialogregisterconfiguration"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Registers or updates an NPC configuration entry for customization panels.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>During gamemode initialization to define available NPC configuration options.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">uniqueID</span> Unique identifier for the configuration.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">data</span> Configuration data containing fields like name, order, shouldShow, onOpen, onApply, etc.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> The stored configuration table.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.dialog.registerConfiguration("shop_inventory", {
      name = "Shop Inventory",
      order = 5,
      shouldShow = function(ply) return ply:IsAdmin() end,
      onOpen = function(npc) OpenShopConfig(npc) end
  })
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liadialoggetconfiguration">
<summary><a id="lia.dialog.getConfiguration"></a>lia.dialog.getConfiguration(uniqueID)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadialoggetconfiguration"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Retrieves a registered configuration entry by its unique identifier.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When accessing configuration menus or checking configuration availability.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">uniqueID</span> The unique identifier of the configuration to retrieve.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table|nil</a></span> The configuration table if found, nil otherwise.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local cfg = lia.dialog.getConfiguration("appearance")
  if cfg and cfg.shouldShow(LocalPlayer()) then
      cfg.onOpen(npc)
  end
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liadialoggetnpcdata">
<summary><a id="lia.dialog.getNPCData"></a>lia.dialog.getNPCData(npcID)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadialoggetnpcdata"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Retrieves sanitized NPC dialog data by unique identifier.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server-side when preparing dialog data for clients or internal operations.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">npcID</span> The unique identifier of the NPC dialog.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table|nil</a></span> Sanitized NPC dialog data, or nil if not found.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local npcData = lia.dialog.getNPCData("tutorial_guide")
  if npcData then PrintTable(npcData) end
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liadialoggetoriginalnpcdata">
<summary><a id="lia.dialog.getOriginalNPCData"></a>lia.dialog.getOriginalNPCData(npcID)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadialoggetoriginalnpcdata"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Returns the original unsanitized NPC dialog definition including server-only callbacks.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server-side when re-filtering conversation options per-player or rebuilding client payloads.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">npcID</span> The unique identifier of the NPC dialog.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table|nil</a></span> Original NPC dialog data, or nil if not found.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local raw = lia.dialog.getOriginalNPCData("tutorial_guide")
  if raw and raw.Conversation then
      -- inspect server-only callbacks before sanitizing
  end
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liadialogsynctoclients">
<summary><a id="lia.dialog.syncToClients"></a>lia.dialog.syncToClients(client)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadialogsynctoclients"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Sends sanitized dialog data to a specific client or all connected players.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After dialog registration, changes, or on-demand admin refreshes.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> <span class="optional">optional</span> Specific player to sync to, or nil to broadcast to all players.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  concommand.Add("lia_dialog_resync", function(admin)
      if IsValid(admin) and admin:IsAdmin() then
          lia.dialog.syncToClients()
          admin:notifyLocalized("dialogResynced")
      end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liadialogsyncdialogs">
<summary><a id="lia.dialog.syncDialogs"></a>lia.dialog.syncDialogs()</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadialogsyncdialogs"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Broadcasts all dialog data to all connected clients.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>After bulk changes, during scheduled refreshes, or maintenance operations.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  timer.Create("ResyncDialogsHourly", 3600, 0, lia.dialog.syncDialogs)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liadialogregisternpc">
<summary><a id="lia.dialog.registerNPC"></a>lia.dialog.registerNPC(uniqueID, data, shouldSync)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadialogregisternpc"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Registers an NPC dialog definition and optionally synchronizes changes to clients.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>During gamemode initialization or when hot-loading NPC dialog data.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">uniqueID</span> Unique identifier for the NPC dialog.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">data</span> Complete NPC dialog definition including Conversation, PrintName, Greeting, etc.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">shouldSync</span> <span class="optional">optional</span> Whether to sync changes to clients immediately (defaults to true).</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> True if successfully registered, false otherwise.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.dialog.registerNPC("quests_barkeep", {
      PrintName = "Barkeep",
      Greeting = "What'll it be?",
      Conversation = {
          ["Got any work?"] = {
              Response = "A few rats in the cellar. Interested?",
              options = {
                  ["I'm in."] = {serverOnly = true, Callback = function(client) StartQuest(client, "cellar_rats") end},
                  ["No thanks."] = {Response = "Suit yourself."}
              }
          }
      }
  })
</code></pre>
</div>

</div>
</details>

---

<details class="realm-server" id="function-liadialogopendialog">
<summary><a id="lia.dialog.openDialog"></a>lia.dialog.openDialog(client, npc, npcID)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadialogopendialog"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Opens an NPC dialog for a player, filtering conversation options based on player permissions.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When a player interacts with an NPC entity.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">client</span> The player to open the dialog for.</p>
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">npc</span> The NPC entity being interacted with.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">npcID</span> The unique identifier of the NPC dialog type.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("PlayerUse", "HandleDialogNPCs", function(ply, ent)
      if ent:GetClass() == "lia_npc" then
          lia.dialog.openDialog(ply, ent, ent.uniqueID or "tutorial_guide")
          return false
      end
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-liadialoggetnpcdata">
<summary><a id="lia.dialog.getNPCData"></a>lia.dialog.getNPCData(npcID)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadialoggetnpcdata"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Retrieves sanitized NPC dialog data on the client.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When client UI needs to render or access dialog information.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">npcID</span> The unique identifier of the NPC dialog.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table|nil</a></span> Sanitized NPC dialog data, or nil if not found.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local data = lia.dialog.getNPCData("tutorial_guide")
  if data then print("Greeting:", data.Greeting) end
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-liadialogsubmitconfiguration">
<summary><a id="lia.dialog.submitConfiguration"></a>lia.dialog.submitConfiguration(configID, npc, payload)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadialogsubmitconfiguration"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Sends NPC customization data to the server for processing.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When submitting changes from NPC customization UI.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">configID</span> The configuration identifier.</p>
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">npc</span> The NPC entity being customized.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">payload</span> The customization data payload.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.dialog.submitConfiguration("appearance", npc, {model = "models/barney.mdl"})
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-liadialogopencustomizationui">
<summary><a id="lia.dialog.openCustomizationUI"></a>lia.dialog.openCustomizationUI(npc, configID)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadialogopencustomizationui"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Opens a comprehensive UI for customizing NPC appearance, animations, and dialog types.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>From properties menu or configuration picker interfaces.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">npc</span> The NPC entity to customize.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">configID</span> <span class="optional">optional</span> Configuration identifier, defaults to "appearance".</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  properties.Add("CustomNPCConfig", {
      Filter = function(_, ent) return ent:GetClass() == "lia_npc" end,
      Action = function(_, ent) lia.dialog.openCustomizationUI(ent, "appearance") end
  })
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liadialoggetavailableconfigurations">
<summary><a id="lia.dialog.getAvailableConfigurations"></a>lia.dialog.getAvailableConfigurations(ply, npc, npcID)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadialoggetavailableconfigurations"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Returns available NPC configurations for a player, sorted by order and name.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Before displaying configuration picker UI to filter accessible options.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/player/">Player</a></span> <span class="parameter">ply</span> The player to check permissions for.</p>
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">npc</span> <span class="optional">optional</span> The NPC entity being configured.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">npcID</span> <span class="optional">optional</span> The NPC's unique identifier.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> Array of accessible configuration tables.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local configs = lia.dialog.getAvailableConfigurations(LocalPlayer(), npc, npc.uniqueID)
  for _, cfg in ipairs(configs) do print("Config:", cfg.id) end
</code></pre>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-liadialogopenconfigurationpicker">
<summary><a id="lia.dialog.openConfigurationPicker"></a>lia.dialog.openConfigurationPicker(npc, npcID)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liadialogopenconfigurationpicker"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Opens the NPC configuration picker UI, prioritizing appearance configuration.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>When a player selects "Configure NPC" from the properties menu.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/development/meta/entity/">Entity</a></span> <span class="parameter">npc</span> The NPC entity to configure.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">npcID</span> <span class="optional">optional</span> The NPC's unique identifier.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  lia.dialog.openConfigurationPicker(ent, ent.uniqueID)
</code></pre>
</div>

</div>
</details>

---

