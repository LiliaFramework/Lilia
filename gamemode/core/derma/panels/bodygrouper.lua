local PANEL = {}
AccessorFunc(PANEL, "m_eTarget", "Target")
local leftrotate, rightrotate = input.LookupBinding("+moveleft"), input.LookupBinding("+moveright")
local leftinput, rightinput = input.GetKeyCode(leftrotate), input.GetKeyCode(rightrotate)
lia.worldPreview = lia.worldPreview or {}
if not lia.worldPreview.begin then
    function lia.worldPreview.shouldHidePlayer(player)
        local owner = lia.worldPreview.activeOwner
        local data = IsValid(owner) and owner._liaWorldPreview
        return data and istable(data.hiddenPlayers) and data.hiddenPlayers[player] or false
    end

    local function getPreviewAngle(client)
        local eyeAngles = IsValid(client) and client:EyeAngles() or angle_zero
        return Angle(0, eyeAngles.y + 180, 0)
    end

    local function getGroundPosition(pos, filter)
        if not isvector(pos) then return pos end
        local startPos = pos + Vector(0, 0, 64)
        local tr = util.TraceLine({
            start = startPos,
            endpos = pos + Vector(0, 0, -16384),
            mask = MASK_SOLID,
            filter = filter
        })

        if tr.Hit and tr.HitWorld and not tr.HitSky then return tr.HitPos + Vector(0, 0, 2) end
        return pos
    end

    local function getPreviewPosition(client)
        if not IsValid(client) then return Vector() end
        local forward = client:EyeAngles():Forward()
        forward.z = 0
        if forward:LengthSqr() <= 0 then
            forward = Vector(1, 0, 0)
        else
            forward:Normalize()
        end

        local eyePos = client:EyePos()
        local hull = util.TraceHull({
            start = eyePos,
            endpos = eyePos + forward * 96,
            mins = Vector(-16, -16, 0),
            maxs = Vector(16, 16, 72),
            filter = client,
            mask = MASK_SOLID
        })

        local basePos = hull.Hit and (hull.HitPos - forward * 28) or client:GetPos() + forward * 85
        return getGroundPosition(basePos, client)
    end

    local function applyIdleSequence(ent)
        if not IsValid(ent) then return end
        local seq = ent:LookupSequence("idle_all_01")
        if seq > 0 then
            ent:ResetSequence(seq)
            ent:SetCycle(0)
            return
        end

        seq = ent:SelectWeightedSequence(ACT_IDLE)
        if seq <= 0 then seq = ent:LookupSequence("idle_unarmed") end
        if seq > 0 then
            ent:ResetSequence(seq)
            ent:SetCycle(0)
            return
        end

        for _, name in ipairs(ent:GetSequenceList()) do
            local lowered = name:lower()
            if lowered ~= "idlenoise" and (lowered:find("idle") or lowered:find("fly")) then
                ent:ResetSequence(name)
                ent:SetCycle(0)
                return
            end
        end
    end

    function lia.worldPreview.close(owner)
        if not owner then return end
        local data = owner._liaWorldPreview
        if not data then return end
        hook.Remove("CalcView", data.calcViewHook)
        hook.Remove("PostDrawOpaqueRenderables", data.renderHook)
        hook.Remove("PrePlayerDraw", data.prePlayerDrawHook)
        hook.Remove("ShouldDrawLocalPlayer", data.shouldDrawLocalPlayerHook)
        if IsValid(data.entity) then data.entity:Remove() end
        if istable(data.hiddenEntities) then
            for ent, noDraw in pairs(data.hiddenEntities) do
                if IsValid(ent) then ent:SetNoDraw(noDraw) end
            end
        end

        if istable(data.hiddenPlayerState) then
            for player, state in pairs(data.hiddenPlayerState) do
                if IsValid(player) then
                    player:SetNoDraw(state.noDraw == true)
                    if state.hadEffect then
                        player:AddEffects(EF_NODRAW)
                    else
                        player:RemoveEffects(EF_NODRAW)
                    end
                end
            end
        end

        if lia.worldPreview.activeOwner == owner then lia.worldPreview.activeOwner = nil end
        owner._liaWorldPreview = nil
    end

    function lia.worldPreview.begin(owner, config)
        if not IsValid(owner) then return end
        if IsValid(lia.worldPreview.activeOwner) and lia.worldPreview.activeOwner ~= owner then lia.worldPreview.close(lia.worldPreview.activeOwner) end
        lia.worldPreview.close(owner)
        local data = {
            config = config or {},
            calcViewHook = "liaWorldPreviewCalcView" .. tostring(owner),
            renderHook = "liaWorldPreviewRender" .. tostring(owner),
            prePlayerDrawHook = "liaWorldPreviewPrePlayerDraw" .. tostring(owner),
            shouldDrawLocalPlayerHook = "liaWorldPreviewShouldDrawLocalPlayer" .. tostring(owner)
        }

        owner._liaWorldPreview = data
        lia.worldPreview.activeOwner = owner
        data.hiddenEntities = {}
        data.hiddenPlayers = {}
        data.hiddenPlayerState = {}
        local processedEntities = {}
        local hiddenTargets = istable(data.config.hideEntities) and data.config.hideEntities or {}
        for _, ent in ipairs(hiddenTargets) do
            if processedEntities[ent] then continue end
            processedEntities[ent] = true
            if not IsValid(ent) or ent == data.entity then continue end
            if ent:IsPlayer() then
                data.hiddenPlayers[ent] = true
                data.hiddenPlayerState[ent] = {
                    noDraw = ent:GetNoDraw(),
                    hadEffect = ent:IsEffectActive(EF_NODRAW)
                }

                ent:SetNoDraw(true)
                ent:AddEffects(EF_NODRAW)
            elseif data.hiddenEntities[ent] == nil then
                data.hiddenEntities[ent] = ent:GetNoDraw()
                ent:SetNoDraw(true)
            end
        end

        hook.Add("PrePlayerDraw", data.prePlayerDrawHook, function(player)
            local previewData = IsValid(owner) and owner._liaWorldPreview
            if not previewData then return end
            if istable(previewData.hiddenPlayers) and previewData.hiddenPlayers[player] then return true end
            if istable(previewData.hiddenEntities) and previewData.hiddenEntities[player] ~= nil then return true end
        end)

        hook.Add("ShouldDrawLocalPlayer", data.shouldDrawLocalPlayerHook, function(player)
            local previewData = IsValid(owner) and owner._liaWorldPreview
            if not previewData or not istable(previewData.hiddenPlayers) then return end
            local client = IsValid(player) and player or LocalPlayer()
            if previewData.hiddenPlayers[client] then return false end
        end)

        hook.Add("CalcView", data.calcViewHook, function(_, _, _, fov)
            if not IsValid(owner) then
                lia.worldPreview.close(owner)
                return
            end

            local previewData = owner._liaWorldPreview
            local ent = previewData and previewData.entity
            if not IsValid(ent) then return end
            local center = ent:GetPos() + Vector(0, 0, previewData.config.heightOffset or 60)
            local desired = center + ent:GetAngles():Forward() * (previewData.config.distance or 70)
            if not previewData.currentCamPos then
                previewData.currentCamPos = desired
            else
                previewData.currentCamPos = LerpVector(FrameTime() * 5, previewData.currentCamPos, desired)
            end

            local target = center - ent:GetAngles():Right() * (previewData.config.sideOffset or 40)
            return {
                origin = previewData.currentCamPos,
                angles = (target - previewData.currentCamPos):Angle(),
                fov = fov,
                drawviewer = true
            }
        end)

        hook.Add("PostDrawOpaqueRenderables", data.renderHook, function()
            if not IsValid(owner) then
                lia.worldPreview.close(owner)
                return
            end

            local previewData = owner._liaWorldPreview
            local ent = previewData and previewData.entity
            if not IsValid(ent) then return end
            ent:FrameAdvance()
            render.SuppressEngineLighting(true)
            render.ResetModelLighting(1, 1, 1)
            for i = 0, 6 do
                render.SetModelLighting(i, 1, 1, 1)
            end

            ent:DrawModel()
            render.SuppressEngineLighting(false)
            render.ResetModelLighting(1, 1, 1)
            for i = 0, 6 do
                render.SetModelLighting(i, 0, 0, 0)
            end
        end)
    end

    function lia.worldPreview.setModel(owner, modelPath, options)
        if not IsValid(owner) then return end
        local data = owner._liaWorldPreview
        if not data then
            lia.worldPreview.begin(owner, options)
            data = owner._liaWorldPreview
        elseif options then
            data.config = options
        end

        if IsValid(data.entity) then data.entity:Remove() end
        data.entity = ClientsideModel(modelPath or "models/error.mdl", RENDERGROUP_OPAQUE)
        if not IsValid(data.entity) then return end
        local client = LocalPlayer()
        local config = data.config or {}
        data.entity:SetPos(config.position or getPreviewPosition(client))
        data.entity:SetAngles(config.angle or getPreviewAngle(client))
        data.entity:SetSkin(config.skin or 0)
        if istable(config.bodygroups) then lia.util.applyBodygroups(data.entity, config.bodygroups) end
        hook.Run("SetupPlayerModel", data.entity)
        hook.Run("ModifyCharacterModel", data.entity, config.context)
        applyIdleSequence(data.entity)
        data.currentCamPos = nil
    end

    function lia.worldPreview.getEntity(owner)
        local data = IsValid(owner) and owner._liaWorldPreview
        return data and data.entity or nil
    end

    function lia.worldPreview.rotate(owner, deltaYaw)
        local ent = lia.worldPreview.getEntity(owner)
        if not IsValid(ent) then return end
        local ang = ent:GetAngles()
        ang.y = ang.y + deltaYaw
        ent:SetAngles(ang)
    end
end

function PANEL:GetPreviewEntity()
    return lia.worldPreview.getEntity(self)
end

function PANEL:GetCurrentBodygroups()
    local model = self:GetPreviewEntity()
    if not IsValid(model) then return {} end
    local groups = {}
    for i = 0, model:GetNumBodyGroups() - 1 do
        groups[i] = model:GetBodygroup(i)
    end
    return groups
end

function PANEL:BuildBodygroupExport()
    local lines = {"{"}
    local groups = self:GetCurrentBodygroups()
    local ids = {}
    for id in pairs(groups) do
        ids[#ids + 1] = id
    end

    table.sort(ids, function(a, b) return tonumber(a) < tonumber(b) end)
    for _, id in ipairs(ids) do
        lines[#lines + 1] = "    [" .. tostring(id) .. "] = " .. tostring(groups[id]) .. ","
    end

    lines[#lines + 1] = "}"
    return table.concat(lines, "\n")
end

function PANEL:Init()
    self:SetSize(math.min(440, ScrW() * 0.28), math.min(ScrH() * 0.75, 760))
    self:SetPos(ScrW() - self:GetWide() - 48, math.max(48, (ScrH() - self:GetTall()) * 0.5))
    self:MakePopup()
    self:SetBackgroundBlur(false)
    self:SetTitle(L("bodygroupMenuTitle"))
    self:DockPadding(8, 32, 8, 8)
    self.previewInfo = self:Add("DPanel")
    self.previewInfo:Dock(TOP)
    self.previewInfo:DockMargin(0, 0, 0, 8)
    self.previewInfo:SetTall(56)
    self.previewInfo.Paint = function(panel, panelWidth, h)
        local str = L("rotateInstruction", leftrotate:upper(), rightrotate:upper())
        lia.util.drawText(L("bodygroupMenuTitle"), panelWidth / 2, 18, Color(255, 255, 255), 1, 1, "LiliaFont.18")
        lia.util.drawText(str, panelWidth / 2, 38, Color(220, 220, 220), 1, 1, "LiliaFont.16")
    end

    self.side = self:Add("Panel")
    self.side:Dock(FILL)
    self.side:DockPadding(5, 5, 5, 5)
    self.skinSelector = self.side:Add("liaSlideBox")
    self.skinSelector:Dock(TOP)
    self.skinSelector:DockMargin(0, 0, 0, 5)
    self.skinSelector:SetText(L("skin"))
    self.skinSelector:SetRange(0, 0, 0)
    self.skinSelector:SetVisible(false)
    self.skinSelector.OnValueChanged = function(_, value)
        local model = self:GetPreviewEntity()
        if IsValid(model) then model:SetSkin(math.Round(value)) end
    end

    self.actions = self.side:Add("Panel")
    self.actions:Dock(BOTTOM)
    self.actions:DockMargin(0, 5, 0, 0)
    self.actions:SetTall(24)
    self.copyBodygroups = self.actions:Add("liaButton")
    self.copyBodygroups:Dock(LEFT)
    self.copyBodygroups:SetWide(160)
    self.copyBodygroups:SetText(L("copyBodygroups"))
    self.copyBodygroups.DoClick = function()
        local export = self:BuildBodygroupExport()
        SetClipboardText(export)
        MsgC(Color(0, 255, 0), "[Lilia] ", color_white, export .. "\n")
        LocalPlayer():notifySuccessLocalized("copied")
    end

    self.submit = self.actions:Add("liaButton")
    self.submit:Dock(FILL)
    self.submit:DockMargin(5, 0, 0, 0)
    self.submit:SetText(L("submit"))
    self.submit.DoClick = function()
        local model = self:GetPreviewEntity()
        if IsValid(model) then
            local skn = model:GetSkin()
            local groups = self:GetCurrentBodygroups()
            local makeChange = true
            if self.originalSkin == skn then makeChange = false end
            if not makeChange then
                for i = 0, model:GetNumBodyGroups() - 1 do
                    if self.originalBodygroups[i] ~= groups[i] then
                        makeChange = true
                        break
                    end
                end
            end

            if makeChange then
                net.Start("BodygrouperMenu")
                net.WriteEntity(self:GetTarget())
                net.WriteUInt(skn, 10)
                net.WriteTable(groups)
                net.SendToServer()
            end
        end
    end

    self.scroll = self.side:Add("liaScrollPanel")
    self.scroll:Dock(FILL)
end

function PANEL:OnClose()
    net.Start("BodygrouperMenuClose")
    net.SendToServer()
    lia.worldPreview.close(self)
end

function PANEL:PopulateOptions()
    local target = self:GetTarget()
    if not IsValid(target) then return end
    self.scroll:Clear()
    if target:SkinCount() > 1 then
        self.skinSelector:SetRange(0, target:SkinCount() - 1, 0)
        self.skinSelector:SetValue(target:GetSkin())
        self.skinSelector:SetVisible(true)
    else
        self.skinSelector:SetVisible(false)
    end

    if target:GetNumBodyGroups() > 1 then
        for i = 0, target:GetNumBodyGroups() - 1 do
            if target:GetBodygroupCount(i) <= 1 then continue end
            local group = target:GetBodygroup(i)
            local panel = vgui.Create("liaSlideBox", self.scroll)
            panel:Dock(TOP)
            panel:DockMargin(0, 0, 0, 5)
            panel:SetText(target:GetBodygroupName(i):sub(1, 1):upper() .. target:GetBodygroupName(i):sub(2))
            panel:SetRange(0, target:GetBodygroupCount(i) - 1, 0)
            panel:SetValue(group)
            panel.OnValueChanged = function(_, value)
                local model = self:GetPreviewEntity()
                if IsValid(model) then model:SetBodygroup(i, math.Round(value)) end
            end
        end
    elseif not self.skinSelector:IsVisible() then
        local info = self.scroll:Add("DLabel")
        info:Dock(TOP)
        info:DockMargin(0, 10, 0, 0)
        info:SetText(L("noBodygroupsnSkins"))
        info:SetFont("liaMediumFont")
        info:SetTextColor(color_white)
        info:SetContentAlignment(5)
        info:SetWrap(true)
        info:SetAutoStretchVertical(true)
        info:SetTall(40)
    end
end

function PANEL:SetTarget(target)
    self.m_eTarget = target
    lia.worldPreview.begin(self, {
        context = target,
        hideEntities = {target, LocalPlayer()}
    })

    lia.worldPreview.setModel(self, target:GetModel(), {
        skin = target:GetSkin(),
        bodygroups = lia.util.resolveBodygroups(target, {}),
        context = target
    })

    local entity = self:GetPreviewEntity()
    if IsValid(entity) then
        self.originalSkin = target:GetSkin()
        entity:SetSkin(target:GetSkin())
        self.originalBodygroups = {}
        for i = 0, entity:GetNumBodyGroups() - 1 do
            self.originalBodygroups[i] = target:GetBodygroup(i)
            entity:SetBodygroup(i, target:GetBodygroup(i))
        end
    end

    self:PopulateOptions()
end

function PANEL:Think()
    if input.IsKeyDown(leftinput) then
        lia.worldPreview.rotate(self, FrameTime() * 180)
    elseif input.IsKeyDown(rightinput) then
        lia.worldPreview.rotate(self, FrameTime() * -180)
    end
end

function PANEL:OnRemove()
    lia.worldPreview.close(self)
end

vgui.Register("BodygrouperMenu", PANEL, "liaFrame")
