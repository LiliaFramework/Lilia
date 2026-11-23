MODULE.Name = "Tickets"
MODULE.author = "Samael"
MODULE.discord = "liliaplayer"
MODULE.desc = "Sends a support ticket to staff."
MODULE.NetworkStrings = {"liaClearAllTicketFrames", "liaTicketSystem", "liaTicketSystemClaim", "liaTicketSystemClose",}
MODULE.Privileges = {
    ["alwaysSeeTickets"] = {
        Name = "Always See Tickets",
        MinAccess = "superadmin",
        Category = "Tickets",
    },
}
