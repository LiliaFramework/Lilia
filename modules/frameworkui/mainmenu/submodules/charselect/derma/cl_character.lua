local PANEL = {}
function PANEL:Init()
    local client = LocalPlayer()
    local clientChar = client.getChar and client:getChar() or nil
    self.disableClientModel = false
    self.noBlur = not clientChar
    self.isLoadMode = false
    if IsValid(lia.gui.loading) then lia.gui.loading:Remove() end
    if IsValid(lia.gui.character) then lia.gui.character:Remove() end
    lia.gui.character = self
    if not render.oldDrawBeam then
        render.oldDrawBeam = render.DrawBeam
        render.DrawBeam = function(startPos, endPos, width, textureStart, textureEnd, color)
            if IsValid(lia.gui.character) then return end
            return render.oldDrawBeam(startPos, endPos, width, textureStart, textureEnd, color)
        end
    end

    hook.Add("PreDrawPhysgunBeam", "DisablePhysgunBeam", function() if IsValid(lia.gui.character) then return true end end)
    self:Dock(FILL)
    self:MakePopup()
    self:SetAlpha(0)
    self:AlphaTo(255, 0.2)
    self.tabs = self:Add("DPanel")
    self.tabs:Dock(TOP)
    self.tabs:DockMargin(64, 32, 64, 0)
    self.tabs:SetTall(48)
    self.tabs:SetPaintBackground(false)
    self.content = self:Add("DPanel")
    self.content:Dock(FILL)
    self.content:DockMargin(64, 0, 64, 64)
    self.content:SetPaintBackground(false)
    self.music = self:Add("liaCharBGMusic")
    self:createTitle()
    self:loadBackground()
    if clientChar and lia.characters and #lia.characters > 0 then
        for _, charID in ipairs(lia.characters) do
            local charObj = type(charID) == "number" and lia.char.loaded[charID] or charID
            if charObj and charObj.getID and clientChar and charObj:getID() == clientChar:getID() then
                self.currentIndex = _
                break
            end
        end

        self.currentIndex = self.currentIndex or 1
    end

    self:createStartButton()
end

function PANEL:createTitle()
    if self.tabs then self.tabs:DockMargin(64, 32, 64, 0) end
end

function PANEL:loadBackground()
    if self.isLoadMode then
        hook.Add("PrePlayerDraw", "liaCharacter_StopDrawPlayers", function() return true end)
        self:updateSelectedCharacter()
        if not IsValid(self.leftArrow) then self:createArrows() end
        hook.Add("CalcView", "liaCharacterMenuCalcView", function(_, _, _, fov)
            local ent = self.modelEntity
            if not IsValid(ent) then return end
            local center = ent:GetPos() + Vector(0, 0, 60)
            local desiredCamPos = center + ent:GetForward() * 70
            self.currentCamPos = self.currentCamPos or desiredCamPos
            self.currentCamPos = LerpVector(FrameTime() * 5, self.currentCamPos, desiredCamPos)
            return {
                origin = self.currentCamPos,
                angles = (center - self.currentCamPos):Angle(),
                fov = fov,
                drawviewer = true
            }
        end)
    else
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
        if url and url:find("%S") then
            self.background = self:Add("DHTML")
            self.background:SetSize(ScrW(), ScrH())
            if url:find("http") then
                self.background:OpenURL(url)
            else
                self.background:SetHTML(url)
            end

            self.background.OnDocumentReady = function() if IsValid(self.bgLoader) then self.bgLoader:AlphaTo(0, 2, 1, function() self.bgLoader:Remove() end) end end
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
end

function PANEL:createStartButton()
    local client = LocalPlayer()
    if not IsValid(client) then
        timer.Simple(0.1, function() if IsValid(self) then self:createStartButton() end end)
        return
    end

    local clientChar = client.getChar and client:getChar() or nil
    local sw, sh = ScrW(), ScrH()
    local btnWidth = sw * 0.2
    local btnHeight = sh * 0.04
    local btnSpacing = sh * 0.01
    local logoPath = lia.config.get("CenterLogo")
    local discordURL = lia.config.get("DiscordURL")
    local workshopURL = lia.config.get("Workshop")
    local buttonsData = {}
    if IsValid(client) and hook.Run("CanPlayerCreateChar", client) ~= false then
        table.insert(buttonsData, {
            id = "create",
            text = "CREATE CHARACTER",
            doClick = function()
                for _, v in pairs(self.buttons) do
                    if IsValid(v) then v:Remove() end
                end

                self:clickSound()
                self.isLoadMode = false
                self:showContent(true)
                self:createCharacterCreation()
            end
        })
    end

    if lia.characters and #lia.characters > 0 then
        table.insert(buttonsData, {
            id = "load",
            text = "LOAD CHARACTER",
            doClick = function()
                for _, v in pairs(self.buttons) do
                    if IsValid(v) then v:Remove() end
                end

                self:clickSound()
                self.isLoadMode = true
                self:showContent(true)
                self:createCharacterSelection()
            end
        })
    end

    if discordURL and discordURL ~= "" then
        table.insert(buttonsData, {
            id = "discord",
            text = "DISCORD",
            doClick = function()
                self:clickSound()
                gui.OpenURL(discordURL)
            end
        })
    end

    if workshopURL and workshopURL ~= "" then
        table.insert(buttonsData, {
            id = "workshop",
            text = "STEAM WORKSHOP",
            doClick = function()
                self:clickSound()
                gui.OpenURL(workshopURL)
            end
        })
    end

    table.insert(buttonsData, {
        id = "disconnect",
        text = "DISCONNECT",
        doClick = function()
            self:clickSound()
            RunConsoleCommand("disconnect")
        end
    })

    if clientChar then
        table.insert(buttonsData, {
            id = "return",
            text = "RETURN",
            doClick = function() self:Remove() end
        })
    end

    self.buttons = {}
    local function createButton(data, index)
        local x = sw / 2 - btnWidth / 2
        local y = sh * 0.3 + (index - 1) * (btnHeight + btnSpacing)
        local btn = self:Add("liaMediumButton")
        btn:SetSize(btnWidth, btnHeight)
        btn:SetPos(x, y)
        btn:SetText(data.text)
        btn.DoClick = data.doClick
        btn.OnCursorEntered = function() surface.PlaySound("ui/hover.wav") end
        local oldSetPos = btn.SetPos
        btn.SetPos = function(b, nx, ny)
            oldSetPos(b, nx, ny)
            if IsValid(self) then self:UpdateLogoPosition() end
        end

        self.buttons[data.id] = btn
    end

    for i, data in ipairs(buttonsData) do
        createButton(data, i)
    end

    if logoPath and logoPath ~= "" then
        local function setLogo(logo)
            if not IsValid(self) then return end
            logo:SetZPos(9999)
            self:UpdateLogoPosition()
            timer.Simple(0, function() if IsValid(logo) then logo:MoveToFront() end end)
        end

        if string.sub(logoPath, 1, 8) == "https://" then
            http.Fetch(logoPath, function(body)
                if not IsValid(self) then return end
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

function PANEL:addTab(name, callback, justClick)
    local button = self.tabs:Add("liaCharacterTabButton")
    button:setText(L(name):upper())
    if justClick then
        if isfunction(callback) then button.DoClick = function() callback(self) end end
        return button
    end

    button.DoClick = function(btn) btn:setSelected(true) end
    if isfunction(callback) then button:onSelected(function() callback(self) end) end
    return button
end

function PANEL:createTabs()
    self.tabs:Clear()
    self:addTab("return", function() self:backToMainMenu() end, true)
end

function PANEL:backToMainMenu()
    self:clickSound()
    if IsValid(self.infoFrame) then self.infoFrame:Remove() end
    if IsValid(self.leftArrow) then
        self.leftArrow:Remove()
        self.leftArrow = nil
    end

    if IsValid(self.rightArrow) then
        self.rightArrow:Remove()
        self.rightArrow = nil
    end

    self.isLoadMode = false
    self.disableClientModel = false
    self.content:Clear()
    self.tabs:Clear()
    self:createStartButton()
    self:loadBackground()
end

function PANEL:createCharacterSelection()
    self.isLoadMode = true
    if IsValid(self.background) then self.background:Remove() end
    if IsValid(self.logo) then self.logo:Remove() end
    if self.buttons then
        for _, b in pairs(self.buttons) do
            if IsValid(b) then b:Remove() end
        end
    end

    if IsValid(self.leftArrow) then
        self.leftArrow:Remove()
        self.leftArrow = nil
    end

    if IsValid(self.rightArrow) then
        self.rightArrow:Remove()
        self.rightArrow = nil
    end

    self.buttons = {}
    self.content:Clear()
    self.content:InvalidateLayout(true)
    self:updateSelectedCharacter()
    self:createArrows()
end

function PANEL:createCharacterCreation()
    if IsValid(self.background) then self.background:Remove() end
    if IsValid(self.logo) then self.logo:Remove() end
    if self.buttons then
        for _, b in pairs(self.buttons) do
            if IsValid(b) then b:Remove() end
        end
    end

    self.buttons = {}
    if IsValid(self.bgLoader) then self.bgLoader:Remove() end
    self.content:Clear()
    self.content:InvalidateLayout(true)
    self.content:Add("liaCharacterCreation")
end

function PANEL:updateSelectedCharacter()
    if not self.isLoadMode then return end
    local characters = lia.characters
    if not characters or #characters == 0 then return end
    self.currentIndex = self.currentIndex or 1
    local selected = characters[self.currentIndex] or characters[1]
    local character = lia.char.loaded[selected]
    if IsValid(self.infoFrame) then self.infoFrame:Remove() end
    self:createSelectedCharacterInfoPanel(character)
    self:updateModelEntity(character)
end

function PANEL:createSelectedCharacterInfoPanel(character)
    if not character then return end
    local info = {}
    table.insert(info, "Name: " .. (character:getName() or ""))
    table.insert(info, "Faction: " .. (team.GetName(character:getFaction()) or ""))
    if character:getClass() and lia.class.list[character:getClass()] and lia.class.list[character:getClass()].name then table.insert(info, "Class: " .. lia.class.list[character:getClass()].name) end
    table.insert(info, "Money: " .. lia.currency.get(character:getMoney()))
    hook.Run("LoadMainMenuInformation", info, character)
    table.insert(info, "Description:")
    table.insert(info, character:getDesc() or "")
    self.infoFrame = self:Add("DFrame")
    self.infoFrame:SetSize(ScrW() * 0.25, ScrH() * 0.45)
    self.infoFrame:SetPos(ScrW() - ScrW() * 0.25 - 50, ScrH() * 0.25)
    self.infoFrame:SetTitle("")
    self.infoFrame:SetDraggable(false)
    self.infoFrame:ShowCloseButton(false)
    local scroll = vgui.Create("DScrollPanel", self.infoFrame)
    scroll:Dock(FILL)
    local padding = 10
    for _, v in ipairs(info) do
        local label = scroll:Add("DLabel")
        label:Dock(TOP)
        label:DockMargin(padding, padding, padding, 0)
        label:SetFont("liaMediumFont")
        label:SetWrap(true)
        label:SetAutoStretchVertical(true)
        label:SetTextColor(Color(255, 255, 255))
        label:SetText(v)
        label:SizeToContentsY()
    end

    local buttonContainer = self.infoFrame:Add("DPanel")
    buttonContainer:Dock(BOTTOM)
    buttonContainer:SetTall(80)
    buttonContainer:SetPaintBackground(false)
    local deleteBtn = vgui.Create("DButton", buttonContainer)
    deleteBtn:Dock(BOTTOM)
    deleteBtn:SetTall(40)
    deleteBtn:SetText("Delete Character")
    deleteBtn.DoClick = function()
        self:clickSound()
        if hook.Run("CanDeleteChar", character:getID()) == false then
            LocalPlayer():notifyWarning("You cannot delete this character!")
            return
        end

        vgui.Create("liaCharacterConfirm"):setMessage(L("charDeletionCannotUndoned")):onConfirm(function() MainMenu:deleteCharacter(character:getID()) end)
    end

    local currentChar = LocalPlayer().getChar and LocalPlayer():getChar() or nil
    local buttonText = "Select Character"
    if currentChar and character:getID() == currentChar:getID() then buttonText = "You are already using this character" end
    if character:getData("banned") then buttonText = "This character is banned" end
    local actionBtn = vgui.Create("DButton", buttonContainer)
    actionBtn:Dock(TOP)
    actionBtn:SetTall(40)
    actionBtn:SetText(buttonText)
    if currentChar and character:getID() == currentChar:getID() or character:getData("banned") then
        actionBtn:SetEnabled(false)
        actionBtn:SetTextColor(Color(255, 255, 255))
    end

    actionBtn.DoClick = function()
        self:clickSound()
        MainMenu:chooseCharacter(character:getID())
        self:Remove()
    end
end

function PANEL:updateModelEntity(character)
    if IsValid(self.modelEntity) then self.modelEntity:Remove() end
    if not character then return end
    local modelPath = character.getModel and character:getModel() or LocalPlayer():GetModel()
    self.modelEntity = ClientsideModel(modelPath, RENDERGROUP_OPAQUE)
    if not IsValid(self.modelEntity) then return end
    self.modelEntity:SetNoDraw(false)
    local skin = character:getData("skin", 0)
    self.modelEntity:SetSkin(skin)
    local numBG = self.modelEntity:GetNumBodyGroups()
    local groups = character:getData("groups", {})
    for i = 0, numBG - 1 do
        local value = groups[i]
        if value ~= nil then self.modelEntity:SetBodygroup(i, value) end
    end

    local pos, ang = hook.Run("GetMainMenuPosition", character)
    if not pos or not ang then
        local spawns = ents.FindByClass("info_player_start")
        if #spawns > 0 then
            pos, ang = spawns[1]:GetPos(), spawns[1]:GetAngles()
        else
            pos, ang = Vector(), Angle()
        end
    end

    ang.pitch, ang.roll = 0, 0
    self.modelEntity:SetPos(pos)
    self.modelEntity:SetAngles(ang)
    for _, seq in ipairs(self.modelEntity:GetSequenceList()) do
        if seq:lower():find("idle") and seq ~= "idlenoise" then
            self.modelEntity:ResetSequence(seq)
            self.modelEntity:SetCycle(0)
            break
        end
    end

    hook.Run("ModifyCharacterModel", self.modelEntity, character)
    hook.Add("PostDrawOpaqueRenderables", self, function()
        if IsValid(self.modelEntity) then
            self.modelEntity:FrameAdvance(RealFrameTime())
            self.modelEntity:DrawModel()
        end
    end)
end

function PANEL:createArrows()
    local sw, sh = ScrW(), ScrH()
    local arrowSize = 80
    local space = 180
    self.leftArrow = self:Add("DButton")
    self.leftArrow:SetSize(arrowSize, arrowSize)
    self.leftArrow:SetPos(sw * 0.5 - arrowSize - space, sh * 0.5 - arrowSize * 0.5)
    self.leftArrow:SetText("<")
    self.leftArrow.DoClick = function()
        if not self.isLoadMode then return end
        local count = #lia.characters
        if count == 0 then return end
        self.currentIndex = (self.currentIndex or 1) - 1
        if self.currentIndex < 1 then self.currentIndex = count end
        self:clickSound()
        self:updateSelectedCharacter()
    end

    self.rightArrow = self:Add("DButton")
    self.rightArrow:SetSize(arrowSize, arrowSize)
    self.rightArrow:SetPos(sw * 0.5 + space, sh * 0.5 - arrowSize * 0.5)
    self.rightArrow:SetText(">")
    self.rightArrow.DoClick = function()
        if not self.isLoadMode then return end
        local count = #lia.characters
        if count == 0 then return end
        self.currentIndex = (self.currentIndex or 1) + 1
        if self.currentIndex > count then self.currentIndex = 1 end
        self:clickSound()
        self:updateSelectedCharacter()
    end
end

function PANEL:UpdateLogoPosition()
    if not IsValid(self.logo) then return end
    local sw, sh = ScrW(), ScrH()
    local btnSpacing = sh * 0.01
    local logoW = sw * 0.13
    local logoH = sw * 0.13
    local scaleFactor = 0.95
    local newLogoW = logoW * scaleFactor
    local newLogoH = logoH * scaleFactor
    local leftMost, rightMost, topY = math.huge, -math.huge, math.huge
    for _, v in pairs(self.buttons) do
        if IsValid(v) then
            local x, y = v:GetPos()
            local btnW = v:GetWide()
            leftMost = math.min(leftMost, x)
            rightMost = math.max(rightMost, x + btnW)
            topY = math.min(topY, y)
        end
    end

    if topY == math.huge then topY = sh / 2 end
    local groupCenter = (leftMost + rightMost) / 2
    local logoX = groupCenter - newLogoW * 0.5
    local logoY = topY - newLogoH - btnSpacing
    self.logo:SetPos(logoX, logoY)
    self.logo:SetSize(newLogoW, newLogoH)
end

function PANEL:showContent(disableBg)
    if IsValid(self.infoFrame) then self.infoFrame:Remove() end
    if IsValid(self.leftArrow) then self.leftArrow:Remove() end
    if IsValid(self.rightArrow) then self.rightArrow:Remove() end
    if IsValid(self.logo) then self.logo:Remove() end
    if self.buttons then
        for _, b in pairs(self.buttons) do
            if IsValid(b) then b:Remove() end
        end
    end

    self.buttons = {}
    self.disableClientModel = true
    self:removeClientModelModifications()
    if IsValid(self.modelEntity) then self.modelEntity:Remove() end
    self.tabs:Clear()
    self.content:Clear()
    self:createTabs()
    self.noBlur = self.isLoadMode or false
    if self.isLoadMode or not disableBg then self:loadBackground() end
end

function PANEL:removeClientModelModifications()
    hook.Remove("PrePlayerDraw", "liaCharacter_StopDrawPlayers")
    if not self.isLoadMode then hook.Remove("CalcView", "liaCharacterMenuCalcView") end
    hook.Remove("PostDrawOpaqueRenderables", self)
end

function PANEL:setFadeToBlack(fade)
    local d = deferred.new()
    if fade then
        if IsValid(self.fade) then self.fade:Remove() end
        local fadePanel = vgui.Create("DPanel")
        fadePanel:SetSize(ScrW(), ScrH())
        fadePanel:SetSkin("Default")
        fadePanel:SetBackgroundColor(color_black)
        fadePanel:SetAlpha(0)
        fadePanel:AlphaTo(255, 0.5, 0, function() d:resolve() end)
        fadePanel:SetZPos(999)
        fadePanel:MakePopup()
        self.fade = fadePanel
    else
        if IsValid(self.fade) then
            local fadePanel = self.fade
            fadePanel:AlphaTo(0, 0.5, 0, function()
                fadePanel:Remove()
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
    if not self.noBlur then lia.util.drawBlur(self) end
    self:paintBackground(w, h)
end

function PANEL:paintBackground(w, h)
    if IsValid(self.background) then return end
    if self.blank then
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

function PANEL:OnRemove()
    hook.Remove("PrePlayerDraw", "liaCharacter_StopDrawPlayers")
    hook.Remove("CalcView", "liaCharacterMenuCalcView")
    hook.Remove("PostDrawOpaqueRenderables", self)
    hook.Remove("PreDrawPhysgunBeam", "DisablePhysgunBeam")
    if render.oldDrawBeam then
        render.DrawBeam = render.oldDrawBeam
        render.oldDrawBeam = nil
    end

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