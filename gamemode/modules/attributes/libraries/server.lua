local staminaPlayers = {}
function MODULE:PostPlayerLoadout(client)
    local char = client:getChar()
    if not char then return end
    lia.attribs.setup(client)
    local inv = char:getInv()
    if inv then
        for _, v in pairs(inv:getItems()) do
            v:call("onLoadout", client)
            if v:getData("equip") and istable(v.attribBoosts) then
                for k, b in pairs(v.attribBoosts) do
                    char:addBoost(v.uniqueID, k, b)
                end
            end
        end
    end

    client:setLocalVar("stamina", char:getMaxStamina())
    staminaPlayers[client] = true
end

function MODULE:PlayerDisconnected(client)
    staminaPlayers[client] = nil
end

function MODULE:KeyPress(client, key)
    local char = client:getChar()
    if not char then return end
    if key == IN_ATTACK2 then
        local wep = client:GetActiveWeapon()
        if IsValid(wep) and wep.IsHands and wep.ReadyToPickup then
            wep:Pickup()
        elseif IsValid(client.Grabbed) then
            client:DropObject(client.Grabbed)
            client.Grabbed = NULL
        end
    end

    if key == IN_JUMP and not client:isNoClipping() and not client:InVehicle() and client:Alive() and client:OnGround() and (client.liaNextJump or 0) <= CurTime() then
        client.liaNextJump = CurTime() + 0.1
        local cost = lia.config.get("JumpStaminaCost", 25)
        local maxStamina = char:getMaxStamina() or lia.config.get("DefaultStamina", 100)
        client:consumeStamina(cost)
        local newStamina = client:getLocalVar("stamina", maxStamina)
        if newStamina <= 0 then client:ConCommand("-speed") end
    end
end

function MODULE:PlayerLoadedChar(client, character)
    client:setLocalVar("stamina", character:getMaxStamina())
    timer.Simple(0.25, function() if IsValid(client) and client:getChar() == character then client:setLocalVar("stamina", character:getMaxStamina()) end end)
end

function MODULE:PostPlayerLoadedChar(client, character)
    if IsValid(client) and character then client:setLocalVar("stamina", character:getMaxStamina()) end
end

net.Receive("ChangeAttribute", function(_, client)
    if not client:hasPrivilege("manageAttributes") then return end
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

    if mode == L("set") then
        if attribValue < 0 then
            client:notifyLocalized("attribNonNegative")
            return
        end

        targetChar:setAttrib(attribKey, attribValue)
        client:notifyLocalized("attribSet", targetChar:getPlayer():Name(), L(lia.attribs.list[attribKey].name), attribValue)
        targetChar:getPlayer():notifyLocalized("yourAttributeSet", lia.attribs.list[attribKey].name, attribValue, client:Nick())
    elseif mode == L("add") then
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

if SERVER and not timer.Exists("liaGlobalStamina") then
    timer.Create("liaGlobalStamina", 0.25, 0, function()
        for client, _ in pairs(staminaPlayers) do
            if IsValid(client) then
                MODULE:CalcStaminaChange(client)
            else
                staminaPlayers[client] = nil
            end
        end
    end)
end
