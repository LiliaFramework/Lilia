function MODULE:ShouldHideBars()
    if lia.config.get("BarsDisabled", false) then return false end
end

function MODULE:HUDPaintBackground()
    if not is64Bits() then draw.SimpleText("We recommend the use of the x86-64 Garry's Mod Branch for this server, consider swapping as soon as possible.", "liaSmallFont", ScrW() * .5, ScrH() * .97, Color(255, 255, 255, 10), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) end
    if self:ShouldDrawBlur() then self:DrawBlur() end
    self:RenderEntities()
end

function MODULE:ShouldDrawPlayerInfo(client)
    if client:isNoClipping() then return false end
end

function MODULE:HUDPaint()
    local client = LocalPlayer()
    if client:Alive() and client:getChar() then
        local weapon = client:GetActiveWeapon()
        if self:ShouldDrawAmmo(weapon) then self:DrawAmmo(weapon) end
        if self:ShouldDrawCrosshair() then self:DrawCrosshair() end
        if lia.option.get("fpsDraw", false) then self:DrawFPS() end
        if lia.config.get("Vignette", true) then self:DrawVignette() end
        if self:ShouldDrawWatermark() then self:DrawWatermark() end
    end
end

function String_Request(name, onRun, onCancel, okBtnText)
    if not okBtnText or okBtnText == "" or okBtnText == " " then okBtnText = "Ok" end
    local bb = vgui.Create("DPanel")
    bb:SetSize(ScrW(), ScrH())
    bb:Center()
    bb:SetAlpha(0)
    bb:AlphaTo(255, 0.2)
    function bb:close()
        bb:AlphaTo(0, 0.2, 0, function() if bb and IsValid(bb) then bb:Remove() end end)
    end

    bb.pop = bb:Add("DFrame")
    bb.pop:SetTitle("")
    bb.pop:SetSize(600, 180)
    bb.pop:MakePopup()
    bb.pop:Center()
    bb.pop:ShowCloseButton(false)
    function bb.pop:close()
        local popout = Derma_Anim("popout", self, function(pnl, _, dt, data)
            pnl:SetSize(pnl:GetWide() - data[1] * dt ^ 2, pnl:GetTall() - data[2] * dt ^ 2)
            pnl:Center()
        end)

        popout:Start(0.2, {self:GetSize()})
        function self:Think()
            if popout:Active() then popout:Run() end
        end

        timer.Simple(0.2, function()
            if bb and IsValid(bb) then bb:close() end
            if bb.pop and IsValid(bb.pop) then bb.pop:Remove() end
        end)
    end

    function bb.pop:Paint(w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(30, 30, 30, 200))
    end

    function bb.pop.OnRemove()
        if bb and IsValid(bb) then bb.close() end
    end

    function bb:Paint(w, h)
        lia.util.drawBlur(self, 4)
        draw.RoundedBox(0, 0, 0, w, h, Color(30, 30, 30, 120))
    end

    local pop = Derma_Anim("pop", bb.pop, function(pnl, _, dt, data)
        pnl:SetSize(0 + data[1] * dt ^ 2, 0 + data[2] * dt ^ 2)
        pnl:Center()
    end)

    pop:Start(0.2, {bb.pop:GetSize()})
    function bb:Think()
        if pop:Active() then pop:Run() end
    end

    timer.Simple(0.2, function()
        bb.pop.name = bb.pop:Add("DLabel")
        bb.pop.name:SetText(name)
        bb.pop.name:SetFont("liaSmallFont")
        bb.pop.name:SetColor(color_white)
        bb.pop.name:SizeToContents()
        bb.pop.name:CenterVertical(0.2)
        bb.pop.name:CenterHorizontal()
        bb.pop.input = bb.pop:Add("DTextEntry")
        bb.pop.input:SetSize(bb.pop:GetWide() * 0.85, 25)
        function bb.pop.input:PerformLayout()
            bb.pop.input:CenterVertical(0.40)
            bb.pop.input:CenterHorizontal()
        end

        local btnVertCenter = 0.7
        bb.pop.ok = bb.pop:Add("DButton")
        bb.pop.ok:SetText(okBtnText)
        bb.pop.ok:SetSize(150, 35)
        bb.pop.ok:SetColor(color_white)
        bb.pop.ok:SetFont("liaSmallFont")
        function bb.pop.ok:PerformLayout()
            bb.pop.ok:SetPos(bb.pop:GetWide() / 2 - bb.pop.ok:GetWide() - 5)
            bb.pop.ok:CenterVertical(btnVertCenter)
        end

        function bb.pop.ok.DoClick()
            if onRun then
                onRun(bb.pop.input:GetValue())
                bb.pop:close()
            end
        end

        function bb.pop.ok:Paint(w, h)
            if self:IsHovered() then
                draw.RoundedBox(0, 0, 0, w, h, Color(30, 30, 30, 255))
            else
                draw.RoundedBox(0, 0, 0, w, h, Color(30, 30, 30, 170))
            end
        end

        bb.pop.cancel = bb.pop:Add("DButton")
        bb.pop.cancel:SetText("Cancel")
        bb.pop.cancel:SetSize(150, 35)
        bb.pop.cancel:SetColor(color_white)
        bb.pop.cancel:SetFont("liaSmallFont")
        function bb.pop.cancel:PerformLayout()
            bb.pop.cancel:SetPos(bb.pop:GetWide() / 2 + 5)
            bb.pop.cancel:CenterVertical(btnVertCenter)
        end

        function bb.pop.cancel.DoClick()
            bb.pop:close()
            bb:close()
            if onCancel then onCancel() end
        end

        function bb.pop.cancel:Paint(w, h)
            if self:IsHovered() then
                draw.RoundedBox(0, 0, 0, w, h, Color(30, 30, 30, 255))
            else
                draw.RoundedBox(0, 0, 0, w, h, Color(30, 30, 30, 170))
            end
        end

        for _, pnl in pairs(bb.pop:GetChildren()) do
            pnl:SetAlpha(0)
            pnl:AlphaTo(255, 0.2, 0.1)
            pnl:InvalidateLayout(true)
        end
    end)
    return bb.pop
end

function Choice_Request(question, yes, no, modify)
    question = question or "Unset Question"
    Empty_Popup(function(frame)
        frame:SetTitle("")
        local wp = frame:GetWorkPanel()
        wp.q = wp:Add("DLabel")
        wp.q:SetText(question)
        wp.q:SetFont("WB_Small")
        wp.q:SetColor(color_white)
        wp.q:SizeToContents()
        wp.q:CenterHorizontal()
        wp.q:CenterVertical(0.25)
        local function addChoice(title)
            local b = wp:Add("DButton")
            b:SetText(title)
            b:SetSize(80, 35)
            b:SetFont("WB_Small")
            b:SetColor(color_black)
            b:CenterVertical(0.65)
            b:SetColorAcc(Color(245, 245, 245))
            b:SetupHover(Color(255, 255, 255))
            function b:Paint(w, h)
                draw.RoundedBox(4, 0, 0, w, h, self.color)
            end
            return b
        end

        wp.yes = addChoice("Yes")
        wp.yes:CenterHorizontal(0.30)
        function wp.yes:DoClick()
            frame:Close()
            if yes then yes() end
        end

        wp.no = addChoice("No")
        wp.no:CenterHorizontal(0.70)
        function wp.no:DoClick()
            frame:Close()
            if no then no() end
        end

        if modify and isfunction(modify) then modify(wp) end
    end)
end

function Important_Notification(message)
    Empty_Popup(function(frame)
        local wp = frame:GetWorkPanel()
        local g = group()
        g.msg = wp:Add("DLabel")
        g.msg:SetText(message)
        g.msg:SetFont("WB_Medium")
        g.msg:SetTextColor(color_white)
        g.msg:SizeToContents()
        g.msg:Center()
        g.cont = wp:Add("WButton")
        g.cont:SetText("Continue")
        g.cont:SetAccentColor(BC_NEUTRAL)
        g.cont:Dock(BOTTOM)
        g.cont:SetSize(frame:GetWide(), 30)
        function g.cont:DoClick()
            self:GInflate(nil, true)
            timer.Simple(0.4, function() frame:Close() end)
        end

        g:FadeIn()
    end)
end

function Empty_Popup(callback, sw, sh)
    sw = sw or 500
    sh = sh or 250
    CreateOverBlur(function(blur)
        frame = blur:Add("WolfFrame")
        frame:SetSize(sw, sh)
        frame:Center()
        frame:MakePopup()
        function frame:OnRemove()
            blur:SmoothClose()
        end

        if callback then callback(frame) end
    end)
end
