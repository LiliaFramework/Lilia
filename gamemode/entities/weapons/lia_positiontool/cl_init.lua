local MODE_INDEX = 1
local CACHED_POSITIONS = {}
local CACHE_TYPE = nil
local LAST_REQUEST = 0
local REQUEST_THROTTLE = 0.5
local function canUseTool()
    local cl = LocalPlayer()
    if not IsValid(cl) then return false end
    return cl:hasPrivilege("usePositionTool") or cl:hasPrivilege("alwaysSpawnAdminStick") or cl:isStaffOnDuty()
end

local function getTypes()
    if not lia.featurePositionTypes or #lia.featurePositionTypes == 0 then return {} end
    return lia.featurePositionTypes
end

local function getCurrentType()
    local types = getTypes()
    if #types == 0 then return nil end
    local idx = (MODE_INDEX - 1) % #types + 1
    return types[idx]
end

local function requestPositions(typeId)
    if CurTime() - LAST_REQUEST < REQUEST_THROTTLE then return end
    LAST_REQUEST = CurTime()
    local MODULE = lia.module.get("administration")
    if not MODULE or not MODULE.positionCallbacks then return end
    local callback = MODULE.positionCallbacks[typeId]
    if callback and callback.onSelect then
        if callback.serverOnly then
            net.Start("liaFeaturePositionsRequest")
            net.WriteString(typeId or "")
            net.SendToServer()
        else
            local client = LocalPlayer()
            if IsValid(client) then
                callback.onSelect(client, function(positions, count)
                    CACHE_TYPE = typeId
                    CACHED_POSITIONS = positions or {}
                end)
            end
        end
    else
        net.Start("liaFeaturePositionsRequest")
        net.WriteString(typeId or "")
        net.SendToServer()
    end
end

net.Receive("liaFeaturePositions", function()
    local typeId = net.ReadString()
    local count = net.ReadUInt(16)
    local list = {}
    for i = 1, count do
        local pos = net.ReadVector()
        local label = net.ReadString()
        list[#list + 1] = {
            pos = pos,
            label = label
        }
    end

    CACHE_TYPE = typeId
    CACHED_POSITIONS = list
end)

function SWEP:PrimaryAttack()
    local client = LocalPlayer()
    if not canUseTool() then return end
    if not IsFirstTimePredicted() then return end
    local trace = client:GetEyeTrace()
    if not trace.Hit then return end
    local pos = trace.HitPos + (trace.HitNormal or vector_up) * 2
    local typeInfo = getCurrentType()
    if not typeInfo then return end
    lia.util.setFeaturePosition(pos, typeInfo.id)
    timer.Simple(0.5, function() if IsValid(client) and IsValid(client:GetActiveWeapon()) and client:GetActiveWeapon():GetClass() == "lia_positiontool" then requestPositions(typeInfo.id) end end)
end

function SWEP:Reload()
    if self.NextReload and self.NextReload > SysTime() then return end
    self.NextReload = SysTime() + 0.5
    local client = LocalPlayer()
    if client:KeyDown(IN_SPEED) then
        if not canUseTool() then return end
        local pos = client:GetPos()
        local typeInfo = getCurrentType()
        if not typeInfo then return end
        lia.util.setFeaturePosition(pos, typeInfo.id)
        timer.Simple(0.5, function() if IsValid(client) and IsValid(client:GetActiveWeapon()) and client:GetActiveWeapon():GetClass() == "lia_positiontool" then requestPositions(typeInfo.id) end end)
        return
    end

    local types = getTypes()
    if #types == 0 then return end
    MODE_INDEX = MODE_INDEX + 1
    if MODE_INDEX > #types then MODE_INDEX = 1 end
    local typeInfo = getCurrentType()
    if typeInfo then requestPositions(typeInfo.id) end
end

function SWEP:Deploy()
    local typeInfo = getCurrentType()
    if typeInfo then
        requestPositions(typeInfo.id)
        timer.Simple(0.15, function()
            local cl = LocalPlayer()
            if IsValid(cl) and IsValid(cl:GetActiveWeapon()) and cl:GetActiveWeapon():GetClass() == "lia_positiontool" then
                local t = getCurrentType()
                if t then requestPositions(t.id) end
            end
        end)
    end
    return true
end

function SWEP:Think()
    local typeInfo = getCurrentType()
    if typeInfo then
        if CACHE_TYPE ~= typeInfo.id then
            requestPositions(typeInfo.id)
        elseif #CACHED_POSITIONS == 0 and (self._lastEmptyRequest or 0) < (CurTime() - 2) then
            self._lastEmptyRequest = CurTime()
            requestPositions(typeInfo.id)
        end
    end
end

function SWEP:GetPositionToolMode()
    return getCurrentType()
end

function SWEP:GetCachedPositions()
    return CACHED_POSITIONS
end

function SWEP:GetCacheType()
    return CACHE_TYPE
end

function SWEP:CanUseTool()
    return canUseTool()
end

function SWEP:Holster()
    return true
end
