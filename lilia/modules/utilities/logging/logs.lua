lia.log.types = {
    ["playerConnected"] = {
        func = function(client) return string.format("[%s] %s has connected to the server.", client:SteamID(), client:Name()) end,
        category = "Connection Logs",
        color = Color(52, 152, 219)
    },
    ["playerDisconnected"] = {
        func = function(client) return string.format("[%s] %s has disconnected from the server.", client:SteamID(), client:Name()) end,
        category = "Connection Logs",
        color = Color(52, 152, 219)
    },
    ["spawned_prop"] = {
        func = function(client, model) return string.format("[%s] %s has spawned a prop with model: %s", client:SteamID(), client:Name(), model) end,
        category = "Spawn Logs",
        color = Color(52, 152, 219)
    },
    ["spawned_ragdoll"] = {
        func = function(client, model) return string.format("[%s] %s has spawned a ragdoll with model: %s", client:SteamID(), client:Name(), model) end,
        category = "Spawn Logs",
        color = Color(52, 152, 219)
    },
    ["spawned_effect"] = {
        func = function(client, effect) return string.format("[%s] %s has spawned an effect: %s", client:SteamID(), client:Name(), effect) end,
        category = "Spawn Logs",
        color = Color(52, 152, 219)
    },
    ["spawned_vehicle"] = {
        func = function(client, vehicleName, model) return string.format("[%s] %s has spawned a vehicle '%s' with model: %s", client:SteamID(), client:Name(), vehicleName, model) end,
        category = "Spawn Logs",
        color = Color(52, 152, 219)
    },
    ["spawned_npc"] = {
        func = function(client, npcName, model) return string.format("[%s] %s has spawned an NPC '%s' with model: %s", client:SteamID(), client:Name(), npcName, model) end,
        category = "Spawn Logs",
        color = Color(52, 152, 219)
    },

    ["swep_spawning"] = {
        func = function(client, swep) return string.format("[%s] %s has spawned SWEP: %s", client:SteamID(), client:Name(), swep) end,
        category = "SWEP Logs",
        color = Color(52, 152, 219)
    },
    ["chat"] = {
        func = function(client, chatType, message) return string.format("[%s] [%s] %s: %s", client:SteamID(), chatType, client:Name(), message) end,
        category = "Chat Logs",
        color = Color(52, 152, 219)
    },
    ["chatOOC"] = {
        func = function(client, msg) return string.format("[%s] [OOC] %s: %s", client:SteamID(), client:Name(), msg) end,
        category = "Chat Logs",
        color = Color(52, 152, 219)
    },
    ["chatLOOC"] = {
        func = function(client, msg) return string.format("[%s] [LOOC] %s: %s", client:SteamID(), client:Name(), msg) end,
        category = "Chat Logs",
        color = Color(52, 152, 219)
    },
    ["command"] = {
        func = function(client, text) return string.format("[%s] %s used '%s'", client:SteamID(), client:Name(), text) end,
        category = "Chat Logs",
        color = Color(52, 152, 219)
    },
    ["charCreate"] = {
        func = function(client, character) return string.format("[%s] %s created the character #%s(%s)", client:SteamID(), client:steamName(), character:getID(), character:getName()) end,
        category = "Character Management Logs",
        color = Color(52, 152, 219)
    },
    ["charLoad"] = {
        func = function(client, id, name) return string.format("[%s] %s loaded the character #%s(%s)", client:SteamID(), client:steamName(), id, name) end,
        category = "Character Management Logs",
        color = Color(52, 152, 219)
    },
    ["charDelete"] = {
        func = function(client, id) return string.format("[%s] %s(%s) deleted character (%s)", IsValid(client) and client:SteamID() or "", IsValid(client) and client:steamName() or "COMMAND", IsValid(client) and client:SteamID() or "", IdleSound()) end,
        category = "Character Management Logs",
        color = Color(52, 152, 219)
    },
    ["characterSelect"] = {
        func = function(client, charID, charName) return string.format("[%s] %s selected character %s(%d).", client:SteamID(), client:Name(), charName, charID) end,
        category = "Character Management Logs",
        color = Color(52, 152, 219)
    },
    ["buydoor"] = {
        func = function(client) return string.format("[%s] %s purchased the door", client:SteamID(), client:Name()) end,
        category = "Door Logs",
        color = Color(52, 152, 219)
    },
    ["selldoor"] = {
        func = function(client) return string.format("[%s] %s sold the door", client:SteamID(), client:Name()) end,
        category = "Door Logs",
        color = Color(52, 152, 219)
    },
    ["vendorAccess"] = {
        func = function(client, vendorName) return string.format("[%s] %s has accessed vendor %s.", client:SteamID(), client:Name(), vendorName) end,
        category = "Vendor Logs",
        color = Color(52, 152, 219)
    },
    ["vendorExit"] = {
        func = function(client, vendorName) return string.format("[%s] %s has exited vendor %s.", client:SteamID(), client:Name(), vendorName) end,
        category = "Vendor Logs",
        color = Color(52, 152, 219)
    },
    ["vendorSell"] = {
        func = function(client, itemName, vendorName) return string.format("[%s] %s has sold a %s to %s.", client:SteamID(), client:Name(), itemName, vendorName) end,
        category = "Vendor Logs",
        color = Color(52, 152, 219)
    },
    ["vendorBuy"] = {
        func = function(client, itemName, vendorName) return string.format("[%s] %s has bought a %s from %s.", client:SteamID(), client:Name(), itemName, vendorName) end,
        category = "Vendor Logs",
        color = Color(52, 152, 219)
    },
    ["vendorBuyFail"] = {
        func = function(client, vendorName, itemName) return string.format("[%s] %s has tried to buy a %s from %s. He had no space!", client:SteamID(), client:Name(), itemName, vendorName) end,
        category = "Vendor Logs",
        color = Color(52, 152, 219)
    },
    ["itemTake"] = {
        func = function(client, itemName) return string.format("[%s] %s has picked up %s.", client:SteamID(), client:Name(), itemName) end,
        category = "Item Logs",
        color = Color(52, 152, 219)
    },
    ["itemUse"] = {
        func = function(client, itemName) return string.format("[%s] %s has used %dx%s.", client:SteamID(), client:Name(), itemName) end,
        category = "Item Logs",
        color = Color(52, 152, 219)
    },
    ["itemDrop"] = {
        func = function(client, itemName) return string.format("[%s] %s has lost %s.", client:SteamID(), client:Name(), itemName) end,
        category = "Item Logs",
        color = Color(52, 152, 219)
    },
    ["itemInteraction"] = {
        func = function(client, action, item) return string.format("[%s] %s tried '%s' on item '%s'(#%s)", client:SteamID(), client:Name(), action, item.name, item.id) end,
        category = "Item Logs",
        color = Color(52, 152, 219)
    },
    ["itemEquip"] = {
        func = function(client, itemName) return string.format("[%s] %s has equipped %s.", client:SteamID(), client:Name(), itemName) end,
        category = "Item Logs",
        color = Color(52, 152, 219)
    },
    ["itemUnequip"] = {
        func = function(client, itemName) return string.format("[%s] %s has unequipped %s.", client:SteamID(), client:Name(), itemName) end,
        category = "Item Logs",
        color = Color(52, 152, 219)
    },
    ["money"] = {
        func = function(client, amount) return string.format("[%s] %s's money has changed by %d.", client:SteamID(), client:Name(), amount) end,
        category = "Character Logs",
        color = Color(52, 152, 219)
    },
    ["moneyGiven"] = {
        func = function(client, targetName, amount) return string.format("[%s] %s has given %s %s.", client:SteamID(), client:Name(), targetName, lia.currency.get(amount)) end,
        category = "Character Logs",
        color = Color(52, 152, 219)
    },
    ["playerHurt"] = {
        func = function(client, attacker, damage, health) return string.format("[%s] %s has taken %d damage from %s, leaving them at %d health.", client:SteamID(), client:Name(), damage, attacker, health) end,
        category = "Damage Logs",
        color = Color(52, 152, 219)
    },
    ["playerDeath"] = {
        func = function(client, attacker) return string.format("[%s] %s has killed %s.", client:SteamID(), attacker, client:Name()) end,
        category = "Death Logs",
        color = Color(52, 152, 219)
    },
    ["toolgunUse"] = {
        func = function(client, tool) return string.format("[%s] %s[%s](%s) used toolgun: %s", client:SteamID(), client:Name(), client:SteamID(), client:CharID(), tool) end,
        category = "Toolgun Logs",
        color = Color(52, 152, 219)
    },
    ["unpersistedEntity"] = {
        func = function(client, entity) return string.format("[%s] %s has removed persistence from '%s'.", client:SteamID(), client:Name(), entity) end,
        category = "Staff Logs",
        color = Color(52, 152, 219)
    },
    ["persistedEntity"] = {
        func = function(client, entity) return string.format("[%s] %s has persisted '%s'.", client:SteamID(), client:Name(), entity) end,
        category = "Staff Logs",
        color = Color(52, 152, 219)
    },
    ["observerEnter"] = {
        func = function(client) return string.format("[%s] %s has entered observer.", client:SteamID(), client:Name()) end,
        category = "Staff Logs",
        color = Color(52, 152, 219)
    },
    ["observerExit"] = {
        func = function(client) return string.format("[%s] %s has left observer.", client:SteamID(), client:Name()) end,
        category = "Staff Logs",
        color = Color(52, 152, 219)
    },
    ["invalidNet"] = {
        func = function(client) return string.format("[%s] [Net Log] Player %s tried to send invalid net message!", client:SteamID(), client:GetName()) end,
        category = "Network Logs",
        color = Color(52, 152, 219)
    },
    ["charRecognize"] = {
        func = function(clientID, targetID, name) return string.format("[%s] recognized [%s] as %s", clientID, targetID, name) end,
        category = "Recognition Logs",
        color = Color(46, 204, 113)
    },
    ["charsetname"] = {
        func = function(adminClientName, targetName, newName) return string.format("[%s] %s changed %s's name to: %s", adminClientName, targetName, targetName, newName) end,
        category = "Character Management Logs",
        color = Color(52, 152, 219)
    },
    ["charsetdesc"] = {
        func = function(adminClientName, targetName, newDescription) return string.format("[%s] %s changed %s's description to: %s", adminClientName, targetName, targetName, newDescription) end,
        category = "Character Management Logs",
        color = Color(52, 152, 219)
    },
    ["charBan"] = {
        func = function(adminClientName, targetName) return string.format("[%s] %s banned character %s", adminClientName, targetName, targetName) end,
        category = "Character Management Logs",
        color = Color(52, 152, 219)
    },
    ["charsetmodel"] = {
        func = function(adminClientName, targetName, newModel, oldModel) return string.format("[%s] %s changed %s's model from %s to %s", adminClientName, targetName, targetName, oldModel, newModel) end,
        category = "Character Management Logs",
        color = Color(52, 152, 219)
    },
    ["charsetbodygroup"] = {
        func = function(adminClientName, targetName, bodyGroupName, newValue, oldValue) return string.format("[%s] %s changed %s's bodygroup %s to %s (was: %s)", adminClientName, targetName, targetName, bodyGroupName, newValue, oldValue) end,
        category = "Character Management Logs",
        color = Color(52, 152, 219)
    },
    ["charsetskin"] = {
        func = function(adminClientName, targetName, newSkin, oldSkin) return string.format("[%s] %s changed %s's skin to %s (was: %s)", adminClientName, targetName, targetName, newSkin, oldSkin) end,
        category = "Character Management Logs",
        color = Color(52, 152, 219)
    }
}