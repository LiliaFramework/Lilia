function MODULE:isRecognizedChatType(chatType)
    return table.HasValue(self.ChatIsRecognized, chatType)
end

function MODULE:GetDisplayedDescription(client, isHUD)
    if not IsValid(client) or not IsValid(LocalPlayer()) then return "Unknown" end
    if client:getChar() and client ~= LocalPlayer() and LocalPlayer():getChar() and not LocalPlayer():getChar():doesRecognize(client:getChar():getID()) then
        if isHUD then return client:getChar():getDesc() end
        return "You do not recognize this person."
    end
end

function MODULE:GetDisplayedName(client, chatType)
    if not IsValid(client) or not IsValid(LocalPlayer()) then return "Unknown" end
    local character = client:getChar()
    local ourCharacter = LocalPlayer():getChar()
    if not character or not ourCharacter then return "Unknown" end
    local myReg = ourCharacter:getRecognizedAs()
    local characterID = character:getID()
    if not ourCharacter:doesRecognize(characterID) then
        if ourCharacter:doesFakeRecognize(characterID) and myReg[characterID] then return myReg[characterID] end
        if chatType and .hookRun("isRecognizedChatType", chatType) then return "[Unknown]" end
        return "Unknown"
    end
end

function MODULE:ShouldAllowScoreboardOverride(client, var)
    if not IsValid(client) or not IsValid(LocalPlayer()) then return false end
    local character = client:getChar()
    local ourCharacter = LocalPlayer():getChar()
    if not character or not ourCharacter then return false end
    local characterID = character:getID()
    local isRecognitionEnabled = self.RecognitionEnabled
    local isVarHiddenInScoreboard = table.HasValue(self.ScoreboardHiddenVars, var)
    local isClientNotLocalPlayer = client ~= LocalPlayer()
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
