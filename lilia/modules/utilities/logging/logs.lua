lia.log.types = {
    ["playerConnected"] = {
        func = function(client) return string.format("[%s] %s has connected to the server.", client:SteamID(), client:Name()) end,
        category = "Connection",
        PLogs = "Connections",
        color = Color(52, 152, 219)
    },
    ["playerDisconnected"] = {
        func = function(client) return string.format("[%s] %s has disconnected from the server.", client:SteamID(), client:Name()) end,
        category = "Connection",
        PLogs = "Connections",
        color = Color(52, 152, 219)
    },
    ["spawned_prop"] = {
        func = function(client, model) return string.format("[%s] %s has spawned a prop with model: %s [CharID: %s]", client:SteamID(), client:Name(), model, client:getChar():getID()) end,
        category = "Spawn",
        PLogs = "Props",
        color = Color(52, 152, 219)
    },
    ["spawned_ragdoll"] = {
        func = function(client, model) return string.format("[%s] %s has spawned a ragdoll with model: %s [CharID: %s]", client:SteamID(), client:Name(), model, client:getChar():getID()) end,
        category = "Spawn",
        PLogs = "Props",
        color = Color(52, 152, 219)
    },
    ["spawned_effect"] = {
        func = function(client, effect) return string.format("[%s] %s has spawned an effect: %s [CharID: %s]", client:SteamID(), client:Name(), effect, client:getChar():getID()) end,
        category = "Spawn",
        PLogs = "Props",
        color = Color(52, 152, 219)
    },
    ["spawned_vehicle"] = {
        func = function(client, vehicleName, model) return string.format("[%s] %s has spawned a vehicle '%s' with model: %s [CharID: %s]", client:SteamID(), client:Name(), vehicleName, model, client:getChar():getID()) end,
        category = "Spawn",
        PLogs = "Props",
        color = Color(52, 152, 219)
    },
    ["spawned_npc"] = {
        func = function(client, npcName, model) return string.format("[%s] %s has spawned an NPC '%s' with model: %s [CharID: %s]", client:SteamID(), client:Name(), npcName, model, client:getChar():getID()) end,
        category = "Spawn",
        PLogs = "Props",
        color = Color(52, 152, 219)
    },
    ["swep_spawning"] = {
        func = function(client, swep) return string.format("[%s] %s has spawned SWEP: %s [CharID: %s]", client:SteamID(), client:Name(), swep, client:getChar():getID()) end,
        category = "SWEP",
        PLogs = "Toolgun",
        color = Color(52, 152, 219)
    },
    ["chat"] = {
        func = function(client, chatType, message) return string.format("[%s] [%s] %s: %s", client:SteamID(), chatType, client:Name(), message) end,
        category = "Chat",
        PLogs = "Chat",
        color = Color(52, 152, 219)
    },
    ["chatOOC"] = {
        func = function(client, msg) return string.format("[%s] [OOC] %s: %s", client:SteamID(), client:Name(), msg) end,
        category = "Chat",
        PLogs = "Chat",
        color = Color(52, 152, 219)
    },
    ["chatLOOC"] = {
        func = function(client, msg) return string.format("[%s] [LOOC] %s: %s", client:SteamID(), client:Name(), msg) end,
        category = "Chat",
        PLogs = "Chat",
        color = Color(52, 152, 219)
    },
    ["command"] = {
        func = function(client, text) return string.format("[%s] %s used '%s'", client:SteamID(), client:Name(), text) end,
        category = "Chat",
        PLogs = "Chat",
        color = Color(52, 152, 219)
    },
    ["charCreate"] = {
        func = function(client, character) return string.format("[%s] %s created the character %s [CharID: %s]", client:SteamID(), client:steamName(), character:getID(), character:getName(), client:getChar():getID()) end,
        category = "Character",
        PLogs = "Character",
        color = Color(52, 152, 219)
    },
    ["charLoad"] = {
        func = function(client, name, id) return string.format("[%s] %s loaded the character %s [CharID: %s]", client:SteamID(), client:steamName(), name, id) end,
        category = "Character",
        PLogs = "Character",
        color = Color(52, 152, 219)
    },
    ["charDelete"] = {
        func = function(client, id) return string.format("[%s] %s(%s) deleted character %s [CharID: %s]", IsValid(client) and client:SteamID() or "", IsValid(client) and client:steamName() or "COMMAND", IsValid(client) and client:SteamID() or "", IdleSound(), id) end,
        category = "Character",
        PLogs = "Character",
        color = Color(52, 152, 219)
    },
    ["characterSelect"] = {
        func = function(client, charID, charName) return string.format("[%s] %s selected character %s (%d) [CharID: %s].", client:SteamID(), client:Name(), charName, charID, client:getChar():getID()) end,
        category = "Character",
        PLogs = "Character",
        color = Color(52, 152, 219)
    },
    ["buydoor"] = {
        func = function(client) return string.format("[%s] %s purchased the door [CharID: %s]", client:SteamID(), client:Name(), client:getChar():getID()) end,
        category = "Door",
        PLogs = "Doors",
        color = Color(52, 152, 219)
    },
    ["selldoor"] = {
        func = function(client) return string.format("[%s] %s sold the door [CharID: %s]", client:SteamID(), client:Name(), client:getChar():getID()) end,
        category = "Door",
        PLogs = "Doors",
        color = Color(52, 152, 219)
    },
    ["vendorAccess"] = {
        func = function(client, vendorName) return string.format("[%s] %s has accessed vendor %s [CharID: %s].", client:SteamID(), client:Name(), vendorName, client:getChar():getID()) end,
        category = "Vendor",
        PLogs = "Vendor",
        color = Color(52, 152, 219)
    },
    ["vendorExit"] = {
        func = function(client, vendorName) return string.format("[%s] %s has exited vendor %s [CharID: %s].", client:SteamID(), client:Name(), vendorName, client:getChar():getID()) end,
        category = "Vendor",
        PLogs = "Vendor",
        color = Color(52, 152, 219)
    },
    ["vendorSell"] = {
        func = function(client, itemName, vendorName) return string.format("[%s] %s has sold a %s to %s [CharID: %s].", client:SteamID(), client:Name(), itemName, vendorName, client:getChar():getID()) end,
        category = "Vendor",
        PLogs = "Vendor",
        color = Color(52, 152, 219)
    },
    ["vendorBuy"] = {
        func = function(client, itemName, vendorName) return string.format("[%s] %s has bought a %s from %s [CharID: %s].", client:SteamID(), client:Name(), itemName, vendorName, client:getChar():getID()) end,
        category = "Vendor",
        PLogs = "Vendor",
        color = Color(52, 152, 219)
    },
    ["vendorBuyFail"] = {
        func = function(client, vendorName, itemName) return string.format("[%s] %s has tried to buy a %s from %s. He had no space! [CharID: %s]", client:SteamID(), client:Name(), itemName, vendorName, client:getChar():getID()) end,
        category = "Vendor",
        PLogs = "Vendor",
        color = Color(52, 152, 219)
    },
    ["itemTake"] = {
        func = function(client, itemName) return string.format("[%s] %s has picked up %s [CharID: %s].", client:SteamID(), client:Name(), itemName, client:getChar():getID()) end,
        category = "Item",
        PLogs = "Inventory",
        color = Color(52, 152, 219)
    },
    ["itemUse"] = {
        func = function(client, itemName) return string.format("[%s] %s has used %dx %s [CharID: %s].", client:SteamID(), client:Name(), 1, itemName, client:getChar():getID()) end,
        category = "Item",
        PLogs = "Inventory",
        color = Color(52, 152, 219)
    },
    ["itemDrop"] = {
        func = function(client, itemName) return string.format("[%s] %s has lost %s [CharID: %s].", client:SteamID(), client:Name(), itemName, client:getChar():getID()) end,
        category = "Item",
        PLogs = "Inventory",
        color = Color(52, 152, 219)
    },
    ["itemInteraction"] = {
        func = function(client, action, item) return string.format("[%s] %s tried '%s' on item '%s'(#%s) [CharID: %s].", client:SteamID(), client:Name(), action, item.name, item.id, client:getChar():getID()) end,
        category = "Item",
        PLogs = "Inventory",
        color = Color(52, 152, 219)
    },
    ["itemEquip"] = {
        func = function(client, itemName) return string.format("[%s] %s has equipped %s [CharID: %s].", client:SteamID(), client:Name(), itemName, client:getChar():getID()) end,
        category = "Item",
        PLogs = "Inventory",
        color = Color(52, 152, 219)
    },
    ["itemUnequip"] = {
        func = function(client, itemName) return string.format("[%s] %s has unequipped %s [CharID: %s].", client:SteamID(), client:Name(), itemName, client:getChar():getID()) end,
        category = "Item",
        PLogs = "Inventory",
        color = Color(52, 152, 219)
    },
    ["money"] = {
        func = function(client, amount) return string.format("[%s] %s's money has changed by %d [CharID: %s].", client:SteamID(), client:Name(), amount, client:getChar():getID()) end,
        category = "Character",
        PLogs = "Money",
        color = Color(52, 152, 219)
    },
    ["moneyGiven"] = {
        func = function(client, targetName, amount) return string.format("[%s] %s has given %s %s [CharID: %s].", client:SteamID(), client:Name(), targetName, lia.currency.get(amount), client:getChar():getID()) end,
        category = "Character",
        PLogs = "Money",
        color = Color(52, 152, 219)
    },
    ["playerHurt"] = {
        func = function(client, attacker, damage, health) return string.format("[%s] %s has taken %d damage from %s, leaving them at %d health [CharID: %s].", client:SteamID(), client:Name(), damage, attacker, health, client:getChar():getID()) end,
        category = "Damage",
        PLogs = "Damage",
        color = Color(52, 152, 219)
    },
    ["playerDeath"] = {
        func = function(client, attacker) return string.format("[%s] %s has killed %s [CharID: %s] using %s.", client:SteamID(), client:Name(), client:Name(), client:getChar():getID(), attacker) end,
        category = "Death",
        PLogs = "Kills/Deaths",
        color = Color(52, 152, 219)
    },
    ["toolgunUse"] = {
        func = function(client, tool) return string.format("[%s] %s used toolgun: %s [CharID: %s]", client:SteamID(), client:Name(), tool, client:getChar():getID()) end,
        category = "Toolgun",
        PLogs = "Toolgun",
        color = Color(52, 152, 219)
    },

    ["observerEnter"] = {
        func = function(client) return string.format("[%s] %s has entered observer. [CharID: %s]", client:SteamID(), client:Name(), client:getChar():getID()) end,
        category = "Staff Actions",
        PLogs = "Staff",
        color = Color(52, 152, 219)
    },
    ["observerExit"] = {
        func = function(client) return string.format("[%s] %s has left observer. [CharID: %s]", client:SteamID(), client:Name(), client:getChar():getID()) end,
        category = "Staff Actions",
        PLogs = "Staff",
        color = Color(52, 152, 219)
    },
    ["invalidNet"] = {
        func = function(client) return string.format("[%s] [Net Log] Player %s tried to send invalid net message! [CharID: %s]", client:SteamID(), client:GetName(), client:getChar():getID()) end,
        category = "Networking",
        PLogs = "Network",
        color = Color(52, 152, 219)
    },
    ["charRecognize"] = {
        func = function(clientID, targetID, name) return string.format("[%s] recognized [%s] as %s [CharID: %s]", clientID, targetID, name, client:getChar():getID()) end,
        category = "Recognition",
        PLogs = "Character",
        color = Color(46, 204, 113)
    },
    ["charsetname"] = {
        func = function(adminClientName, targetName, newName) return string.format("[%s] %s changed %s's name to: %s [CharID: %s]", adminClientName, targetName, targetName, newName, client:getChar():getID()) end,
        category = "Character",
        PLogs = "Character",
        color = Color(52, 152, 219)
    },
    ["charsetdesc"] = {
        func = function(adminClientName, targetName, newDescription) return string.format("[%s] %s changed %s's description to: %s [CharID: %s]", adminClientName, targetName, targetName, newDescription, client:getChar():getID()) end,
        category = "Character",
        PLogs = "Character",
        color = Color(52, 152, 219)
    },
    ["charBan"] = {
        func = function(adminClientName, targetName) return string.format("[%s] %s banned character %s [CharID: %s]", adminClientName, targetName, targetName, client:getChar():getID()) end,
        category = "Character",
        PLogs = "Character",
        color = Color(52, 152, 219)
    },
    ["charsetmodel"] = {
        func = function(adminClientName, targetName, newModel, oldModel) return string.format("[%s] %s changed %s's model from %s to %s [CharID: %s]", adminClientName, targetName, targetName, oldModel, newModel, client:getChar():getID()) end,
        category = "Character",
        PLogs = "Character",
        color = Color(52, 152, 219)
    },
    ["charsetbodygroup"] = {
        func = function(adminClientName, targetName, bodyGroupName, newValue, oldValue) return string.format("[%s] %s changed %s's bodygroup %s to %s (was: %s) [CharID: %s]", adminClientName, targetName, targetName, bodyGroupName, newValue, oldValue, client:getChar():getID()) end,
        category = "Character",
        PLogs = "Character",
        color = Color(52, 152, 219)
    },
    ["charsetskin"] = {
        func = function(adminClientName, targetName, newSkin, oldSkin) return string.format("[%s] %s changed %s's skin to %s (was: %s) [CharID: %s]", adminClientName, targetName, targetName, newSkin, oldSkin, client:getChar():getID()) end,
        category = "Character",
        PLogs = "Character",
        color = Color(52, 152, 219)
    },
    ["moneyPickedUp"] = {
        func = function(client, amount) return string.format("[%s] %s has picked up %s %s [CharID: %s].", client:SteamID(), client:Name(), lia.currency.get(amount), amount > 1 and lia.currency.plural or lia.currency.singular, client:getChar():getID()) end,
        category = "Money",
        PLogs = "Money",
        color = Color(52, 152, 219)
    },
    ["roll"] = {
        func = function(client, value) return string.format("%s rolled %d out of 100 [CharID: %s].", client:Name(), value,) end,
        category = "Roll",
        PLogs = "Roll",
        color = Color(52, 152, 219)
    }
}
