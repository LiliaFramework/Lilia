# Menu

Interactive 3D context menu system for world and entity interactions in the Lilia framework.

---

<h3 style="margin-bottom: 5px;">Overview</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
The menu library provides a comprehensive context menu system for the Lilia framework. It enables the creation of interactive context menus that appear in 3D world space or attached to entities, allowing players to interact with objects and perform actions through a visual interface. The library handles menu positioning, animation, collision detection, and user interaction. Menus automatically fade in when the player looks at them and fade out when they look away, with smooth animations and proper range checking. The system supports both world-positioned menus and entity-attached menus with automatic screen space conversion and boundary clamping to ensure menus remain visible and accessible.
</div>

---

<details class="realm-client" id="function-liamenuadd">
<summary><a id="lia.menu.add"></a>lia.menu.add(opts, pos, onRemove)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liamenuadd"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Adds a new interactive context menu to the system that can be displayed in 3D world space or attached to entities.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called when creating context menus for world interactions, entity interactions, or any situation requiring a visual menu interface.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">table</a></span> <span class="parameter">opts</span> A table containing menu options where keys are display text and values are callback functions.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Vector or Entity</a></span> <span class="parameter">pos</span> The world position for the menu, or an entity to attach the menu to.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">function</a></span> <span class="parameter">onRemove</span> Optional callback function called when the menu is removed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> The index of the newly added menu in the menu list.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  -- Create a simple menu for an entity
  lia.menu.add({
      ["Open"] = function() print("Opening...") end,
      ["Close"] = function() print("Closing...") end
  }, entity)
  -- Create a world-positioned menu
  lia.menu.add({
      ["Pickup"] = function() print("Picked up!") end
  }, Vector(0, 0, 0))
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-liamenudrawall">
<summary><a id="lia.menu.drawAll"></a>lia.menu.drawAll()</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liamenudrawall"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Renders all active context menus on the screen with smooth animations, range checking, and mouse interaction highlighting.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called every frame during the HUD/rendering phase to draw all active menus. Typically hooked into the drawing system.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  -- Called automatically by the framework's rendering system
  -- Can be manually called if needed for custom rendering setups
  hook.Add("HUDPaint", "DrawMenus", function()
      lia.menu.drawAll()
  end)
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-liamenugetactivemenu">
<summary><a id="lia.menu.getActiveMenu"></a>lia.menu.getActiveMenu()</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liamenugetactivemenu"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Determines which menu item is currently under the mouse cursor and within interaction range.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called when checking for menu interactions, mouse clicks, or determining which menu option the player is hovering over.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p>number, function or nil Returns the menu index and the callback function of the active menu item, or nil if no active menu item is found.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  -- Check for menu interactions in a click handler
  local menuIndex, callback = lia.menu.getActiveMenu()
  if menuIndex and callback then
      lia.menu.onButtonPressed(menuIndex, callback)
  end
  -- Check if player is hovering over a menu
  local activeMenu = lia.menu.getActiveMenu()
  if activeMenu then
      -- Player is hovering over a menu item
  end
</code></pre>
</div>

</div>
</details>

---

<details class="realm-client" id="function-liamenuonbuttonpressed">
<summary><a id="lia.menu.onButtonPressed"></a>lia.menu.onButtonPressed(id, cb)</summary>
<div class="details-content">
<h3 style="margin-bottom: 5px; font-weight: 700;"><a id="liamenuonbuttonpressed"></a>Purpose</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Handles menu button press events by removing the menu and executing the associated callback function.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">When Called</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
  <p>Called when a menu button is clicked to process the interaction and clean up the menu.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Parameters</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">number</a></span> <span class="parameter">id</span> The index of the menu to remove from the menu list.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">function</a></span> <span class="parameter">cb</span> The callback function to execute when the button is pressed.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Returns</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.1">boolean</a></span> Returns true if a callback was executed, false otherwise.</p>
</div>

<h3 style="margin-bottom: 5px; font-weight: 700;">Example Usage</h3>
<div style="margin-left: 20px; margin-bottom: 20px;">
<pre><code class="language-lua">  -- Handle a menu button press
  local menuIndex, callback = lia.menu.getActiveMenu()
  if menuIndex then
      local success = lia.menu.onButtonPressed(menuIndex, callback)
      if success then
          print("Menu action executed successfully")
      end
  end
  -- Remove a menu without executing callback
  lia.menu.onButtonPressed(specificMenuId)
</code></pre>
</div>

</div>
</details>

---

