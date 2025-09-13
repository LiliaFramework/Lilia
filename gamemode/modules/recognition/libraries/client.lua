local ChatIsRecognized = {
    ic = true,
    y = true,
    w = true,
    me = true,
}

function MODULE:isRecognizedChatType(chatType)
    return ChatIsRecognized[chatType] or false
end

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
        if chatType and hook.Run("isRecognizedChatType", chatType) then return "[" .. L("unknown") .. "]" end
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

net.Receive("rgnDone", function()
    local client = LocalPlayer()
    hook.Run("OnCharRecognized", client, client:getChar():getID())
end)
