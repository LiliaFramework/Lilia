function RecognitionCore:isCharRecognized(char, id)
    local client = char:getPlayer()
    local recognized = char:getData("rgn", "")
    local other = lia.char.loaded[id]
    local otherclient = other:getPlayer()
    if not IsValid(otherclient) then return false end
    if char.id == id then return true end
    local faction = lia.faction.indices[other:getFaction()]
    if faction and faction.isGloballyRecognized then return true end
    if self.FactionAutoRecognize and (char:getFaction() == other:getFaction() and (self.MemberToMemberAutoRecognition[char:getFaction()] and self.MemberToMemberAutoRecognition[other:getFaction()])) then return true end
    if client:isStaffOnDuty() or otherclient:isStaffOnDuty() then return true end
    if recognized ~= "" and recognized:find("," .. id .. ",") then return true end
    return false
end

function RecognitionCore:isCharFakeRecognized(char, id)
    local other = lia.char.loaded[id]
    local CharNameList = char:getRecognizedAs()
    local clientName = CharNameList[other:getID()]
    return self.FakeNamesEnabled and self:isFakeNameExistant(clientName, CharNameList)
end

function RecognitionCore:isFakeNameExistant(clientName, CharNameList)
    for _, n in pairs(CharNameList) do
        if n == clientName then return true end
    end
    return false
end

lia.char.registerVar("RecognizedAs", {
    field = "recognized_as",
    default = {},
    noDisplay = true
})