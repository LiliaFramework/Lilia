if CLIENT then TicketFrames = {} end
MODULE.name = "Tickets"
MODULE.author = "Samael"
MODULE.discord = "@liliaplayer"
MODULE.desc = "Introduces a ticket system where players can submit help requests that staff can view, respond to, and resolve in an organized manner."
MODULE.Privileges = {
    {
        Name = "alwaysSeeTickets",
        ID = "alwaysSeeTickets",
        MinAccess = "superadmin",
        Category = "tickets",
    },
}
