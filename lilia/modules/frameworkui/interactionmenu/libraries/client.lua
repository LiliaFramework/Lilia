PIM_Frame = nil
function PIM:PlayerBindPress(_, bind, pressed)
    if bind == "+showscores" and pressed and self:CheckPossibilities() then
        self:OpenPIM()
        return true
    end
end

function PIM:OpenPIM()
    if IsValid(PIM_Frame) then PIM_Frame:Close() end
    local frame = vgui.Create("DFrame")
    frame:SetSize(300, 120)
    frame:SetPos(0, ScrH() / 2 - frame:GetTall() / 2)
    frame:CenterHorizontal(0.7)
    frame:MakePopup()
    frame:SetTitle("")
    frame:ShowCloseButton(false)
    frame:SetAlpha(0)
    frame:AlphaTo(255, 0.05)
    function frame:Paint(w, h)
        lia.util.drawBlur(self, 4)
        draw.RoundedBox(0, 0, 0, w, h, Color(20, 20, 20, 120))
    end

    function frame:Think()
        if not input.IsKeyDown(KEY_TAB) then self:Close() end
    end

    timer.Remove("PIM_Frame_Timer")
    timer.Create("PIM_Frame_Timer", 30, 1, function() if frame and IsValid(frame) then frame:Close() end end)
    frame.title = frame:Add("DLabel")
    frame.title:SetText("Player Interactions")
    frame.title:SetFont("liaSmallFont")
    frame.title:SetColor(color_white)
    frame.title:SetSize(frame:GetWide(), 25)
    frame.title:SetContentAlignment(5)
    frame.title:SetPos(0, (25 / 2) - frame.title:GetTall() / 2)
    frame.title:CenterHorizontal()
    function frame.title:PaintOver(w, h)
        surface.SetDrawColor(Color(60, 60, 60))
        surface.DrawLine(0, h - 1, w, h - 1)
    end

    frame.scroll = frame:Add("DScrollPanel")
    frame.scroll:SetSize(frame:GetWide(), 25 * table.Count(self.options))
    frame.scroll:SetPos(0, 25)
    frame.list = frame.scroll:Add("DIconLayout")
    frame.list:SetSize(frame.scroll:GetSize())
    local visibleOptionsCount = 0
    local traceEnt = LocalPlayer():GetEyeTrace().Entity
    for name, opt in pairs(self.options) do
        if opt.shouldShow(LocalPlayer(), traceEnt) and traceEnt:IsPlayer() and self:CheckDistance(LocalPlayer(), traceEnt) then
            visibleOptionsCount = visibleOptionsCount + 1
            local p = frame.list:Add("DButton")
            p:SetText(name)
            p:SetFont("liaSmallFont")
            p:SetColor(color_white)
            p:SetSize(frame.list:GetWide(), 25)
            function p:Paint(w, h)
                if self:IsHovered() then
                    draw.RoundedBox(0, 0, 0, w, h, Color(30, 30, 30, 150))
                else
                    draw.RoundedBox(0, 0, 0, w, h, Color(30, 30, 30, 75))
                end
            end

            function p:DoClick()
                frame:AlphaTo(0, 0.05, 0, function() if frame and IsValid(frame) then frame:Close() end end)
                opt.onRun(LocalPlayer(), traceEnt)
                if opt.runServer then netstream.Start("PIMRunOption", name) end
            end
        end
    end

    local jh = 25 * visibleOptionsCount
    frame.scroll:SetTall(jh)
    frame:SetTall(jh + 45)
    frame:CenterVertical()
    PIM_Frame = frame
end
