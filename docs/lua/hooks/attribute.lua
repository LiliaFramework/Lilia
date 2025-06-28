--[[
    This file documents ATTRIBUTE functions defined within the codebase.

    Generated automatically.
]]

--[[
        OnSetup(client, value)

        Description:
            Runs custom logic when the attribute initializes on a player.
            Typically called after character load or when the attribute value changes.

        Parameters:
            client (Player) – Player owning the character.
            value (number) – Current attribute value.

        Realm:
            Shared

        Returns:
            None

        Example Usage:
            -- Notify the player if their attribute level is high.
            function ATTRIBUTE:OnSetup(client, value)
                if value > 5 then
                    client:ChatPrint("You are very Strong!")
                end
            end
]]
