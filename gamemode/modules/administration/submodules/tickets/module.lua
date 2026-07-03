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
