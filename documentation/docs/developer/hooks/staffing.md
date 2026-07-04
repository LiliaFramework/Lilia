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

# Staffing

This page documents hooks in the staffing category.

---

<details class="realm-client" id="function-adminstickaddmodels">
<summary><span class="summary-main"><a id="AdminStickAddModels"></a>AdminStickAddModels(modList)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/administration/submodules/adminstick/module.lua#L1" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="adminstickaddmodels"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Allows clientside code to add extra model entries to the admin stick model picker.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Staffing</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">modList</span> The mutable list of model definitions shown by the admin stick UI.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("AdminStickAddModels", "liaExampleAdminStickAddModels", function(modList)
      print("[MyModule] handled AdminStickAddModels")
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-onadminstickmenuclosed">
<summary><span class="summary-main"><a id="OnAdminStickMenuClosed"></a>OnAdminStickMenuClosed()</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/administration/submodules/adminstick/module.lua#L28" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="onadminstickmenuclosed"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called after the admin stick menu closes.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Staffing</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OnAdminStickMenuClosed", "liaExampleOnAdminStickMenuClosed", function()
      print("[MyModule] handled OnAdminStickMenuClosed")
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-openadminstickui">
<summary><span class="summary-main"><a id="OpenAdminStickUI"></a>OpenAdminStickUI(target)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/administration/submodules/adminstick/module.lua#L54" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="openadminstickui"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called when the admin stick requests its management UI for a target entity.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Staffing</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/entity/">Entity</a></span> <span class="parameter">target</span> The entity targeted by the admin stick.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("OpenAdminStickUI", "liaExampleOpenAdminStickUI", function(target)
      if not IsValid(target) then return end
      print(string.format("[MyModule] handled OpenAdminStickUI for %s", target:Name()))
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-populateadminstick">
<summary><span class="summary-main"><a id="PopulateAdminStick"></a>PopulateAdminStick(currentMenu, currentTarget, currentStores)</span><a class="source-link-button source-link-button--summary" href="https://github.com/LiliaFramework/Lilia/blob/main/gamemode/modules/administration/submodules/adminstick/module.lua#L82" target="_blank" rel="noopener noreferrer" onclick="event.stopPropagation()">View Source</a></summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="populateadminstick"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Allows clientside code to add option groups to the admin stick menu for the current target.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Category</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Staffing</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Realm</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Client</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="/developer/meta/panel/">Panel</a></span> <span class="parameter">currentMenu</span> The admin stick menu panel being populated.</p>
<p><span class="types"><a class="type" href="/developer/meta/entity/">Entity</a></span> <span class="parameter">currentTarget</span> The entity currently targeted by the admin stick.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">currentStores</span> The mutable list of grouped admin stick menu entries.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  hook.Add("PopulateAdminStick", "liaExamplePopulateAdminStick", function(currentMenu, currentTarget, currentStores)
      if not IsValid(currentMenu) then return end
      currentMenu:SetTooltip("PopulateAdminStick handled by MyModule")
  end)
</code></pre>
</div>

</div>
</details>

---

