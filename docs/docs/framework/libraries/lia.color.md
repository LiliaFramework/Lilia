        ## lia.color.register(name, color)

        **Description:**
            Registers a named color for later lookup.

        ---

        ### Parameters

            * **name** *(string)*: Key used to reference the color.
            * **color** *(Color)*: Color object or table.

        ---

        ### Returns

            * nil

        ---

        **Realm:**
            Shared

        ---

        ### Example

            ```lua
            ```

        ## lia.color.Adjust(color, rOffset, gOffset, bOffset, aOffset)

        **Description:**
            Creates a new color by applying offsets to each channel.

        ---

        ### Parameters

            * **color** *(Color)*: Base color.
            * **rOffset** *(number)*: Red channel delta.
            * **gOffset** *(number)*: Green channel delta.
            * **bOffset** *(number)*: Blue channel delta.
            * **aOffset** *(number)*: Alpha channel delta (optional).

        ---

        ### Returns

            * Color – Adjusted color.

        ---

        **Realm:**
            Shared

        ---

        ### Example

            ```lua
            ```

        ## lia.color.ReturnMainAdjustedColors()

        **Description:**
            Returns a table of commonly used UI colors derived from the base config color.

        ---

        ### Parameters

            * None

        ---

        ### Returns

            * table – Mapping of UI color keys to Color objects.

        ---

        **Realm:**
            Shared

        ---

        ### Example

            ```lua
            ```

