local GM = GM or GAMEMODE
local RealTime, FrameTime = RealTime, FrameTime
local mathApproach = math.Approach
local IsValid = IsValid
local toScreen = FindMetaTable("Vector").ToScreen
local paintedEntitiesCache = {}
local lastTrace = {
    mins = Vector(-4, -4, -4),
    maxs = Vector(4, 4, 4),
    mask = MASK_SHOT_HULL,
    filter = nil,
    start = nil,
    endpos = nil
}

local hidden = {
    CHUDAutoAim = true,
    CHudHealth = true,
    CHudCrosshair = true,
    CHudBattery = true,
    CHudAmmo = true,
    CHudSecondaryAmmo = true,
    CHudHistoryResource = true,
    CHudChat = true,
    CHudDamageIndicator = true,
    CHudVoiceStatus = true,
    CHudHints = true
}

local VoiceRanges = {
    [L("whispering")] = 120,
    [L("talking")] = 300,
    [L("yelling")] = 600,
}

local lastEntity
local nextUpdate = 0
local healthPercent = {
    {
        threshold = 0.2,
        text = L("criticalCondition"),
        color = Color(192, 57, 43)
    },
    {
        threshold = 0.4,
        text = L("seriousInjury"),
        color = Color(231, 76, 60)
    },
    {
        threshold = 0.6,
        text = L("moderateInjury"),
        color = Color(255, 152, 0)
    },
    {
        threshold = 0.8,
        text = L("minorInjury"),
        color = Color(255, 193, 7)
    },
    {
        threshold = 1.0,
        text = L("healthyStatus"),
        color = Color(46, 204, 113)
    }
}

local NoDrawCrosshairWeapon = {
    weapon_crowbar = true,
    weapon_stunstick = true,
    weapon_bugbait = true
}

local function canDrawAmmo(wpn)
    if IsValid(wpn) and wpn.DrawAmmo ~= false and lia.config.get("AmmoDrawEnabled", false) then return hook.Run("ShouldDrawAmmo", wpn) ~= false end
end

local function drawAmmo(wpn)
    local client = LocalPlayer()
    if not IsValid(wpn) then return end
    local clip = wpn:Clip1()
    local count = client:GetAmmoCount(wpn:GetPrimaryAmmoType())
    local sec = client:GetAmmoCount(wpn:GetSecondaryAmmoType())
    local x, y = ScrW() - 80, ScrH() - 80
    if sec > 0 then
        lia.util.drawBlurAt(x, y, 64, 64)
        surface.SetDrawColor(255, 255, 255, 5)
        surface.DrawRect(x, y, 64, 64)
        surface.SetDrawColor(255, 255, 255, 3)
        surface.DrawOutlinedRect(x, y, 64, 64)
        lia.util.drawText(sec, x + 32, y + 32, nil, 1, 1, "liaBigFont")
    end

    if wpn:GetClass() ~= "weapon_slam" and (clip > 0 or count > 0) then
        x = x - (sec > 0 and 144 or 64)
        lia.util.drawBlurAt(x, y, 128, 64)
        surface.SetDrawColor(255, 255, 255, 5)
        surface.DrawRect(x, y, 128, 64)
        surface.SetDrawColor(255, 255, 255, 3)
        surface.DrawOutlinedRect(x, y, 128, 64)
        lia.util.drawText(clip == -1 and count or clip .. "/" .. count, x + 64, y + 32, nil, 1, 1, "liaBigFont")
    end
end

local function canDrawCrosshair()
    local client = LocalPlayer()
    local rag = client:getNetVar("ragdoll")
    local wpn = client:GetActiveWeapon()
    if not client:getChar() then return false end
    if IsValid(wpn) then
        local cl = wpn:GetClass()
        if cl == "gmod_tool" or string.find(cl, "lia_") or string.find(cl, "detector_") then return true end
        if not NoDrawCrosshairWeapon[cl] and lia.config.get("CrosshairEnabled", true) and client:Alive() and not IsValid(rag) and not (g_ContextMenu:IsVisible() or IsValid(lia.gui.character) and lia.gui.character:IsVisible()) then return true end
    end
end

local function drawCrosshair()
    local client = LocalPlayer()
    local trace = util.QuickTrace(client:GetShootPos(), client:GetAimVector() * 15000, client)
    if trace.HitPos then
        local p = trace.HitPos:ToScreen()
        if p then
            local s = 3
            draw.RoundedBox(0, math.Round(p.x - s / 2), math.Round(p.y - s / 2), s, s, color_white)
            s = s - 2
            draw.RoundedBox(0, math.Round(p.x - s / 2), math.Round(p.y - s / 2), s, s, color_white)
        end
    end
end

local function RenderEntities()
    local client = LocalPlayer()
    if client:getChar() then
        local ft = FrameTime()
        local rt = RealTime()
        if nextUpdate < rt then
            nextUpdate = rt + 0.5
            lastTrace.start = client:GetShootPos()
            lastTrace.endpos = lastTrace.start + client:GetAimVector() * 160
            lastTrace.filter = client
            lastTrace.mins = Vector(-4, -4, -4)
            lastTrace.maxs = Vector(4, 4, 4)
            lastTrace.mask = MASK_SHOT_HULL
            lastEntity = util.TraceHull(lastTrace).Entity
            if IsValid(lastEntity) then
                local shouldDraw = hook.Run("ShouldDrawEntityInfo", lastEntity)
                if shouldDraw then paintedEntitiesCache[lastEntity] = true end
            end
        end

        for ent, drawing in pairs(paintedEntitiesCache) do
            if IsValid(ent) then
                local goal = drawing and 255 or 0
                local a = mathApproach(ent.liaAlpha or 0, goal, ft * 1000)
                if lastEntity ~= ent then paintedEntitiesCache[ent] = false end
                if a > 0 then
                    local netPlayer = ent.getNetVar and ent:getNetVar("player")
                    if IsValid(netPlayer) then
                        local p = toScreen(ent:LocalToWorld(ent:OBBCenter()))
                        hook.Run("DrawEntityInfo", netPlayer, a, p)
                    elseif ent.onDrawEntityInfo then
                        ent.onDrawEntityInfo(ent, a)
                    else
                        hook.Run("DrawEntityInfo", ent, a)
                    end
                end

                ent.liaAlpha = a
                if a == 0 and goal == 0 then paintedEntitiesCache[ent] = nil end
            else
                paintedEntitiesCache[ent] = nil
            end
        end
    end
end

function GM:PostDrawOpaqueRenderables()
    if not lia.option.get("voiceRange", false) then return end
    local client = LocalPlayer()
    if not (IsValid(client) and client:IsSpeaking() and client:getChar()) then return end
    local vt = client:getNetVar("VoiceType", L("talking"))
    local radius = VoiceRanges[vt] or VoiceRanges[L("talking")]
    local segments = 36
    local pos = client:GetPos() + Vector(0, 0, 2)
    local color = Color(0, 150, 255)
    render.SetColorMaterial()
    for i = 0, segments - 1 do
        local startAng = math.rad(i / segments * 360)
        local endAng = math.rad((i + 1) / segments * 360)
        local startPos = pos + Vector(math.cos(startAng), math.sin(startAng), 0) * radius
        local endPos = pos + Vector(math.cos(endAng), math.sin(endAng), 0) * radius
        render.DrawLine(startPos, endPos, color, false)
    end
end

function GM:ShouldDrawEntityInfo(e)
    if IsValid(e) then
        if e:IsPlayer() and e:getChar() then
            if e:GetMoveType() == MOVETYPE_NOCLIP or e:GetNoDraw() then return false end
            return true
        end

        if e.getNetVar then
            local ply = e:getNetVar("player")
            if IsValid(ply) then return e == LocalPlayer() and not LocalPlayer():ShouldDrawLocalPlayer() end
        end

        if e.DrawEntityInfo then return true end
        if e.onShouldDrawEntityInfo and e:onShouldDrawEntityInfo() then return true end
        return true
    end
    return false
end

function GM:GetInjuredText(c)
    local h = c:Health()
    local mh = c:GetMaxHealth() or 100
    local p = h / mh
    for _, entry in ipairs(healthPercent) do
        if p <= entry.threshold then return {entry.text, entry.color} end
    end

    local last = healthPercent[#healthPercent]
    return {last.text, last.color}
end

function GM:DrawCharInfo(c, _, info)
    local injured = hook.Run("GetInjuredText", c)
    if injured then info[#info + 1] = {L(injured[1]), injured[2]} end
end

function GM:DrawEntityInfo(e, a, pos)
    if not e:IsPlayer() or hook.Run("ShouldDrawPlayerInfo", e) == false then return end
    local ch = e:getChar()
    if not ch then return end
    pos = pos or toScreen(e:GetPos() + (e:Crouching() and Vector(0, 0, 48) or Vector(0, 0, 80)))
    local x, y = pos.x, pos.y
    local charInfo = {}
    local width = lia.config.get("descriptionWidth", 0.5)
    if e.widthCache ~= width then
        e.widthCache = width
        e.liaNameCache = nil
        e.liaDescCache = nil
    end

    local name = hook.Run("GetDisplayedName", e) or ch and ch.getName(ch) or e:Name()
    if name ~= e.liaNameCache then
        e.liaNameCache = name
        if #name > 250 then name = name:sub(1, 250) .. "..." end
        e.liaNameLines = lia.util.wrapText(name, ScrW() * width, "liaSmallFont")
    end

    for i = 1, #e.liaNameLines do
        charInfo[#charInfo + 1] = {e.liaNameLines[i], color_white}
    end

    local desc = hook.Run("GetDisplayedDescription", e, true) or ch and ch.getDesc(ch) or L("noChar")
    if desc ~= e.liaDescCache then
        e.liaDescCache = desc
        if #desc > 250 then desc = desc:sub(1, 250) .. "..." end
        e.liaDescLines = lia.util.wrapText(desc, ScrW() * width, "liaSmallFont")
    end

    for i = 1, #e.liaDescLines do
        charInfo[#charInfo + 1] = {e.liaDescLines[i]}
    end

    if ch then hook.Run("DrawCharInfo", e, ch, charInfo) end
    for i = 1, #charInfo do
        local info = charInfo[i]
        local _, ty = lia.util.drawText(info[1]:gsub("#", "\226\128\139#"), x, y, ColorAlpha(info[2] or color_white, a), 1, 1, "liaSmallFont")
        y = y + ty
    end
end

local function drawVoiceIndicator()
    local client = LocalPlayer()
    if not IsValid(client) or not client:IsSpeaking() then return end
    local voiceType = client:getNetVar("VoiceType", L("talking"))
    local voiceText = L("youAre") .. " " .. voiceType
    if lia.option.get("voiceRange", false) then
        local radius = VoiceRanges[voiceType] or VoiceRanges[L("talking")]
        local clientPos = client:GetPos()
        local count = 0
        for _, ply in player.Iterator() do
            if ply ~= client and IsValid(ply) and ply:getChar() and ply:Alive() then
                local distance = clientPos:Distance(ply:GetPos())
                if distance <= radius then count = count + 1 end
            end
        end

        if count > 0 then voiceText = voiceText .. " - " .. count .. " people can hear you" end
    end

    local modifiedText = hook.Run("ModifyVoiceIndicatorText", client, voiceText, voiceType)
    if modifiedText then voiceText = modifiedText end
    local boxX = ScrW() / 2
    local boxY = 50
    lia.derma.drawBoxWithText(voiceText, boxX, boxY, {
        font = "LiliaFont.18",
        textColor = Color(255, 255, 255),
        backgroundColor = Color(0, 0, 0, 150),
        borderColor = lia.color.theme.theme,
        borderRadius = 8,
        borderThickness = 2,
        padding = 20,
        textAlignX = TEXT_ALIGN_CENTER,
        textAlignY = TEXT_ALIGN_CENTER,
        autoSize = true
    })
end

function GM:HUDPaint()
    local client = LocalPlayer()
    if client:Alive() and client:getChar() then
        local wpn = client:GetActiveWeapon()
        if canDrawAmmo(wpn) then drawAmmo(wpn) end
        if canDrawCrosshair() then drawCrosshair() end
        local hudInfos = {}
        hook.Run("DisplayPlayerHUDInformation", client, hudInfos)
        if #hudInfos > 0 then
            for _, info in ipairs(hudInfos) do
                if info.text and info.position then
                    local drawOptions = {
                        textColor = info.color or Color(255, 255, 255),
                        font = info.font or "LiliaFont.20"
                    }

                    if info.backgroundColor then drawOptions.backgroundColor = info.backgroundColor end
                    if info.borderColor then drawOptions.borderColor = info.borderColor end
                    if info.borderRadius then drawOptions.borderRadius = info.borderRadius end
                    if info.borderThickness then drawOptions.borderThickness = info.borderThickness end
                    if info.padding then drawOptions.padding = info.padding end
                    if info.textAlignX then drawOptions.textAlignX = info.textAlignX end
                    if info.textAlignY then drawOptions.textAlignY = info.textAlignY end
                    if info.lineSpacing then drawOptions.lineSpacing = info.lineSpacing end
                    if info.autoSize then drawOptions.autoSize = info.autoSize end
                    if info.blur then drawOptions.blur = info.blur end
                    lia.derma.drawBoxWithText(info.text, info.position.x, info.position.y, drawOptions)
                end
            end
        end
    end

    drawVoiceIndicator()
end

function GM:TooltipInitialize(var, panel)
    if panel.liaToolTip or panel.itemID then
        var.markupObject = lia.markup.parse(var:GetText(), ScrW() * 0.15)
        var:SetText("")
        var:SetWide(math.max(ScrW() * 0.15, 200) + 12)
        var:SetHeight(var.markupObject:getHeight() + 12)
        var:SetAlpha(0)
        var:AlphaTo(255, 0.2, 0)
        var.isItemTooltip = true
    end
end

function GM:TooltipPaint(var, w, h)
    if var.isItemTooltip then
        lia.util.drawBlur(var, 2, 2)
        surface.SetDrawColor(0, 0, 0, 230)
        surface.DrawRect(0, 0, w, h)
        var.markupObject:draw(6, 8)
        return true
    end
end

function GM:TooltipLayout(var)
    return var.isItemTooltip
end

function GM:DrawLiliaModelView(_, entity)
    if IsValid(entity.weapon) then entity.weapon:DrawModel() end
end

function GM:OnChatReceived()
    if system.IsWindows() and not system.HasFocus() then system.FlashWindow() end
end

function GM:CreateMove(cmd)
    local client = LocalPlayer()
    if IsValid(client) and client:getNetVar("bIsHoldingObject", false) and cmd:KeyDown(IN_ATTACK2) then
        cmd:ClearMovement()
        local angle = cmd:GetViewAngles()
        angle.z = 0
        cmd:SetViewAngles(angle)
    end
end

function GM:CalcView(client, origin, angles, fov)
    if factionViewEnabled and factionViewPosition then
        local view = self.BaseClass:CalcView(client, origin, angles, fov)
        view.origin = factionViewPosition
        if factionViewAngles then view.angles = factionViewAngles end
        view.znear = 1
        if not factionViewModel or not IsValid(factionViewModel) then factionViewModel = ClientsideModel("models/error.mdl", RENDERGROUP_OPAQUE) end
        if IsValid(factionViewModel) then
            local forwardOffset = factionViewAngles and factionViewAngles:Forward() * 50 or Vector(0, 0, 50)
            local modelPos = factionViewPosition + forwardOffset
            factionViewModel:SetPos(modelPos)
            factionViewModel:SetAngles(factionViewAngles or Angle(0, 180, 0))
            if factionViewFaction then
                local faction = lia.faction.teams[factionViewFaction]
                if faction and faction.models then
                    local modelInfo = faction.models[1]
                    local modelPath = modelInfo
                    if istable(modelInfo) then modelPath = modelInfo[1] end
                    if modelPath and modelPath ~= factionViewModel:GetModel() then factionViewModel:SetModel(modelPath) end
                end
            end

            factionViewModel:DrawModel()
        end
        return view
    end

    local ragEntity = client:getNetVar("ragdoll")
    local ragdoll = client:GetRagdollEntity()
    local ent
    if not IsValid(client:GetVehicle()) and client:GetViewEntity() == client and not client:ShouldDrawLocalPlayer() then
        if IsValid(ragEntity) and ragEntity:IsRagdoll() then
            ent = ragEntity
        elseif not client:Alive() and IsValid(ragdoll) then
            ent = ragdoll
        end
    end

    if ent and ent:IsValid() then
        local idx = ent:LookupAttachment("eyes")
        if idx then
            local data = ent:GetAttachment(idx)
            if data then
                local view = self.BaseClass:CalcView(client, origin, angles, fov)
                view.origin = data.Pos
                view.angles = data.Ang
                view.znear = 1
                return view
            end
        end
    end
end

function GM:PlayerBindPress(client, bind, pressed)
    bind = bind:lower()
    if bind:find("jump") and IsValid(client:getNetVar("ragdoll")) then lia.command.send("chargetup") end
    if bind:find("use") then
        local entity = client:getTracedEntity()
        local hasValidEntity = IsValid(entity) and (entity:isItem() or entity.hasMenu)
        if pressed and hasValidEntity then hook.Run("ItemShowEntityMenu", entity) end
    end

    if (bind:find("use") or bind:find("attack")) and pressed then
        local menu, callback = lia.menu.getActiveMenu()
        if menu and lia.menu.onButtonPressed(menu, callback) then return true end
    end
end

local liaItemDermaMenu = nil
function GM:ItemShowEntityMenu(entity)
    for k, v in ipairs(lia.menu.list) do
        if v.entity == entity then table.remove(lia.menu.list, k) end
    end

    local itemTable = entity:getItemTable()
    if not itemTable then return end
    if not useKeyHeld and input.IsShiftDown() then
        if IsValid(entity) then
            net.Start("liaInvAct")
            net.WriteString("take")
            net.WriteType(entity)
            net.WriteType(nil)
            net.SendToServer()
        end
        return
    end

    if IsValid(liaItemDermaMenu) then liaItemDermaMenu:Remove() end
    liaItemDermaMenu = vgui.Create("liaDermaMenu")
    local tempItem = table.Copy(itemTable)
    tempItem.player = LocalPlayer()
    tempItem.entity = entity
    for key, fn in SortedPairs(itemTable.functions) do
        if key == "combine" then continue end
        if hook.Run("CanRunItemAction", tempItem, key) == false then continue end
        if isfunction(fn.onCanRun) and not fn.onCanRun(tempItem) then continue end
        liaItemDermaMenu:AddOption(L(fn.name or key), function()
            if fn.sound then surface.PlaySound(fn.sound) end
            if not fn.onClick or fn.onClick(tempItem) ~= false then
                net.Start("liaInvAct")
                net.WriteString(key)
                net.WriteType(entity)
                net.WriteType(nil)
                net.SendToServer()
            end

            liaItemDermaMenu:Remove()
            liaItemMenuVisible = false
        end, fn.icon)
    end

    local pos = entity:GetPos()
    local screenPos = pos:ToScreen()
    local menuX = screenPos.x - liaItemDermaMenu:GetWide() / 2
    local menuY = screenPos.y - liaItemDermaMenu:GetTall() - 20
    menuX = math.Clamp(menuX, 0, ScrW() - liaItemDermaMenu:GetWide())
    menuY = math.Clamp(menuY, 0, ScrH() - liaItemDermaMenu:GetTall())
    liaItemDermaMenu:SetPos(menuX, menuY)
    liaItemDermaMenu:MakePopup()
    liaItemDermaMenu:SetVisible(true)
    liaItemDermaMenu:SetKeyboardInputEnabled(false)
    liaItemDermaMenu:SetMouseInputEnabled(true)
    liaItemDermaMenu.OnRemove = function() liaItemMenuVisible = false end
    liaItemMenuVisible = true
end

function GM:HUDPaintBackground()
    lia.menu.drawAll()
    RenderEntities()
    if BRANCH ~= "x86-64" then draw.SimpleText(L("switchTo64Bit"), "liaSmallFont", ScrW() * 0.5, ScrH() * 0.97, Color(255, 255, 255, 10), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) end
end

function GM:OnContextMenuOpen()
    self.BaseClass:OnContextMenuOpen()
    if hook.Run("ShouldShowQuickMenu") == false then return end
    if IsValid(lia.gui.quick) then
        lia.gui.quick:Remove()
        lia.gui.quick = nil
    end

    lia.gui.quick = vgui.Create("liaQuick")
end

function GM:OnContextMenuClose()
    self.BaseClass:OnContextMenuClose()
    if IsValid(lia.gui.quick) then
        lia.gui.quick:Remove()
        lia.gui.quick = nil
    end
end

function GM:CharListLoaded()
    timer.Create("liaWaitUntilPlayerValid", 1, 0, function()
        local client = LocalPlayer()
        if not IsValid(client) then return end
        timer.Remove("liaWaitUntilPlayerValid")
        hook.Run("PreLiliaLoaded")
        lia.option.load()
        hook.Run("LiliaLoaded")
    end)
end

function GM:ForceDermaSkin()
    return lia.config.get("DermaSkin", L("liliaSkin"))
end

function GM:DermaSkinChanged()
    derma.RefreshSkins()
end

function GM:HUDShouldDraw(element)
    return not hidden[element]
end

function GM:PrePlayerDraw(client)
    if not client:getChar() then return true end
end

function GM:PlayerStartVoice(client)
    if not IsValid(g_VoicePanelList) or not lia.config.get("IsVoiceEnabled", true) then return end
    if client:getNetVar("IsDeadRestricted", false) then return false end
    hook.Run("PlayerEndVoice", client)
    local pnl = VoicePanels[client]
    if IsValid(pnl) then
        if pnl.fadeAnim then
            pnl.fadeAnim:Stop()
            pnl.fadeAnim = nil
        end

        pnl:SetAlpha(255)
        return
    end

    if not IsValid(client) then return end
    pnl = g_VoicePanelList:Add("liaVoicePanel")
    pnl:Setup(client)
    VoicePanels[client] = pnl
end

function GM:PlayerEndVoice(client)
    local pnl = VoicePanels[client]
    if IsValid(pnl) and not pnl.fadeAnim then
        pnl.fadeAnim = Derma_Anim("FadeOut", pnl, pnl.FadeOut)
        pnl.fadeAnim:Start(2)
    end
end

function GM:VoiceToggled(enabled)
    if not IsValid(g_VoicePanelList) then return end
    if not enabled then
        for client, pnl in pairs(VoicePanels) do
            if IsValid(pnl) then pnl:Remove() end
            VoicePanels[client] = nil
        end
    end
end

function GM:SpawnMenuOpen()
    local client = LocalPlayer()
    if lia.config.get("SpawnMenuLimit", false) and not (client:hasFlags("pet") or client:isStaffOnDuty() or client:hasPrivilege("canSpawnProps")) then return end
    return true
end

function GM:InitPostEntity()
    lia.joinTime = RealTime() - 0.9716
    if system.IsWindows() and not system.HasFocus() then system.FlashWindow() end
    net.Start("liaStorageSyncRequest")
    net.SendToServer()
end

function GM:HUDDrawTargetID()
    return false
end

function GM:HUDDrawPickupHistory()
    return false
end

function GM:HUDAmmoPickedUp()
    return false
end

function GM:DrawDeathNotice()
    return false
end

function GM:GetMainMenuPosition(character)
    if character and character:getFaction() then
        local faction = lia.faction.get(character:getFaction())
        if faction and faction.mainMenuPosition then
            local menuPos = faction.mainMenuPosition
            local currentMap = game.GetMap()
            if istable(menuPos) and menuPos[currentMap] then
                local mapPos = menuPos[currentMap]
                if istable(mapPos) then
                    return mapPos.position, mapPos.angles
                elseif isvector(mapPos) then
                    return mapPos, Angle(0, 0, 0)
                end
            end

            if istable(menuPos) then
                return menuPos.position, menuPos.angles
            elseif isvector(menuPos) then
                return menuPos, Angle(0, 0, 0)
            end
        end
    end
end