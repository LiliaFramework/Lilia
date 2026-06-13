local REQUEST_THROTTLE = 0.5
local function canUseTool()
    local cl = LocalPlayer()
    if not IsValid(cl) then return false end
    local hasUsePositionTool = cl:hasPrivilege("usePositionTool")
    local hasAlwaysSpawnAdminStick = cl:hasPrivilege("alwaysSpawnAdminStick")
    local isStaffOnDuty = cl:isStaffOnDuty()
    local permission = hasUsePositionTool or hasAlwaysSpawnAdminStick or isStaffOnDuty
    return permission
end

local function getTypes()
    if not lia.util.featurePositionTypes or #lia.util.featurePositionTypes == 0 then return {} end
    return lia.util.featurePositionTypes
end

local function getCurrentType()
    local types = getTypes()
    if #types == 0 then return nil end
    local idx = (lia.mapConfigurerState.modeIndex - 1) % #types + 1
    return types[idx]
end

local function requestPositions(typeId)
    if CurTime() - lia.mapConfigurerState.lastRequest < REQUEST_THROTTLE then return end
    lia.mapConfigurerState.lastRequest = CurTime()
    local callback = lia.util.positionCallbacks[typeId]
    if callback and callback.onSelect then
        if callback.serverOnly then
            net.Start("liaFeaturePositionsRequest")
            net.WriteString(typeId or "")
            net.SendToServer()
        else
            local client = LocalPlayer()
            if IsValid(client) then
                callback.onSelect(client, function(positions, count)
                    lia.mapConfigurerState.cacheType = typeId
                    lia.mapConfigurerState.cachedPositions = positions or {}
                end)
            end
        end
    else
        net.Start("liaFeaturePositionsRequest")
        net.WriteString(typeId or "")
        net.SendToServer()
    end
end

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
    timer.Simple(0.5, function() if IsValid(client) and IsValid(client:GetActiveWeapon()) and client:GetActiveWeapon():GetClass() == "lia_mapconfigurer" then requestPositions(typeInfo.id) end end)
end

function SWEP:SecondaryAttack()
    if not IsFirstTimePredicted() then return end
    if self.NextSecondary and self.NextSecondary > SysTime() then return end
    self.NextSecondary = SysTime() + 0.5
    if not canUseTool() then return end
    local client = LocalPlayer()
    local pos = client:GetPos()
    local typeInfo = getCurrentType()
    if not typeInfo then return end
    lia.util.setFeaturePosition(pos, typeInfo.id)
    timer.Simple(0.5, function() if IsValid(client) and IsValid(client:GetActiveWeapon()) and client:GetActiveWeapon():GetClass() == "lia_mapconfigurer" then requestPositions(typeInfo.id) end end)
end

function SWEP:Reload()
    if self.NextReload and self.NextReload > SysTime() then return end
    self.NextReload = SysTime() + 0.5
    local types = getTypes()
    if #types == 0 then return end
    lia.mapConfigurerState.modeIndex = lia.mapConfigurerState.modeIndex + 1
    if lia.mapConfigurerState.modeIndex > #types then lia.mapConfigurerState.modeIndex = 1 end
    local typeInfo = getCurrentType()
    if typeInfo then requestPositions(typeInfo.id) end
end

function SWEP:Deploy()
    local typeInfo = getCurrentType()
    if typeInfo then
        requestPositions(typeInfo.id)
        timer.Simple(0.15, function()
            local cl = LocalPlayer()
            if IsValid(cl) and IsValid(cl:GetActiveWeapon()) and cl:GetActiveWeapon():GetClass() == "lia_mapconfigurer" then
                local t = getCurrentType()
                if t then requestPositions(t.id) end
            end
        end)
    end
    return true
end

function SWEP:Think()
    local client = LocalPlayer()
    local typeInfo = getCurrentType()
    if client:KeyDown(IN_SPEED) and client:KeyDown(IN_USE) and not lia.mapConfigurerState.removalMenuOpen then
        if self._removalMenuCooldown and self._removalMenuCooldown > CurTime() then return end
        self._removalMenuCooldown = CurTime() + 1.0
        self:OpenRemovalMenu()
    end

    if typeInfo then
        if lia.mapConfigurerState.cacheType ~= typeInfo.id then
            requestPositions(typeInfo.id)
        elseif #lia.mapConfigurerState.cachedPositions == 0 and (self._lastEmptyRequest or 0) < (CurTime() - 2) then
            self._lastEmptyRequest = CurTime()
            requestPositions(typeInfo.id)
        end
    end
end

function SWEP:GetPositionToolMode()
    return getCurrentType()
end

function SWEP:GetCachedPositions()
    return lia.mapConfigurerState.cachedPositions
end

function SWEP:GetCacheType()
    return lia.mapConfigurerState.cacheType
end

function SWEP:CanUseTool()
    return canUseTool()
end

function SWEP:Holster()
    lia.mapConfigurerState.removalMenuOpen = false
    return true
end

function SWEP:OpenRemovalMenu()
    if not canUseTool() then return end
    local typeInfo = getCurrentType()
    if not typeInfo then return end
    lia.mapConfigurerState.removalMenuOpen = true
    local frame = vgui.Create("DFrame")
    frame:SetSize(600, 400)
    frame:SetTitle(L("removeThing", typeInfo.name or L("points")))
    frame:Center()
    frame:MakePopup()
    function frame:OnClose()
        lia.mapConfigurerState.removalMenuOpen = false
    end

    local scroll = vgui.Create("DScrollPanel", frame)
    scroll:Dock(FILL)
    scroll:DockMargin(5, 5, 5, 5)
    local clientPos = LocalPlayer():GetPos()
    if #lia.mapConfigurerState.cachedPositions > 0 then
        for i, point in ipairs(lia.mapConfigurerState.cachedPositions) do
            local idx = i
            local pt = point
            local distance = math.Round(clientPos:Distance(pt.pos))
            local pointPanel = vgui.Create("DPanel", scroll)
            pointPanel:SetTall(60)
            pointPanel:Dock(TOP)
            pointPanel:DockMargin(0, 0, 0, 5)
            local infoLabel = vgui.Create("DLabel", pointPanel)
            infoLabel:SetText(L("pointDistanceInfo", pt.label or L("pointNumber", idx), distance))
            infoLabel:SetFont("LiliaFont.20")
            infoLabel:Dock(LEFT)
            infoLabel:DockMargin(10, 0, 0, 0)
            infoLabel:SizeToContents()
            local removeButton = vgui.Create("DButton", pointPanel)
            removeButton:SetText(L("remove"))
            removeButton:SetSize(80, 30)
            removeButton:Dock(RIGHT)
            removeButton:DockMargin(0, 15, 10, 15)
            removeButton.DoClick = function()
                local pointName = pt.label or L("pointNumber", idx)
                lia.util.removeFeaturePosition(pt.pos, typeInfo.id)
                LocalPlayer():notifySuccessLocalized("removedPoint", pointName)
                frame:Close()
                timer.Simple(0.5, function() if IsValid(LocalPlayer()) and IsValid(LocalPlayer():GetActiveWeapon()) and LocalPlayer():GetActiveWeapon():GetClass() == "lia_mapconfigurer" then requestPositions(typeInfo.id) end end)
            end
        end
    else
        local noPointsLabel = vgui.Create("DLabel", scroll)
        noPointsLabel:SetText(L("noPointsFoundForType"))
        noPointsLabel:SetFont("LiliaFont.24")
        noPointsLabel:SetContentAlignment(5)
        noPointsLabel:Dock(FILL)
        noPointsLabel:SetTextColor(Color(200, 200, 200))
    end
end
