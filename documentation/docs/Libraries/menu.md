# Menu Library

Interactive 3D context menu system for world and entity interactions in the Lilia framework.

---

Overview

The menu library provides a comprehensive context menu system for the Lilia framework. It enables the creation of interactive context menus that appear in 3D world space or attached to entities, allowing players to interact with objects and perform actions through a visual interface. The library handles menu positioning, animation, collision detection, and user interaction. Menus automatically fade in when the player looks at them and fade out when they look away, with smooth animations and proper range checking. The system supports both world-positioned menus and entity-attached menus with automatic screen space conversion and boundary clamping to ensure menus remain visible and accessible.

---

<details class="realm-client">
<summary><a id=lia.menu.add></a>lia.menu.add(opts, pos, onRemove)</summary>
<a id="liamenuadd"></a>
<p>Adds a new interactive context menu to the system that can be displayed in 3D world space or attached to entities.</p>
<p>Called when creating context menus for world interactions, entity interactions, or any situation requiring a visual menu interface.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">opts</span> A table containing menu options where keys are display text and values are callback functions.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#2.2">Vector or Entity</a></span> <span class="parameter">pos</span> The world position for the menu, or an entity to attach the menu to.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.6">function</a></span> <span class="parameter">onRemove</span> Optional callback function called when the menu is removed.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> The index of the newly added menu in the menu list.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    -- Create a simple menu for an entity
    lia.menu.add({
        ["Open"] = function() print("Opening...") end,
        ["Close"] = function() print("Closing...") end
    }, entity)
    -- Create a world-positioned menu
    lia.menu.add({
        ["Pickup"] = function() print("Picked up!") end
    }, Vector(0, 0, 0))
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=lia.menu.drawAll></a>lia.menu.drawAll()</summary>
<a id="liamenudrawall"></a>
<p>Renders all active context menus on the screen with smooth animations, range checking, and mouse interaction highlighting.</p>
<p>Called every frame during the HUD/rendering phase to draw all active menus. Typically hooked into the drawing system.</p>
<h3>Example Usage:</h3>
<pre><code class="language-lua">    -- Called automatically by the framework's rendering system
    -- Can be manually called if needed for custom rendering setups
    hook.Add("HUDPaint", "DrawMenus", function()
        lia.menu.drawAll()
    end)
</code></pre>
</details>

---

<details class="realm-client">
<summary><a id=lia.menu.getActiveMenu></a>lia.menu.getActiveMenu()</summary>
<a id="liamenugetactivemenu"></a>
<p>Determines which menu item is currently under the mouse cursor and within interaction range.</p>
<p>Called when checking for menu interactions, mouse clicks, or determining which menu option the player is hovering over.</p>
<p><h3>Returns:</h3>
number, function or nil Returns the menu index and the callback function of the active menu item, or nil if no active menu item is found.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    -- Check for menu interactions in a click handler
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
</details>

---

<details class="realm-client">
<summary><a id=lia.menu.onButtonPressed></a>lia.menu.onButtonPressed(id, cb)</summary>
<a id="liamenuonbuttonpressed"></a>
<p>Handles menu button press events by removing the menu and executing the associated callback function.</p>
<p>Called when a menu button is clicked to process the interaction and clean up the menu.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">id</span> The index of the menu to remove from the menu list.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.6">function</a></span> <span class="parameter">cb</span> The callback function to execute when the button is pressed.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> Returns true if a callback was executed, false otherwise.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    -- Handle a menu button press
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
</details>

---

