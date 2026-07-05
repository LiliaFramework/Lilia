local function isFakeNameExistant(name, nameList)
    for _, n in pairs(nameList) do
        if n == name then return true end
    end
    return false
end

--[[
    Hooks:
        IsCharRecognized(Character character, number id)

    Purpose:
        Allows modules to override whether one character should fully recognize another character.

    Category:
        Recognition

    Parameters:
        character (Character)
            The character whose recognition list is being checked.

        id (number)
            The target character ID being tested.

    Returns:
        boolean|nil
            Return true to force recognition or false to deny it. Returning nil allows the default recognition rules to continue.

    Example Usage:
        ```lua
        hook.Add("IsCharRecognized", "liaExampleIsCharRecognized", function(character, id)
            if character and character:getID() == id then
                return true
            end
        end)
        ```

    Realm:
        Shared
]]
function MODULE:IsCharRecognized(character, id)
    if not lia.config.get("RecognitionEnabled", true) then return true end
    if not character or not isfunction(character.getPlayer) then return false end
    local client = character:getPlayer()
    if not IsValid(client) then return false end
    if character.id == id then return true end
    local other = lia.char.getCharacter(id, client)
    local otherClient = other and other.getPlayer and other:getPlayer() or nil
    if not IsValid(otherClient) then return false end
    local factionID = character.getFaction and character:getFaction() or nil
    local faction = factionID and lia.faction.indices[factionID] or nil
    local otherFactionID = other and other.getFaction and other:getFaction() or nil
    local otherFaction = otherFactionID and lia.faction.indices[otherFactionID] or nil
    if faction and faction.uniqueID == "staff" then return true end
    if otherFaction and otherFaction.uniqueID == "staff" then return true end
    if faction and faction.RecognizesGlobally then return true end
    if otherFaction then
        if otherFaction.isGloballyRecognized then return true end
        if factionID and factionID == otherFactionID and otherFaction.MemberToMemberAutoRecognition then return true end
    end

    local clientOnDuty = isfunction(client.isStaffOnDuty) and client:isStaffOnDuty() or false
    local otherOnDuty = isfunction(otherClient.isStaffOnDuty) and otherClient:isStaffOnDuty() or false
    if clientOnDuty or otherOnDuty then return true end
    local recognized = tostring(character:getRecognition() or "")
    if recognized:find("," .. tostring(id) .. ",", 1, true) then return true end
    return false
end

--[[
    Hooks:
        IsCharFakeRecognized(Character character, number id)

    Purpose:
        Allows modules to override whether one character should see a fake recognized name for another character.

    Category:
        Recognition

    Parameters:
        character (Character)
            The character whose fake recognition table is being checked.

        id (number)
            The target character ID being tested.

    Returns:
        boolean|nil
            Return true to force fake recognition or false to block it. Returning nil allows the default fake-name checks to continue.

    Example Usage:
        ```lua
        hook.Add("IsCharFakeRecognized", "liaExampleIsCharFakeRecognized", function(character, id)
            if character and character:getData("alwaysFakeRecognize") then
                return true
            end
        end)
        ```

    Realm:
        Shared
]]
function MODULE:IsCharFakeRecognized(character, id)
    if not character or not character.getPlayer then return false end
    local other = lia.char.getCharacter(id, character:getPlayer())
    if not other then return false end
    local CharNameList = character:getFakeName()
    local clientName = CharNameList[other:getID()]
    return lia.config.get("FakeNamesEnabled", false) and isFakeNameExistant(clientName, CharNameList)
end
