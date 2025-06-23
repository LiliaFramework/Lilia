function MODULE:PostPlayerLoadout(client)
    local character = client:getChar()
    if not character then return end
    lia.attribs.setup(client)
    local inv = character:getInv()
    if inv then
        for _, item in pairs(inv:getItems()) do
            item:call("onLoadout", client)
            if item:getData("equip") and istable(item.attribBoosts) then
                for attr, boost in pairs(item.attribBoosts) do
                    character:addBoost(item.uniqueID, attr, boost)
                end
            end
        end
    end

    client:setLocalVar("stamina", character:getMaxStamina())
    timer.Create("StamCheck" .. client:SteamID64(), 0.25, 0, function()
        if not IsValid(client) then
            timer.Remove("StamCheck" .. client:SteamID64())
            return
        end

        if client:isNoClipping() or not character then
            client:SetRunSpeed(lia.config.get("WalkSpeed"))
            return
        end

        local maxStamina = character:getMaxStamina()
        local currentStamina = client:getLocalVar("stamina", 0)
        local isHoldingSprint = client:KeyDown(IN_SPEED) and not client:InVehicle()
        local endBonus = character:getAttrib("end", 0) or 0
        local offset
        if isHoldingSprint and currentStamina > 0 then
            client:SetRunSpeed(lia.config.get("RunSpeed") + (character:getAttrib("stamina", 0) or 0))
            offset = -2 + endBonus / 60
        else
            client:SetRunSpeed(lia.config.get("WalkSpeed"))
            if currentStamina >= maxStamina then
                offset = 0
            elseif currentStamina > 0.5 then
                offset = 1 * lia.config.get("StaminaRegenMultiplier", 1)
            else
                offset = 1.75 * lia.config.get("StaminaRegenMultiplier", 1)
            end

            if client:Crouching() then offset = offset + 1 end
        end

        local newStamina = math.Clamp(currentStamina + offset, 0, maxStamina)
        local slowThreshold = maxStamina * 0.15
        local breathThreshold = maxStamina * 0.25
        local brth = client:getNetVar("brth", false)
        if newStamina <= breathThreshold and not brth then
            client:setNetVar("brth", true)
            client:EmitSound("player/breathe1.wav", 35, 100)
        elseif newStamina > breathThreshold and brth then
            client:StopSound("player/breathe1.wav")
            client:setNetVar("brth", nil)
        end

        if newStamina <= 0 and not client:getNetVar("slow", false) then
            client:setNetVar("slow", true)
        elseif client:getNetVar("slow", false) and newStamina > slowThreshold then
            client:setNetVar("slow", nil)
        end

        if newStamina ~= currentStamina then client:setLocalVar("stamina", newStamina) end
    end)
end

function MODULE:PlayerDisconnected(client)
    timer.Remove("StamCheck" .. client:SteamID64())
end

function MODULE:KeyRelease(client, key)
    if key == IN_ATTACK2 then
        local wep = client:GetActiveWeapon()
        if IsValid(wep) and wep.IsHands and wep.ReadyToPickup then wep:Pickup() end
    end

    if key == IN_JUMP and not client:isNoClipping() and client:getChar() and not client:InVehicle() and client:Alive() then
        local cost = lia.config.get("JumpStaminaCost")
        client:consumeStamina(cost)
        local stm = client:getLocalVar("stamina", 0)
        if stm == 0 then
            client:setNetVar("brth", true)
            client:ConCommand("-speed")
        end
    end
end

function MODULE:PlayerStaminaLost(client)
    if client:getNetVar("brth", false) then return end
    client:setNetVar("brth", true)
    client:EmitSound("player/breathe1.wav", 35, 100)
    local breathThreshold = lia.config.get("StaminaBreathingThreshold", 50)
    timer.Create("liaStamBreathCheck" .. client:SteamID64(), 1, 0, function()
        if not IsValid(client) then
            timer.Remove("liaStamBreathCheck" .. client:SteamID64())
            return
        end

        local currentStamina = client:getLocalVar("stamina", 0)
        if currentStamina <= breathThreshold then
            client:EmitSound("player/breathe1.wav", 35, 100)
            return
        end

        client:StopSound("player/breathe1.wav")
        client:setNetVar("brth", nil)
        timer.Remove("liaStamBreathCheck" .. client:SteamID64())
    end)
end

function MODULE:KeyPress(client, key)
    if key == IN_ATTACK2 and IsValid(client.Grabbed) then
        client:DropObject(client.Grabbed)
        client.Grabbed = NULL
    end
end

function MODULE:OnCharAttribBoosted(client, character, attribID)
    local attribute = lia.attribs.list[attribID]
    if attribute and isfunction(attribute.OnSetup) then attribute:OnSetup(client, character:getAttrib(attribID, 0)) end
end

net.Receive("ChangeAttribute", function(_, client)
    if not client:hasPrivilege("Commands - Manage Attributes") then return end
    local charID = net.ReadInt(32)
    local _ = net.ReadTable()
    local attribKey = net.ReadString()
    local amountStr = net.ReadString()
    local mode = net.ReadString()
    if not attribKey or not lia.attribs.list[attribKey] then
        for k, v in pairs(lia.attribs.list) do
            if lia.util.stringMatches(L(v.name), attribKey) or lia.util.stringMatches(k, attribKey) then
                attribKey = k
                break
            end
        end
    end

    if not attribKey or not lia.attribs.list[attribKey] then
        client:notifyLocalized("invalidAttributeKey")
        return
    end

    local attribValue = tonumber(amountStr)
    if not attribValue then
        client:notifyLocalized("invalidAmount")
        return
    end

    local targetClient = lia.char.getBySteamID(charID)
    if not IsValid(targetClient) then
        client:notifyLocalized("characterNotFound")
        return
    end

    local targetChar = targetClient:getChar()
    if not targetChar then
        client:notifyLocalized("characterNotFound")
        return
    end

    if mode == "Set" then
        if attribValue < 0 then
            client:notifyLocalized("attribNonNegative")
            return
        end

        targetChar:setAttrib(attribKey, attribValue)
        client:notifyLocalized("attribSet", targetChar:getPlayer():Name(), L(lia.attribs.list[attribKey].name), attribValue)
        targetChar:getPlayer():notifyLocalized("yourAttributeSet", lia.attribs.list[attribKey].name, attribValue, client:Nick())
    elseif mode == "Add" then
        if attribValue <= 0 then
            client:notifyLocalized("attribPositive")
            return
        end

        local current = targetChar:getAttrib(attribKey, 0) or 0
        local newValue = current + attribValue
        if not isnumber(newValue) or newValue < 0 then
            client:notifyLocalized("attribCalculationError")
            return
        end

        targetChar:updateAttrib(attribKey, newValue)
        client:notifyLocalized("attribUpdate", targetChar:getPlayer():Name(), L(lia.attribs.list[attribKey].name), attribValue)
        targetChar:getPlayer():notifyLocalized("yourAttributeIncreased", lia.attribs.list[attribKey].name, attribValue, client:Nick())
    else
        client:notifyLocalized("invalidMode")
    end
end)