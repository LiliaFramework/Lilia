local function closeAdminStickMenu()
    if AdminStickIsOpen and IsValid(AdminStickMenu) then AdminStickMenu:Remove() end
end

local function isSelfSelectHeld(client)
    return IsValid(client) and (client:KeyDown(IN_SPEED) or input.IsKeyDown(KEY_LSHIFT) or input.IsKeyDown(KEY_RSHIFT))
end

local function openAdminStickTarget(client, target)
    if not IsValid(client) or not IsValid(target) then return end
    closeAdminStickMenu()
    client.AdminStickTarget = target
    hook.Run("OpenAdminStickUI", target)
end

local function getAdminStickHUDTitle(target)
    if not IsValid(target) then return L("adminStick") end
    if target:IsPlayer() then
        local character = target.getChar and target:getChar()
        return character and character:getName() or target:Nick()
    end

    if target.IsVendor and target.getName then
        local vendorName = target:getName()
        if vendorName and vendorName ~= "" then return vendorName end
    end

    if target.GetName then
        local name = target:GetName()
        if name and name ~= "" then return name end
    end
    return target.PrintName or target:GetClass() or L("unknown")
end

local function normalizeAdminStickHUDRows(information)
    local rows = {}
    for _, entry in ipairs(information or {}) do
        if istable(entry) then
            rows[#rows + 1] = table.Copy(entry)
        elseif isstring(entry) then
            local text = string.Trim(entry)
            if text == "" then
                rows[#rows + 1] = {
                    divider = true
                }
            else
                local label, value = text:match("^([^:]+):%s*(.+)$")
                if label and value then
                    rows[#rows + 1] = {
                        label = string.Trim(label),
                        value = string.Trim(value)
                    }
                else
                    rows[#rows + 1] = {
                        text = text
                    }
                end
            end
        end
    end
    return rows
end

local function buildAdminStickHUDRows(client, target)
    local information = {}
    hook.Run("AddToAdminStickHUD", client, target, information)
    return normalizeAdminStickHUDRows(information)
end

local REQUEST_THROTTLE = 0.5
local mapState = lia.adminStickMapState or lia.mapConfigurerState or {
    typeIndex = 1,
    cachedPositions = {},
    cacheType = nil,
    lastRequest = 0,
    removalMenuOpen = false
}

lia.adminStickMapState = mapState
lia.mapConfigurerState = mapState
mapState.typeIndex = mapState.typeIndex or mapState.modeIndex or 1
local function canUseMapConfigurer(client)
    return IsValid(client) and (client:hasPrivilege("usePositionTool") or client:hasPrivilege("alwaysSpawnAdminStick") or client:isStaffOnDuty())
end

local function canUseDebugMode(client)
    return IsValid(client) and (client:hasPrivilege("developmentHUD") or client:hasPrivilege("staffHUD"))
end

local function formatDebugVector(vector)
    return string.format("%.2f, %.2f, %.2f", vector.x, vector.y, vector.z)
end

local function buildDebugHUDRows(client)
    local rows = {}
    if client:hasPrivilege("developmentHUD") then
        rows[#rows + 1] = {
            label = "SteamID64",
            value = client:SteamID64()
        }

        rows[#rows + 1] = {
            label = "SteamID",
            value = client:SteamID()
        }

        rows[#rows + 1] = {
            label = "Date / Time",
            value = os.date("%m/%d/%Y | %X", os.time())
        }
    end

    if client:hasPrivilege("staffHUD") then
        local trace = client:GetEyeTraceNoCursor()
        rows[#rows + 1] = {
            section = "Position"
        }

        rows[#rows + 1] = {
            label = "Pos",
            value = formatDebugVector(client:GetPos())
        }

        rows[#rows + 1] = {
            label = "Ang",
            value = formatDebugVector(client:EyeAngles())
        }

        rows[#rows + 1] = {
            label = "Trace Pos",
            value = formatDebugVector(trace.HitPos)
        }

        rows[#rows + 1] = {
            label = "Trace Dist",
            value = string.format("%.2f", client:GetPos():Distance(trace.HitPos))
        }

        rows[#rows + 1] = {
            section = "Performance"
        }

        rows[#rows + 1] = {
            label = "Health",
            value = client:Health()
        }

        rows[#rows + 1] = {
            label = "Ping",
            value = client:Ping()
        }

        rows[#rows + 1] = {
            label = "FPS",
            value = math.Round(1 / FrameTime(), 0)
        }

        rows[#rows + 1] = {
            label = "Frame Time",
            value = string.format("%.4f", FrameTime())
        }

        if IsValid(trace.Entity) then
            rows[#rows + 1] = {
                section = "Trace Entity"
            }

            rows[#rows + 1] = {
                label = "Class",
                value = trace.Entity:GetClass()
            }

            rows[#rows + 1] = {
                label = "Model",
                value = trace.Entity.GetModel and trace.Entity:GetModel() or "N/A"
            }
        end
    end
    return rows
end

local function getPositionTypes()
    return lia.util.featurePositionTypes or {}
end

local function getPositionType()
    local types = getPositionTypes()
    if #types == 0 then return nil end
    mapState.typeIndex = (mapState.typeIndex - 1) % #types + 1
    return types[mapState.typeIndex]
end

local function requestPositions(typeId)
    if CurTime() - mapState.lastRequest < REQUEST_THROTTLE then return end
    mapState.lastRequest = CurTime()
    local callback = lia.util.positionCallbacks[typeId]
    if callback and callback.onSelect and not callback.serverOnly then
        callback.onSelect(LocalPlayer(), function(positions)
            mapState.cacheType = typeId
            mapState.cachedPositions = positions or {}
        end)
    else
        net.Start("liaFeaturePositionsRequest")
        net.WriteString(typeId or "")
        net.SendToServer()
    end
end

local function refreshPositions(weapon, typeId)
    timer.Simple(0.5, function()
        local client = LocalPlayer()
        if IsValid(client) and client:GetActiveWeapon() == weapon then requestPositions(typeId) end
    end)
end

local function openRemovalMenu(weapon)
    local typeInfo = getPositionType()
    if not typeInfo or mapState.removalMenuOpen then return end
    mapState.removalMenuOpen = true
    local frame = vgui.Create("DFrame")
    frame:SetSize(600, 400)
    frame:SetTitle(L("removeThing", typeInfo.name or L("points")))
    frame:Center()
    frame:MakePopup()
    function frame:OnClose()
        mapState.removalMenuOpen = false
    end

    local scroll = vgui.Create("DScrollPanel", frame)
    scroll:Dock(FILL)
    scroll:DockMargin(5, 5, 5, 5)
    local clientPos = LocalPlayer():GetPos()
    if #mapState.cachedPositions == 0 then
        local label = vgui.Create("DLabel", scroll)
        label:SetText(L("noPointsFoundForType"))
        label:SetFont("LiliaFont.24")
        label:SetContentAlignment(5)
        label:Dock(FILL)
        return
    end

    for index, point in ipairs(mapState.cachedPositions) do
        local row = vgui.Create("DPanel", scroll)
        row:SetTall(60)
        row:Dock(TOP)
        row:DockMargin(0, 0, 0, 5)
        local label = vgui.Create("DLabel", row)
        label:SetText(L("pointDistanceInfo", point.label or L("pointNumber", index), math.Round(clientPos:Distance(point.pos))))
        label:SetFont("LiliaFont.20")
        label:Dock(LEFT)
        label:DockMargin(10, 0, 0, 0)
        label:SizeToContents()
        local button = vgui.Create("DButton", row)
        button:SetText(L("remove"))
        button:SetSize(80, 30)
        button:Dock(RIGHT)
        button:DockMargin(0, 15, 10, 15)
        button.DoClick = function()
            lia.util.removeFeaturePosition(point.pos, typeInfo.id)
            LocalPlayer():notifySuccessLocalized("removedPoint", point.label or L("pointNumber", index))
            frame:Close()
            refreshPositions(weapon, typeInfo.id)
        end
    end
end

SWEP:RegisterMode("admin", {
    name = function() return L("administrativeMode") end,
    PrimaryAttack = function(_, client)
        if isSelfSelectHeld(client) then return openAdminStickTarget(client, client) end
        openAdminStickTarget(client, client:GetEyeTrace().Entity)
    end,
    SecondaryAttack = function(weapon, client)
        local target = weapon:GetTarget()
        if IsValid(target) and target:IsPlayer() and target ~= client then
            lia.admin.execCommand(target:IsFrozen() and "unfreeze" or "freeze", target:IsBot() and target:Name() or target:SteamID())
        else
            client:notifyErrorLocalized("cantFreezeTarget")
        end
    end,
    Reload = function(_, client)
        if isSelfSelectHeld(client) then
            openAdminStickTarget(client, client)
        else
            closeAdminStickMenu()
            client.AdminStickTarget = nil
        end
    end,
    OnExit = function() closeAdminStickMenu() end
})

SWEP:RegisterMode("map_configurer", {
    name = function() return L("worldConfigurationMode") end,
    CanUse = canUseMapConfigurer,
    PrimaryAttack = function(weapon, client)
        local typeInfo = getPositionType()
        local trace = client:GetEyeTrace()
        if typeInfo and trace.Hit then
            lia.util.setFeaturePosition(trace.HitPos + (trace.HitNormal or vector_up) * 2, typeInfo.id)
            refreshPositions(weapon, typeInfo.id)
        end
    end,
    SecondaryAttack = function(weapon, client)
        local typeInfo = getPositionType()
        if typeInfo then
            lia.util.setFeaturePosition(client:GetPos(), typeInfo.id)
            refreshPositions(weapon, typeInfo.id)
        end
    end,
    Reload = function()
        local types = getPositionTypes()
        if #types == 0 then return end
        mapState.typeIndex = mapState.typeIndex % #types + 1
        local typeInfo = getPositionType()
        if typeInfo then requestPositions(typeInfo.id) end
    end,
    Think = function(weapon, client)
        local typeInfo = getPositionType()
        if client:KeyDown(IN_SPEED) and client:KeyDown(IN_USE) and not mapState.removalMenuOpen and (weapon._nextRemovalMenu or 0) < CurTime() then
            weapon._nextRemovalMenu = CurTime() + 1
            openRemovalMenu(weapon)
        end

        if typeInfo and (mapState.cacheType ~= typeInfo.id or (#mapState.cachedPositions == 0 and (weapon._lastEmptyRequest or 0) < CurTime() - 2)) then
            weapon._lastEmptyRequest = CurTime()
            requestPositions(typeInfo.id)
        end
    end,
    OnEnter = function()
        local typeInfo = getPositionType()
        if typeInfo then requestPositions(typeInfo.id) end
    end,
    OnExit = function() mapState.removalMenuOpen = false end
})

SWEP:RegisterMode("debug", {
    name = function() return L("debugMode") end,
    CanUse = canUseDebugMode,
    PrimaryAttack = function(_, client)
        local trace = client:GetEyeTrace()
        if IsValid(trace.Entity) then properties.OpenEntityMenu(trace.Entity, trace) end
    end
})

function SWEP:GetDebugHUDInfo()
    local client = LocalPlayer()
    if self:GetActiveMode() ~= "debug" or not canUseDebugMode(client) then return end
    return L("debugMode"), buildDebugHUDRows(client)
end

local function drawTopRightModeHUD(title, rows)
    lia.derma.drawBoxWithText(nil, ScrW() - 24, 24, {
        title = title,
        rows = rows,
        font = "HUDFont.18",
        textColor = lia.color.theme.text or Color(235, 240, 242),
        textAlignX = TEXT_ALIGN_RIGHT,
        textAlignY = TEXT_ALIGN_TOP,
        backgroundColor = Color(25, 28, 35, 235),
        borderRadius = 12,
        padding = 18,
        blur = {
            enabled = true,
            amount = 4,
            passes = 1,
            alpha = 200
        },
        shadow = {
            enabled = true,
            offsetX = 12,
            offsetY = 12,
            color = Color(0, 0, 0, 170)
        },
        accentBorder = {
            enabled = true,
            height = 2,
            color = lia.color.theme.accent or lia.color.theme.header or lia.color.theme.theme
        }
    })
end

function SWEP:DrawHUD()
    local mode = self:GetActiveMode()
    if mode == "debug" then
        local title, rows = self:GetDebugHUDInfo()
        if title and rows then drawTopRightModeHUD(title, rows) end
        return
    end

    if mode ~= "admin" then return end
    local _, entityRows = self:GetAdminStickHUDInfo()
    local rows = entityRows or {}
    if #rows > 0 then
        rows[#rows + 1] = {
            divider = true
        }
    end

    rows[#rows + 1] = {
        label = L("adminStickHUDReload"),
        value = L("adminStickInstructionSwitchMode"):gsub("^.-:%s*", "")
    }

    drawTopRightModeHUD(L("administrativeMode"), rows)
end

function SWEP:GetAdminStickHUDInfo()
    local client = LocalPlayer()
    if not IsValid(client) or client:GetActiveWeapon() ~= self then return end
    local mode = self:GetActiveMode()
    if mode ~= "admin" then return end
    local target = client:GetEyeTrace().Entity
    if not IsValid(target) then return end
    local rows = buildAdminStickHUDRows(client, target)
    if #rows == 0 then
        rows = {
            {
                label = "Class",
                value = target:GetClass()
            },
            {
                label = "Model",
                value = target.GetModel and target:GetModel() or "N/A"
            }
        }
    end
    return getAdminStickHUDTitle(target), rows
end

function SWEP:PrimaryAttack()
    local client = LocalPlayer()
    if not IsFirstTimePredicted() then return end
    local _, mode = self:GetActiveMode()
    if mode and mode.PrimaryAttack then mode.PrimaryAttack(self, client) end
end

function SWEP:SecondaryAttack()
    local client = LocalPlayer()
    if not IsFirstTimePredicted() then return end
    local _, mode = self:GetActiveMode()
    if mode and mode.SecondaryAttack then mode.SecondaryAttack(self, client) end
end

function SWEP:GetTarget()
    local client = LocalPlayer()
    if not IsValid(self) or self ~= client:GetActiveWeapon() then
        client.AdminStickTarget = nil
        return client:GetEyeTrace().Entity
    end

    local target = IsValid(client.AdminStickTarget) and client.AdminStickTarget or client:GetEyeTrace().Entity
    return target
end

function SWEP:Reload()
    if self.NextReload and self.NextReload > SysTime() then return end
    self.NextReload = SysTime() + 0.5
    local client = LocalPlayer()
    if not isSelfSelectHeld(client) and self:CycleMode() then return end
    local _, mode = self:GetActiveMode()
    if mode and mode.Reload then mode.Reload(self, client) end
end

function SWEP:Deploy()
    local _, mode = self:GetActiveMode()
    if mode and mode.OnEnter then mode.OnEnter(self) end
    return true
end

function SWEP:Think()
    local _, mode = self:GetActiveMode()
    if mode and mode.Think then mode.Think(self, LocalPlayer()) end
end

function SWEP:GetPositionToolMode()
    if self:GetActiveMode() == "map_configurer" then return getPositionType() end
end

function SWEP:GetCachedPositions()
    return mapState.cachedPositions
end

function SWEP:GetCacheType()
    return mapState.cacheType
end

function SWEP:CanUseTool()
    return self:GetActiveMode() == "map_configurer" and canUseMapConfigurer(LocalPlayer())
end

function SWEP:Holster()
    local client = LocalPlayer()
    if IsValid(client) then client.AdminStickTarget = nil end
    local _, mode = self:GetActiveMode()
    if mode and mode.OnExit then mode.OnExit(self) end
    return true
end

hook.Add("OnAdminStickMenuClosed", "ClearAdminStickTarget", function()
    local client = LocalPlayer()
    if IsValid(client) and client.AdminStickTarget == client then client.AdminStickTarget = nil end
end)
