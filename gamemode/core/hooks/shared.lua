local GM = GM or GAMEMODE
--[[
    Hooks:
        PlayerModelChanged(Player client, string newVar)

    Purpose:
        Runs when a character's `model` var changes so modules can react to the player receiving a new model path.

    Category:
        Character

    Parameters:
        client (Player)
            The player whose character model changed.

        newVar (string)
            The new model path assigned to the character.

    Returns:
        nil

    Example Usage:
        ```lua
        hook.Add("PlayerModelChanged", "liaExamplePlayerModelChanged", function(client, newVar)
            if IsValid(client) then
                print(client:Nick(), "changed model to", newVar)
            end
        end)
        ```

    Realm:
        Shared
]]
function GM:OnCharVarChanged(character, varName, oldVar, newVar)
    local client = character:getPlayer()
    if varName == "model" then hook.Run("PlayerModelChanged", client, newVar) end
    if lia.char.varHooks[varName] then
        for _, v in pairs(lia.char.varHooks[varName]) do
            v(character, oldVar, newVar)
        end
    end
end

function GM:FindUseEntity(client, ent)
    return ent
end

function GM:MouthMoveAnimation(ply)
    if lia.config.get("MouthMoveAnimation", true) then
        local flexes = {ply:GetFlexIDByName("jaw_drop"), ply:GetFlexIDByName("left_part"), ply:GetFlexIDByName("right_part"), ply:GetFlexIDByName("left_mouth_drop"), ply:GetFlexIDByName("right_mouth_drop")}
        local weight = ply:IsSpeaking() and math.Clamp(ply:VoiceVolume() * 2, 0, 2) or 0
        for k, v in ipairs(flexes) do
            ply:SetFlexWeight(v, weight)
        end
    end
    return nil
end

function GM:GrabEarAnimation(ply, plyTable)
    if lia.config.get("GrabEarAnimation", true) then
        if not plyTable then plyTable = ply:GetTable() end
        plyTable.ChatGestureWeight = plyTable.ChatGestureWeight or 0
        if ply:IsPlayingTaunt() then return end
        if ply:IsTyping() then
            plyTable.ChatGestureWeight = math.Approach(plyTable.ChatGestureWeight, 1, FrameTime() * 5.0)
        else
            plyTable.ChatGestureWeight = math.Approach(plyTable.ChatGestureWeight, 0, FrameTime() * 5.0)
        end

        if plyTable.ChatGestureWeight > 0 then
            ply:AnimRestartGesture(GESTURE_SLOT_VCD, ACT_GMOD_IN_CHAT, true)
            ply:AnimSetGestureWeight(GESTURE_SLOT_VCD, plyTable.ChatGestureWeight)
        end
    end
    return nil
end

function GM:PreGamemodeLoaded()
    widgets.PlayerTick = function() end
    hook.Remove("PlayerTick", "TickWidgets")
    hook.Remove("PostDrawEffects", "RenderWidgets")
end

--[[
    Hooks:
        GetModelGender(string model)

    Purpose:
        Allows schemas or modules to override the gender classification used for model-dependent helpers such as voice and appearance checks.

    Category:
        Character

    Parameters:
        model (string)
            The model path being classified.

    Returns:
        string|nil
            Return `female` or `male` to override the detected gender. Returning nil allows the default model-name checks to continue.

    Example Usage:
        ```lua
        hook.Add("GetModelGender", "liaExampleGetModelGender", function(model)
            if isstring(model) and model:find("custom_female", 1, true) then
                return "female"
            end
        end)
        ```

    Realm:
        Shared
]]
function GM:GetModelGender(model)
    local isFemale = model:find("alyx") or model:find("mossman") or model:find("female")
    return isFemale and "female" or "male"
end

function GM:GetAttributeMax(client, attribute)
    local attribTable = lia.attribs.list[attribute]
    if not attribTable then return lia.config.get("MaxAttributePoints") end
    if istable(attribTable) and isnumber(attribTable.maxValue) then return attribTable.maxValue end
    return lia.config.get("MaxAttributePoints")
end

function GM:GetAttributeStartingMax(client, attribute)
    local attribTable = lia.attribs.list[attribute]
    if not attribTable then return lia.config.get("MaxStartingAttributes") end
    if istable(attribTable) and isnumber(attribTable.startingMax) then return attribTable.startingMax end
    return lia.config.get("MaxStartingAttributes")
end

function GM:GetMaxStartingAttributePoints(client, default)
    return default or lia.config.get("StartingAttributePoints", 30)
end
