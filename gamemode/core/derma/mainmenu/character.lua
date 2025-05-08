local PANEL = {}
function PANEL:Init()
    local client = LocalPlayer()
    local clientChar = client.getChar and client:getChar()
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

    hook.Add("PreDrawPhysgunBeam", "DisablePhysgunBeam", function() return IsValid(lia.gui.character) end)
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
        for i, charID in ipairs(lia.characters) do
            local charObj = type(charID) == "number" and lia.char.loaded[charID] or charID
            if charObj and charObj.getID and charObj:getID() == clientChar:getID() then
                self.currentIndex = i
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
        if not IsValid(self.leftArrow) and #lia.characters > 1 then self:createArrows() end
        hook.Add("CalcView", "liaCharacterMenuCalcView", function(_, _, _, fov)
            local ent = self.modelEntity
            if not IsValid(ent) then return end
            local center = ent:GetPos() + Vector(0, 0, 60)
            local desired = center + ent:GetForward() * 70
            self.currentCamPos = self.currentCamPos and LerpVector(FrameTime() * 5, self.currentCamPos, desired) or desired
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

    local clientChar = client.getChar and client:getChar()
    local w, h, s = ScrW() * 0.2, ScrH() * 0.04, ScrH() * 0.01
    local logoPath, discordURL, workshopURL = lia.config.get("CenterLogo"), lia.config.get("DiscordURL"), lia.config.get("Workshop")
    local buttonsData = {}
    if hook.Run("CanPlayerCreateChar", client) ~= false then
        table.insert(buttonsData, {
            id = "create",
            text = L("createCharacter"),
            doClick = function()
                for _, b in pairs(self.buttons) do
                    if IsValid(b) then b:Remove() end
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
            text = L("loadCharacter"),
            doClick = function()
                for _, b in pairs(self.buttons) do
                    if IsValid(b) then b:Remove() end
                end

                self:clickSound()
                self.isLoadMode = true
                self:showContent(true)
                self:createCharacterSelection()
            end
        })
    end

    if discordURL ~= "" then
        table.insert(buttonsData, {
            id = "discord",
            text = L("discord"),
            doClick = function()
                self:clickSound()
                gui.OpenURL(discordURL)
            end
        })
    end

    if workshopURL ~= "" then
        table.insert(buttonsData, {
            id = "workshop",
            text = L("steamWorkshop"),
            doClick = function()
                self:clickSound()
                gui.OpenURL(workshopURL)
            end
        })
    end

    table.insert(buttonsData, {
        id = "disconnect",
        text = L("disconnect"),
        doClick = function()
            self:clickSound()
            RunConsoleCommand("disconnect")
        end
    })

    if clientChar then
        table.insert(buttonsData, {
            id = "return",
            text = L("return"),
            doClick = function() self:Remove() end
        })
    end

    self.buttons = {}
    for i, data in ipairs(buttonsData) do
        local x, y = ScrW() / 2 - w / 2, ScrH() * 0.3 + (i - 1) * (h + s)
        local btn = self:Add("liaMediumButton")
        btn:SetSize(w, h)
        btn:SetPos(x, y)
        btn:SetText(string.upper(data.text))
        btn.DoClick = data.doClick
        btn.OnCursorEntered = function() surface.PlaySound("ui/hover.wav") end
        local oldSetPos = btn.SetPos
        btn.SetPos = function(b, nx, ny)
            oldSetPos(b, nx, ny)
            if IsValid(self) then self:UpdateLogoPosition() end
        end

        self.buttons[data.id] = btn
    end

    if logoPath ~= "" then
        local function setLogo(img)
            if not IsValid(self) then return end
            img:SetZPos(9999)
            self:UpdateLogoPosition()
            timer.Simple(0, function() if IsValid(img) then img:MoveToFront() end end)
        end

        if logoPath:sub(1, 8) == "https://" then
            http.Fetch(logoPath, function(body)
                if not IsValid(self) then return end
                file.Write("temp_logo.png", body)
                self.logo = self:Add("DImage")
                self.logo:SetImage("data/temp_logo.png")
                setLogo(self.logo)
            end)
        else
            self.logo = self:Add("DImage")
            self.logo:SetImage(logoPath)
            setLogo(self.logo)
        end
    end
end

function PANEL:addTab(name, callback, justClick, height)
    local btn = self.tabs:Add("liaMediumButton")
    local label = L(name .. "Label"):upper()
    btn:SetText(label)
    surface.SetFont(btn:GetFont())
    local textW, textH = surface.GetTextSize(label)
    btn:SetWide(textW + 40)
    btn:SetTall(height or textH + 20)
    if justClick then
        if isfunction(callback) then btn.DoClick = function() callback(self) end end
        return btn
    end

    btn.DoClick = function(b) b:setSelected(true) end
    if isfunction(callback) then btn:onSelected(function() callback(self) end) end
    return btn
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
    for _, name in ipairs{"background", "logo"} do
        if IsValid(self[name]) then
            self[name]:Remove()
            self[name] = nil
        end
    end

    for _, b in pairs(self.buttons or {}) do
        if IsValid(b) then b:Remove() end
    end

    self.buttons = {}
    if IsValid(self.leftArrow) then
        self.leftArrow:Remove()
        self.leftArrow = nil
    end

    if IsValid(self.rightArrow) then
        self.rightArrow:Remove()
        self.rightArrow = nil
    end

    self.content:Clear()
    self.content:InvalidateLayout(true)
    self:updateSelectedCharacter()
    if #lia.characters > 1 then self:createArrows() end
end

function PANEL:createCharacterCreation()
    for _, name in ipairs{"background", "logo"} do
        if IsValid(self[name]) then
            self[name]:Remove()
            self[name] = nil
        end
    end

    for _, b in pairs(self.buttons or {}) do
        if IsValid(b) then b:Remove() end
    end

    self.buttons = {}
    if IsValid(self.bgLoader) then self.bgLoader:Remove() end
    self.content:Clear()
    self.content:InvalidateLayout(true)
    self.content:Add("liaCharacterCreation")
end

function PANEL:updateSelectedCharacter()
    if not self.isLoadMode then return end
    local chars = lia.characters
    if not chars or #chars == 0 then return end
    self.currentIndex = self.currentIndex or 1
    local sel = chars[self.currentIndex] or chars[1]
    local character = lia.char.loaded[sel]
    if IsValid(self.infoFrame) then self.infoFrame:Remove() end
    self:createSelectedCharacterInfoPanel(character)
    self:updateModelEntity(character)
end

function PANEL:createSelectedCharacterInfoPanel(character)
    if not character then return end
    local info = {L("name") .. ": " .. (character:getName() or ""), L("desc") .. ":", character:getDesc() or "", L("faction") .. ": " .. (team.GetName(character:getFaction()) or "")}
    if character:getClass() then
        local cls = lia.class.list[character:getClass()]
        if cls and cls.name then table.insert(info, L("class") .. ": " .. cls.name) end
    end

    table.insert(info, L("moneyLabel") .. ": " .. lia.currency.get(character:getMoney()))
    hook.Run("LoadMainMenuInformation", info, character)
    self.infoFrame = self:Add("SemiTransparentDFrame")
    self.infoFrame:SetSize(ScrW() * 0.25, ScrH() * 0.45)
    self.infoFrame:SetPos(ScrW() * 0.75 - 50, ScrH() * 0.25)
    self.infoFrame:SetTitle("")
    self.infoFrame:SetDraggable(false)
    self.infoFrame:ShowCloseButton(false)
    local scroll = vgui.Create("DScrollPanel", self.infoFrame)
    scroll:Dock(FILL)
    for _, text in ipairs(info) do
        local lbl = scroll:Add("DLabel")
        lbl:Dock(TOP)
        lbl:DockMargin(10, 10, 10, 0)
        lbl:SetFont("liaMediumFont")
        lbl:SetWrap(true)
        lbl:SetAutoStretchVertical(true)
        lbl:SetTextColor(Color(255, 255, 255))
        lbl:SetText(text)
        lbl:SizeToContentsY()
    end

    local btnCon = self.infoFrame:Add("DPanel")
    btnCon:Dock(BOTTOM)
    btnCon:SetTall(100)
    btnCon:SetPaintBackground(false)
    local frameW, frameH = self.infoFrame:GetWide(), btnCon:GetTall()
    local btnW, btnH = frameW * 0.75, 40
    local padding = 10
    local xPos = (frameW - btnW) / 2
    local topY = padding / 2
    local bottomY = frameH - btnH - padding
    local selectBtn = vgui.Create("liaSmallButton", btnCon)
    selectBtn:SetSize(btnW, btnH)
    selectBtn:SetPos(xPos, topY)
    local clientChar = LocalPlayer().getChar and LocalPlayer():getChar()
    local selectText = L("selectCharacter")
    if clientChar and character:getID() == clientChar:getID() then
        selectText = L("alreadyUsingCharacter")
    elseif character:getData("banned") then
        selectText = L("bannedCharacter")
    end

    selectBtn:SetText(selectText)
    if clientChar and character:getID() == clientChar:getID() or character:getData("banned") then
        selectBtn:SetEnabled(false)
        selectBtn:SetTextColor(Color(255, 255, 255))
    end

    selectBtn.DoClick = function()
        lia.module.list["mainmenu"]:chooseCharacter(character:getID())
        self:Remove()
    end

    local deleteBtn = vgui.Create("liaSmallButton", btnCon)
    deleteBtn:SetSize(btnW, btnH)
    deleteBtn:SetPos(xPos, bottomY)
    deleteBtn:SetText(L("deleteCharacter"))
    deleteBtn.DoClick = function()
        if hook.Run("CanDeleteChar", character:getID()) == false then
            LocalPlayer():notifyWarning(L("cannotDeleteChar"))
            return
        end

        vgui.Create("liaCharacterConfirm"):setMessage(L("charDeletionCannotUndone")):onConfirm(function() lia.module.list["mainmenu"]:deleteCharacter(character:getID()) end)
    end
end

function PANEL:updateModelEntity(character)
    if IsValid(self.modelEntity) then self.modelEntity:Remove() end
    if not character then return end
    local model = character.getModel and character:getModel() or LocalPlayer():GetModel()
    self.modelEntity = ClientsideModel(model, RENDERGROUP_OPAQUE)
    if not IsValid(self.modelEntity) then return end
    self.modelEntity:SetSkin(character:getData("skin", 0))
    for i = 0, self.modelEntity:GetNumBodyGroups() - 1 do
        local groups = character:getData("groups", {})
        if groups[i] then self.modelEntity:SetBodygroup(i, groups[i]) end
    end

    local pos, ang = hook.Run("GetMainMenuPosition", character)
    if not pos or not ang then
        local spawns = ents.FindByClass("info_player_start")
        pos = #spawns > 0 and spawns[1]:GetPos() or Vector()
        ang = #spawns > 0 and spawns[1]:GetAngles() or Angle()
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
    local size, space = 100, 240
    local function newArrow(sign, xOffset)
        local btn = self:Add("liaBigButton")
        btn:SetSize(size, size)
        btn:SetPos(ScrW() * 0.5 + xOffset, ScrH() * 0.5 - size * 0.5)
        btn:SetFont("liaHugeFont")
        btn:SetText(sign)
        btn.OnCursorEntered = function() surface.PlaySound("ui/hover.wav") end
        btn.DoClick = function()
            if not self.isLoadMode or not lia.characters or #lia.characters == 0 then return end
            self.currentIndex = self.currentIndex + (sign == "<" and -1 or 1)
            if self.currentIndex < 1 then self.currentIndex = #lia.characters end
            if self.currentIndex > #lia.characters then self.currentIndex = 1 end
            self:clickSound()
            self:updateSelectedCharacter()
        end
        return btn
    end

    self.leftArrow = newArrow("<", -size - space)
    self.rightArrow = newArrow(">", space)
end

function PANEL:UpdateLogoPosition()
    if not IsValid(self.logo) then return end
    local pad = ScrH() * 0.01
    local logoW, logoH = ScrW() * 0.13 * 0.95, ScrW() * 0.13 * 0.95
    local left, right, top = math.huge, -math.huge, math.huge
    for _, v in pairs(self.buttons) do
        if IsValid(v) then
            local x, y = v:GetPos()
            left, right, top = math.min(left, x), math.max(right, x + v:GetWide()), math.min(top, y)
        end
    end

    top = top == math.huge and ScrH() / 2 or top
    local center = (left + right) / 2
    self.logo:SetPos(center - logoW * 0.5, top - logoH - pad)
    self.logo:SetSize(logoW, logoH)
end

function PANEL:showContent(disableBg)
    if IsValid(self.infoFrame) then self.infoFrame:Remove() end
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

    for _, b in pairs(self.buttons or {}) do
        if IsValid(b) then b:Remove() end
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
    if not self.noBlur then lia.util.drawBlur(self) end
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