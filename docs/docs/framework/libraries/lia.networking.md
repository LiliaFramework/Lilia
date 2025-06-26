        ## setNetVar(key, value, receiver)

        **Description:**
            Stores a global network variable and broadcasts the new value
to clients via the "gVar" netstream message.

        ---

        ### Parameters

            * **key** *(string)*: The unique identifier for the variable.
            * **value** *(any)*: Value to assign. Functions and nested functions
            * are disallowed.
            * **receiver** *(Player or table)*: Optional receiver(s) for the update.
            * Pass nil to broadcast to everyone.

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

        ## getNetVar(key, default)

        **Description:**
            Returns the value of a global network variable previously set
with setNetVar.

        ---

        ### Parameters

            * **key** *(string)*: Name of the variable to read.
            * **default** *(any)*: Value returned when the variable is nil.

        ---

        ### Returns

            * any – The stored value or the provided default.

        ---

        **Realm:**
            Shared

        ---

        ### Example

            ```lua
            ```

        ## getNetVar(key, default)

        **Description:**
            Client-side access to global variables synchronized from the server.

        ---

        ### Parameters

            * **key** *(string)*: Name of the variable to read.
            * **default** *(any)*: Value returned when the variable is nil.

        ---

        ### Returns

            * any – The stored value or the provided default.

        ---

        **Realm:**
            Client

        ---

        ### Example

            ```lua
            ```

        ## playerMeta.getLocalVar(key, default)

        **Description:**
            Alias for entityMeta.getNetVar available on the client. This
allows code written for entities to work directly on the local
player object.

        ---

        ### Parameters

            * **key** *(string)*: Name of the variable to read.
            * **default** *(any)*: Value returned when the variable is nil.

        ---

        ### Returns

            * any – The stored value or the provided default.

        ---

        **Realm:**
            Client

        ---

        ### Example

            ```lua
            ```

