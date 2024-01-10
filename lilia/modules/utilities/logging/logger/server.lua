
lia.log.addType(
    "money",
    function(client, ...)
        local data = {...}
        local amount = data[1] or 0
        return string.format("%s's money has changed by %d.", client:Name(), amount)
    end
)


lia.log.addType(
    "playerHurt",
    function(client, attacker, damage, health)
        attacker = tostring(attacker)
        damage = damage or 0
        health = health or 0
        return string.format("%s has taken %d damage from %s, leaving them at %d health.", client:Name(), damage, attacker, health)
    end
)


lia.log.addType(
    "playerDeath",
    function(client, ...)
        local data = {...}
        local attacker = data[1] or "unknown"
        return string.format("%s has killed %s.", attacker, client:Name())
    end
)


lia.log.addType(
    "playerConnected",
    function(client, ...)
        local data = {...}
        local steamID = data[2]
        return string.format("%s[%s] has connected to the server.", client:Name(), steamID or client:SteamID())
    end
)


lia.log.addType("playerDisconnected", function(client, ...) return string.format("%s[%s] has disconnected from the server.", client:Name(), client:SteamID()) end)

