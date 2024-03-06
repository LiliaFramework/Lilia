
net.Receive("liaAuditPanel", function()
    local data = net.ReadTable()
    local panel = vgui.Create("liaAuditPanel")
    panel:populateRows(data)
end)


netstream.Hook("liaReport", function(data) vgui.Create("liaReport"):populate(data) end)

