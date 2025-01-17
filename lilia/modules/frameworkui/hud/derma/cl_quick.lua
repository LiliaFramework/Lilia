local PANEL = {}
function PANEL:Init()
    if IsValid(lia.gui.quick) then lia.gui.quick:Remove() end
    lia.gui.quick = self
    self:SetSize(400, 36)
    self:SetPos(ScrW() - 36, -36)
    self:MakePopup()
    self:SetKeyboardInputEnabled(false)
    self:SetZPos(999)
    self:SetMouseInputEnabled(true)
    self.categories = {}
    self.title = self:Add("DLabel")
    self.title:SetTall(36)
    self.title:Dock(TOP)
    self.title:SetFont("liaMediumFont")
    self.title:SetText(L("quickSettings"))
    self.title:SetContentAlignment(4)
    self.title:SetTextInset(44, 0)
    self.title:SetTextColor(color_white)
    self.title:SetExpensiveShadow(1, Color(0, 0, 0, 175))
    self.title.Paint = function(_, w, h)
        surface.SetDrawColor(lia.config.Color)
        surface.DrawRect(0, 0, w, h)
    end

    self.expand = self:Add("DButton")
    self.expand:SetContentAlignment(5)
    self.expand:SetText("`")
    self.expand:SetFont("liaIconsMedium")
    self.expand:SetPaintBackground(false)
    self.expand:SetTextColor(color_white)
    self.expand:SetExpensiveShadow(1, Color(0, 0, 0, 150))
    self.expand:SetSize(36, 36)
    self.expand.DoClick = function(_)
        if self.expanded then
            self:SizeTo(400, 36, 0.15, nil, nil, function() self:MoveTo(ScrW() - 36, 30, 0.15) end)
            self.scroll:SizeTo(400, ScrH() * 0.5, 0.15)
            self.expanded = false
        else
            self:MoveTo(ScrW() - 600, 30, 0.15, nil, nil, function()
                local height = 0
                for _, category in pairs(self.categories) do
                    for _, btn in ipairs(category.buttons) do
                        if IsValid(btn) and btn:IsVisible() then height = height + btn:GetTall() + 1 end
                    end
                end

                height = math.min(height, ScrH() * 0.5)
                self:SizeTo(600, height + 36, 0.15)
                self.scroll:SizeTo(600, height, 0.15)
            end)

            self.expanded = true
        end
    end

    self.scroll = self:Add("DScrollPanel")
    self.scroll:SetPos(0, 36)
    self.scroll:SetSize(self:GetWide(), ScrH() * 0.5)
    self:MoveTo(self.x, 30, 0.05)
    hook.Run("SetupQuickMenu", self)
end

local function paintButton(button, w, h)
    local r, g, b = lia.config.Color:Unpack()
    local alpha = 100
    if button.Depressed or button:IsSelected() then
        alpha = 255
    elseif button.Hovered then
        alpha = 200
    end

    surface.SetDrawColor(r, g, b, alpha)
    surface.SetMaterial(lia.util.getMaterial("vgui/gradient-r"))
    surface.DrawTexturedRect(0, 0, w / 2, h)
    surface.SetMaterial(lia.util.getMaterial("vgui/gradient-l"))
    surface.DrawTexturedRect(w / 2, 0, w / 2, h)
end

function PANEL:addCategory(text)
    if self.categories[text] then return self.categories[text].label end
    local categoryLabel = self.scroll:Add("DButton")
    categoryLabel:SetText("")
    categoryLabel:SetTall(36)
    categoryLabel:Dock(TOP)
    categoryLabel:DockMargin(0, 1, 0, 0)
    categoryLabel:SetFont("liaMediumFont")
    categoryLabel:SetTextColor(color_white)
    categoryLabel:SetExpensiveShadow(1, Color(0, 0, 0, 150))
    categoryLabel:SetContentAlignment(5)
    categoryLabel:SetMouseInputEnabled(true)
    categoryLabel.Paint = function(this, w, h)
        surface.SetDrawColor(lia.config.Color)
        surface.DrawRect(0, 0, w, h)
        draw.SimpleText(text, this:GetFont(), w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    categoryLabel.expanded = true
    categoryLabel.buttons = {}
    categoryLabel.DoClick = function()
        categoryLabel.expanded = not categoryLabel.expanded
        for _, btn in ipairs(categoryLabel.buttons) do
            btn:SetVisible(categoryLabel.expanded)
        end
    end

    self.categories[text] = {
        label = categoryLabel,
        buttons = {}
    }
    return categoryLabel
end

function PANEL:addButton(text, callback, category)
    category = category or "Miscellaneous"
    local cat = self.categories[category]
    if not cat then
        cat = {
            label = self:addCategory(category),
            buttons = {}
        }

        self.categories[category] = cat
    end

    local button = self.scroll:Add("DButton")
    button:SetText(text)
    button:SetTall(36)
    button:Dock(TOP)
    button:DockMargin(20, 1, 0, 0)
    button:SetFont("liaMediumLightFont")
    button:SetExpensiveShadow(1, Color(0, 0, 0, 150))
    button:SetContentAlignment(4)
    button:SetTextInset(8, 0)
    button:SetTextColor(color_white)
    button.Paint = paintButton
    if callback then button.DoClick = callback end
    button:SetVisible(cat.label.expanded)
    table.insert(cat.buttons, button)
    return button
end

function PANEL:addSpacer()
    local panel = self.scroll:Add("DPanel")
    panel:SetTall(1)
    panel:Dock(TOP)
    panel:DockMargin(20, 1, 0, 0)
    panel.Paint = function(_, w, h)
        surface.SetDrawColor(255, 255, 255, 10)
        surface.DrawRect(0, 0, w, h)
    end
    return panel
end

function PANEL:addSlider(text, callback, value, min, max, decimal, category)
    category = category or "Miscellaneous"
    local cat = self.categories[category]
    if not cat then
        cat = {
            label = self:addCategory(category),
            buttons = {}
        }

        self.categories[category] = cat
    end

    local slider = self.scroll:Add("DNumSlider")
    slider:SetText(text)
    slider:SetTall(36)
    slider:Dock(TOP)
    slider:DockMargin(20, 1, 0, 0)
    slider:SetExpensiveShadow(1, Color(0, 0, 0, 150))
    slider:SetMin(min or 0)
    slider:SetMax(max or 100)
    slider:SetDecimals(decimal or 0)
    slider:SetValue(value or 0)
    slider.Label:SetFont("liaMediumLightFont")
    slider.Label:SetTextColor(color_white)
    local textEntry = slider:GetTextArea()
    textEntry:SetFont("liaMediumLightFont")
    textEntry:SetTextColor(color_white)
    if callback then
        slider.OnValueChanged = function(this, val)
            val = math.Round(val, decimal)
            callback(this, val)
        end
    end

    slider.Paint = paintButton
    slider:SetVisible(cat.label.expanded)
    table.insert(cat.buttons, slider)
    return slider
end

function PANEL:addCheck(text, callback, checked, category)
    category = category or "Miscellaneous"
    local cat = self.categories[category]
    if not cat then
        cat = {
            label = self:addCategory(category),
            buttons = {}
        }

        self.categories[category] = cat
    end

    local button = self.scroll:Add("DButton")
    button:SetText(text)
    button:SetTall(36)
    button:Dock(TOP)
    button:DockMargin(20, 1, 0, 0)
    button:SetFont("liaMediumLightFont")
    button:SetExpensiveShadow(1, Color(0, 0, 0, 150))
    button:SetContentAlignment(4)
    button:SetTextInset(8, 0)
    button:SetTextColor(color_white)
    button.Paint = paintButton
    button.DoClick = function(panel)
        panel.checked = not panel.checked
        if callback then callback(panel, panel.checked) end
    end

    button.checked = checked or false
    button.PaintOver = function(this, w, h)
        local checkColor = this.checked and lia.config.Color or Color(255, 255, 255, 50)
        draw.SimpleText(this.checked and "✔" or "", "liaIconsSmall", w - 20, h / 2, checkColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    button:SetVisible(cat.label.expanded)
    table.insert(cat.buttons, button)
    return button
end

function PANEL:Paint(w, h)
    surface.SetDrawColor(0, 0, 0, 200)
    surface.DrawRect(0, 0, w, h)
    lia.util.drawBlur(self)
    surface.SetDrawColor(lia.config.Color)
    surface.DrawRect(0, 0, w, 36)
end

vgui.Register("liaQuick", PANEL, "EditablePanel")