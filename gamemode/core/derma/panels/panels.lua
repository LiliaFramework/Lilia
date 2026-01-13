local cacheKeys, cache, len = {}, {}, 0
local function PaintPanel(_, w, h)
    local radius = 6
    local shadowIntensity = 8
    local shadowBlur = 12
    lia.derma.rect(0, 0, w, h):Rad(radius):Color(lia.color.theme.window_shadow):Shadow(shadowIntensity, shadowBlur):Shape(lia.derma.SHAPE_IOS):Draw()
    lia.derma.rect(0, 0, w, h):Rad(radius):Color(lia.color.theme.background_alpha):Draw()
end

local function PaintFrame(pnl, w, h)
    if not pnl.LaidOut then
        local btn = pnl.btnClose
        if btn and btn:IsValid() then
            btn:SetPos(w - 26, 4)
            btn:SetSize(24, 24)
            btn:SetFont("Marlett")
            btn:SetText("✕")
            btn:SetTextColor(Color(255, 255, 255))
            btn:PerformLayout()
        end

        pnl.LaidOut = true
    end

    lia.util.drawBlur(pnl, 10)
    local radius = 6
    local shadowIntensity = 8
    local shadowBlur = 12
    lia.derma.rect(0, 0, w, h):Rad(radius):Color(lia.color.theme.window_shadow):Shadow(shadowIntensity, shadowBlur):Shape(lia.derma.SHAPE_IOS):Draw()
    lia.derma.rect(0, 0, w, h):Rad(radius):Color(lia.color.theme.background_alpha):Draw()
end

local BlurredDFrame = {}
function BlurredDFrame:Init()
    self:SetTitle("")
    self:ShowCloseButton(true)
    self:SetDraggable(true)
    self:MakePopup()
end

function BlurredDFrame:PerformLayout()
    DFrame.PerformLayout(self)
    if IsValid(self.btnClose) then self.btnClose:SetZPos(1000) end
end

function BlurredDFrame:Paint(w, h)
    PaintFrame(self, w, h)
end

vgui.Register("liaBlurredDFrame", BlurredDFrame, "DFrame")
local TransparentDFrame = {}
function TransparentDFrame:Init()
    self:SetTitle("")
    self:ShowCloseButton(true)
    self:SetDraggable(true)
    self:MakePopup()
    self.m_bBackground = false
end

function TransparentDFrame:PerformLayout()
    DFrame.PerformLayout(self)
    if IsValid(self.btnClose) then self.btnClose:SetZPos(1000) end
end

function TransparentDFrame:Paint(w, h)
    PaintPanel(self, w, h)
end

vgui.Register("liaSemiTransparentDFrame", TransparentDFrame, "DFrame")
local SimplePanel = {}
function SimplePanel:Paint(w, h)
    PaintPanel(self, w, h)
end

vgui.Register("liaSemiTransparentDPanel", SimplePanel, "DPanel")
timer.Create("derma_convar_fix", 0.5, 0, function()
    if len == 0 then return end
    local name
    for i = 1, len do
        name = cache[i]
        RunConsoleCommand(name, cacheKeys[name])
        cacheKeys[name] = nil
        cache[i] = nil
    end

    len = 0
end)

function Derma_SetCvar_Safe(name, value)
    if not cacheKeys[name] then
        cacheKeys[name] = tostring(value)
        len = len + 1
        cache[len] = name
    else
        timer.Adjust("derma_convar_fix", 0.5)
        cacheKeys[name] = tostring(value)
    end
end

function Derma_Install_Convar_Functions(panel)
    function panel:SetConVar(strConVar)
        self.m_strConVar = strConVar
    end

    function panel:ConVarChanged(strNewValue)
        local cvar = self.m_strConVar
        if not cvar or string.len(cvar) < 2 then return end
        Derma_SetCvar_Safe(cvar, strNewValue)
    end

    function panel:SetConVar(name, isNumber)
        self.m_conVar = GetConVar(name)
        if not self.m_conVar then return end
        self.m_isNumber = isNumber
        self.m_prevValue = isNumber and self.m_conVar:GetFloat() or self.m_conVar:GetString()
        self:SetValue(self.m_prevValue)
    end

    function panel:Think()
        local cvar = self.m_conVar
        if not cvar then return end
        local current = self.m_isNumber and cvar:GetFloat() or cvar:GetString()
        if current ~= self.m_prevValue then
            self.m_prevValue = current
            self:SetValue(current)
        end
    end
end

local QuickPanel = {}
function QuickPanel:Init()
    if IsValid(lia.gui.quick) then lia.gui.quick:Remove() end
    lia.gui.quick = self
    self:SetSkin(lia.config.get("DermaSkin", L("liliaSkin")))
    self:SetTitle(L("quickSettings"))
    self:SetAlphaBackground(false)
    self.scroll = self:Add("liaScrollPanel")
    self.scroll:Dock(FILL)
    self.scroll.Paint = function(_, w, h)
        local theme = lia.color.theme
        local panelColor = theme and theme.panel and theme.panel[1] or Color(50, 50, 50)
        draw.RoundedBox(8, 0, 0, w, h, panelColor)
    end

    self.items = {}
    self.optionsCache = {}
    self.forceRepopulate = true
    hook.Run("SetupQuickMenu", self)
    self:populateOptions()
    local h = 0
    for _, v in pairs(self.items) do
        if IsValid(v) then h = h + v:GetTall() + 1 end
    end

    h = math.min(h, ScrH() * 0.5)
    local targetHeight = math.max(h, 100)
    self:SetSize(400, targetHeight)
    self:SetPos(ScrW() - 400, 30)
    self:MakePopup()
    self:SetKeyboardInputEnabled(false)
    self:SetZPos(999)
    self:SetMouseInputEnabled(true)
    hook.Add("OnThemeChanged", self, function() if IsValid(self) then self:RefreshTheme() end end)
    hook.Add("OptionAdded", self, function(key, name, option) if (option.isQuick or (option.data and option.data.isQuick)) and IsValid(self) then self:InvalidateCache() end end)
end

function QuickPanel:Paint(w, h)
    local theme = lia.color.theme or {}
    local accent = theme.accent or theme.header or theme.theme or Color(100, 150, 200, 255)
    local background = theme.background_alpha or theme.background or Color(40, 40, 40, 220)
    local headerColor = theme.header or Color(34, 34, 34, 210)
    local headerText = theme.header_text or color_white
    local shadow = theme.window_shadow or Color(0, 0, 0, 60)
    local radius = 10
    local screenX, screenY = self:LocalToScreen(0, 0)
    lia.derma.rect(0, 0, w, h):Rad(radius):Color(shadow):Shape(lia.derma.SHAPE_IOS):Shadow(12, 18):Draw()
    lia.util.drawBlurAt(screenX, screenY, w, h)
    lia.derma.rect(0, 0, w, h):Rad(radius):Color(background):Draw()
    surface.SetDrawColor(accent.r, accent.g, accent.b, accent.a or 255)
    surface.DrawRect(0, 0, w, 4)
    lia.derma.rect(0, 0, w, 24):Radii(radius, radius, 0, 0):Color(headerColor):Draw()
    if self.title and self.title ~= "" then draw.SimpleText(self.title, "LiliaFont.16", 12, 12, headerText, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER) end
    surface.SetDrawColor(accent.r, accent.g, accent.b, 40)
    surface.DrawOutlinedRect(1, 1, w - 2, h - 2)
end

function QuickPanel:PerformLayout(w)
    if IsValid(self.cls) then self.cls:SetPos(w - 22, 2) end
end

function QuickPanel:addButton(text, cb)
    local btn = self.scroll:Add("liaButton")
    btn:SetText(text)
    btn:SetTall(36)
    btn:Dock(TOP)
    btn:DockMargin(0, 1, 0, 0)
    btn:SetFont("LiliaFont.20")
    if cb then btn.DoClick = cb end
    self.items[#self.items + 1] = btn
    return btn
end

function QuickPanel:addSpacer()
    local pnl = self.scroll:Add("DPanel")
    pnl:SetTall(1)
    pnl:Dock(TOP)
    pnl:DockMargin(0, 1, 0, 0)
    pnl.Paint = function(_, w, h)
        surface.SetDrawColor(lia.color.theme and lia.color.theme.panel[2] or Color(60, 60, 60))
        surface.DrawRect(0, 0, w, h)
    end

    self.items[#self.items + 1] = pnl
    return pnl
end

function QuickPanel:addCategoryHeader(categoryName, categoryColor)
    local header = self.scroll:Add("DPanel")
    header:SetTall(26)
    header:Dock(TOP)
    header:DockMargin(2, 4, 2, 2)
    header:SetPaintBackground(false)
    header.Paint = function(_, w, h)
        local theme = lia.color.theme
        local bgColor = theme and theme.category_header or Color(45, 55, 65, 100)
        local accentColor = categoryColor or (theme and theme.category_accent or Color(100, 150, 200, 255))
        local textColor = theme and theme.category_text or theme and theme.text or color_white
        local lineColor = theme and theme.category_line or Color(255, 255, 255, 20)
        lia.derma.rect(0, 0, w, h):Rad(8):Color(bgColor):Shape(lia.derma.SHAPE_IOS):Draw()
        surface.SetDrawColor(accentColor)
        surface.DrawRect(0, 0, 3, h)
        local displayText = categoryName
        local localized = L(displayText)
        if localized and localized ~= "" then displayText = localized end
        draw.SimpleText(displayText, "LiliaFont.17", w / 2, h / 2, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        surface.SetDrawColor(lineColor)
        surface.DrawRect(0, h - 1, w, 1)
    end

    self.items[#self.items + 1] = header
    return header
end

function QuickPanel:addSlider(text, cb, val, min, max, dec)
    local container = self.scroll:Add("DPanel")
    container:SetTall(70)
    container:Dock(TOP)
    container:DockMargin(0, 1, 0, 0)
    container.Paint = function(_, w, h) lia.derma.rect(0, 0, w, h):Rad(16):Color(Color(40, 40, 50, 100)):Shape(lia.derma.SHAPE_IOS):Draw() end
    local label = vgui.Create("DLabel", container)
    label:Dock(TOP)
    label:SetTall(25)
    label:DockMargin(10, 5, 10, 0)
    label:SetText("")
    local function updateLabelText(value)
        local displayValue
        if dec and dec > 0 then
            displayValue = math.Round(value, dec)
        else
            displayValue = math.Round(value)
        end

        local displayText = text .. " - " .. tostring(displayValue)
        label.Paint = function(_, w, h) draw.SimpleText(displayText, "LiliaFont.24", w / 2, h / 2, lia.color.theme.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) end
    end

    updateLabelText(val or 0)
    local slider = container:Add("liaSlider")
    slider:Dock(TOP)
    slider:DockMargin(20, 5, 20, 10)
    slider:SetTall(20)
    slider:SetRange(min or 0, max or 100, dec or 0)
    slider:SetValue(val or 0)
    if cb then
        slider.OnValueChanged = function()
            local actualValue = slider:GetValue()
            if not isnumber(actualValue) then
                if isvector(actualValue) then
                    actualValue = actualValue.x or 0
                else
                    actualValue = tonumber(actualValue) or 0
                end
            end

            local r = math.Round(actualValue, dec or 0)
            updateLabelText(r)
            cb(slider, r)
        end
    end

    self.items[#self.items + 1] = container
    return container
end

function QuickPanel:addCheck(text, cb, checked)
    local row = self.scroll:Add("DPanel")
    row:SetTall(36)
    row:Dock(TOP)
    row:DockMargin(0, 1, 0, 0)
    row.Paint = function(_, _, h)
        local theme = lia.color.theme
        local textColor = theme and theme.text or Color(255, 255, 255)
        draw.SimpleText(text, "LiliaFont.20", 8, h / 2, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    local chk = vgui.Create("liaCheckbox", row)
    chk:SetChecked(checked)
    chk:SetSize(22, 22)
    chk.OnChange = function(_, v) if cb then cb(row, v) end end
    row.PerformLayout = function(_, w, h) chk:SetPos(w - chk:GetWide() - 8, math.floor((h - chk:GetTall()) * 0.5)) end
    self.items[#self.items + 1] = row
    return row
end

function QuickPanel:setIcon(ch)
    self.icon = ch
end

function QuickPanel:RefreshTheme()
    if not IsValid(self) then return end
    if IsValid(self.scroll) then
        self.scroll.Paint = function(_, w, h)
            local theme = lia.color.theme
            local panelColor = theme and theme.panel and theme.panel[1] or Color(50, 50, 50)
            draw.RoundedBox(8, 0, 0, w, h, panelColor)
        end
    end

    local themeText = lia.color.theme.text or color_white
    for _, item in ipairs(self.items or {}) do
        if IsValid(item) and item.SetTextColor then item:SetTextColor(themeText) end
    end

    self:InvalidateLayout(true)
end

function QuickPanel:InvalidateCache()
    self.forceRepopulate = true
end

function QuickPanel:OnRemove()
    hook.Remove("OnThemeChanged", self)
    hook.Remove("OptionAdded", self)
    if lia.gui.quick == self then lia.gui.quick = nil end
end

function QuickPanel:OnClose()
    self:SetVisible(false)
    return false
end

function QuickPanel:populateOptions()
    if self.optionsCache and #self.optionsCache > 0 and not self.forceRepopulate then
        for _, item in ipairs(self.optionsCache) do
            if IsValid(item) then self.items[#self.items + 1] = item end
        end
        return
    end

    if self.forceRepopulate then
        for _, item in ipairs(self.items) do
            if IsValid(item) then item:Remove() end
        end
    end

    self.items = {}
    self.optionsCache = {}
    self.forceRepopulate = false
    local allOptions = {}
    for k, v in pairs(lia.option.stored) do
        if v and (v.isQuick or v.data and v.data.isQuick) then
            allOptions[#allOptions + 1] = {
                key = k,
                opt = v
            }
        end
    end

    if #allOptions == 0 then
        self:Remove()
        return
    end

    local categories = {}
    for _, info in ipairs(allOptions) do
        local opt = info.opt
        if not opt.visible or (isfunction(opt.visible) and opt.visible()) then
            local categoryName = (opt.data and opt.data.category) or L("categoryUnsorted")
            if not categories[categoryName] then categories[categoryName] = {} end
            table.insert(categories[categoryName], info)
        end
    end

    local sortedCategories = {}
    for categoryName, _ in pairs(categories) do
        table.insert(sortedCategories, categoryName)
    end

    table.sort(sortedCategories, function(a, b)
        if a == L("categoryUnsorted") then return false end
        if b == L("categoryUnsorted") then return true end
        return a < b
    end)

    local hasAddedItems = false
    local function getTypeOrder(optType)
        if optType == "Boolean" then
            return 1
        elseif optType == "Int" or optType == "Float" then
            return 2
        else
            return 3
        end
    end

    for _, categoryName in ipairs(sortedCategories) do
        local categoryOptions = categories[categoryName]
        if #categoryOptions > 0 then
            table.sort(categoryOptions, function(a, b)
                local typeA = getTypeOrder(a.opt.type)
                local typeB = getTypeOrder(b.opt.type)
                if typeA ~= typeB then return typeA < typeB end
                local nameA = a.opt.name or a.key
                local nameB = b.opt.name or b.key
                return nameA < nameB
            end)

            if hasAddedItems then self:addSpacer() end
            local categoryColor = Color(255, 255, 255, 255)
            for _, info in ipairs(categoryOptions) do
                local opt = info.opt
                local data = opt.data or {}
                if data.categoryColor then
                    categoryColor = data.categoryColor
                    break
                end
            end

            local categoryHeader = self:addCategoryHeader(categoryName, categoryColor)
            if categoryHeader then self.optionsCache[#self.optionsCache + 1] = categoryHeader end
            for j, info in ipairs(categoryOptions) do
                local key = info.key
                local opt = info.opt
                local data = opt.data or {}
                local val = lia.option.get(key, opt.default)
                local item
                if opt.type == "Boolean" then
                    item = self:addCheck(opt.name or key, function(_, state) lia.option.set(key, state) end, val)
                elseif opt.type == "Int" or opt.type == "Float" then
                    item = self:addSlider(opt.name or key, function(_, v) lia.option.set(key, v) end, val, data.min or 0, data.max or 100, opt.type == "Float" and (data.decimals or 2) or 0)
                end

                if item then self.optionsCache[#self.optionsCache + 1] = item end
                if j < #categoryOptions then self:addSpacer() end
            end

            hasAddedItems = true
        end
    end
end

vgui.Register("liaQuick", QuickPanel, "liaFrame")
