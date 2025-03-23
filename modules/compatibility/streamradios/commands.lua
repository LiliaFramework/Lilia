lia.command.add("3dradioclean", {
    superAdminOnly = true,
    privilege = "Clean Radios",
    onRun = function(client)
        local count = 0
        for _, entity in pairs(ents.FindByClass("sent_streamradio")) do
            entity:Remove()
            count = count + 1
        end

        client:notifyLocalized("cleaningFinished", "3D Stream Radios", count)
    end
})
