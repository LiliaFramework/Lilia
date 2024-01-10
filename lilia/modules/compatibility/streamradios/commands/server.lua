
lia.command.add(
    "3dradioclean",
    {
        superAdminOnly = true,
        syntax = "<string name>",
        privilege = "Ban Characters",
        onRun = function(client)
            for _, ent in pairs(ents.FindByClass("sent_streamradio")) do
                ent:Remove()
            end

            client:notify("Cleanup done")
        end
    }
)

