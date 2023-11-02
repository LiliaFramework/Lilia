--------------------------------------------------------------------------------------------------------------------------
function MODULE:IsCharRecognized(char, id)
    if char.id == id then return true end
    local other = lia.char.loaded[id]
    local recognized = char:getData("rgn", "")
    local faction = lia.faction.indices[other:getFaction()]
    if other and faction then
        if faction.isGloballyRecognized then return true end
        if lia.config.FactionAutoRecognize and (char:getFaction() == other:getFaction() and (lia.config.MemberToMemberAutoRecognition[char:getFaction()] and lia.config.MemberToMemberAutoRecognition[other:getFaction()])) then return true end
        if lia.config.StaffAutoRecognize and char:getFaction() == FACTION_STAFF then return true end
    end

    if recognized == "" then return false end
    if recognized:find("," .. id .. ",") then return true end
end

--------------------------------------------------------------------------------------------------------------------------
lia.char.registerVar(
    "CharsWeKnow",
    {
        field = "chars_we_know",
        default = {},
        noDisplay = true
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.char.registerVar(
    "RecognizedAs",
    {
        field = "recognized_as",
        default = {},
        noDisplay = true
    }
)
--------------------------------------------------------------------------------------------------------------------------