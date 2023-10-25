--------------------------------------------------------------------------------------------------------------------------
function lia.faction.hasWhitelist(faction)
    local data = lia.faction.indices[faction]
    if data then
        if data.isDefault then return true end
        local liaData = lia.localData and lia.localData.whitelists or {}

        return liaData[SCHEMA.folder] and liaData[SCHEMA.folder][data.uniqueID] == true or false
    end

    return false
end
--------------------------------------------------------------------------------------------------------------------------