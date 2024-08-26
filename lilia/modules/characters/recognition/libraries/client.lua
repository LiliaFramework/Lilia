function MODULE:isRecognizedChatType(chatType)
    return table.HasValue(self.ChatIsRecognized, chatType)
end

function MODULE:GetDisplayedDescription(client, isHUD)
    local lp = LocalPlayer()
    if not IsValid(client) or not IsValid(lp) then return L"unknown" end
    if client:getChar() and client ~= lp and lp:getChar() and not lp:getChar():doesRecognize(client:getChar():getID()) then
        if isHUD then return client:getChar():getDesc() end
        return L"noRecog"
    end
end

function MODULE:GetDisplayedName(client, chatType)
    local lp = LocalPlayer()
    if not IsValid(client) or not IsValid(lp) then return L"unknown" end
    local character = client:getChar()
    local ourCharacter = lp:getChar()
    if not character or not ourCharacter then return L"unknown" end
    local myReg = ourCharacter:getRecognizedAs()
    local characterID = character:getID()
    if not ourCharacter:doesRecognize(characterID) then
        if ourCharacter:doesFakeRecognize(characterID) and myReg[characterID] then return myReg[characterID] end
        if chatType and hook.Run("isRecognizedChatType", chatType) then return "[" .. L"unknown" .. "]" end
        return L"unknown"
    end
end

function MODULE:ShouldAllowScoreboardOverride(client, var)
    local lp = LocalPlayer()
    if not IsValid(client) or not IsValid(lp) then return false end
    local character = client:getChar()
    local ourCharacter = lp:getChar()
    if not character or not ourCharacter then return false end
    local characterID = character:getID()
    local isRecognitionEnabled = self.RecognitionEnabled
    local isVarHiddenInScoreboard = table.HasValue(self.ScoreboardHiddenVars, var)
    local isClientNotLocalPlayer = client ~= lp
    local isRecognized = ourCharacter:doesRecognize(characterID)
    local isFakeRecognized = ourCharacter:doesFakeRecognize(characterID)
    local isNotRecognizedAndNotFakeRecognized = not (isRecognized or isFakeRecognized)
    return isRecognitionEnabled and isVarHiddenInScoreboard and isClientNotLocalPlayer and isNotRecognizedAndNotFakeRecognized
end

function MODULE:OnCharRecognized()
    surface.PlaySound("buttons/button17.wav")
end

function MODULE:CharRecognize(level, name)
    netstream.Start("rgn", level, name)
end