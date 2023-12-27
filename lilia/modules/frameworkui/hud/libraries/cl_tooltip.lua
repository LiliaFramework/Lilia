--------------------------------------------------------------------------------------------------------------------------
function FrameworkHUD:TooltipInitialize(var, panel)
    if panel.liaToolTip or panel.itemID then
        var.markupObject = lia.markup.parse(var:GetText(), ScrW() * .15)
        var:SetText("")
        var:SetWide(math.max(ScrW() * .15, 200) + 12)
        var:SetHeight(var.markupObject:getHeight() + 12)
        var:SetAlpha(0)
        var:AlphaTo(255, 0.2, 0)
        var.isItemTooltip = true
    end
end

--------------------------------------------------------------------------------------------------------------------------
function FrameworkHUD:TooltipPaint(var, w, h)
    if var.isItemTooltip then
        lia.util.drawBlur(var, 2, 2)
        surface.SetDrawColor(0, 0, 0, 230)
        surface.DrawRect(0, 0, w, h)
        if var.markupObject then var.markupObject:draw(12 * 0.5, 12 * 0.5 + 2) end
        return true
    end
end

--------------------------------------------------------------------------------------------------------------------------
function FrameworkHUD:TooltipLayout(var)
    if var.isItemTooltip then return true end
end
--------------------------------------------------------------------------------------------------------------------------
