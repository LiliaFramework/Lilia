--[[
    Hooks:
        ShouldAllowScoreboardOverride(Player client, string var)

    Purpose:
        Determines whether scoreboard and voice UI should use recognition-safe replacements for a player's visible data.

    Category:
        Recognition

    Parameters:
        client (Player)
            The player whose displayed information is being evaluated.

        var (string)
            The specific field being checked, such as `name`, `model`, `desc`, or `classlogo`.

    Returns:
        boolean|nil
            Return true to use the recognition override for that field, or false to keep the original value.

    Example Usage:
        ```lua
        hook.Add("ShouldAllowScoreboardOverride", "liaExampleShouldAllowScoreboardOverride", function(client, var)
            if var == "name" and client == LocalPlayer() then
                return false
            end
        end)
        ```

    Realm:
        Client
]]
local ChatIsRecognized = {
    ic = true,
    y = true,
    w = true,
    me = true,
}

--[[
    Hooks:
        GetDisplayedDescription(Player client, boolean isHUD)

    Purpose:
        Allows modules to override the description shown for a player when recognition rules hide their normal description.

    Category:
        Recognition

    Parameters:
        client (Player)
            The player whose description is being displayed.

        isHUD (boolean)
            Whether the description is being requested for a HUD or world display instead of the scoreboard.

    Returns:
        string|nil
            Return a replacement description string. Returning nil allows the default recognition-aware description logic to continue.

    Example Usage:
        ```lua
        hook.Add("GetDisplayedDescription", "liaExampleGetDisplayedDescription", function(client, isHUD)
            if isHUD and IsValid(client) and client:isStaffOnDuty() then
                return "Staff member"
            end
        end)
        ```

    Realm:
        Client
]]
function MODULE:GetDisplayedDescription(client, isHUD)
    local lp = LocalPlayer()
    if not IsValid(client) or not IsValid(lp) then return L("unknown") end
    if client:getChar() and client ~= lp and lp:getChar() and not lp:getChar():doesRecognize(client:getChar():getID()) then
        if isHUD then return client:getChar():getDesc() end
        return L("noRecog")
    end
end

function MODULE:GetDisplayedName(client, chatType)
    local lp = LocalPlayer()
    if not IsValid(client) or not IsValid(lp) then return L("unknown") end
    local character = client:getChar()
    local ourCharacter = lp:getChar()
    if not character or not ourCharacter then return L("unknown") end
    local myReg = ourCharacter:getFakeName()
    local characterID = character:getID()
    if not ourCharacter:doesRecognize(characterID) then
        if ourCharacter:doesFakeRecognize(characterID) and myReg[characterID] then return myReg[characterID] end
        if chatType and (ChatIsRecognized[chatType] or hook.Run("IsRecognizedChatType", chatType)) then return "[" .. L("unknown") .. "]" end
        return L("unknown")
    end
end

function MODULE:ShouldAllowScoreboardOverride(client, var)
    if client == LocalPlayer() then return false end
    if not IsValid(client) or not IsValid(LocalPlayer()) then return false end
    local character = client:getChar()
    local ourCharacter = LocalPlayer():getChar()
    if not character or not ourCharacter then return false end
    local isRecognitionEnabled = lia.config.get("RecognitionEnabled", true)
    local isVarHiddenInScoreboard = var == "name" or var == "model" or var == "desc" or var == "classlogo"
    local isNotRecognized = not (ourCharacter:doesRecognize(character:getID()) or ourCharacter:doesFakeRecognize(character:getID()))
    return isRecognitionEnabled and isVarHiddenInScoreboard and isNotRecognized
end
