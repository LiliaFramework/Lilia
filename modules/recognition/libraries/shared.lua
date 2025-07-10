local function isFakeNameExistant(name, nameList)
    for _, n in pairs(nameList) do
        if n == name then return true end
    end
    return false
end

function MODULE:isCharRecognized(character, id)
    local result, reason = false, "Not recognized"
    if not lia.config.get("RecognitionEnabled", true) then
        result, reason = true, "Recognition disabled"
    else
        local client = character:getPlayer()
        local other = lia.char.loaded[id]
        local otherclient = other and other:getPlayer()
        if not IsValid(otherclient) then
            result, reason = false, "Other client invalid"
        elseif character.id == id then
            result, reason = true, "Same character"
        else
            local factionID = character:getFaction()
            local faction = factionID and lia.faction.indices[factionID]
            if faction and faction.RecognizesGlobally then
                result, reason = true, "Faction recognizes globally"
            else
                local otherFactionID = other:getFaction()
                local otherFaction = lia.faction.indices[otherFactionID]
                if otherFaction then
                    if otherFaction.isGloballyRecognized then
                        result, reason = true, "Other faction recognizes globally"
                    elseif factionID == otherFactionID and otherFaction.MemberToMemberAutoRecognition then
                        result, reason = true, "Member-to-member auto recognition"
                    end
                end

                if not result then
                    if client:isStaffOnDuty() or otherclient:isStaffOnDuty() then
                        result, reason = true, "Staff on duty"
                    else
                        local recognized = character:getRecognition() or ""
                        if recognized:find("," .. id .. ",") then result, reason = true, "Previously recognized" end
                    end
                end
            end
        end
    end

    print("isCharRecognized reason: " .. reason)
    return result
end

function MODULE:isCharFakeRecognized(character, id)
    local other = lia.char.loaded[id]
    local CharNameList = character:getRecognizedAs()
    local clientName = CharNameList[other:getID()]
    return lia.config.get("FakeNamesEnabled", false) and isFakeNameExistant(clientName, CharNameList)
end
