        ## lia.font.register(fontName, fontData)

        **Description:**
            Creates and stores a font using surface.CreateFont for later refresh.

        ---

        ### Parameters

            * **fontName** *(string)*: Font identifier.
            * **fontData** *(table)*: Font properties table.

        ---

        ### Returns

            * None

        ---

        **Realm:**
            Client

        ---

        ### Example

            ```lua
            lia.font.register("MyFont", {font = "Arial", size = 16})
            ```

        ## lia.font.getAvailableFonts()

        **Description:**
            Returns a sorted list of font names that have been registered.

        ---

        ### Parameters

            * None

        ---

        ### Returns

            * table – Array of font name strings.

        ---

        **Realm:**
            Client

        ---

        ### Example

            ```lua
            local fonts = lia.font.getAvailableFonts()
            PrintTable(fonts)
            ```

        ## lia.font.refresh()

        **Description:**
            Recreates all stored fonts. Called when font related config values change.

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
            lia.font.refresh()
            ```

