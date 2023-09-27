
lia.config.ChatIsRecognized = {"ic", "y", "w", "me"}

function MODULE:IsRecognizedChatType(chatType)
    return table.HasValue(lia.config.ChatIsRecognized, chatType)
end

function MODULE:GetDisplayedDescription(client)
    if client:getChar() and client ~= LocalPlayer() and LocalPlayer():getChar() and not LocalPlayer():getChar():doesRecognize(client:getChar()) and not hook.Run("IsPlayerRecognized", client) then return L"noRecog" end
end

function MODULE:GetDisplayedName(client, chatType)
    if client ~= LocalPlayer() then
        local character = client:getChar()
        local ourCharacter = LocalPlayer():getChar()
        local myReg = ourCharacter:getRecognizedAs()
        if myReg[character:getID()] then
            return myReg[character:getID()]
        elseif ourCharacter and character and not ourCharacter:doesRecognize(character) and not hook.Run("IsPlayerRecognized", client) then
            if chatType and hook.Run("IsRecognizedChatType", chatType) then
                return "[Unknown Person]"
            elseif not chatType then
                return L"unknown"
            end
        end
    end
end

function MODULE:ShouldAllowScoreboardOverride(client)
    if lia.config.RecognitionEnabled then return true end
end

function MODULE:OnCharRecognized(client, recogCharID)
    surface.PlaySound("buttons/button17.wav")
end

function CharRecognize(level, name)
    if name then
        netstream.Start("rgn", level, name)
    else
        netstream.Start("rgn", level)
    end
end
