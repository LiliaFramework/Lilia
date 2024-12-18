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
        category = "Spawn & Entity",
        color = Color(52, 152, 219)
    },
    ["spawned_ragdoll"] = {
        func = function(client, model) return string.format("[%s] %s has spawned a ragdoll with model: %s [CharID: %s]", client:SteamID(), client:Name(), model, client:getChar():getID()) end,
        category = "Spawn & Entity",
        color = Color(52, 152, 219)
    },
    ["spawned_effect"] = {
        func = function(client, effect) return string.format("[%s] %s has spawned an effect: %s [CharID: %s]", client:SteamID(), client:Name(), effect, client:getChar():getID()) end,
        category = "Spawn & Entity",
        color = Color(52, 152, 219)
    },
    ["spawned_vehicle"] = {
        func = function(client, vehicle, model) return string.format("[%s] %s has spawned a vehicle '%s' with model: %s [CharID: %s]", client:SteamID(), client:Name(), vehicle, model, client:getChar():getID()) end,
        category = "Spawn & Entity",
        color = Color(52, 152, 219)
    },
    ["spawned_npc"] = {
        func = function(client, npc, model) return string.format("[%s] %s has spawned an NPC '%s' with model: %s [CharID: %s]", client:SteamID(), client:Name(), npc, model, client:getChar():getID()) end,
        category = "Spawn & Entity",
        color = Color(52, 152, 219)
    },
    ["swep_spawning"] = {
        func = function(client, swep) return string.format("[%s] %s has spawned SWEP: %s [CharID: %s]", client:SteamID(), client:Name(), swep, client:getChar():getID()) end,
        category = "Spawn & Entity",
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
        func = function(client, name) return string.format("[%s] %s loaded character %s [CharID: %s]", client:SteamID(), client:Name(), name, client:getChar():getID()) end,
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
        category = "Financial & Vendor",
        color = Color(52, 152, 219)
    },
    ["selldoor"] = {
        func = function(client, price) return string.format("[%s] %s sold the door for %d [CharID: %s]", client:SteamID(), client:Name(), price, client:getChar():getID()) end,
        category = "Financial & Vendor",
        color = Color(52, 152, 219)
    },
    ["vendorAccess"] = {
        func = function(client, vendor) return string.format("[%s] %s accessed vendor %s [CharID: %s]", client:SteamID(), client:Name(), vendor, client:getChar():getID()) end,
        category = "Financial & Vendor",
        color = Color(52, 152, 219)
    },
    ["vendorExit"] = {
        func = function(client, vendor) return string.format("[%s] %s exited vendor %s [CharID: %s]", client:SteamID(), client:Name(), vendor, client:getChar():getID()) end,
        category = "Financial & Vendor",
        color = Color(52, 152, 219)
    },
    ["vendorSell"] = {
        func = function(client, item, vendor) return string.format("[%s] %s sold a %s to %s [CharID: %s]", client:SteamID(), client:Name(), item, vendor, client:getChar():getID()) end,
        category = "Financial & Vendor",
        color = Color(52, 152, 219)
    },
    ["vendorBuy"] = {
        func = function(client, item, vendor) return string.format("[%s] %s bought a %s from %s [CharID: %s]", client:SteamID(), client:Name(), item, vendor, client:getChar():getID()) end,
        category = "Financial & Vendor",
        color = Color(52, 152, 219)
    },
    ["vendorBuyFail"] = {
        func = function(client, vendor, item) return string.format("[%s] %s tried to buy a %s from %s but it failed. He likely had no space! [CharID: %s]", client:SteamID(), client:Name(), item, vendor, client:getChar():getID()) end,
        category = "Financial & Vendor",
        color = Color(52, 152, 219)
    },
    ["itemTake"] = {
        func = function(client, item) return string.format("[%s] %s picked up %s [CharID: %s]", client:SteamID(), client:Name(), item, client:getChar():getID()) end,
        category = "Item & Inventory",
        color = Color(52, 152, 219)
    },
    ["itemUse"] = {
        func = function(client, item) return string.format("[%s] %s used %s [CharID: %s]", client:SteamID(), client:Name(), item, client:getChar():getID()) end,
        category = "Item & Inventory",
        color = Color(52, 152, 219)
    },
    ["itemDrop"] = {
        func = function(client, item) return string.format("[%s] %s dropped %s [CharID: %s]", client:SteamID(), client:Name(), item, client:getChar():getID()) end,
        category = "Item & Inventory",
        color = Color(52, 152, 219)
    },
    ["itemInteraction"] = {
        func = function(client, action, item) return string.format("[%s] %s tried '%s' on item '%s' [CharID: %s]", client:SteamID(), client:Name(), action, item.name, client:getChar():getID()) end,
        category = "Item & Inventory",
        color = Color(52, 152, 219)
    },
    ["itemEquip"] = {
        func = function(client, item) return string.format("[%s] %s equipped %s [CharID: %s]", client:SteamID(), client:Name(), item, client:getChar():getID()) end,
        category = "Item & Inventory",
        color = Color(52, 152, 219)
    },
    ["itemUnequip"] = {
        func = function(client, item) return string.format("[%s] %s unequipped %s [CharID: %s]", client:SteamID(), client:Name(), item, client:getChar():getID()) end,
        category = "Item & Inventory",
        color = Color(52, 152, 219)
    },
    ["money"] = {
        func = function(client, amount) return string.format("[%s] %s's money changed by %d [CharID: %s]", client:SteamID(), client:Name(), amount, client:getChar():getID()) end,
        category = "Financial & Vendor",
        color = Color(52, 152, 219)
    },
    ["moneyGiven"] = {
        func = function(client, name, amount) return string.format("[%s] %s gave %s %s [CharID: %s]", client:SteamID(), client:Name(), name, lia.currency.get(amount), client:getChar():getID()) end,
        category = "Financial & Vendor",
        color = Color(52, 152, 219)
    },
    ["playerHurt"] = {
        func = function(client, attacker, damage, health) return string.format("[%s] %s took %d damage from %s, leaving them at %d health [CharID: %s]", client:SteamID(), client:Name(), damage, attacker, health, client:getChar():getID()) end,
        category = "Combat",
        color = Color(52, 152, 219)
    },
    ["playerDeath"] = {
        func = function(client, attacker) return string.format("[%s] %s was killed by %s [CharID: %s]", client:SteamID(), client:Name(), attacker, client:getChar():getID()) end,
        category = "Combat",
        color = Color(52, 152, 219)
    },
    ["toolgunUse"] = {
        func = function(client, tool) return string.format("[%s] %s used toolgun: %s [CharID: %s]", client:SteamID(), client:Name(), tool, client:getChar():getID()) end,
        category = "Item & Inventory",
        color = Color(52, 152, 219)
    },
    ["invalidNet"] = {
        func = function(client) return string.format("[%s] %s sent invalid net message! [CharID: %s]", client:SteamID(), client:Name(), client:getChar():getID()) end,
        category = "Management",
        color = Color(52, 152, 219)
    },
    ["charRecognize"] = {
        func = function(client, id, name) return string.format("[%s] %s recognized [%s] as %s [CharID: %s]", client:SteamID(), client:Name(), id, name, client:getChar():getID()) end,
        category = "Character",
        color = Color(46, 204, 113)
    },
    ["charsetname"] = {
        func = function(client, name, newName) return string.format("[%s] %s changed %s's name to %s [CharID: %s]", client:SteamID(), client:Name(), name, newName, client:getChar():getID()) end,
        category = "Character",
        color = Color(52, 152, 219)
    },
    ["charsetdesc"] = {
        func = function(client, name, newDescription) return string.format("[%s] %s changed %s's description to %s [CharID: %s]", client:SteamID(), client:Name(), name, newDescription, client:getChar():getID()) end,
        category = "Character",
        color = Color(52, 152, 219)
    },
    ["charBan"] = {
        func = function(client, name) return string.format("[%s] %s banned character %s [CharID: %s]", client:SteamID(), client:Name(), name, client:getChar():getID()) end,
        category = "Character",
        color = Color(52, 152, 219)
    },
    ["charsetmodel"] = {
        func = function(client, name, newModel, oldModel) return string.format("[%s] %s changed %s's model from %s to %s [CharID: %s]", client:SteamID(), client:Name(), name, oldModel, newModel, client:getChar():getID()) end,
        category = "Character",
        color = Color(52, 152, 219)
    },
    ["charsetbodygroup"] = {
        func = function(client, name, bodyGroupName, newValue, oldValue) return string.format("[%s] %s changed %s's bodygroup %s to %s (was: %s) [CharID: %s]", client:SteamID(), client:Name(), name, bodyGroupName, newValue, oldValue, client:getChar():getID()) end,
        category = "Character",
        color = Color(52, 152, 219)
    },
    ["charsetskin"] = {
        func = function(client, name, newSkin, oldSkin) return string.format("[%s] %s changed %s's skin to %s (was: %s) [CharID: %s]", client:SteamID(), client:Name(), name, newSkin, oldSkin, client:getChar():getID()) end,
        category = "Character",
        color = Color(52, 152, 219)
    },
    ["moneyPickedUp"] = {
        func = function(client, amount) return string.format("[%s] %s picked up %s %s [CharID: %s]", client:SteamID(), client:Name(), lia.currency.get(amount), amount > 1 and lia.currency.plural or lia.currency.singular, client:getChar():getID()) end,
        category = "Financial & Vendor",
        color = Color(52, 152, 219)
    },
    ["roll"] = {
        func = function(client, value) return string.format("[%s] %s rolled %d out of 100 [CharID: %s]", client:SteamID(), client:Name(), value, client:getChar():getID()) end,
        category = "Miscellaneous",
        color = Color(52, 152, 219)
    },
    ["ticketOpen"] = {
        func = function(client) return string.format("%s opened a ticket.", client:Name()) end,
        category = "Management",
        color = Color(255, 0, 0)
    },
    ["ticketTook"] = {
        func = function(client) return string.format("%s took a ticket.", client:Name()) end,
        category = "Management",
        color = Color(255, 0, 0)
    },
    ["ticketClosed"] = {
        func = function(client) return string.format("%s closed a ticket.", client:Name()) end,
        category = "Management",
        color = Color(255, 0, 0)
    },
    ["unprotectedVJNetCall"] = {
        func = function(client) return string.format("%s is trying to abuse unprotected VJ net calls.", client:Name()) end,
        category = "Management",
        color = Color(255, 0, 0)
    },
    ["Ragdolled"] = {
        func = function(client, state)
            if state then
                return client:Nick() .. " has been ragdolled."
            else
                return client:Nick() .. " has stood up."
            end
        end,
        category = "Combat",
        color = Color(255, 0, 0)
    },
    ["Set Attribute"] = {
        func = function(client, data) return string.format("%s set attribute '%s' to level %d for %s", client:Name(), data.attributeName, data.level, data.target) end,
        category = "Management",
        color = Color(52, 152, 219)
    },
    ["Add Attribute"] = {
        func = function(client, data) return string.format("%s added level %d to attribute '%s' for %s", client:Name(), data.addedLevel, data.attributeName, data.target) end,
        category = "Management",
        color = Color(46, 204, 113)
    },
    ["Lock Storage"] = {
        func = function(client, data) return string.format("%s locked storage on %s with password '%s'", client:Name(), data.target, data.password) end,
        category = "Management",
        color = Color(52, 152, 219)
    },
    ["Unlock Storage"] = {
        func = function(client, data) return string.format("%s unlocked storage on %s", client:Name(), data.target) end,
        category = "Management",
        color = Color(46, 204, 113)
    },
    ["Open Trunk"] = {
        func = function(client, data) return string.format("%s opened the trunk of %s", client:Name(), data.target) end,
        category = "Management",
        color = Color(155, 89, 182)
    },
    ["Force Permakill"] = {
        func = function(client, data) return string.format("%s has forcefully permakilled %s (%s)", client:Name(), data.target, data.targetSteamID) end,
        category = "Combat",
        color = Color(192, 57, 43)
    },
    ["Toggle PK Flag"] = {
        func = function(client, data)
            local state = data.newPKState and "enabled" or "disabled"
            return string.format("%s has %s the PermaKill flag for %s (%s)", client:Name(), state, data.target, data.targetSteamID)
        end,
        category = "Management",
        color = Color(241, 196, 15)
    },
    ["Return Items"] = {
        func = function(client, data)
            local items = table.concat(data.items, ", ")
            return string.format("%s returned items [%s] to %s (%s)", client:Name(), items, data.target, data.targetSteamID)
        end,
        category = "Item & Inventory",
        color = Color(46, 204, 113)
    },
    ["Remove Spawn"] = {
        func = function(client, data) return string.format("%s removed %d spawn(s) within a radius of %d units from position (%s)", client:Name(), data.count, data.radius, tostring(data.position)) end,
        category = "Spawn & Entity",
        color = Color(192, 57, 43)
    },
    ["Add Spawn"] = {
        func = function(client, data) return string.format("%s added a spawn for faction '%s'%s at position (%s)", client:Name(), data.faction, data.class and (" with class '" .. data.class .. "'") or "", tostring(data.position)) end,
        category = "Spawn & Entity",
        color = Color(52, 152, 219)
    },
    ["Play Global Sound"] = {
        func = function(client, data) return string.format("%s played global sound '%s'", client:Name(), data.sound) end,
        category = "Sound",
        color = Color(52, 152, 219)
    },
    ["Play Sound"] = {
        func = function(client, data) return string.format("%s played sound '%s' to %s", client:Name(), data.sound, data.target) end,
        category = "Sound",
        color = Color(46, 204, 113)
    },
    ["Return Player"] = {
        func = function(client, data) return string.format("%s returned %s to their death position", client:Name(), data.target) end,
        category = "Management",
        color = Color(155, 89, 182)
    },
    ["Roll"] = {
        func = function(client, data) return string.format("%s rolled a value of %d", client:Name(), data.rollValue) end,
        category = "Miscellaneous",
        color = Color(241, 196, 15)
    },
    ["Change Description"] = {
        func = function(client, data) return string.format("%s changed %s's description to '%s'", client:Name(), data.target, data.desc) end,
        category = "Character",
        color = Color(52, 152, 219)
    },
    ["Change Up"] = {
        func = function(client, data) return string.format("%s made %s get up from ragdoll", client:Name(), data.target) end,
        category = "Character",
        color = Color(46, 204, 113)
    },
    ["Give Money"] = {
        func = function(client, data) return string.format("%s gave %s %s", client:Name(), data.target, lia.currency.get(data.amount)) end,
        category = "Financial & Vendor",
        color = Color(241, 196, 15)
    },
    ["Fall Over"] = {
        func = function(client, data) return string.format("%s forced %s to fall over for %d seconds", client:Name(), data.target, data.time or 5) end,
        category = "Combat",
        color = Color(155, 89, 182)
    },
    ["Drop Money"] = {
        func = function(client, data) return string.format("%s dropped %s to the ground", client:Name(), lia.currency.get(data.amount)) end,
        category = "Financial & Vendor",
        color = Color(192, 57, 43)
    },
    ["Entity Info"] = {
        func = function(client, data) return string.format("%s viewed info of entity '%s' (ID: %d)", client:Name(), data.class, data.id) end,
        category = "Management",
        color = Color(46, 204, 113)
    },
    ["Check Inventory"] = {
        func = function(client, data) return string.format("%s checked %s's inventory", client:Name(), data.target) end,
        category = "Item & Inventory",
        color = Color(52, 152, 219)
    },
    ["Give Flag"] = {
        func = function(client, data) return string.format("%s gave flag '%s' to %s", client:Name(), data.flag, data.target) end,
        category = "Management",
        color = Color(46, 204, 113)
    },
    ["Give All Flags"] = {
        func = function(client, data) return string.format("%s gave all flags to %s", client:Name(), data.target) end,
        category = "Management",
        color = Color(46, 204, 113)
    },
    ["Toggle Pet Flag"] = {
        func = function(client, data)
            local action = data.newState and "granted" or "revoked"
            return string.format("%s %s the 'pet' flag for %s", client:Name(), action, data.target)
        end,
        category = "Management",
        color = Color(155, 89, 182)
    },
    ["Take All Flags"] = {
        func = function(client, data) return string.format("%s took all flags from %s", client:Name(), data.target) end,
        category = "Management",
        color = Color(192, 57, 43)
    },
    ["Take Flag"] = {
        func = function(client, data) return string.format("%s took flag '%s' from %s", client:Name(), data.flag, data.target) end,
        category = "Management",
        color = Color(192, 57, 43)
    },
    ["Bring Lost Items"] = {
        func = function(client, data) return string.format("%s brought lost items to %s", client:Name(), data.target) end,
        category = "Item & Inventory",
        color = Color(46, 204, 113)
    },
    ["Clean Items"] = {
        func = function(client, data) return string.format("%s cleaned up %d items from the map", client:Name(), data.count) end,
        category = "Management",
        color = Color(192, 57, 43)
    },
    ["Clean Props"] = {
        func = function(client, data) return string.format("%s cleaned up %d props from the map", client:Name(), data.count) end,
        category = "Management",
        color = Color(192, 57, 43)
    },
    ["Clean NPCs"] = {
        func = function(client, data) return string.format("%s cleaned up %d NPCs from the map", client:Name(), data.count) end,
        category = "Management",
        color = Color(192, 57, 43)
    },
    ["Unban Character"] = {
        func = function(client, data) return string.format("%s unbanned character '%s'", client:Name(), data.target) end,
        category = "Character",
        color = Color(46, 204, 113)
    },
    ["Clear Inventory"] = {
        func = function(client, data) return string.format("%s cleared %s's inventory", client:Name(), data.target) end,
        category = "Item & Inventory",
        color = Color(192, 57, 43)
    },
    ["Kick Character"] = {
        func = function(client, data) return string.format("%s kicked %s's character", client:Name(), data.target) end,
        category = "Character",
        color = Color(192, 57, 43)
    },
    ["Freeze All Props"] = {
        func = function(client, data) return string.format("%s froze %d entities belonging to %s", client:Name(), data.count, data.target) end,
        category = "Management",
        color = Color(155, 89, 182)
    },
    ["Ban Character"] = {
        func = function(client, data) return string.format("%s banned character '%s'", client:Name(), data.target) end,
        category = "Character",
        color = Color(192, 57, 43)
    },
    ["Check All Money"] = {
        func = function(client) return string.format("%s checked all players' money", client:Name()) end,
        category = "Financial & Vendor",
        color = Color(241, 196, 15)
    },
    ["Check Flags"] = {
        func = function(client, data) return string.format("%s checked %s's flags", client:Name(), data.target) end,
        category = "Management",
        color = Color(46, 204, 113)
    },
    ["Find All Flags"] = {
        func = function(client) return string.format("%s listed all on-duty staff's flags", client:Name()) end,
        category = "Management",
        color = Color(46, 204, 113)
    },
    ["Check Money"] = {
        func = function(client, data) return string.format("%s checked %s's money: %s", client:Name(), data.target, lia.currency.get(data.amount)) end,
        category = "Financial & Vendor",
        color = Color(241, 196, 15)
    },
    ["List Bodygroups"] = {
        func = function(client, data) return string.format("%s listed bodygroups for %s", client:Name(), data.target) end,
        category = "Character",
        color = Color(155, 89, 182)
    },
    ["Change Model"] = {
        func = function(client, data) return string.format("%s changed %s's model from '%s' to '%s'", client:Name(), data.target, data.oldModel, data.newModel) end,
        category = "Character",
        color = Color(52, 152, 219)
    },
    ["Give Item"] = {
        func = function(client, data) return string.format("%s gave item '%s' to %s", client:Name(), data.item, data.target) end,
        category = "Item & Inventory",
        color = Color(46, 204, 113)
    },
    ["Change Name"] = {
        func = function(client, data) return string.format("%s changed %s's name to '%s'", client:Name(), data.target, data.newName) end,
        category = "Character",
        color = Color(46, 204, 113)
    },
    ["Change Scale"] = {
        func = function(client, data) return string.format("%s changed %s's model scale to %f", client:Name(), data.target, data.scale) end,
        category = "Character",
        color = Color(155, 89, 182)
    },
    ["Change Jump Power"] = {
        func = function(client, data) return string.format("%s changed %s's jump power to %d", client:Name(), data.target, data.jumpPower) end,
        category = "Character",
        color = Color(155, 89, 182)
    },
    ["Change Bodygroup"] = {
        func = function(client, data) return string.format("%s changed %s's bodygroup '%s' to %d (was %d)", client:Name(), data.target, data.bodyGroup, data.newValue, data.oldValue) end,
        category = "Character",
        color = Color(155, 89, 182)
    },
    ["Change Skin"] = {
        func = function(client, data) return string.format("%s changed %s's skin from %d to %d", client:Name(), data.target, data.oldSkin, data.newSkin) end,
        category = "Character",
        color = Color(155, 89, 182)
    },
    ["Set Money"] = {
        func = function(client, data) return string.format("%s set %s's money to %s", client:Name(), data.target, lia.currency.get(data.amount)) end,
        category = "Financial & Vendor",
        color = Color(241, 196, 15)
    },
    ["Add Money"] = {
        func = function(client, data) return string.format("%s added %s to %s's money. Total: %s", client:Name(), lia.currency.get(data.amount), data.target, lia.currency.get(data.total)) end,
        category = "Financial & Vendor",
        color = Color(241, 196, 15)
    },
    ["List Flags"] = {
        func = function(client,) return string.format("%s listed flags", client:Name()) end,
        category = "Management",
        color = Color(46, 204, 113)
    },
    ["List Items"] = {
        func = function(client, data) return string.format("%s listed all items", client:Name()) end,
        category = "Item & Inventory",
        color = Color(52, 152, 219)
    },
    ["List Modules"] = {
        func = function(client) return string.format("%s listed all modules", client:Name()) end,
        category = "Management",
        color = Color(52, 152, 219)
    },
    ["List Entities"] = {
        func = function(client) return string.format("%s listed all entities", client:Name()) end,
        category = "Management",
        color = Color(46, 204, 113)
    },
    ["List Staff"] = {
        func = function(client) return string.format("%s listed all staff members", client:Name()) end,
        category = "Management",
        color = Color(155, 89, 182)
    },
    ["List On Duty Staff"] = {
        func = function(client) return string.format("%s listed all on-duty staff members", client:Name()) end,
        category = "Management",
        color = Color(155, 89, 182)
    },
    ["List VIPs"] = {
        func = function(client) return string.format("%s listed all VIPs", client:Name()) end,
        category = "Management",
        color = Color(155, 89, 182)
    },
    ["List Users"] = {
        func = function(client) return string.format("%s listed all users", client:Name()) end,
        category = "Management",
        color = Color(155, 89, 182)
    },
    ["Play Global Bot Say"] = {
        func = function(client, data) return string.format("%s made all bots say '%s'", client:Name(), data.message) end,
        category = "Sound",
        color = Color(52, 152, 219)
    },
    ["Bot Say"] = {
        func = function(client, data) return string.format("%s made bot '%s' say '%s'", client:Name(), data.botName, data.message) end,
        category = "Sound",
        color = Color(46, 204, 113)
    },
    ["Force Say"] = {
        func = function(client, data) return string.format("%s forced %s to say '%s'", client:Name(), data.target, data.message) end,
        category = "Sound",
        color = Color(155, 89, 182)
    },
}