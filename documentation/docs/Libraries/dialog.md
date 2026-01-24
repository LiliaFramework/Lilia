# Dialog Library

Comprehensive NPC dialog management system for the Lilia framework.

---

Overview

The dialog library provides comprehensive functionality for managing NPC conversations and dialog systems in the Lilia framework. It handles NPC registration, conversation filtering, client synchronization, and provides both server-side data management and client-side UI interactions. The library supports complex conversation trees with conditional options, server-only callbacks, and dynamic NPC customization. It includes automatic data sanitization, conversation filtering based on player permissions, and seamless integration with the framework's networking system. The library ensures secure and efficient dialog handling across both server and client realms.

---

<details class="realm-shared">
<summary><a id=lia.dialog.isTableEqual></a>lia.dialog.isTableEqual(tbl1, tbl2, checked)</summary>
<a id="liadialogistableequal"></a>
<p>Performs a deep comparison of two tables to detect changes, avoiding infinite loops from circular references.</p>
<p>Before syncing dialog data to clients to prevent unnecessary network traffic.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">tbl1</span> First table to compare.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">tbl2</span> Second table to compare.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">checked</span> <span class="optional">optional</span> Internal table used to track visited references and prevent cycles.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> True if tables are identical, false otherwise.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    if not lia.dialog.isTableEqual(oldData, newData) then
        lia.dialog.syncDialogs()
    end
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.dialog.registerConfiguration></a>lia.dialog.registerConfiguration(uniqueID, data)</summary>
<a id="liadialogregisterconfiguration"></a>
<p>Registers or updates an NPC configuration entry for customization panels.</p>
<p>During gamemode initialization to define available NPC configuration options.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">uniqueID</span> Unique identifier for the configuration.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">data</span> Configuration data containing fields like name, order, shouldShow, onOpen, onApply, etc.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> The stored configuration table.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.dialog.registerConfiguration("shop_inventory", {
        name = "Shop Inventory",
        order = 5,
        shouldShow = function(ply) return ply:IsAdmin() end,
        onOpen = function(npc) OpenShopConfig(npc) end
    })
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.dialog.getConfiguration></a>lia.dialog.getConfiguration(uniqueID)</summary>
<a id="liadialoggetconfiguration"></a>
<p>Retrieves a registered configuration entry by its unique identifier.</p>
<p>When accessing configuration menus or checking configuration availability.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">uniqueID</span> The unique identifier of the configuration to retrieve.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table|nil</a></span> The configuration table if found, nil otherwise.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local cfg = lia.dialog.getConfiguration("appearance")
    if cfg and cfg.shouldShow(LocalPlayer()) then
        cfg.onOpen(npc)
    end
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=lia.dialog.getNPCData></a>lia.dialog.getNPCData(npcID)</summary>
<a id="liadialoggetnpcdata"></a>
<p>Retrieves sanitized NPC dialog data by unique identifier.</p>
<p>Server-side when preparing dialog data for clients or internal operations.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">npcID</span> The unique identifier of the NPC dialog.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table|nil</a></span> Sanitized NPC dialog data, or nil if not found.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local npcData = lia.dialog.getNPCData("tutorial_guide")
    if npcData then PrintTable(npcData) end
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=lia.dialog.getOriginalNPCData></a>lia.dialog.getOriginalNPCData(npcID)</summary>
<a id="liadialoggetoriginalnpcdata"></a>
<p>Returns the original unsanitized NPC dialog definition including server-only callbacks.</p>
<p>Server-side when re-filtering conversation options per-player or rebuilding client payloads.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">npcID</span> The unique identifier of the NPC dialog.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table|nil</a></span> Original NPC dialog data, or nil if not found.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local raw = lia.dialog.getOriginalNPCData("tutorial_guide")
    if raw and raw.Conversation then
        -- inspect server-only callbacks before sanitizing
    end
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=lia.dialog.syncToClients></a>lia.dialog.syncToClients(client)</summary>
<a id="liadialogsynctoclients"></a>
<p>Sends sanitized dialog data to a specific client or all connected players.</p>
<p>After dialog registration, changes, or on-demand admin refreshes.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> <span class="optional">optional</span> Specific player to sync to, or nil to broadcast to all players.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    concommand.Add("lia_dialog_resync", function(admin)
        if IsValid(admin) and admin:IsAdmin() then
            lia.dialog.syncToClients()
            admin:notifyLocalized("dialogResynced")
        end
    end)
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=lia.dialog.syncDialogs></a>lia.dialog.syncDialogs()</summary>
<a id="liadialogsyncdialogs"></a>
<p>Broadcasts all dialog data to all connected clients.</p>
<p>After bulk changes, during scheduled refreshes, or maintenance operations.</p>
<h3>Example Usage:</h3>
<pre><code class="language-lua">    timer.Create("ResyncDialogsHourly", 3600, 0, lia.dialog.syncDialogs)
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=lia.dialog.registerNPC></a>lia.dialog.registerNPC(uniqueID, data, shouldSync)</summary>
<a id="liadialogregisternpc"></a>
<p>Registers an NPC dialog definition and optionally synchronizes changes to clients.</p>
<p>During gamemode initialization or when hot-loading NPC dialog data.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">uniqueID</span> Unique identifier for the NPC dialog.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">data</span> Complete NPC dialog definition including Conversation, PrintName, Greeting, etc.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> <span class="parameter">shouldSync</span> <span class="optional">optional</span> Whether to sync changes to clients immediately (defaults to true).</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> True if successfully registered, false otherwise.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.dialog.registerNPC("quests_barkeep", {
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
</details>

---

<details class="realm-server">
<summary><a id=lia.dialog.openDialog></a>lia.dialog.openDialog(client, npc, npcID)</summary>
<a id="liadialogopendialog"></a>
<p>Opens an NPC dialog for a player, filtering conversation options based on player permissions.</p>
<p>When a player interacts with an NPC entity.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> The player to open the dialog for.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Entity">Entity</a></span> <span class="parameter">npc</span> The NPC entity being interacted with.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">npcID</span> The unique identifier of the NPC dialog type.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    hook.Add("PlayerUse", "HandleDialogNPCs", function(ply, ent)
        if ent:GetClass() == "lia_npc" then
            lia.dialog.openDialog(ply, ent, ent.uniqueID or "tutorial_guide")
            return false
        end
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=lia.dialog.getNPCData></a>lia.dialog.getNPCData(npcID)</summary>
<a id="liadialoggetnpcdata"></a>
<p>Retrieves sanitized NPC dialog data on the client.</p>
<p>When client UI needs to render or access dialog information.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">npcID</span> The unique identifier of the NPC dialog.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table|nil</a></span> Sanitized NPC dialog data, or nil if not found.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local data = lia.dialog.getNPCData("tutorial_guide")
    if data then print("Greeting:", data.Greeting) end
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=lia.dialog.submitConfiguration></a>lia.dialog.submitConfiguration(configID, npc, payload)</summary>
<a id="liadialogsubmitconfiguration"></a>
<p>Sends NPC customization data to the server for processing.</p>
<p>When submitting changes from NPC customization UI.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">configID</span> The configuration identifier.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Entity">Entity</a></span> <span class="parameter">npc</span> The NPC entity being customized.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">payload</span> The customization data payload.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.dialog.submitConfiguration("appearance", npc, {model = "models/barney.mdl"})
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=lia.dialog.openCustomizationUI></a>lia.dialog.openCustomizationUI(npc, configID)</summary>
<a id="liadialogopencustomizationui"></a>
<p>Opens a comprehensive UI for customizing NPC appearance, animations, and dialog types.</p>
<p>From properties menu or configuration picker interfaces.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Entity">Entity</a></span> <span class="parameter">npc</span> The NPC entity to customize.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">configID</span> <span class="optional">optional</span> Configuration identifier, defaults to "appearance".</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    properties.Add("CustomNPCConfig", {
        Filter = function(_, ent) return ent:GetClass() == "lia_npc" end,
        Action = function(_, ent) lia.dialog.openCustomizationUI(ent, "appearance") end
    })
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.dialog.getAvailableConfigurations></a>lia.dialog.getAvailableConfigurations(ply, npc, npcID)</summary>
<a id="liadialoggetavailableconfigurations"></a>
<p>Returns available NPC configurations for a player, sorted by order and name.</p>
<p>Before displaying configuration picker UI to filter accessible options.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">ply</span> The player to check permissions for.</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Entity">Entity</a></span> <span class="parameter">npc</span> <span class="optional">optional</span> The NPC entity being configured.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">npcID</span> <span class="optional">optional</span> The NPC's unique identifier.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> Array of accessible configuration tables.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    local configs = lia.dialog.getAvailableConfigurations(LocalPlayer(), npc, npc.uniqueID)
    for _, cfg in ipairs(configs) do print("Config:", cfg.id) end
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.dialog.openConfigurationPicker></a>lia.dialog.openConfigurationPicker(npc, npcID)</summary>
<a id="liadialogopenconfigurationpicker"></a>
<p>Opens the NPC configuration picker UI, prioritizing appearance configuration.</p>
<p>When a player selects "Configure NPC" from the properties menu.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Entity">Entity</a></span> <span class="parameter">npc</span> The NPC entity to configure.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">npcID</span> <span class="optional">optional</span> The NPC's unique identifier.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    lia.dialog.openConfigurationPicker(ent, ent.uniqueID)
</code></pre>
</details>

---

