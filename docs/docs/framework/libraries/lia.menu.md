        ## menu.add(opts, pos, onRemove)

        **Description:**
            Creates an on-screen interaction menu from a table of label/callback
pairs. The menu can be anchored to a world position or entity and will
call the optional onRemove callback when it disappears.

        ---

        ### Parameters

            * **opts** *(table)*: Key/value pairs where the key is the option text and the
            * value is the function to execute when selected.
            * **pos** *(Vector or Entity)*: World position of the menu or entity to attach
            * it to.
            * **onRemove** *(function)*: Called when the menu entry is removed (optional).

        ---

        ### Returns

            * number – The index of the newly inserted menu entry.

        ---

        **Realm:**
            Client

        ---

        ### Example

            ```lua
            ```

        ## menu.drawAll()

        **Description:**
            Draws all active menus and their options each frame. Menus fade in when
looked at and fade out when the player looks away or moves out of range.

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
            ```

        ## menu.getActiveMenu()

        **Description:**
            Checks if the player is hovering over a menu option within interaction
range and returns the menu index and callback for that option.

        ---

        ### Parameters

            * None

        ---

        ### Returns

            * **index** *(number)*: The position of the active menu in the list.
            * **callback** *(function)*: The function associated with the hovered option.

        ---

        **Realm:**
            Client

        ---

        ### Example

            ```lua
            ```

        ## menu.onButtonPressed(id, cb)

        **Description:**
            Removes the menu at the given index and executes its callback if
provided. Returns true when a callback was run.

        ---

        ### Parameters

            * **id** *(number)*: Index of the menu entry in the list.
            * **cb** *(function)*: Callback to execute for the selected option.

        ---

        ### Returns

            * boolean – Whether a callback was invoked.

        ---

        **Realm:**
            Client

        ---

        ### Example

            ```lua
            ```

