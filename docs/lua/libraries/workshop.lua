    --[[
        lia.workshop.gather()

        Description:
            Collects workshop IDs from installed addons and registered modules.

        Realm:
            Server

        Returns:
            ids (table) – Table of workshop IDs to download.

        Example Usage:
        -- [[ Example of how to use this function ]]
            local ids = lia.workshop.gather()
    ]]

    --[[
        lia.workshop.send(ply)

        Description:
            Sends the collected workshop IDs to a connecting player.

        Parameters:
            ply (Player) – Player to send the download list to.

        Realm:
            Server

        Returns:
            None

        Example Usage:
        -- [[ Example of how to use this function ]]
            lia.workshop.send(ply)
    ]]
