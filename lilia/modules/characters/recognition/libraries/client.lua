function RecognitionCore:isRecognizedChatType(chatType)
    return table.HasValue(self.ChatIsRecognized, chatType)
end

function RecognitionCore:GetDisplayedDescription(client, isHUD)
    if client:getChar() and client ~= LocalPlayer() and LocalPlayer():getChar() and not LocalPlayer():getChar():doesRecognize(client:getChar():getID()) then
        if isHUD then return client:getChar():getDesc() end
        return "You do not recognize this person."
    end
end

function RecognitionCore:GetDisplayedName(client, chatType)
    local character = client:getChar()
    local ourCharacter = LocalPlayer():getChar()
    local myReg = ourCharacter:getRecognizedAs()
    local characterID = character:getID()
    if not ourCharacter:doesRecognize(characterID) then
        if ourCharacter:doesFakeRecognize(characterID) and myReg[characterID] then return myReg[characterID] end
        if chatType and hook.Run("isRecognizedChatType", chatType) then return "[Unknown]" end
        return "Unknown"
    end
end

function RecognitionCore:ShouldAllowScoreboardOverride(client, var)
    local character = client:getChar()
    local ourCharacter = LocalPlayer():getChar()
    local characterID = character:getID()
    local isRecognitionEnabled = self.RecognitionEnabled
    local isVarHiddenInScoreboard = table.HasValue(self.ScoreboardHiddenVars, var)
    local isClientNotLocalPlayer = client ~= LocalPlayer()
    local isRecognized = ourCharacter:doesRecognize(characterID)
    local isFakeRecognized = ourCharacter:doesFakeRecognize(characterID)
    local isNotRecognizedAndNotFakeRecognized = not (isRecognized and isFakeRecognized)
    print("RecognitionEnabled:", self.RecognitionEnabled)
    print("ScoreboardHiddenVars contains var:", table.HasValue(self.ScoreboardHiddenVars, var))
    print("Client is not the local player:", client ~= LocalPlayer())
    print("Our character recognizes the client's character:", ourCharacter:doesRecognize(character:getID()))
    print("Our character fake recognizes the client's character:", ourCharacter:doesFakeRecognize(character:getID()))
    if isRecognitionEnabled and isVarHiddenInScoreboard and isClientNotLocalPlayer and isNotRecognizedAndNotFakeRecognized then return true end
    return false
end

function RecognitionCore:OnCharRecognized(_, _)
    surface.PlaySound("buttons/button17.wav")
end

function RecognitionCore:CharRecognize(level, name)
    netstream.Start("rgn", level, name)
end
