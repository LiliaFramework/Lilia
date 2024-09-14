concommand.Add("ticketsystem_claimtop", function()
    if #MODULE.Aframes > 0 then
        local button = MODULE.Aframes[1]:GetChildren()[10]
        button.DoClick()
    end
end)

concommand.Add("viewclaims", function(_, _, args)
    net.Start("ViewClaims")
    net.WriteString(table.concat(args, ""))
    net.SendToServer()
end)