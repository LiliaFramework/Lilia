lia.log.types = {
    ["playerConnected"] = {
        func = function(client) return string.format("[%s] %s has connected to the server.", client:SteamID(), client:Name()) end,
        category = "Connection",
        color = Color(52, 152, 219)
    },
    ["playerDisconnected"] = {
        func = function(client) return string.format("[%s] %s has disconnected from the server.", client:SteamID(), client:Name()) end,
        category = "Connection",
        color = Color(52, 152, 219)
    },
    ["spawned_prop"] = {
        func = function(client, model) return string.format("[%s] %s has spawned a prop with model: %s [CharID: %s]", client:SteamID(), client:Name(), model, client:getChar():getID()) end,
        category = "Spawn",
        color = Color(52, 152, 219)
    },
    ["spawned_ragdoll"] = {
        func = function(client, model) return string.format("[%s] %s has spawned a ragdoll with model: %s [CharID: %s]", client:SteamID(), client:Name(), model, client:getChar():getID()) end,
        category = "Spawn",
        color = Color(52, 152, 219)
    },
    ["spawned_effect"] = {
        func = function(client, effect) return string.format("[%s] %s has spawned an effect: %s [CharID: %s]", client:SteamID(), client:Name(), effect, client:getChar():getID()) end,
        category = "Spawn",
        color = Color(52, 152, 219)
    },
    ["spawned_vehicle"] = {
        func = function(client, vehicle, model) return string.format("[%s] %s has spawned a vehicle '%s' with model: %s [CharID: %s]", client:SteamID(), client:Name(), vehicle, model, client:getChar():getID()) end,
        category = "Spawn",
        color = Color(52, 152, 219)
    },
    ["spawned_npc"] = {
        func = function(client, npc, model) return string.format("[%s] %s has spawned an NPC '%s' with model: %s [CharID: %s]", client:SteamID(), client:Name(), npc, model, client:getChar():getID()) end,
        category = "Spawn",
        color = Color(52, 152, 219)
    },
    ["swep_spawning"] = {
        func = function(client, swep) return string.format("[%s] %s has spawned SWEP: %s [CharID: %s]", client:SteamID(), client:Name(), swep, client:getChar():getID()) end,
        category = "SWEP",
        color = Color(52, 152, 219)
    },
    ["chat"] = {
        func = function(client, chatType, message) return string.format("[%s] [%s] %s: %s [CharID: %s]", client:SteamID(), chatType, client:Name(), message, client:getChar():getID()) end,
        category = "Chat",
        color = Color(52, 152, 219)
    },
    ["chatOOC"] = {
        func = function(client, msg) return string.format("[%s] [OOC] %s: %s [CharID: %s]", client:SteamID(), client:Name(), msg, client:getChar():getID()) end,
        category = "Chat",
        color = Color(52, 152, 219)
    },
    ["chatLOOC"] = {
        func = function(client, msg) return string.format("[%s] [LOOC] %s: %s [CharID: %s]", client:SteamID(), client:Name(), msg, client:getChar():getID()) end,
        category = "Chat",
        color = Color(52, 152, 219)
    },
    ["command"] = {
        func = function(client, text) return string.format("[%s] %s used '%s' [CharID: %s]", client:SteamID(), client:Name(), text, client:getChar():getID()) end,
        category = "Chat",
        color = Color(52, 152, 219)
    },
    ["charCreate"] = {
        func = function(client, character) return string.format("[%s] %s created character %s [CharID: %s]", client:SteamID(), client:Name(), character:getName(), character:getID()) end,
        category = "Character",
        color = Color(52, 152, 219)
    },
    ["charLoad"] = {
        func = function(client, name) return string.format("[%s] %s loaded character %s [CharID: %s]", client:SteamID(), client:Name(), name, character:getID()) end,
        category = "Character",
        color = Color(52, 152, 219)
    },
    ["charDelete"] = {
        func = function(client, id) return string.format("[%s] %s deleted character %s [CharID: %s]", IsValid(client) and client:SteamID() or "CONSOLE", IsValid(client) and client:Name() or "CONSOLE", id, IsValid(client) and client:getChar():getID() or "Unknown") end,
        category = "Character",
        color = Color(52, 152, 219)
    },
    ["buydoor"] = {
        func = function(client, price) return string.format("[%s] %s purchased the door for %d [CharID: %s]", client:SteamID(), client:Name(), price, client:getChar():getID()) end,
        category = "Door",
        color = Color(52, 152, 219)
    },
    ["selldoor"] = {
        func = function(client, price) return string.format("[%s] %s sold the door for %d [CharID: %s]", client:SteamID(), client:Name(), price, client:getChar():getID()) end,
        category = "Door",
        color = Color(52, 152, 219)
    },
    ["vendorAccess"] = {
        func = function(client, vendor) return string.format("[%s] %s accessed vendor %s [CharID: %s]", client:SteamID(), client:Name(), vendor, client:getChar():getID()) end,
        category = "Vendor",
        color = Color(52, 152, 219)
    },
    ["vendorExit"] = {
        func = function(client, vendor) return string.format("[%s] %s exited vendor %s [CharID: %s]", client:SteamID(), client:Name(), vendor, client:getChar():getID()) end,
        category = "Vendor",
        color = Color(52, 152, 219)
    },
    ["vendorSell"] = {
        func = function(client, item, vendor) return string.format("[%s] %s sold a %s to %s [CharID: %s]", client:SteamID(), client:Name(), item, vendor, client:getChar():getID()) end,
        category = "Vendor",
        color = Color(52, 152, 219)
    },
    ["vendorBuy"] = {
        func = function(client, item, vendor) return string.format("[%s] %s bought a %s from %s [CharID: %s]", client:SteamID(), client:Name(), item, vendor, client:getChar():getID()) end,
        category = "Vendor",
        color = Color(52, 152, 219)
    },
    ["vendorBuyFail"] = {
        func = function(client, vendor, item) return string.format("[%s] %s tried to buy a %s from %s but it failed. He likely had no space! [CharID: %s]", client:SteamID(), client:Name(), item, vendor, client:getChar():getID()) end,
        category = "Vendor",
        color = Color(52, 152, 219)
    },
    ["itemTake"] = {
        func = function(client, item) return string.format("[%s] %s picked up %s [CharID: %s]", client:SteamID(), client:Name(), item, client:getChar():getID()) end,
        category = "Item",
        color = Color(52, 152, 219)
    },
    ["itemUse"] = {
        func = function(client, item) return string.format("[%s] %s used %s [CharID: %s]", client:SteamID(), client:Name(), item, client:getChar():getID()) end,
        category = "Item",
        color = Color(52, 152, 219)
    },
    ["itemDrop"] = {
        func = function(client, item) return string.format("[%s] %s dropped %s [CharID: %s]", client:SteamID(), client:Name(), item, client:getChar():getID()) end,
        category = "Item",
        color = Color(52, 152, 219)
    },
    ["itemInteraction"] = {
        func = function(client, action, item) return string.format("[%s] %s tried '%s' on item '%s' [CharID: %s]", client:SteamID(), client:Name(), action, item.name, client:getChar():getID()) end,
        category = "Item",
        color = Color(52, 152, 219)
    },
    ["itemEquip"] = {
        func = function(client, item) return string.format("[%s] %s equipped %s [CharID: %s]", client:SteamID(), client:Name(), item, client:getChar():getID()) end,
        category = "Item",
        color = Color(52, 152, 219)
    },
    ["itemUnequip"] = {
        func = function(client, item) return string.format("[%s] %s unequipped %s [CharID: %s]", client:SteamID(), client:Name(), item, client:getChar():getID()) end,
        category = "Item",
        color = Color(52, 152, 219)
    },
    ["money"] = {
        func = function(client, amount) return string.format("[%s] %s's money changed by %d [CharID: %s]", client:SteamID(), client:Name(), amount, client:getChar():getID()) end,
        category = "Character",
        color = Color(52, 152, 219)
    },
    ["moneyGiven"] = {
        func = function(client, name, amount) return string.format("[%s] %s gave %s %s [CharID: %s]", client:SteamID(), client:Name(), name, lia.currency.get(amount), client:getChar():getID()) end,
        category = "Character",
        color = Color(52, 152, 219)
    },
    ["playerHurt"] = {
        func = function(client, attacker, damage, health) return string.format("[%s] %s took %d damage from %s, leaving them at %d health [CharID: %s]", client:SteamID(), client:Name(), damage, attacker, health, client:getChar():getID()) end,
        category = "Damage",
        color = Color(52, 152, 219)
    },
    ["playerDeath"] = {
        func = function(client, attacker) return string.format("[%s] %s was killed by %s [CharID: %s]", client:SteamID(), client:Name(), attacker, client:getChar():getID()) end,
        category = "Death",
        color = Color(52, 152, 219)
    },
    ["toolgunUse"] = {
        func = function(client, tool) return string.format("[%s] %s used toolgun: %s [CharID: %s]", client:SteamID(), client:Name(), tool, client:getChar():getID()) end,
        category = "Toolgun",
        color = Color(52, 152, 219)
    },
    ["invalidNet"] = {
        func = function(client) return string.format("[%s] %s sent invalid net message! [CharID: %s]", client:SteamID(), client:Name(), client:getChar():getID()) end,
        category = "Networking",
        color = Color(52, 152, 219)
    },
    ["charRecognize"] = {
        func = function(client, id, name) return string.format("[%s] %s recognized [%s] as %s [CharID: %s]", client:SteamID(), client:Name(), id, name, client:getChar():getID()) end,
        category = "Recognition",
        color = Color(46, 204, 113)
    },
    ["moneyPickedUp"] = {
        func = function(client, amount) return string.format("[%s] %s picked up %s %s [CharID: %s]", client:SteamID(), client:Name(), lia.currency.get(amount), amount > 1 and lia.currency.plural or lia.currency.singular, client:getChar():getID()) end,
        category = "Money",
        color = Color(52, 152, 219)
    },
}