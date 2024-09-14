concommand.Add("ticketsystem_claimtop", function(client, cmd, args)
    if #MODULE.Aframes > 0 then
        local button = MODULE.Aframes[1]:GetChildren()[10]
        button.DoClick()
    end
end)

concommand.Add("viewclaims", function(pl, cmd, args)
    net.Start("ViewClaims")
    net.WriteString(table.concat(args, ""))
    net.SendToServer()
end)