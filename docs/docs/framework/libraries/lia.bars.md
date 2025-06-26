        ## lia.bar.get(identifier)

        **Description:**
            Retrieves a bar object from the list by its unique identifier.

        ---

        ### Parameters

            * **identifier** *(string)*: The unique identifier of the bar to retrieve.

        ---

        ### Returns

            * table or nil – The bar table if found, or nil if not found.

        ---

        **Realm:**
            Client

        ---

        ### Example

            ```lua
            local bar = lia.bar.get("health")
            ```

        ## lia.bar.add(getValue, color, priority, identifier)

        **Description:**
            Adds a new bar or replaces an existing one in the bar list.
If the identifier matches an existing bar, the old bar is removed first.
Bars are drawn in order of ascending priority.

        ---

        ### Parameters

            * **getValue** *(function)*: A callback that returns the current value of the bar.
            * **color** *(Color)*: The fill color for the bar. Defaults to a random pastel color.
            * **priority** *(number)*: Determines drawing order; lower values draw first. Defaults to end of list.
            * **identifier** *(string)*: Optional unique identifier for the bar.

        ---

        ### Returns

            * number – The priority assigned to the added bar.

        ---

        **Realm:**
            Client

        ---

        ### Example

            ```lua
            lia.bar.add(function() return 1 end, Color(255,0,0), 1, "example")
            ```

        ## lia.bar.remove(identifier)

        **Description:**
            Removes a bar from the list based on its unique identifier.

        ---

        ### Parameters

            * **identifier** *(string)*: The unique identifier of the bar to remove.

        ---

        ### Returns

            * None

        ---

        **Realm:**
            Client

        ---

        ### Example

            ```lua
            lia.bar.remove("example")
            ```

        ## lia.bar.drawBar(x, y, w, h, pos, max, color)

        **Description:**
            Draws a single horizontal bar at the specified screen coordinates,
filling it proportionally based on pos and max.

        ---

        ### Parameters

            * **x** *(number)*: The x-coordinate of the bar's top-left corner.
            * **y** *(number)*: The y-coordinate of the bar's top-left corner.
            * **w** *(number)*: The total width of the bar (including padding).
            * **h** *(number)*: The total height of the bar.
            * **pos** *(number)*: The current value to display (will be clamped to max).
            * **max** *(number)*: The maximum possible value for the bar.
            * **color** *(Color)*: The color to fill the bar.

        ---

        ### Returns

            * None

        ---

        **Realm:**
            Client

        ---

        ### Example

            ```lua
            lia.bar.drawBar(10, 10, 200, 20, 0.5, 1, Color(255,0,0))
            ```

        ## lia.bar.drawAction(text, duration)

        **Description:**
            Displays a temporary action progress bar with accompanying text
for the specified duration on the HUD.

        ---

        ### Parameters

            * **text** *(string)*: The text to display above the progress bar.
            * **duration** *(number)*: Duration in seconds for which the bar is displayed.

        ---

        ### Returns

            * None

        ---

        **Realm:**
            Client

        ---

        ### Example

            ```lua
            lia.bar.drawAction("Reloading", 2)
            ```

        ## lia.bar.drawAll()

        **Description:**
            Iterates through all registered bars, applies smoothing to their values,
and draws them on the HUD according to their priority and visibility rules.

        ---

        ### Parameters

            * None

        ---

        ### Returns

            * None

        ---

        **Realm:**
            Client

        ---

        ### Example

            ```lua
            hook.Add("HUDPaintBackground", "liaBarDraw", lia.bar.drawAll)
            ```

