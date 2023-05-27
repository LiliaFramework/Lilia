local PLUGIN = PLUGIN

lia.command.add("viewnotes", {
    onRun = function(client, arguments)
        PLUGIN:openNotes(client, client, false)
    end
})

lia.command.add("adminnotes", {
    adminOnly = true,
    syntax = "<string target>",
    onRun = function(client, arguments)
        local target = lia.command.findPlayer(client, arguments[1])

        if target then
            PLUGIN:openNotes(client, target, true)
        end
    end
})