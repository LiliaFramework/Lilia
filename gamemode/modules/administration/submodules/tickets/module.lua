--[[
    Hooks:
        CreateTicketFrame(requester, message, claimed)

    Purpose:
        Creates the clientside ticket popup frame for a submitted help ticket.

    Category:
        Administration - Tickets

    Parameters:
        requester (Player)
            The player who opened the ticket.

        message (string)
            The submitted ticket text to display.

        claimed (Player)
            The staff member currently assigned to the ticket, when one exists.

    Example Usage:
        ```lua
        hook.Add("CreateTicketFrame", "liaExampleCreateTicketFrame", function(requester, message, claimed)
            if not IsValid(requester) or message == "" then return end
            print(string.format("[MyModule] %s: %s", requester:Name(), message))
        end)
        ```

    Returns:
        Panel|nil
            The created ticket frame when the requester is valid.

    Realm:
        Client
]]
--[[
    Hooks:
        OnTicketClaimed(client, requester, ticketMessage)

    Purpose:
        Called after a staff member claims a ticket.

    Category:
        Administration - Tickets

    Parameters:
        client (Player)
            The staff member who claimed the ticket.

        requester (Player)
            The player who opened the ticket.

        ticketMessage (string)
            The ticket text that was claimed.

    Example Usage:
        ```lua
        hook.Add("OnTicketClaimed", "liaExampleOnTicketClaimed", function(client, requester, ticketMessage)
            if not IsValid(client) or ticketMessage == "" then return end
            print(string.format("[MyModule] %s: %s", client:Name(), ticketMessage))
        end)
        ```

    Returns:
        nil

    Realm:
        Server
]]
--[[
    Hooks:
        OnTicketClosed(client, requester, ticketMessage)

    Purpose:
        Called after a staff member closes a ticket.

    Category:
        Administration - Tickets

    Parameters:
        client (Player)
            The staff member who closed the ticket.

        requester (Player)
            The player who opened the ticket.

        ticketMessage (string)
            The ticket text that was closed.

    Example Usage:
        ```lua
        hook.Add("OnTicketClosed", "liaExampleOnTicketClosed", function(client, requester, ticketMessage)
            if not IsValid(client) or ticketMessage == "" then return end
            print(string.format("[MyModule] %s: %s", client:Name(), ticketMessage))
        end)
        ```

    Returns:
        nil

    Realm:
        Server
]]
--[[
    Hooks:
        OnTicketCreated(client, message)

    Purpose:
        Called after a player creates a new help ticket.

    Category:
        Administration - Tickets

    Parameters:
        client (Player)
            The player who opened the ticket.

        message (string)
            The submitted ticket text.

    Example Usage:
        ```lua
        hook.Add("OnTicketCreated", "liaExampleOnTicketCreated", function(client, message)
            if not IsValid(client) or message == "" then return end
            print(string.format("[MyModule] %s: %s", client:Name(), message))
        end)
        ```

    Returns:
        nil

    Realm:
        Server
]]
--[[
    Hooks:
        TicketSystemClaim(client, requester, ticketMessage)

    Purpose:
        Called when the ticket system processes a claim action and broadcasts the result.

    Category:
        Administration - Tickets

    Parameters:
        client (Player)
            The staff member claiming the ticket.

        requester (Player)
            The player who opened the ticket.

        ticketMessage (string)
            The ticket text being claimed.

    Example Usage:
        ```lua
        hook.Add("TicketSystemClaim", "liaExampleTicketSystemClaim", function(client, requester, ticketMessage)
            if not IsValid(client) or ticketMessage == "" then return end
            print(string.format("[MyModule] %s: %s", client:Name(), ticketMessage))
        end)
        ```

    Returns:
        nil

    Realm:
        Server
]]
--[[
    Hooks:
        TicketSystemClose(client, requester, ticketMessage)

    Purpose:
        Called when the ticket system processes a close action and broadcasts the result.

    Category:
        Administration - Tickets

    Parameters:
        client (Player)
            The staff member closing the ticket.

        requester (Player)
            The player who opened the ticket.

        ticketMessage (string)
            The ticket text being closed.

    Example Usage:
        ```lua
        hook.Add("TicketSystemClose", "liaExampleTicketSystemClose", function(client, requester, ticketMessage)
            if not IsValid(client) or ticketMessage == "" then return end
            print(string.format("[MyModule] %s: %s", client:Name(), ticketMessage))
        end)
        ```

    Returns:
        nil

    Realm:
        Server
]]
--[[
    Hooks:
        GetAllCaseClaims()

    Purpose:
        Retrieves aggregated ticket-claim statistics for staff members.

    Category:
        Administration - Tickets

    Parameters:
        None

    Example Usage:
        ```lua
        hook.Add("GetAllCaseClaims", "liaExampleGetAllCaseClaims", function()
            print("[MyModule] handled GetAllCaseClaims")
        end)
        ```

    Returns:
        Deferred
            Resolves with a table keyed by admin SteamID containing claim totals and last-claim data.

    Realm:
        Server
]]
MODULE.Name = "@tickets"
MODULE.author = "Samael"
MODULE.discord = "@liliaplayer"
MODULE.desc = "@ticketDesc"
MODULE.NetworkStrings = {"liaActiveTickets", "liaClearAllTicketFrames", "liaRequestActiveTickets", "liaRequestTicketsCount", "liaTicketsCount", "liaTicketSystem", "liaTicketSystemClaim", "liaTicketSystemClose", "liaViewClaims",}
MODULE.Privileges = {
    ["alwaysSeeTickets"] = {
        Name = "@alwaysSeeTickets",
        MinAccess = "superadmin",
        Category = "@tickets",
    },
}
