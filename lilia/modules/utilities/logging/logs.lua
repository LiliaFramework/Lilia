lia.log.types = {
    -- Connection Logs
    ["playerConnected"] = {
        func = function(client) return string.format("%s[%s] has connected to the server.", client:Name(), client:SteamID()) end,
        category = "Connection Logs",
        color = Color(255, 255, 255)
    },
    ["playerDisconnected"] = {
        func = function(client, ...) return string.format("%s[%s] has disconnected from the server.", client:Name(), client:SteamID()) end,
        category = "Connection Logs",
        color = Color(255, 255, 255)
    },
    -- Spawn Logs
    ["spawned_prop"] = {
        func = function(client, model) return string.format("%s has spawned a prop with model: %s", client:Name(), model) end,
        category = "Spawn Logs",
        color = Color(52, 152, 219)
    },
    ["spawned_ragdoll"] = {
        func = function(client, model) return string.format("%s has spawned a ragdoll with model: %s", client:Name(), model) end,
        category = "Spawn Logs",
        color = Color(52, 152, 219)
    },
    ["spawned_effect"] = {
        func = function(client, effect) return string.format("%s has spawned an effect: %s", client:Name(), effect) end,
        category = "Spawn Logs",
        color = Color(52, 152, 219)
    },
    ["spawned_vehicle"] = {
        func = function(client, vehicleName, model) return string.format("%s has spawned a vehicle '%s' with model: %s", client:Name(), vehicleName, model) end,
        category = "Spawn Logs",
        color = Color(52, 152, 219)
    },
    ["spawned_npc"] = {
        func = function(client, npcName, model) return string.format("%s has spawned an NPC '%s' with model: %s", client:Name(), npcName, model) end,
        category = "Spawn Logs",
        color = Color(52, 152, 219)
    },
    -- SWEP Logs
    ["swep_giving"] = {
        func = function(client, target, swep) return string.format("%s has given SWEP '%s' to %s", client:Name(), swep, target:Name()) end,
        category = "SWEP Logs",
        color = Color(52, 152, 219)
    },
    ["swep_spawning"] = {
        func = function(client, swep) return string.format("%s has spawned SWEP: %s", client:Name(), swep) end,
        category = "SWEP Logs",
        color = Color(52, 152, 219)
    },
    -- Chat Logs
    ["chat"] = {
        func = function(client, ...)
            local arg = {...}
            return string.format("[%s] %s: %s", arg[1], client:Name(), arg[2])
        end,
        category = "Chat Logs",
        color = Color(52, 152, 219)
    },
    ["command"] = {
        func = function(client, ...)
            local arg = {...}
            return string.format("%s used '%s'", client:Name(), arg[1])
        end,
        category = "Chat Logs",
        color = Color(52, 152, 219)
    },
    -- Character Management Logs
    ["charCreate"] = {
        func = function(client, ...)
            local arg = {...}
            return string.format("%s created the character #%s(%s)", client:steamName(), arg[1]:getID(), arg[1]:getName())
        end,
        category = "Character Management Logs",
        color = Color(52, 152, 219)
    },
    ["charLoad"] = {
        func = function(client, ...)
            local arg = {...}
            return string.format("%s loaded the character #%s(%s)", client:steamName(), arg[1], arg[2])
        end,
        category = "Character Management Logs",
        color = Color(52, 152, 219)
    },
    ["charDelete"] = {
        func = function(client, ...)
            local arg = {...}
            return string.format("%s(%s) deleted character (%s)", IsValid(client) and client:steamName() or "COMMAND", IsValid(client) and client:SteamID() or "", arg[1])
        end,
        category = "Character Management Logs",
        color = Color(52, 152, 219)
    },
    ["buydoor"] = {
        func = function(client, ...) return string.format("%s purchased the door", client:Name()) end,
        category = "Character Management Logs",
        color = Color(52, 152, 219)
    },
    ["selldoor"] = {
        func = function(client, ...) return string.format("%s sold the door", client:Name()) end,
        category = "Character Management Logs",
        color = Color(52, 152, 219)
    },
    -- Vendor Logs
    ["buy"] = {
        func = function(client, ...)
            local arg = {...}
            return string.format("%s purchased '%s' from an NPC", client:Name(), arg[1])
        end,
        category = "Vendor Logs",
        color = Color(52, 152, 219)
    },
    ["vendorAccess"] = {
        func = function(client, ...)
            local data = {...}
            local vendorName = data[1] or "unknown"
            return string.format("%s has accessed vendor %s.", client:Name(), vendorName)
        end,
        category = "Vendor Logs",
        color = Color(52, 152, 219)
    },
    ["vendorExit"] = {
        func = function(client, ...)
            local data = {...}
            local vendorName = data[1] or "unknown"
            return string.format("%s has exited vendor %s.", client:Name(), vendorName)
        end,
        category = "Vendor Logs",
        color = Color(52, 152, 219)
    },
    ["vendorSell"] = {
        func = function(client, ...)
            local data = {...}
            local vendorName = data[1] or "unknown"
            local itemName = data[2] or "unknown"
            return string.format("%s has sold a %s to %s.", client:Name(), itemName, vendorName)
        end,
        category = "Vendor Logs",
        color = Color(52, 152, 219)
    },
    ["vendorBuy"] = {
        func = function(client, ...)
            local data = {...}
            local vendorName = data[1] or "unknown"
            local itemName = data[2] or "unknown"
            return string.format("%s has bought a %s from %s.", client:Name(), itemName, vendorName)
        end,
        category = "Vendor Logs",
        color = Color(52, 152, 219)
    },
    ["vendorBuyFail"] = {
        func = function(client, ...)
            local data = {...}
            local vendorName = data[1] or "unknown"
            local itemName = data[2] or "unknown"
            return string.format("%s has tried to buy a %s from %s. He had no space!", client:Name(), itemName, vendorName)
        end,
        category = "Vendor Logs",
        color = Color(52, 152, 219)
    },
    -- Item Logs
    ["itemTake"] = {
        func = function(client, ...)
            local data = {...}
            local itemName = data[1] or "unknown"
            local itemCount = data[2] or 1
            return string.format("%s has picked up %dx%s.", client:Name(), itemCount, itemName)
        end,
        category = "Item Logs",
        color = Color(52, 152, 219)
    },
    ["itemDrop"] = {
        func = function(client, ...)
            local data = {...}
            local itemName = data[1] or "unknown"
            local itemCount = data[2] or 1
            return string.format("%s has lost %dx%s.", client:Name(), itemCount, itemName)
        end,
        category = "Item Logs",
        color = Color(52, 152, 219)
    },
    ["itemUse"] = {
        func = function(client, ...)
            local arg = {...}
            local item = arg[2]
            return string.format("%s tried '%s' on item '%s'(#%s)", client:Name(), arg[1], item.name, item.id)
        end,
        category = "Item Logs",
        color = Color(52, 152, 219)
    },
    -- Character Logs
    ["money"] = {
        func = function(client, ...)
            local data = {...}
            local amount = data[1] or 0
            return string.format("%s's money has changed by %d.", client:Name(), amount)
        end,
        category = "Character Logs",
        color = Color(52, 152, 219)
    },
    ["moneyGiven"] = {
        func = function(client, targetName, amount) return string.format("%s has given %s %s.", client:Name(), targetName, lia.currency.get(amount)) end,
        category = "Character Logs",
        color = Color(52, 152, 219)
    },
    ["moneyGivenTAB"] = {
        func = function(client, targetName, amount) return string.format("%s has given %s %s using TAB.", client:Name(), targetName, lia.currency.get(amount)) end,
        category = "Character Logs",
        color = Color(52, 152, 219)
    },
    -- Damage and Death Logs
    ["playerHurt"] = {
        func = function(client, attacker, damage, health)
            attacker = tostring(attacker)
            damage = damage or 0
            health = health or 0
            return string.format("%s has taken %d damage from %s, leaving them at %d health.", client:Name(), damage, attacker, health)
        end,
        category = "Damage Logs",
        color = Color(52, 152, 219)
    },
    ["playerDeath"] = {
        func = function(client, ...)
            local data = {...}
            local attacker = data[1] or "unknown"
            return string.format("%s has killed %s.", attacker, client:Name())
        end,
        category = "Death Logs",
        color = Color(52, 152, 219)
    },
    -- Staff Logs
    ["unpersistedEntity"] = {
        func = function(client, entity) return string.format("%s has removed persistence from '%s'.", client:Name(), entity) end,
        category = "Staff Logs",
        color = Color(52, 152, 219)
    },
    ["persistedEntity"] = {
        func = function(client, entity) return string.format("%s has persisted '%s'.", client:Name(), entity) end,
        category = "Staff Logs",
        color = Color(52, 152, 219)
    },
    ["observerEnter"] = {
        func = function(client, ...) return string.format("%s has entered observer.", client:Name()) end,
        category = "Staff Logs",
        color = Color(52, 152, 219)
    },
    ["observerExit"] = {
        func = function(client, ...) return string.format("%s has left observer.", client:Name()) end,
        category = "Staff Logs",
        color = Color(52, 152, 219)
    },
    -- Network Logs
    ["net"] = {
        func = function(client, messageName) return string.format("[Net Log] Player %s (%s) sent net message %s.", client:GetName(), client:SteamID(), messageName) end,
        category = "Network Logs",
        color = Color(52, 152, 219)
    },
    ["invalidNet"] = {
        func = function(client) return string.format("[Net Log] Player %s (%s) tried to send invalid net message!", client:GetName(), client:SteamID()) end,
        category = "Network Logs",
        color = Color(52, 152, 219)
    },
}
