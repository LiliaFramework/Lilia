local PANEL = {}
local function isGeneratedCloseNode(node)
    if not istable(node) then return false end
    local nodeID = string.Trim(string.lower(tostring(node.dialogID or "")))
    return nodeID == "goodbye" or nodeID == "bye" or nodeID == "farewell" or nodeID == "close"
end

local function resolveThemeColor(value, fallback)
    if IsColor(value) then return value end
    if istable(value) and IsColor(value[1]) then return value[1] end
    return fallback
end

local function getThemeColors()
    local theme = lia.color.theme or {}
    local configured = lia.config and lia.config.get and lia.config.get("Color") or nil
    local accent = resolveThemeColor(theme.accent or theme.theme or configured, Color(45, 190, 170))
    local text = resolveThemeColor(theme.text, Color(225, 238, 238))
    return accent, text
end

local function drawPanel(x, y, w, h, radius, color, outline)
    if lia.derma and lia.derma.rect and lia.derma.SHAPE_IOS then
        lia.derma.rect(x, y, w, h):Rad(radius):Color(color):Shape(lia.derma.SHAPE_IOS):Draw()
        if outline then lia.derma.rect(x, y, w, h):Rad(radius):Color(outline):Shape(lia.derma.SHAPE_IOS):Outline(1):Draw() end
        return
    end

    draw.RoundedBox(radius, x, y, w, h, color)
    if outline then
        surface.SetDrawColor(outline)
        surface.DrawOutlinedRect(x, y, w, h, 1)
    end
end

local function drawIcon(material, x, y, size, color)
    if not material or material:IsError() then return end
    surface.SetMaterial(material)
    surface.SetDrawColor(color or color_white)
    surface.DrawTexturedRect(x, y, size, size)
end

local historyNPCIcon = Material("icon16/comments.png", "smooth")
local historyPlayerIcon = Material("icon16/user.png", "smooth")
function PANEL:Init()
    if IsValid(lia.dialog.vgui) then lia.dialog.vgui:Remove() end
    if IsValid(lia.dialog.historyFrame) then lia.dialog.historyFrame:Remove() end
    if IsValid(lia.dialog.backdrop) then lia.dialog.backdrop:Remove() end
    lia.dialog.vgui = self
    self.npcDisplayName = L("dialog")
    self.lastResponseText = ""
    self.pendingResponse = false
    self.hasHistoryMessage = false
    self.conversationStack = {}
    self.dialogGap = math.Clamp(ScrW() * 0.009, 10, 16)
    self.historyWidth = math.Clamp(ScrW() * 0.19, 240, 360)
    local dialogWidth = math.Clamp(ScrW() * 0.4, 440, 760)
    local availableWidth = math.max(ScrW() - 24, 480)
    if self.historyWidth + self.dialogGap + dialogWidth > availableWidth then
        self.historyWidth = math.Clamp(math.floor(availableWidth * 0.31), 200, 320)
        dialogWidth = math.max(availableWidth - self.historyWidth - self.dialogGap, 280)
    end

    local dialogHeight = math.Clamp(ScrH() * 0.5, 360, math.max(ScrH() - 24, 360))
    local totalWidth = self.historyWidth + self.dialogGap + dialogWidth
    local startX = math.max(math.floor((ScrW() - totalWidth) * 0.5), 12)
    local startY = math.max(math.floor((ScrH() - dialogHeight) * 0.5), 12)
    self:SetSize(dialogWidth, dialogHeight)
    self:SetPos(startX + self.historyWidth + self.dialogGap, startY)
    self:SetMouseInputEnabled(true)
    self:SetKeyboardInputEnabled(true)
    self:SetAlpha(0)
    self.Paint = function(_, w, h)
        local accent = getThemeColors()
        drawPanel(0, 0, w, h, 8, Color(4, 16, 21, 246), Color(accent.r, accent.g, accent.b, 145))
    end

    self.backdrop = vgui.Create("DPanel")
    self.backdrop:SetSize(ScrW(), ScrH())
    self.backdrop:SetPos(0, 0)
    self.backdrop:SetMouseInputEnabled(false)
    self.backdrop:SetKeyboardInputEnabled(false)
    self.backdrop:SetAlpha(0)
    self.backdrop.Paint = function(panel, w, h)
        if lia.util and lia.util.drawBlackBlur then lia.util.drawBlackBlur(panel, 1, 4, 255, 155) end
        surface.SetDrawColor(0, 8, 10, 72)
        surface.DrawRect(0, 0, w, h)
    end

    self.backdrop:MoveToBack()
    self.backdrop:AlphaTo(255, 0.2, 0)
    lia.dialog.backdrop = self.backdrop
    self.dialogHistoryFrame = vgui.Create("EditablePanel")
    self.dialogHistoryFrame:SetSize(self.historyWidth, dialogHeight)
    self.dialogHistoryFrame:SetPos(startX, startY)
    self.dialogHistoryFrame:SetMouseInputEnabled(true)
    self.dialogHistoryFrame:SetKeyboardInputEnabled(false)
    self.dialogHistoryFrame:SetAlpha(0)
    self.dialogHistoryFrame.Paint = function(_, w, h)
        local accent = getThemeColors()
        drawPanel(0, 0, w, h, 8, Color(4, 16, 21, 246), Color(accent.r, accent.g, accent.b, 145))
    end

    lia.dialog.historyFrame = self.dialogHistoryFrame
    self.historyHeader = self.dialogHistoryFrame:Add("DPanel")
    self.historyHeader:Dock(TOP)
    self.historyHeader:SetTall(58)
    self.historyHeader.Paint = function(_, w, h)
        local accent = getThemeColors()
        draw.SimpleText(string.upper(L("history")), "LiliaFont.18", 18, 20, accent, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        surface.SetDrawColor(accent.r, accent.g, accent.b, 78)
        surface.DrawRect(16, h - 1, w - 32, 1)
    end

    self.dialogHistoryScroll = self.dialogHistoryFrame:Add("liaScrollPanel")
    self.dialogHistoryScroll:Dock(FILL)
    self.dialogHistoryScroll:DockMargin(14, 12, 10, 14)
    self.dialogHistoryScroll:DockPadding(0, 0, 4, 0)
    self.dialogHistoryScroll.Paint = function() end
    self.dialogHistoryList = self.dialogHistoryScroll:Add("DListLayout")
    self.dialogHistoryList:Dock(TOP)
    self.header = self:Add("DPanel")
    self.header:Dock(TOP)
    self.header:SetMouseInputEnabled(true)
    self.header:SetTall(58)
    self.header.Paint = function(_, w, h)
        local accent = getThemeColors()
        draw.SimpleText(string.upper(tostring(self.npcDisplayName or L("dialog"))), "LiliaFont.18", 18, 20, accent, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        surface.SetDrawColor(accent.r, accent.g, accent.b, 78)
        surface.DrawRect(16, h - 1, w - 32, 1)
    end

    self.closeButton = self.header:Add("DButton")
    self.closeButton:Dock(RIGHT)
    self.closeButton:SetWide(52)
    self.closeButton:SetText("")
    self.closeButton.Paint = function(button, w, h)
        local accent = getThemeColors()
        local hovered = button:IsHovered()
        if hovered then drawPanel(6, 8, w - 12, h - 16, 5, Color(accent.r, accent.g, accent.b, 24), Color(accent.r, accent.g, accent.b, 72)) end
        draw.SimpleText("X", "LiliaFont.20", w * 0.5, h * 0.5, hovered and Color(244, 248, 248) or Color(170, 192, 193), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    self.closeButton.DoClick = function() self:Remove() end
    self.header.OnMousePressed = function(header, code)
        if code ~= MOUSE_LEFT then return end
        local x, y = self:LocalCursorPos()
        self.dragging = true
        self.dragOffsetX = x
        self.dragOffsetY = y
        header:MouseCapture(true)
    end

    self.header.OnMouseReleased = function(header, code)
        if code ~= MOUSE_LEFT then return end
        self.dragging = false
        header:MouseCapture(false)
    end

    self.header.Think = function(header)
        if not self.dragging then return end
        if not input.IsMouseDown(MOUSE_LEFT) then
            self.dragging = false
            header:MouseCapture(false)
            return
        end

        local mouseX, mouseY = gui.MousePos()
        local x = math.Clamp(mouseX - self.dragOffsetX, self.historyWidth + self.dialogGap + 12, ScrW() - self:GetWide() - 12)
        local y = math.Clamp(mouseY - self.dragOffsetY, 12, ScrH() - self:GetTall() - 12)
        self:SetPos(x, y)
        self:SyncHistoryFrame()
    end

    self.content = self:Add("DPanel")
    self.content:Dock(FILL)
    self.content:DockMargin(16, 14, 16, 16)
    self.content.Paint = function() end
    self.dialogOptions = self.content:Add("liaScrollPanel")
    self.dialogOptions:Dock(BOTTOM)
    self.dialogOptions:SetTall(0)
    self.dialogOptions:SetZPos(4)
    self.dialogOptions:DockPadding(8, 0, 8, 0)
    self.dialogOptions.Paint = function() end
    self.responseScroll = self.content:Add("liaScrollPanel")
    self.responseScroll:Dock(FILL)
    self.responseScroll:DockMargin(8, 8, 8, 16)
    self.responseScroll:DockPadding(0, 0, 4, 0)
    self.responseScroll.Paint = function() end
    local canvas = self.dialogOptions:GetCanvas()
    if IsValid(canvas) then
        canvas.Paint = function() end
        canvas.PerformLayout = function(canvasPanel)
            if canvasPanel.BaseClass and canvasPanel.BaseClass.PerformLayout then canvasPanel.BaseClass.PerformLayout(canvasPanel) end
            canvasPanel:SizeToChildren(false, true)
        end
    end

    local responseCanvas = self.responseScroll:GetCanvas()
    if IsValid(responseCanvas) then responseCanvas.Paint = function() end end
    self.responseText = self.responseScroll:Add("DLabel")
    self.responseText:Dock(TOP)
    self.responseText:SetWrap(true)
    self.responseText:SetAutoStretchVertical(true)
    self.responseText:SetFont("LiliaFont.30")
    self.responseText:SetTextColor(self:GetSpeakerColor(false))
    self.responseText:SetText("")
    self.responseText:SetContentAlignment(7)
    self.responseText.PerformLayout = function(label)
        if IsValid(label:GetParent()) then
            local width = math.max(label:GetParent():GetWide() - 8, 1)
            if label:GetWide() ~= width then label:SetWide(width) end
        end

        if label.BaseClass and label.BaseClass.PerformLayout then label.BaseClass.PerformLayout(label) end
    end

    hook.Add("OnThemeChanged", self, self.OnThemeChanged)
    self.dialogHistoryFrame:MakePopup()
    self:MakePopup()
    self.dialogHistoryFrame:SetKeyboardInputEnabled(false)
    self:AlphaTo(255, 0.2, 0)
    self.dialogHistoryFrame:AlphaTo(255, 0.2, 0)
end

function PANEL:Think()
    if IsValid(self.backdrop) then if self.backdrop:GetWide() ~= ScrW() or self.backdrop:GetTall() ~= ScrH() then self.backdrop:SetSize(ScrW(), ScrH()) end end
end

function PANEL:SyncHistoryFrame()
    if not IsValid(self.dialogHistoryFrame) then return end
    local x, y = self:GetPos()
    self.dialogHistoryFrame:SetSize(self.historyWidth, self:GetTall())
    self.dialogHistoryFrame:SetPos(x - self.historyWidth - self.dialogGap, y)
end

function PANEL:OnThemeChanged()
    if IsValid(self.header) then self.header:InvalidateLayout(true) end
    if IsValid(self.historyHeader) then self.historyHeader:InvalidateLayout(true) end
    if IsValid(self.responseText) then self.responseText:SetTextColor(self:GetSpeakerColor(false)) end
end

function PANEL:OnKeyCodePressed(key)
    if key == KEY_ESCAPE then self:Remove() end
end

function PANEL:SetDialogText(text)
    self:ResetConversationHistory(text)
end

function PANEL:SetDialogTitle(title)
    self.npcDisplayName = title or L("dialog")
    if IsValid(self.header) then self.header:InvalidateLayout(true) end
end

function PANEL:ClearDialogOptions()
    if not IsValid(self.dialogOptions) then return end
    local canvas = self.dialogOptions.GetCanvas and self.dialogOptions:GetCanvas()
    if IsValid(canvas) then
        canvas:Clear()
    elseif self.dialogOptions.Clear then
        self.dialogOptions:Clear()
    end
end

function PANEL:GetSpeakerColor(isPlayer)
    local accent, text = getThemeColors()
    return isPlayer and accent or text
end

function PANEL:ScrollHistoryToBottom()
    if not IsValid(self.dialogHistoryScroll) then return end
    local scrollBar = self.dialogHistoryScroll:GetVBar()
    if not IsValid(scrollBar) then return end
    timer.Simple(0, function() if IsValid(scrollBar) then scrollBar:SetScroll(scrollBar.CanvasSize) end end)
end

function PANEL:AppendDialogLine(text, isPlayer, skipResponseUpdate)
    if not text or text == "" or not IsValid(self.dialogHistoryList) then return end
    local speaker = isPlayer and L("you") or self.npcDisplayName or L("dialog")
    local accent = getThemeColors()
    local isFirstMessage = not self.hasHistoryMessage
    self.hasHistoryMessage = true
    local container = self.dialogHistoryList:Add("DPanel")
    container:Dock(TOP)
    container:DockMargin(0, isFirstMessage and 2 or 0, 4, 14)
    container:SetTall(54)
    container.Paint = function() end
    local icon = container:Add("DPanel")
    icon:SetSize(24, 24)
    icon.Paint = function(_, w, h) drawIcon(isPlayer and historyPlayerIcon or historyNPCIcon, 0, 0, math.min(w, h), isPlayer and accent or Color(190, 207, 207)) end
    local speakerLabel = container:Add("DLabel")
    speakerLabel:SetFont("LiliaFont.18")
    speakerLabel:SetTextColor(accent)
    speakerLabel:SetText(speaker)
    speakerLabel:SetContentAlignment(4)
    local messageLabel = container:Add("DLabel")
    messageLabel:SetFont("LiliaFont.17")
    messageLabel:SetTextColor(Color(195, 211, 212))
    messageLabel:SetText(tostring(text))
    messageLabel:SetWrap(true)
    messageLabel:SetAutoStretchVertical(true)
    messageLabel:SetContentAlignment(7)
    container.PerformLayout = function(panel, w)
        local width = math.max(w, panel:GetParent():GetWide())
        local textWidth = math.max(width - 38, 80)
        icon:SetPos(0, 4)
        speakerLabel:SetPos(38, 0)
        speakerLabel:SetSize(textWidth, 22)
        messageLabel:SetPos(38, 24)
        messageLabel:SetWide(textWidth)
        messageLabel:InvalidateLayout(true)
        messageLabel:SizeToContentsY()
        panel:SetTall(math.max(54, messageLabel:GetTall() + 28))
    end

    container:InvalidateLayout(true)
    timer.Simple(0, function()
        if not IsValid(container) or not IsValid(self.dialogHistoryList) then return end
        container:SetWide(math.max(self.dialogHistoryList:GetWide() - 4, 1))
        container:InvalidateLayout(true)
        self.dialogHistoryList:InvalidateLayout(true)
        self:ScrollHistoryToBottom()
    end)

    if not isPlayer and not skipResponseUpdate then
        self.lastResponseText = text
        self:UpdateResponseText(text)
    end
end

function PANEL:ResetConversationHistory(initialText)
    if not IsValid(self.dialogHistoryList) then return end
    self.dialogHistoryList:Clear()
    self.hasHistoryMessage = false
    if initialText and initialText ~= "" then
        self:AppendDialogLine(initialText, false)
    else
        self:UpdateResponseText("")
    end
end

function PANEL:UpdateResponseText(text)
    if not IsValid(self.responseText) then return end
    self.responseText:SetText(text or "")
    self.responseText:InvalidateLayout(true)
    self.responseText:SizeToChildren(false, true)
    if IsValid(self.responseScroll) then
        local scrollBar = self.responseScroll:GetVBar()
        if IsValid(scrollBar) then scrollBar:SetScroll(0) end
    end
end

function PANEL:DisplayResponsePayload(payload)
    if payload == nil then return end
    if istable(payload) then
        local lines = {}
        for _, line in ipairs(payload) do
            if line ~= nil then table.insert(lines, tostring(line)) end
        end

        if #lines > 0 then
            local combinedText = table.concat(lines, "\n")
            self:AppendDialogLine(combinedText, false)
        end
        return
    end

    local payloadStr = tostring(payload)
    self:AppendDialogLine(payloadStr, false)
end

function PANEL:HandleResponse(info, npc, label)
    if not info then return end
    if info.Response then
        self:DisplayResponsePayload(info.Response)
        return
    end

    local targetNPC = IsValid(npc) and npc or self.activeNPC
    if IsValid(targetNPC) and targetNPC.uniqueID and self.activeConversation then
        local storedData = lia.dialog.getNPCData(targetNPC.uniqueID)
        if storedData and storedData.Conversation then
            local storedOption = storedData.Conversation[label]
            if storedOption and storedOption.Response then
                self:DisplayResponsePayload(storedOption.Response)
                return
            end
        end
    end

    local shouldRequest = (info.hasResponse == true) or (not info.Response and not info.noResponse and IsValid(targetNPC))
    if shouldRequest and IsValid(targetNPC) then
        self.pendingResponse = true
        local requestTime = CurTime()
        self.lastResponseRequest = {
            time = requestTime,
            label = label
        }

        net.Start("liaNpcDialogRequestResponse")
        net.WriteEntity(targetNPC)
        net.WriteString(label)
        net.SendToServer()
        timer.Simple(2, function() if IsValid(self) and self.pendingResponse and self.lastResponseRequest and self.lastResponseRequest.time == requestTime then self.pendingResponse = false end end)
    end
end

function PANEL:DisplayServerResponse(responses)
    if self.closingForGoodbye then return end
    self.pendingResponse = false
    if self.lastResponseRequest then self.lastResponseRequest = nil end
    self:DisplayResponsePayload(responses)
end

function PANEL:PerformLayout(w, h)
    if IsValid(self.content) and IsValid(self.dialogOptions) then
        local canvas = self.dialogOptions:GetCanvas()
        local buttonsHeight = 0
        if IsValid(canvas) then
            canvas:SizeToChildren(false, true)
            buttonsHeight = canvas:GetTall()
        end

        local maximumHeight = math.max(math.floor(self.content:GetTall() * 0.55), 64)
        local targetHeight = buttonsHeight > 0 and math.Clamp(buttonsHeight + 4, 64, maximumHeight) or 0
        if self.dialogOptions:GetTall() ~= targetHeight then self.dialogOptions:SetTall(targetHeight) end
    end

    self:SyncHistoryFrame()
end

function PANEL:OnRemove()
    hook.Remove("OnThemeChanged", self)
    if IsValid(self.dialogHistoryFrame) then self.dialogHistoryFrame:Remove() end
    if IsValid(self.backdrop) then self.backdrop:Remove() end
    if lia.dialog.historyFrame == self.dialogHistoryFrame then lia.dialog.historyFrame = nil end
    if lia.dialog.backdrop == self.backdrop then lia.dialog.backdrop = nil end
    if lia.dialog.vgui == self then lia.dialog.vgui = nil end
end

function PANEL:BuildGeneratedOptions(nodeOptions)
    local options = {}
    for _, node in ipairs(nodeOptions or {}) do
        local label = node.playerText ~= "" and node.playerText or node.dialogID or node.id
        options[#options + 1] = {
            label = label,
            nodeID = node.id,
            closeDialog = isGeneratedCloseNode(node)
        }
    end
    return options
end

function PANEL:LoadGeneratedDialog(dialogData)
    if not istable(dialogData) or not istable(dialogData.GeneratedDialog) then return end
    local generatedDialog = dialogData.GeneratedDialog
    local startNode = lia.dialog.getGeneratedStartNode and lia.dialog.getGeneratedStartNode(generatedDialog)
    if not startNode then return end
    self.generatedDialog = generatedDialog
    self.currentGeneratedNodeID = startNode.id
    self.generatedOptions = self:BuildGeneratedOptions(lia.dialog.getGeneratedChildNodes and lia.dialog.getGeneratedChildNodes(generatedDialog, startNode.id) or {})
    self:SetDialogText(startNode.npcText or "")
    self:ClearDialogOptions()
    self:AddDialogOptions(self.generatedOptions, self.activeNPC, true)
    if startNode.soundPath and startNode.soundPath ~= "" then surface.PlaySound(startNode.soundPath) end
end

function PANEL:HandleGeneratedDialogResult(result)
    if not istable(result) then return end
    self.pendingResponse = false
    if result.npcText and result.npcText ~= "" then self:AppendDialogLine(result.npcText, false) end
    if result.soundPath and result.soundPath ~= "" then surface.PlaySound(result.soundPath) end
    if result.closeDialog then
        self.closingForGoodbye = true
        self:Remove()
        return
    end

    if result.success then self.currentGeneratedNodeID = result.selectedNodeID or self.currentGeneratedNodeID end
    self.generatedOptions = result.options or self.generatedOptions or {}
    self:ClearDialogOptions()
    self:AddDialogOptions(self.generatedOptions, self.activeNPC, true)
end

function PANEL:AddDialogOptions(options, npc, skipBackButton)
    local function labelMatches(text, ...)
        local normalized = string.Trim(string.lower(tostring(text or "")))
        for i = 1, select("#", ...) do
            local candidate = select(i, ...)
            if normalized == string.Trim(string.lower(tostring(candidate or ""))) then return true end
        end
        return false
    end

    local ply = LocalPlayer()
    if isfunction(options) then options = options(ply, npc) end
    local validOptions = {}
    if not istable(options) then return end
    for label, info in pairs(options) do
        if istable(info) and info.label ~= nil then
            table.insert(validOptions, {
                label = tostring(info.label),
                info = info
            })
        else
            table.insert(validOptions, {
                label = tostring(label),
                info = istable(info) and info or {}
            })
        end
    end

    if not skipBackButton and #self.conversationStack > 0 then
        table.insert(validOptions, {
            label = L("back"),
            info = {
                Response = "",
                isAutoBack = true
            }
        })
    end

    table.sort(validOptions, function(a, b)
        local labelA = string.lower(tostring(a.label or ""))
        local labelB = string.lower(tostring(b.label or ""))
        local aIsAdmin = labelA:find("^%[admin%]") or labelA:find("^%[admin%]:")
        local bIsAdmin = labelB:find("^%[admin%]") or labelB:find("^%[admin%]:")
        if aIsAdmin and not bIsAdmin then return true end
        if bIsAdmin and not aIsAdmin then return false end
        local aIsBack = a.info.isAutoBack and labelMatches(a.label, "back", L("back"), "return", L("returnText"))
        local bIsBack = b.info.isAutoBack and labelMatches(b.label, "back", L("back"), "return", L("returnText"))
        if aIsBack and not bIsBack then return true end
        if bIsBack and not aIsBack then return false end
        local aIsGoodbye = a.info.closeDialog or labelMatches(a.label, "goodbye", "bye", "farewell", "close", L("close"))
        local bIsGoodbye = b.info.closeDialog or labelMatches(b.label, "goodbye", "bye", "farewell", "close", L("close"))
        if aIsGoodbye and not bIsGoodbye then return false end
        if bIsGoodbye and not aIsGoodbye then return true end
        return labelA < labelB
    end)

    for _, option in ipairs(validOptions) do
        local label = option.label
        local info = option.info
        local choiceBtn = self.dialogOptions:Add("DButton")
        choiceBtn:Dock(TOP)
        choiceBtn:DockMargin(0, 0, 0, 10)
        choiceBtn:SetTall(56)
        choiceBtn:SetText("")
        choiceBtn:SetCursor("hand")
        choiceBtn.Paint = function(button, w, h)
            local accent = getThemeColors()
            local hovered = button:IsHovered()
            local pressed = button:IsDown()
            local background = pressed and Color(18, 39, 45, 248) or hovered and Color(14, 34, 40, 246) or Color(8, 25, 30, 238)
            local outlineAlpha = pressed and 185 or hovered and 145 or 76
            drawPanel(0, 0, w, h, 6, background, Color(accent.r, accent.g, accent.b, outlineAlpha))
            if hovered or pressed then
                surface.SetDrawColor(accent.r, accent.g, accent.b, pressed and 255 or 210)
                surface.DrawRect(0, 7, 3, h - 14)
            end

            draw.SimpleText(label, "LiliaFont.22", w * 0.5, h * 0.5, Color(238, 245, 245), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        choiceBtn.DoClick = function()
            if lia.websound and lia.websound.playButtonSound then lia.websound.playButtonSound() end
            if info.nodeID and self.generatedDialog then
                self:AppendDialogLine(label, true)
                self.pendingResponse = true
                self.generatedClosingNode = info.closeDialog or false
                net.Start("liaNpcDialogNodeSelect")
                net.WriteEntity(IsValid(npc) and npc or self.activeNPC)
                net.WriteString(info.nodeID)
                net.WriteString(self.currentGeneratedNodeID or "")
                net.SendToServer()
                return
            end

            local isGoodbye = info.closeDialog or labelMatches(label, "goodbye", "bye", "farewell", "close", L("close"))
            local isBack = labelMatches(label, "back", L("back"), "return", L("returnText"))
            if isBack and info.isAutoBack then
                self:AppendDialogLine(label, true)
                if #self.conversationStack > 0 then
                    local previousLevel = table.remove(self.conversationStack)
                    self:ClearDialogOptions()
                    self:AddDialogOptions(previousLevel.options, previousLevel.npc, false)
                    return
                end
                return
            end

            self:AppendDialogLine(label, true)
            if isGoodbye then
                self.closingForGoodbye = true
                if info.Callback and not info.serverOnly then info.Callback(ply, npc) end
                if info.serverOnly then
                    local targetNPC = IsValid(npc) and npc or self.activeNPC
                    if IsValid(targetNPC) then
                        net.Start("liaNpcDialogServerCallback")
                        net.WriteEntity(targetNPC)
                        net.WriteString(label)
                        net.SendToServer()
                    end
                end

                self:Remove()
                return
            end

            if isBack and info.Callback and not info.serverOnly then
                info.Callback(ply, npc)
                return
            end

            self:HandleResponse(info, npc, label)
            if info.Callback and not info.serverOnly then info.Callback(ply, npc) end
            if info.serverOnly then
                local targetNPC = IsValid(npc) and npc or self.activeNPC
                if IsValid(targetNPC) then
                    net.Start("liaNpcDialogServerCallback")
                    net.WriteEntity(targetNPC)
                    net.WriteString(label)
                    net.SendToServer()
                end
            end

            if info.options then
                local nextOptions = info.options
                if isfunction(nextOptions) then nextOptions = nextOptions(ply, npc) end
                if nextOptions and istable(nextOptions) then
                    table.insert(self.conversationStack, {
                        options = options,
                        npc = npc
                    })

                    self:ClearDialogOptions()
                    self:AddDialogOptions(nextOptions, npc, false)
                    return
                end
            end

            if self.pendingResponse then return end
            local shouldClose = info.closeDialog or false
            if shouldClose or info.keepOpen == false then
                timer.Simple(0.1, function() if IsValid(self) then self:Remove() end end)
                return
            end
            return
        end
    end

    timer.Simple(0, function() if IsValid(self) and IsValid(self.dialogOptions) then self:InvalidateLayout(true) end end)
end

function PANEL:LoadNPCDialog(convoSettings, npc)
    if not convoSettings then return end
    local dialogText = convoSettings.Greeting or convoSettings.text or convoSettings.description or convoSettings.dialog or ""
    self.activeNPC = npc
    self.activeConversation = convoSettings
    self.generatedDialog = nil
    self.currentGeneratedNodeID = nil
    self.generatedOptions = nil
    self.conversationStack = {}
    self:SetDialogText(dialogText)
    self:ClearDialogOptions()
    if convoSettings.GeneratedDialog then
        self:LoadGeneratedDialog(convoSettings)
    elseif convoSettings.Conversation then
        self:AddDialogOptions(convoSettings.Conversation, npc, false)
    end
end

vgui.Register("liaDialogMenu", PANEL, "EditablePanel")