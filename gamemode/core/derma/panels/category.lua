local PANEL = {}
function PANEL:Init()
    self:SetTall(30)
    self:DockPadding(0, 36, 0, 0)
    self.name = L("category")
    self.bool_opened = false
    self.bool_header_centered = false
    self.content_size = 0
    self.header_color = lia.color.theme.panel[1]
    self.header_color_standard = self.header_color
    self.header_color_opened = lia.color.theme.category_opened
    self.header = vgui.Create("Button", self)
    self.header:SetText("")
    self.header.Paint = function(_, w, h)
        lia.derma.rect(0, 0, w, h):Rad(16):Color(self.header_color):Shape(lia.derma.SHAPE_IOS):Draw()
        local arrow = self.bool_opened and "▼" or "▶"
        draw.SimpleText(arrow, "LiliaFont.18", 8, h * 0.5 - 1, lia.color.theme.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        local posX = self.bool_header_centered and w * 0.5 or 24
        local alignX = self.bool_header_centered and TEXT_ALIGN_CENTER or TEXT_ALIGN_LEFT
        draw.SimpleText(self.name, "LiliaFont.20", posX, 4, lia.color.theme.text, alignX)
        self.header_color = lia.color.lerp(8, self.header_color, self.bool_opened and self.header_color_opened or self.header_color_standard)
    end

    self.header.DoClick = function()
        self.bool_opened = not self.bool_opened
        self:SizeToContents()
        local totalTall = self:GetTall()
        self:SizeTo(-1, totalTall, 0.2, 0, 0.2)
        if IsValid(self.contents) then self.contents:SetVisible(self.bool_opened) end
        self:InvalidateLayout(true)
        self:InvalidateParent(true)
    end
end

function PANEL:SetText(name)
    self.name = name
end

function PANEL:SetCenterText(is_centered)
    self.bool_header_centered = is_centered
end

function PANEL:SetLabel(label)
    self:SetText(label)
end

function PANEL:SetExpanded(is_active)
    self:SetActive(is_active)
end

function PANEL:SetContents(panel)
    if IsValid(self.contents) then self.contents:Remove() end
    self.contents = panel
    panel:SetParent(self)
    panel:Dock(TOP)
    panel:SetVisible(self.bool_opened)
    self:SizeToContents()
end

function PANEL:SizeToContents()
    if not IsValid(self.contents) then
        self.content_size = 0
    else
        self.contents:InvalidateLayout(true)
        self.content_size = self.contents:GetTall()
    end

    local totalTall = 30 + (self.bool_opened and self.content_size + 12 or 0)
    self:SetTall(totalTall)
end

function PANEL:RecalculateSize()
    self:SizeToContents()
end

function PANEL:Toggle()
    self:SetActive(not self.bool_opened)
end

function PANEL:GetHeader()
    return self.header
end

function PANEL:AddItem(panel)
    if not IsValid(self.contents) then
        self.contents = vgui.Create("DPanel", self)
        self.contents:Dock(TOP)
        self.contents:DockPadding(5, 5, 5, 5)
        self.contents:SetPaintBackground(false)
        self.contents:SetVisible(self.bool_opened)
    end

    panel:SetParent(self.contents)
    panel:Dock(TOP)
    panel:DockMargin(0, 0, 0, 5)
    self:SizeToContents()
end

function PANEL:SetColor(col)
    self.header_color_standard = col
end

function PANEL:SetActive(is_active)
    if self.bool_opened == is_active then return end
    self.bool_opened = is_active
    self.header_color = is_active and self.header_color_opened or self.header_color_standard
    self:SizeToContents()
    if IsValid(self.contents) then self.contents:SetVisible(is_active) end
end

function PANEL:PerformLayout(w)
    self.header:SetSize(w, 30)
    if IsValid(self.contents) and self.bool_opened then self:SizeToContents() end
end

vgui.Register("liaCategory", PANEL, "Panel")
