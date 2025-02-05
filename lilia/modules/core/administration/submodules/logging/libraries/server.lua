local MODULE = MODULE
util.AddNetworkString("send_logs")
function MODULE:ReadLogFiles(category)
    local maxDays = lia.config.get("LogRetentionDays", 7)
    local maxLines = lia.config.get("MaxLogLines", 1000)
    local logs = {}
    local logFilePath = "lilia/logs/" .. engine.ActiveGamemode() .. "/" .. category .. ".txt"
    if file.Exists(logFilePath, "DATA") then
        local logFileContent = file.Read(logFilePath, "DATA")
        local lines = {}
        local cutoffDate = os.time() - (maxDays * 86400)
        for line in logFileContent:gmatch("[^\r\n]+") do
            table.insert(lines, line)
        end

        local startIndex = math.max(#lines - maxLines + 1, 1)
        for i = startIndex, #lines do
            local timestamp, message = lines[i]:match("^%[([^%]]+)%]%s*(.+)")
            if timestamp and message then
                local logTime = os.time({
                    year = tonumber(timestamp:sub(1, 4)),
                    month = tonumber(timestamp:sub(6, 7)),
                    day = tonumber(timestamp:sub(9, 10)),
                    hour = tonumber(timestamp:sub(12, 13)),
                    min = tonumber(timestamp:sub(15, 16)),
                    sec = tonumber(timestamp:sub(18, 19))
                })

                if logTime and logTime >= cutoffDate then
                    table.insert(logs, {
                        timestamp = timestamp,
                        message = message
                    })
                end
            end
        end
    end
    return logs
end

local function SyncLogsToDiscord(text)
    HTTP({
        url = MODULE.DiscordLoggingWebhook,
        method = "POST",
        parameters = {
            content = text,
            username = "[LOG]"
        },
        success = function(code, body, headers) end,
        failed = function(reason) Msg(reason) end
    })
end

function MODULE:OnServerLog(_, logType, logString)
    for _, admin in pairs(lia.util.getAdmins()) do
        if hook.Run("CanPlayerSeeLog", admin, logType) ~= false then lia.log.send(admin, logString) end
    end

    if self.DiscordLoggingWebhook and self.DiscordLoggingWebhook ~= "" then SyncLogsToDiscord(logString) end
end

function MODULE:CanPlayerSeeLog()
    return lia.config.get("AdminConsoleNetworkLogs")
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