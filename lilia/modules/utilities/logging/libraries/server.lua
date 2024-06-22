﻿function MODULE:ReadLogFiles(logtype)
    local logs = {}
    local logFilePath = "lilia/" .. logtype .. "/*.txt"
    local logFiles = file.Find(logFilePath, "DATA")
    for _, fileName in ipairs(logFiles) do
        local strippedName = string.StripExtension(fileName)
        table.insert(logs, strippedName)
    end
    return logs
end

function MODULE:ReadLogsFromFile(logtype, selectedDate)
    local logs = {}
    local logFilePath = "lilia/" .. logtype .. "/" .. selectedDate:gsub("/", "-") .. ".txt"
    if file.Exists(logFilePath, "DATA") then
        local logFileContent = file.Read(logFilePath, "DATA")
        for line in logFileContent:gmatch("[^\r\n]+") do
            local timestamp, message = line:match("%[([^%]]+)%]%s*(.+)")
            if timestamp and message then
                table.insert(logs, {
                    timestamp = timestamp,
                    message = message
                })
            end
        end
    end
    return logs
end

function MODULE:OnServerLog(client, logType, logString, category, color)
    for _, v in pairs(lia.util.getAdmins()) do
        if hook.Run("CanPlayerSeeLog", v, logType) ~= false then lia.log.send(v, lia.log.getString(client, logType, logString, category, color)) end
    end

    local LogEvent = self:addCategory(category, color)
    LogEvent(logString)
end

function MODULE:CanPlayerSeeLog()
    return lia.config.AdminConsoleNetworkLogs
end

function MODULE:OnCharTradeVendor(client, vendor, item, isSellingToVendor, character, itemType, isFailed)
    local vendorName = vendor:getNetVar("name")
    if isFailed then
        lia.log.add(client, "vendorBuyFail", item:getName(), vendorName)
    elseif isSellingToVendor then
        lia.log.add(client, "vendorSell", item:getName(), vendorName)
    else
        lia.log.add(client, "vendorBuy", item:getName(), vendorName)
    end
end

function MODULE:OnPlayerObserve(client, state)
    lia.log.add(client, state and "observerEnter" or "observerExit")
end

function MODULE:PlayerAuthed(client)
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

function MODULE:OnCharDelete(client, id)
    lia.log.add(client, "charDelete", id)
end

function MODULE:OnCharCreated(client, character)
    lia.log.add(client, "charCreate", character)
end

function MODULE:CharLoaded(id)
    local character = lia.char.loaded[id]
    local client = character:getPlayer()
    lia.log.add(client, "charLoad", id, character:getName())
end

function MODULE:PlayerSpawnedProp(client, model, entity)
    lia.log.add(client, "spawned_prop", model)
end

function MODULE:PlayerSpawnedRagdoll(client, model, entity)
    lia.log.add(client, "spawned_ragdoll", model)
end

function MODULE:PlayerSpawnedEffect(client, model, entity)
    lia.log.add(client, "spawned_effect", model)
end

function MODULE:PlayerSpawnedVehicle(client, vehicle, entity)
    lia.log.add(client, "spawned_vehicle", vehicle:GetClass(), vehicle:GetModel())
end

function MODULE:PlayerSpawnedNPC(client, npc, entity)
    lia.log.add(client, "spawned_npc", npc:GetClass(), npc:GetModel())
end

function MODULE:PlayerGiveSWEP(client, target, swep)
    lia.log.add(client, "swep_giving", target, swep:GetClass())
end

function MODULE:PlayerSpawnSWEP(client, swep)
    lia.log.add(client, "swep_spawning", swep:GetClass())
end

function MODULE:CanTool(client, _, tool)
    lia.log.add(client, "toolgunUse", tool)
end