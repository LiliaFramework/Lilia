--[[
    Hooks:
        GetAttributeMax(Player client, string id)

    Purpose:
        Allows schemas or modules to override the maximum value shown for an attribute in the F1 character information panel.

    Category:
        Attributes

    Parameters:
        client (Player)
            The local player whose character information is being displayed.

        id (string)
            The unique attribute identifier currently being rendered.

    Example Usage:
        ```lua
        hook.Add("GetAttributeMax", "liaExampleGetAttributeMax", function(client, id)
            if id == "stm" then return 150 end
        end)
        ```

    Returns:
        number|nil
            Return a numeric maximum to override the default attribute limit. Return nil to keep the configured attribute maximum.

    Realm:
        Shared
]]
--[[
    Hooks:
        GetCharMaxStamina(Character char)

    Purpose:
        Allows modules to override the stamina maximum used by the client-side stamina display and prediction logic.

    Category:
        Attributes

    Parameters:
        char (Character)
            The loaded character whose stamina cap is being queried.

    Example Usage:
        ```lua
        hook.Add("GetCharMaxStamina", "liaExampleGetCharMaxStamina", function(char)
            if char and char:getAttrib("end", 0) >= 50 then return 125 end
        end)
        ```

    Returns:
        number|nil
            Return a numeric stamina cap to override the default stamina value. Return nil to keep the configured default.

    Realm:
        Shared
]]
--[[
    Hooks:
        OnLocalVarSet(string key, any value)

    Purpose:
        Runs after the local player receives an updated local netvar so client modules can react to predicted stamina changes or other local-only state.

    Category:
        Networking

    Parameters:
        key (string)
            The local netvar name that was updated.

        value (any)
            The new local netvar value that was received.

    Example Usage:
        ```lua
        hook.Add("OnLocalVarSet", "liaExampleOnLocalVarSet", function(key, value)
            if key == "stamina" then
                print("Stamina updated:", value)
            end
        end)
        ```

    Returns:
        nil

    Realm:
        Client
]]
local predictedStamina = 100
function MODULE:LoadCharInformation()
    local client = LocalPlayer()
    if not IsValid(client) then return end
    local char = client:getChar()
    if not char then return end
    if table.IsEmpty(lia.attribs.list) then return end
    hook.Run("AddSection", L("attributesModuleName"), Color(0, 0, 0), 2, 1)
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
        hook.Run("AddBarField", L("attributesModuleName"), id, attr.name, function() return minVal end, function() return maxVal end, function() return char:getAttrib(id) end)
    end

    local max = hook.Run("GetCharMaxStamina", char) or lia.config.get("DefaultStamina", 100)
    predictedStamina = client:getLocalVar("stamina", max)
end

function MODULE:Think()
    local offset = self:CalcStaminaChange(LocalPlayer())
    offset = math.Remap(FrameTime(), 0, 0.25, 0, offset)
    if offset ~= 0 then
        local max = hook.Run("GetCharMaxStamina", LocalPlayer():getChar()) or lia.config.get("DefaultStamina", 100)
        predictedStamina = math.Clamp(predictedStamina + offset, 0, max)
    end
end

function MODULE:OnLocalVarSet(key, value)
    if key ~= "stamina" then return end
    if math.abs(predictedStamina - value) > 5 then predictedStamina = value end
end

lia.bar.add(function()
    local client = LocalPlayer()
    local char = client:getChar()
    if not char then return 0 end
    local max = hook.Run("GetCharMaxStamina", char) or lia.config.get("DefaultStamina", 100)
    return predictedStamina / max
end, Color(200, 200, 40), nil, "stamina")
