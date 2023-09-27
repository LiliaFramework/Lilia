--------------------------------------------------------------------------------------------------------
local MODULE = MODULE
--------------------------------------------------------------------------------------------------------
lia.command.add(
    "banooc",
    {
        privilege = "Management - Ban OOC",
        syntax = "<string target>",
        onRun = function(client, arguments)
            local target = lia.command.findPlayer(client, arguments[1])
            if target then
                MODULE.oocBans[target:SteamID()] = true
                client:notify(target:Name() .. " has been banned from OOC.")
            else
                client:notify("Invalid target.")
            end
        end
    }
)

--------------------------------------------------------------------------------------------------------
lia.command.add(
    "unbanooc",
    {
        privilege = "Management - Unban OOC",
        syntax = "<string target>",
        onRun = function(client, arguments)
            local target = lia.command.findPlayer(client, arguments[1])
            if target then
                MODULE.oocBans[target:SteamID()] = nil
                client:notify(target:Name() .. " has been unbanned from OOC.")
            end
        end
    }
)

--------------------------------------------------------------------------------------------------------
lia.command.add(
    "blockooc",
    {
        privilege = "Management - Block OOC",
        syntax = "<string target>",
        onRun = function(client, arguments)
            if GetGlobalBool("oocblocked", false) then
                SetGlobalBool("oocblocked", false)
                client:notify("Unlocked OOC!")
            else
                SetGlobalBool("oocblocked", true)
                client:notify("Blocked OOC!")
            end
        end
    }
)
--------------------------------------------------------------------------------------------------------