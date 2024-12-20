﻿local MODULE = MODULE
util.AddNetworkString("send_logs")
function MODULE:ReadLogFiles(logtype)
    local logs = {}
    local logFilePath = "lilia/logs" .. logtype .. "/*.txt"
    local logFiles = file.Find(logFilePath, "DATA")
    for _, fileName in ipairs(logFiles) do
        local strippedName = string.StripExtension(fileName)
        table.insert(logs, strippedName)
    end
    return logs
end

function MODULE:ReadLogsFromFile(logtype, selectedDate)
    local logs = {}
    local logFilePath = "lilia/logs" .. logtype .. "/" .. selectedDate:gsub("/", "-") .. ".txt"
    if file.Exists(logFilePath, "DATA") then
        local logFileContent = file.Read(logFilePath, "DATA")
        for line in logFileContent:gmatch("[^\r\n]+") do
            local timestamp, message = line:match("^%[([^%]]+)%]%s*(.+)")
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

function MODULE:OnServerLog(_, logType, logString)
    for _, admin in pairs(lia.util.getAdmins()) do
        if hook.Run("CanPlayerSeeLog", admin, logType) ~= false then lia.log.send(admin, logString) end
    end
end

function MODULE:CanPlayerSeeLog()
    return lia.config.AdminConsoleNetworkLogs
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
        lia.log.add(client, "itemUse", name)
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

function MODULE:PlayerGiveSWEP(client, swep)
    lia.log.add(client, "swep_spawning", swep)
end

function MODULE:PlayerSpawnSWEP(client, swep)
    lia.log.add(client, "swep_spawning", swep)
end

function MODULE:CanTool(client, _, tool)
    lia.log.add(client, "toolgunUse", tool)
end