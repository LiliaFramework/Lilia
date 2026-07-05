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

# View

Clientside view helpers for world-space model previews, preview camera control, and temporary entity hiding.

---

<h3 style="margin-bottom: 5px;">Overview</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
The view library centralizes world-space preview behavior under `lia.view`. It can start and stop a preview session for a panel owner, spawn and manage a clientside model, rotate that model, expose the active preview entity, and temporarily hide players or entities while the preview is active.
</div>

---

<details class="realm-client" id="function-liaviewshouldhideplayer">
<summary><span class="summary-main"><a id="lia.view.shouldHidePlayer"></a>lia.view.shouldHidePlayer(player)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/view.lua#L169" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liaviewshouldhideplayer"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Checks whether a player should be skipped while the active preview is hiding selected players.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/player/">Player</a></span> <span class="parameter">player</span> The player being considered for drawing.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> True when the player is part of the active preview's hidden player set.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local previewOwner = lia.view.activeOwner
  if IsValid(previewOwner) and lia.view.shouldHidePlayer(LocalPlayer()) then
      chat.AddText(Color(255, 200, 0), "The active preview is hiding the local player.")
  end
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-liaviewclose">
<summary><span class="summary-main"><a id="lia.view.close"></a>lia.view.close(owner)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/view.lua#L195" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liaviewclose"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Stops a preview session, removes its clientside model, restores hidden entities, and unregisters preview hooks.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/panel/">Panel</a></span> <span class="parameter">owner</span> The panel or owner object that started the preview session.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local panel = vgui.Create("EditablePanel")
  lia.view.begin(panel, {hideEntities = {LocalPlayer()}})
  lia.view.close(panel)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-liaviewbegin">
<summary><span class="summary-main"><a id="lia.view.begin"></a>lia.view.begin(owner, config)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/view.lua#L252" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liaviewbegin"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Starts a world-space preview session for an owner and configures temporary draw suppression for the supplied entities.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/panel/">Panel</a></span> <span class="parameter">owner</span> The panel or owner object that controls the preview lifecycle.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">config</span> Preview configuration such as hidden entities, camera offsets, preview position, and context data.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local panel = vgui.Create("EditablePanel")
  lia.view.begin(panel, {
      hideEntities = {LocalPlayer()},
      position = LocalPlayer():GetPos() + Vector(64, 0, 8),
      angle = Angle(0, LocalPlayer():EyeAngles().y + 180, 0)
  })
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-liaviewsetmodel">
<summary><span class="summary-main"><a id="lia.view.setModel"></a>lia.view.setModel(owner, modelPath, options)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/view.lua#L382" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liaviewsetmodel"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Creates or replaces the clientside preview model for an owner and applies the supplied appearance options.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/panel/">Panel</a></span> <span class="parameter">owner</span> The panel or owner object that owns the preview session.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">modelPath</span> The model path to preview.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">options</span> Appearance and context options such as skin, bodygroups, angle, position, and hidden entities.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local panel = vgui.Create("EditablePanel")
  lia.view.setModel(panel, LocalPlayer():GetModel(), {
      position = LocalPlayer():GetPos() + Vector(64, 0, 8),
      bodygroups = {[1] = 0}
  })
  lia.view.rotate(panel, 30)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-liaviewgetentity">
<summary><span class="summary-main"><a id="lia.view.getEntity"></a>lia.view.getEntity(owner)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/view.lua#L434" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liaviewgetentity"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Returns the current clientside preview entity for an owner.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/panel/">Panel</a></span> <span class="parameter">owner</span> The panel or owner object that owns the preview session.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/entity/">Entity|nil</a></span> The active clientside preview model, or nil when no preview is active.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local panel = vgui.Create("EditablePanel")
  local previewEntity = lia.view.getEntity(panel)
  if IsValid(previewEntity) then
      previewEntity:SetSkin(1)
      previewEntity:SetCycle(0)
  end
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-liaviewrotate">
<summary><span class="summary-main"><a id="lia.view.rotate"></a>lia.view.rotate(owner, deltaYaw)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/view.lua#L461" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liaviewrotate"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Rotates the current preview entity around its yaw axis.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/panel/">Panel</a></span> <span class="parameter">owner</span> The panel or owner object that owns the preview session.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">deltaYaw</span> The yaw delta to apply in degrees.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  local panel = vgui.Create("EditablePanel")
  lia.view.rotate(panel, 15)
  lia.view.rotate(panel, 15)
</code></pre>
</div>

</div>
</details>

---

<h2 style="margin-bottom: 5px;">Hooks</h2>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p>Library-specific hooks documented for this library.</p>
</div>

---

<details class="realm-client" id="function-modifycharactermodel">
<summary><span class="summary-main"><a id="ModifyCharacterModel"></a>ModifyCharacterModel(entity, contextOrCharacter)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/view.lua#L44" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="modifycharactermodel"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Allows code to adjust a preview model after its base model, skin, and bodygroups have been applied for character creation or character selection scenes.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Main Menu</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/entity/">Entity</a></span> <span class="parameter">entity</span> The clientside model entity being displayed.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table|Character</a></span> <span class="parameter">contextOrCharacter</span> <span class="optional">optional</span> Either the creation context table, the loaded character being previewed, or nil when no extra context is supplied.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("ModifyCharacterModel", "liaExampleModifyCharacterModel", function(entity, contextOrCharacter)
      entity:SetAngles(Angle(0, 180, 0))
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-setupplayermodel">
<summary><span class="summary-main"><a id="SetupPlayerModel"></a>SetupPlayerModel(entity, character)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/core/libraries/view.lua#L14" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="setupplayermodel"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Allows code to configure a clientside player preview model after it is spawned but before character-specific appearance tweaks are applied.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Main Menu</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/entity/">Entity</a></span> <span class="parameter">entity</span> The clientside model entity being prepared for preview.</p>
<p><span class="types"><a class="type" href="/developer/libraries/char/">Character</a></span> <span class="parameter">character</span> <span class="optional">optional</span> An optional loaded character when the preview is built from character selection data.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("SetupPlayerModel", "liaExampleSetupPlayerModel", function(entity, character)
      entity:SetCycle(0)
  end)
</code></pre>
</div>

</div>
</details>

---

