lia.command.add("banooc", {
    syntax = "<string target>",
    onRun = function(client, arguments)
        local target = lia.command.findPlayer(client, arguments[1])

        if not client:IsSuperAdmin() then
            client:notify("Your rank is not high enough to use this command.")

            return false
        end

        if target then
            MODULE.oocBans[target:SteamID()] = true
            client:notify(target:Name() .. " has been banned from OOC.")
        else
            client:notify("Invalid target.")
        end
    end
})

lia.command.add("unbanooc", {
    syntax = "<string target>",
    onRun = function(client, arguments)
        local target = lia.command.findPlayer(client, arguments[1])

        if not client:IsSuperAdmin() then
            client:notify("Your rank is not high enough to use this command.")

            return false
        end

        if target then
            MODULE.oocBans[target:SteamID()] = nil
            client:notify(target:Name() .. " has been unbanned from OOC.")
        end
    end
})

lia.command.add("blockooc", {
    syntax = "<string target>",
    onRun = function(client, arguments)
        if not client:IsSuperAdmin() then
            client:notify("Your rank is not high enough to use this command.")

            return false
        end

        if GetGlobalBool("oocblocked", false) then
            SetGlobalBool("oocblocked", false)
            client:notify("Unlocked OOC!")
        else
            SetGlobalBool("oocblocked", true)
            client:notify("Blocked OOC!")
        end
    end
})