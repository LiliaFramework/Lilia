local PANEL = {}
local CharHover = {"buttons/button15.wav", 35, 250}
local CharClick = {"buttons/button14.wav", 35, 255}
local CharWarning = {"friends/friend_join.wav", 40, 255}
PANEL.ANIM_SPEED = 0.1
PANEL.FADE_SPEED = 0.5
function PANEL:UpdateLogoPosition()
    local sw, sh = ScrW(), ScrH()
    local btnSpacing = sh * 0.01
    local logoW = sw * 0.13
    local logoH = sw * 0.13
    local scaleFactor = 0.95
    local newLogoW = logoW * scaleFactor
    local newLogoH = logoH * scaleFactor
    local leftMost = math.huge
    local rightMost = -math.huge
    local topY = math.huge
    for _, btn in pairs(self.buttons) do
        if IsValid(btn) then
            local x, y = btn:GetPos()
            local btnW = btn:GetWide()
            leftMost = math.min(leftMost, x)
            rightMost = math.max(rightMost, x + btnW)
            topY = math.min(topY, y)
        end
    end

    if topY == math.huge then topY = sh / 2 end
    local groupCenter = (leftMost + rightMost) / 2
    local logoX = groupCenter - newLogoW / 2
    local logoY = topY - newLogoH - btnSpacing
    self.logo:SetPos(logoX, logoY)
    self.logo:SetSize(newLogoW, newLogoH)
end

function PANEL:createCharacterInfoPanel()
    local client = LocalPlayer()
    local character = client:getChar()
    local info = {}
    table.insert(info, "Name: " .. (character:getName() or ""))
    table.insert(info, "Faction: " .. (team.GetName(client:Team()) or ""))
    if character:getClass() and lia.class.list[character:getClass()] and lia.class.list[character:getClass()].name then table.insert(info, "Class: " .. lia.class.list[character:getClass()].name) end
    table.insert(info, "Money: " .. lia.currency.get(character:getMoney()))
    table.insert(info, "Description:")
    table.insert(info, character:getDesc() or "")
    hook.Run("LoadMainMenuInformation", info)
    self.infoFrame = self:Add("DFrame")
    self.infoFrame:SetSize(ScrW() * 0.25, ScrH() * 0.45)
    self.infoFrame:SetPos(ScrW() - ScrW() * 0.25 - 50, ScrH() * 0.25)
    self.infoFrame:SetTitle("")
    self.infoFrame:SetDraggable(false)
    self.infoFrame:ShowCloseButton(false)
    local scroll = vgui.Create("DScrollPanel", self.infoFrame)
    scroll:Dock(FILL)
    local padding = 10
    for k, text in ipairs(info) do
        local label = scroll:Add("DLabel")
        label:Dock(TOP)
        label:DockMargin(padding, padding, padding, 0)
        label:SetFont("liaMediumFont")
        label:SetWrap(true)
        label:SetAutoStretchVertical(true)
        label:SetText(text)
        label:SizeToContentsY()
    end
end

function PANEL:createStartButton()
    local client = LocalPlayer()
    local sw, sh = ScrW(), ScrH()
    local btnWidth = sw * 0.2
    local btnHeight = sh * 0.04
    local btnSpacing = sh * 0.01
    local logoW = sw * 0.13
    local logoH = sw * 0.13
    local logoPath = lia.config.get("CenterLogo")
    local discordURL = lia.config.get("DiscordURL")
    local workshopURL = lia.config.get("Workshop")
    local buttonConfigs = {}
    table.insert(buttonConfigs, {
        id = "play",
        text = "PLAY",
        doClick = function()
            if self.buttons then
                for _, btn in pairs(self.buttons) do
                    if IsValid(btn) then btn:Remove() end
                end
            end

            if self.logo and IsValid(self.logo) then self.logo:Remove() end
            self:clickSound()
            self:showContent()
        end
    })

    if discordURL and discordURL ~= "" then
        table.insert(buttonConfigs, {
            id = "discord",
            text = "DISCORD",
            doClick = function()
                self:clickSound()
                gui.OpenURL(discordURL)
            end
        })
    end

    if workshopURL and workshopURL ~= "" then
        table.insert(buttonConfigs, {
            id = "workshop",
            text = "STEAM WORKSHOP",
            doClick = function()
                self:clickSound()
                gui.OpenURL(workshopURL)
            end
        })
    end

    table.insert(buttonConfigs, {
        id = "disconnect",
        text = "DISCONNECT",
        doClick = function()
            self:clickSound()
            RunConsoleCommand("disconnect")
        end
    })

    if client:getChar() then
        table.insert(buttonConfigs, {
            id = "return",
            text = "RETURN",
            doClick = function() self:fadeOut() end
        })
    end

    local numButtons = #buttonConfigs
    local totalHeight = numButtons * btnHeight + (numButtons - 1) * btnSpacing
    local startY = sh / 2 - totalHeight / 2
    self.buttons = {}
    local function createButtons(xOffset)
        for i, config in ipairs(buttonConfigs) do
            local btn = self:Add("liaMediumButton")
            btn:SetSize(btnWidth, btnHeight)
            local posY = startY + (i - 1) * (btnHeight + btnSpacing)
            btn:SetPos(xOffset, posY)
            btn:SetText(config.text)
            btn.DoClick = config.doClick
            btn.OnCursorEntered = function() surface.PlaySound("ui/hover.wav") end
            local oldSetPos = btn.SetPos
            btn.SetPos = function(b, x, y)
                oldSetPos(b, x, y)
                if IsValid(self) then self:UpdateLogoPosition() end
            end

            self.buttons[config.id] = btn
        end
    end

    if client:getChar() then
        local trace = {}
        trace.start = client:EyePos()
        trace.endpos = trace.start + client:GetAimVector() * 100
        trace.filter = {client}
        local tr = util.TraceLine(trace)
        if tr.Hit then
            createButtons(sw / 2 - btnWidth / 2)
        else
            createButtons(sw * 0.1)
            self:createCharacterInfoPanel()
        end
    else
        createButtons(sw / 2 - btnWidth / 2)
    end

    if logoPath and logoPath ~= "" then
        local scaleFactor = 0.95
        local newLogoW = logoW * scaleFactor
        local newLogoH = logoH * scaleFactor
        local function setLogo(logo)
            logo:SetZPos(9999)
            self:UpdateLogoPosition()
            timer.Simple(0, function() if IsValid(logo) then logo:MoveToFront() end end)
        end

        if string.sub(logoPath, 1, 8) == "https://" then
            http.Fetch(logoPath, function(body)
                local fileName = "temp_logo.png"
                file.Write(fileName, body)
                self.logo = self:Add("DImage")
                self.logo:SetImage("data/" .. fileName)
                setLogo(self.logo)
            end)
        else
            self.logo = self:Add("DImage")
            self.logo:SetImage(logoPath)
            setLogo(self.logo)
        end
    end
end

function PANEL:playSound(url)
    if lia.menuSound then
        lia.menuSound:Stop()
        lia.menuSound = nil
    end

    timer.Remove("liaSoundFader")
    local source = url
    if source:find("%S") then
        local function callback(sound, errorID, fault)
            if sound then
                sound:SetVolume(2)
                lia.menuSound = sound
                lia.menuSound:Play()
            else
                MsgC(Color(255, 50, 50), errorID .. " ")
                MsgC(color_white, fault .. "\n")
            end
        end

        if source:find("http") then
            sound.PlayURL(source, "noplay", callback)
        else
            sound.PlayFile("sound/" .. source, "noplay", callback)
        end
    end
end

function PANEL:fadeMusic()
    if lia.menuSound then
        local fraction = 1
        local startTime, finishTime = RealTime(), RealTime() + 10
        timer.Create("liaMusicFader", 0.1, 0, function()
            if lia.menuSound then
                fraction = 1 - math.TimeFraction(startTime, finishTime, RealTime())
                lia.menuSound:SetVolume(fraction * 0.5)
                if fraction <= 0 then
                    lia.menuSound:Stop()
                    lia.menuSound = nil
                    timer.Remove("liaMusicFader")
                end
            else
                timer.Remove("liaMusicFader")
            end
        end)
    end
end

function PANEL:createTitle()
    if self.tabs then self.tabs:DockMargin(64, 32, 64, 0) end
end

function PANEL:loadBackground()
    local client = LocalPlayer()
    if client:getChar() then
        local camDist = 100
        local center = client:EyePos() + Vector(0, 0, 40)
        local forward = client:EyeAngles():Forward()
        local traceData = {
            start = center,
            endpos = center + forward * camDist,
            filter = {client}
        }

        local tr = util.TraceLine(traceData)
        if not tr.Hit then
            hook.Add("PrePlayerDraw", "liaCharacter_StopDrawLocalPlayer", function(ply) if ply == client then return true end end)
            self:spawnClientModelEntity()
            hook.Add("CalcView", "liaCharacterMenuCalcViewApproach", function(ply, pos, angles, fov, nearZ, farZ)
                if not IsValid(lia.gui.character) or not IsValid(lia.gui.character.modelEntity) then return end
                local ent = lia.gui.character.modelEntity
                local center = ent:GetPos() + Vector(0, 0, 60)
                local targetCamDistance = 30
                local desiredCamPos = center + ent:GetForward() * targetCamDistance
                lia.gui.character.currentCamPos = lia.gui.character.currentCamPos or desiredCamPos
                lia.gui.character.currentCamPos = LerpVector(FrameTime() * 5, lia.gui.character.currentCamPos, desiredCamPos)
                local view = {
                    origin = lia.gui.character.currentCamPos,
                    angles = (center - lia.gui.character.currentCamPos):Angle(),
                    fov = fov,
                    drawviewer = true
                }
                return view
            end)
            return
        end
    end

    local url = lia.config.get("BackgroundURL")
    if url and url:find("%S") then
        self.background = self:Add("DHTML")
        self.background:SetSize(ScrW(), ScrH())
        if url:find("http") then
            self.background:OpenURL(url)
        else
            self.background:SetHTML(url)
        end

        self.background.OnDocumentReady = function() self.bgLoader:AlphaTo(0, 2, 1, function() self.bgLoader:Remove() end) end
        self.background:MoveToBack()
        self.background:SetZPos(-999)
        if lia.config.get("CharMenuBGInputDisabled") then
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

function PANEL:spawnClientModelEntity()
    if IsValid(self.modelEntity) then self.modelEntity:Remove() end
    local ply = LocalPlayer()
    local modelPath = ply:GetModel()
    self.modelEntity = ClientsideModel(modelPath, RENDER_GROUP_OPAQUE_ENTITY)
    if not IsValid(self.modelEntity) then return end
    self.modelEntity:SetNoDraw(false)
    self.modelEntity:SetSkin(ply:GetSkin() or 0)
    local numBG = self.modelEntity:GetNumBodyGroups()
    for i = 0, numBG - 1 do
        self.modelEntity:SetBodygroup(i, ply:GetBodygroup(i))
    end

    for k, v in ipairs(self.modelEntity:GetSequenceList()) do
        if v:lower():find("idle") and v ~= "idlenoise" then
            self.modelEntity:ResetSequence(k)
            self.modelEntity:SetCycle(0)
            break
        end
    end

    hook.Add("PostDrawOpaqueRenderables", self, function()
        if IsValid(self.modelEntity) then
            self.modelEntity:FrameAdvance(RealFrameTime())
            self.modelEntity:DrawModel()
        end
    end)
end

function PANEL:paintBackground(w, h)
    if IsValid(self.background) then return end
    if self.blank then
        surface.SetDrawColor(42, 42, 42, 179)
        surface.DrawRect(0, 0, w, h)
    end
end

function PANEL:addTab(name, callback, justClick)
    local button = self.tabs:Add("liaCharacterTabButton")
    button:setText(L(name):upper())
    if justClick then
        if isfunction(callback) then button.DoClick = function() callback(self) end end
        return
    end

    button.DoClick = function(btn) btn:setSelected(true) end
    if isfunction(callback) then button:onSelected(function() callback(self) end) end
    return button
end

function PANEL:createTabs()
    local client = LocalPlayer()
    local load, create
    if lia.characters and #lia.characters > 0 then load = self:addTab("load character", self.createCharacterSelection) end
    if hook.Run("CanPlayerCreateChar", client) ~= false then create = self:addTab("new character", self.createCharacterCreation) end
    if IsValid(load) then
        load:setSelected()
    elseif IsValid(create) then
        create:setSelected()
    end

    if client:getChar() then
        self:addTab("return", function() if IsValid(self) and client:getChar() then self:fadeOut() end end, true)
    else
        self:addTab("leave", function() vgui.Create("liaCharacterConfirm"):setTitle(L("disconnect"):upper() .. "?"):setMessage(L("You will disconnect from the server."):upper()):onConfirm(function() client:ConCommand("disconnect") end) end, true)
    end

    local totalWidth = -32
    for _, v in ipairs(self.tabs:GetChildren()) do
        totalWidth = totalWidth + v:GetWide()
    end

    self.tabs:Dock(BOTTOM)
    self.tabs:DockMargin(0, 0, 0, 10)
    self.tabs:DockMargin(self.tabs:GetWide() * 0.5 - totalWidth * 0.5, 0, 0, 10)
    self:Dock(FILL)
    self:DockMargin(0, 0, 0, 0)
end

function PANEL:createCharacterSelection()
    self.content:Clear()
    self.content:InvalidateLayout(true)
    self.content:Add("liaCharacterSelection")
end

function PANEL:createCharacterCreation()
    self.content:Clear()
    self.content:InvalidateLayout(true)
    self.content:Add("liaCharacterCreation")
end

function PANEL:fadeOut()
    self:AlphaTo(0, self.ANIM_SPEED, 0, function() self:Remove() end)
end

function PANEL:Init()
    local client = LocalPlayer()
    if IsValid(lia.gui.loading) then lia.gui.loading:Remove() end
    if IsValid(lia.gui.character) then lia.gui.character:Remove() end
    lia.gui.character = self
    self.color = ColorAlpha(color_white, 150)
    self.colorSelected = color_white
    self.colorHovered = ColorAlpha(color_white, 50)
    self:Dock(FILL)
    self:MakePopup()
    self:SetAlpha(0)
    self:AlphaTo(255, self.ANIM_SPEED * 2)
    self.tabs = self:Add("DPanel")
    self.tabs:Dock(TOP)
    self.tabs:DockMargin(64, 32, 64, 0)
    self.tabs:SetTall(48)
    self.tabs:SetPaintBackground(false)
    self:createTitle()
    self.content = self:Add("DPanel")
    self.content:Dock(FILL)
    self.content:DockMargin(64, 0, 64, 64)
    self.content:SetPaintBackground(false)
    self.music = self:Add("liaCharBGMusic")
    self:loadBackground()
    self:InvalidateParent(true)
    self:InvalidateChildren(true)
    self:createStartButton()
end

function PANEL:showContent()
    self.tabs:Clear()
    self.content:Clear()
    self:createTabs()
end

function PANEL:setFadeToBlack(fade)
    local d = deferred.new()
    if fade then
        if IsValid(self.fade) then self.fade:Remove() end
        local fade = vgui.Create("DPanel")
        fade:SetSize(ScrW(), ScrH())
        fade:SetSkin("Default")
        fade:SetBackgroundColor(color_black)
        fade:SetAlpha(0)
        fade:AlphaTo(255, self.FADE_SPEED, 0, function() d:resolve() end)
        fade:SetZPos(999)
        fade:MakePopup()
        self.fade = fade
    elseif IsValid(self.fade) then
        local fadePanel = self.fade
        fadePanel:AlphaTo(0, self.FADE_SPEED, 0, function()
            fadePanel:Remove()
            d:resolve()
        end)
    end
    return d
end

function PANEL:Paint(w, h)
    local client = LocalPlayer()
    if not client:getChar() then
        lia.util.drawBlur(self)
        self:paintBackground(w, h)
    end
end

function PANEL:hoverSound()
    local client = LocalPlayer()
    client:EmitSound(unpack(CharHover))
end

function PANEL:clickSound()
    local client = LocalPlayer()
    client:EmitSound(unpack(CharClick))
end

function PANEL:warningSound()
    local client = LocalPlayer()
    client:EmitSound(unpack(CharWarning))
end

function PANEL:OnRemove()
    hook.Remove("PrePlayerDraw", "liaCharacter_StopDrawLocalPlayer")
    hook.Remove("CalcView", "liaCharacterMenuCalcView")
    hook.Remove("PostDrawOpaqueRenderables", self)
    if IsValid(self.modelEntity) then self.modelEntity:Remove() end
end

function PANEL:Think()
    if IsValid(self.logo) then
        self.logo:SetZPos(9999)
        self.logo:MoveToFront()
        self:UpdateLogoPosition()
    end
end

vgui.Register("liaCharacter", PANEL, "EditablePanel")