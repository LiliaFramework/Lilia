local MODULE = MODULE
local function SendLogs(client, categorizedLogs)
    lia.net.writeBigTable(client, "send_logs", categorizedLogs)
end

local function CanPlayerSeeLog(client)
    return lia.config.get("AdminConsoleNetworkLogs", true) and client:hasPrivilege("canSeeLogs")
end

local function ReadLogEntries(category)
    local d = deferred.new()
    local maxDays = lia.config.get("LogRetentionDays", 7)
    local maxLines = lia.config.get("MaxLogLines", 1000)
    local cutoff = os.time() - maxDays * 86400
    local cutoffStr = os.date("%Y-%m-%d %H:%M:%S", cutoff)
    local condition = table.concat({"gamemode = " .. lia.db.convertDataType(engine.ActiveGamemode()), "category = " .. lia.db.convertDataType(category), "timestamp >= " .. lia.db.convertDataType(cutoffStr)}, " AND ") .. " ORDER BY id DESC LIMIT " .. maxLines
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

        d:resolve(logs)
    end)
    return d
end

net.Receive("send_logs_request", function(_, client)
    if not CanPlayerSeeLog(client) then return end
    local categories = {}
    for _, v in pairs(lia.log.types) do
        categories[v.category or L("uncategorized")] = true
    end

    local catList = {}
    for k in pairs(categories) do
        if hook.Run("CanPlayerSeeLogCategory", client, k) ~= false then catList[#catList + 1] = k end
    end

    local logsByCategory = {}
    local function fetch(i)
        if i > #catList then return SendLogs(client, logsByCategory) end
        local cat = catList[i]
        ReadLogEntries(cat):next(function(entries)
            if #entries > 0 then logsByCategory[cat] = entries end
            fetch(i + 1)
        end)
    end

    fetch(1)
end)

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

function MODULE:PlayerSpawn(client)
    lia.log.add(client, "playerSpawn")
end

function MODULE:OnPlayerObserve(client, state)
    lia.log.add(client, "observeToggle", state and L("enabled") or L("disabled"))
end

function MODULE:TicketSystemClaim(admin, requester)
    lia.db.count("ticketclaims", "adminSteamID = " .. lia.db.convertDataType(admin:SteamID())):next(function(count) lia.log.add(admin, "ticketClaimed", requester:Name(), count) end)
end

local function GetPlayerInfo(ply)
    if not IsValid(ply) then return "Unknown Player" end
    return string.format("%s (%s)", ply:Nick(), ply:SteamID64())
end

local function GetAdminInfo(admin)
    if not IsValid(admin) then return "Console" end
    return string.format("%s (%s)", admin:Nick(), admin:SteamID64())
end

function MODULE:TicketSystemClose(admin, requester)
    lia.db.count("ticketclaims", "adminSteamID = " .. lia.db.convertDataType(admin:SteamID())):next(function(count) lia.log.add(admin, "ticketClosed", requester:Name(), count) end)
    lia.discord.relayMessage({
        title = L("discordTicketSystemTitle"),
        description = L("discordTicketSystemClosedDescription"),
        color = 3447003,
        fields = {
            {
                name = L("discordTicketSystemStaffMember"),
                value = GetAdminInfo(admin),
                inline = true
            },
            {
                name = L("discordTicketSystemRequester"),
                value = GetPlayerInfo(requester),
                inline = true
            },
            {
                name = L("discordTicketSystemOriginalMessage"),
                value = message or L("discordTicketSystemNoMessageProvided"),
                inline = false
            }
        }
    })
end

function MODULE:WarningIssued(admin, target, reason, index)
    lia.db.count("warnings", "charID = " .. lia.db.convertDataType(target:getChar():getID())):next(function(count) lia.log.add(admin, "warningIssued", target, reason, count, index) end)
    lia.discord.relayMessage({
        title = L("discordWarningSystemTitle"),
        description = L("discordWarningSystemIssuedDescription"),
        color = 16776960,
        fields = {
            {
                name = L("discordWarningSystemAdmin"),
                value = GetAdminInfo(admin),
                inline = true
            },
            {
                name = L("discordWarningSystemTargetPlayer"),
                value = GetPlayerInfo(target),
                inline = true
            },
            {
                name = L("discordWarningSystemReason"),
                value = reason or L("discordWarningSystemNoReasonSpecified"),
                inline = false
            },
            {
                name = L("discordWarningSystemWarningCount"),
                value = tostring(count or 1),
                inline = true
            }
        }
    })
end

function MODULE:WarningRemoved(admin, target, warning, index)
    lia.db.count("warnings", "charID = " .. lia.db.convertDataType(target:getChar():getID())):next(function(count) lia.log.add(admin, "warningRemoved", target, warning, count, index) end)
    lia.discord.relayMessage({
        title = L("discordWarningSystemTitle"),
        description = L("discordWarningSystemRemovedDescription"),
        color = 16776960,
        fields = {
            {
                name = L("discordWarningSystemAdmin"),
                value = GetAdminInfo(admin),
                inline = true
            },
            {
                name = L("discordWarningSystemTargetPlayer"),
                value = GetPlayerInfo(target),
                inline = true
            },
            {
                name = L("discordWarningSystemRemovedWarningReason"),
                value = warning and warning.reason or L("discordWarningSystemNoReasonSpecified"),
                inline = false
            },
            {
                name = L("discordWarningSystemWarningIndex"),
                value = tostring(index or L("discordWarningSystemUnknown")),
                inline = true
            },
            {
                name = L("discordWarningSystemOriginalWarner"),
                value = warning and warning.admin or L("discordWarningSystemUnknown"),
                inline = true
            }
        }
    })
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