lia.adminStickMapState = lia.adminStickMapState or lia.mapConfigurerState or {
    modeIndex = 1,
    cachedPositions = {},
    cacheType = nil,
    lastRequest = 0,
    removalMenuOpen = false
}

lia.mapConfigurerState = lia.adminStickMapState
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

    local radiusCount = net.ReadUInt(16)
    for i = 1, radiusCount do
        local radius = net.ReadFloat()
        if list[i] then list[i].radius = radius end
    end

    lia.adminStickMapState.cacheType = typeId
    lia.adminStickMapState.cachedPositions = list
end)

net.Receive("liaBlindTarget", function()
    local enabled = net.ReadBool()
    if enabled then
        hook.Add("HUDPaint", "blindTarget", function() draw.RoundedBox(0, 0, 0, ScrW(), ScrH(), Color(0, 0, 0, 255)) end)
    else
        hook.Remove("HUDPaint", "blindTarget")
    end
end)

net.Receive("liaBlindFade", function()
    local isWhite = net.ReadBool()
    local duration = net.ReadFloat()
    local fadeIn = net.ReadFloat()
    local fadeOut = net.ReadFloat()
    local startTime = CurTime()
    local endTime = startTime + duration
    local color = isWhite and Color(255, 255, 255) or Color(0, 0, 0)
    local hookName = "blindFade" .. startTime
    hook.Add("HUDPaint", hookName, function()
        local ct = CurTime()
        if ct >= endTime then
            hook.Remove("HUDPaint", hookName)
            return
        end

        local alpha
        if ct < startTime + fadeIn then
            alpha = (ct - startTime) / fadeIn
        elseif ct > endTime - fadeOut then
            alpha = (endTime - ct) / fadeOut
        else
            alpha = 1
        end

        surface.SetDrawColor(color.r, color.g, color.b, math.Clamp(alpha * 255, 0, 255))
        surface.DrawRect(0, 0, ScrW(), ScrH())
    end)
end)

net.Receive("liaAdminModeSwapCharacter", function()
    local id = net.ReadInt(32)
    assert(isnumber(id), "id must be a number")
    local d = deferred.new()
    net.Receive("liaCharChoose", function()
        local message = net.ReadString()
        if message == "" then
            d:resolve()
            lia.char.getCharacter(id, nil, function(character)
                local client = LocalPlayer()
                if IsValid(client) then client:SetNoDraw(false) end
                hook.Run("CharLoaded", character)
            end)
        else
            d:reject(lia.lang.resolve(message))
        end
    end)

    net.Start("liaCharChoose")
    net.WriteUInt(id, 32)
    net.SendToServer()
    d:catch(function(err) if err and err ~= "" then LocalPlayer():notifyError(err) end end)
end)

lia.net.readBigTable("liaMapEntities", function(entities)
    local adminModule = lia.module.get("administration")
    if not adminModule then return end
    adminModule.playerEntityData = istable(entities) and entities or {}
    if isfunction(adminModule.ReconcilePlayerEntityWaypoints) then adminModule:ReconcilePlayerEntityWaypoints(adminModule:BuildPlayerEntityData(adminModule.playerEntityData)) end
    local panel = adminModule.playerEntityPanel
    if IsValid(panel) and isfunction(panel.SetEntities) then panel:SetEntities(adminModule.playerEntityData) end
end)

lia.net.readBigTable("liaStaffCasesSnapshot", function(payload)
    payload = payload or {}
    local adminModule = lia.module.get("administration")
    if not adminModule then return end
    adminModule.staffCasesPayload = {
        tickets = payload.tickets or {},
        warnings = payload.warnings or {},
        pks = payload.pks or {}
    }

    local panel = adminModule.staffCasesPanel
    if IsValid(panel) and isfunction(panel.RefreshData) then panel:RefreshData() end
end)

net.Receive("liaCharDeleted", function() if IsValid(panelRef) and isfunction(panelRef.buildSheets) and MODULE and isfunction(MODULE.startFullCharListRequest) then MODULE:startFullCharListRequest(panelRef) end end)
net.Receive("liaOnlineStaffData", function()
    local staffData = net.ReadTable() or {}
    hook.Run("OnlineStaffDataReceived", staffData)
end)
