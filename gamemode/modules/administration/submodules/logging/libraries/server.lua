local MODULE = MODULE
function MODULE:SendLogsInChunks(client, categorizedLogs)
    local json = util.TableToJSON(categorizedLogs)
    local data = util.Compress(json)
    local chunks = {}
    for i = 1, #data, 32768 do
        chunks[#chunks + 1] = string.sub(data, i, i + 32768 - 1)
    end

    for i, chunk in ipairs(chunks) do
        net.Start("send_logs")
        net.WriteUInt(i, 16)
        net.WriteUInt(#chunks, 16)
        net.WriteUInt(#chunk, 16)
        net.WriteData(chunk, #chunk)
        net.Send(client)
    end
end

function MODULE:ReadLogEntries(category)
    local d = deferred.new()
    local maxDays = lia.config.get("LogRetentionDays", 7)
    local maxLines = lia.config.get("MaxLogLines", 1000)
    local cutoff = os.time() - maxDays * 86400
    local cutoffStr = os.date("%Y-%m-%d %H:%M:%S", cutoff)
    local condition = table.concat({"_gamemode = " .. lia.db.convertDataType(engine.ActiveGamemode()), "_category = " .. lia.db.convertDataType(category), "_timestamp >= " .. lia.db.convertDataType(cutoffStr)}, " AND ") .. " ORDER BY _id DESC LIMIT " .. maxLines
    lia.db.select({"_timestamp", "_message", "_steamID"}, "logs", condition):next(function(res)
        local rows = res.results or {}
        local logs = {}
        for _, row in ipairs(rows) do
            logs[#logs + 1] = {
                timestamp = row._timestamp,
                message = row._message,
                steamID = row._steamID
            }
        end

        d:resolve(logs)
    end)
    return d
end

net.Receive("send_logs_request", function(_, client)
    if not MODULE:CanPlayerSeeLog(client) then return end
    local categories = {}
    for _, logType in pairs(lia.log.types) do
        categories[logType.category or "Uncategorized"] = true
    end

    local catList = {}
    for cat in pairs(categories) do
        if hook.Run("CanPlayerSeeLogCategory", client, cat) ~= false then catList[#catList + 1] = cat end
    end

    local logsByCategory = {}
    local function fetch(idx)
        if idx > #catList then return MODULE:SendLogsInChunks(client, logsByCategory) end
        local cat = catList[idx]
        MODULE:ReadLogEntries(cat):next(function(entries)
            logsByCategory[cat] = entries
            fetch(idx + 1)
        end)
    end

    fetch(1)
end)

function MODULE:CanPlayerSeeLog(client)
    return lia.config.get("AdminConsoleNetworkLogs", true) and client:hasPrivilege("Staff Permissions - Can See Logs")
end

function MODULE:OnCharDelete(client, id)
    lia.log.add(client, "charDelete", id)
end

function MODULE:OnPlayerInteractItem(client, action, item, result)
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

    action = string.lower(action)
    if not item then return end
    local name = item.name
    if result == false then
        lia.log.add(client, "itemInteractionFailed", action, name)
        return
    end

    if action == "use" then
        lia.log.add(client, "use", name)
    elseif action == "drop" then
        lia.log.add(client, "itemDrop", name)
    elseif action == "take" then
        lia.log.add(client, "itemTake", name)
    elseif action == "unequip" then
        lia.log.add(client, "itemUnequip", name)
    elseif action == "equip" then
        lia.log.add(client, "itemEquip", name)
    else
        lia.log.add(client, "itemInteraction", action, item)
    end
end

function MODULE:PlayerConnect(name, ip)
    lia.log.add(nil, "playerConnect", name, ip)
end

function MODULE:PlayerInitialSpawn(client)
    lia.log.add(client, "playerInitialSpawn")
end

function MODULE:PlayerDisconnect(client)
    lia.log.add(client, "playerDisconnected")
end

function MODULE:PlayerHurt(client, attacker, health, damage)
    lia.log.add(client, "playerHurt", attacker:IsPlayer() and attacker:Name() or attacker:GetClass(), damage, health)
end

function MODULE:PlayerDeath(client, attacker)
    lia.log.add(client, "playerDeath", attacker:IsPlayer() and attacker:Name() or attacker:GetClass())
end

function MODULE:OnCharCreated(client, character)
    lia.log.add(client, "charCreate", character)
end

function MODULE:PostPlayerLoadedChar(client, character)
    lia.log.add(client, "charLoad", character:getName(), character:getID())
end

function MODULE:PlayerSpawnedProp(client, model)
    lia.log.add(client, "spawned_prop", model)
end

function MODULE:PlayerSpawnedRagdoll(client, model)
    lia.log.add(client, "spawned_ragdoll", model)
end

function MODULE:PlayerSpawnedEffect(client, model)
    lia.log.add(client, "spawned_effect", model)
end

function MODULE:PlayerSpawnedVehicle(client, vehicle)
    lia.log.add(client, "spawned_vehicle", vehicle:GetClass(), vehicle:GetModel())
end

function MODULE:PlayerSpawnedNPC(client, npc)
    lia.log.add(client, "spawned_npc", npc:GetClass(), npc:GetModel())
end

function MODULE:PlayerSpawnedSENT(client, sent)
    lia.log.add(client, "spawned_sent", sent:GetClass(), sent:GetModel())
end

function MODULE:PlayerGiveSWEP(client, swep)
    lia.log.add(client, "swep_spawning", swep)
end

function MODULE:PlayerSpawnSWEP(client, swep)
    lia.log.add(client, "swep_spawning", swep)
end

function MODULE:CanTool(client, _, tool)
    lia.log.add(client, "toolgunUse", tool)
end

function MODULE:PlayerSpawn(client)
    lia.log.add(client, "playerSpawn")
end

function MODULE:OnPlayerObserve(client, state)
    lia.log.add(client, "observeToggle", state and "enabled" or "disabled")
end

function MODULE:TicketSystemClaim(admin, requester)
    lia.db.count("ticketclaims", "_admin = " .. lia.db.convertDataType(admin:SteamID64())):next(function(count) lia.log.add(admin, "ticketClaimed", requester:Name(), count) end)
end

function MODULE:TicketSystemClose(admin, requester)
    lia.db.count("ticketclaims", "_admin = " .. lia.db.convertDataType(admin:SteamID64())):next(function(count) lia.log.add(admin, "ticketClosed", requester:Name(), count) end)
end

function MODULE:WarningIssued(admin, target, reason, index)
    lia.db.count("warnings", "_charID = " .. lia.db.convertDataType(target:getChar():getID())):next(function(count) lia.log.add(admin, "warningIssued", target, reason, count, index) end)
end

function MODULE:WarningRemoved(admin, target, warning, index)
    lia.db.count("warnings", "_charID = " .. lia.db.convertDataType(target:getChar():getID())):next(function(count) lia.log.add(admin, "warningRemoved", target, warning, count, index) end)
end

function MODULE:ItemTransfered(context)
    local client = context.client
    local item = context.item
    if not (IsValid(client) and item) then return end
    local fromID = context.from and context.from:getID() or 0
    local toID = context.to and context.to:getID() or 0
    lia.log.add(client, "itemTransfer", item:getName(), fromID, toID)
end

function MODULE:OnItemAdded(owner, item)
    lia.log.add(owner, "itemAdded", item:getName())
end

function MODULE:ItemFunctionCalled(item, action, client)
    if not action then return end
    local lowered = string.lower(action)
    if lowered == "onloadout" or lowered == "onsave" then return end
    if IsValid(client) then lia.log.add(client, "itemFunction", action, item:getName()) end
end

function MODULE:ItemDraggedOutOfInventory(client, item)
    lia.log.add(client, "itemDraggedOut", item:getName())
end
