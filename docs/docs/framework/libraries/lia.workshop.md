        ## lia.workshop.gather()

        **Description:**
            Collects workshop IDs from installed addons and registered modules.

        ---

        ### Parameters

            None

        ---

        ### Returns

            * **ids** *(table)*: Table of workshop IDs to download.

        ---

        **Realm:**
            Server

        ---

        ### Example

            ```lua
            ```

        ## lia.workshop.send(ply)

        **Description:**
            Sends the collected workshop IDs to a connecting player.

        ---

        ### Parameters

            * **ply** *(Player)*: Player to send the download list to.

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

        ## hook.Add("PlayerInitialSpawn")

        **Description:**
            Sends the workshop download list shortly after a player connects
if automatic downloads are enabled.

        ---

        ### Parameters

            * **ply** *(Player)*: Player that joined the server.

        ---

        ### Returns

            None

        ---

        **Realm:**
            Server

        ---

        ### Example

            ```lua
            ```

        ## net.Receive("WorkshopDownloader_Start")

        **Description:**
            Receives a list of workshop addon IDs and begins downloading
them on the client.

        ---

        ### Parameters

            None

        ---

        ### Returns

            None

        ---

        **Realm:**
            Client

        ---

        ### Example

            ```lua
            ```

        ## workshop_force_redownload console command

        **Description:**
            Forces all workshop addons to be downloaded again.

        ---

        ### Parameters

            None

        ---

        ### Returns

            None

        ---

        **Realm:**
            Client

        ---

        ### Example

            ```lua
            ```

        ## hook.Add("CreateInformationButtons")

        **Description:**
            Adds a page to the information menu listing all automatically
downloaded workshop addons.

        ---

        ### Parameters

            * **pages** *(table)*: Table of existing menu pages.

        ---

        ### Returns

            None

        ---

        **Realm:**
            Client

        ---

        ### Example

            ```lua
            ```

