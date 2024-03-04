---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
local MODULE = MODULE
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
local parse = function() end
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function MODULE:addRegex(regex, color)
    MODULE.regex[regex] = color
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
local function lerpColor(t, fColor, eColor)
    return Color(Lerp(t, fColor.r, eColor.r), Lerp(t, fColor.g, eColor.g), Lerp(t, fColor.b, eColor.b))
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function MODULE:drawGradient(_, _, w, h, color, end_color)
    for x = 0, w do
        surface.SetDrawColor(lerpColor(x / w, color, end_color))
        surface.DrawLine(x, 0, x, h)
    end
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function MODULE:createButton(parent, text, dock, doclick, color, end_color)
    local color = color or ColorPatters.blue_fg
    local end_color = end_color or ColorPatters.blue_bg
    local button = parent:Add("DButton")
    button:Dock(dock)
    button:SetText(text)
    button:SetTextColor(color_white)
    button:SetFont("DermaDefaultBold")
    function button:Paint(w, h)
        MODULE:drawGradient(0, 0, w, h, self:IsHovered() and end_color or color, self:IsHovered() and color or end_color)
    end

    function button:DoClickInternal()
        surface.PlaySound("ui/buttonclick.wav")
    end

    function button:OnCursorEntered()
        surface.PlaySound("ui/buttonrollover.wav")
    end

    button.DoClick = doclick
    return button
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
net.Receive("SyncLogs", function(len)
    local max_pages = net.ReadUInt(MODULE.maxPagesInBits)
    if max_pages > 0 then
        local data = util.JSONToTable(util.Decompress(net.ReadData(len - 1 - MODULE.maxPagesInBits)))
        parse(data, max_pages)
    else
        parse()
    end
end)

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
local function retrieve_categories()
    net.Start("SyncCategories")
    net.SendToServer()
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function MODULE:InitPostEntity()
    retrieve_categories()
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
net.Receive("SyncCategories", function()
    MODULE.categories = {}
    local count = net.ReadUInt(MODULE.maxCategoriesInBits)
    for _ = 1, count do
        local name, color = net.ReadString(), net.ReadColor()
        MODULE.categories[name] = {
            name = name,
            color = color,
        }
    end
end)

net.Receive("OpenLogger", function()
    local ply = LocalPlayer()
    if not CAMI.PlayerHasAccess(ply, "Commands - View Logs", nil) then return end
    local panel = vgui.Create("DFrame")
    panel:DockPadding(0, 0, 0, 0)
    panel:SetSize(ScrW() / 1.96, ScrH() / 1.7)
    panel:SetSizable(false)
    panel:SetDraggable(false)
    panel:ShowCloseButton(false)
    panel:SetTitle("")
    panel:Center()
    panel:MakePopup()
    panel:SetAlpha(0)
    panel:AlphaTo(255, .2, 0)
    panel.Paint = function(_, w, h)
        w = w - ScrW() / 8
        MODULE:drawGradient(0, 0, w, h, ColorPatters.fg, ColorPatters.bg)
        surface.SetDrawColor(ColorPatters.fg)
        surface.DrawLine(w - 1, 0, w - 1, h)
    end

    local log = panel:Add("UILog")
    local pager = log:Add("DPanel")
    pager:Dock(BOTTOM)
    pager:DockMargin(0, 10, 0, 0)
    pager.cur_page = 1
    pager.max_page = 1
    function pager:Paint(w, h)
        draw.SimpleText(("Page %d/%d"):format(self.cur_page, self.max_page), "DermaDefaultBold", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    MODULE:createButton(pager, "Next", RIGHT, function()
        if not log.category then return end
        local old_page = pager.cur_page
        pager.cur_page = math.Clamp(pager.cur_page + 1, 1, pager.max_page)
        if old_page == pager.cur_page then return end
        log.category:DoClick()
    end)

    MODULE:createButton(pager, "Previous", LEFT, function()
        if not log.category then return end
        local old_page = pager.cur_page
        pager.cur_page = math.Clamp(pager.cur_page - 1, 1, pager.max_page)
        if old_page == pager.cur_page then return end
        log.category:DoClick()
    end)

    local nav = panel:Add("UINav")
    local i, before_word = 0
    for _, v in SortedPairs(MODULE.categories or {}) do
        local new_word = string.match(v.name, "^(%w+)")
        local c = Color(math.Clamp(v.color.r - 30, 0, 255), math.Clamp(v.color.g - 30, 0, 255), math.Clamp(v.color.b - 30, 0, 255))
        local cat = nav:AddButton(v.name, v.color, c)
        if before_word and not (before_word == new_word) then cat:DockMargin(0, 5, 0, 0) end
        function cat:DoClick()
            if log.category ~= self then pager.cur_page = 1 end
            log.category = self
            log:Clear()
            net.Start("SyncLogs")
            net.WriteUInt(pager.cur_page, MODULE.maxPagesInBits)
            net.WriteString(v.name)
            net.SendToServer()
            log:AddDelimiter("Fetching logs..")
            parse = function(logs, max_page)
                if not IsValid(cat) then return end
                log:Clear()
                if logs and max_page then
                    for _, lv in ipairs(logs) do
                        log:AddLog(lv.log, tonumber(lv.time))
                    end

                    pager.max_page = max_page
                else
                    log:AddDelimiter("No log found")
                    pager.max_page = 1
                end
            end
        end

        if i == 0 then cat.DoClick() end
        i = i + 1
        before_word = new_word
    end

    local close = nav:AddButton("Close", Color(231, 76, 60), Color(192, 57, 43))
    close:SetParent(nav)
    close:Dock(BOTTOM)
    close:DockMargin(0, 0, 0, 5)
    close.DoClick = function() panel:AlphaTo(0, .2, 0, function() panel:Remove() end) end
    log:SetPos(15, 15)
    log:SetSize(panel:GetWide() - nav:GetWide() - 30, ScrH() / 1.8)
end)

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
MODULE.addRegex("*", Color(52, 152, 219))
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
MODULE.addRegex("&", Color(46, 204, 113))
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
MODULE.addRegex("~", Color(46, 204, 113))
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
MODULE.addRegex("!", Color(46, 204, 113))
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
MODULE.addRegex("?", Color(155, 89, 182))
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
concommand.Add("logger_retrieve_categories", retrieve_categories)
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
