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

local function chatFilterShade(color, amount, alpha)
    return Color(math.Clamp((color.r or 0) + amount, 0, 255), math.Clamp((color.g or 0) + amount, 0, 255), math.Clamp((color.b or 0) + amount, 0, 255), alpha or color.a or 255)
end

local function buildFilteredWordsAdminPanel(panel)
    MODULE.filteredWordAdminPanel = panel
    panel:Clear()
    panel:DockPadding(12, 12, 12, 12)
    panel.Paint = nil
    local theme = lia.color.theme or {}
    local background = theme.background or Color(18, 20, 24)
    local accent = theme.accent or theme.primary or Color(60, 180, 190)
    local function removeFilteredWord(word)
        word = string.Trim(tostring(word or ""))
        if word == "" or word == L("chatFilterEmpty") then return end
        net.Start("liaChatboxRemoveFilteredWord")
        net.WriteString(word)
        net.SendToServer()
    end

    local controls = panel:Add("DPanel")
    controls:Dock(TOP)
    controls:SetTall(42)
    controls:DockMargin(0, 0, 0, 10)
    controls.Paint = nil
    local searchWrap = controls:Add("DPanel")
    searchWrap:Dock(FILL)
    searchWrap:DockMargin(0, 0, 8, 0)
    searchWrap.Paint = function(_, w, h)
        draw.RoundedBox(8, 0, 0, w, h, chatFilterShade(background, 8, 235))
        draw.RoundedBox(8, 1, 1, w - 2, h - 2, chatFilterShade(background, 14, 235))
    end

    local search = searchWrap:Add("liaEntry")
    search:Dock(FILL)
    search:DockMargin(12, 5, 12, 5)
    search:SetFont("LiliaFont.17")
    search:SetPlaceholderText(L("chatFilterSearch"))
    search:SetTextColor(Color(220, 220, 220))
    search.Paint = search.Paint
    local addButton = controls:Add("liaButton")
    addButton:Dock(RIGHT)
    addButton:SetWide(142)
    addButton:SetText(L("chatFilterAddWord"))
    addButton.DoClick = openAddFilteredWordPrompt
    local scroll = panel:Add("DScrollPanel")
    scroll:Dock(FILL)
    scroll.empty = false
    scroll.Paint = function(_, w, h)
        draw.RoundedBox(10, 0, 0, w, h, chatFilterShade(background, 4, 235))
        if scroll.empty then draw.SimpleText(L("chatFilterEmpty"), "LiliaFont.20", w * 0.5, h * 0.5, Color(150, 150, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) end
    end

    local vbar = scroll:GetVBar()
    vbar:SetWide(6)
    vbar.Paint = nil
    vbar.btnUp.Paint = nil
    vbar.btnDown.Paint = nil
    vbar.btnGrip.Paint = function(_, w, h) draw.RoundedBox(4, 0, 0, w, h, Color(accent.r, accent.g, accent.b, 150)) end
    local layout = scroll:Add("DIconLayout")
    layout:Dock(TOP)
    layout:DockMargin(12, 12, 12, 12)
    layout:SetSpaceX(10)
    layout:SetSpaceY(10)
    local function addWordCard(word)
        local card = layout:Add("DPanel")
        card:SetSize(220, 58)
        card.word = word
        card.Paint = function(this, w, h)
            local hovered = this:IsHovered() or this.copyButton:IsHovered() or this.removeButton:IsHovered()
            local border = hovered and Color(accent.r, accent.g, accent.b, 165) or chatFilterShade(background, 34, 210)
            local fill = hovered and chatFilterShade(background, 22, 248) or chatFilterShade(background, 14, 240)
            draw.RoundedBox(10, 0, 0, w, h, border)
            draw.RoundedBox(10, 1, 1, w - 2, h - 2, fill)
            draw.SimpleText(this.word, "LiliaFont.17", 14, 18, Color(230, 230, 230), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText(L("chatFilterWordLabel"), "LiliaFont.15", 14, 40, Color(145, 145, 145), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end

        local copyButton = card:Add("DButton")
        copyButton:Dock(FILL)
        copyButton:SetText("")
        copyButton.Paint = nil
        copyButton.DoClick = function() SetClipboardText(word) end
        copyButton.DoRightClick = function()
            local menu = DermaMenu()
            menu:AddOption(L("copyRow"), function() SetClipboardText(word) end):SetIcon("icon16/page_copy.png")
            menu:AddOption(L("chatFilterRemoveWord"), function() removeFilteredWord(word) end):SetIcon("icon16/delete.png")
            menu:Open()
        end

        card.copyButton = copyButton
        local remove = card:Add("liaButton")
        remove:Dock(RIGHT)
        remove:DockMargin(0, 10, 10, 10)
        remove:SetWide(72)
        remove:SetText(L("remove"))
        remove.DoClick = function() removeFilteredWord(word) end
        card.removeButton = remove
    end

    function panel:populateFilteredWords(words)
        local searchText = string.lower(string.Trim(search:GetValue() or ""))
        local filteredWords = {}
        layout:Clear()
        for _, word in ipairs(words or MODULE.filteredWords or {}) do
            word = tostring(word)
            filteredWords[#filteredWords + 1] = word
        end

        table.sort(filteredWords, function(a, b) return a:lower() < b:lower() end)
        MODULE.filteredWordCount = #filteredWords
        local added = 0
        for _, word in ipairs(filteredWords) do
            if searchText == "" or word:lower():find(searchText, 1, true) then
                addWordCard(word)
                added = added + 1
            end
        end

        scroll.empty = added == 0
        layout:InvalidateLayout(true)
        layout:SizeToChildren(false, true)
        scroll:InvalidateLayout(true)
    end

    search.OnTextChanged = function() panel:populateFilteredWords(MODULE.filteredWords or {}) end
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
