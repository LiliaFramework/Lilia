        ## lia.notices.notify(message, recipient)

        **Description:**
            Sends a notification message to a specific player or all players.

        ---

        ### Parameters

            * **message** *(string)*: Message text to send.
            * **recipient** *(Player|nil)*: Target player, or nil to broadcast.

        ---

        ### Returns

            * None

        ---

        **Realm:**
            Server

        ---

        ### Example

            ```lua
            ```

        ## lia.notices.notifyLocalized(key, recipient, ...)

        **Description:**
            Sends a localized notification to a player or all players.

        ---

        ### Parameters

            * **key** *(string)*: Localization key.
            * **recipient** *(Player|nil)*: Target player or nil to broadcast.
            * **...** *(any)*: Formatting arguments for the localization string.

        ---

        ### Returns

            * None

        ---

        **Realm:**
            Server

        ---

        ### Example

            ```lua
            ```

        ## lia.notices.notify(message)

        **Description:**
            Creates a visual notification panel on the client's screen.

        ---

        ### Parameters

            * **message** *(string)*: Message text to display.

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

        ## lia.notices.notifyLocalized(key, ...)

        **Description:**
            Displays a localized notification on the client's screen.

        ---

        ### Parameters

            * **key** *(string)*: Localization key.
            * **...** *(any)*: Formatting arguments for the localization string.

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

        ## notification.AddLegacy(text)

        **Description:**
            Overrides Garry's Mod legacy notification to use lia.notices.

        ---

        ### Parameters

            * **text** *(string)*: Message text to display.

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

