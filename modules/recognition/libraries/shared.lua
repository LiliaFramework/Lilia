local function isFakeNameExistant(name, nameList)
    for _, n in pairs(nameList) do
        if n == name then return true end
    end
    return false
end

function MODULE:isCharRecognized(character, id)
    if not lia.config.get("RecognitionEnabled", true) then return true end
    local client = character:getPlayer()
    local recognized = character:getData("rgn", "")
    local other = lia.char.loaded[id]
    local otherclient = other and other:getPlayer()
    if not IsValid(otherclient) then return false end
    if character.id == id then return true end
    local factionID = character:getFaction()
    local faction = factionID and lia.faction.indices[factionID]
    if faction and faction.RecognizesGlobally then return true end
    local otherFactionID = other and other:getFaction()
    local otherFaction = otherFactionID and lia.faction.indices[otherFactionID]
    if otherFaction then
        if otherFaction.isGloballyRecognized then return true end
        if factionID == otherFactionID and otherFaction.MemberToMemberAutoRecognition then return true end
    end

    if client:isStaffOnDuty() or otherclient:isStaffOnDuty() then return true end
    if recognized ~= "" and recognized:find("," .. id .. ",") then return true end
    return false
end

function MODULE:isCharFakeRecognized(character, id)
    local other = lia.char.loaded[id]
    local CharNameList = character:getRecognizedAs()
    local clientName = CharNameList[other:getID()]
    return lia.config.get("FakeNamesEnabled", false) and isFakeNameExistant(clientName, CharNameList)
end
