
local character = lia.meta.character

function character:doesRecognize(id)
    if not isnumber(id) and id.getID then
        id = id:getID()
    end

    return hook.Run("IsCharRecognized", self, id) ~= false
end


function MODULE:IsCharRecognized(char, id)
    if char.id == id then return true end
    local other = lia.char.loaded[id]
    if other then
        local faction = lia.faction.indices[other:getFaction()]
        if lia.config.FactionAutoRecognize and char:getFaction() == other:getFaction() and not lia.config.noRecognise[char:getFaction()] and not lia.config.noRecognise[other:getFaction()] then return end
        if lia.config.StaffAutoRecognize and char:getFaction() == FACTION_STAFF and other:getFaction() ~= FACTION_STAFF then return true end
    end

    local recognized = char:getData("rgn", "")
    if recognized == "" then return false end
    if not recognized:find("," .. id .. ",") then return false end
    if recognized ~= "" and recognized:find("," .. id .. ",") then return true end
end

