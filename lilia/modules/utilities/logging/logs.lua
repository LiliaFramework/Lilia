lia.log.addType("chat", function(client, ...)
    local arg = {...}
    return string.format("[%s] %s: %s", arg[1], client:Name(), arg[2])
end, "Chat Logs")

lia.log.addType("command", function(client, ...)
    local arg = {...}
    return string.format("%s used '%s'", client:Name(), arg[1])
end, "Chat Logs")

lia.log.addType("charCreate", function(client, ...)
    local arg = {...}
    return string.format("%s created the character #%s(%s)", client:steamName(), arg[1]:getID(), arg[1]:getName())
end, "Character Management Logs")

lia.log.addType("charLoad", function(client, ...)
    local arg = {...}
    return string.format("%s loaded the character #%s(%s)", client:steamName(), arg[1], arg[2])
end, "Character Management Logs")

lia.log.addType("charDelete", function(client, ...)
    local arg = {...}
    return string.format("%s(%s) deleted character (%s)", IsValid(client) and client:steamName() or "COMMAND", IsValid(client) and client:SteamID() or "", arg[1])
end, "Character Management Logs")

lia.log.addType("buy", function(client, ...)
    local arg = {...}
    return string.format("%s purchased '%s' from an NPC", client:Name(), arg[1])
end, "Vendor Logs")

lia.log.addType("itemTake", function(client, ...)
    local data = {...}
    local itemName = data[1] or "unknown"
    local itemCount = data[2] or 1
    return string.format("%s has picked up %dx%s.", client:Name(), itemCount, itemName)
end, "Item Logs")

lia.log.addType("itemDrop", function(client, ...)
    local data = {...}
    local itemName = data[1] or "unknown"
    local itemCount = data[2] or 1
    return string.format("%s has lost %dx%s.", client:Name(), itemCount, itemName)
end, "Item Logs")

lia.log.addType("itemUse", function(client, ...)
    local arg = {...}
    local item = arg[2]
    return string.format("%s tried '%s' on item '%s'(#%s)", client:Name(), arg[1], item.name, item.id)
end, "Item Logs")

lia.log.addType("vendorAccess", function(client, ...)
    local data = {...}
    local vendorName = data[1] or "unknown"
    return string.format("%s has accessed vendor %s.", client:Name(), vendorName)
end, "Vendor Logs")

lia.log.addType("vendorExit", function(client, ...)
    local data = {...}
    local vendorName = data[1] or "unknown"
    return string.format("%s has exited vendor %s.", client:Name(), vendorName)
end, "Vendor Logs")

lia.log.addType("vendorSell", function(client, ...)
    local data = {...}
    local vendorName = data[1] or "unknown"
    local itemName = data[2] or "unknown"
    return string.format("%s has sold a %s to %s.", client:Name(), itemName, vendorName)
end, "Vendor Logs")

lia.log.addType("vendorBuy", function(client, ...)
    local data = {...}
    local vendorName = data[1] or "unknown"
    local itemName = data[2] or "unknown"
    return string.format("%s has bought a %s from %s.", client:Name(), itemName, vendorName)
end, "Vendor Logs")

lia.log.addType("vendorBuyFail", function(client, ...)
    local data = {...}
    local vendorName = data[1] or "unknown"
    local itemName = data[2] or "unknown"
    return string.format("%s has tried to buy a %s from %s. He had no space!", client:Name(), itemName, vendorName)
end, "Vendor Logs")

lia.log.addType("money", function(client, ...)
    local data = {...}
    local amount = data[1] or 0
    return string.format("%s's money has changed by %d.", client:Name(), amount)
end, "Character Logs")

lia.log.addType("playerHurt", function(client, attacker, damage, health)
    attacker = tostring(attacker)
    damage = damage or 0
    health = health or 0
    return string.format("%s has taken %d damage from %s, leaving them at %d health.", client:Name(), damage, attacker, health)
end, "Damage Logs")

lia.log.addType("playerDeath", function(client, ...)
    local data = {...}
    local attacker = data[1] or "unknown"
    return string.format("%s has killed %s.", attacker, client:Name())
end, "Death Logs")

lia.log.addType("playerConnected", function(client, ...)
    local data = {...}
    local steamID = data[2]
    return string.format("%s[%s] has connected to the server.", client:Name(), steamID or client:SteamID())
end, "Connection Logs")

lia.log.addType("spawned_ent", function(client, group, class, hasName, entityName, entityModel) return string.format("%s has spawned a %s with class %s and %s: %s", client:Name(), group, class, hasName and "Name" or "Model", hasName and entityName or entityModel) end, "Spawn Logs")
lia.log.addType("moneyGiven", function(client, targetName, amount) return string.format("%s has given %s %s.", client:Name(), targetName, lia.currency.get(amount)) end, "Character Logs")
lia.log.addType("moneyGivenTAB", function(client, targetName, amount) return string.format("%s has given %s %s using TAB.", client:Name(), targetName, lia.currency.get(amount)) end, "Character Logs")
lia.log.addType("playerDisconnected", function(client, ...) return string.format("%s[%s] has disconnected from the server.", client:Name(), client:SteamID()) end, "Connection Logs")
lia.log.addType("unpersistedEntity", function(client, entity) return string.format("%s has removed persistence from '%s'.", client:Name(), entity) end, "Staff Logs")
lia.log.addType("persistedEntity", function(client, entity) return string.format("%s has persisted '%s'.", client:Name(), entity) end, "Staff Logs")
lia.log.addType("observerEnter", function(client, ...) return string.format("%s has entered observer.", client:Name()) end, "Staff Logs")
lia.log.addType("observerExit", function(client, ...) return string.format("%s has left observer.", client:Name()) end, "Staff Logs")
lia.log.addType("buydoor", function(client, ...) return string.format("%s purchased the door", client:Name()) end, "Character Logs")
lia.log.addType("selldoor", function(client, ...) return string.format("%s sold the door", client:Name()) end, "Character Logs")
lia.log.addType("net", function(client, messageName) return string.format("[Net Log] Player %s (%s) sent net message %s.", client:GetName(), client:SteamID(), messageName) end, "Network Logs")
lia.log.addType("invalidNet", function(client) return string.format("[Net Log] Player %s (%s) tried to send invalid net message!", client:GetName(), client:SteamID()) end, "Network Logs")
lia.log.addType("concommand", function(client, cmd, argStr) return string.format("[ConCommand Log] Player %s (%s) ran command %s with arguments: %s.", client:GetName(), client:SteamID(), cmd, argStr) end, "Command Logs")
