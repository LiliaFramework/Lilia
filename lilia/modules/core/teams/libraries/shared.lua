﻿function MODULE:CheckFactionLimitReached(faction, character, client)
    if faction.OnCheckLimitReached then return faction:OnCheckLimitReached(character, client) end
    if faction.onCheckLimitReached then
        LiliaDeprecated("onCheckLimitReached is deprecated. Use OnCheckLimitReached for optimization purposes.")
        return faction:onCheckLimitReached(character, client)
    end

    if not isnumber(faction.limit) then return false end
    local maxPlayers = faction.limit
    if faction.limit < 1 then maxPlayers = math.Round(player.GetCount() * faction.limit) end
    return team.NumPlayers(faction.index) >= maxPlayers
end

function MODULE:GetDefaultCharName(client, faction, data)
    local info = lia.faction.indices[faction]
    if info and isfunction(info.nameTemplate) then
        local name, override = info:nameTemplate(client)
        if override then return name, true end
    end

    local prefix = info and (isfunction(info.prefix) and info.prefix(client) or info.prefix) or ""
    if not prefix or prefix == "" then return data, false end
    local nameWithPrefix = string.Trim(prefix .. " " .. data)
    if info then
        if info.GetDefaultName then return info:GetDefaultName(client) end
        if info.getDefaultName then
            LiliaDeprecated("getDefaultName is deprecated. Use GetDefaultName for optimization purposes.")
            return info:getDefaultName(client)
        end
    end
    return nameWithPrefix, false
end

function MODULE:GetDefaultCharDesc(client, faction)
    local info = lia.faction.indices[faction]
    if info then
        if info.getDefaultDesc then
            LiliaDeprecated("getDefaultDesc is deprecated. Use GetDefaultDesc for optimization purposes.")
            return info:getDefaultDesc(client)
        end

        if info.GetDefaultDesc then return info:GetDefaultDesc(client) end
    end
end

function MODULE:DrawCharInfo(client, _, info)
    if not self.ClassDisplay then return end
    local charClass = client:getClassData()
    if charClass then
        local classColor = charClass.color or Color(255, 255, 255)
        local className = charClass.name or "Undefined"
        info[#info + 1] = {className, classColor}
    end
end