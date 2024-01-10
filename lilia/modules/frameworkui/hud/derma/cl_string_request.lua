
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
        local popout = Derma_Anim(
            "popout",
            self,
            function(pnl, _, dt, data)
                pnl:SetSize(pnl:GetWide() - data[1] * dt ^ 2, pnl:GetTall() - data[2] * dt ^ 2)
                pnl:Center()
            end
        )

        popout:Start(0.2, {self:GetSize()})
        function self:Think()
            if popout:Active() then popout:Run() end
        end

        timer.Simple(
            0.2,
            function()
                if bb and IsValid(bb) then bb:close() end
                if bb.pop and IsValid(bb.pop) then bb.pop:Remove() end
            end
        )
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

    local pop = Derma_Anim(
        "pop",
        bb.pop,
        function(pnl, _, dt, data)
            pnl:SetSize(0 + data[1] * dt ^ 2, 0 + data[2] * dt ^ 2)
            pnl:Center()
        end
    )

    pop:Start(0.2, {bb.pop:GetSize()})
    function bb:Think()
        if pop:Active() then pop:Run() end
    end

    timer.Simple(
        0.2,
        function()
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
        end
    )
    return bb.pop
end

