--------------------------------------------------------------------------------------------------------------------------
lia.config.ChatIsRecognized = {"ic", "y", "w", "me"}
--------------------------------------------------------------------------------------------------------------------------
function MODULE:IsRecognizedChatType(chatType)
    return table.HasValue(lia.config.ChatIsRecognized, chatType)
end

--------------------------------------------------------------------------------------------------------------------------
function MODULE:GetDisplayedDescription(client, isHUD)
    if client:getChar() and client ~= LocalPlayer() and LocalPlayer():getChar() and not LocalPlayer():getChar():doesRecognize(client:getChar():getID()) then
        if isHUD then return client:getChar():getDesc() end
        return "You do not recognize this person."
    end
end

--------------------------------------------------------------------------------------------------------------------------
function MODULE:GetDisplayedName(client, chatType)
    local character = client:getChar()
    local ourCharacter = LocalPlayer():getChar()
    if client == LocalPlayer() then return character:getName() end
    if client:IsBot() then return client:GetName() end
    if not ourCharacter:doesRecognize(character:getID()) then
        if chatType and hook.Run("IsRecognizedChatType", chatType) then
            return "[Unknown Person]"
        elseif not chatType then
            return "Unknown"
        end
    else
        local myReg = ourCharacter:getRecognizedAs()
        if myReg[character:getID()] then
            return myReg[character:getID()]
        else
            return character:getName()
        end
    end
end

--------------------------------------------------------------------------------------------------------------------------
function MODULE:ShouldAllowScoreboardOverride(client, var)
    local character = client:getChar()
    local ourCharacter = LocalPlayer():getChar()
    if (lia.config.RecognitionEnabled and table.HasValue(lia.config.ScoreboardHiddenVars, var)) and (client ~= LocalPlayer()) and not ourCharacter:doesRecognize(character:getID()) then return true end
end

--------------------------------------------------------------------------------------------------------------------------
function MODULE:OnCharRecognized(client, recogCharID)
    surface.PlaySound("buttons/button17.wav")
end

--------------------------------------------------------------------------------------------------------------------------
function CharRecognize(level, name)
    netstream.Start("rgn", level, name)
end

--------------------------------------------------------------------------------------------------------------------------
concommand.Add("dev_reloadsb", function() if IsValid(lia.gui.score) then lia.gui.score:Remove() end end)
--------------------------------------------------------------------------------------------------------------------------
