local MODULE = MODULE
function MODULE:CanPlayerSeeLog(client)
    local adminConsoleNetworkLogs = lia.config.get("AdminConsoleNetworkLogs", true)
    local canSeeLogs = client:hasPrivilege("canSeeLogs")
    local permission = adminConsoleNetworkLogs and canSeeLogs
    lia.debug("[Permissions]", "Permission Check for function CanPlayerSeeLog", "AdminConsoleNetworkLogs=", tostring(adminConsoleNetworkLogs), "hasPrivilege(canSeeLogs)=", tostring(canSeeLogs), "finalResult=", tostring(permission))
    return permission
end

function MODULE:ReadLogEntries(category, page)
    local d = deferred.new()
    local maxDays = lia.config.get("LogRetentionDays", 7)
    local logsPerPage = lia.config.get("logsPerPage", 50)
    local cutoff = os.time() - maxDays * 86400
    local cutoffStr = os.date("%Y-%m-%d %H:%M:%S", cutoff)
    local countCondition = table.concat({"gamemode = " .. lia.db.convertDataType(engine.ActiveGamemode()), "category = " .. lia.db.convertDataType(category), "timestamp >= " .. lia.db.convertDataType(cutoffStr)}, " AND ")
    lia.db.count("logs", countCondition):next(function(totalCount)
        local offset = (page - 1) * logsPerPage
        local limit = logsPerPage
        local condition = countCondition .. " ORDER BY id DESC LIMIT " .. limit .. " OFFSET " .. offset
        lia.db.select({"timestamp", "message", "steamID"}, "logs", condition):next(function(res)
            local rows = res.results or {}
            local logs = {}
            for _, row in ipairs(rows) do
                logs[#logs + 1] = {
                    timestamp = row.timestamp,
                    message = row.message,
                    steamID = row.steamID
                }
            end

            d:resolve({
                logs = logs,
                totalCount = totalCount,
                totalPages = math.max(1, math.ceil(totalCount / logsPerPage)),
                currentPage = page,
                category = category
            })
        end)
    end)
    return d
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
    local steam64 = IsValid(client) and client:SteamID64() or ""
    local message = L("staffLogPlayerJoined", client:Name(), steam64)
    StaffAddTextShadowed(Color(0, 200, 0), "JOIN", Color(255, 255, 255), message)
end

function MODULE:PlayerDisconnected(client)
    lia.log.add(client, "playerDisconnected")
    local steam64 = IsValid(client) and client:SteamID64() or ""
    local message = L("staffLogPlayerLeft", client:Name(), steam64)
    StaffAddTextShadowed(Color(128, 128, 128), "LEAVE", Color(255, 255, 255), message)
end

function MODULE:PlayerHurt(client, attacker, health, damage)
    if IsValid(attacker) then
        lia.log.add(client, "playerHurt", attacker:IsPlayer() and attacker:Name() or attacker:GetClass(), damage, health)
    else
        lia.log.add(client, "playerHurt", "unknown", damage, health)
    end
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

function MODULE:CanTool(client, trace, tool)
    local entity = trace.Entity
    local entityInfo = "none"
    if IsValid(entity) then
        if entity:IsPlayer() then
            entityInfo = "player:" .. entity:Name()
        elseif entity:IsNPC() then
            entityInfo = "npc:" .. entity:GetClass()
        elseif entity:IsVehicle() then
            entityInfo = "vehicle:" .. entity:GetClass()
        else
            entityInfo = "entity:" .. entity:GetClass()
        end
    end

    lia.log.add(client, "toolgunUse", tool, entityInfo)
end

function MODULE:OnPlayerObserve(client, state)
    lia.log.add(client, "observeToggle", state and L("enabled") or L("disabled"))
end

function MODULE:WarningIssued(admin, target, reason, severity, index)
    lia.db.count("warnings", "charID = " .. lia.db.convertDataType(target:getChar():getID())):next(function(count) lia.log.add(admin, "warningIssued", target, reason, severity or "Medium", count, index) end)
end

function MODULE:WarningRemoved(admin, target, warning, index)
    lia.db.count("warnings", "charID = " .. lia.db.convertDataType(target:getChar():getID())):next(function(count) lia.log.add(admin, "warningRemoved", target, warning, count, index) end)
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

