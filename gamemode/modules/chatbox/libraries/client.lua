--[[
    Hooks:
        CreateChatboxPanel()

    Purpose:
        Ensures the custom chatbox panel exists so persisted messages, message-mode input, and chat synchronization can target a live UI panel.

    Category:
        Chat

    Parameters:
        None

    Example Usage:
        ```lua
        hook.Add("CreateChatboxPanel", "liaExampleCreateChatboxPanel", function()
            print("Chatbox creation requested")
        end)
        ```

    Returns:
        nil

    Realm:
        Client
]]
--[[
    Hooks:
        ChatboxPanelCreated(Panel panel)

    Purpose:
        Runs immediately after the custom chatbox panel is created so modules can attach post-creation behavior before persisted messages are replayed.

    Category:
        Chat

    Parameters:
        panel (Panel)
            The newly created `liaChatBox` panel instance.

    Example Usage:
        ```lua
        hook.Add("ChatboxPanelCreated", "liaExampleChatboxPanelCreated", function(panel)
            panel:SetAlpha(255)
        end)
        ```

    Returns:
        nil

    Realm:
        Client
]]
local MODULE = MODULE
lia.chat = lia.chat or {}
lia.chat.persistedMessages = lia.chat.persistedMessages or {}
chat.liaAddText = chat.liaAddText or chat.AddText
local function createShadowed(panel, args)
    if not (IsValid(panel) and IsValid(panel.scroll)) then return false end
    if not (istable(args) and #args >= 3 and IsColor(args[1]) and isstring(args[2]) and IsColor(args[3])) then return false end
    local labelColor = args[1]
    local labelText = args[2]
    local textColor = args[3]
    local messageText = ""
    for i = 4, #args do
        if isstring(args[i]) then messageText = messageText .. args[i] end
    end

    local paintedPanel = vgui.Create("liaPaintedNotification", panel.scroll)
    paintedPanel:SetNotification(labelText, labelColor, messageText, textColor)
    paintedPanel:SetWide(panel:GetWide() - 16)
    paintedPanel.start = CurTime() + 8
    paintedPanel.finish = paintedPanel.start + 12
    paintedPanel.Think = function(p)
        if panel.active then
            p:SetAlpha(255)
        else
            local fraction = math.TimeFraction(p.start, p.finish, CurTime())
            local alpha = 255 - (fraction * 255)
            p:SetAlpha(math.max(alpha, 0))
        end
    end

    panel.list = panel.list or {}
    panel.list[#panel.list + 1] = paintedPanel
    paintedPanel:SetPos(0, panel.lastY or 0)
    panel.lastY = (panel.lastY or 0) + paintedPanel:GetTall() + 2
    timer.Simple(0.01, function() if IsValid(panel.scroll) and IsValid(paintedPanel) then panel.scroll:ScrollToChild(paintedPanel) end end)
    return true
end

function MODULE:CreateChatboxPanel()
    if IsValid(self.panel) then return end
    if IsValid(lia.gui.chat) then
        self.panel = lia.gui.chat
        return
    end

    self.panel = vgui.Create("liaChatBox")
    self.panel.skipPersist = true
    hook.Run("ChatboxPanelCreated", self.panel)
    for _, entry in ipairs(lia.chat.persistedMessages or {}) do
        if istable(entry) and entry.arguments then
            if entry.shadowed then
                createShadowed(self.panel, entry.arguments)
            else
                self.panel:addText(unpack(entry.arguments))
            end
        end
    end

    self.panel.skipPersist = false
    if lia.chat.wasActive then self.panel:setActive(true) end
end

function MODULE:InitPostEntity()
    hook.Run("CreateChatboxPanel")
end

function MODULE:PlayerBindPress(_, bind, pressed)
    bind = bind:lower()
    if bind:find("messagemode") and pressed then
        if not IsValid(self.panel) then hook.Run("CreateChatboxPanel") end
        if not self.panel.active then self.panel:setActive(true) end
        return true
    end
end

function chat.AddText(...)
    if not IsValid(MODULE.panel) then hook.Run("CreateChatboxPanel") end
    local show = true
    if IsValid(MODULE.panel) then show = MODULE.panel:addText(...) end
    if show then
        chat.liaAddText(...)
        hook.Run("ChatboxTextAdded", ...)
    end
end

function MODULE:ChatText(_, _, text, messageType)
    if messageType ~= "none" then return end
    local hadPanel = IsValid(self.panel)
    if not hadPanel then
        local prevActive = lia.chat.wasActive
        lia.chat.wasActive = false
        hook.Run("CreateChatboxPanel")
        lia.chat.wasActive = prevActive
    end

    if not IsValid(self.panel) then return end
    local wasActive = self.panel.active
    self.panel:addText(text)
    if not wasActive and self.panel.active then self.panel:setActive(false) end
    if lia.config.get("CustomChatSound", "") and lia.config.get("CustomChatSound", "") ~= "" then
        surface.PlaySound(lia.config.get("CustomChatSound", ""))
    else
        chat.PlaySound()
    end
end

function MODULE:ChatAddText(text, ...)
    if not lia.config.get("ChatSizeDiff", false) then return text end
    local chatArgs = {...}
    local function getChatMode(args)
        for _, value in ipairs(args) do
            if isstring(value) then
                local trimmed = string.Trim(value)
                if trimmed ~= "" and not string.StartWith(trimmed, ": ") then return string.lower(trimmed) end
            end
        end
    end

    local chatMode = getChatMode(chatArgs)
    if not chatMode then return "<font=LiliaFont.22>" end
    if string.find(chatMode, "yell", 1, true) then
        return "<font=LiliaFont.26b>"
    elseif string.sub(chatMode, 1, 2) == "**" then
        return "<font=LiliaFont.23i>"
    elseif string.find(chatMode, "whisper", 1, true) then
        return "<font=LiliaFont.20>"
    elseif string.find(chatMode, "ooc", 1, true) or string.find(chatMode, "looc", 1, true) then
        return "<font=LiliaFont.22>"
    else
        return "<font=LiliaFont.24>"
    end
end

local function openAddFilteredWordPrompt()
    LocalPlayer():requestString(L("chatFilterAddWord"), L("chatFilterEnterWord"), function(value)
        if value == false then return end
        value = string.Trim(tostring(value or ""))
        if value == "" then
            LocalPlayer():notifyErrorLocalized("chatFilterInvalidWord")
            return
        end

        net.Start("liaChatboxAddFilteredWord")
        net.WriteString(value)
        net.SendToServer()
    end)
end

local function buildFilteredWordsAdminPanel(panel)
    MODULE.filteredWordAdminPanel = panel
    panel:Clear()
    panel:DockPadding(12, 12, 12, 12)
    panel.Paint = nil
    local theme = lia.color.theme or {}
    local accent = theme.accent or theme.header or theme.theme or Color(184, 132, 74)
    local panelColor = Color(4, 18, 23, 242)
    local panelColorSoft = Color(7, 24, 29, 238)
    local panelColorHovered = Color(12, 31, 36, 244)
    local selectedColor = Color(22, 31, 32, 250)
    local borderColor = Color(47, 59, 57, 220)
    local textColor = Color(230, 238, 236)
    local mutedTextColor = Color(150, 168, 166)
    local selectedWord
    local wordButtons = {}
    local sourceWords = {}
    local syncingSearch = false
    local function drawPanel(x, y, w, h, radius, color, outline)
        lia.derma.rect(x, y, w, h):Rad(radius):Color(color):Shape(lia.derma.SHAPE_IOS):Draw()
        if outline then lia.derma.rect(x, y, w, h):Rad(radius):Color(outline):Shape(lia.derma.SHAPE_IOS):Outline(1):Draw() end
    end

    local function styleScrollBar(scrollPanel)
        if not IsValid(scrollPanel) then return end
        local vbar = scrollPanel:GetVBar()
        if not IsValid(vbar) then return end
        vbar:SetWide(7)
        vbar.Paint = function(_, w, h)
            surface.SetDrawColor(255, 255, 255, 4)
            surface.DrawRect(0, 0, w, h)
        end

        vbar.btnUp.Paint = function() end
        vbar.btnDown.Paint = function() end
        vbar.btnGrip.Paint = function(_, w, h) drawPanel(1, 0, w - 2, h, 4, Color(accent.r, accent.g, accent.b, 145)) end
    end

    local function removeFilteredWord(word)
        word = string.Trim(tostring(word or ""))
        if word == "" or word == L("chatFilterEmpty") then return end
        net.Start("liaChatboxRemoveFilteredWord")
        net.WriteString(word)
        net.SendToServer()
    end

    local function createSearchEntry(parent, placeholder)
        local wrap = parent:Add("DPanel")
        wrap.Paint = function(_, w, h) drawPanel(0, 0, w, h, 5, panelColorSoft, Color(accent.r, accent.g, accent.b, 60)) end
        local entry = wrap:Add("DTextEntry")
        entry:Dock(FILL)
        entry:DockMargin(14, 4, 14, 4)
        entry:SetFont("LiliaFont.16")
        entry:SetTextColor(textColor)
        entry:SetCursorColor(accent)
        entry:SetPlaceholderText(placeholder)
        entry:SetPlaceholderColor(Color(115, 132, 132))
        entry:SetDrawBackground(false)
        entry:SetPaintBackground(false)
        entry:SetPaintBorderEnabled(false)
        return wrap, entry
    end

    local controls = panel:Add("DPanel")
    controls:Dock(TOP)
    controls:SetTall(46)
    controls:DockMargin(0, 0, 0, 14)
    controls.Paint = nil
    local topSearchWrap, topSearch = createSearchEntry(controls, L("chatFilterSearch"))
    topSearchWrap:Dock(FILL)
    topSearchWrap:DockMargin(0, 0, 12, 0)
    local addButton = controls:Add("DButton")
    addButton:Dock(RIGHT)
    addButton:SetWide(154)
    addButton:SetText("")
    addButton.Paint = function(self, w, h)
        local hovered = self:IsHovered()
        drawPanel(0, 0, w, h, 5, hovered and panelColorHovered or panelColorSoft, Color(accent.r, accent.g, accent.b, hovered and 105 or 60))
        draw.SimpleText("+  " .. string.upper(L("chatFilterAddWord")), "LiliaFont.16", w * 0.5, h * 0.5, hovered and Color(245, 245, 240) or textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    addButton.DoClick = function()
        lia.websound.playButtonSound()
        openAddFilteredWordPrompt()
    end

    local body = panel:Add("DPanel")
    body:Dock(FILL)
    body.Paint = nil
    local listPanel = body:Add("DPanel")
    listPanel:Dock(LEFT)
    listPanel:SetWide(470)
    listPanel:DockMargin(0, 0, 12, 0)
    listPanel:DockPadding(14, 14, 14, 14)
    listPanel.Paint = function(_, w, h) drawPanel(0, 0, w, h, 7, panelColor, borderColor) end
    local listHeader = listPanel:Add("DPanel")
    listHeader:Dock(TOP)
    listHeader:SetTall(34)
    listHeader.Paint = nil
    local listTitle = listHeader:Add("DLabel")
    listTitle:Dock(LEFT)
    listTitle:SetWide(180)
    listTitle:SetFont("LiliaFont.18")
    listTitle:SetText("FILTERED WORDS")
    listTitle:SetTextColor(accent)
    listTitle:SetContentAlignment(4)
    local countLabel = listHeader:Add("DLabel")
    countLabel:Dock(LEFT)
    countLabel:SetWide(90)
    countLabel:SetFont("LiliaFont.15")
    countLabel:SetTextColor(accent)
    countLabel:SetContentAlignment(4)
    local listSearchWrap, listSearch = createSearchEntry(listPanel, L("search"))
    listSearchWrap:Dock(TOP)
    listSearchWrap:SetTall(42)
    listSearchWrap:DockMargin(0, 4, 0, 14)
    local listScroll = listPanel:Add("DScrollPanel")
    listScroll:Dock(FILL)
    listScroll.Paint = function() end
    styleScrollBar(listScroll)
    local listCanvas = listScroll:GetCanvas()
    listCanvas:DockPadding(0, 0, 8, 0)
    listCanvas.Paint = function() end
    local emptyLabel = listCanvas:Add("DLabel")
    emptyLabel:Dock(TOP)
    emptyLabel:SetTall(72)
    emptyLabel:SetFont("LiliaFont.17")
    emptyLabel:SetTextColor(mutedTextColor)
    emptyLabel:SetContentAlignment(5)
    emptyLabel:SetWrap(true)
    emptyLabel:SetText(L("chatFilterEmpty"))
    emptyLabel:SetVisible(false)
    local detailPanel = body:Add("DPanel")
    detailPanel:Dock(FILL)
    detailPanel:DockPadding(20, 18, 20, 18)
    detailPanel.Paint = function(_, w, h) drawPanel(0, 0, w, h, 7, panelColor, borderColor) end
    local emptyState = body:Add("DPanel")
    emptyState:Dock(FILL)
    emptyState:SetVisible(false)
    emptyState.Paint = function(_, w, h)
        drawPanel(0, 0, w, h, 7, panelColor, borderColor)
        local centerY = h * 0.5 - 48
        draw.SimpleText("No filtered words", "LiliaFont.30", w * 0.5, centerY, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText("The server chat filter is currently empty.", "LiliaFont.18", w * 0.5, centerY + 42, mutedTextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText("Add a word to start blocking it from chat.", "LiliaFont.16", w * 0.5, centerY + 70, mutedTextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    local emptyAddButton = emptyState:Add("DButton")
    emptyAddButton:SetText("")
    emptyAddButton.Paint = function(self, w, h)
        local hovered = self:IsHovered()
        drawPanel(0, 0, w, h, 5, hovered and panelColorHovered or panelColorSoft, Color(accent.r, accent.g, accent.b, hovered and 115 or 70))
        draw.SimpleText("+  ADD FIRST WORD", "LiliaFont.16", w * 0.5, h * 0.5, hovered and Color(245, 245, 240) or textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    emptyAddButton.DoClick = function()
        lia.websound.playButtonSound()
        openAddFilteredWordPrompt()
    end

    emptyState.PerformLayout = function(_, w, h)
        emptyAddButton:SetSize(190, 46)
        emptyAddButton:SetPos(math.floor((w - 190) * 0.5), math.floor(h * 0.5 + 48))
    end

    local detailContent = detailPanel:Add("DPanel")
    detailContent:Dock(FILL)
    detailContent.Paint = function(_, w, h)
        if not selectedWord then
            draw.SimpleText("No word selected", "LiliaFont.24", w * 0.5, h * 0.5 - 12, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText("Select a filtered word from the list to inspect it.", "LiliaFont.16", w * 0.5, h * 0.5 + 22, mutedTextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            return
        end

        draw.SimpleText(selectedWord, "LiliaFont.30", 10, 8, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText(L("chatFilterWordLabel"), "LiliaFont.17", 10, 48, mutedTextColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        local sectionY = 112
        draw.SimpleText("GENERAL", "LiliaFont.17", 10, sectionY, accent, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        surface.SetDrawColor(accent.r, accent.g, accent.b, 70)
        surface.DrawRect(10, sectionY + 30, w - 20, 1)
        local rows = {{"Word", selectedWord, textColor}, {"Status", "ACTIVE", Color(78, 205, 116)}, {"Type", "Filtered word", textColor}}
        local rowY = sectionY + 38
        for _, row in ipairs(rows) do
            draw.SimpleText(row[1], "LiliaFont.16", 22, rowY + 14, Color(190, 205, 204), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText(row[2], "LiliaFont.16", w - 22, rowY + 14, row[3], TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
            surface.SetDrawColor(255, 255, 255, 14)
            surface.DrawRect(10, rowY + 30, w - 20, 1)
            rowY = rowY + 42
        end

        local actionY = rowY + 26
        draw.SimpleText("ACTIONS", "LiliaFont.17", 10, actionY, accent, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        surface.SetDrawColor(accent.r, accent.g, accent.b, 70)
        surface.DrawRect(10, actionY + 30, w - 20, 1)
    end

    local copyButton = detailContent:Add("DButton")
    copyButton:SetText("")
    copyButton.Paint = function(self, w, h)
        local hovered = self:IsHovered() and selectedWord ~= nil
        drawPanel(0, 0, w, h, 5, hovered and panelColorHovered or panelColorSoft, Color(accent.r, accent.g, accent.b, hovered and 115 or 70))
        draw.SimpleText("COPY WORD", "LiliaFont.16", w * 0.5, h * 0.5, selectedWord and textColor or mutedTextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    copyButton.DoClick = function()
        if not selectedWord then return end
        lia.websound.playButtonSound()
        SetClipboardText(selectedWord)
    end

    local removeButton = detailContent:Add("DButton")
    removeButton:SetText("")
    removeButton.Paint = function(self, w, h)
        local hovered = self:IsHovered() and selectedWord ~= nil
        local danger = Color(210, 72, 72)
        drawPanel(0, 0, w, h, 5, hovered and Color(danger.r, danger.g, danger.b, 24) or Color(32, 18, 20, 245), Color(danger.r, danger.g, danger.b, hovered and 210 or 145))
        draw.SimpleText("REMOVE WORD", "LiliaFont.16", w * 0.5, h * 0.5, selectedWord and danger or mutedTextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    removeButton.DoClick = function()
        if not selectedWord then return end
        lia.websound.playButtonSound()
        removeFilteredWord(selectedWord)
    end

    local noticePanel = detailContent:Add("DPanel")
    noticePanel.Paint = function(_, w, h)
        if not selectedWord then return end
        drawPanel(0, 0, w, h, 5, panelColorSoft, Color(borderColor.r, borderColor.g, borderColor.b, 120))
        draw.SimpleText("This word is blocked by the server chat filter.", "LiliaFont.15", 14, h * 0.5, mutedTextColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    detailContent.PerformLayout = function(_, w)
        local actionY = 112 + 38 + 42 * 3 + 26 + 42
        local buttonW = math.Clamp(math.floor((w - 32) * 0.28), 140, 190)
        copyButton:SetPos(10, actionY)
        copyButton:SetSize(buttonW, 46)
        removeButton:SetPos(20 + buttonW, actionY)
        removeButton:SetSize(buttonW, 46)
        noticePanel:SetPos(10, actionY + 68)
        noticePanel:SetSize(math.max(w - 20, 1), 48)
    end

    body.PerformLayout = function(_, w) listPanel:SetWide(math.Clamp(math.floor(w * 0.42), 330, 520)) end
    local function refreshSelection()
        for _, button in ipairs(wordButtons) do
            if IsValid(button) then button:InvalidateLayout(true) end
        end

        detailContent:InvalidateLayout(true)
    end

    local function selectWord(word)
        selectedWord = word
        refreshSelection()
    end

    local function currentFilter()
        return string.lower(string.Trim(topSearch:GetValue() or ""))
    end

    local function addWordButton(word)
        local button = listCanvas:Add("DButton")
        button:Dock(TOP)
        button:SetTall(66)
        button:DockMargin(0, 0, 0, 8)
        button:SetText("")
        button.word = word
        button.Paint = function(self, w, h)
            local selected = selectedWord == self.word
            local hovered = self:IsHovered()
            local fill = selected and selectedColor or hovered and panelColorHovered or panelColorSoft
            local outline = selected and Color(accent.r, accent.g, accent.b, 170) or Color(borderColor.r, borderColor.g, borderColor.b, 180)
            drawPanel(0, 0, w, h, 6, fill, outline)
            if selected then
                surface.SetDrawColor(accent.r, accent.g, accent.b, 235)
                surface.DrawRect(0, 6, 3, h - 12)
            end

            draw.SimpleText(self.word, "LiliaFont.20", 18, 13, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            draw.SimpleText(L("chatFilterWordLabel"), "LiliaFont.15", 18, 40, mutedTextColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        end

        button.DoClick = function(self)
            lia.websound.playButtonSound()
            selectWord(self.word)
        end

        button.DoRightClick = function(self)
            local menu = DermaMenu()
            menu:AddOption(L("copyRow"), function() SetClipboardText(self.word) end)
            menu:AddOption(L("chatFilterRemoveWord"), function() removeFilteredWord(self.word) end)
            menu:Open()
        end

        wordButtons[#wordButtons + 1] = button
    end

    local function refreshList()
        local query = currentFilter()
        for _, button in ipairs(wordButtons) do
            if IsValid(button) then button:Remove() end
        end

        wordButtons = {}
        local visibleWords = {}
        for _, word in ipairs(sourceWords) do
            if query == "" or word:lower():find(query, 1, true) then visibleWords[#visibleWords + 1] = word end
        end

        for _, word in ipairs(visibleWords) do
            addWordButton(word)
        end

        local total = #sourceWords
        countLabel:SetText(string.format("%d %s", total, total == 1 and "word" or "words"))
        local hasWords = total > 0
        listPanel:SetVisible(hasWords)
        detailPanel:SetVisible(hasWords)
        emptyState:SetVisible(not hasWords)
        emptyLabel:SetVisible(hasWords and #visibleWords == 0)
        if hasWords and #visibleWords == 0 then
            emptyLabel:SetText("No filtered words match your search.")
        else
            emptyLabel:SetText(L("chatFilterEmpty"))
        end

        local selectionStillVisible = false
        for _, word in ipairs(visibleWords) do
            if word == selectedWord then
                selectionStillVisible = true
                break
            end
        end

        if not selectionStillVisible then selectedWord = visibleWords[1] end
        refreshSelection()
        listCanvas:InvalidateLayout(true)
        listCanvas:SizeToChildren(false, true)
        listScroll:InvalidateLayout(true)
    end

    local function synchronizeSearch(value, source)
        if syncingSearch then return end
        syncingSearch = true
        local target = source == topSearch and listSearch or topSearch
        if IsValid(target) and target:GetValue() ~= value then target:SetText(value) end
        syncingSearch = false
        refreshList()
    end

    topSearch.OnChange = function(self) synchronizeSearch(self:GetValue() or "", self) end
    listSearch.OnChange = function(self) synchronizeSearch(self:GetValue() or "", self) end
    function panel:populateFilteredWords(words)
        local sortedWords = {}
        for _, word in ipairs(words or MODULE.filteredWords or {}) do
            word = string.Trim(tostring(word or ""))
            if word ~= "" then sortedWords[#sortedWords + 1] = word end
        end

        table.sort(sortedWords, function(a, b) return a:lower() < b:lower() end)
        sourceWords = sortedWords
        MODULE.filteredWords = table.Copy(sortedWords)
        MODULE.filteredWordCount = #sortedWords
        refreshList()
    end

    panel:populateFilteredWords(MODULE.filteredWords or {})
end

function MODULE:PopulateAdminTabs(pages)
    local client = LocalPlayer()
    if not IsValid(client) or not client:hasPrivilege("manageChatFilter") then return end
    pages[#pages + 1] = {
        name = "@chatFilterTitle",
        icon = "icon16/comments.png",
        drawFunc = function(panel)
            buildFilteredWordsAdminPanel(panel)
            net.Start("liaChatboxRequestFilteredWords")
            net.SendToServer()
        end
    }
end
