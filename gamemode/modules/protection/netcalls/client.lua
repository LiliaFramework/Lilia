local MODULE = MODULE
net.Receive("liaVerifyCheats", function()
    MODULE:VerifyCheats()
    net.Start("liaVerifyCheatsResponse")
    net.SendToServer()
end)

lia.net.readBigTable("liaEntityTabData", function(payload)
    MODULE.entityTabRequestPending = false
    MODULE.entityTabData = istable(payload) and payload or {
        owners = {},
        totalEntities = 0
    }
    lia.debug(
        "[Entity Tab Debug]",
        "receivedServerPayload=true",
        "owners=", tostring(istable(MODULE.entityTabData.owners) and #MODULE.entityTabData.owners or 0),
        "totalEntities=", tostring(MODULE.entityTabData.totalEntities or 0)
    )
    if IsValid(MODULE.entityTabPanel) and isfunction(MODULE.populateEntityTabPanel) then MODULE:populateEntityTabPanel(MODULE.entityTabPanel) end
end)
