local predictedStamina = 100
function MODULE:PlayerBindPress(client, bind, pressed)
    if not pressed then return end
    local char = client:getChar()
    if not char then return end
    local predicted = predictedStamina or 0
    local actual = client:getNetVar("stamina", hook.Run("GetCharMaxStamina", char) or lia.config.get("DefaultStamina", 100))
    local jumpReq = lia.config.get("JumpStaminaCost", 25)
    if bind == "+jump" and client:GetMoveType() ~= MOVETYPE_NOCLIP and predicted < jumpReq and actual < jumpReq then return true end
    local stamina = math.min(predicted, actual)
    if bind == "+speed" and stamina <= 5 then
        client:ConCommand("-speed")
        return true
    end
end

function MODULE:Think()
    local client = LocalPlayer()
    if not client:getChar() then return end
    local character = client:getChar()
    local maxStamina = hook.Run("GetCharMaxStamina", character) or lia.config.get("DefaultStamina", 100)
    local offset = self:CalcStaminaChange(client)
    offset = math.Remap(FrameTime(), 0, 0.25, 0, offset)
    if offset ~= 0 then predictedStamina = math.Clamp(predictedStamina + offset, 0, maxStamina) end
end

function MODULE:NetVarChanged(client, key, _, newVar)
    if client ~= LocalPlayer() or key ~= "stamina" then return end
    predictedStamina = newVar
end

function MODULE:LoadCharInformation()
    local client = LocalPlayer()
    if not IsValid(client) then return end
    local char = client:getChar()
    if not char then return end
    if table.IsEmpty(lia.attribs.list) then return end
    hook.Run("AddSection", L("attributes"), Color(0, 0, 0), 2, 1)
    local attrs = {}
    for id, attr in pairs(lia.attribs.list) do
        attrs[#attrs + 1] = {
            id = id,
            attr = attr
        }
    end

    table.sort(attrs, function(a, b) return a.attr.name < b.attr.name end)
    for _, entry in ipairs(attrs) do
        local id, attr = entry.id, entry.attr
        local minVal = attr.min or 0
        local maxVal = hook.Run("GetAttributeMax", client, id) or attr.max or 100
        hook.Run("AddBarField", L("attributes"), id, attr.name, function() return minVal end, function() return maxVal end, function() return char:getAttrib(id) end)
    end
end

lia.bar.add(function()
    local client = LocalPlayer()
    local char = client:getChar()
    if not char then return 0 end
    local max = hook.Run("GetCharMaxStamina", char) or lia.config.get("DefaultStamina", 100)
    return predictedStamina / max
end, Color(200, 200, 40), nil, "stamina")

function MODULE:OnReloaded()
    local client = LocalPlayer()
    if not IsValid(client) then return end
    local char = client:getChar()
    if not char then return end
    predictedStamina = client:getNetVar("stamina", hook.Run("GetCharMaxStamina", char) or lia.config.get("DefaultStamina", 100))
end
