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

function MODULE:ReadLogFiles(category)
    local maxDays = lia.config.get("LogRetentionDays", 7)
    local maxLines = lia.config.get("MaxLogLines", 1000)
    local logs = {}
    local fnameCat = string.lower(category:gsub("%s+", "_"))
    local path = "lilia/logs/" .. engine.ActiveGamemode() .. "/" .. fnameCat .. ".txt"
    if not file.Exists(path, "DATA") then return logs end
    local content = file.Read(path, "DATA")
    local lines = {}
    local cutoff = os.time() - maxDays * 86400
    for line in content:gmatch("[^\r\n]+") do
        lines[#lines + 1] = line
    end

    local startIdx = math.max(#lines - maxLines + 1, 1)
    for i = startIdx, #lines do
        local ts, msg = lines[i]:match("^%[([^%]]+)%]%s*(.+)")
        if ts and msg then
            local y, m, d, H, M, S = ts:sub(1, 4), ts:sub(6, 7), ts:sub(9, 10), ts:sub(12, 13), ts:sub(15, 16), ts:sub(18, 19)
            local logTime = os.time{
                year = tonumber(y),
                month = tonumber(m),
                day = tonumber(d),
                hour = tonumber(H),
                min = tonumber(M),
                sec = tonumber(S)
            }

            if logTime >= cutoff then
                logs[#logs + 1] = {
                    timestamp = ts,
                    message = msg
                }
            end
        end
    end
    return logs
end

net.Receive("send_logs_request", function(_, client)
    if not MODULE:CanPlayerSeeLog(client) then return end
    local logsByCategory = {}
    for _, logType in pairs(lia.log.types) do
        local cat = logType.category or "Uncategorized"
        logsByCategory[cat] = logsByCategory[cat] or {}
        for _, entry in ipairs(MODULE:ReadLogFiles(cat)) do
            logsByCategory[cat][#logsByCategory[cat] + 1] = entry
        end
    end

    MODULE:SendLogsInChunks(client, logsByCategory)
end)

function MODULE:CanPlayerSeeLog(client)
    return lia.config.get("AdminConsoleNetworkLogs", true) and client:hasPrivilege("Staff Permissions - Can See Logs")
end

function MODULE:OnCharDelete(client, id)
    lia.log.add(client, "charDelete", id)
end

function MODULE:OnPlayerInteractItem(client, action, item)
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

function MODULE:PlayerInitialSpawn(client)
    lia.log.add(client, "playerConnected")
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
    local caseclaims = lia.data.get("caseclaims", {}, true)
    local info = caseclaims[admin:SteamID64()]
    lia.log.add(admin, "ticketClaimed", requester:Name(), info and info.claims or 0)
end

function MODULE:TicketSystemClose(admin, requester)
    local caseclaims = lia.data.get("caseclaims", {}, true)
    local info = caseclaims[admin:SteamID64()]
    lia.log.add(admin, "ticketClosed", requester:Name(), info and info.claims or 0)
end

function MODULE:WarningIssued(admin, target, reason, index)
    local warns = target:getLiliaData("warns") or {}
    lia.log.add(admin, "warningIssued", target, reason, #warns, index)
end

function MODULE:WarningRemoved(admin, target, warning, index)
    local warns = target:getLiliaData("warns") or {}
    lia.log.add(admin, "warningRemoved", target, warning, #warns, index)
end


