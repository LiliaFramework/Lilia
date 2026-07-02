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

# Doors

This page documents the hooks defined by the doors module.

---

<details class="realm-server" id="function-canplayerlock">
<summary><span class="summary-main"><a id="CanPlayerLock"></a>CanPlayerLock(client, door)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/doors/module.lua#L1" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="canplayerlock"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Determines whether a player is allowed to start the key-based door or vehicle locking action.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Doors</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/player/">Player</a></span> <span class="parameter">client</span> The player attempting to lock the target entity.</p>
<p><span class="types"><a class="type" href="/developer/meta/entity/">Entity</a></span> <span class="parameter">door</span> The targeted door, vehicle, or simfphys vehicle.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean|nil</a></span> Return false to block the locking action. Returning nil allows the default permission checks to continue.</p>
</div>

</div>
</details>

---

<details class="realm-server" id="function-canplayerunlock">
<summary><span class="summary-main"><a id="CanPlayerUnlock"></a>CanPlayerUnlock(client, door)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/doors/module.lua#L25" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="canplayerunlock"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Determines whether a player is allowed to start the key-based door or vehicle unlocking action.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Doors</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/player/">Player</a></span> <span class="parameter">client</span> The player attempting to unlock the target entity.</p>
<p><span class="types"><a class="type" href="/developer/meta/entity/">Entity</a></span> <span class="parameter">door</span> The targeted door, vehicle, or simfphys vehicle.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean|nil</a></span> Return false to block the unlocking action. Returning nil allows the default permission checks to continue.</p>
</div>

</div>
</details>

---

<details class="realm-server" id="function-canplayerusedoor">
<summary><span class="summary-main"><a id="CanPlayerUseDoor"></a>CanPlayerUseDoor(client, door)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/doors/module.lua#L49" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="canplayerusedoor"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Determines whether a player may use a door before the module applies its default interaction handling.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Doors</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/player/">Player</a></span> <span class="parameter">client</span> The player trying to use the door.</p>
<p><span class="types"><a class="type" href="/developer/meta/entity/">Entity</a></span> <span class="parameter">door</span> The door entity being used.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean|nil</a></span> Return false to deny the use attempt. Returning nil allows the default door-use flow to continue.</p>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-collectdoordatafields">
<summary><span class="summary-main"><a id="CollectDoorDataFields"></a>CollectDoorDataFields(fields)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/doors/module.lua#L73" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="collectdoordatafields"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Allows plugins or modules to register additional door data fields before default door data is built.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Doors</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">fields</span> Mutable table that should be populated with custom field definitions. Each key should map to field information such as `default` and, when database-backed, `type`.</p>
</div>

</div>
</details>

---

<details class="realm-server" id="function-doorlocktoggled">
<summary><span class="summary-main"><a id="DoorLockToggled"></a>DoorLockToggled(client, door, state)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/doors/module.lua#L93" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="doorlocktoggled"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called after a door or supported vehicle has been locked or unlocked through the keys system.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Doors</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/player/">Player</a></span> <span class="parameter">client</span> The player who triggered the lock state change.</p>
<p><span class="types"><a class="type" href="/developer/meta/entity/">Entity</a></span> <span class="parameter">door</span> The entity whose lock state was changed.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> <span class="parameter">state</span> The new lock state. True means locked and false means unlocked.</p>
</div>

</div>
</details>

---

<details class="realm-client" id="function-filterdoorinfo">
<summary><span class="summary-main"><a id="FilterDoorInfo"></a>FilterDoorInfo(entity, doorData, doorInfo)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/doors/module.lua#L119" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="filterdoorinfo"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Lets clientside code adjust or filter the assembled door information list before it is rendered.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Doors</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/entity/">Entity</a></span> <span class="parameter">entity</span> The door entity currently being inspected.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">doorData</span> The resolved cached door data for the entity.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">doorInfo</span> The mutable list of display entries that will be converted into the door info box text.</p>
</div>

</div>
</details>

---

<details class="realm-client" id="function-getdoorinfo">
<summary><span class="summary-main"><a id="GetDoorInfo"></a>GetDoorInfo(entity, doorData, doorInfo)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/doors/module.lua#L145" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="getdoorinfo"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Populates the clientside door information list that is shown when looking at a visible door.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Doors</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/entity/">Entity</a></span> <span class="parameter">entity</span> The door entity currently being inspected.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">doorData</span> The resolved cached door data for the entity.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">doorInfo</span> The mutable list that should receive formatted door information entries.</p>
</div>

</div>
</details>

---

<details class="realm-client" id="function-getdoorinfoforadminstick">
<summary><span class="summary-main"><a id="GetDoorInfoForAdminStick"></a>GetDoorInfoForAdminStick(target, extraInfo)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/doors/module.lua#L171" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="getdoorinfoforadminstick"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Adds extra clientside admin-stick information lines for a targeted door.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Doors</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/entity/">Entity</a></span> <span class="parameter">target</span> The door entity currently targeted by the admin stick.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">extraInfo</span> The mutable list of additional text lines to append to the admin stick HUD output.</p>
</div>

</div>
</details>

---

<details class="realm-server" id="function-keylock">
<summary><span class="summary-main"><a id="KeyLock"></a>KeyLock(client, door, time)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/doors/module.lua#L194" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="keylock"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called when the keys weapon requests a lock action for a targeted door or supported vehicle.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Doors</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/player/">Player</a></span> <span class="parameter">client</span> The player using the keys weapon.</p>
<p><span class="types"><a class="type" href="/developer/meta/entity/">Entity</a></span> <span class="parameter">door</span> The targeted door, vehicle, or simfphys vehicle.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">time</span> The action duration, in seconds, used for the stared lock interaction.</p>
</div>

</div>
</details>

---

<details class="realm-server" id="function-keyunlock">
<summary><span class="summary-main"><a id="KeyUnlock"></a>KeyUnlock(client, door, time)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/doors/module.lua#L220" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="keyunlock"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called when the keys weapon requests an unlock action for a targeted door or supported vehicle.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Doors</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/player/">Player</a></span> <span class="parameter">client</span> The player using the keys weapon.</p>
<p><span class="types"><a class="type" href="/developer/meta/entity/">Entity</a></span> <span class="parameter">door</span> The targeted door, vehicle, or simfphys vehicle.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">time</span> The action duration, in seconds, used for the stared unlock interaction.</p>
</div>

</div>
</details>

---

<details class="realm-server" id="function-playerusedoor">
<summary><span class="summary-main"><a id="PlayerUseDoor"></a>PlayerUseDoor(client, door)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/doors/module.lua#L246" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="playerusedoor"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Runs after door-use permission checks succeed, allowing modules to override the final use result.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Doors</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/player/">Player</a></span> <span class="parameter">client</span> The player trying to use the door.</p>
<p><span class="types"><a class="type" href="/developer/meta/entity/">Entity</a></span> <span class="parameter">door</span> The door entity being used.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean|nil</a></span> Return a non-nil value to override the final result of the use attempt. Returning nil leaves the default behavior unchanged.</p>
</div>

</div>
</details>

---

<details class="realm-server" id="function-postdoordataload">
<summary><span class="summary-main"><a id="PostDoorDataLoad"></a>PostDoorDataLoad(ent, doorData)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/doors/module.lua#L270" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="postdoordataload"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called after persisted or preset door data is assembled, before it is cached on the entity.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Doors</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/entity/">Entity</a></span> <span class="parameter">ent</span> The door entity receiving the loaded data.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">doorData</span> The resolved door data table about to be cached.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table|nil</a></span> Return a replacement door data table to modify the loaded values, or nil to keep the original table.</p>
</div>

</div>
</details>

---

<details class="realm-server" id="function-predoordatasave">
<summary><span class="summary-main"><a id="PreDoorDataSave"></a>PreDoorDataSave(door, doorData)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/doors/module.lua#L294" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="predoordatasave"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called before cached door data is normalized and written back to persistent storage.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Doors</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Server</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/entity/">Entity</a></span> <span class="parameter">door</span> The door entity whose data is about to be saved.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">doorData</span> The current resolved door data table that will be serialized.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table|nil</a></span> Return a replacement door data table to change what gets saved, or nil to keep the current values.</p>
</div>

</div>
</details>

---

