local character = lia.meta.character

do
    function character:doesRecognize(id)
        if type(id) ~= "number" and id.getID then
            id = id:getID()
        end

        return hook.Run("IsCharRecognized", self, id) ~= false
    end
end

function PLUGIN:IsCharRecognized(char, id)
    local other = lia.char.loaded[id]

    if other then
        local faction = lia.faction.indices[other:getFaction()]
        if faction and faction.isGloballyRecognized then return end
        if char:getFaction() == other:getFaction() and not self.noRecognise[char:getFaction()] and not self.noRecognise[other:getFaction()] then return end
        if char:getFaction() == FACTION_STAFF and other:getFaction() ~= FACTION_STAFF then return true end
    end

    local recognized = char:getData("rgn", "")
    if recognized == "" then return false end
    if not recognized:find("," .. id .. ",") then return false end
end