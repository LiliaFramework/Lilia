--------------------------------------------------------------------------------------------------------------------------
lia.config.ChatIsRecognized = {"ic", "y", "w", "me"}
--------------------------------------------------------------------------------------------------------------------------
function MODULE:IsRecognizedChatType(chatType)
    return table.HasValue(lia.config.ChatIsRecognized, chatType)
end

--------------------------------------------------------------------------------------------------------------------------
function MODULE:GetDisplayedDescription(client)
    local character = client:getChar()
    if client:getChar() and client ~= LocalPlayer() and LocalPlayer():getChar() and not LocalPlayer():getChar():doesRecognize(client:getChar()) and not hook.Run("IsPlayerRecognized", client) then return character:getDesc() end
end

--------------------------------------------------------------------------------------------------------------------------
function MODULE:GetDisplayedName(client, chatType)
    local character = client:getChar()
    local ourCharacter = LocalPlayer():getChar()
    if client == LocalPlayer() then return end
    if client:IsBot() then return client:GetName() end
    if not (ourCharacter and character) then return end
    if not (ourCharacter:doesRecognize(character) and hook.Run("IsPlayerRecognized", client)) then
        if chatType and hook.Run("IsRecognizedChatType", chatType) or not not chatType then return "[Unknown Person]" end
    else
        if ourCharacter:getRecognizedAs()[character:getID()] then return ourCharacter:getRecognizedAs()[character:getID()] end
        return character:getName()
    end
end

--------------------------------------------------------------------------------------------------------------------------
function MODULE:ShouldAllowScoreboardOverride(client, var)
    if lia.config.RecognitionEnabled and lia.config.ScoreboardHiddenVars[var] ~= nil and (client ~= LocalPlayer()) then
        local character = client:getChar()
        local ourCharacter = LocalPlayer():getChar()
        if ourCharacter and character and not ourCharacter:doesRecognize(character) and not hook.Run("IsPlayerRecognized", client) then return true end
    end
end

--------------------------------------------------------------------------------------------------------------------------
function MODULE:OnCharRecognized(client, recogCharID)
    surface.PlaySound("buttons/button17.wav")
end

--------------------------------------------------------------------------------------------------------------------------
function CharRecognize(level, name)
    if name then
        netstream.Start("rgn", level, name)
    else
        netstream.Start("rgn", level)
    end
end
--------------------------------------------------------------------------------------------------------------------------