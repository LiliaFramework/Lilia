﻿function RecognitionCore:isRecognizedChatType(chatType)
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
    if self.RecognitionEnabled and table.HasValue(self.ScoreboardHiddenVars, var) and (client ~= LocalPlayer()) and not (ourCharacter:doesRecognize(character:getID()) and ourCharacter:doesFakeRecognize(character:getID())) then return true end
end

function RecognitionCore:OnCharRecognized(_, _)
    surface.PlaySound("buttons/button17.wav")
end

function RecognitionCore:CharRecognize(level, name)
    netstream.Start("rgn", level, name)
end
