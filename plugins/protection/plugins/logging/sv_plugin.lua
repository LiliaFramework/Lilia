local L, IsValid = Format, IsValid

lia.log.addType("playerHurt", function(client, attacker, damage, health)
    attacker = tostring(attacker)
    damage = damage or 0
    health = health or 0

    return string.format("%s has taken %d damage from %s, leaving them at %d health.", client:Name(), damage, attacker, health)
end)

lia.log.addType("playerDeath", function(client, ...)
    local data = {...}

    local attacker = data[1] or "unknown"

    return string.format("%s has killed %s.", attacker, client:Name())
end)

lia.log.addType("playerConnected", function(client, ...)
    local data = {...}

    local steamID = data[2]

    return string.format("%s[%s] has connected to the server.", client:Name(), steamID or client:SteamID())
end)

lia.log.addType("playerDisconnected", function(client, ...)
    return string.format("%s[%s] has disconnected from the server.", client:Name(), client:SteamID())
end)

lia.log.addType("itemTake", function(client, ...)
    local data = {...}

    local itemName = data[1] or "unknown"
    local itemCount = data[2] or 1

    return string.format("%s has picked up %dx%s.", client:Name(), itemCount, itemName)
end)

lia.log.addType("itemDrop", function(client, ...)
    local data = {...}

    local itemName = data[1] or "unknown"
    local itemCount = data[2] or 1

    return string.format("%s has lost %dx%s.", client:Name(), itemCount, itemName)
end)

lia.log.addType("money", function(client, ...)
    local data = {...}

    local amount = data[1] or 0

    return string.format("%s's money has changed by %d.", client:Name(), amount)
end)

lia.log.addType("chat", function(client, ...)
    local arg = {...}

    return L("[%s] %s: %s", arg[1], client:Name(), arg[2])
end)

lia.log.addType("command", function(client, ...)
    local arg = {...}

    return L("%s used '%s'", client:Name(), arg[1])
end)

lia.log.addType("charCreate", function(client, ...)
    local arg = {...}

    return L("%s created the character #%s(%s)", client:steamName(), arg[1]:getID(), arg[1]:getName())
end)

lia.log.addType("charLoad", function(client, ...)
    local arg = {...}

    return L("%s loaded the character #%s(%s)", client:steamName(), arg[1], arg[2])
end)

lia.log.addType("charDelete", function(client, ...)
    local arg = {...}

    return L("%s(%s) deleted character (%s)", IsValid(client) and client:steamName() or "COMMAND", IsValid(client) and client:SteamID() or "", arg[1])
end)

lia.log.addType("itemUse", function(client, ...)
    local arg = {...}

    local item = arg[2]

    return L("%s tried '%s' on item '%s'(#%s)", client:Name(), arg[1], item.name, item.id)
end)

lia.log.addType("shipment", function(client, ...)
    local arg = {...}

    return L("%s took '%s' from a shipment", client:Name(), arg[1])
end)

lia.log.addType("shipmentO", function(client, ...)
    local arg = {...}

    return L("%s ordered a shipment", client:Name())
end)

lia.log.addType("buy", function(client, ...)
    local arg = {...}

    return L("%s purchased '%s' from an NPC", client:Name(), arg[1])
end)

lia.log.addType("buydoor", function(client, ...)
    local arg = {...}

    return L("%s purchased the door", client:Name())
end)

lia.log.addType("observerEnter", function(client, ...)
    return string.format("%s has entered observer.", client:Name())
end)

lia.log.addType("observerExit", function(client, ...)
    return string.format("%s has left observer.", client:Name())
end)

function PLUGIN:CharacterLoaded(id)
    local character = lia.char.loaded[id]
    local client = character:getPlayer()
    lia.log.add(client, "charLoad", id, character:getName())
end

function PLUGIN:OnCharacterDelete(client, id)
    lia.log.add(client, "charDelete", id)
end

function PLUGIN:OnCharCreated(client, character)
    lia.log.add(client, "charCreate", character)
end

function PLUGIN:OnTakeShipmentItem(client, itemClass, amount)
    local itemTable = lia.item.list[itemClass]
    lia.log.add(client, "shipment", itemTable.name)
end

function PLUGIN:OnCreateShipment(client, shipmentEntity)
    lia.log.add(client, "shipmentO")
end

function PLUGIN:OnCharTradeVendor(client, vendor, x, y, invID, price, isSell)
end

function PLUGIN:OnPlayerInteractItem(client, action, item)
    if isentity(item) then
        if IsValid(item) then
            local itemID = item.liaItemID
            item = lia.item.instances[itemID]
        else
            return
        end
    elseif isnumber(item) then
        item = lia.item.instances[item]
    end

    if not item then return end
    lia.log.add(client, "itemUse", action, item)
end