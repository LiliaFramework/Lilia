local MODULE = MODULE
function MODULE:OnPlayerJoinClass(client, class, oldClass)
    local info = lia.class.list[class]
    local info2 = lia.class.list[oldClass]
    if info then
        if info.OnSet then info:OnSet(client) end
        if oldClass ~= class and info.OnTransferred then info:OnTransferred(client, oldClass) end
    else
        lia.error(L("invalidClassError", tostring(class)))
    end

    if info2 and info2.OnLeave then info2:OnLeave(client) end
    net.Start("liaClassUpdate")
    net.WriteEntity(client)
    net.Broadcast()
    self:UpdateNPCRelations(client)
end

--[[
    Hooks:
        OnPlayerJoinClass(Player client, number class, number|nil oldClass)

    Purpose:
        Runs after a player is assigned to a class so modules can react to the new class and any transferred state.

    Category:
        Teams

    Parameters:
        client (Player)
            The player joining the class.

        class (number)
            The class index the player has just joined.

        oldClass (number|nil)
            The previous class index when the player switched from another class.

    Returns:
        nil

    Example Usage:
        ```lua
        hook.Add("OnPlayerJoinClass", "liaExampleOnPlayerJoinClass", function(client, class, oldClass)
            if IsValid(client) then
                print(client:Nick(), "joined class", class, "from", oldClass)
            end
        end)
        ```

    Realm:
        Server
]]
function MODULE:OnTransferred(client)
    local char = client:getChar()
    if char then
        local currentClass = char:getClass()
        if currentClass then
            local classData = lia.class.list[currentClass]
            if not classData or classData.faction ~= client:Team() then char:kickClass() end
        end
    end
end

function MODULE:CanPlayerJoinClass(client, class)
    if lia.class.hasWhitelist(class) and not client:getChar():getClasswhitelists()[class] then return false end
    return true
end

function MODULE:OnCharCreated(_, character)
    local faction = lia.faction.get(character:getFaction())
    if not faction then return end
    local items = faction.items or {}
    for _, item in pairs(items) do
        character:getInv():add(item, 1)
    end

    local defaultClass = lia.faction.getDefaultClass(character:getFaction())
    if defaultClass then
        character:setClass(defaultClass.index)
    else
        character:setClass(0)
    end

    self:EnsureFactionTracking(character, character:getPlayer(), "created")
end

function MODULE:PlayerLoadedChar(client, character)
    self:EnsureFactionTracking(character, client, "loaded")
    if character:getData("factionKickWarn") then
        client:notifyWarningLocalized("kickedFromFaction")
        hook.Run("OnTransferred", client)
        local faction = lia.faction.indices[client:Team()]
        if faction and faction.OnTransferred then faction:OnTransferred(client) end
        character:setData("factionKickWarn", nil)
    end

    local class = lia.class.list[character:getClass()]
    if character then
        if class and client:Team() == class.faction then
            local oldClass = character:getClass()
            timer.Simple(.3, function()
                if IsValid(client) then
                    character:setClass(class.index)
                    hook.Run("OnPlayerJoinClass", client, class.index, oldClass)
                end
            end)
        end

        if not class or class.faction ~= client:Team() then
            local defClass = lia.faction.getDefaultClass(client:Team())
            if defClass then
                character:setClass(defClass.index)
            else
                character:setClass(0)
            end
        end
    end
end

function MODULE:CharPreSave(character)
    self:FlushFactionPlaytime(character)
end

local function getNormalizedNPCClass(entity)
    if not IsValid(entity) or not entity:IsNPC() then return nil end
    local class = entity:GetClass()
    if class == "npc_turret_floor" then
        if not entity.liaNPCRelationsInitialized then
            timer.Simple(0, function() if IsValid(entity) then hook.Run("OnEntityCreated", entity) end end)
            entity.liaNPCRelationsInitialized = true
            return nil
        elseif bit.band(entity:GetSpawnFlags(), 512) ~= 0 then
            class = "npc_turret_floor_resistance"
        end
    elseif class == "npc_rollermine" then
        if not entity.liaNPCRelationsInitialized then
            timer.Simple(0, function() if IsValid(entity) then hook.Run("OnEntityCreated", entity) end end)
            entity.liaNPCRelationsInitialized = true
            return nil
        elseif bit.band(entity:GetSpawnFlags(), 262144) ~= 0 then
            class = "npc_rollermine_hacked"
        end
    elseif class == "npc_citizen" then
        local keys = entity:GetKeyValues()
        if not entity.liaNPCRelationsInitialized then
            timer.Simple(0, function() if IsValid(entity) then hook.Run("OnEntityCreated", entity) end end)
            entity.liaNPCRelationsInitialized = true
            return nil
        elseif keys.squadname and keys.squadname == "overwatch" then
            class = "npc_citizen_rebel_enemy"
        end
    end
    return class
end

local function debugNPCRelations(message, ...)
    lia.debug("[NPC Relations]", message, ...)
end

local function getClientNPCRelations(client)
    local character = client:getChar()
    if not character then
        debugNPCRelations("Skipped relation lookup", "player=", tostring(IsValid(client) and client:Name() or "unknown"), "reason=", "no character")
        return nil
    end

    local mergedRelations = {}
    local hasRelations = false
    local faction = lia.faction.indices[character:getFaction()]
    if faction and faction.NPCRelations then
        table.Merge(mergedRelations, faction.NPCRelations)
        hasRelations = true
    end

    local class = lia.class.list[character:getClass()]
    if class and class.faction == character:getFaction() and class.NPCRelations then
        table.Merge(mergedRelations, class.NPCRelations)
        hasRelations = true
    end

    local overriddenRelations = hook.Run("GetNPCRelations", client, hasRelations and mergedRelations or nil)
    if overriddenRelations ~= nil then
        debugNPCRelations("Resolved relations override", "player=", tostring(client:Name()), "faction=", tostring(faction and faction.uniqueID or "nil"), "class=", tostring(character:getClass()), "relationCount=", tostring(istable(overriddenRelations) and table.Count(overriddenRelations) or 0), "source=", "hook")
        return overriddenRelations
    end

    debugNPCRelations("Resolved relations", "player=", tostring(client:Name()), "faction=", tostring(faction and faction.uniqueID or "nil"), "class=", tostring(character:getClass()), "relationCount=", tostring(hasRelations and table.Count(mergedRelations) or 0), "source=", hasRelations and "faction/class merge" or "default hostile")
    return hasRelations and mergedRelations or nil
end

local function applyNPCRelation(entity, client)
    if not IsValid(entity) or not entity:IsNPC() or not IsValid(client) then return end
    local rawClass = entity:GetClass()
    local npcClass = getNormalizedNPCClass(entity)
    if not npcClass then
        debugNPCRelations("Deferred NPC relation application", "entity=", tostring(entity), "rawClass=", tostring(rawClass), "player=", tostring(client:Name()))
        return
    end

    local relations = getClientNPCRelations(client)
    if istable(relations) and relations[npcClass] then
        entity:AddEntityRelationship(client, relations[npcClass], 0)
        debugNPCRelations("Applied specific relation", "entity=", tostring(entity), "rawClass=", tostring(rawClass), "normalizedClass=", tostring(npcClass), "player=", tostring(client:Name()), "disposition=", tostring(relations[npcClass]))
    elseif relations == nil then
        entity:AddEntityRelationship(client, D_HT, 0)
        debugNPCRelations("Applied default hostile relation", "entity=", tostring(entity), "rawClass=", tostring(rawClass), "normalizedClass=", tostring(npcClass), "player=", tostring(client:Name()), "disposition=", tostring(D_HT))
    else
        debugNPCRelations("No matching relation entry", "entity=", tostring(entity), "rawClass=", tostring(rawClass), "normalizedClass=", tostring(npcClass), "player=", tostring(client:Name()))
    end
end

function MODULE:UpdateNPCRelations(client)
    if not IsValid(client) or not client:getChar() then return end
    debugNPCRelations("Refreshing NPC relations", "player=", tostring(client:Name()))
    for _, entity in ents.Iterator() do
        applyNPCRelation(entity, client)
    end
end

local function applyAttributes(client, attr)
    if not attr then return end
    local offset = Vector(0, 0, 64)
    local offsetDuck = Vector(0, 0, 28)
    client:SetViewOffset(offset)
    client:SetViewOffsetDucked(offsetDuck)
    client:SetModelScale(1)
    MODULE:UpdateNPCRelations(client)
    if attr.scale and attr.scale ~= 1 then
        client:SetViewOffset(offset * attr.scale)
        client:SetViewOffsetDucked(offsetDuck * attr.scale)
        client:SetModelScale(attr.scale)
    end

    local configRunSpeed = lia.config.get("RunSpeed")
    local configWalkSpeed = lia.config.get("WalkSpeed")
    if attr.runSpeed then
        client:SetRunSpeed(math.Round(configRunSpeed * attr.runSpeed))
    else
        client:SetRunSpeed(configRunSpeed)
    end

    if attr.walkSpeed then
        client:SetWalkSpeed(math.Round(configWalkSpeed * attr.walkSpeed))
    else
        client:SetWalkSpeed(configWalkSpeed)
    end

    if attr.jumpPower then client:SetJumpPower(math.Round(client:GetJumpPower() * attr.jumpPower)) end
    client:SetBloodColor(attr.bloodcolor or BLOOD_COLOR_RED)
    if attr.health then
        client:SetMaxHealth(attr.health)
        client:SetHealth(attr.health)
    end

    if attr.armor then client:SetArmor(attr.armor) end
    if attr.OnSpawn then attr:OnSpawn(client) end
    if attr.weapons then
        if istable(attr.weapons) then
            for _, weapon in ipairs(attr.weapons) do
                client:Give(weapon, true)
            end
        else
            client:Give(attr.weapons, true)
        end
    end
end

function MODULE:CanCharBeTransfered(character, faction)
    if faction.oneCharOnly then
        for _, otherCharacter in next, lia.char.getAll() do
            if otherCharacter.steamID == character.steamID and faction.index == otherCharacter:getFaction() then return false, L("charAlreadyInFaction") end
        end
    end
end

function MODULE:OnEntityCreated(entity)
    if not IsValid(entity) or not entity:IsNPC() then return end
    for _, client in player.Iterator() do
        applyNPCRelation(entity, client)
    end
end

function MODULE:PlayerSpawn(client)
    self:UpdateNPCRelations(client)
end

function MODULE:OnCharVarChanged(character, key, oldValue, newValue)
    if key ~= "faction" or oldValue == nil or oldValue == 0 then return end
    local client = character:getPlayer()
    if IsValid(client) then self:UpdateNPCRelations(client) end
end

function MODULE:OnPlayerSwitchClass(client)
    self:UpdateNPCRelations(client)
end

function MODULE:PostPlayerLoadout(client)
    local character = client:getChar()
    if not character then return end
    local faction = lia.faction.indices[character:getFaction()]
    local class = lia.class.list[character:getClass()]
    if class and class.faction ~= client:Team() then class = nil end
    timer.Simple(0.2, function()
        if IsValid(client) then
            local mergedAttr = {}
            if faction then
                for k, v in pairs(faction) do
                    mergedAttr[k] = v
                end
            end

            if class then
                for k, v in pairs(class) do
                    mergedAttr[k] = v
                end

                if class.model then
                    local appliedClassModel
                    if isstring(class.model) then
                        client:SetModel(class.model)
                        appliedClassModel = true
                    elseif istable(class.model) then
                        local selected = character:getData("classModel")
                        if isstring(selected) and selected ~= "" and (not util or not util.IsValidModel or util.IsValidModel(selected)) then
                            client:SetModel(selected)
                            appliedClassModel = true
                        end
                    end

                    if appliedClassModel then
                        lia.util.applyBodygroups(client, character:getBodygroups())
                        client:SetSkin(character:getSkin())
                    end
                end
            end

            applyAttributes(client, mergedAttr)
        end
    end)
end

function MODULE:CanPlayerUseChar(client, character)
    local faction = lia.faction.indices[character:getFaction()]
    if faction and hook.Run("CheckFactionLimitReached", faction, character, client) then return false, L("limitFaction") end
end

function MODULE:CanPlayerSwitchChar(client, currentCharacter, newCharacter)
    local faction = lia.faction.indices[newCharacter:getFaction()]
    if faction and self:CheckFactionLimitReached(faction, newCharacter, client) then return false, L("limitFaction") end
end

lia.command.add("speed", {
    desc = "@speedCommandDesc",
    onRun = function(client)
        client:notifyLocalized("speedCommandStatus", client:GetRunSpeed(), client:GetWalkSpeed())
        return ""
    end
})

local TRACKED_FACTION_KEYS = {
    factionJoinDates = true,
    factionPlaytime = true,
    factionTransferHistory = true,
    factionNotes = true
}

local function getFactionUniqueID(factionValue)
    if istable(factionValue) then factionValue = factionValue.uniqueID or factionValue.index end
    if isstring(factionValue) then
        local faction = lia.faction.get(factionValue)
        return faction and faction.uniqueID or factionValue
    elseif isnumber(factionValue) then
        local faction = lia.faction.indices[factionValue] or lia.faction.get(factionValue)
        return faction and faction.uniqueID or nil
    end
end

local function sanitizeFactionHistory(history)
    if not istable(history) then return {} end
    local sanitized = {}
    for _, entry in ipairs(history) do
        if istable(entry) then
            sanitized[#sanitized + 1] = {
                at = tonumber(entry.at) or os.time(),
                from = entry.from,
                to = entry.to,
                byName = entry.byName,
                bySteamID = entry.bySteamID,
                reason = entry.reason
            }
        end
    end
    return sanitized
end

local function trimFactionHistory(history, maxEntries)
    maxEntries = maxEntries or 24
    while #history > maxEntries do
        table.remove(history, #history)
    end
    return history
end

local function decodeTrackedFactionRow(value)
    if not value or value == "" then return nil end
    local ok, decoded = pcall(pon.decode, value)
    if not ok or not istable(decoded) then return nil end
    return decoded[1]
end

function MODULE:CanAccessFactionRoster(client, factionUniqueID)
    if not IsValid(client) then return false end
    if client:hasPrivilege("listCharacters") or client:hasPrivilege("canManageFactions") then return true end
    local character = client:getChar()
    if not character or not character:hasFlags("F") then return false end
    return getFactionUniqueID(character:getFaction()) == getFactionUniqueID(factionUniqueID)
end

function MODULE:CanEditFactionNotes(client, factionUniqueID)
    return self:CanAccessFactionRoster(client, factionUniqueID)
end

function MODULE:FlushFactionPlaytime(character, now)
    if not character then return 0 end
    now = tonumber(now) or os.time()
    local factionUniqueID = getFactionUniqueID(character:getFaction())
    local sessionStart = tonumber(character.liaFactionSessionStart or 0)
    if not factionUniqueID or sessionStart <= 0 or now <= sessionStart then
        character.liaFactionSessionStart = now
        return 0
    end

    local playtimeByFaction = character:getData("factionPlaytime", {})
    if not istable(playtimeByFaction) then playtimeByFaction = {} end
    local elapsed = now - sessionStart
    playtimeByFaction[factionUniqueID] = (tonumber(playtimeByFaction[factionUniqueID]) or 0) + elapsed
    character:setData("factionPlaytime", playtimeByFaction, true)
    character.liaFactionSessionStart = now
    return elapsed
end

function MODULE:EnsureFactionTracking(character, actor, reason)
    if not character then return end
    local factionUniqueID = getFactionUniqueID(character:getFaction())
    if not factionUniqueID then return end
    local now = os.time()
    local joinDates = character:getData("factionJoinDates", {})
    if not istable(joinDates) then joinDates = {} end
    if not tonumber(joinDates[factionUniqueID]) then
        joinDates[factionUniqueID] = now
        character:setData("factionJoinDates", joinDates, true)
        local history = sanitizeFactionHistory(character:getData("factionTransferHistory", {}))
        table.insert(history, 1, {
            at = now,
            from = nil,
            to = factionUniqueID,
            byName = IsValid(actor) and actor:Name() or nil,
            bySteamID = IsValid(actor) and actor:SteamID() or nil,
            reason = reason or "created"
        })

        trimFactionHistory(history)
        character:setData("factionTransferHistory", history, true)
    end

    character.liaFactionSessionStart = now
end

function MODULE:TrackFactionTransfer(character, oldFactionValue, newFactionValue, actor, reason)
    if not character then return end
    local oldFactionUniqueID = getFactionUniqueID(oldFactionValue)
    local newFactionUniqueID = getFactionUniqueID(newFactionValue)
    if oldFactionUniqueID == newFactionUniqueID and newFactionUniqueID then
        self:EnsureFactionTracking(character, actor, reason)
        return
    end

    local now = os.time()
    if oldFactionUniqueID then self:FlushFactionPlaytime(character, now) end
    local joinDates = character:getData("factionJoinDates", {})
    if not istable(joinDates) then joinDates = {} end
    if newFactionUniqueID then joinDates[newFactionUniqueID] = now end
    character:setData("factionJoinDates", joinDates, true)
    local history = sanitizeFactionHistory(character:getData("factionTransferHistory", {}))
    table.insert(history, 1, {
        at = now,
        from = oldFactionUniqueID,
        to = newFactionUniqueID,
        byName = IsValid(actor) and actor:Name() or nil,
        bySteamID = IsValid(actor) and actor:SteamID() or nil,
        reason = reason or "transferred"
    })

    trimFactionHistory(history)
    character:setData("factionTransferHistory", history, true)
    character.liaFactionSessionStart = now
end

function MODULE:TrackOfflineFactionTransfer(charID, oldFactionValue, newFactionValue, actor, reason)
    charID = tonumber(charID)
    if not charID then return end
    local joinDates = lia.char.getCharData(charID, "factionJoinDates")
    if not istable(joinDates) then joinDates = {} end
    local newFactionUniqueID = getFactionUniqueID(newFactionValue)
    if newFactionUniqueID then joinDates[newFactionUniqueID] = os.time() end
    lia.char.setCharDatabase(charID, "factionJoinDates", joinDates)
    local history = sanitizeFactionHistory(lia.char.getCharData(charID, "factionTransferHistory"))
    table.insert(history, 1, {
        at = os.time(),
        from = getFactionUniqueID(oldFactionValue),
        to = newFactionUniqueID,
        byName = IsValid(actor) and actor:Name() or nil,
        bySteamID = IsValid(actor) and actor:SteamID() or nil,
        reason = reason or "transferred"
    })

    trimFactionHistory(history)
    lia.char.setCharDatabase(charID, "factionTransferHistory", history)
end

function MODULE:BuildFactionMembersPayload(client, factionUniqueID, callback)
    local faction = lia.faction.get(factionUniqueID)
    if not faction then
        if callback then
            callback({
                faction = factionUniqueID,
                members = {}
            })
        end
        return
    end

    local gamemode = SCHEMA and SCHEMA.folder or engine.ActiveGamemode()
    local query = string.format([[
        SELECT c.id, c.name, c.lastJoinTime, c.steamID, c.class, c.playtime
        FROM lia_characters AS c
        WHERE c.faction = %s AND c.schema = %s
        ORDER BY c.lastJoinTime DESC
    ]], lia.db.convertDataType(faction.uniqueID), lia.db.convertDataType(gamemode))
    lia.db.query(query, function(data)
        local rows = data or {}
        local ids = {}
        for _, row in ipairs(rows) do
            local charID = tonumber(row.id)
            if charID then ids[#ids + 1] = charID end
        end

        local function finish()
            local members = {}
            for _, row in ipairs(rows) do
                local charID = tonumber(row.id) or row.id
                local lastOnlineText
                local owner = lia.char.getOwnerByID(charID)
                if not IsValid(owner) and row.steamID then
                    local ply = player.GetBySteamID(tostring(row.steamID))
                    local ownerChar = IsValid(ply) and ply:getChar() or nil
                    if ownerChar and ownerChar:getID() == tonumber(charID) then owner = ply end
                end

                local ownerChar = IsValid(owner) and owner:getChar() or nil
                if ownerChar and ownerChar:getID() == tonumber(charID) then
                    lastOnlineText = L("onlineNow")
                else
                    lastOnlineText = row.lastJoinTime or L("unknown")
                end

                local classIndex = tonumber(row.class) or 0
                local classData = lia.class.list[classIndex]
                members[#members + 1] = {
                    name = row.name or L("unknown"),
                    lastOnline = lastOnlineText,
                    lastActive = row.lastJoinTime or L("unknown"),
                    charID = charID,
                    steamID = row.steamID,
                    class = classIndex,
                    className = classData and classData.name or nil,
                    playtime = tonumber(row.playtime) or 0
                }
            end

            if callback then
                callback({
                    faction = faction.uniqueID,
                    members = members
                })
            end
        end

        finish()
    end)
end

function MODULE:SendFactionMembers(client, factionUniqueID)
    self:BuildFactionMembersPayload(client, factionUniqueID, function(payload) lia.net.writeBigTable(client, "liaFactionMembers", payload) end)
end

function MODULE:BuildFactionMemberDetailsPayload(client, factionUniqueID, charID, callback)
    local faction = lia.faction.get(factionUniqueID)
    charID = tonumber(charID)
    if not faction or not charID then
        if callback then
            callback({
                faction = factionUniqueID,
                charID = charID
            })
        end
        return
    end

    local gamemode = SCHEMA and SCHEMA.folder or engine.ActiveGamemode()
    local query = string.format([[
        SELECT c.id, c.name, c.lastJoinTime, c.steamID, c.class, c.playtime
        FROM lia_characters AS c
        WHERE c.id = %s AND c.faction = %s AND c.schema = %s
        LIMIT 1
    ]], charID, lia.db.convertDataType(faction.uniqueID), lia.db.convertDataType(gamemode))
    lia.db.query(query, function(data)
        local row = data and data[1]
        if not row then
            if callback then
                callback({
                    faction = faction.uniqueID,
                    charID = charID
                })
            end
            return
        end

        local trackedKeys = {}
        for key in pairs(TRACKED_FACTION_KEYS) do
            trackedKeys[#trackedKeys + 1] = "'" .. lia.db.escape(key) .. "'"
        end

        lia.db.query(string.format("SELECT charID, key, value FROM lia_chardata WHERE charID = %d AND key IN (%s)", charID, table.concat(trackedKeys, ",")), function(extraRows)
            local charData = {}
            for _, extraRow in ipairs(extraRows or {}) do
                charData[extraRow.key] = decodeTrackedFactionRow(extraRow.value)
            end

            local owner = lia.char.getOwnerByID(charID)
            if not IsValid(owner) and row.steamID then
                local ply = player.GetBySteamID(tostring(row.steamID))
                local ownerChar = IsValid(ply) and ply:getChar() or nil
                if ownerChar and ownerChar:getID() == charID then owner = ply end
            end

            local ownerChar = IsValid(owner) and owner:getChar() or nil
            if ownerChar and ownerChar.getData then
                for key in pairs(TRACKED_FACTION_KEYS) do
                    charData[key] = ownerChar:getData(key, charData[key])
                end
            end

            local now = os.time()
            local classIndex = tonumber(row.class) or 0
            local classData = lia.class.list[classIndex]
            local joinDates = istable(charData.factionJoinDates) and charData.factionJoinDates or {}
            local joinDate = tonumber(joinDates[faction.uniqueID]) or nil
            local factionPlaytime = istable(charData.factionPlaytime) and charData.factionPlaytime or {}
            local playtimeInFaction = tonumber(factionPlaytime[faction.uniqueID]) or 0
            local lastOnlineText = row.lastJoinTime or L("unknown")
            if ownerChar and ownerChar:getID() == charID then
                lastOnlineText = L("onlineNow")
                if ownerChar:getFaction() == faction.index and tonumber(ownerChar.liaFactionSessionStart or 0) > 0 then playtimeInFaction = playtimeInFaction + math.max(0, now - tonumber(ownerChar.liaFactionSessionStart)) end
            end

            local notesByFaction = istable(charData.factionNotes) and charData.factionNotes or {}
            local noteData = notesByFaction[faction.uniqueID]
            local member = {
                name = row.name or L("unknown"),
                lastOnline = lastOnlineText,
                lastActive = row.lastJoinTime or L("unknown"),
                charID = charID,
                steamID = row.steamID,
                class = classIndex,
                className = classData and classData.name or nil,
                playtime = tonumber(row.playtime) or 0,
                joinDate = joinDate,
                timeInFaction = joinDate and math.max(0, now - joinDate) or 0,
                playtimeInFaction = playtimeInFaction,
                transferHistory = sanitizeFactionHistory(charData.factionTransferHistory),
                factionNote = istable(noteData) and tostring(noteData.text or "") or isstring(noteData) and noteData or "",
                factionNoteMeta = istable(noteData) and {
                    updatedAt = tonumber(noteData.updatedAt) or nil,
                    updatedBy = noteData.updatedBy,
                    updatedBySteamID = noteData.updatedBySteamID
                } or nil
            }

            if callback then
                callback({
                    faction = faction.uniqueID,
                    charID = charID,
                    member = member
                })
            end
        end)
    end)
end

function MODULE:SendFactionMemberDetails(client, factionUniqueID, charID)
    self:BuildFactionMemberDetailsPayload(client, factionUniqueID, charID, function(payload) lia.net.writeBigTable(client, "liaFactionMemberDetails", payload) end)
end
