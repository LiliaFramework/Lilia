lia.command.add("cleardecals", {
    adminOnly = true,
    privilege = "Clear Decals",
    onRun = function() end
})

lia.command.add("playtime", {
    adminOnly = false,
    onRun = function() end
})

concommand.Add("ticketsystem_claimtop", function()
    if #TicketFrames > 0 then
        local button = TicketFrames[1]:GetChildren()[10]
        button.DoClick()
    end
end)

concommand.Add("viewclaims", function(_, _, args)
    net.Start("ViewClaims")
    net.WriteString(table.concat(args, ""))
    net.SendToServer()
end)