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

# Admin

Shared administration helpers for usergroup management, privilege registration, permission checks, CAMI synchronization, and admin UI support.

---

<h3 style="margin-bottom: 5px;">Overview</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
This module powers Lilia's admin permission system under `lia.admin`. It manages built-in and custom usergroups, resolves privilege inheritance, integrates with CAMI, synchronizes permission data to clients, provides usergroup editing UI, and executes or routes admin commands depending on realm.
</div>

---

<details class="realm-shared" id="function-getusergroupicon">
<summary><span class="summary-main"><a id="GetUsergroupIcon"></a>GetUsergroupIcon(groupName, groupData, groupOrPlayer)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/administration/admin.lua#L14" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="getusergroupicon"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Allows plugins or modules to override the icon path used for a usergroup in admin-related UI.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string</a></span> <span class="parameter">groupName</span> The normalized usergroup name being resolved.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">groupData</span> <span class="optional">optional</span> The stored group data for the usergroup, if available.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string|Player</a></span> <span class="parameter">groupOrPlayer</span> The original argument passed into `lia.admin.getUsergroupIcon`.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">string|nil</a></span> Return a string icon path to override the default icon resolution. Return nil to continue normal behavior.</p>
</div>

</div>
</details>

---

<details class="realm-shared" id="function-onadminsystemloaded">
<summary><span class="summary-main"><a id="OnAdminSystemLoaded"></a>OnAdminSystemLoaded(groups, privileges)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/administration/admin.lua#L38" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="onadminsystemloaded"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Runs after the admin system finishes loading groups and privileges from storage.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Shared</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">groups</span> The normalized admin usergroup table.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">privileges</span> The rebuilt privilege minimum-access table.</p>
</div>

</div>
</details>

---

<details class="realm-client" id="function-populateadmintabs">
<summary><span class="summary-main"><a id="PopulateAdminTabs"></a>PopulateAdminTabs(pages)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/administration/admin.lua#L58" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="populateadmintabs"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Allows modules to add pages to the admin menu, including the usergroup management panel defined in this file.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">pages</span> The mutable page definition array used to build the admin interface.</p>
</div>

</div>
</details>

---

