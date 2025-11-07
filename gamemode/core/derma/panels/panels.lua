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
    hook.Add("OptionAdded", self, function(_, _, option) if (option.isQuick or (option.data and option.data.isQuick)) and IsValid(self) then self:InvalidateCache() end end)
end

function QuickPanel:Paint(w, h)
    local theme = lia.color.theme
    local bgColor = theme and theme.background_alpha or Color(34, 34, 34, 210)
    local headerColor = theme and theme.header or Color(34, 34, 34, 210)
    draw.RoundedBox(6, 0, 0, w, h, bgColor)
    draw.RoundedBox(6, 0, 0, w, 24, headerColor)
    if self.title and self.title ~= "" then draw.SimpleText(self.title, "LiliaFont.16", 6, 4, theme and theme.header_text or Color(255, 255, 255)) end
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

function QuickPanel:addSlider(text, cb, val, min, max, dec)
    local s = self.scroll:Add("liaNumSlider")
    s:SetText(text)
    s:SetTall(60)
    s:Dock(TOP)
    s:DockMargin(0, 1, 0, 0)
    s:SetMin(min or 0)
    s:SetMax(max or 100)
    s:SetDecimals(dec or 0)
    s:SetValue(val or 0)
    if cb then
        s.OnValueChanged = function(this, newVal)
            local r = math.Round(newVal, dec or 0)
            cb(this, r)
        end
    end

    self.items[#self.items + 1] = s
    return s
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

    local groups = {
        Boolean = {},
        Int = {},
        Float = {}
    }

    for _, info in ipairs(allOptions) do
        local opt = info.opt
        if not opt.visible or (isfunction(opt.visible) and opt.visible()) then
            if opt.type == "Boolean" then
                groups.Boolean[#groups.Boolean + 1] = info
            elseif opt.type == "Int" then
                groups.Int[#groups.Int + 1] = info
            elseif opt.type == "Float" then
                groups.Float[#groups.Float + 1] = info
            end
        end
    end

    for _, group in pairs(groups) do
        table.sort(group, function(a, b)
            local nameA = a.opt.name or a.key
            local nameB = b.opt.name or b.key
            return nameA < nameB
        end)
    end

    local groupOrder = {"Boolean", "Int", "Float"}
    local hasAddedItems = false
    for _, groupType in ipairs(groupOrder) do
        local group = groups[groupType]
        if #group > 0 then
            if hasAddedItems then self:addSpacer() end
            for j, info in ipairs(group) do
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
                if j < #group then self:addSpacer() end
            end

            hasAddedItems = true
        end
    end
end

vgui.Register("liaQuick", QuickPanel, "liaFrame")
local blur = Material("pp/blurscreen")
local gradLeft = Material("vgui/gradient-l")
local gradUp = Material("vgui/gradient-u")
local gradRight = Material("vgui/gradient-r")
local gradDown = Material("vgui/gradient-d")
local function drawCircle(x, y, r)
    local circle = {}
    for i = 1, 360 do
        circle[i] = {}
        circle[i].x = x + math.cos(math.rad(i * 360) / 360) * r
        circle[i].y = y + math.sin(math.rad(i * 360) / 360) * r
    end

    surface.DrawPoly(circle)
end

local meta = FindMetaTable("Panel")
function meta:On(name, fn)
    name = self.AppendOverwrite or name
    local old = self[name]
    self[name] = function(s, ...)
        if old then old(s, ...) end
        fn(s, ...)
    end
end

function meta:SetupTransition(name, speed, fn)
    fn = self.TransitionFunc or fn
    self[name] = 0
    self:On("Think", function(s) s[name] = Lerp(FrameTime() * speed, s[name], fn(s) and 1 or 0) end)
end

local classes = {}
classes.FadeHover = function(pnl, col, speed, rad)
    col = col or Color(255, 255, 255, 30)
    speed = speed or 6
    pnl:SetupTransition("FadeHover", speed, function(s) return s:IsHovered() end)
    pnl:On("Paint", function(s, w, h)
        local colAlpha = ColorAlpha(col, col.a * s.FadeHover)
        if rad and rad > 0 then
            draw.RoundedBox(rad, 0, 0, w, h, colAlpha)
        else
            surface.SetDrawColor(colAlpha)
            surface.DrawRect(0, 0, w, h)
        end
    end)
end

classes.BarHover = function(pnl, col, height, speed)
    col = col or Color(255, 255, 255, 255)
    height = height or 2
    speed = speed or 6
    pnl:SetupTransition("BarHover", speed, function(s) return s:IsHovered() end)
    pnl:On("PaintOver", function(s, w, h)
        local bar = math.Round(w * s.BarHover)
        surface.SetDrawColor(col)
        surface.DrawRect(w / 2 - bar / 2, h - height, bar, height)
    end)
end

classes.FillHover = function(pnl, col, dir, speed, mat)
    col = col or Color(255, 255, 255, 30)
    dir = dir or LEFT
    speed = speed or 8
    pnl:SetupTransition("FillHover", speed, function(s) return s:IsHovered() end)
    pnl:On("PaintOver", function(s, w, h)
        surface.SetDrawColor(col)
        local x, y, fw, fh
        if dir == LEFT then
            x, y, fw, fh = 0, 0, math.Round(w * s.FillHover), h
        elseif dir == TOP then
            x, y, fw, fh = 0, 0, w, math.Round(h * s.FillHover)
        elseif dir == RIGHT then
            local prog = math.Round(w * s.FillHover)
            x, y, fw, fh = w - prog, 0, prog, h
        elseif dir == BOTTOM then
            local prog = math.Round(h * s.FillHover)
            x, y, fw, fh = 0, h - prog, w, prog
        end

        if mat then
            surface.SetMaterial(mat)
            surface.DrawTexturedRect(x, y, fw, fh)
        else
            surface.DrawRect(x, y, fw, fh)
        end
    end)
end

classes.Background = function(pnl, col, rad, rtl, rtr, rbl, rbr)
    pnl:On("Paint", function(_, w, h)
        if rad and rad > 0 then
            if rtl ~= nil then
                draw.RoundedBoxEx(rad, 0, 0, w, h, col, rtl, rtr, rbl, rbr)
            else
                draw.RoundedBox(rad, 0, 0, w, h, col)
            end
        else
            surface.SetDrawColor(col)
            surface.DrawRect(0, 0, w, h)
        end
    end)
end

classes.Material = function(pnl, mat, col)
    col = col or Color(255, 255, 255)
    pnl:On("Paint", function(_, w, h)
        surface.SetDrawColor(col)
        surface.SetMaterial(mat)
        surface.DrawTexturedRect(0, 0, w, h)
    end)
end

classes.TiledMaterial = function(pnl, mat, tw, th, col)
    col = col or Color(255, 255, 255, 255)
    pnl:On("Paint", function(_, w, h)
        surface.SetMaterial(mat)
        surface.SetDrawColor(col)
        surface.DrawTexturedRectUV(0, 0, w, h, 0, 0, w / tw, h / th)
    end)
end

classes.Outline = function(pnl, col, width)
    col = col or Color(255, 255, 255, 255)
    width = width or 1
    pnl:On("Paint", function(_, w, h)
        surface.SetDrawColor(col)
        for i = 0, width - 1 do
            surface.DrawOutlinedRect(0 + i, 0 + i, w - i * 2, h - i * 2)
        end
    end)
end

classes.LinedCorners = function(pnl, col, cornerLen)
    col = col or Color(255, 255, 255, 255)
    cornerLen = cornerLen or 15
    pnl:On("Paint", function(_, w, h)
        surface.SetDrawColor(col)
        surface.DrawRect(0, 0, cornerLen, 1)
        surface.DrawRect(0, 1, 1, cornerLen - 1)
        surface.DrawRect(w - cornerLen, h - 1, cornerLen, 1)
        surface.DrawRect(w - 1, h - cornerLen, 1, cornerLen - 1)
    end)
end

classes.SideBlock = function(pnl, col, size, side)
    col = col or Color(255, 255, 255, 255)
    size = size or 3
    side = side or LEFT
    pnl:On("Paint", function(_, w, h)
        surface.SetDrawColor(col)
        if side == LEFT then
            surface.DrawRect(0, 0, size, h)
        elseif side == TOP then
            surface.DrawRect(0, 0, w, size)
        elseif side == RIGHT then
            surface.DrawRect(w - size, 0, size, h)
        elseif side == BOTTOM then
            surface.DrawRect(0, h - size, w, size)
        end
    end)
end

classes.Text = function(pnl, text, font, col, alignment, ox, oy, paint)
    font = font or "Trebuchet24"
    col = col or Color(255, 255, 255, 255)
    alignment = alignment or TEXT_ALIGN_CENTER
    ox = ox or 0
    oy = oy or 0
    if not paint and pnl.SetText and pnl.SetFont and pnl.SetTextColor then
        pnl:SetText(text)
        pnl:SetFont(font)
        pnl:SetTextColor(col)
    else
        pnl:On("Paint", function(_, w, h)
            local x = 0
            if alignment == TEXT_ALIGN_CENTER then
                x = w / 2
            elseif alignment == TEXT_ALIGN_RIGHT then
                x = w
            end

            draw.SimpleText(text, font, x + ox, h / 2 + oy, col, alignment, TEXT_ALIGN_CENTER)
        end)
    end
end

classes.DualText = function(pnl, toptext, topfont, topcol, bottomtext, bottomfont, bottomcol, alignment, centerSpacing)
    topfont = topfont or "Trebuchet24"
    topcol = topcol or Color(0, 127, 255, 255)
    bottomfont = bottomfont or "Trebuchet18"
    bottomcol = bottomcol or Color(255, 255, 255, 255)
    alignment = alignment or TEXT_ALIGN_CENTER
    centerSpacing = centerSpacing or 0
    pnl:On("Paint", function(_, w, h)
        surface.SetFont(topfont)
        local _, th = surface.GetTextSize(toptext)
        surface.SetFont(bottomfont)
        local _, bh = surface.GetTextSize(bottomtext)
        local y1, y2 = h / 2 - bh / 2, h / 2 + th / 2
        local x
        if alignment == TEXT_ALIGN_LEFT then
            x = 0
        elseif alignment == TEXT_ALIGN_CENTER then
            x = w / 2
        elseif alignment == TEXT_ALIGN_RIGHT then
            x = w
        end

        draw.SimpleText(toptext, topfont, x, y1 + centerSpacing, topcol, alignment, TEXT_ALIGN_CENTER)
        draw.SimpleText(bottomtext, bottomfont, x, y2 - centerSpacing, bottomcol, alignment, TEXT_ALIGN_CENTER)
    end)
end

classes.Blur = function(pnl, amount)
    pnl:On("Paint", function(s)
        local x, y = s:LocalToScreen(0, 0)
        local scrW, scrH = ScrW(), ScrH()
        surface.SetDrawColor(255, 255, 255)
        surface.SetMaterial(blur)
        for i = 1, 3 do
            blur:SetFloat("$blur", (i / 3) * (amount or 8))
            blur:Recompute()
            render.UpdateScreenEffectTexture()
            surface.DrawTexturedRect(x * -1, y * -1, scrW, scrH)
        end
    end)
end

classes.CircleClick = function(pnl, col, speed, trad)
    col = col or Color(255, 255, 255, 50)
    speed = speed or 5
    pnl.Rad, pnl.Alpha, pnl.ClickX, pnl.ClickY = 0, 0, 0, 0
    pnl:On("Paint", function(s, w)
        if s.Alpha >= 1 then
            surface.SetDrawColor(ColorAlpha(col, s.Alpha))
            draw.NoTexture()
            drawCircle(s.ClickX, s.ClickY, s.Rad)
            s.Rad = Lerp(FrameTime() * speed, s.Rad, trad or w)
            s.Alpha = Lerp(FrameTime() * speed, s.Alpha, 0)
        end
    end)

    pnl:On("DoClick", function(s)
        s.ClickX, s.ClickY = s:CursorPos()
        s.Rad = 0
        s.Alpha = col.a
    end)
end

classes.CircleHover = function(pnl, col, speed, trad)
    col = col or Color(255, 255, 255, 30)
    speed = speed or 6
    pnl.LastX, pnl.LastY = 0, 0
    pnl:SetupTransition("CircleHover", speed, function(s) return s:IsHovered() end)
    pnl:On("Think", function(s) if s:IsHovered() then s.LastX, s.LastY = s:CursorPos() end end)
    pnl:On("PaintOver", function(s, w)
        draw.NoTexture()
        surface.SetDrawColor(ColorAlpha(col, col.a * s.CircleHover))
        drawCircle(s.LastX, s.LastY, s.CircleHover * (trad or w))
    end)
end

classes.SquareCheckbox = function(pnl, inner, outer, speed)
    inner = inner or Color(0, 255, 0, 255)
    outer = outer or Color(255, 255, 255, 255)
    speed = speed or 14
    pnl:SetupTransition("SquareCheckbox", speed, function(s) return s:GetChecked() end)
    pnl:On("Paint", function(s, w, h)
        surface.SetDrawColor(outer)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(inner)
        surface.DrawOutlinedRect(0, 0, w, h)
        local bw, bh = (w - 4) * s.SquareCheckbox, (h - 4) * s.SquareCheckbox
        bw, bh = math.Round(bw), math.Round(bh)
        surface.DrawRect(w / 2 - bw / 2, h / 2 - bh / 2, bw, bh)
    end)
end

classes.CircleCheckbox = function(pnl, inner, outer, speed)
    inner = inner or Color(0, 255, 0, 255)
    outer = outer or Color(255, 255, 255, 255)
    speed = speed or 14
    pnl:SetupTransition("CircleCheckbox", speed, function(s) return s:GetChecked() end)
    pnl:On("Paint", function(s, w, h)
        draw.NoTexture()
        surface.SetDrawColor(outer)
        drawCircle(w / 2, h / 2, w / 2 - 1)
        surface.SetDrawColor(inner)
        drawCircle(w / 2, h / 2, w * s.CircleCheckbox / 2)
    end)
end

classes.AvatarMask = function(pnl, mask)
    pnl.Avatar = vgui.Create("AvatarImage", pnl)
    pnl.Avatar:SetPaintedManually(true)
    pnl.Paint = function(s, w, h)
        render.ClearStencil()
        render.SetStencilEnable(true)
        render.SetStencilWriteMask(1)
        render.SetStencilTestMask(1)
        render.SetStencilFailOperation(STENCILOPERATION_REPLACE)
        render.SetStencilPassOperation(STENCILOPERATION_ZERO)
        render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
        render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NEVER)
        render.SetStencilReferenceValue(1)
        draw.NoTexture()
        surface.SetDrawColor(255, 255, 255, 255)
        mask(s, w, h)
        render.SetStencilFailOperation(STENCILOPERATION_ZERO)
        render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
        render.SetStencilZFailOperation(STENCILOPERATION_ZERO)
        render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
        render.SetStencilReferenceValue(1)
        s.Avatar:SetPaintedManually(false)
        s.Avatar:PaintManual()
        s.Avatar:SetPaintedManually(true)
        render.SetStencilEnable(false)
        render.ClearStencil()
    end

    pnl.PerformLayout = function(s) s.Avatar:SetSize(s:GetWide(), s:GetTall()) end
    pnl.SetPlayer = function(s, ply, size) s.Avatar:SetPlayer(ply, size) end
    pnl.SetSteamID = function(s, id, size) s.Avatar:SetSteamID(id, size) end
end

classes.CircleAvatar = function(pnl) pnl:Class("AvatarMask", function(_, w, h) drawCircle(w / 2, h / 2, w / 2) end) end
classes.Circle = function(pnl, col)
    col = col or Color(255, 255, 255, 255)
    pnl:On("Paint", function(_, w, h)
        draw.NoTexture()
        surface.SetDrawColor(col)
        drawCircle(w / 2, h / 2, math.min(w, h) / 2)
    end)
end

classes.CircleFadeHover = function(pnl, col, speed)
    col = col or Color(255, 255, 255, 30)
    speed = speed or 6
    pnl:SetupTransition("CircleFadeHover", speed, function(s) return s:IsHovered() end)
    pnl:On("Paint", function(s, w, h)
        draw.NoTexture()
        surface.SetDrawColor(ColorAlpha(col, col.a * s.CircleFadeHover))
        drawCircle(w / 2, h / 2, w / 2)
    end)
end

classes.CircleExpandHover = function(pnl, col, speed)
    col = col or Color(255, 255, 255, 30)
    speed = speed or 6
    pnl:SetupTransition("CircleExpandHover", speed, function(s) return s:IsHovered() end)
    pnl:On("Paint", function(s, w, h)
        local rad = math.Round(w / 2 * s.CircleExpandHover)
        draw.NoTexture()
        surface.SetDrawColor(ColorAlpha(col, col.a * s.CircleExpandHover))
        drawCircle(w / 2, h / 2, rad)
    end)
end

classes.Gradient = function(pnl, col, dir, frac, op)
    dir = dir or BOTTOM
    frac = frac or 1
    pnl:On("Paint", function(_, w, h)
        surface.SetDrawColor(col)
        local x, y, gw, gh
        if dir == LEFT then
            local prog = math.Round(w * frac)
            x, y, gw, gh = 0, 0, prog, h
            surface.SetMaterial(op and gradRight or gradLeft)
        elseif dir == TOP then
            local prog = math.Round(h * frac)
            x, y, gw, gh = 0, 0, w, prog
            surface.SetMaterial(op and gradDown or gradUp)
        elseif dir == RIGHT then
            local prog = math.Round(w * frac)
            x, y, gw, gh = w - prog, 0, prog, h
            surface.SetMaterial(op and gradLeft or gradRight)
        elseif dir == BOTTOM then
            local prog = math.Round(h * frac)
            x, y, gw, gh = 0, h - prog, w, prog
            surface.SetMaterial(op and gradUp or gradDown)
        end

        surface.DrawTexturedRect(x, y, gw, gh)
    end)
end

classes.SetOpenURL = function(pnl, url) pnl:On("DoClick", function() gui.OpenURL(url) end) end
classes.NetMessage = function(pnl, name, data)
    data = data or function() end
    pnl:On("DoClick", function()
        net.Start(name)
        data(pnl)
        net.SendToServer()
    end)
end

classes.Stick = function(pnl, dock, margin, dontInvalidate)
    dock = dock or FILL
    margin = margin or 0
    pnl:Dock(dock)
    if margin > 0 then pnl:DockMargin(margin, margin, margin, margin) end
    if not dontInvalidate then pnl:InvalidateParent(true) end
end

classes.DivTall = function(pnl, frac, target)
    frac = frac or 2
    target = target or pnl:GetParent()
    pnl:SetTall(target:GetTall() / frac)
end

classes.DivWide = function(pnl, frac, target)
    target = target or pnl:GetParent()
    frac = frac or 2
    pnl:SetWide(target:GetWide() / frac)
end

classes.SquareFromHeight = function(pnl) pnl:SetWide(pnl:GetTall()) end
classes.SquareFromWidth = function(pnl) pnl:SetTall(pnl:GetWide()) end
classes.SetRemove = function(pnl, target)
    target = target or pnl
    pnl:On("DoClick", function() if IsValid(target) then target:Remove() end end)
end

classes.FadeIn = function(pnl, time, alpha)
    time = time or 0.2
    alpha = alpha or 255
    pnl:SetAlpha(0)
    pnl:AlphaTo(alpha, time)
end

classes.HideVBar = function(pnl)
    local vbar = pnl:GetVBar()
    vbar:SetWide(0)
    vbar:Hide()
end

classes.SetTransitionFunc = function(pnl, fn) pnl.TransitionFunc = fn end
classes.ClearTransitionFunc = function(pnl) pnl.TransitionFunc = nil end
classes.SetAppendOverwrite = function(pnl, fn) pnl.AppendOverwrite = fn end
classes.ClearAppendOverwrite = function(pnl) pnl.AppendOverwrite = nil end
classes.ClearPaint = function(pnl) pnl.Paint = nil end
classes.ReadyTextbox = function(pnl)
    pnl:SetPaintBackground(false)
    pnl:SetAppendOverwrite("PaintOver"):SetTransitionFunc(function(s) return s:IsEditing() end)
end

function meta:Class(name, ...)
    local class = classes[name]
    assert(class, L("classDoesNotExist", name))
    class(self, ...)
    return self
end

for k, _ in pairs(classes) do
    meta[k] = function(s, ...) return s:Class(k, ...) end
end
