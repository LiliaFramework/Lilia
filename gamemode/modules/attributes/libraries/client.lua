local predictedStamina = 100
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

    local max = hook.Run("GetCharMaxStamina", char) or lia.config.get("DefaultStamina", 100)
    predictedStamina = client:getNetVar("stamina", max)
end

function MODULE:Think()
    local offset = self:CalcStaminaChange(LocalPlayer())
    offset = math.Remap(FrameTime(), 0, 0.25, 0, offset)
    if offset ~= 0 then
        local max = hook.Run("GetCharMaxStamina", LocalPlayer():getChar()) or lia.config.get("DefaultStamina", 100)
        predictedStamina = math.Clamp(predictedStamina + offset, 0, max)
    end
end

net.Receive("liaStaminaSync", function()
    local serverStamina = net.ReadFloat()
    if math.abs(predictedStamina - serverStamina) > 5 then predictedStamina = serverStamina end
end)

lia.bar.add(function()
    local client = LocalPlayer()
    local char = client:getChar()
    if not char then return 0 end
    local max = hook.Run("GetCharMaxStamina", char) or lia.config.get("DefaultStamina", 100)
    return predictedStamina / max
end, Color(200, 200, 40), nil, "stamina")
