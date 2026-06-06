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
