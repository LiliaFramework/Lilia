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
    CHudVoiceStatus = true
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
    if IsValid(wpn) and wpn.DrawAmmo ~= false and lia.config.get("AmmoDrawEnabled", false) then return true end
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
    local rag = client:getRagdoll()
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
            if e:isNoClipping() or e:GetNoDraw() then return false end
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

function GM:HUDPaint()
    local client = LocalPlayer()
    if client:Alive() and client:getChar() then
        local wpn = client:GetActiveWeapon()
        if canDrawAmmo(wpn) then drawAmmo(wpn) end
        if canDrawCrosshair() then drawCrosshair() end
    end
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
    if IsValid(client) and client:getLocalVar("bIsHoldingObject", false) and cmd:KeyDown(IN_ATTACK2) then
        cmd:ClearMovement()
        local angle = cmd:GetViewAngles()
        angle.z = 0
        cmd:SetViewAngles(angle)
    end
end

function GM:CalcView(client, origin, angles, fov)
    local view = self.BaseClass:CalcView(client, origin, angles, fov)
    local ragEntity = client:getRagdoll()
    local ragdoll = client:GetRagdollEntity()
    local ent
    if not client:hasValidVehicle() and client:GetViewEntity() == client and not client:ShouldDrawLocalPlayer() then
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
                view.origin = data.Pos
                view.angles = data.Ang
                view.znear = 1
            end
        end
    end
    return view
end

function GM:PlayerBindPress(client, bind, pressed)
    bind = bind:lower()
    if bind:find("jump") and IsValid(client:getRagdoll()) then lia.command.send("chargetup") end
    if (bind:find("use") or bind:find("attack")) and pressed then
        local menu, callback = lia.menu.getActiveMenu()
        if menu and lia.menu.onButtonPressed(menu, callback) then return true end
        if bind:find("use") then
            local entity = client:getTracedEntity()
            if IsValid(entity) and (entity:isItem() or entity.hasMenu) then hook.Run("ItemShowEntityMenu", entity) end
        end
    end
end

function GM:ItemShowEntityMenu(entity)
    for k, v in ipairs(lia.menu.list) do
        if v.entity == entity then table.remove(lia.menu.list, k) end
    end

    local itemTable = entity:getItemTable()
    if not itemTable then return end
    if input.IsShiftDown() then
        if IsValid(entity) then
            net.Start("invAct")
            net.WriteString("take")
            net.WriteType(entity)
            net.SendToServer()
        end
        return
    end

    if IsValid(liaItemMenuInstance) then liaItemMenuInstance:Remove() end
    liaItemMenuInstance = vgui.Create("liaItemMenu")
    liaItemMenuInstance:SetEntity(entity)
end

function GM:HUDPaintBackground()
    lia.menu.drawAll()
    RenderEntities()
    self.BaseClass.PaintWorldTips(self.BaseClass)
    if BRANCH ~= "x86-64" then draw.SimpleText(L("switchTo64Bit"), "liaSmallFont", ScrW() * 0.5, ScrH() * 0.97, Color(255, 255, 255, 10), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) end
end

function GM:OnContextMenuOpen()
    self.BaseClass:OnContextMenuOpen()
    vgui.Create("liaQuick")
end

function GM:OnContextMenuClose()
    self.BaseClass:OnContextMenuClose()
    if IsValid(lia.gui.quick) then lia.gui.quick:Remove() end
end

function GM:CharListLoaded()
    timer.Create("liaWaitUntilPlayerValid", 1, 0, function()
        local client = LocalPlayer()
        if not IsValid(client) then return end
        timer.Remove("liaWaitUntilPlayerValid")
        hook.Run("PreLiliaLoaded")
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
    pnl = g_VoicePanelList:Add("VoicePanel")
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
end

concommand.Add("lia_vgui_cleanup", function()
    for _, v in pairs(vgui.GetWorldPanel():GetChildren()) do
        if not (v.Init and debug.getinfo(v.Init, "Sln").short_src:find("chatbox")) then v:Remove() end
    end
end, nil, L("vguiCleanupCommandDesc"))

concommand.Add("weighpoint_stop", function() hook.Add("HUDPaint", "WeighPoint", function() end) end)
local dermaPreviewFrame
concommand.Add("lia_open_derma_preview", function()
    if IsValid(dermaPreviewFrame) then dermaPreviewFrame:Remove() end
    local frame = vgui.Create("DFrame")
    frame:SetTitle(L("dermaPreviewTitle"))
    frame:SetSize(ScrW() * 0.8, ScrH() * 0.8)
    frame:Center()
    frame:MakePopup()
    dermaPreviewFrame = frame
    local scroll = vgui.Create("DScrollPanel", frame)
    scroll:Dock(FILL)
    local function addPreview(name, creator)
        local label = scroll:Add("DLabel")
        label:Dock(TOP)
        label:DockMargin(10, 10, 10, 2)
        label:SetText(name)
        label:SizeToContents()
        local panel = creator()
        if IsValid(panel) then
            panel:Dock(TOP)
            panel:DockMargin(10, 2, 10, 0)
        end
    end

    addPreview("DFrame", function()
        local container = scroll:Add("DPanel")
        container:SetTall(70)
        container:SetPaintBackground(false)
        local miniFrame = vgui.Create("DFrame", container)
        miniFrame:SetTitle("DFrame")
        miniFrame:SetSize(150, 60)
        miniFrame:SetDraggable(false)
        miniFrame:ShowCloseButton(true)
        miniFrame:SetPos(0, 5)
        return container
    end)

    addPreview("DPanel", function()
        local panel = scroll:Add("DPanel")
        panel:SetTall(50)
        return panel
    end)

    addPreview("DButton", function()
        local btn = scroll:Add("DButton")
        btn:SetText("DButton")
        return btn
    end)

    addPreview("DLabel", function()
        local lbl = scroll:Add("DLabel")
        lbl:SetText("DLabel")
        lbl:SizeToContents()
        return lbl
    end)

    addPreview("DTextEntry", function()
        local txt = scroll:Add("DTextEntry")
        txt:SetText("DTextEntry")
        return txt
    end)

    addPreview("DCheckBox", function()
        local cb = scroll:Add("DCheckBox")
        cb:SetValue(true)
        return cb
    end)

    addPreview("DComboBox", function()
        local combo = scroll:Add("DComboBox")
        combo:AddChoice(L("optionWithNumber", 1))
        combo:AddChoice(L("optionWithNumber", 2))
        combo:ChooseOption(L("optionWithNumber", 1), 1)
        return combo
    end)

    addPreview("DListView", function()
        local listView = scroll:Add("DListView")
        listView:SetTall(120)
        listView:AddColumn(L("columnWithNumber", 1))
        listView:AddColumn(L("columnWithNumber", 2))
        listView:AddLine(L("rowColumn", 1, 1), L("rowColumn", 1, 2))
        listView:AddLine(L("rowColumn", 2, 1), L("rowColumn", 2, 2))
        return listView
    end)

    addPreview("DImage", function()
        local container = scroll:Add("DPanel")
        container:SetTall(40)
        container:SetPaintBackground(false)
        local img = vgui.Create("DImage", container)
        img:SetImage("icon16/star.png")
        img:SetSize(32, 32)
        img:SetPos(0, 4)
        return container
    end)

    addPreview("DPanelList", function()
        local list = scroll:Add("DPanelList")
        list:SetTall(80)
        list:EnableVerticalScrollbar()
        list:SetPadding(5)
        for i = 1, 10 do
            local item = vgui.Create("DLabel")
            item:SetText(L("item") .. " " .. i)
            item:SizeToContents()
            list:AddItem(item)
        end
        return list
    end)

    addPreview("DProgressBar", function()
        local progress = scroll:Add("DProgress")
        progress:SetTall(20)
        progress:SetFraction(0.5)
        return progress
    end)

    addPreview("DNumSlider", function()
        local slider = scroll:Add("DNumSlider")
        slider:SetText("DNumSlider")
        slider:SetMin(0)
        slider:SetMax(100)
        slider:SetValue(50)
        slider:SetDecimals(0)
        slider:SetTall(35)
        return slider
    end)

    addPreview("DScrollPanel", function()
        local subScroll = scroll:Add("DScrollPanel")
        subScroll:SetTall(100)
        for i = 1, 20 do
            local line = subScroll:Add("DLabel")
            line:SetText(L("line") .. " " .. i)
            line:Dock(TOP)
            line:DockMargin(0, 0, 0, 5)
        end
        return subScroll
    end)

    addPreview("DTree", function()
        local tree = scroll:Add("DTree")
        tree:SetTall(100)
        local node1 = tree:AddNode(L("nodeWithNumber", 1))
        node1:AddNode(L("childWithNumber", 1))
        node1:AddNode(L("childWithNumber", 2))
        tree:AddNode(L("nodeWithNumber", 2))
        return tree
    end)

    addPreview("DColorMixer", function()
        local mixer = scroll:Add("DColorMixer")
        mixer:SetTall(150)
        mixer:SetPalette(true)
        mixer:SetAlphaBar(true)
        mixer:SetWangs(true)
        return mixer
    end)

    addPreview("DPropertySheet", function()
        local sheet = scroll:Add("DPropertySheet")
        sheet:SetTall(120)
        local tab1 = vgui.Create("DPanel")
        tab1:Dock(FILL)
        local lbl1 = vgui.Create("DLabel", tab1)
        lbl1:Dock(TOP)
        lbl1:DockMargin(0, 0, 0, 4)
        lbl1:SetText(L("settings"))
        lbl1:SizeToContents()
        local btn1 = vgui.Create("DButton", tab1)
        btn1:Dock(TOP)
        btn1:SetText(L("apply"))
        local tab2 = vgui.Create("DPanel")
        tab2:Dock(FILL)
        local entry = vgui.Create("DTextEntry", tab2)
        entry:Dock(TOP)
        entry:SetPlaceholderText(L("enterValue"))
        local chkLabel = vgui.Create("DCheckBoxLabel", tab2)
        chkLabel:Dock(TOP)
        chkLabel:DockMargin(0, 4, 0, 0)
        chkLabel:SetText(L("enableFeature"))
        sheet:AddSheet(L("tabWithNumber", 1), tab1, "icon16/wrench.png")
        sheet:AddSheet(L("tabWithNumber", 2), tab2, "icon16/cog.png")
        return sheet
    end)

    addPreview("DCategoryList", function()
        local catList = scroll:Add("DCategoryList")
        catList:SetTall(100)
        local category = catList:Add(L("categoryWithNumber", 1))
        category:Add(L("itemWithNumber", 1))
        category:Add(L("itemWithNumber", 2))
        category:SetExpanded(true)
        return catList
    end)

    addPreview("DCollapsibleCategory", function()
        local collCat = scroll:Add("DCollapsibleCategory")
        collCat:SetLabel("DCollapsibleCategory")
        local content = vgui.Create("DPanel")
        content:SetTall(40)
        collCat:SetContents(content)
        collCat:SetExpanded(true)
        if collCat.GetHeaderHeight then
            collCat:SetTall(collCat:GetHeaderHeight() + content:GetTall())
        else
            collCat:SetTall(60)
        end
        return collCat
    end)

    addPreview("DModelPanel", function()
        local container = scroll:Add("DPanel")
        container:SetTall(300)
        container:SetPaintBackground(false)
        local modelPanel = vgui.Create("DModelPanel", container)
        modelPanel:SetModel("models/props_c17/oildrum001.mdl")
        modelPanel:SetSize(300, 300)
        modelPanel:SetPos(0, 0)
        return container
    end)
end)
