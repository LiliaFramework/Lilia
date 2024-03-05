local PANEL = {}
local MODULE = MODULE
ColorPatters = {
    fg = Color(52, 73, 94),
    bg = Color(44, 62, 80),
    blue_fg = Color(52, 152, 219),
    blue_bg = Color(41, 128, 185),
}

local function letters(txt)
    return txt:gmatch(".")
end

function PANEL:Init()
    self.buttons = {}
    self.scroll = vgui.Create("DScrollPanel", self)
    self.scroll:Dock(FILL)
    local vbar = self.scroll:GetVBar()
    vbar:SetHideButtons(true)
    vbar.Paint = function(_, w, h)
        surface.SetDrawColor(Color(52, 73, 94))
        surface.DrawRect(w / 2, 0, w / 2, h)
    end

    vbar.btnGrip.Paint = function(_, w, h)
        surface.SetDrawColor(Color(40, 58, 75))
        surface.DrawRect(w / 2, 0, w / 2, h)
    end
end

function PANEL:Paint()
end

function PANEL:Clear()
    self.buttons = {}
    self.scroll:Clear()
end

function PANEL:AddDelimiter(txt)
    local delimiter = self.scroll:Add("DPanel")
    delimiter:Dock(TOP)
    function delimiter:Paint(w, h)
        surface.SetDrawColor(ColorPatters.bg)
        surface.DrawRect(0, 0, w, h)
        draw.SimpleText(txt, nil, w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

function PANEL:AddLog(txt, time)
    local current_date, current_formated_date, last_button = os.date("*t", time), os.date("%d %B %Y (%d/%m/%y)", time), self.buttons[#self.buttons]
    if last_button then
        local last_date = os.date("*t", last_button.time)
        if not (current_date.day == last_date.day) or not (current_date.month == last_date.month) or not (current_date.year == last_date.year) then self:AddDelimiter(current_formated_date) end
    else
        self:AddDelimiter(current_formated_date)
    end

    local unregexed_txt = ""
    for l in letters(txt) do
        if MODULE.regex[l] then continue end
        unregexed_txt = unregexed_txt .. l
    end

    local i, font = #self.buttons, "DermaDefaultBold"
    local log = self.scroll:Add("DPanel")
    log:Dock(TOP)
    log.time = time
    function log:Paint(w, h)
        if i % 2 == 0 then
            surface.SetDrawColor(Color(0, 0, 0, 0))
        else
            surface.SetDrawColor(Color(44, 62, 80))
        end

        surface.DrawRect(0, 0, w, h)
        surface.SetFont(font)
        local offset_x, offset_y, last_regex_color, i = 0, draw.GetFontHeight(font) / 2, nil, 1
        for l in letters(txt) do
            local regex_color = MODULE.regex[l]
            if regex_color then
                if not last_regex_color then
                    last_regex_color = regex_color
                else
                    last_regex_color = nil
                end

                continue
            end

            if last_regex_color then
                surface.SetTextColor(last_regex_color)
            else
                surface.SetTextColor(color_white)
            end

            surface.SetTextPos(55 + offset_x, offset_y)
            surface.DrawText(l)
            offset_x = offset_x + surface.GetTextSize(unregexed_txt:sub(i, i))
            i = i + 1
        end

        draw.SimpleText(os.date("%H:%M:%S", time), "DermaDefault", 5, h / 2, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    self.buttons[#self.buttons + 1] = log
    return log
end

vgui.Register("UILog", PANEL, "DPanel")
PANEL = {}
function PANEL:Init()
    self.buttons = {}
    self:Dock(RIGHT)
    self:SetWidth(ScrW() / 8)
    self.scroll = vgui.Create("DScrollPanel", self)
    self.scroll:Dock(FILL)
    self.scroll:DockMargin(0, 90, 0, 5)
    local vbar = self.scroll:GetVBar()
    vbar:SetHideButtons(true)
    vbar:SetWide(0)
end

function PANEL:Paint(w, h)
    surface.SetDrawColor(44, 62, 80)
    surface.DrawRect(0, 0, w, h)
    draw.SimpleText("Swirlseed", "DermaLarge", w / 2, 35, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    draw.SimpleText("Lilia's Official Logging System", "DermaDefaultBold", w / 2, 60, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

function PANEL:AddButton(txt, color, end_color)
    local button = MODULE:createButton(self.scroll, txt, TOP, nil, color, end_color)
    self.buttons[#self.buttons + 1] = button
    return button
end

vgui.Register("UINav", PANEL, "DPanel")
