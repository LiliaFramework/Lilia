do
local PANEL = {}
local function mmColor(src, fallback, alpha)
    local c = IsColor(src) and src or fallback
    return Color(c.r, c.g, c.b, alpha or c.a or 255)
end

local function mmTheme()
    return lia.color and lia.color.theme or {}
end

local function mmAccent(alpha)
    local theme = mmTheme()
    local src = theme.maincolor or theme.accent or theme.theme or lia.config.get("Color") or Color(76, 164, 224)
    return mmColor(src, Color(76, 164, 224), alpha)
end

local function mmText(alpha)
    local theme = mmTheme()
    local src = theme.text or theme.foreground or Color(230, 239, 239)
    return mmColor(src, Color(230, 239, 239), alpha)
end

local function mmBg(alpha)
    local theme = mmTheme()
    local src = theme.background or theme.panel or theme.window or Color(7, 14, 23)
    return mmColor(src, Color(7, 14, 23), alpha)
end

local function mmMix(from, to, frac, alpha)
    from = IsColor(from) and from or Color(7, 14, 23)
    to = IsColor(to) and to or Color(230, 239, 239)
    frac = math.Clamp(tonumber(frac) or 0, 0, 1)
    return Color(math.Round(Lerp(frac, from.r, to.r)), math.Round(Lerp(frac, from.g, to.g)), math.Round(Lerp(frac, from.b, to.b)), alpha or math.Round(Lerp(frac, from.a or 255, to.a or 255)))
end

local function mmSurface(frac, alpha)
    return mmMix(mmBg(255), mmText(255), frac or 0.04, alpha)
end

local function mmMuted(alpha)
    return mmMix(mmText(255), mmBg(255), 0.40, alpha or 190)
end

local function mmDrawPanel(x, y, w, h, radius, bg, outline)
    if lia.derma.SHAPE_IOS then
        lia.derma.rect(x, y, w, h):Rad(radius or 6):Color(bg):Shape(lia.derma.SHAPE_IOS):Draw()
        if outline then lia.derma.rect(x, y, w, h):Rad(radius or 6):Color(outline):Shape(lia.derma.SHAPE_IOS):Outline(1):Draw() end
    else
        draw.RoundedBox(radius or 6, x, y, w, h, bg)
        if outline then
            surface.SetDrawColor(outline)
            surface.DrawOutlinedRect(x, y, w, h, 1)
        end
    end
end

local function mmPaintContainer(w, h)
    local accent = mmAccent()
    mmDrawPanel(0, 0, w, h, 5, mmSurface(0.02, 236), Color(accent.r, accent.g, accent.b, 70))
end

local function mmPaintBlock(w, h, active)
    local accent = mmAccent()
    local frac = active and 0.065 or 0.05
    local bg = mmSurface(frac, active and 242 or 238)
    local out = Color(accent.r, accent.g, accent.b, active and 145 or 52)
    mmDrawPanel(0, 0, w, h, 7, bg, out)
end

local function mmStyleScrollBar(scroll)
    if not IsValid(scroll) or not IsValid(scroll.VBar) then return end
    local bar = scroll.VBar
    bar:SetWide(8)
    bar.Paint = function() end
    if IsValid(bar.btnUp) then bar.btnUp.Paint = function() end end
    if IsValid(bar.btnDown) then bar.btnDown.Paint = function() end end
    if IsValid(bar.btnGrip) then bar.btnGrip.Paint = function(self, w, h) draw.RoundedBox(4, 1, 0, math.max(w - 2, 1), h, self:IsHovered() and mmAccent(150) or mmMuted(90)) end end
end

local function mmEase(t)
    t = math.Clamp(t, 0, 1)
    return t * t * t * (t * (t * 6 - 15) + 10)
end

local function mmTweenPanel(panel, targetX, targetY, targetAlpha, duration, delay, onComplete)
    if not IsValid(panel) then return end
    local fromX, fromY = panel:GetPos()
    local fromAlpha = panel:GetAlpha()
    local startTime = RealTime() + (delay or 0)
    duration = math.max(duration or 0.28, 0.01)
    panel.Think = function(self)
        local t = (RealTime() - startTime) / duration
        if t < 0 then return end
        local fraction = mmEase(t)
        self:SetPos(math.Round(Lerp(fraction, fromX, targetX)), math.Round(Lerp(fraction, fromY, targetY)))
        self:SetAlpha(math.Round(Lerp(fraction, fromAlpha, targetAlpha)))
        if t >= 1 then
            self.Think = nil
            if isfunction(onComplete) then onComplete() end
        end
    end
end

local function mmAnimateIn(panel, x, y, dx, dy, duration, delay)
    if not IsValid(panel) then return end
    panel:SetPos(x + (dx or 0), y + (dy or 0))
    panel:SetAlpha(0)
    mmTweenPanel(panel, x, y, 255, duration or 0.32, delay or 0)
end

function PANEL:Init()
    local client = LocalPlayer()
    local clientChar = client.getChar and client:getChar()
    self.disableClientModel = false
    self.noBlur = true
    self.isLoadMode = false
    if IsValid(lia.gui.loading) then lia.gui.loading:Remove() end
    if IsValid(lia.gui.character) then lia.gui.character:Remove() end
    lia.gui.character = self
    hook.Run("CharMenuOpened", self)
    if not render.oldDrawBeam then
        render.oldDrawBeam = render.DrawBeam
        render.DrawBeam = function(startPos, endPos, width, textureStart, textureEnd, color)
            if IsValid(lia.gui.character) then return end
            return render.oldDrawBeam(startPos, endPos, width, textureStart, textureEnd, color)
        end
    end

    hook.Add("DrawPhysgunBeam", "liaMainMenuPreDrawPhysgunBeam", function() return IsValid(lia.gui.character) end)
    hook.Remove("RenderScreenspaceEffects", "liaCharMenuDarken")
    self:Dock(FILL)
    self:MakePopup()
    self:SetAlpha(255)
    self:Stop()
    self.charListUpdateHook = "liaCharacterCharListUpdate" .. tostring(self)
    hook.Add("CharListUpdated", self.charListUpdateHook, function(oldCharList, newCharList)
        if not IsValid(self) then return end
        self:onCharListUpdated(oldCharList, newCharList)
    end)

    self.adminPrivilegesUpdateHook = "liaCharacterAdminPrivilegesUpdate" .. tostring(self)
    hook.Add("AdminPrivilegesUpdated", self.adminPrivilegesUpdateHook, function()
        if not IsValid(self) or not self.inMainMenu or self.panelsTransitioning then return end
        self:createStartButton()
    end)

    self.tabs = self:Add("DPanel")
    self.tabs:Dock(TOP)
    self.tabs:DockMargin(64, 32, 64, 0)
    self.tabs:SetTall(48)
    self.tabs:SetPaintBackground(false)
    self.content = self:Add("DPanel")
    self.content:Dock(FILL)
    self.content:DockMargin(64, 0, 64, 64)
    self.content:SetPaintBackground(false)
    self:StartBGMusic()
    self:createTitle()
    self:loadBackground()
    if clientChar and lia.characters and #lia.characters > 0 then
        for i, charID in ipairs(lia.characters) do
            local charObj = isnumber(charID) and lia.char.getCharacter(charID) or charID
            if charObj and charObj.getID and charObj:getID() == clientChar:getID() then
                self.currentIndex = i
                break
            end
        end

        self.currentIndex = self.currentIndex or 1
    end

    self:createStartButton()
end

function PANEL:setInWorldPreviewEnabled(enabled)
    enabled = enabled == true
    if enabled == self.inWorldPreview then return end
    self.inWorldPreview = enabled
    if enabled then
        self:hideExternalEntities()
        hook.Add("PrePlayerDraw", "liaMainMenuPrePlayerDraw", function() return true end)
        local calcViewHook = "liaMainMenuCalcView"
        hook.Add("CalcView", calcViewHook, function(_, _, _, fov)
            if not IsValid(self) or not self.inWorldPreview then return end
            local ent = self.modelEntity
            if not IsValid(ent) then return end
            local center = ent:GetPos() + Vector(0, 0, 60)
            local modelAngles = self.mainMenuModelAngles or ent:GetAngles()
            local forward = modelAngles:Forward()
            local desired = center + forward * 70
            if not self.currentCamPos then
                self.currentCamPos = desired
            else
                self.currentCamPos = LerpVector(FrameTime() * 5, self.currentCamPos, desired)
            end

            local target = center
            if self.inWorldPreview and not self.isLoadMode then target = target - modelAngles:Right() * 40 end
            return {
                origin = self.currentCamPos,
                angles = (target - self.currentCamPos):Angle(),
                fov = fov,
                drawviewer = true
            }
        end)
    else
        self:restoreExternalEntities()
        self.currentCamPos = nil
        hook.Remove("CalcView", "liaMainMenuCalcView")
        hook.Remove("PrePlayerDraw", "liaMainMenuPrePlayerDraw")
        hook.Remove("PostDrawOpaqueRenderables", "liaMainMenuPostDrawOpaqueRenderables")
        if self.mainMenuRenderHookID then
            hook.Remove("PostDrawOpaqueRenderables", self.mainMenuRenderHookID)
            self.mainMenuRenderHookID = nil
        end

        if IsValid(self.modelEntity) then self.modelEntity:Remove() end
    end
end

function PANEL:updateCreationModelEntity(context)
    if not istable(context) then return end
    local factionIndex = context.faction
    local faction = factionIndex and lia.faction.indices[factionIndex] or nil
    if not faction then return end
    local class = lia.faction.getCharacterCreationClass(faction, context.class)
    local info = lia.faction.getCharacterCreationModelInfo(faction, class, context.model)
    if not info then return end
    local parsed = lia.faction.getModelData(context.model, info)
    local mdl, skin, groups = info, 0, {}
    if parsed then mdl, skin, groups = parsed.model, parsed.skin, parsed.bodygroups end
    if IsValid(self.modelEntity) then self.modelEntity:Remove() end
    self.modelEntity = ClientsideModel(mdl or "models/error.mdl", RENDERGROUP_OPAQUE)
    if not IsValid(self.modelEntity) then return end
    self.modelEntity:SetSkin(lia.faction.normalizeSkinValue(context.skin, skin))
    local finalGroups = istable(context.groups) and context.groups or istable(groups) and groups
    if finalGroups then lia.util.applyBodygroups(self.modelEntity, finalGroups) end
    hook.Run("SetupPlayerModel", self.modelEntity)
    local pos, ang
    if faction.mainMenuPosition then
        local menuPos = faction.mainMenuPosition
        local currentMap = game.GetMap()
        if istable(menuPos) and menuPos[currentMap] then
            local mapPos = menuPos[currentMap]
            if istable(mapPos) then
                pos, ang = mapPos.position, mapPos.angles
            elseif isvector(mapPos) then
                pos, ang = mapPos, Angle(0, 0, 0)
            end
        elseif istable(menuPos) then
            pos, ang = menuPos.position, menuPos.angles
        elseif isvector(menuPos) then
            pos, ang = menuPos, Angle(0, 0, 0)
        end
    end

    if not pos then
        local client = LocalPlayer()
        local hookResult = hook.Run("GetMainMenuPosition", IsValid(client) and client.getChar and client:getChar() or nil)
        if hookResult then
            if istable(hookResult) then
                pos, ang = hookResult.pos, hookResult.ang
            elseif isvector(hookResult) then
                pos = hookResult
                ang = Angle(0, 0, 0)
            end
        end
    end

    if not pos or not ang then
        local spawns = ents.FindByClass("info_player_start")
        if #spawns > 0 then
            pos = spawns[1]:GetPos()
            ang = spawns[1]:GetAngles()
        else
            pos = Vector()
            ang = Angle()
        end
    end

    self.mainMenuModelAngles = ang
    pos = self:getClosestGroundPosition(pos)
    self.modelEntity:SetPos(pos)
    self.modelEntity:SetAngles(ang)
    self.currentCamPos = nil
    local seqID = self.modelEntity:LookupSequence("idle_all_01")
    if seqID > 0 then
        self.modelEntity:ResetSequence(seqID)
        self.modelEntity:SetCycle(0)
    end

    hook.Run("ModifyCharacterModel", self.modelEntity, context)
    hook.Remove("PostDrawOpaqueRenderables", "liaMainMenuPostDrawOpaqueRenderables")
    if self.mainMenuRenderHookID then
        hook.Remove("PostDrawOpaqueRenderables", self.mainMenuRenderHookID)
        self.mainMenuRenderHookID = nil
    end

    self.mainMenuRenderHookID = "liaMainMenuPostDrawOpaqueRenderables" .. tostring(self)
    hook.Add("PostDrawOpaqueRenderables", self.mainMenuRenderHookID, function()
        if not IsValid(self) or not self.inWorldPreview or not IsValid(self.modelEntity) then return end
        self.modelEntity:FrameAdvance()
        render.SuppressEngineLighting(true)
        local ok, err = pcall(function()
            render.ResetModelLighting(1, 1, 1)
            for i = 0, 6 do
                render.SetModelLighting(i, 1, 1, 1)
            end

            self.modelEntity:DrawModel()
        end)

        render.SuppressEngineLighting(false)
        render.ResetModelLighting(1, 1, 1)
        for i = 0, 6 do
            render.SetModelLighting(i, 0, 0, 0)
        end

        if not ok then ErrorNoHalt(err .. "\n") end
    end)
end

function PANEL:createWelcomeSidePanel()
    local client = LocalPlayer()
    if not IsValid(client) then return end
    if IsValid(self.welcomeSide) then self.welcomeSide:Remove() end
    local function changelogText()
        local data = SCHEMA and (SCHEMA.changelog or SCHEMA.Changelog)
        if isstring(data) then
            for line in data:gmatch("[^\r\n]+") do
                local entry = string.Trim(line)
                if entry ~= "" then return "LATEST CHANGELOG", entry end
            end
        elseif istable(data) then
            local entries = data.entries or data.releases or data.versions or data.items or data.list or data
            if istable(entries) then
                local key, entry
                if #entries > 0 then
                    entry = entries[1]
                else
                    for k, v in pairs(entries) do
                        if not key or tostring(k) > tostring(key) then key, entry = k, v end
                    end
                end

                if isstring(entry) then return key and "CHANGELOG / " .. tostring(key) or "LATEST CHANGELOG", entry end
                if istable(entry) then
                    local heading = entry.version or entry.title or key
                    local values = entry.changes or entry.notes or entry.text or entry.message or entry.description or entry.entries or entry.items
                    if istable(values) then
                        values = values[1]
                        if istable(values) then values = values.text or values.message or values.description or values.change end
                    end

                    if isstring(values) and string.Trim(values) ~= "" then return heading and "CHANGELOG / " .. tostring(heading) or "LATEST CHANGELOG", values end
                end
            end
        end
        return nil
    end

    local changeTitle, changeText = changelogText()
    local rightW = math.Clamp(ScrW() * 0.23, 360, 520)
    local rightH = math.min(changeText and 390 or 250, ScrH() - 48)
    local rightX = ScrW() - rightW - math.max(32, ScrW() * 0.04)
    local mainMenuHeight = math.Clamp(ScrH() * 0.58, 440, 640)
    local rightY = ScrH() * 0.5 - mainMenuHeight * 0.5
    local pad = 18
    local innerW = rightW - pad * 2
    self.welcomeSide = self:Add("DPanel")
    local panel = self.welcomeSide
    panel:SetSize(rightW, rightH)
    panel.Paint = function(_, w, h) mmPaintContainer(w, h) end
    mmAnimateIn(panel, rightX, rightY, 18, 0, 0.36, 0.06)
    local function addLabel(text, font, color, x, y, width, height)
        local label = panel:Add("DLabel")
        label:SetPos(x, y)
        label:SetSize(width, height)
        label:SetFont(font)
        label:SetTextColor(color)
        label:SetText(text)
        return label
    end

    local function fitText(value, font, width)
        local str = tostring(value or "")
        surface.SetFont(font)
        if surface.GetTextSize(str) <= width then return str end
        while #str > 0 and surface.GetTextSize(str .. "...") > width do
            str = string.sub(str, 1, -2)
        end
        return str .. "..."
    end

    local function formatPlaytime(value)
        local seconds = math.max(tonumber(value) or 0, 0)
        local days = math.floor(seconds / 86400)
        local hours = math.floor(seconds % 86400 / 3600)
        local minutes = math.floor(seconds % 3600 / 60)
        if days > 0 then return string.format("%dd %dh %dm", days, hours, minutes) end
        if hours > 0 then return string.format("%dh %dm", hours, minutes) end
        return string.format("%dm", minutes)
    end

    local function characterCount()
        return lia.characters and #lia.characters or 0
    end

    local function characterLimit()
        local count = tonumber(hook.Run("GetMaxPlayerChar", client)) or tonumber(lia.config.get("MaxCharacters", 5)) or 5
        return math.max(0, math.floor(count))
    end

    local function drawDivider(y)
        local line = panel:Add("DPanel")
        line:SetPos(pad, y)
        line:SetSize(innerW, 1)
        line.Paint = function(_, w, h)
            local accent = mmAccent(70)
            surface.SetDrawColor(accent)
            surface.DrawRect(0, 0, w, h)
        end
    end

    addLabel(characterCount() == 0 and "WELCOME" or "WELCOME BACK", "LiliaFont.30", mmText(), pad, 19, innerW, 38)
    local greeting = addLabel("", "LiliaFont.17", mmMuted(), pad, 58, innerW, 24)
    drawDivider(80)
    local cardW = math.floor((innerW - 10) * 0.5)
    local function addInfoCard(x, y, heading)
        local card = panel:Add("DPanel")
        card:SetPos(x, y)
        card:SetSize(cardW, 64)
        card.Paint = function(_, w, h) mmPaintBlock(w, h, false) end
        addLabel(heading, "LiliaFont.14", mmMuted(), x + 12, y + 8, cardW - 24, 19)
        return addLabel("", "LiliaFont.22", mmText(), x + 12, y + 29, cardW - 24, 27)
    end

    local playtime = addInfoCard(pad, 94, "TOTAL PLAYTIME")
    local characters = addInfoCard(pad + cardW + 10, 94, "CHARACTERS")
    local playerCount = addInfoCard(pad, 168, "PLAYER COUNT")
    local currentMap = addInfoCard(pad + cardW + 10, 168, "MAP")
    if changeText and rightH >= 382 then
        local changeY = 254
        addLabel(fitText(changeTitle, "LiliaFont.14", innerW), "LiliaFont.14", mmAccent(), pad, changeY, innerW, 21)
        local changeCard = panel:Add("DPanel")
        changeCard:SetPos(pad, changeY + 26)
        changeCard:SetSize(innerW, math.min(92, math.max(40, rightH - changeY - 48)))
        changeCard.Paint = function(_, w, h) mmPaintBlock(w, h, false) end
        local changeLabel = changeCard:Add("DLabel")
        changeLabel:SetPos(12, 9)
        changeLabel:SetSize(innerW - 24, changeCard:GetTall() - 17)
        changeLabel:SetFont("LiliaFont.16")
        changeLabel:SetTextColor(mmText())
        changeLabel:SetWrap(true)
        changeLabel:SetText(string.Trim(changeText))
    end

    local previousName, previousCount, previousLimit, previousMinutes, previousPopulation, previousCapacity, previousMap
    greeting.Think = function()
        if not IsValid(client) then return end
        local name = client.steamName and client:steamName() or client:SteamName() or client:Nick() or "Player"
        local count, limit = characterCount(), characterLimit()
        if name ~= previousName or count ~= previousCount or limit ~= previousLimit then
            previousName, previousCount, previousLimit = name, count, limit
            greeting:SetText(fitText((count == 0 and "Welcome, " or "Good to see you again, ") .. name .. ".", "LiliaFont.17", innerW))
            characters:SetText(string.format("%d / %d", count, limit))
        end

        local minutes = math.floor((tonumber(client.getPlayTime and client:getPlayTime() or 0) or 0) / 60)
        if minutes ~= previousMinutes then
            previousMinutes = minutes
            playtime:SetText(formatPlaytime(client.getPlayTime and client:getPlayTime() or 0))
        end

        local population = #player.GetAll()
        local capacity = game.MaxPlayers()
        if population ~= previousPopulation or capacity ~= previousCapacity then
            previousPopulation, previousCapacity = population, capacity
            playerCount:SetText(string.format("%d / %d", population, capacity))
        end

        local mapName = game.GetMap() or "Unknown"
        if mapName ~= previousMap then
            previousMap = mapName
            currentMap:SetText(fitText(mapName, "LiliaFont.22", cardW - 24))
        end
    end
end

function PANEL:getPreviewPlacement(character)
    local pos, ang
    local result = {hook.Run("GetMainMenuPosition", character)}
    if isvector(result[1]) then
        pos = result[1]
        if isangle(result[2]) then ang = result[2] end
    elseif istable(result[1]) then
        pos = result[1].pos or result[1].position
        ang = result[1].ang or result[1].angles
    end

    if not isvector(pos) then
        local spawns = ents.FindByClass("info_player_start")
        if #spawns > 0 then
            pos = spawns[1]:GetPos()
            ang = spawns[1]:GetAngles()
        else
            pos = Vector()
            ang = Angle()
        end
    end

    if not isangle(ang) then ang = Angle() end
    return self:getClosestGroundPosition(pos), ang
end

function PANEL:getLoadEntryView(fov)
    local state = self.loadEntryCamera
    if not state then return end
    local progress = math.Clamp((RealTime() - state.startTime) / state.duration, 0, 1)
    local fraction = mmEase(progress)
    local origin = LerpVector(fraction, state.fromPos, state.toPos)
    local angles = LerpAngle(fraction, state.fromAngles, state.toAngles)
    self.currentCamPos = origin
    if progress >= 1 then
        self.loadEntryCamera = nil
        self.currentCamPos = state.toPos
    end
    return {
        origin = origin,
        angles = angles,
        fov = fov,
        drawviewer = true
    }
end

function PANEL:beginLoadCameraTransition()
    self.loadEntryCamera = nil
    local characterIDs = {}
    for _, characterID in pairs(lia.characters or {}) do
        local character = lia.char.getCharacter(characterID)
        if character and character:getFaction() ~= FACTION_STAFF then characterIDs[#characterIDs + 1] = characterID end
    end

    if #characterIDs == 0 then return end
    local index = math.Clamp(self.currentIndex or 1, 1, #characterIDs)
    local character = lia.char.getCharacter(characterIDs[index])
    if not character then return end
    local pos, ang = self:getPreviewPlacement(character)
    local center = pos + Vector(0, 0, 60)
    local target = center + ang:Forward() * 70
    local fromPos = EyePos()
    local fromAngles = EyeAngles()
    if not isvector(fromPos) or not isangle(fromAngles) then return end
    self.loadEntryCamera = {
        fromPos = fromPos,
        fromAngles = fromAngles,
        toPos = target,
        toAngles = (center - target):Angle(),
        startTime = RealTime(),
        duration = 1.05
    }

    hook.Add("CalcView", "liaMainMenuCalcView", function(_, _, _, fov)
        if not IsValid(self) then return end
        return self:getLoadEntryView(fov)
    end)
end

function PANEL:transitionPanelsOut(panels, callback)
    if self.panelsTransitioning then return end
    self.panelsTransitioning = true
    local transitioning = {}
    for _, info in ipairs(panels or {}) do
        if IsValid(info.panel) then transitioning[#transitioning + 1] = info end
    end

    if #transitioning == 0 then
        self.panelsTransitioning = false
        if isfunction(callback) then callback() end
        return
    end

    local remaining = #transitioning
    for _, info in ipairs(transitioning) do
        local panel = info.panel
        local x, y = panel:GetPos()
        panel:SetMouseInputEnabled(false)
        mmTweenPanel(panel, x + (info.dx or 0), y + (info.dy or 0), 0, 0.44, 0, function()
            if IsValid(panel) then panel:Remove() end
            remaining = remaining - 1
            if remaining <= 0 and IsValid(self) then
                self.panelsTransitioning = false
                if isfunction(callback) then callback() end
            end
        end)
    end
end

function PANEL:openCharacterSelectionWithTransition()
    if self.panelsTransitioning then return end
    self:clickSound()
    self:beginLoadCameraTransition()
    self:transitionPanelsOut({
        {
            panel = self.menuPanel,
            dx = -22
        },
        {
            panel = self.welcomeSide,
            dx = 22
        }
    }, function() if IsValid(self) then self:createCharacterSelection() end end)
end

function PANEL:animateCreationInterface(creator)
    if IsValid(creator) and IsValid(creator.inputWindow) then
        creator:InvalidateLayout(true)
        if isvector(creator.cameraToOrigin) and isvector(creator.cameraToLook) then
            local origin = EyePos()
            local angles = EyeAngles()
            if isvector(origin) and isangle(angles) then
                creator.cameraFromOrigin = origin
                creator.cameraFromLook = origin + angles:Forward() * 150
                creator.cameraCurrentOrigin = creator.cameraFromOrigin
                creator.cameraCurrentLook = creator.cameraFromLook
                creator.cameraFromFOV = creator.cameraToFOV
                creator.cameraCurrentFOV = creator.cameraToFOV
                creator.cameraStartTime = CurTime()
                creator.cameraDuration = 0.95
            end
        end

        local window = creator.inputWindow
        window:SetAlpha(0)
        window:AlphaTo(255, 0.58, 0.01)
        if IsValid(creator.paper) then
            local paper = creator.paper
            local x, y = paper:GetPos()
            paper:SetPos(x + 42, y)
            paper:SetAlpha(0)
            mmTweenPanel(paper, x, y, 255, 0.62, 0.04)
        end
        return
    end

    if not IsValid(self.content) then return end
    local content = self.content
    local x, y = content:GetPos()
    content:SetAlpha(0)
    mmTweenPanel(content, x, y, 255, 0.58, 0.03)
end

function PANEL:openCharacterCreationWithTransition()
    if self.panelsTransitioning then return end
    self:clickSound()
    self.loadEntryCamera = nil
    self:transitionPanelsOut({
        {
            panel = self.menuPanel,
            dx = -22
        },
        {
            panel = self.selectionPanel,
            dx = 22
        },
        {
            panel = self.welcomeSide,
            dx = 22
        },
        {
            panel = self.leftArrow,
            dx = -12
        },
        {
            panel = self.rightArrow,
            dx = 12
        }
    }, function()
        if not IsValid(self) then return end
        self.isLoadMode = false
        self:showContent(true)
        self.tabs:SetVisible(true)
        self.content:SetVisible(true)
        local creator = self:createCharacterCreation()
        if IsValid(creator) then self:animateCreationInterface(creator) end
    end)
end

function PANEL:createTitle()
    if self.tabs then self.tabs:DockMargin(64, 32, 64, 0) end
end

function PANEL:createChangelogDisplay()
    if not SCHEMA or not (SCHEMA.changelog or SCHEMA.Changelog) then return end
    self.changelogPanel = self:Add("DPanel")
    self.changelogPanel:SetPos(32, 32)
    self.changelogPanel:SetSize(ScrW() * 0.25, ScrH() * 0.4)
    self.changelogPanel:SetAlpha(0)
    self.changelogPanel:AlphaTo(255, 0.4, 0)
    local accentColor = lia.color.theme.theme
    self.changelogPanel.Paint = function(s, w, h)
        local bgColor = Color(25, 28, 35, 250)
        lia.derma.rect(0, 0, w, h):Rad(12):Color(Color(0, 0, 0, 180)):Shadow(15, 20):Shape(lia.derma.SHAPE_IOS):Draw()
        lia.derma.rect(0, 0, w, h):Rad(12):Color(bgColor):Shape(lia.derma.SHAPE_IOS):Draw()
        lia.derma.rect(0, 0, w, 5):Radii(12, 12, 0, 0):Color(accentColor):Draw()
    end

    local padding = 20
    local contentY = padding + 10
    local titleLabel = self.changelogPanel:Add("DLabel")
    titleLabel:SetFont("LiliaFont.30")
    titleLabel:SetTextColor(Color(255, 255, 255))
    titleLabel:SetText("Changelog")
    titleLabel:SetContentAlignment(5)
    titleLabel:SetWide(self.changelogPanel:GetWide() - padding * 2)
    titleLabel:SetPos(padding, contentY)
    titleLabel:SetTall(40)
    titleLabel:SetExpensiveShadow(1, Color(0, 0, 0, 150))
    contentY = contentY + 50
    local scroll = self.changelogPanel:Add("liaScrollPanel")
    scroll:SetPos(padding, contentY)
    scroll:SetSize(self.changelogPanel:GetWide() - padding * 2, self.changelogPanel:GetTall() - contentY - padding)
    scroll:InvalidateLayout(true)
    local function addSpacer(height)
        local spacer = scroll:Add("DPanel")
        spacer:SetTall(height or 15)
        spacer:Dock(TOP)
        spacer.Paint = function() end
    end

    local function addTextLabel(text, font, color, indent, marginBottom)
        local label = scroll:Add("DLabel")
        label:SetFont(font)
        label:SetTextColor(color)
        label:SetText(tostring(text or ""))
        label:SetWrap(true)
        label:SetAutoStretchVertical(true)
        label:SetWide(scroll:GetWide() - padding * 2)
        label:Dock(TOP)
        label:DockMargin(indent or 0, 0, 0, marginBottom or 8)
        return label
    end

    local function addVersionLabel(text)
        local versionLabel = scroll:Add("DLabel")
        versionLabel:SetFont("LiliaFont.22")
        versionLabel:SetTextColor(accentColor)
        versionLabel:SetText(tostring(text or ""))
        versionLabel:SetContentAlignment(5)
        versionLabel:SetWide(scroll:GetWide() - padding * 2)
        versionLabel:SetTall(30)
        versionLabel:Dock(TOP)
        versionLabel:DockMargin(0, 0, 0, 5)
        versionLabel:SetExpensiveShadow(1, Color(0, 0, 0, 150))
        return versionLabel
    end

    local function addDateLabel(text)
        local dateLabel = scroll:Add("DLabel")
        dateLabel:SetFont("LiliaFont.16")
        dateLabel:SetTextColor(Color(180, 180, 180))
        dateLabel:SetText(tostring(text or ""))
        dateLabel:SetContentAlignment(5)
        dateLabel:SetWide(scroll:GetWide() - padding * 2)
        dateLabel:SetTall(20)
        dateLabel:Dock(TOP)
        dateLabel:DockMargin(0, 0, 0, 10)
        return dateLabel
    end

    local function extractChangeText(change)
        if isstring(change) then return change end
        if not istable(change) then return tostring(change or "") end
        local text = change.text or change.message or change.description or change.title or change.label or change.name or change.change or change[1]
        if not text then return "" end
        local category = change.type or change.category or change.tag or change.kind
        if isstring(category) and category ~= "" then text = "[" .. category .. "] " .. tostring(text) end
        return tostring(text)
    end

    local function renderChanges(changes)
        if isstring(changes) then
            addTextLabel(changes, "LiliaFont.18", Color(220, 220, 220), 0, 8)
            return
        end

        if not istable(changes) then return end
        for _, change in ipairs(changes) do
            local text = extractChangeText(change)
            if text ~= "" then addTextLabel("• " .. text, "LiliaFont.18", Color(220, 220, 220), 10, 8) end
        end
    end

    local function versionSortValue(version)
        local parts = {}
        for piece in tostring(version):gmatch("(%d+)") do
            parts[#parts + 1] = tonumber(piece) or 0
        end
        return parts
    end

    local function versionSorter(a, b)
        local aParts = versionSortValue(a)
        local bParts = versionSortValue(b)
        local count = math.max(#aParts, #bParts)
        for i = 1, count do
            local aPart = aParts[i] or 0
            local bPart = bParts[i] or 0
            if aPart ~= bPart then return aPart > bPart end
        end
        return tostring(a) > tostring(b)
    end

    local changelogContent = SCHEMA.changelog or SCHEMA.Changelog
    if istable(changelogContent) then changelogContent = changelogContent.entries or changelogContent.releases or changelogContent.versions or changelogContent.items or changelogContent.list or changelogContent end
    if istable(changelogContent) then
        local isKeyedFormat = false
        local isSimpleList = true
        for k, v in pairs(changelogContent) do
            if isstring(k) and (istable(v) or isstring(v)) then
                isKeyedFormat = true
                break
            end

            if not isnumber(k) or not isstring(v) then isSimpleList = false end
        end

        if isKeyedFormat then
            local sortedVersions = {}
            for version in pairs(changelogContent) do
                table.insert(sortedVersions, version)
            end

            table.sort(sortedVersions, versionSorter)
            for _, version in ipairs(sortedVersions) do
                local entry = changelogContent[version]
                local versionText = string.format("Version %s", version)
                local dateText
                local changes = entry
                if istable(entry) and (entry.changes or entry.notes or entry.entries or entry.items or entry.text or entry.message or entry.title or entry.label or entry.date or entry.released or entry.releaseDate) then
                    versionText = entry.version or entry.title or entry.label or versionText
                    dateText = entry.date or entry.released or entry.releaseDate
                    changes = entry.changes or entry.notes or entry.entries or entry.items or entry.text or entry.message or (#entry > 0 and entry or nil)
                end

                addVersionLabel(versionText)
                if dateText then addDateLabel(dateText) end
                renderChanges(changes)
                addSpacer()
            end
        elseif isSimpleList then
            renderChanges(changelogContent)
        else
            for i, entry in ipairs(changelogContent) do
                if isstring(entry) then
                    renderChanges({entry})
                elseif istable(entry) then
                    local versionText = entry.version or entry.title or entry.label or string.format("Version %s", i)
                    local dateText = entry.date or entry.released or entry.releaseDate
                    local changes = entry.changes or entry.notes or entry.entries or entry.items or entry.text or entry.message or (#entry > 0 and entry or nil)
                    addVersionLabel(versionText)
                    if dateText then addDateLabel(dateText) end
                    renderChanges(changes)
                    addSpacer()
                end
            end
        end
    elseif isstring(changelogContent) then
        addTextLabel(changelogContent, "LiliaFont.18", Color(220, 220, 220), 0, 8)
    end
end

function PANEL:StartBGMusic()
    if lia.menuMusic then
        lia.menuMusic:Stop()
        lia.menuMusic = nil
    end

    timer.Remove("liaMusicFader")
    local src = lia.config.get("Music", "")
    if not src:match("%S") then return end
    local vol = lia.config.get("MusicVolume", 0.25)
    local function play(music)
        music:SetVolume(vol)
        lia.menuMusic = music
        music:Play()
    end

    sound.PlayFile(src, "noplay", function(m) if m then play(m) end end)
end

function PANEL:hideExternalEntities()
    if self.hiddenEntities then self:restoreExternalEntities() end
    self.hiddenEntities = {}
    for _, ent in ents.Iterator() do
        if ent ~= self.modelEntity and not ent:IsWorld() and not ent:CreatedByMap() then
            self.hiddenEntities[ent] = ent:GetNoDraw()
            ent:SetNoDraw(true)
        end
    end
end

function PANEL:restoreExternalEntities()
    if not self.hiddenEntities then return end
    for ent, wasHidden in pairs(self.hiddenEntities) do
        if IsValid(ent) then ent:SetNoDraw(wasHidden) end
    end

    local client = LocalPlayer()
    if IsValid(client) and self.hiddenEntities[client] ~= nil then
        client:SetNoDraw(self.hiddenEntities[client])
    elseif IsValid(client) then
        client:SetNoDraw(false)
    end

    self.hiddenEntities = nil
end

function PANEL:loadBackground()
    if self.isLoadMode then
        hook.Remove("CalcView", "liaMainMenuCalcView")
        hook.Remove("PrePlayerDraw", "liaMainMenuPrePlayerDraw")
        self:hideExternalEntities()
        hook.Add("PrePlayerDraw", "liaMainMenuPrePlayerDraw", function() return true end)
        self:updateSelectedCharacter()
        if not IsValid(self.leftArrow) and self.availableCharacters and #self.availableCharacters > 1 then self:createArrows() end
        hook.Add("CalcView", "liaMainMenuCalcView", function(_, _, _, fov)
            if not IsValid(self) then return end
            if self.loadEntryCamera then return self:getLoadEntryView(fov) end
            local ent = self.modelEntity
            if not IsValid(ent) then return end
            local toCenter = ent:GetPos() + Vector(0, 0, 60)
            local toForward = ent:GetAngles():Forward()
            local origin, lookAt
            if self._camTransitionStart and self._camTransitionDuration and self._camFromCenter and self._camToCenter and self._camFromForward and self._camToForward then
                local t = math.Clamp((CurTime() - self._camTransitionStart) / self._camTransitionDuration, 0, 1)
                local eased = mmEase(t)
                local center = LerpVector(eased, self._camFromCenter, self._camToCenter)
                local forward = LerpVector(eased, self._camFromForward, self._camToForward)
                if forward:LengthSqr() < 0.0001 then forward = toForward end
                forward:Normalize()
                local baseDist = 70
                local outDist = self._camPanOutDistance or 60
                local dist = baseDist + outDist * math.sin(math.pi * eased)
                origin = center + forward * dist
                lookAt = center
                self.currentCamPos = origin
                if t >= 1 then
                    self._camTransitionStart = nil
                    self._camTransitionDuration = nil
                    self._camFromCenter = nil
                    self._camToCenter = nil
                    self._camFromForward = nil
                    self._camToForward = nil
                    self._camPanOutDistance = nil
                end
            else
                local desired = toCenter + toForward * 70
                if not self.currentCamPos then
                    self.currentCamPos = desired
                else
                    self.currentCamPos = LerpVector(FrameTime() * 5, self.currentCamPos, desired)
                end

                origin = self.currentCamPos
                lookAt = toCenter
            end
            return {
                origin = origin,
                angles = ((lookAt or toCenter) - origin):Angle(),
                fov = fov,
                drawviewer = true
            }
        end)
    else
        hook.Remove("CalcView", "liaMainMenuCalcView")
        self.loadEntryCamera = nil
        hook.Remove("PrePlayerDraw", "liaMainMenuPrePlayerDraw")
        self:restoreExternalEntities()
        if IsValid(self.modelEntity) then self.modelEntity:Remove() end
        if IsValid(self.leftArrow) then
            self.leftArrow:Remove()
            self.leftArrow = nil
        end

        if IsValid(self.rightArrow) then
            self.rightArrow:Remove()
            self.rightArrow = nil
        end

        local url = lia.config.get("BackgroundURL")
        if not isstring(url) then url = tostring(url or "") end
        if string.find(url, "%S") then
            self.background = self:Add("DHTML")
            self.background:SetSize(ScrW(), ScrH())
            self.background.ConsoleMessage = function(_, msg) end
            self.background.OnDocumentReady = function() if IsValid(self.bgLoader) then self.bgLoader:Remove() end end
            self.background.OnDocumentError = function(_, errCode, errText) end
            if string.find(url, "http", 1, true) then
                local isImageURL = url:find("%.png", 1, true) or url:find("%.jpg", 1, true) or url:find("%.jpeg", 1, true) or url:find("%.webp", 1, true) or url:find("%.gif", 1, true)
                if isImageURL then
                    local safeURL = url:gsub('"', "%%22")
                    self.background:SetHTML([[<html><head><meta charset="utf-8"><style>
html, body { width:100%; height:100%; margin:0; padding:0; overflow:hidden; background:#000; }
body { background-position:center center; background-repeat:no-repeat; background-size:cover; }
</style></head><body>
<script>
(function() {
  try {
    var url = "]] .. safeURL .. [[";
    console.log("[Lilia MainMenu] Attempting to load image:", url);
    var img = new Image();
    img.onload = function() {
      document.body.style.backgroundImage = 'url("' + url + '")';
      console.log("[Lilia MainMenu] Image loaded OK:", img.width + "x" + img.height);
      document.title = "LiliaBG:OK";
    };
    img.onerror = function(e) {
      console.log("[Lilia MainMenu] Image failed to load", e);
      document.title = "LiliaBG:ERR";
    };
    img.src = url;
  } catch (e) {
    console.log("[Lilia MainMenu] Exception:", e);
    document.title = "LiliaBG:EX";
  }
})();
</script>
</body></html>]])
                else
                    self.background:OpenURL(url)
                end
            else
                self.background:SetHTML(url)
            end

            self.background:MoveToBack()
            self.background:SetZPos(-999)
            if lia.config.get("CharMenuBGInputDisabled", true) then
                self.background:SetMouseInputEnabled(false)
                self.background:SetKeyboardInputEnabled(false)
            end

            self.bgLoader = self:Add("DPanel")
            self.bgLoader:SetSize(ScrW(), ScrH())
            self.bgLoader:SetZPos(-998)
            self.bgLoader.Paint = function(_, w, h)
                surface.SetDrawColor(5, 5, 5)
                surface.DrawRect(0, 0, w, h)
            end
        end
    end
end

function PANEL:createStartButton()
    local client = LocalPlayer()
    if not IsValid(client) then
        timer.Simple(0.1, function() if IsValid(self) then self:createStartButton() end end)
        return
    end

    self.inMainMenu = true
    self.isLoadMode = false
    self:setInWorldPreviewEnabled(false)
    if IsValid(self.menuPanel) then self.menuPanel:Remove() end
    if IsValid(self.welcomeSide) then self.welcomeSide:Remove() end
    if IsValid(self.selectionPanel) then self.selectionPanel:Remove() end
    if IsValid(self.infoFrame) then self.infoFrame:Remove() end
    if IsValid(self.bgLoader) then self.bgLoader:Remove() end
    if IsValid(self.background) then self.background:Remove() end
    if IsValid(self.changelogPanel) then self.changelogPanel:Remove() end
    if IsValid(self.modelEntity) then
        self.modelEntity:Remove()
        self.modelEntity = nil
    end

    self.buttons = self.buttons or {}
    self:showContent(false)
    self.tabs:SetVisible(false)
    self.content:SetVisible(false)
    local w = math.Clamp(ScrW() * 0.24, 340, 470)
    local h = math.Clamp(ScrH() * 0.58, 440, 640)
    local x = math.max(32, ScrW() * 0.035)
    local y = ScrH() * 0.5 - h * 0.5
    self.menuPanel = self:Add("DPanel")
    self.menuPanel:SetSize(w, h)
    self.menuPanel:SetPos(x, y)
    self.menuPanel.Paint = function(_, pw, ph) mmPaintContainer(pw, ph) end
    mmAnimateIn(self.menuPanel, x, y, -14, 0, 0.34, 0)
    local discordURL = lia.config.get("DiscordURL", "")
    local buttonsData = {}
    local hasStaffChar, hasNonStaffChar = false, false
    if lia.characters and #lia.characters > 0 then
        for _, charID in pairs(lia.characters) do
            local character = lia.char.getCharacter(charID)
            if character then
                if character:getFaction() == FACTION_STAFF then
                    hasStaffChar = true
                else
                    hasNonStaffChar = true
                end
            end
        end
    end

    local function openCharacterCreation()
        self:openCharacterCreationWithTransition()
    end

    local function openCharacterSelection()
        self:openCharacterSelectionWithTransition()
    end

    local function addEntry(section, id, text, tooltip, doClick)
        buttonsData[#buttonsData + 1] = {
            section = section,
            id = id,
            text = text,
            tooltip = tooltip,
            doClick = doClick
        }
    end

    if hook.Run("CanPlayerCreateChar", client) ~= false then addEntry("Character Access", "create", "Create Character", "Create a new identity and enter the city.", openCharacterCreation) end
    local loadTooltip = hasNonStaffChar and "Continue with an existing identity." or "Browse characters or create your first character."
    addEntry("Character Access", "load", "Load Character", loadTooltip, openCharacterSelection)
    local mainCharID = IsValid(client) and client:getMainCharacter() or nil
    local clientChar = client.getChar and client:getChar()
    if mainCharID and lia.characters and #lia.characters > 0 and table.HasValue(lia.characters, mainCharID) and (not clientChar or clientChar:getID() ~= mainCharID) then
        addEntry("Character Access", "loadmain", "Load Main Character", "Jump straight into your main character.", function()
            self:clickSound()
            lia.module.get("mainmenu"):LoadMainCharacter():next(function() end):catch(function(err) if err and err ~= "" then LocalPlayer():notifyError(err) end end)
        end)
    end

    local canCreateStaffCharacter = client:hasPrivilege("createStaffCharacter")
    local isStaffOnDuty = client:isStaffOnDuty()
    if canCreateStaffCharacter and not isStaffOnDuty then
        addEntry("Staff Access", "staff", hasStaffChar and "Load Staff Character" or "Create Staff Character", hasStaffChar and "Load your staff character." or "Create a character with staff permissions.", function()
            self:clickSound()
            if hasStaffChar then
                for _, charID in pairs(lia.characters or {}) do
                    local character = lia.char.getCharacter(charID)
                    if character and character:getFaction() == FACTION_STAFF then
                        lia.module.get("mainmenu"):ChooseCharacter(character:getID()):next(function() if IsValid(lia.gui.character) then lia.gui.character:Remove() end end):catch(function(err) if err and err ~= "" then LocalPlayer():notifyError(err) end end)
                        break
                    end
                end
            else
                self:createStaffCharacter()
            end
        end)
    end

    if discordURL ~= "" then
        addEntry("System", "discord", "Discord", "Join our Discord server.", function()
            self:clickSound()
            gui.OpenURL(discordURL)
        end)
    end

    addEntry("System", "mount", "Workshop", "Browse and mount Workshop addons.", function()
        self:clickSound()
        if IsValid(lia.gui.workshopMount) then lia.gui.workshopMount:Remove() end
        lia.gui.workshopMount = vgui.Create("liaWorkshopMountMenu")
    end)

    addEntry("System", "disconnect", "Disconnect", "Leave the server and return to desktop.", function()
        self:clickSound()
        RunConsoleCommand("disconnect")
    end)

    if clientChar and not self.isKickedFromChar then addEntry("System", "return", "Return to Your Character", "Close this menu and return to play.", function() self:Remove() end) end
    self.buttons = {}
    local pad = 18
    local innerW = w - pad * 2
    local cursorY = 18
    local title = self.menuPanel:Add("DLabel")
    title:SetFont("LiliaFont.30")
    title:SetTextColor(mmText())
    title:SetText("MAIN MENU")
    title:SetPos(pad, cursorY)
    title:SizeToContents()
    cursorY = cursorY + 34
    local subtitle = self.menuPanel:Add("DLabel")
    subtitle:SetFont("LiliaFont.17")
    subtitle:SetTextColor(mmMuted())
    subtitle:SetText("Choose how you want to enter the city.")
    subtitle:SetPos(pad, cursorY)
    subtitle:SizeToContents()
    cursorY = cursorY + 28
    local lastSection
    local function addSectionLabel(text)
        local lbl = self.menuPanel:Add("DLabel")
        lbl:SetFont("LiliaFont.14")
        lbl:SetTextColor(mmMuted(180))
        lbl:SetText(string.upper(text))
        lbl:SetPos(pad, cursorY)
        lbl:SizeToContents()
        cursorY = cursorY + 22
    end

    local function addMenuButton(entry)
        local btnH = 56
        local btn = self.menuPanel:Add("DButton")
        btn:SetText("")
        btn:SetPos(pad, cursorY)
        btn:SetSize(innerW, btnH)
        btn.liaToolTip = entry.tooltip and entry.tooltip ~= ""
        btn.liaMainMenuTooltip = btn.liaToolTip
        btn.liaMainMenuTooltipText = entry.tooltip
        if btn.liaToolTip then btn:SetTooltip("<font=LiliaFont.16>" .. entry.tooltip .. "</font>") end
        btn.Paint = function(s, bw, bh)
            local hovered = s:IsHovered()
            mmPaintBlock(bw, bh, hovered)
            draw.SimpleText(string.upper(entry.text), "LiliaFont.17", 16, 18, mmText(), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText(entry.tooltip or "", "LiliaFont.14", 16, 38, mmMuted(), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            if hovered then draw.SimpleText(">", "LiliaFont.17", bw - 16, bh * 0.5, mmAccent(), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) end
        end

        function btn:OnCursorEntered()
            if IsValid(lia.gui.character) then lia.gui.character:hoverSound() end
        end

        btn.DoClick = entry.doClick
        self.buttons[entry.id] = btn
        cursorY = cursorY + btnH + 10
    end

    for _, entry in ipairs(buttonsData) do
        if entry.section ~= lastSection then
            addSectionLabel(entry.section)
            lastSection = entry.section
        end

        addMenuButton(entry)
    end

    self:createWelcomeSidePanel()
end

function PANEL:addTab(name, callback, justClick, height)
    local btn = self.tabs:Add("liaMediumButton")
    surface.SetFont(btn:GetFont())
    local textW, textH = surface.GetTextSize(tostring(name):upper())
    btn:SetWide(textW + 40)
    btn:SetText(tostring(name):upper())
    btn:SetShowLine(true)
    btn:SetTall(height or textH + 20)
    if justClick then
        if isfunction(callback) then btn.DoClick = function() callback(self) end end
        return btn
    end

    btn.DoClick = function(b) b:SetSelected(true) end
    if isfunction(callback) then btn:onSelected(function() callback(self) end) end
    return btn
end

function PANEL:createTabs()
    self.tabs:Clear()
    if not self.isLoadMode and not self.isKickedFromChar then self:addTab("Return to Main Menu", function() self:backToMainMenu() end, true) end
end

function PANEL:backToMainMenu()
    self:clickSound()
    if IsValid(lia.gui.charConfirm) then lia.gui.charConfirm:Remove() end
    if IsValid(self.infoFrame) then self.infoFrame:Remove() end
    if IsValid(self.changelogPanel) then self.changelogPanel:Remove() end
    if IsValid(self.leftArrow) then
        self.leftArrow:Remove()
        self.leftArrow = nil
    end

    if IsValid(self.rightArrow) then
        self.rightArrow:Remove()
        self.rightArrow = nil
    end

    local function finish()
        if self.inWorldPreview then self:setInWorldPreviewEnabled(false) end
        if IsValid(self.selectBtn) then self.selectBtn:Remove() end
        if IsValid(self.deleteBtn) then self.deleteBtn:Remove() end
        if IsValid(self.setMainBtn) then self.setMainBtn:Remove() end
        for _, btn in pairs(self.buttons) do
            if IsValid(btn) then btn:Remove() end
        end

        self.buttons = {}
        self.isLoadMode = false
        self.disableClientModel = false
        self.inCharacterCreation = false
        self.content:Clear()
        self.tabs:Clear()
        self:createStartButton()
        self:loadBackground()
    end

    self:transitionPanelsOut({
        {
            panel = self.menuPanel,
            dx = -14
        },
        {
            panel = self.selectionPanel,
            dx = 14
        }
    }, function() if IsValid(self) then finish() end end)
end

function PANEL:getClosestGroundPosition(pos)
    if not isvector(pos) then return pos end
    local startPos = pos + Vector(0, 0, 64)
    local endPos = pos + Vector(0, 0, -16384)
    local tr = util.TraceLine({
        start = startPos,
        endpos = endPos,
        mask = MASK_SOLID,
        filter = {self.modelEntity, LocalPlayer()}
    })

    if tr.Hit and tr.HitWorld and not tr.HitSky then
        local hitPos = tr.HitPos
        if isvector(hitPos) and hitPos.z <= startPos.z + 1 then return hitPos + Vector(0, 0, 2) end
    end
    return pos
end

function PANEL:createCharacterSelection()
    self.isLoadMode = true
    self.inMainMenu = false
    if IsValid(self.welcomeSide) then self.welcomeSide:Remove() end
    if IsValid(self.menuPanel) then self.menuPanel:Remove() end
    if IsValid(self.selectionPanel) then self.selectionPanel:Remove() end
    if IsValid(self.changelogPanel) then self.changelogPanel:Remove() end
    self.buttons = self.buttons or {}
    self.availableCharacters = {}
    for _, charID in pairs(lia.characters or {}) do
        local character = lia.char.getCharacter(charID)
        if character and character:getFaction() ~= FACTION_STAFF then self.availableCharacters[#self.availableCharacters + 1] = charID end
    end

    self:showContent(true)
    self.tabs:SetVisible(false)
    self.content:SetVisible(true)
    local client = LocalPlayer()
    local hasStaffChar = false
    for _, charID in pairs(lia.characters or {}) do
        local character = lia.char.getCharacter(charID)
        if character and character:getFaction() == FACTION_STAFF then
            hasStaffChar = true
            break
        end
    end

    local leftW = math.Clamp(ScrW() * 0.24, 340, 470)
    local leftH = math.Clamp(ScrH() * 0.58, 440, 640)
    local leftX = math.max(32, ScrW() * 0.035)
    local leftY = ScrH() * 0.5 - leftH * 0.5
    self.menuPanel = self:Add("DPanel")
    self.menuPanel:SetSize(leftW, leftH)
    self.menuPanel:SetPos(leftX, leftY)
    self.menuPanel.Paint = function(_, pw, ph) mmPaintContainer(pw, ph) end
    mmAnimateIn(self.menuPanel, leftX, leftY, -14, 0, 0.34, 0)
    local pad = 18
    local innerW = leftW - pad * 2
    local y = 18
    local title = self.menuPanel:Add("DLabel")
    title:SetFont("LiliaFont.30")
    title:SetTextColor(mmText())
    title:SetText("MAIN MENU")
    title:SetPos(pad, y)
    title:SizeToContents()
    y = y + 34
    local subtitle = self.menuPanel:Add("DLabel")
    subtitle:SetFont("LiliaFont.17")
    subtitle:SetTextColor(mmMuted())
    subtitle:SetText("Use the arrows to switch characters.")
    subtitle:SetPos(pad, y)
    subtitle:SizeToContents()
    y = y + 28
    local function addSectionLabel(text)
        local lbl = self.menuPanel:Add("DLabel")
        lbl:SetFont("LiliaFont.14")
        lbl:SetTextColor(mmMuted(180))
        lbl:SetText(string.upper(text))
        lbl:SetPos(pad, y)
        lbl:SizeToContents()
        y = y + 22
    end

    local function addMenuButton(text, tooltip, doClick)
        local btnH = 56
        local btn = self.menuPanel:Add("DButton")
        btn:SetText("")
        btn:SetPos(pad, y)
        btn:SetSize(innerW, btnH)
        btn.Paint = function(s, bw, bh)
            local hovered = s:IsHovered()
            mmPaintBlock(bw, bh, hovered)
            draw.SimpleText(string.upper(text), "LiliaFont.17", 16, 18, mmText(), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText(tooltip or "", "LiliaFont.14", 16, 38, mmMuted(), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            if hovered then draw.SimpleText(">", "LiliaFont.17", bw - 16, bh * 0.5, mmAccent(), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) end
        end

        function btn:OnCursorEntered()
            if IsValid(lia.gui.character) then lia.gui.character:hoverSound() end
        end

        btn.DoClick = doClick
        y = y + btnH + 10
        return btn
    end

    addSectionLabel("Character Access")
    addMenuButton("Create Character", "Create a new identity and enter the city.", function() self:openCharacterCreationWithTransition() end)
    addMenuButton("Load Character", #self.availableCharacters > 0 and "Continue with an existing identity." or "No characters found yet.", function() self:clickSound() end)
    if client:hasPrivilege("createStaffCharacter") and not client:isStaffOnDuty() then
        addSectionLabel("Staff Access")
        addMenuButton(hasStaffChar and "Load Staff Character" or "Create Staff Character", hasStaffChar and "Load your staff character." or "Create a character with staff permissions.", function()
            self:clickSound()
            if hasStaffChar then
                for _, charID in pairs(lia.characters or {}) do
                    local character = lia.char.getCharacter(charID)
                    if character and character:getFaction() == FACTION_STAFF then
                        lia.module.get("mainmenu"):ChooseCharacter(character:getID()):next(function() if IsValid(lia.gui.character) then lia.gui.character:Remove() end end):catch(function(err) if err and err ~= "" then LocalPlayer():notifyError(err) end end)
                        break
                    end
                end
            else
                self:createStaffCharacter()
            end
        end)
    end

    addSectionLabel("System")
    addMenuButton("Workshop", "Browse and mount Workshop addons.", function()
        self:clickSound()
        if IsValid(lia.gui.workshopMount) then lia.gui.workshopMount:Remove() end
        lia.gui.workshopMount = vgui.Create("liaWorkshopMountMenu")
    end)

    addMenuButton("Disconnect", "Leave the server and return to desktop.", function()
        self:clickSound()
        RunConsoleCommand("disconnect")
    end)

    local rightW = math.Clamp(ScrW() * 0.23, 360, 520)
    local rightH = math.Clamp(ScrH() * 0.60, 480, 700)
    local rightX = ScrW() - rightW - math.max(32, ScrW() * 0.04)
    local rightY = ScrH() * 0.5 - rightH * 0.5
    self.selectionPanel = self:Add("DPanel")
    self.selectionPanel:SetSize(rightW, rightH)
    self.selectionPanel:SetPos(rightX, rightY)
    self.selectionPanel.Paint = function(_, pw, ph) mmPaintContainer(pw, ph) end
    mmAnimateIn(self.selectionPanel, rightX, rightY, 18, 0, 0.36, 0.06)
    self.selectionTitle = self.selectionPanel:Add("DLabel")
    self.selectionTitle:SetFont("LiliaFont.22")
    self.selectionTitle:SetTextColor(mmText())
    self.selectionTitle:SetText("CHARACTER DETAILS")
    self.selectionTitle:SetPos(16, 14)
    self.selectionTitle:SizeToContents()
    self.selectionCountLabel = self.selectionPanel:Add("DLabel")
    self.selectionCountLabel:SetFont("LiliaFont.17")
    self.selectionCountLabel:SetTextColor(mmAccent())
    self.selectionCountLabel:SetText("")
    self.selectionCountLabel:SetPos(rightW - 54, 16)
    self.selectionCountLabel:SizeToContents()
    local detailsY = 50
    local actionHeight = 139
    local actionY = rightH - actionHeight - 15
    self.detailsWrap = self.selectionPanel:Add("DPanel")
    self.detailsWrap:SetPos(16, detailsY)
    self.detailsWrap:SetSize(rightW - 32, math.max(80, actionY - detailsY - 12))
    self.detailsWrap.Paint = function(_, w, h) mmPaintBlock(w, h, false) end
    self.detailsPanel = self.detailsWrap:Add("DScrollPanel")
    self.detailsPanel:SetPos(6, 6)
    self.detailsPanel:SetSize(self.detailsWrap:GetWide() - 12, self.detailsWrap:GetTall() - 12)
    self.detailsPanel.Paint = function() end
    mmStyleScrollBar(self.detailsPanel)
    self.actionPanel = self.selectionPanel:Add("DPanel")
    self.actionPanel:SetPos(16, actionY)
    self.actionPanel:SetSize(rightW - 32, actionHeight)
    self.actionPanel.Paint = function() end
    if #self.availableCharacters > 0 then
        self.currentIndex = math.Clamp(self.currentIndex or 1, 1, #self.availableCharacters)
    else
        self.currentIndex = nil
    end

    self:updateSelectedCharacter()
end

function PANEL:createCharacterCreation()
    local creator, reason = lia.module.get("mainmenu"):OpenCharacterCreator(self)
    if not IsValid(creator) then
        self.inCharacterCreation = false
        self.panelsTransitioning = false
        self:createStartButton()
        if reason then LocalPlayer():notifyError(reason) end
        return
    end

    self:restoreExternalEntities()
    hook.Remove("PrePlayerDraw", "liaMainMenuPrePlayerDraw")
    hook.Remove("CalcView", "liaMainMenuCalcView")
    hook.Remove("PostDrawOpaqueRenderables", "liaMainMenuPostDrawOpaqueRenderables")
    if self.mainMenuRenderHookID then
        hook.Remove("PostDrawOpaqueRenderables", self.mainMenuRenderHookID)
        self.mainMenuRenderHookID = nil
    end

    if IsValid(self.modelEntity) then
        self.modelEntity:Remove()
        self.modelEntity = nil
    end

    if IsValid(self.fadingModelEntity) then self.fadingModelEntity:Remove() end
    self.fadingModelEntity = nil
    self.previewCharacterID = nil
    if IsValid(self.leftArrow) then
        self.leftArrow:Remove()
        self.leftArrow = nil
    end

    if IsValid(self.rightArrow) then
        self.rightArrow:Remove()
        self.rightArrow = nil
    end

    for _, name in ipairs{"background", "logo", "changelogPanel"} do
        if IsValid(self[name]) then
            self[name]:Remove()
            self[name] = nil
        end
    end

    for _, b in pairs(self.buttons) do
        if IsValid(b) then b:Remove() end
    end

    self.buttons = {}
    if IsValid(self.bgLoader) then self.bgLoader:Remove() end
    self.content:Clear()
    self.content:InvalidateLayout(true)
    self.creator = creator
    self.inCharacterCreation = true
    self:SetVisible(false)
    return creator
end

function PANEL:ReturnFromCharacterCreation()
    self.creator = nil
    self.inCharacterCreation = false
    self.panelsTransitioning = false
    self:SetVisible(true)
    self:MakePopup()
    self:MoveToFront()
    self.content:Clear()
    self.tabs:Clear()
    self:createStartButton()
end

function PANEL:createStaffCharacter()
    local client = LocalPlayer()
    local steamName = client:Nick()
    local staffData = {
        name = steamName,
        faction = FACTION_STAFF,
        model = 1,
        desc = "",
        skin = 0,
        groups = {}
    }

    lia.module.get("mainmenu"):CreateCharacter(staffData):next(function(charID) lia.module.get("mainmenu"):ChooseCharacter(charID):next(function() if IsValid(lia.gui.character) then lia.gui.character:Remove() end end):catch(function(err) if err and err ~= "" then LocalPlayer():notifyError(err) end end) end):catch(function(err) LocalPlayer():notifyError(err or "Failed to create staff character") end)
end

function PANEL:updateSelectedCharacter()
    if not self.isLoadMode then return end
    local chars = self.availableCharacters or {}
    if #chars == 0 then
        self.currentIndex = nil
        if IsValid(self.modelEntity) then
            self.modelEntity:Remove()
            self.modelEntity = nil
        end

        if IsValid(self.fadingModelEntity) then
            self.fadingModelEntity:Remove()
            self.fadingModelEntity = nil
        end

        self.previewCharacterID = nil
        self:createSelectedCharacterInfoPanel(nil)
        return
    end

    self.currentIndex = math.Clamp(self.currentIndex or 1, 1, #chars)
    local selectedID = chars[self.currentIndex]
    local character = lia.char.getCharacter(selectedID)
    self:createSelectedCharacterInfoPanel(character)
    if character and (self.previewCharacterID ~= selectedID or not IsValid(self.modelEntity)) then self:updateModelEntity(character) end
end

function PANEL:updateSelectedCharacterForID(charID)
    if not self.isLoadMode then return end
    local chars = self.availableCharacters or {}
    if #chars == 0 then
        self.currentIndex = nil
        if IsValid(self.modelEntity) then
            self.modelEntity:Remove()
            self.modelEntity = nil
        end

        self:createSelectedCharacterInfoPanel(nil)
        return
    end

    for i, cID in ipairs(chars) do
        if cID == charID then
            self.currentIndex = i
            break
        end
    end

    self:updateSelectedCharacter()
end

function PANEL:createSelectedCharacterInfoPanel(character)
    if not IsValid(self.selectionPanel) then return end
    local accent = mmAccent()
    local chars = self.availableCharacters or {}
    if IsValid(self.detailsPanel) then self.detailsPanel:Clear() end
    if IsValid(self.actionPanel) then self.actionPanel:Clear() end
    if IsValid(self.selectionCountLabel) then
        self.selectionCountLabel:SetText(string.format("%d / %d", self.currentIndex or 0, #chars))
        self.selectionCountLabel:SizeToContents()
    end

    if not character then
        local empty = self.detailsPanel:Add("DPanel")
        empty:Dock(FILL)
        empty.Paint = function(_, w, h)
            draw.SimpleText("NO CHARACTERS FOUND", "LiliaFont.22", w * 0.5, h * 0.38, mmText(), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText("Create a character to begin your journey in the city.", "LiliaFont.17", w * 0.5, h * 0.50, mmMuted(), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        local createBtn = self.actionPanel:Add("DButton")
        createBtn:Dock(TOP)
        createBtn:SetTall(42)
        createBtn:SetText("")
        createBtn.Paint = function(s, w, h)
            mmPaintBlock(w, h, s:IsHovered())
            draw.SimpleText("CREATE CHARACTER", "LiliaFont.17", w * 0.5, h * 0.5, mmText(), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        function createBtn:OnCursorEntered()
            if IsValid(lia.gui.character) then lia.gui.character:hoverSound() end
        end

        createBtn.DoClick = function() self:openCharacterCreationWithTransition() end
        return
    end

    local detailsWidth = math.max(250, self.detailsPanel:GetWide() - 14)
    local cardGap = 8
    local rowHeight = 57
    local cardWidth = math.floor((detailsWidth - cardGap) * 0.5)
    local function createDetailCard(parent, title, value, width, height)
        local card = parent:Add("DPanel")
        card:SetSize(width, height)
        card.Paint = function(_, w, h) mmPaintBlock(w, h, false) end
        local key = card:Add("DLabel")
        key:SetFont("LiliaFont.14")
        key:SetTextColor(mmMuted())
        key:SetText(string.upper(title))
        key:SetPos(12, 9)
        key:SizeToContents()
        local label = card:Add("DLabel")
        label:SetFont(title == "Description" and "LiliaFont.16" or "LiliaFont.17")
        label:SetTextColor(mmText())
        label:SetText(tostring(value or ""))
        label:SetWrap(true)
        label:SetContentAlignment(7)
        label:SetPos(12, 28)
        label:SetSize(width - 24, height - 34)
        return card
    end

    local function createPair(left, right)
        local row = self.detailsPanel:Add("DPanel")
        row:Dock(TOP)
        row:DockMargin(0, 0, 0, cardGap)
        row:SetTall(rowHeight)
        row.Paint = function() end
        createDetailCard(row, left[1], left[2], cardWidth, rowHeight):SetPos(0, 0)
        if right then createDetailCard(row, right[1], right[2], cardWidth, rowHeight):SetPos(cardWidth + cardGap, 0) end
    end

    local function createFull(title, value, height)
        local card = createDetailCard(self.detailsPanel, title, value, detailsWidth, height)
        card:Dock(TOP)
        card:DockMargin(0, 0, 0, cardGap)
    end

    createPair({"Name", character:getName() or ""}, {"Faction", team.GetName(character:getFaction()) or ""})
    local description = tostring(character:getDesc() or "")
    local estimatedLines = math.ceil(#description / math.max(20, math.floor((detailsWidth - 24) / 7.4)))
    local descriptionHeight = 43 + math.max(2, estimatedLines) * 18
    createFull("Description", description, math.Clamp(descriptionHeight, 79, 186))
    local extraValue
    if character.getClass and character:getClass() then
        local cls = lia.class.list[character:getClass()]
        if cls and cls.name then extraValue = {"Class", cls.name} end
    end

    createPair({"Money", lia.currency.get(character:getMoney())}, extraValue)
    if next(lia.attribs.list or {}) then
        local heading = self.detailsPanel:Add("DLabel")
        heading:Dock(TOP)
        heading:DockMargin(0, 7, 0, 9)
        heading:SetTall(19)
        heading:SetFont("LiliaFont.16")
        heading:SetTextColor(mmAccent())
        heading:SetText("ATTRIBUTES")
        local attrs = {}
        for id, attr in pairs(lia.attribs.list) do
            attrs[#attrs + 1] = {
                id = id,
                attr = attr
            }
        end

        table.sort(attrs, function(a, b) return a.attr.name < b.attr.name end)
        for _, entry in ipairs(attrs) do
            local value = character:getAttrib(entry.id) or (entry.attr.min or 0)
            local maximum = math.max(entry.attr.max or 100, 1)
            local label = self.detailsPanel:Add("DLabel")
            label:Dock(TOP)
            label:DockMargin(0, 0, 0, 4)
            label:SetTall(18)
            label:SetFont("LiliaFont.14")
            label:SetTextColor(mmText())
            label:SetText(entry.attr.name)
            local progress = self.detailsPanel:Add("liaProgressBar")
            progress:Dock(TOP)
            progress:DockMargin(0, 0, 0, 12)
            progress:SetTall(26)
            progress:SetFraction(math.Clamp(value / maximum, 0, 1))
            progress:SetText(value .. "/" .. maximum)
            progress.Font = "LiliaFont.14"
            progress:SetBarColor(entry.attr.color or accent)
        end
    end

    self.detailsPanel:InvalidateLayout(true)
    if IsValid(self.detailsWrap) then
        local x, y = self.detailsWrap:GetPos()
        self.detailsWrap:SetAlpha(0)
        mmTweenPanel(self.detailsWrap, x, y, 255, 0.24, 0)
    end

    local function addActionButton(text, colorOverride, doClick)
        local btn = self.actionPanel:Add("DButton")
        btn:Dock(TOP)
        btn:DockMargin(0, 0, 0, 8)
        btn:SetTall(36)
        btn:SetText("")
        btn.Paint = function(s, w, h)
            local borderColor = colorOverride or mmAccent()
            local active = s:IsHovered()
            local bg = mmSurface(active and 0.06 or 0.04, active and 242 or 236)
            mmDrawPanel(0, 0, w, h, 4, bg, Color(borderColor.r, borderColor.g, borderColor.b, active and 120 or 70))
            draw.SimpleText(string.upper(text), "LiliaFont.14", w * 0.5, h * 0.5, mmText(), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        function btn:OnCursorEntered()
            if IsValid(lia.gui.character) then lia.gui.character:hoverSound() end
        end

        btn.DoClick = doClick
        return btn
    end

    addActionButton(character:isBanned() and "Character Permanently Killed" or "Play Character", nil, function()
        if character:isBanned() then
            local characterName = character:getName()
            LocalPlayer():requestString("Permanent Kill", string.format("Your character: %s, has been permanently killed. An administrator has approved this PK.\nPKs are a regular part of RP; you can always make a new character. Have fun!", characterName), function() end)
            return
        end

        self:clickSound()
        lia.module.get("mainmenu"):ChooseCharacter(character:getID()):next(function() if IsValid(self) then self:Remove() end end):catch(function(err) if err and err ~= "" then LocalPlayer():notifyError(err) end end)
    end)

    addActionButton("Delete Character", Color(185, 90, 90), function()
        local charID = character:getID()
        if hook.Run("CanDeleteChar", charID) == false then
            LocalPlayer():notifyError("You cannot delete this character!")
            return
        end

        self:showConfirmation("Are you sure you want to delete this character?\nThis action cannot be undone.", function() lia.module.get("mainmenu"):DeleteCharacter(charID) end)
    end)

    local localClient = LocalPlayer()
    local mainCharID = IsValid(localClient) and localClient:getMainCharacter() or nil
    if character:getID() ~= mainCharID then
        addActionButton("Set as Main Character", nil, function()
            if IsValid(localClient) then localClient:setMainCharacter(character:getID()) end
            self:clickSound()
            self:createSelectedCharacterInfoPanel(character)
        end)
    end
end

function PANEL:updateModelEntity(character)
    local prevEnt = self.modelEntity
    if not character then return end
    if IsValid(self.fadingModelEntity) then self.fadingModelEntity:Remove() end
    self.fadingModelEntity = nil
    local model = character.getModel and character:getModel() or LocalPlayer():GetModel()
    self.modelEntity = ClientsideModel(model, RENDERGROUP_OPAQUE)
    if not IsValid(self.modelEntity) then
        self.modelEntity = prevEnt
        return
    end

    self.modelEntity:SetSkin(character:getSkin())
    lia.util.applyBodygroups(self.modelEntity, character:getBodygroups())
    hook.Run("SetupPlayerModel", self.modelEntity, character)
    local pos, ang = self:getPreviewPlacement(character)
    self.modelEntity:SetPos(pos)
    self.modelEntity:SetAngles(ang)
    if IsValid(prevEnt) and self.isLoadMode then
        local fromCenter = prevEnt:GetPos() + Vector(0, 0, 60)
        local fromForward = prevEnt:GetAngles():Forward()
        local toCenter = self.modelEntity:GetPos() + Vector(0, 0, 60)
        local toForward = self.modelEntity:GetAngles():Forward()
        self._camFromCenter = fromCenter
        self._camFromForward = fromForward
        self._camToCenter = toCenter
        self._camToForward = toForward
        self._camTransitionStart = CurTime()
        self._camTransitionDuration = 0.72
        self._camPanOutDistance = 34
    elseif not self.loadEntryCamera then
        self.currentCamPos = nil
    end

    self.previewCharacterID = character:getID()
    if IsValid(prevEnt) then
        self.fadingModelEntity = prevEnt
        self.modelTransitionStarted = RealTime()
    else
        self.modelTransitionStarted = nil
    end

    local seqID = self.modelEntity:LookupSequence("idle_all_01")
    if seqID > 0 then
        self.modelEntity:ResetSequence(seqID)
        self.modelEntity:SetCycle(0)
    else
        for _, seq in ipairs(self.modelEntity:GetSequenceList()) do
            if seq:lower():find("idle") and seq ~= "idlenoise" then
                self.modelEntity:ResetSequence(seq)
                self.modelEntity:SetCycle(0)
                break
            end
        end
    end

    hook.Run("ModifyCharacterModel", self.modelEntity, character)
    hook.Add("PostDrawOpaqueRenderables", "liaMainMenuPostDrawOpaqueRenderables", function()
        if not IsValid(self) or not IsValid(self.modelEntity) or not (self.isLoadMode or self.inWorldPreview) then return end
        local fraction = self.modelTransitionStarted and mmEase((RealTime() - self.modelTransitionStarted) / 0.36) or 1
        if IsValid(self.fadingModelEntity) then
            if fraction < 1 then
                render.SetBlend(1 - fraction)
                self.fadingModelEntity:FrameAdvance()
                self.fadingModelEntity:DrawModel()
            else
                self.fadingModelEntity:Remove()
                self.fadingModelEntity = nil
                self.modelTransitionStarted = nil
            end
        end

        render.SetBlend(fraction)
        self.modelEntity:FrameAdvance()
        self.modelEntity:DrawModel()
        render.SetBlend(1)
    end)
end

function PANEL:createArrows()
    if IsValid(self.leftArrow) then self.leftArrow:Remove() end
    if IsValid(self.rightArrow) then self.rightArrow:Remove() end
    local size = math.Clamp(ScrH() * 0.062, 48, 66)
    local gap = math.Clamp(ScrW() * 0.135, 155, 265)
    local centerX = ScrW() * 0.5
    local centerY = ScrH() * 0.52
    local function newArrow(direction)
        local button = self:Add("DButton")
        button:SetText("")
        button:SetSize(size, size)
        local x = direction < 0 and centerX - gap - size or centerX + gap
        local y = centerY - size * 0.5
        mmAnimateIn(button, x, y, direction * 12, 0, 0.34, 0.08)
        button.hoverFraction = 0
        button.Paint = function(s, w, h)
            s.hoverFraction = Lerp(math.min(FrameTime() * 12, 1), s.hoverFraction, s:IsHovered() and 1 or 0)
            local fraction = s.hoverFraction
            local accent = mmAccent()
            local background = mmSurface(0.05 + fraction * 0.035, 232 + fraction * 15)
            mmDrawPanel(0, 0, w, h, 6, background, Color(accent.r, accent.g, accent.b, 65 + fraction * 110))
            local cx = math.floor(w * 0.5)
            local cy = math.floor(h * 0.5)
            local reach = math.floor(math.min(w, h) * 0.16)
            surface.SetDrawColor(mmMix(mmMuted(), accent, 0.45 + fraction * 0.55))
            if direction < 0 then
                surface.DrawLine(cx + reach * 0.35, cy - reach, cx - reach * 0.65, cy)
                surface.DrawLine(cx - reach * 0.65, cy, cx + reach * 0.35, cy + reach)
            else
                surface.DrawLine(cx - reach * 0.35, cy - reach, cx + reach * 0.65, cy)
                surface.DrawLine(cx + reach * 0.65, cy, cx - reach * 0.35, cy + reach)
            end
        end

        button.OnCursorEntered = function() if IsValid(self) then self:hoverSound() end end
        button.DoClick = function()
            local chars = self.availableCharacters or {}
            if not self.isLoadMode or self.panelsTransitioning or #chars < 2 then return end
            if self.nextArrowInput and RealTime() < self.nextArrowInput then return end
            self.nextArrowInput = RealTime() + 0.14
            self._loadSwapDir = direction
            self.currentIndex = (self.currentIndex or 1) + direction
            if self.currentIndex < 1 then self.currentIndex = #chars end
            if self.currentIndex > #chars then self.currentIndex = 1 end
            self:clickSound()
            self:updateSelectedCharacter()
        end
        return button
    end

    self.leftArrow = newArrow(-1)
    self.rightArrow = newArrow(1)
end

function PANEL:UpdateLogoPosition()
    if not IsValid(self.logo) then return end
    local pad = ScrH() * 0.03
    local baseSize = math.max(ScrW() * 0.15, 300)
    local logoW, logoH = baseSize * 0.95, baseSize * 0.6 * 0.95
    local left, right, top = math.huge, -math.huge, math.huge
    for _, v in pairs(self.buttons) do
        if IsValid(v) then
            local x, y = v:GetPos()
            left = math.min(left, x)
            right = math.max(right, x + v:GetWide())
            top = math.min(top, y)
        end
    end

    top = top == math.huge and ScrH() * 0.5 or top
    local center = (left + right) * 0.5
    local maxLogoW = math.min(logoW, ScrW() * 0.8)
    local maxLogoH = math.min(logoH, ScrH() * 0.3)
    logoW = maxLogoW
    logoH = maxLogoH
    local logoX = math.max(pad, math.min(center - logoW * 0.5, ScrW() - logoW - pad))
    local logoY = math.max(pad, top - logoH - pad)
    self.logo:SetPos(logoX, logoY)
    self.logo:SetSize(logoW, logoH)
    self.logo:SetKeepAspect(true)
end

function PANEL:showContent(disableBg)
    if IsValid(self.infoFrame) then self.infoFrame:Remove() end
    if IsValid(self.bgLoader) then self.bgLoader:Remove() end
    if IsValid(self.background) then self.background:Remove() end
    if IsValid(self.leftArrow) then
        self.leftArrow:Remove()
        self.leftArrow = nil
    end

    if IsValid(self.rightArrow) then
        self.rightArrow:Remove()
        self.rightArrow = nil
    end

    if IsValid(self.logo) then
        self.logo:Remove()
        self.logo = nil
    end

    for _, b in pairs(self.buttons) do
        if IsValid(b) then b:Remove() end
    end

    self.buttons = {}
    self.disableClientModel = true
    self:removeClientModelModifications()
    if IsValid(self.modelEntity) then self.modelEntity:Remove() end
    if IsValid(self.fadingModelEntity) then self.fadingModelEntity:Remove() end
    self.fadingModelEntity = nil
    self.previewCharacterID = nil
    self.modelTransitionStarted = nil
    self.tabs:Clear()
    self.content:Clear()
    self:createTabs()
    self.noBlur = self.isLoadMode or false
    if self.isLoadMode or not disableBg then self:loadBackground() end
end

function PANEL:removeClientModelModifications()
    hook.Remove("PrePlayerDraw", "liaMainMenuPrePlayerDraw")
    hook.Remove("CalcView", "liaMainMenuCalcView")
    hook.Remove("PostDrawOpaqueRenderables", "liaMainMenuPostDrawOpaqueRenderables")
    if self.mainMenuRenderHookID then
        hook.Remove("PostDrawOpaqueRenderables", self.mainMenuRenderHookID)
        self.mainMenuRenderHookID = nil
    end
end

function PANEL:setFadeToBlack(fade)
    local d = deferred.new()
    if fade then
        if IsValid(self.fade) then self.fade:Remove() end
        local p = vgui.Create("DPanel")
        p:SetSize(ScrW(), ScrH())
        p:SetSkin("Default")
        p:SetBackgroundColor(color_black)
        p:SetAlpha(0)
        p:AlphaTo(255, 0.5, 0, function() d:resolve() end)
        p:SetZPos(999)
        p:MakePopup()
        self.fade = p
    else
        if IsValid(self.fade) then
            local p = self.fade
            p:AlphaTo(0, 0.5, 0, function()
                p:Remove()
                d:resolve()
            end)
        end
    end
    return d
end

function PANEL:fadeOut()
    self:AlphaTo(0, 0.1, 0, function() self:Remove() end)
end

function PANEL:Paint(w, h)
    self:paintBackground(w, h)
end

function PANEL:paintBackground(w, h)
    if not IsValid(self.background) and self.blank then
        surface.SetDrawColor(42, 42, 42, 179)
        surface.DrawRect(0, 0, w, h)
    end
end

function PANEL:hoverSound()
    LocalPlayer():EmitSound("buttons/button15.wav", 35, 250)
end

function PANEL:clickSound()
    LocalPlayer():EmitSound("buttons/button14.wav", 35, 255)
end

function PANEL:warningSound()
    LocalPlayer():EmitSound("friends/friend_join.wav", 40, 255)
end

function PANEL:Update()
    if IsValid(self) then
        self:Remove()
        local mainMenuModule = lia.module.get("mainmenu")
        if mainMenuModule and isfunction(mainMenuModule.OpenCharacterMenu) then
            mainMenuModule:OpenCharacterMenu()
        else
            vgui.Create("liaCharacter")
        end
    end
end

function PANEL:onCharListUpdated(_, newCharList)
    if not self.isLoadMode then return end
    self.availableCharacters = {}
    for _, charID in ipairs(newCharList or {}) do
        local character = lia.char.getCharacter(charID)
        if character and character:getFaction() ~= FACTION_STAFF then self.availableCharacters[#self.availableCharacters + 1] = charID end
    end

    if self.currentIndex and #self.availableCharacters > 0 then
        self.currentIndex = math.Clamp(self.currentIndex, 1, #self.availableCharacters)
    else
        self.currentIndex = #self.availableCharacters > 0 and 1 or nil
    end

    self:createCharacterSelection()
end

function PANEL:OnRemove()
    if IsValid(self.creator) then
        local creator = self.creator
        self.creator = nil
        creator.sourceMenu = nil
        if not creator.finished then
            creator.returningToMenu = true
            creator:Remove()
        end
    end

    if lia.gui.character == self then lia.gui.character = nil end
    hook.Run("CharMenuClosed")
    self:restoreExternalEntities()
    local client = LocalPlayer()
    if IsValid(client) then client:SetNoDraw(false) end
    hook.Remove("PrePlayerDraw", "liaMainMenuPrePlayerDraw")
    hook.Remove("CalcView", "liaMainMenuCalcView")
    hook.Remove("PostDrawOpaqueRenderables", "liaMainMenuPostDrawOpaqueRenderables")
    if self.mainMenuRenderHookID then
        hook.Remove("PostDrawOpaqueRenderables", self.mainMenuRenderHookID)
        self.mainMenuRenderHookID = nil
    end

    hook.Remove("DrawPhysgunBeam", "liaMainMenuPreDrawPhysgunBeam")
    hook.Remove("RenderScreenspaceEffects", "liaCharMenuDarken")
    if self.charListUpdateHook then hook.Remove("CharListUpdated", self.charListUpdateHook) end
    if self.adminPrivilegesUpdateHook then hook.Remove("AdminPrivilegesUpdated", self.adminPrivilegesUpdateHook) end
    if render.oldDrawBeam then
        render.DrawBeam = render.oldDrawBeam
        render.oldDrawBeam = nil
    end

    local music = lia.menuMusic
    if music then
        lia.menuMusic = nil
        timer.Remove("liaMusicFader")
        local vol = lia.config.get("MusicVolume", 0.25)
        local start = RealTime()
        timer.Create("liaMusicFader", 0.1, 0, function()
            if not music then return timer.Remove("liaMusicFader") end
            local frac = math.max(0, 1 - (RealTime() - start) / 5)
            if music.ChangeVolume then
                music:ChangeVolume(frac * vol, 0.1)
            else
                music:SetVolume(frac * vol)
            end

            if frac <= 0 then
                music:Stop()
                timer.Remove("liaMusicFader")
            end
        end)
    end

    self.loadEntryCamera = nil
    if IsValid(self.modelEntity) then self.modelEntity:Remove() end
    if IsValid(self.fadingModelEntity) then self.fadingModelEntity:Remove() end
end

function PANEL:Think()
    if IsValid(self.logo) then
        self.logo:SetZPos(9999)
        self.logo:MoveToFront()
        self:UpdateLogoPosition()
    end
end

function PANEL:showConfirmation(message, onConfirm, onCancel)
    if IsValid(lia.gui.charConfirm) then lia.gui.charConfirm:Remove() end
    local frame = vgui.Create("liaFrame", self)
    lia.gui.charConfirm = frame
    local pad, btnH = 10, 25
    frame:SetSize(400, 200)
    frame:MakePopup()
    frame:SetTitle("")
    frame:SetCenterTitle(("Are you sure?"):upper())
    frame:ShowCloseButton(false)
    frame:SetDraggable(false)
    local accentColor = lia.color.theme.theme
    local oldPaint = frame.Paint
    frame.Paint = function(s, w, h)
        if oldPaint then oldPaint(s, w, h) end
        surface.SetDrawColor(accentColor)
        surface.DrawRect(0, 0, w, 2)
    end

    local messageLabel = frame:Add("DLabel")
    messageLabel:SetFont("LiliaFont.14")
    messageLabel:SetTextColor(color_white)
    messageLabel:SetWrap(true)
    messageLabel:SetContentAlignment(5)
    local confirmButton = frame:Add("liaButton")
    confirmButton:SetFont("LiliaFont.17")
    confirmButton:SetText(("Yes"):upper())
    confirmButton:SetPaintBackground(false)
    confirmButton:SetContentAlignment(5)
    function confirmButton:OnCursorEntered()
        self.BaseClass.OnCursorEntered(self)
        if IsValid(lia.gui.character) then lia.gui.character:hoverSound() end
    end

    confirmButton.DoClick = function()
        if IsValid(lia.gui.character) then lia.gui.character:clickSound() end
        if isfunction(onConfirm) then onConfirm() end
        frame:Remove()
    end

    local cancelButton = frame:Add("liaButton")
    cancelButton:SetFont("LiliaFont.17")
    cancelButton:SetText(("No"):upper())
    cancelButton:SetPaintBackground(false)
    cancelButton:SetContentAlignment(5)
    function cancelButton:OnCursorEntered()
        self.BaseClass.OnCursorEntered(self)
        if IsValid(lia.gui.character) then lia.gui.character:hoverSound() end
    end

    cancelButton.DoClick = function()
        if IsValid(lia.gui.character) then lia.gui.character:clickSound() end
        if isfunction(onCancel) then onCancel() end
        frame:Remove()
    end

    timer.Simple(0.25, function() if IsValid(lia.gui.character) then lia.gui.character:warningSound() end end)
    timer.Simple(0, function()
        if IsValid(frame) then
            local w, h = frame:GetWide(), frame:GetTall()
            frame:SetPos((ScrW() - w) * 0.5, (ScrH() - h) * 0.5)
        end
    end)

    function frame:PerformLayout(w, h)
        if IsValid(frame.top_panel) then frame.top_panel:SetSize(w, 24) end
        if IsValid(frame.cls) then
            frame.cls:SetSize(20, 20)
            frame.cls:SetPos(w - 22, 2)
        end

        if IsValid(frame.resizer) then
            frame.resizer:SetSize(14, 14)
            frame.resizer:SetPos(w - 14, h - 14)
            frame.resizer:SetVisible(frame.sizable or false)
        end

        local availH = h - 24 - pad * 2 - btnH
        messageLabel:SetSize(w - pad * 2, availH)
        messageLabel:InvalidateLayout(true)
        messageLabel:SizeToContentsY()
        messageLabel:SetPos((w - messageLabel:GetWide()) * 0.5, 24 + pad + (availH - messageLabel:GetTall()) * 0.5)
        local btnW = (w - pad * 3) * 0.5
        confirmButton:SetSize(btnW, btnH)
        confirmButton:SetPos(pad, h - pad - btnH)
        cancelButton:SetSize(btnW, btnH)
        cancelButton:SetPos(pad * 2 + btnW, h - pad - btnH)
    end

    messageLabel:SetText(message:upper())
    frame:InvalidateLayout()
    return frame
end

local MountPanel = {}
function MountPanel:Init()
    self:SetSize(ScrW(), ScrH())
    self:MakePopup()
    self.Paint = function(_, w, h)
        surface.SetDrawColor(0, 0, 0, 210)
        surface.DrawRect(0, 0, w, h)
    end

    self.OnRemove = function()
        if lia.gui.workshopMount == self then lia.gui.workshopMount = nil end
    end

    local width = math.Clamp(ScrW() * 0.62, 760, 1120)
    local height = math.Clamp(ScrH() * 0.74, 520, 760)
    local root = self:Add("DPanel")
    root:SetSize(width, height)
    root.Paint = function(_, w, h) mmDrawPanel(0, 0, w, h, 7, mmSurface(0.02, 246), mmAccent(70)) end
    mmAnimateIn(root, (ScrW() - width) * 0.5, (ScrH() - height) * 0.5, 0, 14, 0.26, 0)
    local bar = root:Add("DPanel")
    bar:Dock(TOP)
    bar:SetTall(46)
    bar.Paint = function(_, w, h)
        draw.SimpleText("WORKSHOP", "LiliaFont.17", 16, h * 0.5, mmText(), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        surface.SetDrawColor(mmAccent(55))
        surface.DrawRect(16, h - 1, w - 32, 1)
    end

    local close = bar:Add("DButton")
    close:SetText("")
    close:SetSize(96, 32)
    close.Paint = function(s, w, h)
        mmPaintBlock(w, h, s:IsHovered())
        draw.SimpleText("CLOSE", "LiliaFont.16", w * 0.5, h * 0.5, mmText(), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    close.PerformLayout = function()
        close:SetPos(bar:GetWide() - 108, 7)
    end

    close.DoClick = function()
        if IsValid(lia.gui.character) then lia.gui.character:clickSound() end
        self:Remove()
    end

    local content = root:Add("DPanel")
    content:Dock(FILL)
    content.Paint = function() end
    lia.workshop.createBrowser(content, {
        mountMode = true,
        collectionURL = lia.config.get("Workshop", ""),
        palette = {
            accent = mmAccent(),
            text = mmText(),
            muted = mmMuted(),
            surface = mmSurface(0.02, 246),
            surfaceAlt = mmSurface(0.055, 244),
            drawPanel = mmDrawPanel
        }
    })
end

function MountPanel:OnKeyCodePressed(key)
    if key == KEY_ESCAPE then self:Remove() end
end

vgui.Register("liaWorkshopMountMenu", MountPanel, "EditablePanel")
vgui.Register("liaCharacter", PANEL, "EditablePanel")
end

do
local MODULE = MODULE
local fallbackAccent = Color(76, 164, 224)
local fallbackText = Color(230, 239, 239)
local fallbackBackground = Color(7, 14, 23)
local fallbackNegative = Color(205, 74, 74)
local attributeOrder = {"agility", "end", "strength"}
local supportedPayloadKeys = {
    faction = true,
    name = true,
    desc = true,
    model = true,
    skin = true,
    bodygroups = true,
    attribs = true,
    class = true
}

local function copyValue(value)
    if istable(value) then return table.Copy(value) end
    return value
end

local function getThemeColor(source, fallback, alpha)
    fallback = IsColor(fallback) and fallback or fallbackText
    source = IsColor(source) and source or fallback
    return Color(source.r, source.g, source.b, alpha or source.a or fallback.a or 255)
end

local function mixThemeColors(from, to, fraction, alpha)
    from = IsColor(from) and from or fallbackBackground
    to = IsColor(to) and to or fallbackText
    fraction = math.Clamp(tonumber(fraction) or 0, 0, 1)
    return Color(math.Round(Lerp(fraction, from.r, to.r)), math.Round(Lerp(fraction, from.g, to.g)), math.Round(Lerp(fraction, from.b, to.b)), alpha or math.Round(Lerp(fraction, from.a or 255, to.a or 255)))
end

local function getActiveThemePalette()
    return lia.color and lia.color.theme or {}
end

local function getThemeAccent(alpha)
    local theme = getActiveThemePalette()
    local source = theme.maincolor or theme.accent or theme.theme
    if not IsColor(source) then source = lia.color.getMainColor() end
    return getThemeColor(source, fallbackAccent, alpha)
end

local function getThemeTextColor(alpha)
    local theme = getActiveThemePalette()
    return getThemeColor(theme.text or theme.foreground, fallbackText, alpha)
end

local function getThemeBackgroundColor(alpha)
    local theme = getActiveThemePalette()
    return getThemeColor(theme.background or theme.panel or theme.window, fallbackBackground, alpha)
end

local function getThemeSurface(strength, alpha)
    return mixThemeColors(getThemeBackgroundColor(255), getThemeTextColor(255), strength or 0.04, alpha)
end

local function getThemeMutedColor(alpha)
    return mixThemeColors(getThemeTextColor(255), getThemeBackgroundColor(255), 0.38, alpha or 190)
end

local function getThemeDisabledColor(alpha)
    return mixThemeColors(getThemeTextColor(255), getThemeBackgroundColor(255), 0.64, alpha or 120)
end

local function getThemeNegativeColor(alpha)
    local theme = getActiveThemePalette()
    local source = theme.negative
    if not IsColor(source) then source = lia.color.calculateNegativeColor(getThemeAccent()) end
    return getThemeColor(source, fallbackNegative, alpha)
end

local function drawPanel(x, y, w, h, radius, background, outline)
    if lia.derma.SHAPE_IOS then
        lia.derma.rect(x, y, w, h):Rad(radius):Color(background):Shape(lia.derma.SHAPE_IOS):Draw()
        if outline then lia.derma.rect(x, y, w, h):Rad(radius):Color(outline):Shape(lia.derma.SHAPE_IOS):Outline(1):Draw() end
        return
    end

    draw.RoundedBox(radius, x, y, w, h, background)
    if outline then
        surface.SetDrawColor(outline)
        surface.DrawOutlinedRect(x, y, w, h, 1)
    end
end

local function bindThemedLabel(label, getter)
    if not IsValid(label) then return end
    label.Think = function(self) if isfunction(getter) then self:SetTextColor(getter()) end end
end

local function makeButton(parent, text, secondary)
    local button = parent:Add("DButton")
    button:SetText("")
    button._text = text
    button._hover = 0
    button.Think = function(self) self._hover = Lerp(FrameTime() * 12, self._hover or 0, self:IsHovered() and self:IsEnabled() and 1 or 0) end
    button.Paint = function(self, w, h)
        local accent = secondary and getThemeNegativeColor() or getThemeAccent()
        local hover = self._hover or 0
        local background = Color(accent.r, accent.g, accent.b, secondary and 16 + hover * 15 or 22 + hover * 26)
        local outline = Color(accent.r, accent.g, accent.b, 70 + hover * 105)
        if not self:IsEnabled() then
            background = getThemeSurface(0.025, 205)
            outline = getThemeMutedColor(45)
        end

        drawPanel(0, 0, w, h, 6, background, outline)
        draw.SimpleText(self._text, "LiliaFont.18", w * 0.5, h * 0.5, self:IsEnabled() and getThemeTextColor() or getThemeDisabledColor(), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    return button
end

local function makeEntry(parent, title, multiline)
    local wrap = parent:Add("DPanel")
    wrap:SetMouseInputEnabled(true)
    wrap:SetKeyboardInputEnabled(true)
    wrap.Paint = function(_, w, h)
        local accent = getThemeAccent()
        drawPanel(0, 0, w, h, 7, getThemeSurface(0.05, 240), Color(accent.r, accent.g, accent.b, 50))
        draw.SimpleText(title, "LiliaFont.16", 13, 10, getThemeMutedColor(), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end

    local entry = wrap:Add("DTextEntry")
    entry:SetMouseInputEnabled(true)
    entry:SetKeyboardInputEnabled(true)
    entry:SetFont(multiline and "LiliaFont.16" or "LiliaFont.18")
    entry:SetTextColor(getThemeTextColor())
    entry:SetCursorColor(getThemeAccent())
    entry:SetHighlightColor(getThemeAccent(100))
    entry:SetDrawBackground(false)
    entry:SetPaintBackground(false)
    entry:SetPaintBorderEnabled(false)
    entry:SetMultiline(multiline == true)
    entry.Think = function(self)
        self:SetTextColor(getThemeTextColor())
        self:SetCursorColor(getThemeAccent())
        self:SetHighlightColor(getThemeAccent(100))
    end

    wrap.PerformLayout = function(_, w, h)
        local entryY = multiline and 32 or 33
        local bottomPadding = multiline and 10 or 11
        entry:SetPos(13, entryY)
        entry:SetSize(w - 26, h - entryY - bottomPadding)
    end
    return wrap, entry
end

local function styleScrollBar(scroll)
    if not IsValid(scroll) or not IsValid(scroll.VBar) then return end
    local bar = scroll.VBar
    bar:SetWide(8)
    bar.Paint = function() end
    bar.btnUp.Paint = function() end
    bar.btnDown.Paint = function() end
    bar.btnGrip.Paint = function(self, w, h) draw.RoundedBox(4, 1, 0, w - 2, h, self:IsHovered() and getThemeAccent(125) or getThemeMutedColor(80)) end
end

local function getCreationDropdownText(combo)
    local value = combo.selected
    if not isstring(value) or value == "" then if isfunction(combo.GetValue) then value = combo:GetValue() end end
    if not isstring(value) or value == "" then if isfunction(combo.GetSelectedText) then value = combo:GetSelectedText() end end
    if not isstring(value) or value == "" then if isfunction(combo.GetText) then value = combo:GetText() end end
    if not isstring(value) or value == "" then value = combo.placeholder or "" end
    return tostring(value)
end

local function paintCreationDropdownField(combo, w, h)
    local accent = getThemeAccent()
    local isOpen = combo.opened or IsValid(combo.Menu) and combo.Menu:IsVisible() or IsValid(combo.menu) and combo.menu:IsVisible()
    local highlighted = combo:IsHovered() or IsValid(combo.btn) and combo.btn:IsHovered() or isOpen
    drawPanel(0, 0, w, h, 6, getThemeSurface(highlighted and 0.065 or 0.05, 242), Color(accent.r, accent.g, accent.b, highlighted and 130 or 55))
    draw.SimpleText(getCreationDropdownText(combo), "LiliaFont.16", 12, h * 0.5, combo:IsEnabled() and getThemeTextColor() or getThemeDisabledColor(), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    local x = w - 18
    local y = math.floor(h * 0.5)
    surface.SetDrawColor(isOpen and accent or getThemeMutedColor())
    if isOpen then
        surface.DrawLine(x - 4, y + 2, x, y - 2)
        surface.DrawLine(x, y - 2, x + 4, y + 2)
    else
        surface.DrawLine(x - 4, y - 2, x, y + 2)
        surface.DrawLine(x, y + 2, x + 4, y - 2)
    end
end

local function collectCreationDropdownOptions(parent, output)
    if not IsValid(parent) then return end
    for _, child in ipairs(parent:GetChildren()) do
        local className = isfunction(child.GetClassName) and string.lower(child:GetClassName() or "") or ""
        if className == "dbutton" or className:find("menuoption", 1, true) then
            output[#output + 1] = child
        elseif child ~= parent.VBar and not className:find("scrollbar", 1, true) then
            collectCreationDropdownOptions(child, output)
        end
    end
end

local function styleCreationDropdownScroll(menu)
    local bar = menu.VBar or isfunction(menu.GetVBar) and menu:GetVBar()
    if not IsValid(bar) then return end
    bar:SetWide(7)
    bar.Paint = function(_, w, h) draw.RoundedBox(0, 0, 0, w, h, getThemeSurface(0.02, 230)) end
    if IsValid(bar.btnUp) then bar.btnUp.Paint = function() end end
    if IsValid(bar.btnDown) then bar.btnDown.Paint = function() end end
    if IsValid(bar.btnGrip) then bar.btnGrip.Paint = function(self, w, h) draw.RoundedBox(2, 2, 0, math.max(w - 4, 1), h, getThemeAccent(self:IsHovered() and 225 or 175)) end end
end

local function styleCreationDropdownMenu(menu, combo)
    if not IsValid(menu) or not IsValid(combo) then return end
    local isLiliaCombo = IsValid(combo.btn) and istable(combo.choices)
    menu.Paint = function(_, w, h)
        local accent = getThemeAccent()
        drawPanel(0, 0, w, h, 5, getThemeSurface(0.025, 253), Color(accent.r, accent.g, accent.b, 93))
    end

    if isfunction(menu.SetMinimumWidth) then menu:SetMinimumWidth(combo:GetWide()) end
    if isfunction(menu.SetMaxHeight) then menu:SetMaxHeight(312) end
    local canvas = isfunction(menu.GetCanvas) and menu:GetCanvas() or menu
    local options = {}
    collectCreationDropdownOptions(canvas, options)
    local choiceIndex = 0
    for _, option in ipairs(options) do
        local label
        if isLiliaCombo then
            repeat
                choiceIndex = choiceIndex + 1
            until not combo.choices[choiceIndex] or not combo.choices[choiceIndex].spacer

            local choice = combo.choices[choiceIndex]
            label = choice and choice.text or ""
            option:DockMargin(6, 2, 6, 0)
        else
            label = isfunction(option.GetText) and option:GetText() or ""
        end

        label = tostring(label or "")
        option:SetTall(25)
        if isfunction(option.SetFont) then option:SetFont("LiliaFont.16") end
        option.Paint = function(self, w, h)
            local accent = getThemeAccent()
            local selected = label == getCreationDropdownText(combo)
            local hovered = self:IsHovered()
            local background = selected and Color(accent.r, accent.g, accent.b, 34) or hovered and Color(accent.r, accent.g, accent.b, 27) or getThemeSurface(0.018, 248)
            local outline = selected and Color(accent.r, accent.g, accent.b, 105) or hovered and Color(accent.r, accent.g, accent.b, 78) or getThemeMutedColor(25)
            drawPanel(0, 0, w, h, 3, background, outline)
            draw.SimpleText(label, "LiliaFont.16", 12, h * 0.5, self:IsEnabled() and getThemeTextColor() or getThemeDisabledColor(), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
    end

    styleCreationDropdownScroll(menu)
    if isLiliaCombo then
        local contentHeight = 12
        for _, choice in ipairs(combo.choices) do
            contentHeight = contentHeight + (choice.spacer and 10 or 27)
        end

        local x, y = combo:LocalToScreen(0, combo:GetTall())
        local spaceBelow = math.max(ScrH() - y - 10, 0)
        local spaceAbove = math.max(y - combo:GetTall() - 10, 0)
        local height = math.min(contentHeight, 312, math.max(spaceBelow, spaceAbove))
        if height > 0 then
            menu:SetSize(combo:GetWide(), height)
            menu:SetPos(x, spaceBelow < height and spaceAbove > spaceBelow and y - height - combo:GetTall() or y)
        end
    end

    if isfunction(menu.InvalidateLayout) then menu:InvalidateLayout(true) end
end

local function styleCreationComboBox(combo)
    if not IsValid(combo) or combo.schemaCreatorDropdownStyled then return end
    if not isfunction(combo.AddChoice) or not isfunction(combo.OpenMenu) then return end
    combo.schemaCreatorDropdownStyled = true
    if isfunction(combo.SetTextColor) then combo:SetTextColor(getThemeTextColor()) end
    if IsValid(combo.btn) and istable(combo.choices) then combo.btn.Paint = function(_, w, h) paintCreationDropdownField(combo, w, h) end end
    local originalOnMenuOpened = combo.OnMenuOpened
    combo.OnMenuOpened = function(self, ...)
        if isfunction(originalOnMenuOpened) then originalOnMenuOpened(self, ...) end
        local menu = self.menu or self.Menu
        if not IsValid(menu) then
            local candidate = select(1, ...)
            if IsValid(candidate) then menu = candidate end
        end

        if IsValid(menu) then styleCreationDropdownMenu(menu, self) end
    end

    local originalOpenMenu = combo.OpenMenu
    combo.OpenMenu = function(self, ...)
        local results = {originalOpenMenu(self, ...)}
        local menu = self.menu or self.Menu
        if IsValid(menu) then styleCreationDropdownMenu(menu, self) end
        return unpack(results)
    end
end

local function styleCreationComboBoxes(root)
    if not IsValid(root) then return end
    styleCreationComboBox(root)
    for _, child in ipairs(root:GetChildren()) do
        styleCreationComboBoxes(child)
    end
end

MODULE.StyleCreationComboBox = styleCreationComboBox
local idleSequences = {"idle_all_01", "idle_all_02", "idle_subtle", "idle_unarmed", "idle01", "idle"}
local function getIdleSequence(entity)
    if not IsValid(entity) then return nil end
    for _, name in ipairs(idleSequences) do
        local sequence = entity:LookupSequence(name)
        if sequence and sequence >= 0 then return sequence end
    end

    local sequence = entity:SelectWeightedSequence(ACT_IDLE)
    if sequence and sequence >= 0 then return sequence end
end

local function applyIdleSequence(entity)
    if not IsValid(entity) then return end
    local sequence = getIdleSequence(entity)
    if not sequence then return end
    entity:ResetSequence(sequence)
    entity:SetCycle(0)
    entity:SetPlaybackRate(1)
    if entity.SetIK then entity:SetIK(true) end
    for _, parameter in ipairs({"move_x", "move_y", "move_yaw", "body_yaw", "body_pitch"}) do
        entity:SetPoseParameter(parameter, 0)
    end

    entity:InvalidateBoneCache()
    entity:SetupBones()
end

local function getFactionByIndex(index)
    if not index then return nil end
    return lia.faction.indices and lia.faction.indices[index] or lia.faction.get(index)
end

local function getAvailableFactions()
    local output = {}
    for _, faction in pairs(lia.faction.teams or {}) do
        if faction.index == FACTION_STAFF or faction.uniqueID == "staff" then continue end
        if not lia.faction.hasWhitelist(faction.index) then continue end
        output[#output + 1] = faction
    end

    table.sort(output, function(a, b) return tostring(a.name or "") < tostring(b.name or "") end)
    return output
end

local function getDefaultCreationClasses(faction)
    local output = {}
    if not faction or not lia.class or not lia.class.list then return output end
    for _, class in pairs(lia.class.list) do
        if class and class.faction == faction.index and class.isDefault then output[#output + 1] = class end
    end

    table.sort(output, function(a, b)
        local aName = tostring(a.name or a.uniqueID or a.index or "")
        local bName = tostring(b.name or b.uniqueID or b.index or "")
        if aName == bName then return (tonumber(a.index) or 0) < (tonumber(b.index) or 0) end
        return aName < bName
    end)
    return output
end

local function isDefaultCreationClass(faction, classIndex)
    classIndex = tonumber(classIndex)
    if not faction or not classIndex then return false end
    for _, class in ipairs(getDefaultCreationClasses(faction)) do
        if tonumber(class.index) == classIndex then return true, class end
    end
    return false
end

local function resetCreationClassForFaction(context, faction)
    local classes = getDefaultCreationClasses(faction)
    if #classes == 1 then
        context.class = classes[1].index
    else
        context.class = nil
    end
    return classes
end

local function getCreationClass(faction, context)
    if not faction then return nil end
    return lia.faction.getCharacterCreationClass(faction, context.class)
end

local function normalizeCreationModelChoices(source)
    if istable(source) then return source end
    if isstring(source) and source ~= "" then
        return {
            [1] = source
        }
    end
    return {}
end

local function getCreationModelChoices(faction, context)
    if not faction then return {}, false end
    local class = getCreationClass(faction, context)
    if class then
        if class.model ~= nil then return normalizeCreationModelChoices(class.model), true end
        if class.models ~= nil then return normalizeCreationModelChoices(class.models), false end
    end

    if faction.model ~= nil then return normalizeCreationModelChoices(faction.model), true end
    if faction.models ~= nil then return normalizeCreationModelChoices(faction.models), false end
    local choices, _, forced = lia.faction.getCharacterCreationModelChoices(faction, class)
    return normalizeCreationModelChoices(choices), forced == true
end

local function getFilteredModels(faction, context)
    if not faction then return {}, false end
    local choices, forced = getCreationModelChoices(faction, context)
    local output = {}
    local seen = {}
    local function addModel(key, raw, respectFilter)
        local parsed = lia.faction.getModelData(key, raw)
        if not parsed or not isstring(parsed.model) or parsed.model == "" then return end
        if seen[tostring(key) .. "|" .. parsed.model] then return end
        if respectFilter and not lia.faction.isModelUsable(parsed.model) then return end
        if respectFilter and hook.Run("FilterCharModels", LocalPlayer(), faction, raw, key) == false then return end
        seen[tostring(key) .. "|" .. parsed.model] = true
        output[#output + 1] = {
            key = key,
            raw = raw,
            parsed = parsed
        }
    end

    for key, raw in pairs(choices) do
        addModel(key, raw, true)
    end

    if #output == 0 then
        local fallbackChoices = normalizeCreationModelChoices(faction.models ~= nil and faction.models or faction.model)
        if table.Count(fallbackChoices) == 0 then fallbackChoices = choices end
        for key, raw in pairs(fallbackChoices) do
            addModel(key, raw, false)
        end
    end

    table.sort(output, function(a, b)
        if isnumber(a.key) and isnumber(b.key) then return a.key < b.key end
        return tostring(a.key) < tostring(b.key)
    end)
    return output, forced
end

local function resolveBodygroups(modelPath, bodygroups)
    if istable(bodygroups) then return table.Copy(bodygroups) end
    local output = {}
    if not isstring(bodygroups) or bodygroups == "" then return output end
    local entity = ClientsideModel(modelPath, RENDERGROUP_OTHER)
    if IsValid(entity) then
        local resolved = lia.util.resolveBodygroups(entity, bodygroups)
        if istable(resolved) then output = resolved end

        entity:Remove()
    end
    return output
end

local function getSelectedModelData(context)
    local faction = getFactionByIndex(context.faction)
    if not faction then return nil, nil, nil end
    local choices = getCreationModelChoices(faction, context)
    local selectedKey = context.model
    local raw = selectedKey ~= nil and choices[selectedKey] or nil
    if raw == nil then selectedKey, raw = next(choices) end

    if raw == nil then return faction, nil, nil end
    local parsed = lia.faction.getModelData(selectedKey, raw)
    return faction, raw, parsed
end

local function setDefaultAppearance(context, modelKey, parsed)
    context.model = modelKey
    context.skin = math.max(tonumber(parsed and parsed.skin) or 0, 0)
    context.bodygroups = parsed and resolveBodygroups(parsed.model, parsed.bodygroups) or {}
end

local function applyDefaultsForFaction(context, faction)
    local models = getFilteredModels(faction, context)
    local first = models[1]
    if first then
        setDefaultAppearance(context, first.key, first.parsed)
    else
        context.model = nil
        context.skin = 0
        context.bodygroups = {}
    end
end

local function applyIdentityDefaults(context)
    local client = LocalPlayer()
    local defaultName, nameOverride = hook.Run("GetDefaultCharName", client, context.faction, context)
    if isstring(defaultName) and nameOverride ~= false then
        local current = string.Trim(tostring(context.name or ""))
        if current == "" or nameOverride == true then context.name = defaultName end
    end

    if hook.Run("ShouldShowCharVarInCreation", "desc") ~= false and lia.char.vars.desc then
        local current = string.Trim(tostring(context.desc or ""))
        if current == "" then context.desc = copyValue(lia.char.vars.desc.default) end
    end

    if hook.Run("ShouldShowCharVarInCreation", "name") == false and lia.char.vars.name then context.name = copyValue(lia.char.vars.name.default) end
    if hook.Run("ShouldShowCharVarInCreation", "desc") == false and lia.char.vars.desc then context.desc = copyValue(lia.char.vars.desc.default) end
end

local function visibleTabs(creator)
    local output = {}
    local client = LocalPlayer()
    for _, tab in ipairs(MODULE:GetCreationTabs()) do
        local allowed = not tab.shouldShow or tab.shouldShow(client, creator.context, creator) ~= false
        if allowed and hook.Run("CanShowCharacterCreationTab", tab.id, client, creator.context, creator) ~= false then output[#output + 1] = tab end
    end
    return output
end

local function getDataLogo(data)
    if not data then return nil end
    local source = data.logo or data.icon or data.image
    if type(source) == "IMaterial" then return source end
    if isstring(source) and source ~= "" then
        local material = Material(source, "smooth")
        if material and not material:IsError() then return material end
    end
    return nil
end

local function getFactionLogo(faction)
    return getDataLogo(faction)
end

local function getClassLogo(class, faction)
    return getDataLogo(class) or getFactionLogo(faction)
end

local function humanizeWords(value)
    value = string.Trim(tostring(value or ""))
    if value == "" then return "" end
    local output = {}
    for word in value:gmatch("[^%s]+") do
        local upperWord = string.upper(word)
        if #word <= 3 and word == upperWord then
            output[#output + 1] = upperWord
        else
            output[#output + 1] = string.upper(word:sub(1, 1)) .. string.lower(word:sub(2))
        end
    end
    return table.concat(output, " ")
end

local function getModelBaseName(modelPath)
    local clean = tostring(modelPath or ""):gsub("\\", "/")
    local base = clean:match("([^/]+)$") or clean
    return base
end

local function getModelDisplayTitle(modelData)
    if not modelData then return "Unknown Model" end
    local parsed = modelData.parsed or {}
    local raw = modelData.raw
    local candidates = {parsed.name, parsed.displayName, parsed.title, parsed.label, istable(raw) and raw.name or nil, istable(raw) and raw.displayName or nil, istable(raw) and raw.title or nil, istable(raw) and raw.label or nil, getModelBaseName(parsed.model)}
    for _, candidate in ipairs(candidates) do
        if isstring(candidate) and string.Trim(candidate) ~= "" then
            local textValue = candidate
            if textValue:find("/") or textValue:find("\\") then textValue = getModelBaseName(textValue) end
            textValue = textValue:gsub("%.mdl$", "")
            textValue = textValue:gsub("[_%-]+", " ")
            textValue = textValue:gsub("%s+", " ")
            return humanizeWords(textValue)
        end
    end
    return "Unknown Model"
end

local function getModelDisplaySubtitle(modelData)
    if not modelData or not modelData.parsed then return "" end
    return getModelBaseName(modelData.parsed.model or "")
end

local function getModelCategory(modelData)
    if not modelData then return "Other" end
    local parsed = modelData.parsed or {}
    local raw = modelData.raw
    local direct = parsed.category or parsed.group or parsed.family or parsed.type or istable(raw) and (raw.category or raw.group or raw.family or raw.type) or nil
    if isstring(direct) and string.Trim(direct) ~= "" then return humanizeWords(direct:gsub("[_%-]+", " ")) end
    local title = string.lower(getModelDisplayTitle(modelData))
    local subtitle = string.lower(getModelDisplaySubtitle(modelData))
    local combined = title .. " " .. subtitle
    local rules = {{"combine", "Combine"}, {"metropolice", "Combine"}, {"overwatch", "Combine"}, {"civil protection", "Combine"}, {"medic", "Utility"}, {"scanner", "Utility"}, {"turret", "Utility"}, {"barney", "Citizens"}, {"rebel", "Citizens"}, {"refugee", "Citizens"}, {"citizen", "Citizens"}, {"worker", "Citizens"}, {"prison", "Security"}, {"guard", "Security"}}
    for _, rule in ipairs(rules) do
        if combined:find(rule[1], 1, true) then return rule[2] end
    end

    local firstWord = getModelDisplayTitle(modelData):match("^([^%s]+)")
    if isstring(firstWord) and firstWord ~= "" then return humanizeWords(firstWord) end
    return "Other"
end

local function matchesModelSearch(modelData, query)
    query = string.Trim(string.lower(tostring(query or "")))
    if query == "" then return true end
    local searchHaystack = string.lower(table.concat({tostring(getModelDisplayTitle(modelData) or ""), tostring(getModelDisplaySubtitle(modelData) or ""), tostring(modelData and modelData.parsed and modelData.parsed.model or ""), tostring(getModelCategory(modelData) or "")}, " "))
    return searchHaystack:find(query, 1, true) ~= nil
end

local function getCreatorPaperMetrics()
    local screenWidth = ScrW()
    local screenHeight = ScrH()
    local maximumPaperWidth = math.max(screenWidth - 48, 620)
    local paperMaximum = math.min(1280, maximumPaperWidth)
    local paperMinimum = math.min(880, paperMaximum)
    local paperWidth = math.Clamp(math.floor(screenWidth * 0.6), paperMinimum, paperMaximum)
    local paperHeight = math.Clamp(math.floor(screenHeight * 0.9), math.min(680, screenHeight - 30), screenHeight - 30)
    local marginRight = math.Clamp(math.floor(screenWidth * 0.03), 24, 64)
    return screenWidth - paperWidth - marginRight, math.floor((screenHeight - paperHeight) * 0.5), paperWidth, paperHeight
end

local PANEL = {}
function PANEL:Init()
    if IsValid(lia.gui.schemaCharacterCreator) and lia.gui.schemaCharacterCreator ~= self then lia.gui.schemaCharacterCreator:Remove() end
    lia.gui.schemaCharacterCreator = self
    self:SetSize(ScrW(), ScrH())
    self:SetAlpha(0)
    self:AlphaTo(255, 0.2, 0)
    self:SetMouseInputEnabled(false)
    self:SetKeyboardInputEnabled(false)
    self.context = {
        attribs = {},
        skin = 0,
        bodygroups = {}
    }

    MODULE.creationContext = self.context
    self.creating = false
    self.finished = false
    self.currentIndex = 0
    self.completedTabs = {}
    self.hookID = "liaSchemaCharacterCreator" .. tostring(self):gsub("[^%w]", "")
    local factions = getAvailableFactions()
    if factions[1] then
        self.context.faction = factions[1].index
        resetCreationClassForFaction(self.context, factions[1])
        applyDefaultsForFaction(self.context, factions[1])
        applyIdentityDefaults(self.context)
    end

    MODULE:RefreshCreationTabs()
    self.tabs = visibleTabs(self)
    self.inputWindow = vgui.Create("DFrame")
    self.inputWindow:SetPos(0, 0)
    self.inputWindow:SetSize(ScrW(), ScrH())
    self.inputWindow:SetTitle("")
    self.inputWindow:ShowCloseButton(false)
    self.inputWindow:SetDraggable(false)
    self.inputWindow:SetSizable(false)
    self.inputWindow:SetDeleteOnClose(false)
    self.inputWindow:SetPaintShadow(false)
    self.inputWindow:SetMouseInputEnabled(true)
    self.inputWindow:SetKeyboardInputEnabled(true)
    self.inputWindow.Paint = function() end
    self.inputWindow:MakePopup()
    self.inputWindow:SetZPos(32767)
    self.inputWindow:MoveToFront()
    self.inputWindow:RequestFocus()
    self.inputWindow.OnKeyCodePressed = function(_, key) if IsValid(self) then self:OnKeyCodePressed(key) end end
    self.paper = self.inputWindow:Add("DPanel")
    self.paper:SetMouseInputEnabled(true)
    self.paper:SetKeyboardInputEnabled(true)
    self.paper.Paint = function(_, w, h)
        local accent = getThemeAccent()
        drawPanel(0, 0, w, h, 10, getThemeSurface(0.025, 238), Color(accent.r, accent.g, accent.b, 92))
        surface.SetDrawColor(accent.r, accent.g, accent.b, 190)
        surface.DrawRect(0, 0, w, 2)
        surface.DrawRect(0, h - 2, w, 2)
    end

    self.page = self.paper:Add("DPanel")
    self.page:SetPaintBackground(false)
    self.page:SetMouseInputEnabled(true)
    self.page:SetKeyboardInputEnabled(true)
    self:BuildInterface()
    self:SetupWorldScene()
    if factions[1] then self:RefreshWorldModel(false) end
    self:ShowTab(1, true)
end

function PANEL:SetCreationContext(key, value)
    self.context[key] = value
    MODULE.creationContext = self.context
end

function PANEL:GetCreationContext(key)
    if key ~= nil then return self.context[key] end
    return self.context
end

function PANEL:BuildInterface()
    self.header = self.page:Add("DPanel")
    self.header.Paint = function(_, w, h)
        local accent = getThemeAccent()
        local faction = getFactionByIndex(self.context.faction)
        local active = self.tabs[self.currentIndex]
        draw.SimpleText("CUSTOMIZE", "LiliaFont.30", 0, 0, getThemeTextColor(), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText((faction and faction.name or "Character") .. "  /  " .. (active and active.name or "Creation"), "LiliaFont.16", 0, 34, getThemeMutedColor(), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        surface.SetDrawColor(accent.r, accent.g, accent.b, 165)
        surface.DrawRect(0, h - 1, w, 1)
    end

    self.tabNavigation = self.page:Add("DPanel")
    self.tabNavigation:SetMouseInputEnabled(true)
    self.tabNavigation.Paint = function(_, w, h)
        local accent = getThemeAccent()
        drawPanel(0, 0, w, h, 8, getThemeSurface(0.025, 222), Color(accent.r, accent.g, accent.b, 55))
    end

    self.stage = self.page:Add("DPanel")
    self.stage:SetMouseInputEnabled(true)
    self.stage:SetKeyboardInputEnabled(true)
    self.stage.Paint = function(_, w, h)
        local accent = getThemeAccent()
        drawPanel(0, 0, w, h, 8, getThemeSurface(0.025, 230), Color(accent.r, accent.g, accent.b, 55))
    end

    self.errorPanel = self.page:Add("DPanel")
    self.errorPanel:SetVisible(false)
    self.errorPanel.Paint = function(_, w, h)
        local negative = getThemeNegativeColor()
        drawPanel(0, 0, w, h, 6, Color(negative.r, negative.g, negative.b, 18), Color(negative.r, negative.g, negative.b, 90))
    end

    self.errorLabel = self.errorPanel:Add("DLabel")
    self.errorLabel:SetFont("LiliaFont.16")
    self.errorLabel:SetTextColor(getThemeNegativeColor())
    self.errorLabel:SetContentAlignment(5)
    self.errorLabel:SetWrap(true)
    bindThemedLabel(self.errorLabel, function() return getThemeNegativeColor() end)
    self.backButton = makeButton(self.page, "BACK", true)
    self.backButton:SetZPos(50)
    self.backButton.DoClick = function() self:Previous() end
    self.mainMenuButton = makeButton(self.page, "MAIN MENU", true)
    self.mainMenuButton:SetZPos(50)
    self.mainMenuButton.DoClick = function() if not self.creating then self:ReturnToMainMenu() end end
    self.nextButton = makeButton(self.page, "NEXT")
    self.nextButton:SetZPos(50)
    self.nextButton.DoClick = function() self:Next() end
    self:BuildTabNavigation()
end

function PANEL:RefreshVisibleTabs(preferredTabID)
    local current = self.tabs and self.tabs[self.currentIndex] or nil
    local targetID = preferredTabID or current and current.id or nil
    MODULE:RefreshCreationTabs()
    self.tabs = visibleTabs(self)
    local targetIndex = 1
    if targetID then
        for index, tab in ipairs(self.tabs) do
            if tab.id == targetID then
                targetIndex = index
                break
            end
        end
    end

    self.currentIndex = math.Clamp(targetIndex, 1, math.max(#self.tabs, 1))
    if IsValid(self.tabNavigation) then self:BuildTabNavigation() end
    return self.currentIndex
end

function PANEL:BuildTabNavigation()
    self.tabNavigation:Clear()
    self.tabButtons = {}
    for index, tab in ipairs(self.tabs) do
        local tabIndex = index
        local button = self.tabNavigation:Add("DButton")
        button:SetText("")
        button._hover = 0
        button.Think = function(panel) panel._hover = Lerp(FrameTime() * 12, panel._hover or 0, panel:IsHovered() and 1 or 0) end
        button.Paint = function(panel, w, h)
            local active = self.currentIndex == tabIndex
            local complete = self:IsTabComplete(tab)
            local accent = getThemeAccent()
            local hover = panel._hover or 0
            drawPanel(0, 0, w, h, 6, active and Color(accent.r, accent.g, accent.b, 30) or getThemeSurface(0.05, 225), Color(accent.r, accent.g, accent.b, active and 190 or 45 + hover * 75))
            if active then
                surface.SetDrawColor(accent.r, accent.g, accent.b, 230)
                surface.DrawRect(0, 0, 4, h)
            end

            draw.SimpleText(string.format("%02d", tabIndex), "LiliaFont.16", 14, 12, active and accent or getThemeMutedColor(), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            draw.SimpleText(string.upper(tab.name), "LiliaFont.18", 14, 34, getThemeTextColor(), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            local badgeText
            local badgeColor
            if active then
                badgeText = complete and "ACTIVE" or "NOT READY"
                badgeColor = complete and accent or getThemeNegativeColor()
            elseif complete then
                badgeText = "READY"
                badgeColor = accent
            end

            if badgeText then
                local badgeWidth = badgeText == "NOT READY" and 78 or badgeText == "ACTIVE" and 58 or 54
                drawPanel(w - badgeWidth - 10, 9, badgeWidth, 22, 4, Color(badgeColor.r, badgeColor.g, badgeColor.b, 24), Color(badgeColor.r, badgeColor.g, badgeColor.b, 82))
                draw.SimpleText(badgeText, "LiliaFont.15", w - badgeWidth * 0.5 - 10, 20, badgeColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        end

        button.DoClick = function() self:RequestTab(tabIndex) end
        self.tabButtons[#self.tabButtons + 1] = button
    end

    self:InvalidateLayout(true)
end

function PANEL:IsTabComplete(tab)
    if not tab then return false end
    if self.completedTabs[tab.id] then return true end
    if tab.id == "review" then
        for _, candidate in ipairs(self.tabs) do
            if candidate.id ~= "review" and not self.completedTabs[candidate.id] then return false end
        end
        return true
    end
    return false
end

function PANEL:ShowError(message)
    message = string.Trim(tostring(message or ""))
    self.errorLabel:SetText(message)
    self.errorPanel:SetVisible(message ~= "")
    self:InvalidateLayout(true)
end

function PANEL:ValidateTab(tab)
    if not tab then return false, "This creation step is unavailable." end
    if self.tabs[self.currentIndex] == tab and IsValid(self.activeTabPanel) and isfunction(self.activeTabPanel.SyncContext) then self.activeTabPanel:SyncContext() end
    if tab.onValidate then
        local ok, reason = tab.onValidate(self.context, self)
        if ok == false then return false, reason end
    end

    local hookOK, hookReason = hook.Run("ValidateCharacterCreationTab", tab.id, self.context, self)
    if hookOK == false then return false, hookReason end
    return true
end

function PANEL:RefreshActiveTabValidation()
    local tab = self.tabs[self.currentIndex]
    if not tab then return end
    local complete = self:ValidateTab(tab)
    self.completedTabs[tab.id] = complete == true or nil
    if complete == true and IsValid(self.errorPanel) and self.errorPanel:IsVisible() then self:ShowError("") end
end

function PANEL:RequestTab(index)
    index = math.Clamp(index, 1, #self.tabs)
    if index > self.currentIndex then
        local current = self.tabs[self.currentIndex]
        local ok, reason = self:ValidateTab(current)
        if not ok then
            self.completedTabs[current.id] = nil
            self:BuildTabNavigation()
            self:ShowError(reason or "Please complete this section.")
            return
        end

        self.completedTabs[current.id] = true
    end

    self:ShowTab(index)
end

function PANEL:GetCameraModeForTab(tab)
    if not tab then return "appearance" end
    return "appearance"
end

function PANEL:ShowTab(index, immediate)
    if #self.tabs == 0 then return end
    index = math.Clamp(index, 1, #self.tabs)
    local oldTab = self.tabs[self.currentIndex]
    if oldTab and IsValid(self.activeTabPanel) and oldTab.onLeave then oldTab.onLeave(self.activeTabPanel, self.context, self) end
    if IsValid(self.activeTabPanel) then
        self.activeTabPanel:Stop()
        self.activeTabPanel:Remove()
    end

    self.currentIndex = index
    local tab = self.tabs[index]
    self.activeTabPanel = tab.onCreate(self.stage, self.context, self)
    if not IsValid(self.activeTabPanel) then self.activeTabPanel = self.stage:Add("DPanel") end
    self.activeTabPanel:SetPos(18, 18)
    self.activeTabPanel:SetAlpha(immediate and 255 or 0)
    if not immediate then self.activeTabPanel:AlphaTo(255, 0.16, 0) end
    hook.Run("CharacterCreationTabCreated", tab.id, self.activeTabPanel, self.context, self)
    if tab.onEnter then tab.onEnter(self.activeTabPanel, self.context, self) end
    hook.Run("CharacterCreationTabChanged", oldTab and oldTab.id or nil, tab.id, self.context, self)
    styleCreationComboBoxes(self.activeTabPanel)
    local complete = self:ValidateTab(tab)
    self.completedTabs[tab.id] = complete == true or nil
    self.backButton:SetVisible(index > 1)
    self.backButton._text = "BACK"
    self.mainMenuButton:SetVisible(true)
    self.nextButton._text = index == #self.tabs and "CREATE CHARACTER" or "NEXT"
    self.nextButton:SetEnabled(not self.creating)
    self:ShowError("")
    self:BuildTabNavigation()
    self:TransitionCamera(self:GetCameraModeForTab(tab), immediate and 0 or 0.65)
    self:InvalidateLayout(true)
end

function PANEL:Previous()
    if self.creating or self.currentIndex <= 1 then return end
    self:ShowTab(self.currentIndex - 1)
end

function PANEL:Next()
    if self.creating then return end
    if self.createdCharacterID then
        self:LoadCreatedCharacter()
        return
    end

    local tab = self.tabs[self.currentIndex]
    local ok, reason = self:ValidateTab(tab)
    if not ok then
        self.completedTabs[tab.id] = nil
        self:BuildTabNavigation()
        self:ShowError(reason or "Please complete this section.")
        return
    end

    self.completedTabs[tab.id] = true
    if self.currentIndex < #self.tabs then
        self:ShowTab(self.currentIndex + 1)
        return
    end

    for index, candidate in ipairs(self.tabs) do
        local valid, message = self:ValidateTab(candidate)
        if not valid then
            self.completedTabs[candidate.id] = nil
            self:ShowTab(index)
            self:ShowError(message or "Please complete this section.")
            return
        end

        self.completedTabs[candidate.id] = true
    end

    self:CreateCharacter()
end

function PANEL:BuildSummary()
    local summary = {}
    for _, tab in ipairs(self.tabs) do
        local startIndex = #summary + 1
        if tab.onBuildSummary then tab.onBuildSummary(self.context, summary, self) end
        for index = startIndex, #summary do
            local item = summary[index]
            if istable(item) then
                item.header = item.header or tab.reviewHeader or tab.name
                item.section = item.section or tab.id
            end
        end
    end

    hook.Run("BuildCharacterCreationSummary", self.context, summary, self)
    return summary
end

function PANEL:BuildPayload()
    local payload = {}
    for key in pairs(supportedPayloadKeys) do
        if lia.char.vars[key] and self.context[key] ~= nil then payload[key] = copyValue(self.context[key]) end
    end

    for _, tab in ipairs(self.tabs) do
        if tab.onBuildPayload then tab.onBuildPayload(payload, self.context, self) end
    end

    hook.Run("BuildCharacterCreationPayload", payload, self.context, self)
    for key in pairs(payload) do
        if not lia.char.vars[key] then payload[key] = nil end
    end

    if isstring(payload.name) then payload.name = string.Trim(payload.name) end
    if isstring(payload.desc) then payload.desc = string.Trim(payload.desc) end
    if payload.skin ~= nil then payload.skin = math.max(math.floor(tonumber(payload.skin) or 0), 0) end
    if istable(payload.bodygroups) then
        local bodygroups = {}
        for key, value in pairs(payload.bodygroups) do
            local group = tonumber(key)
            local selected = tonumber(value)
            if group and selected then bodygroups[group] = math.max(math.floor(selected), 0) end
        end

        payload.bodygroups = bodygroups
    end

    if istable(payload.attribs) then
        local attribs = {}
        for _, key in ipairs(attributeOrder) do
            attribs[key] = math.max(math.floor(tonumber(payload.attribs[key]) or 0), 0)
        end

        payload.attribs = attribs
    end
    return payload
end

function PANEL:LoadCreatedCharacter()
    if self.creating or not self.createdCharacterID then return end
    self.creating = true
    self.nextButton:SetEnabled(false)
    self.backButton:SetEnabled(false)
    self:ShowError("")
    lia.module.get("mainmenu"):ChooseCharacter(self.createdCharacterID):next(function()
        if not IsValid(self) then return end
        self.finished = true
        if IsValid(self.sourceMenu) then self.sourceMenu:Remove() end
        self:Remove()
    end):catch(function(err)
        if not IsValid(self) then return end
        self.creating = false
        self.nextButton:SetEnabled(true)
        self.nextButton._text = "LOAD CHARACTER"
        self:ShowError(err or "Character created, but it could not be loaded. Try loading it again.")
    end)
end

function PANEL:CreateCharacter()
    if self.creating then return end
    if self.createdCharacterID then
        self:LoadCreatedCharacter()
        return
    end

    self.creating = true
    self.nextButton:SetEnabled(false)
    self.backButton:SetEnabled(false)
    self:ShowError("")
    local payload = self:BuildPayload()
    local mainmenu = lia.module.get("mainmenu")
    mainmenu:CreateCharacter(payload):next(function(characterID)
        if not IsValid(self) then return end
        self.createdCharacterID = characterID
        hook.Run("CharacterCreationFinished", characterID, self.context, self)
        self.creating = false
        self:LoadCreatedCharacter()
    end):catch(function(err)
        if not IsValid(self) then return end
        self.creating = false
        self.nextButton:SetEnabled(true)
        self.backButton:SetEnabled(true)
        self:ShowError(err or "The server rejected this character.")
    end)
end

function PANEL:SetSourceMenu(menu)
    self.sourceMenu = menu
end

function PANEL:ReturnToMainMenu()
    if self.creating then return end
    self.returningToMenu = true
    local sourceMenu = self.sourceMenu
    self.sourceMenu = nil
    self:Remove()
    if IsValid(sourceMenu) and isfunction(sourceMenu.ReturnFromCharacterCreation) then
        sourceMenu:ReturnFromCharacterCreation()
        return
    end

    timer.Simple(0, function()
        local client = LocalPlayer()
        if not IsValid(client) or client:getChar() then return end
        local mainmenu = lia.module.get("mainmenu")
        if mainmenu and isfunction(mainmenu.OpenCharacterMenu) then mainmenu:OpenCharacterMenu() end
    end)
end

function PANEL:GetWorldModelBounds()
    if not IsValid(self.worldEntity) then return nil end
    local mins, maxs = self.worldEntity:GetRenderBounds()
    return mins, maxs
end

function PANEL:FindWorldGround(client, forward)
    local desired = client:GetPos() + forward * 150
    local forwardTrace = util.TraceHull({
        start = client:EyePos(),
        endpos = desired + Vector(0, 0, 52),
        mins = Vector(-18, -18, -18),
        maxs = Vector(18, 18, 18),
        filter = client,
        mask = MASK_SOLID_BRUSHONLY
    })

    if forwardTrace.Hit then desired = forwardTrace.HitPos - forward * 42 end
    local groundTrace = util.TraceLine({
        start = desired + Vector(0, 0, 128),
        endpos = desired - Vector(0, 0, 512),
        filter = client,
        mask = MASK_SOLID_BRUSHONLY
    })
    return groundTrace.Hit and groundTrace.HitPos or desired
end

function PANEL:HideWorldEntities()
    self.hiddenEntities = self.hiddenEntities or {}
    local world = game.GetWorld()
    for _, entity in ipairs(ents.GetAll()) do
        if IsValid(entity) and entity ~= world and entity ~= self.worldEntity then
            if self.hiddenEntities[entity] == nil then self.hiddenEntities[entity] = entity:GetNoDraw() end
            entity:SetNoDraw(true)
        end
    end
end

function PANEL:RestoreWorldEntities()
    for entity, noDraw in pairs(self.hiddenEntities or {}) do
        if IsValid(entity) then entity:SetNoDraw(noDraw == true) end
    end

    self.hiddenEntities = nil
end

function PANEL:DrawWorldPreviewEntity(entity)
    if not IsValid(entity) then return end
    self.worldEntityDrawnFrame = FrameNumber()
    cam.IgnoreZ(false)
    render.SuppressEngineLighting(true)
    render.SetLightingOrigin(entity:GetPos())
    render.ResetModelLighting(0.85, 0.85, 0.85)
    for index = 0, 6 do
        render.SetModelLighting(index, 1, 1, 1)
    end

    entity:DrawModel()
    render.SuppressEngineLighting(false)
    render.ResetModelLighting(1, 1, 1)
end

function PANEL:ApplyWorldAppearance()
    local entity = self.worldEntity
    if not IsValid(entity) then return end
    local skin = math.Clamp(math.floor(tonumber(self.context.skin) or 0), 0, math.max(entity:SkinCount() - 1, 0))
    entity:SetSkin(skin)
    for _, group in ipairs(entity:GetBodyGroups() or {}) do
        entity:SetBodygroup(group.id, 0)
    end

    for key, value in pairs(self.context.bodygroups or {}) do
        local id = tonumber(key)
        if id then entity:SetBodygroup(id, math.Clamp(math.floor(tonumber(value) or 0), 0, math.max(entity:GetBodygroupCount(id) - 1, 0))) end
    end
end

function PANEL:AlignWorldModelToGround()
    if not IsValid(self.worldEntity) then return end
    self.worldEntity:SetAngles(self.worldModelAngle or angle_zero)
    local mins = self:GetWorldModelBounds()
    if not mins then return end
    local base = self.worldGround or LocalPlayer():GetPos()
    self.worldEntity:SetPos(base - Vector(0, 0, mins.z))
    self.worldEntity:InvalidateBoneCache()
    self.worldEntity:SetupBones()
end

function PANEL:PlayIdleAnimation()
    applyIdleSequence(self.worldEntity)
end

function PANEL:RefreshWorldModel(transition)
    local _, _, parsed = getSelectedModelData(self.context)
    if not parsed or not isstring(parsed.model) or parsed.model == "" then return end
    local hadEntity = IsValid(self.worldEntity)
    if hadEntity then self.worldEntity:Remove() end
    util.PrecacheModel(parsed.model)
    self.worldEntity = ClientsideModel(parsed.model, RENDERGROUP_OPAQUE)
    if not IsValid(self.worldEntity) then return end
    self.worldEntity:SetNoDraw(false)
    self.worldEntity:DrawShadow(false)
    self.worldEntity:SetRenderMode(RENDERMODE_NORMAL)
    self.worldEntity:SetColor(color_white)
    self.worldEntity.liaSchemaCharacterCreatorPreview = true
    self.worldEntity.RenderOverride = function(entity) if IsValid(self) then self:DrawWorldPreviewEntity(entity) end end
    self:ApplyWorldAppearance()
    self:PlayIdleAnimation()
    self:AlignWorldModelToGround()
    local mode = self:GetCameraModeForTab(self.tabs[self.currentIndex])
    if transition and hadEntity then
        self:TransitionCamera(mode, 0.45)
    else
        self:RefreshCameraTarget(mode)
    end
end

function PANEL:GetPreviewHeadPosition()
    local entity = self.worldEntity
    if not IsValid(entity) then return nil end
    entity:SetupBones()
    local attachmentIndex = entity:LookupAttachment("eyes")
    if attachmentIndex and attachmentIndex > 0 then
        local attachment = entity:GetAttachment(attachmentIndex)
        if attachment and attachment.Pos then return attachment.Pos end
    end

    for _, boneName in ipairs({"ValveBiped.Bip01_Head1", "ValveBiped.Bip01_Head", "Bip01 Head", "Head"}) do
        local boneIndex = entity:LookupBone(boneName)
        if boneIndex then
            local position = entity:GetBonePosition(boneIndex)
            if position then return position end
        end
    end

    local mins, maxs = self:GetWorldModelBounds()
    if not mins or not maxs then return entity:GetPos() + Vector(0, 0, 64) end
    local height = math.max(maxs.z - mins.z, 48)
    return entity:GetPos() + Vector(0, 0, mins.z + height * 0.82)
end

function PANEL:GetPreviewTargetX()
    local paperX = getCreatorPaperMetrics()
    return math.max(paperX, 1) * 0.5
end

function PANEL:GetCenteredLookOffset(originRight, distance, fov)
    local screenWidth = math.max(ScrW(), 1)
    local screenHeight = math.max(ScrH(), 1)
    local targetFraction = math.Clamp(self:GetPreviewTargetX() / screenWidth, 0.01, 0.49)
    local normalizedX = targetFraction * 2 - 1
    local aspectScale = screenWidth / screenHeight / (4 / 3)
    local horizontalTan = math.tan(math.rad(fov * 0.5)) * aspectScale
    local screenAngle = math.atan(normalizedX * horizontalTan)
    local entityBearing = math.atan(-originRight / math.max(distance, 0.001))
    local cameraBearing = entityBearing - screenAngle
    return originRight + distance * math.tan(cameraBearing)
end

function PANEL:GetCameraPreset(mode)
    local entity = self.worldEntity
    if not IsValid(entity) then return nil end
    local mins, maxs = self:GetWorldModelBounds()
    if not mins or not maxs then return nil end
    local height = math.max(maxs.z - mins.z, 48)
    local base = entity:GetPos()
    if mode == "creation" then
        local fov = 28
        local head = self:GetPreviewHeadPosition() or base + Vector(0, 0, mins.z + height * 0.82)
        local distance = math.Clamp(height * 0.58, 38, 54)
        local originRight = -height * 0.025
        local lookRight = self:GetCenteredLookOffset(originRight, distance, fov)
        local look = head + self.worldRight * lookRight - Vector(0, 0, height * 0.012)
        local origin = head - self.worldForward * distance + self.worldRight * originRight + Vector(0, 0, height * 0.008)
        return origin, look, fov
    end

    if mode == "summary" then
        local fov = 32
        local head = self:GetPreviewHeadPosition() or base + Vector(0, 0, mins.z + height * 0.82)
        local distance = math.Clamp(height * 0.92, 68, 90)
        local originRight = height * 0.245
        local lookRight = self:GetCenteredLookOffset(originRight, distance, fov)
        local anchor = head - Vector(0, 0, height * 0.14)
        local look = anchor + self.worldRight * lookRight
        local origin = anchor - self.worldForward * distance + self.worldRight * originRight + Vector(0, 0, height * 0.04)
        return origin, look, fov
    end

    local fov = 46
    local width = math.max(maxs.x - mins.x, maxs.y - mins.y, 24)
    local center = base + Vector(0, 0, mins.z + height * 0.5)
    local horizontalOffset = height * 0.14
    local distance = math.max(height * 1.9, width * 2.15, 146)
    local originRight = 6 + horizontalOffset
    local lookRight = self:GetCenteredLookOffset(originRight, distance, fov)
    local look = center + self.worldRight * lookRight
    local origin = center - self.worldForward * distance + self.worldRight * originRight + Vector(0, 0, height * 0.1)
    return origin, look, fov
end

function PANEL:RefreshCameraTarget(mode)
    local origin, look, fov = self:GetCameraPreset(mode)
    if not origin then return end
    self.cameraFromOrigin = origin
    self.cameraFromLook = look
    self.cameraFromFOV = fov
    self.cameraToOrigin = origin
    self.cameraToLook = look
    self.cameraToFOV = fov
    self.cameraCurrentOrigin = origin
    self.cameraCurrentLook = look
    self.cameraCurrentFOV = fov
    self.cameraStartTime = CurTime()
    self.cameraDuration = 0
end

function PANEL:TransitionCamera(mode, duration)
    local origin, look, fov = self:GetCameraPreset(mode)
    if not origin then return end
    self.cameraFromOrigin = self.cameraCurrentOrigin or origin
    self.cameraFromLook = self.cameraCurrentLook or look
    self.cameraFromFOV = self.cameraCurrentFOV or fov
    self.cameraToOrigin = origin
    self.cameraToLook = look
    self.cameraToFOV = fov
    self.cameraStartTime = CurTime()
    self.cameraDuration = duration or 0.65
    if self.cameraDuration <= 0 then
        self.cameraCurrentOrigin = origin
        self.cameraCurrentLook = look
        self.cameraCurrentFOV = fov
    end
end

function PANEL:UpdateHeadTracking()
    local entity = self.worldEntity
    if not IsValid(entity) then return end
    local mouseX, mouseY = gui.MousePos()
    local yaw = 0
    local pitch = 0
    if mouseX >= 0 and mouseY >= 0 then
        yaw = math.Clamp((mouseX / ScrW() - 0.35) * 70, -35, 35)
        pitch = math.Clamp((0.48 - mouseY / ScrH()) * 55, -20, 20)
    end

    entity:SetPoseParameter("head_yaw", yaw)
    entity:SetPoseParameter("head_pitch", pitch)
    entity:SetPoseParameter("aim_yaw", yaw * 0.35)
    entity:SetPoseParameter("aim_pitch", pitch * 0.35)
    entity:InvalidateBoneCache()
end

function PANEL:SetupWorldScene()
    local client = LocalPlayer()
    if not IsValid(client) then return end
    local flatAngle = Angle(0, client:EyeAngles().y, 0)
    self.worldForward = flatAngle:Forward()
    self.worldRight = flatAngle:Right()
    self.worldGround = self:FindWorldGround(client, self.worldForward)
    self.worldModelAngle = Angle(0, flatAngle.y + 180, 0)
    self.hiddenEntities = {}
    self:HideWorldEntities()
    hook.Add("CalcView", self.hookID, function()
        if not IsValid(self) or not self.cameraToOrigin or not self.cameraToLook then return end
        local duration = math.max(self.cameraDuration or 0, 0.001)
        local fraction = math.Clamp((CurTime() - (self.cameraStartTime or CurTime())) / duration, 0, 1)
        fraction = fraction * fraction * (3 - 2 * fraction)
        local origin = LerpVector(fraction, self.cameraFromOrigin or self.cameraToOrigin, self.cameraToOrigin)
        local look = LerpVector(fraction, self.cameraFromLook or self.cameraToLook, self.cameraToLook)
        local fov = Lerp(fraction, self.cameraFromFOV or self.cameraToFOV, self.cameraToFOV)
        self.cameraCurrentOrigin = origin
        self.cameraCurrentLook = look
        self.cameraCurrentFOV = fov
        return {
            origin = origin,
            angles = (look - origin):Angle(),
            fov = fov,
            znear = 1,
            zfar = 4096,
            drawviewer = false
        }
    end)

    hook.Add("ShouldDrawLocalPlayer", self.hookID, function() if IsValid(self) then return false end end)
    hook.Add("PrePlayerDraw", self.hookID, function() if IsValid(self) then return true end end)
    hook.Add("HUDShouldDraw", self.hookID, function(name)
        if not IsValid(self) then return end
        if name == "CHudChat" then return true end
        return false
    end)

    hook.Add("PreDrawViewModel", self.hookID, function() if IsValid(self) then return true end end)
    hook.Add("PreDrawPlayerHands", self.hookID, function() if IsValid(self) then return true end end)
    hook.Add("PreDrawEffects", self.hookID, function() if IsValid(self) then return true end end)
    hook.Add("PostDrawOpaqueRenderables", self.hookID, function(drawingDepth, drawingSkybox)
        if drawingDepth or drawingSkybox or not IsValid(self) or not IsValid(self.worldEntity) then return end
        if self.worldEntityDrawnFrame == FrameNumber() then return end
        self:DrawWorldPreviewEntity(self.worldEntity)
    end)
end

function PANEL:PerformLayout()
    if IsValid(self.inputWindow) then
        self.inputWindow:SetPos(0, 0)
        self.inputWindow:SetSize(ScrW(), ScrH())
    end

    if not IsValid(self.paper) then return end
    local paperX, paperY, paperWidth, paperHeight = getCreatorPaperMetrics()
    self.paper:SetPos(paperX, paperY)
    self.paper:SetSize(paperWidth, paperHeight)
    self.page:SetPos(22, 14)
    self.page:SetSize(paperWidth - 44, paperHeight - 28)
    local w, h = self.page:GetSize()
    self.header:SetPos(0, 0)
    self.header:SetSize(w, 62)
    local top = 76
    local bottomHeight = self.errorPanel:IsVisible() and 92 or 54
    local bodyHeight = math.max(h - top - bottomHeight, 1)
    local navWidth = math.Clamp(math.floor(w * 0.2), 170, 220)
    local gap = 14
    self.tabNavigation:SetPos(0, top)
    self.tabNavigation:SetSize(navWidth, bodyHeight)
    local tabGap = 8
    local tabHeight = math.Clamp(math.floor((bodyHeight - 20 - (#self.tabButtons - 1) * tabGap) / math.max(#self.tabButtons, 1)), 70, 86)
    local tabY = 10
    for _, button in ipairs(self.tabButtons or {}) do
        button:SetPos(10, tabY)
        button:SetSize(navWidth - 20, tabHeight)
        tabY = tabY + tabHeight + tabGap
    end

    local stageX = navWidth + gap
    self.stage:SetPos(stageX, top)
    self.stage:SetSize(math.max(w - stageX, 1), bodyHeight)
    if IsValid(self.activeTabPanel) then
        self.activeTabPanel:SetPos(18, 18)
        self.activeTabPanel:SetSize(math.max(self.stage:GetWide() - 36, 1), math.max(self.stage:GetTall() - 36, 1))
        self.activeTabPanel:InvalidateLayout(true)
    end

    local buttonY = h - 40
    if self.errorPanel:IsVisible() then
        self.errorPanel:SetPos(stageX, h - 82)
        self.errorPanel:SetSize(math.max(w - stageX, 1), 32)
        self.errorLabel:SetPos(10, 0)
        self.errorLabel:SetSize(self.errorPanel:GetWide() - 20, 32)
        buttonY = h - 40
    end

    local buttonWidth = math.Clamp(math.floor((w - gap) * 0.22), 130, 200)
    self.backButton:SetPos(0, buttonY)
    self.backButton:SetSize(buttonWidth, 40)
    local mainMenuX = self.currentIndex > 1 and (w - buttonWidth) * 0.5 or 0
    self.mainMenuButton:SetPos(mainMenuX, buttonY)
    self.mainMenuButton:SetSize(buttonWidth, 40)
    self.nextButton:SetPos(w - buttonWidth, buttonY)
    self.nextButton:SetSize(buttonWidth, 40)
end

function PANEL:Think()
    if CurTime() >= (self.nextDropdownStyleCheck or 0) then
        self.nextDropdownStyleCheck = CurTime() + 0.75
        styleCreationComboBoxes(self.activeTabPanel)
    end

    if IsValid(self.inputWindow) then
        self.inputWindow:SetMouseInputEnabled(true)
        self.inputWindow:SetKeyboardInputEnabled(true)
    end

    if CurTime() >= (self.nextEntityHide or 0) then
        self.nextEntityHide = CurTime() + 0.15
        self:HideWorldEntities()
    end

    if IsValid(self.worldEntity) then
        self.worldEntity:SetNoDraw(false)
        self.worldEntity:FrameAdvance(FrameTime())
        self:UpdateHeadTracking()
    end
end

function PANEL:OnKeyCodePressed(key)
    if key == KEY_ESCAPE and not self.creating then self:ReturnToMainMenu() end
end

function PANEL:OnRemove()
    hook.Remove("CalcView", self.hookID)
    hook.Remove("ShouldDrawLocalPlayer", self.hookID)
    hook.Remove("PrePlayerDraw", self.hookID)
    hook.Remove("PreDrawViewModel", self.hookID)
    hook.Remove("PreDrawPlayerHands", self.hookID)
    hook.Remove("PreDrawEffects", self.hookID)
    hook.Remove("HUDShouldDraw", self.hookID)
    hook.Remove("PostDrawOpaqueRenderables", self.hookID)
    self:RestoreWorldEntities()
    if IsValid(self.worldEntity) then self.worldEntity:Remove() end
    if IsValid(self.inputWindow) then self.inputWindow:Remove() end
    if lia.gui.schemaCharacterCreator == self then lia.gui.schemaCharacterCreator = nil end
    if MODULE.creationContext == self.context then MODULE.creationContext = {} end
    if not self.finished and not self.returningToMenu then
        local sourceMenu = self.sourceMenu
        timer.Simple(0, function()
            local client = LocalPlayer()
            if not IsValid(client) or client:getChar() then return end
            if IsValid(sourceMenu) and isfunction(sourceMenu.ReturnFromCharacterCreation) then
                sourceMenu:ReturnFromCharacterCreation()
                return
            end

            local mainmenu = lia.module.get("mainmenu")
            if mainmenu and isfunction(mainmenu.ResetCharacterPanel) then mainmenu:ResetCharacterPanel() end
        end)
    end
end

function PANEL:Paint(w, h)
    local activeTab = self.tabs and self.tabs[self.currentIndex]
    if not activeTab or activeTab.id ~= "appearance" then lia.util.drawBlackBlur(self, 1, 4, 255, 90) end
    surface.SetDrawColor(getThemeBackgroundColor(42))
    surface.DrawRect(0, 0, w, h)
end

vgui.Register("liaSchemaCharacterCreator", PANEL, "EditablePanel")
local function addPageHeading(panel, title, subtitle)
    panel.title = panel:Add("DLabel")
    panel.title:SetFont("LiliaFont.30")
    panel.title:SetText(title)
    panel.title:SetTextColor(getThemeTextColor())
    bindThemedLabel(panel.title, function() return getThemeTextColor() end)
    panel.subtitle = panel:Add("DLabel")
    panel.subtitle:SetFont("LiliaFont.16")
    panel.subtitle:SetText(subtitle)
    panel.subtitle:SetTextColor(getThemeMutedColor())
    panel.subtitle:SetWrap(true)
    bindThemedLabel(panel.subtitle, function() return getThemeMutedColor() end)
end

local function paintSection(_, w, h)
    local accent = getThemeAccent()
    drawPanel(0, 0, w, h, 7, getThemeSurface(0.05, 240), Color(accent.r, accent.g, accent.b, 52))
end

hook.Add("RegisterCharacterCreationTabs", "liaSchemaCharacterCreatorBuiltins", function(tabs)
    tabs["faction"] = {
        name = "Faction",
        order = 10,
        onCreate = function(parent, context, creator)
            local panel = vgui.Create("DPanel", parent)
            panel:SetPaintBackground(false)
            addPageHeading(panel, "FACTION", "Select the faction this character belongs to. Your choice updates the available models and world preview.")
            panel.scroll = panel:Add("DScrollPanel")
            panel.scroll.Paint = function() end
            styleScrollBar(panel.scroll)
            panel.cards = {}
            for _, faction in ipairs(getAvailableFactions()) do
                local card = panel.scroll:Add("DButton")
                card:SetText("")
                card._hover = 0
                card.faction = faction
                card.Think = function(self) self._hover = Lerp(FrameTime() * 12, self._hover or 0, self:IsHovered() and 1 or 0) end
                card.Paint = function(button, w, h)
                    local selected = context.faction == faction.index
                    local accent = IsColor(faction.color) and faction.color or getThemeAccent()
                    drawPanel(0, 0, w, h, 7, selected and Color(accent.r, accent.g, accent.b, 28) or getThemeSurface(0.05, 238), Color(accent.r, accent.g, accent.b, selected and 190 or 48 + (button._hover or 0) * 82))
                    if selected then
                        surface.SetDrawColor(accent.r, accent.g, accent.b, 235)
                        surface.DrawRect(0, 0, 4, h)
                    end

                    local logo = getFactionLogo(faction)
                    local textX = 16
                    if logo then
                        surface.SetMaterial(logo)
                        surface.SetDrawColor(255, 255, 255, 220)
                        surface.DrawTexturedRect(16, 16, 52, 52)
                        textX = 82
                    end

                    draw.SimpleText(faction.name or "Faction", "LiliaFont.22", textX, 16, getThemeTextColor(), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                    local desc = tostring(faction.desc or "No description available.")
                    draw.SimpleText(string.sub(desc:gsub("\n", " "), 1, 84), "LiliaFont.15", textX, 46, getThemeMutedColor(), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                end

                card.DoClick = function()
                    if context.faction == faction.index then return end
                    context.faction = faction.index
                    context.attribs = context.attribs or {}
                    resetCreationClassForFaction(context, faction)
                    applyDefaultsForFaction(context, faction)
                    applyIdentityDefaults(context)
                    creator.completedTabs.faction = nil
                    creator.completedTabs.class = nil
                    creator.completedTabs.identity = nil
                    creator.completedTabs.appearance = nil
                    local factionTabIndex = creator:RefreshVisibleTabs("faction")
                    creator:RefreshWorldModel(true)
                    creator:ShowTab(factionTabIndex, true)
                end

                panel.cards[#panel.cards + 1] = card
            end

            panel.PerformLayout = function(self, w, h)
                self.title:SetPos(0, 0)
                self.title:SetSize(w, 36)
                self.subtitle:SetPos(0, 40)
                self.subtitle:SetSize(w, 42)
                self.scroll:SetPos(0, 92)
                self.scroll:SetSize(w, math.max(h - 92, 1))
                local canvas = self.scroll:GetCanvas()
                local cardW = math.max(self.scroll:GetWide() - 12, 1)
                local y = 0
                for _, card in ipairs(self.cards) do
                    card:SetPos(0, y)
                    card:SetSize(cardW, 86)
                    y = y + 96
                end

                canvas:SetTall(y)
            end
            return panel
        end,
        onValidate = function(context)
            if not context.faction or not getFactionByIndex(context.faction) then return false, "Choose an available faction." end
            return true
        end,
        onBuildSummary = function(context, summary)
            local faction = getFactionByIndex(context.faction)
            if faction then
                summary[#summary + 1] = {
                    title = "Faction",
                    value = faction.name
                }
            end
        end
    }

    tabs["class"] = {
        name = "Class",
        order = 15,
        shouldShow = function(_, context)
            local faction = getFactionByIndex(context.faction)
            return #getDefaultCreationClasses(faction) > 1
        end,
        onCreate = function(parent, context, creator)
            local panel = vgui.Create("DPanel", parent)
            panel:SetPaintBackground(false)
            addPageHeading(panel, "CLASS", "This faction has multiple default classes. Choose which class this character should start as.")
            panel.scroll = panel:Add("DScrollPanel")
            panel.scroll.Paint = function() end
            styleScrollBar(panel.scroll)
            panel.cards = {}
            local faction = getFactionByIndex(context.faction)
            for _, class in ipairs(getDefaultCreationClasses(faction)) do
                local card = panel.scroll:Add("DButton")
                card:SetText("")
                card._hover = 0
                card.class = class
                card.Think = function(self) self._hover = Lerp(FrameTime() * 12, self._hover or 0, self:IsHovered() and 1 or 0) end
                card.Paint = function(button, w, h)
                    local selected = tonumber(context.class) == tonumber(class.index)
                    local accent = IsColor(class.color) and class.color or faction and IsColor(faction.color) and faction.color or getThemeAccent()
                    drawPanel(0, 0, w, h, 7, selected and Color(accent.r, accent.g, accent.b, 28) or getThemeSurface(0.05, 238), Color(accent.r, accent.g, accent.b, selected and 190 or 48 + (button._hover or 0) * 82))
                    if selected then
                        surface.SetDrawColor(accent.r, accent.g, accent.b, 235)
                        surface.DrawRect(0, 0, 4, h)
                    end

                    local logo = getClassLogo(class, faction)
                    local textX = 16
                    if logo then
                        surface.SetMaterial(logo)
                        surface.SetDrawColor(255, 255, 255, 220)
                        surface.DrawTexturedRect(16, 16, 52, 52)
                        textX = 82
                    end

                    draw.SimpleText(tostring(class.name or class.uniqueID or "Class"), "LiliaFont.22", textX, 16, getThemeTextColor(), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                    local desc = tostring(class.desc or "Default class for this faction.")
                    draw.SimpleText(string.sub(desc:gsub("\n", " "), 1, 100), "LiliaFont.15", textX, 46, getThemeMutedColor(), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                end

                card.DoClick = function()
                    if tonumber(context.class) == tonumber(class.index) then return end
                    context.class = class.index
                    applyDefaultsForFaction(context, faction)
                    applyIdentityDefaults(context)
                    creator.completedTabs.class = nil
                    creator.completedTabs.identity = nil
                    creator.completedTabs.appearance = nil
                    creator:RefreshWorldModel(true)
                    creator:RefreshActiveTabValidation()
                end

                panel.cards[#panel.cards + 1] = card
            end

            panel.PerformLayout = function(self, w, h)
                self.title:SetPos(0, 0)
                self.title:SetSize(w, 36)
                self.subtitle:SetPos(0, 40)
                self.subtitle:SetSize(w, 42)
                self.scroll:SetPos(0, 92)
                self.scroll:SetSize(w, math.max(h - 92, 1))
                local canvas = self.scroll:GetCanvas()
                local cardW = math.max(self.scroll:GetWide() - 12, 1)
                local y = 0
                for _, card in ipairs(self.cards) do
                    card:SetPos(0, y)
                    card:SetSize(cardW, 86)
                    y = y + 96
                end

                canvas:SetTall(y)
            end
            return panel
        end,
        onValidate = function(context)
            local faction = getFactionByIndex(context.faction)
            local classes = getDefaultCreationClasses(faction)
            if #classes <= 1 then return true end
            if not isDefaultCreationClass(faction, context.class) then return false, "Choose a default class." end
            return true
        end,
        onBuildSummary = function(context, summary)
            local faction = getFactionByIndex(context.faction)
            local _, class = isDefaultCreationClass(faction, context.class)
            if class then
                summary[#summary + 1] = {
                    title = "Class",
                    value = tostring(class.name or class.uniqueID or class.index)
                }
            end
        end
    }

    tabs["attributes"] = {
        name = "Attributes",
        order = 40,
        onCreate = function(parent, context, creator)
            context.attribs = context.attribs or {}
            local panel = vgui.Create("DPanel", parent)
            panel:SetPaintBackground(false)
            addPageHeading(panel, "ATTRIBUTES", "Allocate the normal Lilia starting-point budget between Agility, Endurance, and Strength.")
            panel.budget = hook.Run("GetMaxStartingAttributePoints", LocalPlayer(), lia.config.get("StartingAttributePoints", 30)) or lia.config.get("StartingAttributePoints", 30)
            panel.remaining = panel:Add("DPanel")
            panel.remaining.Paint = function(_, w, h)
                local accent = getThemeAccent()
                drawPanel(0, 0, w, h, 7, Color(accent.r, accent.g, accent.b, 20), Color(accent.r, accent.g, accent.b, 80))
                local spent = 0
                for _, value in pairs(context.attribs or {}) do
                    spent = spent + (tonumber(value) or 0)
                end

                draw.SimpleText("POINTS REMAINING", "LiliaFont.16", 14, 9, getThemeMutedColor(), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                draw.SimpleText(tostring(math.max(panel.budget - spent, 0)), "LiliaFont.30", w - 14, h * 0.5, accent, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
            end

            panel.rows = {}
            local function spentPoints()
                local spent = 0
                for _, value in pairs(context.attribs or {}) do
                    spent = spent + (tonumber(value) or 0)
                end
                return spent
            end

            for _, key in ipairs(attributeOrder) do
                local attribute = lia.attribs and lia.attribs.list and lia.attribs.list[key]
                if not attribute or attribute.noStartBonus then continue end
                context.attribs[key] = tonumber(context.attribs[key]) or 0
                local row = panel:Add("DPanel")
                row.Paint = paintSection
                row.name = row:Add("DLabel")
                row.name:SetFont("LiliaFont.20")
                row.name:SetText(attribute.name or key)
                row.name:SetTextColor(getThemeTextColor())
                bindThemedLabel(row.name, function() return getThemeTextColor() end)
                row.desc = row:Add("DLabel")
                row.desc:SetFont("LiliaFont.14")
                row.desc:SetText(attribute.desc or "")
                row.desc:SetTextColor(getThemeMutedColor())
                row.desc:SetWrap(true)
                bindThemedLabel(row.desc, function() return getThemeMutedColor() end)
                row.minus = makeButton(row, "−", true)
                row.value = row:Add("DLabel")
                row.value:SetFont("LiliaFont.24")
                row.value:SetTextColor(getThemeTextColor())
                row.value:SetContentAlignment(5)
                bindThemedLabel(row.value, function() return getThemeTextColor() end)
                row.plus = makeButton(row, "+")
                local function update()
                    row.value:SetText(tostring(context.attribs[key] or 0))
                    panel.remaining:InvalidateLayout(true)
                    if IsValid(creator) then creator:RefreshActiveTabValidation() end
                end

                local function getAdjustmentStep()
                    if input.IsKeyDown(KEY_LSHIFT) or input.IsKeyDown(KEY_RSHIFT) then return 10 end
                    if input.IsKeyDown(KEY_LCONTROL) or input.IsKeyDown(KEY_RCONTROL) then return 5 end
                    return 1
                end

                row.minus.DoClick = function()
                    local current = tonumber(context.attribs[key]) or 0
                    context.attribs[key] = math.max(current - getAdjustmentStep(), 0)
                    update()
                end

                row.plus.DoClick = function()
                    local current = tonumber(context.attribs[key]) or 0
                    local maximum = tonumber(attribute.startingMax)
                    local remaining = math.max(panel.budget - spentPoints(), 0)
                    if remaining <= 0 or maximum and current >= maximum then return end
                    local target = current + math.min(getAdjustmentStep(), remaining)
                    if maximum then target = math.min(target, maximum) end
                    context.attribs[key] = target
                    update()
                end

                update()
                panel.rows[#panel.rows + 1] = row
            end

            panel.PerformLayout = function(self, w, h)
                self.title:SetPos(0, 0)
                self.title:SetSize(w, 36)
                self.subtitle:SetPos(0, 40)
                self.subtitle:SetSize(w, 42)
                self.remaining:SetPos(0, 96)
                self.remaining:SetSize(w, 62)
                local y = 172
                for _, row in ipairs(self.rows) do
                    row:SetPos(0, y)
                    row:SetSize(w, 92)
                    row.name:SetPos(14, 12)
                    row.name:SetSize(math.max(w - 190, 1), 24)
                    row.desc:SetPos(14, 39)
                    row.desc:SetSize(math.max(w - 190, 1), 40)
                    row.plus:SetPos(w - 48, 24)
                    row.plus:SetSize(36, 44)
                    row.value:SetPos(w - 96, 24)
                    row.value:SetSize(44, 44)
                    row.minus:SetPos(w - 136, 24)
                    row.minus:SetSize(36, 44)
                    y = y + 102
                end
            end
            return panel
        end,
        onValidate = function(context)
            local budget = hook.Run("GetMaxStartingAttributePoints", LocalPlayer(), lia.config.get("StartingAttributePoints", 30)) or lia.config.get("StartingAttributePoints", 30)
            local spent = 0
            for _, key in ipairs(attributeOrder) do
                local attribute = lia.attribs and lia.attribs.list and lia.attribs.list[key]
                if not attribute or attribute.noStartBonus then return false, "A required schema attribute is unavailable: " .. key end
                local value = tonumber(context.attribs and context.attribs[key]) or 0
                if value < 0 or value ~= math.floor(value) then return false, "Attribute allocations must be whole non-negative values." end
                if attribute.startingMax and value > attribute.startingMax then return false, (attribute.name or key) .. " exceeds its starting maximum." end
                spent = spent + value
            end

            if spent ~= budget then return false, "Allocate all " .. budget .. " available attribute points." end
            return true
        end,
        onBuildSummary = function(context, summary)
            for _, key in ipairs(attributeOrder) do
                local attribute = lia.attribs and lia.attribs.list and lia.attribs.list[key]
                summary[#summary + 1] = {
                    title = attribute and attribute.name or key,
                    value = tostring(context.attribs and context.attribs[key] or 0),
                    section = "attributes"
                }
            end
        end
    }

    tabs["identity"] = {
        name = "Identity",
        order = 20,
        onCreate = function(parent, context, creator)
            applyIdentityDefaults(context)
            local panel = vgui.Create("DPanel", parent)
            panel:SetPaintBackground(false)
            addPageHeading(panel, "IDENTITY", "Define the character's required identity fields. Server-side character validation still applies.")
            panel.controls = {}
            panel.contextEntries = {}
            panel.SyncContext = function(self)
                for key, entry in pairs(self.contextEntries) do
                    if IsValid(entry) then context[key] = entry:GetValue() end
                end
            end

            panel.SetContextEntryValue = function(self, key, value)
                value = tostring(value or "")
                context[key] = value
                local entry = self.contextEntries[key]
                if IsValid(entry) and entry:GetValue() ~= value then entry:SetValue(value) end
            end

            local function bindEntry(entry, key, editable)
                panel.contextEntries[key] = entry
                entry:SetEditable(editable ~= false)
                if editable == false then return end
                local function sync(self, value)
                    context[key] = tostring(value ~= nil and value or self:GetValue() or "")
                    if IsValid(creator) and creator.activeTabPanel == panel then creator:RefreshActiveTabValidation() end
                end

                entry.OnChange = function(self) sync(self) end
                entry.OnValueChange = function(self, value) sync(self, value) end
                entry.OnLoseFocus = function(self) sync(self) end
                entry.OnEnter = function(self) sync(self) end
            end

            if hook.Run("ShouldShowCharVarInCreation", "name") ~= false then
                local wrap, entry = makeEntry(panel, "NAME", false)
                wrap:SetTall(86)
                entry:SetValue(tostring(context.name or ""))
                bindEntry(entry, "name", hook.Run("CanEditCharVarInCreation", "name", context, creator) ~= false)
                panel.controls[#panel.controls + 1] = wrap
            end

            if hook.Run("ShouldShowCharVarInCreation", "desc") ~= false then
                local wrap, entry = makeEntry(panel, "DESCRIPTION", true)
                wrap:SetTall(120)
                entry:SetValue(tostring(context.desc or ""))
                bindEntry(entry, "desc", hook.Run("CanEditCharVarInCreation", "desc", context, creator) ~= false)
                panel.controls[#panel.controls + 1] = wrap
            end

            panel.PerformLayout = function(self, w, h)
                self.title:SetPos(0, 0)
                self.title:SetSize(w, 36)
                self.subtitle:SetPos(0, 40)
                self.subtitle:SetSize(w, 42)
                local y = 98
                for _, control in ipairs(self.controls) do
                    control:SetPos(0, y)
                    control:SetSize(w, control:GetTall())
                    y = y + control:GetTall() + 14
                end
            end
            return panel
        end,
        onLeave = function(panel) if IsValid(panel) and isfunction(panel.SyncContext) then panel:SyncContext() end end,
        onValidate = function(context)
            local defaultName, nameOverride = hook.Run("GetDefaultCharName", LocalPlayer(), context.faction, context)
            local nameIsForced = isstring(defaultName) and nameOverride == true
            if hook.Run("ShouldShowCharVarInCreation", "name") ~= false and not nameIsForced and string.Trim(tostring(context.name or "")) == "" then return false, "A character name is required." end
            if hook.Run("ShouldShowCharVarInCreation", "desc") ~= false then
                local description = string.Trim(tostring(context.desc or ""))
                if description == "" then return false, "A character description is required." end
                local minimum = lia.config.get("MinDescLen", 16)
                if #description:gsub("%s", "") < minimum then return false, "Description must contain at least " .. minimum .. " non-space characters." end
            end
            return true
        end,
        onBuildSummary = function(context, summary)
            summary[#summary + 1] = {
                title = "Name",
                value = tostring(context.name or ""),
                order = -100,
                layout = "wide"
            }

            summary[#summary + 1] = {
                title = "Description",
                value = tostring(context.desc or ""),
                order = 100000,
                layout = "wide"
            }

        end
    }

    tabs["appearance"] = {
        name = "Appearance",
        order = 30,
        onCreate = function(parent, context, creator)
            local panel = vgui.Create("DPanel", parent)
            panel:SetPaintBackground(false)
            addPageHeading(panel, "APPEARANCE", "Choose a valid model. Skin and bodygroup options appear below when the selected model allows them.")
            panel.searchWrap = panel:Add("DPanel")
            panel.searchWrap.Paint = function(_, w, h)
                local accent = getThemeAccent()
                drawPanel(0, 0, w, h, 7, getThemeSurface(0.04, 235), Color(accent.r, accent.g, accent.b, 52))
                draw.SimpleText("⌕", "LiliaFont.18", 14, h * 0.5, getThemeMutedColor(), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end

            panel.searchEntry = panel.searchWrap:Add("DTextEntry")
            panel.searchEntry:SetFont("LiliaFont.16")
            panel.searchEntry:SetTextColor(getThemeTextColor())
            panel.searchEntry:SetCursorColor(getThemeAccent())
            panel.searchEntry:SetHighlightColor(getThemeAccent(100))
            panel.searchEntry:SetDrawBackground(false)
            panel.searchEntry:SetPaintBackground(false)
            panel.searchEntry:SetPaintBorderEnabled(false)
            panel.searchEntry:SetUpdateOnType(true)
            panel.searchEntry.Paint = function(self, w, h)
                self:DrawTextEntryText(getThemeTextColor(), getThemeAccent(), getThemeTextColor())
                if string.Trim(self:GetValue() or "") == "" and not self:HasFocus() then draw.SimpleText("Search models...", "LiliaFont.16", 0, h * 0.5, getThemeMutedColor(150), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER) end
            end

            panel.filterCombo = panel:Add("liaComboBox")
            panel.filterCombo:SetFont("LiliaFont.16")
            panel.filterCombo:PostInit()
            panel.filterCombo:AddChoice("All Models", "all")
            panel.filterCombo:AddChoice("Male", "male")
            panel.filterCombo:AddChoice("Female", "female")
            panel.filterCombo:FinishAddingOptions()
            panel.filterCombo:ChooseOptionData("all")
            panel.filterCombo.OnSelect = function(_, _, _, value)
                panel.selectedGender = value or "all"
                if isfunction(panel.ApplyModelFilters) then panel:ApplyModelFilters() end
            end

            panel.modelWrap = panel:Add("DPanel")
            panel.modelWrap.Paint = function(_, w, h)
                local accent = getThemeAccent()
                drawPanel(0, 0, w, h, 7, getThemeSurface(0.035, 224), Color(accent.r, accent.g, accent.b, 48))
            end

            panel.modelScroll = panel.modelWrap:Add("liaScrollPanel")
            panel.modelScroll.Paint = function() end
            styleScrollBar(panel.modelScroll)
            panel.modelEmpty = panel.modelWrap:Add("DLabel")
            panel.modelEmpty:SetFont("LiliaFont.18")
            panel.modelEmpty:SetText("No models match the current filters.")
            panel.modelEmpty:SetTextColor(getThemeMutedColor())
            panel.modelEmpty:SetContentAlignment(5)
            bindThemedLabel(panel.modelEmpty, function() return getThemeMutedColor() end)
            panel.modelEmpty:SetVisible(false)
            panel.customWrap = panel:Add("DPanel")
            panel.customWrap:SetVisible(false)
            panel.customWrap.Paint = function(_, w, h)
                local accent = getThemeAccent()
                drawPanel(0, 0, w, h, 7, getThemeSurface(0.035, 228), Color(accent.r, accent.g, accent.b, 48))
            end

            panel.customHeader = panel.customWrap:Add("liaHeaderPanel")
            panel.customHeader:SetLineWidth(1)
            panel.customHeader.Think = function(self) self:SetLineColor(getThemeAccent(150)) end
            panel.customTitle = panel.customHeader:Add("DLabel")
            panel.customTitle:SetFont("LiliaFont.18")
            panel.customTitle:SetText("SKIN & BODYGROUPS")
            panel.customTitle:SetTextColor(getThemeTextColor())
            bindThemedLabel(panel.customTitle, function() return getThemeTextColor() end)
            panel.customTitle:SetContentAlignment(4)
            panel.customSubtitle = panel.customWrap:Add("DLabel")
            panel.customSubtitle:SetFont("LiliaFont.14")
            panel.customSubtitle:SetText("Available options for the selected model.")
            panel.customSubtitle:SetTextColor(getThemeMutedColor())
            bindThemedLabel(panel.customSubtitle, function() return getThemeMutedColor() end)
            panel.customScroll = panel.customWrap:Add("liaScrollPanel")
            panel.customScroll.Paint = function() end
            styleScrollBar(panel.customScroll)
            panel.modelCards = {}
            panel.visibleModelCards = {}
            panel.customControls = {}
            panel.selectedGender = "all"
            local faction = getFactionByIndex(context.faction)
            local models = getFilteredModels(faction, context)
            if #models > 0 then
                local hasSelection = false
                for _, modelData in ipairs(models) do
                    if modelData.key == context.model then
                        hasSelection = true
                        break
                    end
                end

                if not hasSelection then setDefaultAppearance(context, models[1].key, models[1].parsed) end
            end

            for _, modelData in ipairs(models) do
                local card = panel.modelScroll:Add("DButton")
                card:SetText("")
                card.index = modelData.key
                card.modelData = modelData
                card.displaySubtitle = getModelDisplaySubtitle(modelData)
                local gender = string.lower(tostring(hook.Run("GetModelGender", modelData.parsed.model) or "male"))
                card.gender = gender == "female" and "female" or "male"
                card._hover = 0
                card.Think = function(self)
                    local hovering = self:IsHovered() or IsValid(self.icon) and self.icon:IsHovered()
                    self._hover = Lerp(FrameTime() * 12, self._hover or 0, hovering and 1 or 0)
                end

                card.Paint = function(self, w, h)
                    local accent = getThemeAccent()
                    local selected = context.model == self.index
                    local hover = self._hover or 0
                    local background = selected and Color(accent.r, accent.g, accent.b, 24) or getThemeSurface(0.045 + hover * 0.02, 224)
                    local outline = Color(accent.r, accent.g, accent.b, selected and 190 or 36 + hover * 72)
                    drawPanel(0, 0, w, h, 7, background, outline)
                    if selected then
                        surface.SetDrawColor(accent.r, accent.g, accent.b, 225)
                        surface.DrawRect(0, 0, 2, h)
                    end
                end

                local icon = card:Add("SpawnIcon")
                card.icon = icon
                icon.index = modelData.key
                icon.modelData = modelData
                local resolvedGroups = resolveBodygroups(modelData.parsed.model, modelData.parsed.bodygroups)
                local bodyGroups = ""
                for i = 0, 8 do
                    bodyGroups = bodyGroups .. tostring(resolvedGroups[i] or 0)
                end

                local skin = tonumber(modelData.parsed.skin) or 0
                icon:SetModel(modelData.parsed.model, skin, bodyGroups)
                icon:SetTooltip(modelData.parsed.model)
                icon.model = modelData.parsed.model
                icon.skin = skin
                icon.bodyGroups = bodyGroups
                icon.PaintOver = function() end
                card.modelLabel = card:Add("DLabel")
                card.modelLabel:SetFont("LiliaFont.14")
                card.modelLabel:SetText(card.displaySubtitle)
                card.modelLabel:SetTextColor(getThemeMutedColor())
                card.modelLabel:SetContentAlignment(7)
                card.modelLabel:SetMouseInputEnabled(false)
                bindThemedLabel(card.modelLabel, function() return getThemeMutedColor() end)
                card.DoClick = function()
                    setDefaultAppearance(context, modelData.key, modelData.parsed)
                    creator.completedTabs.appearance = nil
                    creator:RefreshWorldModel(true)
                    creator:ShowTab(creator.currentIndex, true)
                end

                icon.DoClick = card.DoClick
                hook.Run("OnCharacterCreationModelIconSet", icon, modelData.parsed.model, skin, bodyGroups)
                panel.modelCards[#panel.modelCards + 1] = card
            end

            function panel:ApplyModelFilters()
                self.visibleModelCards = {}
                local query = string.Trim(self.searchEntry:GetValue() or "")
                local selectedGender = self.selectedGender or "all"
                for _, card in ipairs(self.modelCards) do
                    local matchesGender = selectedGender == "all" or card.gender == selectedGender
                    local matchesSearch = matchesModelSearch(card.modelData, query)
                    local visible = matchesGender and matchesSearch
                    card:SetVisible(visible)
                    if visible then self.visibleModelCards[#self.visibleModelCards + 1] = card end
                end

                if #self.modelCards == 0 then
                    self.modelEmpty:SetText("No valid models are available for this faction/class.")
                else
                    self.modelEmpty:SetText("No models match the current filters.")
                end

                self.modelEmpty:SetVisible(#self.visibleModelCards == 0)
                self:InvalidateLayout(true)
            end

            panel.searchEntry.OnValueChange = function() if isfunction(panel.ApplyModelFilters) then panel:ApplyModelFilters() end end
            local function addSkinSlideBox(maximum, selected, isAllowed, onSelect)
                if maximum <= 0 then return end
                local control = panel.customScroll:Add("liaSlideBox")
                control.controlType = "slidebox"
                control:SetText("Skin")
                control:SetRange(0, maximum, 0)
                local updating = false
                local function nearestAllowed(value)
                    value = math.Clamp(math.Round(tonumber(value) or 0), 0, maximum)
                    if isAllowed(value) then return value end
                    for distance = 1, maximum do
                        local lower = value - distance
                        if lower >= 0 and isAllowed(lower) then return lower end
                        local upper = value + distance
                        if upper <= maximum and isAllowed(upper) then return upper end
                    end
                    return 0
                end

                local initial = nearestAllowed(selected)
                control:SetValue(initial)
                control.OnValueChanged = function(self, value)
                    if updating then return end
                    local valid = nearestAllowed(value)
                    if valid ~= math.Round(value) then
                        updating = true
                        self:SetValue(valid)
                        updating = false
                    end

                    onSelect(valid)
                end

                panel.customControls[#panel.customControls + 1] = control
            end

            local function addBodygroupSlider(title, values, selected, onSelect)
                if #values <= 1 then return end
                local control = panel.customScroll:Add("DPanel")
                control:SetPaintBackground(false)
                control.controlType = "slider"
                control.header = control:Add("liaHeaderPanel")
                control.header:SetLineWidth(1)
                control.header.Think = function(self) self:SetLineColor(getThemeAccent(90)) end
                control.label = control.header:Add("DLabel")
                control.label:SetFont("LiliaFont.15")
                control.label:SetText(string.upper(title))
                control.label:SetTextColor(getThemeMutedColor())
                control.label:SetContentAlignment(4)
                bindThemedLabel(control.label, function() return getThemeMutedColor() end)
                control.valueLabel = control.header:Add("DLabel")
                control.valueLabel:SetFont("LiliaFont.15")
                control.valueLabel:SetTextColor(getThemeTextColor())
                control.valueLabel:SetContentAlignment(6)
                bindThemedLabel(control.valueLabel, function() return getThemeTextColor() end)
                control.slider = control:Add("liaSlider")
                control.slider:SetRange(0, #values - 1, 0)
                local selectedIndex = 1
                local selectedValue = tonumber(selected) or values[1]
                for index, value in ipairs(values) do
                    if tonumber(value) == selectedValue then
                        selectedIndex = index
                        break
                    end
                end

                control.slider:SetValue(selectedIndex - 1)
                control.valueLabel:SetText(tostring(values[selectedIndex]))
                control.slider.OnValueChanged = function(_, sliderValue)
                    local index = math.Clamp(math.Round(sliderValue) + 1, 1, #values)
                    local value = values[index]
                    control.valueLabel:SetText(tostring(value))
                    onSelect(value)
                end

                panel.customControls[#panel.customControls + 1] = control
            end

            local selectedFaction, raw, parsed = getSelectedModelData(context)
            local tempEntity
            if parsed and isstring(parsed.model) then tempEntity = ClientsideModel(parsed.model, RENDERGROUP_OTHER) end
            if IsValid(tempEntity) then
                tempEntity:SetNoDraw(true)
                local skinAllowed, bodygroupsAllowed = lia.faction.getModelCustomizationAllowed(LocalPlayer(), selectedFaction, context)
                if skinAllowed and tempEntity:SkinCount() > 1 then
                    addSkinSlideBox(tempEntity:SkinCount() - 1, tonumber(context.skin) or 0, function(value) return lia.faction.isSkinAllowedForFaction(selectedFaction, value, raw, context.model) end, function(value)
                        context.skin = value
                        creator:ApplyWorldAppearance()
                    end)
                end

                if bodygroupsAllowed then
                    for _, group in ipairs(tempEntity:GetBodyGroups() or {}) do
                        if group.num <= 1 then continue end
                        local groupID = group.id
                        local groupName = group.name
                        local values = {}
                        for value = 0, group.num - 1 do
                            if lia.faction.isBodygroupValueAllowed(selectedFaction, parsed.model, groupID, value, groupName, raw, context.model) then values[#values + 1] = value end
                        end

                        addBodygroupSlider(groupName or ("Bodygroup " .. groupID), values, tonumber(context.bodygroups[groupID]) or 0, function(value)
                            value = tonumber(value) or 0
                            if lia.faction.isBodygroupValueAllowed(selectedFaction, parsed.model, groupID, value, groupName, raw, context.model) then
                                context.bodygroups[groupID] = value
                                creator:ApplyWorldAppearance()
                            end
                        end)
                    end
                end

                tempEntity:Remove()
            end

            panel.PerformLayout = function(self, w, h)
                self.title:SetPos(0, 0)
                self.title:SetSize(w, 36)
                self.subtitle:SetPos(0, 40)
                self.subtitle:SetSize(w, 42)
                local controlsY = 92
                local searchHeight = 34
                local filterWidth = math.Clamp(math.floor(w * 0.26), 170, 220)
                local gap = 12
                self.searchWrap:SetPos(0, controlsY)
                self.searchWrap:SetSize(w - filterWidth - gap, searchHeight)
                self.searchEntry:SetPos(36, 2)
                self.searchEntry:SetSize(self.searchWrap:GetWide() - 48, searchHeight - 4)
                self.filterCombo:SetPos(w - filterWidth, controlsY)
                self.filterCombo:SetSize(filterWidth, searchHeight)
                local modelAreaY = controlsY + searchHeight + 14
                local contentBottom = h
                local hasCustomization = #self.customControls > 0
                self.customWrap:SetVisible(hasCustomization)
                if hasCustomization then
                    local customGap = 10
                    local controlWidth = 210
                    local innerWidth = math.max(math.floor(w * 0.5), 1)
                    local innerX = math.floor((w - innerWidth) * 0.5)
                    local available = math.max(innerWidth - 28, 1)
                    local columns = math.Clamp(math.floor((available + customGap) / (controlWidth + customGap)), 1, 4)
                    local rows = math.max(math.ceil(#self.customControls / columns), 1)
                    local visibleRows = math.min(rows, 2)
                    local customHeight = math.Clamp(64 + visibleRows * 72 + 12, 142, 220)
                    self.customWrap:SetPos(0, h - customHeight)
                    self.customWrap:SetSize(w, customHeight)
                    self.customHeader:SetPos(innerX + 12, 8)
                    self.customHeader:SetSize(innerWidth - 24, 28)
                    self.customTitle:SetPos(2, 0)
                    self.customTitle:SetSize(innerWidth - 28, 22)
                    self.customSubtitle:SetPos(innerX + 14, 38)
                    self.customSubtitle:SetSize(innerWidth - 28, 20)
                    self.customScroll:SetPos(innerX + 10, 62)
                    self.customScroll:SetSize(innerWidth - 20, customHeight - 72)
                    local canvas = self.customScroll:GetCanvas()
                    local scrollAvailable = math.max(self.customScroll:GetWide() - 12, 1)
                    columns = math.Clamp(math.floor((scrollAvailable + customGap) / (controlWidth + customGap)), 1, 4)
                    local cellWidth = math.floor((scrollAvailable - (columns - 1) * customGap) / columns)
                    local controlHeight = 62
                    local lastRow = -1
                    for index, control in ipairs(self.customControls) do
                        local column = (index - 1) % columns
                        local row = math.floor((index - 1) / columns)
                        lastRow = row
                        control:SetPos(column * (cellWidth + customGap), row * (controlHeight + customGap))
                        control:SetSize(cellWidth, controlHeight)
                        if control.controlType == "slidebox" then continue end
                        control.header:SetPos(0, 0)
                        control.header:SetSize(cellWidth, 24)
                        control.label:SetPos(4, 0)
                        control.label:SetSize(math.max(cellWidth - 54, 1), 20)
                        control.valueLabel:SetPos(math.max(cellWidth - 48, 0), 0)
                        control.valueLabel:SetSize(44, 20)
                        control.slider:SetPos(0, 32)
                        control.slider:SetSize(cellWidth, 20)
                    end

                    local canvasHeight = lastRow >= 0 and (lastRow + 1) * (controlHeight + customGap) - customGap or 1
                    canvas:SetTall(math.max(canvasHeight, 1))
                    contentBottom = h - customHeight - 12
                end

                self.modelWrap:SetPos(0, modelAreaY)
                self.modelWrap:SetSize(w, math.max(contentBottom - modelAreaY, 1))
                self.modelScroll:SetPos(10, 10)
                self.modelScroll:SetSize(w - 20, math.max(self.modelWrap:GetTall() - 20, 1))
                self.modelEmpty:SetPos(20, 0)
                self.modelEmpty:SetSize(w - 40, self.modelWrap:GetTall())
                local canvas = self.modelScroll:GetCanvas()
                local visibleCards = self.visibleModelCards or {}
                local available = math.max(self.modelScroll:GetWide() - 8, 1)
                local cardGap = 10
                local targetWidth = 122
                local maxColumns = math.min(math.max(#visibleCards, 1), 6)
                local columns = math.Clamp(math.floor((available + cardGap) / (targetWidth + cardGap)), 1, math.max(maxColumns, 1))
                local cardW = math.floor((available - (columns - 1) * cardGap) / columns)
                cardW = math.Clamp(cardW, 114, 150)
                local iconH = cardW - 4
                local cardH = iconH + 28
                local lastRow = -1
                for index, card in ipairs(visibleCards) do
                    local column = (index - 1) % columns
                    local row = math.floor((index - 1) / columns)
                    lastRow = row
                    card:SetPos(column * (cardW + cardGap), row * (cardH + cardGap))
                    card:SetSize(cardW, cardH)
                    card.icon:SetPos(6, 6)
                    card.icon:SetSize(cardW - 12, iconH - 8)
                    card.modelLabel:SetPos(9, iconH)
                    card.modelLabel:SetSize(cardW - 18, 20)
                end

                local modelCanvasHeight = lastRow >= 0 and (lastRow + 1) * (cardH + cardGap) - cardGap or 1
                canvas:SetTall(math.max(modelCanvasHeight, 1))
            end

            panel:ApplyModelFilters()
            creator:RefreshWorldModel(false)
            return panel
        end,
        onEnter = function(_, _, creator) creator:TransitionCamera("appearance", 0.55) end,
        onValidate = function(context)
            local faction = getFactionByIndex(context.faction)
            if not faction then return false, "Choose a faction first." end
            local models = getFilteredModels(faction, context)
            for _, modelData in ipairs(models) do
                if modelData.key == context.model then return true end
            end
            return false, "Choose a valid appearance model."
        end,
        onBuildSummary = function(context, summary)
            local _, _, parsed = getSelectedModelData(context)
            if parsed then
                summary[#summary + 1] = {
                    title = "Model",
                    value = parsed.model
                }

                summary[#summary + 1] = {
                    title = "Skin",
                    value = tostring(context.skin or 0)
                }

                local groupCount = table.Count(context.bodygroups or {})
                summary[#summary + 1] = {
                    title = "Bodygroups",
                    value = groupCount > 0 and tostring(groupCount) .. " configured" or "Default"
                }
            end
        end
    }

    tabs["review"] = {
        name = "Review",
        order = 50,
        onCreate = function(parent, _, creator)
            local panel = vgui.Create("DPanel", parent)
            panel:SetPaintBackground(false)
            addPageHeading(panel, "SUMMARY & FINISH", "Review your character and edit any section before creating it.")
            panel.summary = creator:BuildSummary()
            panel.cards = {}
            panel.layoutItems = {}
            panel.sections = {}
            local tabsByID = {}
            local tabsByTitle = {}
            local tabIndexes = {}
            for index, tab in ipairs(creator.tabs) do
                if tab.id == "review" then continue end
                tabsByID[tab.id] = tab
                tabIndexes[tab.id] = index
                tabsByTitle[string.lower(tostring(tab.reviewHeader or tab.name))] = tab
                tabsByTitle[string.lower(tostring(tab.name))] = tab
            end

            local sectionsByID = {}
            for index, item in ipairs(panel.summary) do
                if not istable(item) or item.hidden == true then continue end
                local header = string.Trim(tostring(item.header or ""))
                local sourceID = isstring(item.section) and item.section ~= "" and item.section or nil
                local matchedTab = sourceID and tabsByID[sourceID] or tabsByTitle[string.lower(header)]
                local sectionID = sourceID or matchedTab and matchedTab.id or header ~= "" and string.lower(header) or "additional"
                local section = sectionsByID[sectionID]
                if not section then
                    local title = header ~= "" and header or matchedTab and (matchedTab.reviewHeader or matchedTab.name) or sourceID and sourceID ~= "additional" and sourceID or "Additional Details"
                    section = {
                        id = sectionID,
                        title = tostring(title),
                        tabID = matchedTab and matchedTab.id or nil,
                        order = tonumber(item.sectionOrder) or matchedTab and matchedTab.order or 1000 + index,
                        index = index,
                        entries = {}
                    }

                    sectionsByID[sectionID] = section
                    panel.sections[#panel.sections + 1] = section
                end

                if not section.tabID and isstring(item.editTab) and tabsByID[item.editTab] then section.tabID = item.editTab end
                section.entries[#section.entries + 1] = {
                    item = item,
                    index = index
                }
            end

            table.sort(panel.sections, function(a, b)
                if a.order == b.order then return a.index < b.index end
                return a.order < b.order
            end)

            panel.scroll = panel:Add("DScrollPanel")
            panel.scroll.Paint = function() end
            styleScrollBar(panel.scroll)
            local function makeDefaultCard(item)
                local card = panel.scroll:Add("DPanel")
                card.isDefaultReviewCard = true
                card.Paint = function(_, w, h)
                    local accent = getThemeAccent()
                    drawPanel(0, 0, w, h, 6, getThemeSurface(0.05, 240), Color(accent.r, accent.g, accent.b, 46))
                    surface.SetDrawColor(accent.r, accent.g, accent.b, 125)
                    surface.DrawRect(0, 0, 2, h)
                end

                card.title = card:Add("DLabel")
                card.title:SetFont("LiliaFont.15")
                card.title:SetText(string.upper(tostring(item.title or "DETAIL")))
                card.title:SetTextColor(getThemeMutedColor())
                bindThemedLabel(card.title, function() return getThemeMutedColor() end)
                card.value = card:Add("DLabel")
                card.value:SetFont("LiliaFont.18")
                card.value:SetText(tostring(item.value == nil and "" or item.value))
                card.value:SetTextColor(getThemeTextColor())
                card.value:SetWrap(true)
                bindThemedLabel(card.value, function() return getThemeTextColor() end)
                card.PerformLayout = function(self, w, h)
                    self.title:SetPos(13, 8)
                    self.title:SetSize(math.max(w - 26, 1), 18)
                    self.value:SetPos(13, 29)
                    self.value:SetSize(math.max(w - 26, 1), math.max(h - 36, 1))
                end
                return card
            end

            local totalItems = 0
            for _, section in ipairs(panel.sections) do
                table.sort(section.entries, function(a, b)
                    local aOrder = tonumber(a.item.order) or a.index
                    local bOrder = tonumber(b.item.order) or b.index
                    if aOrder == bOrder then return a.index < b.index end
                    return aOrder < bOrder
                end)

                local visibleEntries = {}
                for _, entry in ipairs(section.entries) do
                    local item = entry.item
                    local card = hook.Run("CreateCharacterCreationReviewItem", panel.scroll, item, panel, creator.context, creator)
                    if card == false then continue end
                    if not IsValid(card) then card = makeDefaultCard(item) end
                    card.reviewItem = item
                    entry.panel = card
                    visibleEntries[#visibleEntries + 1] = entry
                    panel.cards[#panel.cards + 1] = card
                    totalItems = totalItems + 1
                    hook.Run("CharacterCreationReviewItemCreated", card, item, panel, creator.context, creator)
                end

                section.entries = visibleEntries
            end

            local visibleSections = {}
            for _, section in ipairs(panel.sections) do
                if #section.entries == 0 then continue end
                local header = panel.scroll:Add("DPanel")
                header.section = section
                header.Paint = function(self, w, h)
                    local accent = getThemeAccent()
                    draw.SimpleText(string.upper(self.section.title), "LiliaFont.16", 2, 5, getThemeTextColor(), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                    surface.SetDrawColor(accent.r, accent.g, accent.b, 110)
                    surface.DrawRect(0, h - 1, w, 1)
                end

                local tabID = section.tabID
                if tabID and tabIndexes[tabID] then
                    header.edit = header:Add("DButton")
                    header.edit:SetText("")
                    header.edit.Paint = function(self, w, h)
                        local accent = getThemeAccent()
                        draw.SimpleText("EDIT", "LiliaFont.15", w - 8, h * 0.5, self:IsHovered() and getThemeTextColor() or accent, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
                    end

                    header.edit.DoClick = function() creator:RequestTab(tabIndexes[tabID]) end
                    header.PerformLayout = function(self, w)
                        self.edit:SetPos(w - 64, 0)
                        self.edit:SetSize(64, 29)
                    end
                end

                section.headerPanel = header
                visibleSections[#visibleSections + 1] = section
                panel.layoutItems[#panel.layoutItems + 1] = {
                    panel = header,
                    height = 34
                }

                for _, entry in ipairs(section.entries) do
                    panel.layoutItems[#panel.layoutItems + 1] = {
                        panel = entry.panel
                    }
                end
            end

            panel.sections = visibleSections
            panel.overview = panel:Add("DPanel")
            panel.overview.Paint = function(_, w, h)
                local accent = getThemeAccent()
                drawPanel(0, 0, w, h, 7, Color(accent.r, accent.g, accent.b, 15), Color(accent.r, accent.g, accent.b, 75))
                surface.SetDrawColor(accent.r, accent.g, accent.b, 220)
                surface.DrawRect(0, 0, 3, h)
                draw.SimpleText("CHARACTER SUMMARY", "LiliaFont.18", 15, 9, getThemeTextColor(), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                draw.SimpleText(string.format("%d sections  /  %d details", #panel.sections, totalItems), "LiliaFont.16", 15, 34, getThemeMutedColor(), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            end

            local function getTextMetrics(text, font, width)
                surface.SetFont(font)
                local _, lineHeight = surface.GetTextSize("Ag")
                local lines = 0
                for rawLine in (tostring(text) .. "\n"):gmatch("(.-)\n") do
                    local lineWidth = 0
                    for word in rawLine:gmatch("%S+") do
                        local wordWidth = surface.GetTextSize(word)
                        local spaceWidth = lineWidth > 0 and surface.GetTextSize(" ") or 0
                        if lineWidth > 0 and lineWidth + spaceWidth + wordWidth > width then
                            lines = lines + 1
                            lineWidth = 0
                        end

                        if wordWidth > width then
                            local segments = math.ceil(wordWidth / math.max(width, 1))
                            lines = lines + segments - 1
                            lineWidth = wordWidth - (segments - 1) * width
                        else
                            lineWidth = lineWidth + (lineWidth > 0 and spaceWidth or 0) + wordWidth
                        end
                    end

                    lines = lines + 1
                end
                return lines * math.max(lineHeight, 18)
            end

            local function wantsWide(entry, rowWidth)
                local item = entry.item
                local layout = item.layout or entry.panel.reviewLayout
                if tonumber(item.span) == 2 or layout == "wide" or layout == "full" then return true end
                if tonumber(item.span) == 1 or layout == "compact" then return false end
                if not entry.panel.isDefaultReviewCard then return true end
                local halfWidth = (rowWidth - 9) * 0.5 - 28
                local value = tostring(item.value == nil and "" or item.value)
                if value:find("\n", 1, true) then return true end
                surface.SetFont("LiliaFont.18")
                local valueWidth = surface.GetTextSize(value)
                surface.SetFont("LiliaFont.15")
                local titleWidth = surface.GetTextSize(string.upper(tostring(item.title or "DETAIL")))
                return valueWidth > halfWidth or titleWidth > halfWidth
            end

            local function getEntryHeight(entry, width)
                local item = entry.item
                local explicit = tonumber(item.height) or tonumber(entry.panel.reviewHeight)
                if explicit then return math.max(explicit, 1) end
                if not entry.panel.isDefaultReviewCard then return math.max(entry.panel:GetTall(), 76) end
                local contentHeight = getTextMetrics(item.value == nil and "" or item.value, "LiliaFont.18", math.max(width - 28, 1))
                return math.max(66, 39 + contentHeight)
            end

            panel.PerformLayout = function(self, w, h)
                self.title:SetPos(0, 0)
                self.title:SetSize(w, 36)
                self.subtitle:SetPos(0, 40)
                self.subtitle:SetSize(w, 42)
                self.overview:SetPos(0, 90)
                self.overview:SetSize(w, 60)
                self.scroll:SetPos(0, 162)
                self.scroll:SetSize(w, math.max(h - 162, 1))
                local rowWidth = math.max(self.scroll:GetWide() - 12, 1)
                local columnGap = 9
                local cardGap = 9
                local halfWidth = math.max((rowWidth - columnGap) * 0.5, 1)
                local y = 0
                for _, section in ipairs(self.sections) do
                    section.headerPanel:SetPos(0, y)
                    section.headerPanel:SetSize(rowWidth, 34)
                    y = y + 43
                    local waiting = false
                    local rowHeight = 0
                    for index, entry in ipairs(section.entries) do
                        local card = entry.panel
                        local wide = rowWidth < 460 or wantsWide(entry, rowWidth)
                        if not wide and not waiting then
                            local nextEntry = section.entries[index + 1]
                            if not nextEntry or wantsWide(nextEntry, rowWidth) then wide = true end
                        end

                        if wide then
                            if waiting then
                                y = y + rowHeight + cardGap
                                waiting = false
                                rowHeight = 0
                            end

                            local height = getEntryHeight(entry, rowWidth)
                            card:SetPos(0, y)
                            card:SetSize(rowWidth, height)
                            y = y + height + cardGap
                        else
                            local height = getEntryHeight(entry, halfWidth)
                            if waiting then
                                card:SetPos(halfWidth + columnGap, y)
                                card:SetSize(halfWidth, height)
                                y = y + math.max(rowHeight, height) + cardGap
                                waiting = false
                                rowHeight = 0
                            else
                                card:SetPos(0, y)
                                card:SetSize(halfWidth, height)
                                waiting = true
                                rowHeight = height
                            end
                        end
                    end

                    if waiting then y = y + rowHeight + cardGap end
                    y = y + 16
                end

                self.scroll:GetCanvas():SetTall(math.max(y, self.scroll:GetTall()))
                hook.Run("CharacterCreationReviewLayout", self, self.cards, self.summary, creator.context, creator)
            end

            hook.Run("CharacterCreationReviewCreated", panel, panel.summary, creator.context, creator)
            return panel
        end,
        onEnter = function(_, _, creator) creator:TransitionCamera("appearance", 0.55) end,
        onValidate = function() return true end
    }
end)
end

do
    local PANEL = {}

    function PANEL:Init()
        self:Dock(FILL)
        self:SetPaintBackground(false)
        self.context = {}
    end

    function PANEL:addLabel(value)
        local label = self:Add("DLabel")
        label:SetFont("LiliaFont.16")
        label:SetText(tostring(value):upper())
        label:SizeToContents()
        label:Dock(TOP)
        return label
    end

    function PANEL:getContext(key, fallback)
        local creator = lia.gui.schemaCharacterCreator
        local context = IsValid(creator) and creator.context or self.context
        if key == nil then return context end
        local value = context[key]
        return value == nil and fallback or value
    end

    function PANEL:setContext(key, value)
        local creator = lia.gui.schemaCharacterCreator
        local context = IsValid(creator) and creator.context or self.context
        context[key] = value
    end

    vgui.Register("liaCharacterCreateStep", PANEL, "liaScrollPanel")
end
