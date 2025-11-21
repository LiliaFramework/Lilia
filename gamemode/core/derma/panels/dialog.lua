local PANEL = {}
function PANEL:Init()
    if IsValid(lia.dialog.vgui) then lia.dialog.vgui:Remove() end
    lia.dialog.vgui = self
    self:SetTitle("Dialog")
    self:SetSize(ScrW() * 0.4, ScrH() * 0.45)
    self:Center()
    self:ShowCloseButton(true)
    self:MakePopup()
    self:SetDraggable(true)
    self:SetMouseInputEnabled(true)
    if IsValid(lia.dialog.historyFrame) then lia.dialog.historyFrame:Remove() end
    self.dialogHistoryFrame = vgui.Create("liaFrame")
    self.dialogHistoryFrame:SetTitle("History")
    self.dialogHistoryFrame:ShowCloseButton(false)
    local historyW = ScrW() * 0.2
    self.dialogHistoryFrame:SetSize(historyW, ScrH() * 0.45)
    lia.dialog.historyFrame = self.dialogHistoryFrame
    self.dialogHistoryFrame:MakePopup()
    timer.Simple(0, function()
        if not IsValid(self) or not IsValid(self.dialogHistoryFrame) then return end
        local _, dialogY = self:GetPos()
        local dialogW = self:GetWide()
        local historyWidth = ScrW() * 0.2
        local totalW = historyWidth + 6 + dialogW
        local startX = (ScrW() - totalW) / 2
        local y = dialogY
        self.dialogHistoryFrame:SetPos(startX, y)
        self:SetPos(startX + historyWidth + 6, y)
    end)

    self.dialogHistoryScroll = self.dialogHistoryFrame:Add("liaScrollPanel")
    self.dialogHistoryScroll:Dock(FILL)
    self.dialogHistoryScroll:DockMargin(6, 6, 6, 6)
    self.dialogHistoryScroll:DockPadding(2, 10, 2, 2)
    self.dialogHistoryList = self.dialogHistoryScroll:Add("DListLayout")
    self.dialogHistoryList:Dock(TOP)
    self.content = self:Add("DPanel")
    self.content:Dock(FILL)
    self.content:SetZPos(2)
    self.content:DockMargin(6, 6, 6, 6)
    self.content:DockPadding(6, 6, 6, 6)
    self.content:SetPaintBackground(false)
    self.dialogOptions = self.content:Add("liaScrollPanel")
    self.dialogOptions:Dock(BOTTOM)
    self.dialogOptions:SetTall(0)
    self.dialogOptions:SetZPos(4)
    self.dialogOptions:DockMargin(0, 0, 0, 0)
    self.dialogOptions:DockPadding(2, 2, 2, 2)
    self.responseScroll = self.content:Add("liaScrollPanel")
    self.responseScroll:Dock(FILL)
    self.responseScroll:DockMargin(0, 0, 0, 8)
    self.responseScroll:DockPadding(2, 2, 2, 2)
    local canvas = self.dialogOptions:GetCanvas()
    if IsValid(canvas) and canvas.SizeToChildren then
        canvas.PerformLayout = function(canvasPanel)
            if canvasPanel.BaseClass and canvasPanel.BaseClass.PerformLayout then canvasPanel.BaseClass.PerformLayout(canvasPanel) end
            canvasPanel:SizeToChildren(false, true)
        end
    end

    self.responseText = self.responseScroll:Add("DLabel")
    self.responseText:Dock(TOP)
    self.responseText:SetWrap(true)
    self.responseText:SetAutoStretchVertical(true)
    self.responseText:SetFont("LiliaFont.28")
    self.responseText:SetTextColor(self:GetSpeakerColor(false))
    self.responseText:SetText("")
    self.responseText:SetTall(0)
    self.responseText:SetContentAlignment(4)
    self.responseText.PerformLayout = function(label)
        if IsValid(label:GetParent()) then
            local parentW = label:GetParent():GetWide()
            if parentW > 0 and label:GetWide() ~= parentW then label:SetWide(parentW) end
        end

        if label.BaseClass and label.BaseClass.PerformLayout then label.BaseClass.PerformLayout(label) end
    end

    self.npcDisplayName = "Dialog"
    self.lastResponseText = ""
    self.pendingResponse = false
    self.hasHistoryMessage = false
    self.conversationStack = {}
end

function PANEL:Think()
end

function PANEL:SetDialogText(text)
    self:ResetConversationHistory(text)
end

function PANEL:SetDialogTitle(title)
    local resolved = title or "Dialog"
    self.npcDisplayName = resolved
    self:SetTitle(resolved)
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
    local theme = lia.color.theme or {}
    if isPlayer then
        local accent = theme.accent
        if istable(accent) then return accent[1] end
        return accent or Color(180, 210, 255)
    end

    local textColor = theme.text
    if istable(textColor) then return textColor[1] end
    return textColor or color_white
end

function PANEL:ScrollHistoryToBottom()
    if not IsValid(self.dialogHistoryScroll) then return end
    local scrollBar = self.dialogHistoryScroll:GetVBar()
    if not IsValid(scrollBar) then return end
    timer.Simple(0, function() if IsValid(scrollBar) then scrollBar:SetScroll(scrollBar.CanvasSize) end end)
end

function PANEL:AppendDialogLine(text, isPlayer, skipResponseUpdate)
    if not text or text == "" or not IsValid(self.dialogHistoryList) then return end
    local prefix
    if isPlayer then
        local ply = LocalPlayer()
        prefix = (IsValid(ply) and ply:Name()) or "You"
    else
        prefix = self.npcDisplayName or self:GetTitle()
    end

    local formatted = prefix and prefix ~= "" and (prefix .. ": " .. text) or text
    local isFirstMessage = not self.hasHistoryMessage
    self.hasHistoryMessage = true
    local container = self.dialogHistoryList:Add("DPanel")
    container:SetPaintBackground(false)
    container:SetTall(0)
    container:Dock(TOP)
    container:DockMargin(0, isFirstMessage and 4 or 2, 0, 2)
    container.dialogHistoryScroll = self.dialogHistoryScroll
    container.dialogHistoryList = self.dialogHistoryList
    function container:PerformLayout()
        if IsValid(self.dialogHistoryScroll) then
            local scrollW = self.dialogHistoryScroll:GetWide()
            if scrollW > 0 then
                local scrollBar = self.dialogHistoryScroll:GetVBar()
                local actualW = scrollW
                if IsValid(scrollBar) and scrollBar:IsVisible() then actualW = scrollW - scrollBar:GetWide() end
                actualW = actualW - 12
                if actualW > 0 and self:GetWide() ~= actualW then self:SetWide(actualW) end
            end
        end
    end

    local label = container:Add("DLabel")
    label:Dock(TOP)
    label:SetWrap(true)
    label:SetAutoStretchVertical(true)
    label:SetFont("LiliaFont.20")
    label:SetTextColor(self:GetSpeakerColor(isPlayer))
    label:SetText(formatted)
    label:SetContentAlignment(4)
    function label:PerformLayout()
        if IsValid(self:GetParent()) then
            local parentW = self:GetParent():GetWide()
            if parentW > 0 and self:GetWide() ~= parentW then self:SetWide(parentW) end
        end
    end

    if IsValid(self.dialogHistoryScroll) then
        local scrollW = self.dialogHistoryScroll:GetWide()
        if scrollW > 0 then
            local scrollBar = self.dialogHistoryScroll:GetVBar()
            local actualW = scrollW
            if IsValid(scrollBar) and scrollBar:IsVisible() then actualW = scrollW - scrollBar:GetWide() end
            actualW = actualW - 12
            if actualW > 0 then
                container:SetWide(actualW)
                label:SetWide(actualW)
            end
        end
    end

    container:InvalidateLayout(true)
    container:SizeToChildren(false, true)
    timer.Simple(0, function()
        if IsValid(container) and IsValid(label) and IsValid(self.dialogHistoryScroll) then
            local scrollW = self.dialogHistoryScroll:GetWide()
            if scrollW > 0 then
                local scrollBar = self.dialogHistoryScroll:GetVBar()
                local actualW = scrollW
                if IsValid(scrollBar) and scrollBar:IsVisible() then actualW = scrollW - scrollBar:GetWide() end
                actualW = actualW - 12
                if actualW > 0 then
                    container:SetWide(actualW)
                    label:SetWide(actualW)
                    container:InvalidateLayout(true)
                    container:SizeToChildren(false, true)
                    label:InvalidateLayout(true)
                end
            end
        end
    end)

    timer.Simple(0.1, function()
        if IsValid(container) and IsValid(label) and IsValid(self.dialogHistoryScroll) then
            local scrollW = self.dialogHistoryScroll:GetWide()
            if scrollW > 0 then
                local scrollBar = self.dialogHistoryScroll:GetVBar()
                local actualW = scrollW
                if IsValid(scrollBar) and scrollBar:IsVisible() then actualW = scrollW - scrollBar:GetWide() end
                actualW = actualW - 12
                if actualW > 0 and label:GetWide() ~= actualW then
                    container:SetWide(actualW)
                    label:SetWide(actualW)
                    container:InvalidateLayout(true)
                    container:SizeToChildren(false, true)
                    label:InvalidateLayout(true)
                end
            end
        end
    end)

    self:ScrollHistoryToBottom()
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
        timer.Simple(0.01, function()
            if IsValid(self) and IsValid(self.responseScroll) and IsValid(self.responseText) and IsValid(self.content) then
                local textHeight = self.responseText:GetTall()
                local contentH = self.content:GetTall()
                local maxHeight = math.max(contentH * 0.7, 150)
                local minHeight = 50
                local targetHeight = math.min(math.max(textHeight + 8, minHeight), maxHeight)
                if self.responseScroll:GetTall() ~= targetHeight then self.responseScroll:SetTall(targetHeight) end
            end
        end)
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
    self.BaseClass.PerformLayout(self, w, h)
    if IsValid(self.content) and IsValid(self.dialogOptions) then
        local contentH = self.content:GetTall()
        local canvas = self.dialogOptions:GetCanvas()
        local buttonsContentHeight = 0
        if IsValid(canvas) then
            canvas:SizeToChildren(false, true)
            buttonsContentHeight = canvas:GetTall()
        end

        local minButtonsHeight = 100
        local maxButtonsHeight = math.max(contentH * 0.5, minButtonsHeight)
        local targetButtonsHeight = math.Clamp(buttonsContentHeight + 4, minButtonsHeight, maxButtonsHeight)
        local minTextHeight = math.max(contentH * 0.3, 150)
        local availableForButtons = contentH - minTextHeight - 8
        targetButtonsHeight = math.min(targetButtonsHeight, math.max(availableForButtons, minButtonsHeight))
        if self.dialogOptions:GetTall() ~= targetButtonsHeight then self.dialogOptions:SetTall(targetButtonsHeight) end
    end

    if IsValid(self.dialogHistoryFrame) then
        local dialogX, y = self:GetPos()
        local historyW = ScrW() * 0.2
        self.dialogHistoryFrame:SetSize(historyW, h)
        local historyX = dialogX - historyW - 6
        if historyX < 6 then
            historyX = 6
            self:SetPos(historyX + historyW + 6, y)
        end

        self.dialogHistoryFrame:SetPos(historyX, y)
        self.dialogHistoryFrame:SetTall(h)
    end
end

function PANEL:OnRemove()
    if IsValid(self.dialogHistoryFrame) then self.dialogHistoryFrame:Remove() end
    if lia.dialog.historyFrame == self.dialogHistoryFrame then lia.dialog.historyFrame = nil end
end

function PANEL:AddDialogOptions(options, npc, skipBackButton)
    local ply = LocalPlayer()
    if isfunction(options) then options = options(ply, npc) end
    local validOptions = {}
    for label, info in pairs(options) do
        table.insert(validOptions, {
            label = label,
            info = info
        })
    end

    if not skipBackButton and #self.conversationStack > 0 then
        table.insert(validOptions, {
            label = "Back",
            info = {
                Response = "",
                isAutoBack = true
            }
        })
    end

    table.sort(validOptions, function(a, b)
        local labelA = a.label:lower()
        local labelB = b.label:lower()
        local aIsAdmin = labelA:find("^%[admin%]") or labelA:find("^%[admin%]:")
        local bIsAdmin = labelB:find("^%[admin%]") or labelB:find("^%[admin%]:")
        if aIsAdmin and not bIsAdmin then return true end
        if bIsAdmin and not aIsAdmin then return false end
        local aIsBack = (labelA == "back") and a.info.isAutoBack
        local bIsBack = (labelB == "back") and b.info.isAutoBack
        if aIsBack and not bIsBack then return true end
        if bIsBack and not aIsBack then return false end
        local aIsGoodbye = (labelA == "goodbye") or (labelA == "bye") or (labelA == "farewell")
        local bIsGoodbye = labelB == "goodbye" or labelB == "bye" or labelB == "farewell"
        if aIsGoodbye and not bIsGoodbye then return false end
        if bIsGoodbye and not aIsGoodbye then return true end
        return a.label < b.label
    end)

    for _, option in ipairs(validOptions) do
        local label = option.label
        local info = option.info
        local choiceBtn = self.dialogOptions:Add("liaButton")
        choiceBtn:Dock(TOP)
        choiceBtn:DockMargin(6, 8, 6, 0)
        choiceBtn:SetTall(45)
        choiceBtn:SetText(label)
        choiceBtn:SetFont("LiliaFont.32")
        choiceBtn.DoClick = function()
            local isGoodbye = string.lower(label) == "goodbye" or string.lower(label) == "bye" or string.lower(label) == "farewell" or string.lower(label) == "close"
            local isBack = string.lower(label) == "back" or string.lower(label) == "return"
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
    self.conversationStack = {}
    self:SetDialogText(dialogText)
    self:ClearDialogOptions()
    if convoSettings.Conversation then self:AddDialogOptions(convoSettings.Conversation, npc, false) end
end

vgui.Register("DialogMenu", PANEL, "liaFrame")
