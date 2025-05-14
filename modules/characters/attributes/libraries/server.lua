function MODULE:PostPlayerLoadout(client)
    local uniqueID = "StamCheck" .. client:SteamID64()
    local character = client:getChar()
    if character and character:getInv() then
        lia.attribs.setup(client)
        for _, item in pairs(character:getInv():getItems()) do
            item:call("onLoadout", client)
            if item:getData("equip") and istable(item.attribBoosts) then
                for attribute, boost in pairs(item.attribBoosts) do
                    character:addBoost(item.uniqueID, attribute, boost)
                end
            end
        end
    end

    timer.Create(uniqueID, 0.25, 0, function()
        if not IsValid(client) then
            timer.Remove(uniqueID)
            return
        end

        self:CalcStaminaChange(client)
    end)
end

function MODULE:KeyRelease(client, key)
    if key == IN_ATTACK2 then
        local wep = client:GetActiveWeapon()
        if IsValid(wep) and wep.IsHands and wep.ReadyToPickup then wep:Pickup() end
    end

    if lia.config.get("StaminaSlowdown", true) and key == IN_JUMP and not client:isNoClipping() and client:getChar() and not client:InVehicle() and client:Alive() then
        client:consumeStamina(15)
        local stm = client:getLocalVar("stamina", 0)
        if stm == 0 then
            client:setNetVar("brth", true)
            client:ConCommand("-speed")
        end
    end
end

function MODULE:KeyPress(client, key)
    if key == IN_ATTACK2 and IsValid(client.Grabbed) then
        client:DropObject(client.Grabbed)
        client.Grabbed = NULL
    end
end

function MODULE:PlayerLoadedChar(client, character)
    local maxstm = character:getMaxStamina()
    timer.Simple(0.25, function() client:setLocalVar("stamina", maxstm) end)
end

function MODULE:PlayerStaminaLost(client)
    if client.isBreathing then return end
    client:EmitSound("player/breathe1.wav", 35, 100)
    client.isBreathing = true
    timer.Create("liaStamBreathCheck" .. client:SteamID64(), 1, 0, function()
        if client:getLocalVar("stamina", 0) < lia.config.get("StaminaBreathingThreshold", 50) then return end
        client:StopSound("player/breathe1.wav")
        client.isBreathing = nil
        timer.Remove("liaStamBreathCheck" .. client:SteamID64())
    end)
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