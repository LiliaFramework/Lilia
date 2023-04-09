CHAT_RECOGNIZED = CHAT_RECOGNIZED or {}
CHAT_RECOGNIZED["ic"] = true
CHAT_RECOGNIZED["y"] = true
CHAT_RECOGNIZED["w"] = true
CHAT_RECOGNIZED["me"] = true

function PLUGIN:IsRecognizedChatType(chatType)
    return CHAT_RECOGNIZED[chatType]
end

function PLUGIN:GetDisplayedDescription(client)
    if client:getChar() and client ~= LocalPlayer() and LocalPlayer():getChar() and not LocalPlayer():getChar():doesRecognize(client:getChar()) and not hook.Run("IsPlayerRecognized", client) then return L"noRecog" end
end

function PLUGIN:ShouldAllowScoreboardOverride(client)
    if lia.config.get("sbRecog") then return true end
end

function PLUGIN:GetDisplayedName(client, chatType)
    if client ~= LocalPlayer() then
        local character = client:getChar()
        local ourCharacter = LocalPlayer():getChar()

        if ourCharacter and character and not ourCharacter:doesRecognize(character) and not hook.Run("IsPlayerRecognized", client) then
            if chatType and hook.Run("IsRecognizedChatType", chatType) then
                local description = character:getDesc()

                if #description > 40 then
                    description = description:utf8sub(1, 37) .. "..."
                end

                return "[" .. description .. "]"
            elseif not chatType then
                return L"unknown"
            end
        end
    end
end

netstream.Hook("rgnMenu", function()
    local menu = DermaMenu()

    menu:AddOption(L"rgnLookingAt", function()
        netstream.Start("rgn", 1)
    end)

    menu:AddOption(L"rgnWhisper", function()
        netstream.Start("rgn", 2)
    end)

    menu:AddOption(L"rgnTalk", function()
        netstream.Start("rgn", 3)
    end)

    menu:AddOption(L"rgnYell", function()
        netstream.Start("rgn", 4)
    end)

    menu:Open()
    menu:MakePopup()
    menu:Center()
end)

netstream.Hook("rgnDone", function()
    hook.Run("OnCharRecognized", client, id)
end)

function PLUGIN:OnCharRecognized(client, recogCharID)
    surface.PlaySound("buttons/button17.wav")
end

-- Add interaction function
lia.playerInteract.addFunc("recognize", {
    nameLocalized = "recognize",
    callback = function(target)
        netstream.Start("rgnDirect", target)
    end,
    canSee = function(target)
        return true
    end
})