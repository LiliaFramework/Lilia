--------------------------------------------------------------------------------------------------------
function GM:CreateLoadingScreen()
    if IsValid(lia.gui.loading) then
        lia.gui.loading:Remove()
    end

    local loader = vgui.Create("EditablePanel")
    loader:ParentToHUD()
    loader:Dock(FILL)

    loader.Paint = function(this, w, h)
        surface.SetDrawColor(0, 0, 0)
        surface.DrawRect(0, 0, w, h)
    end

    local label = loader:Add("DLabel")
    label:Dock(FILL)
    label:SetText(L"loading")
    label:SetFont("liaNoticeFont")
    label:SetContentAlignment(5)
    label:SetTextColor(color_white)
    label:InvalidateLayout(true)
    label:SizeToContents()

    timer.Simple(5, function()
        if IsValid(lia.gui.loading) then
            local fault = getNetVar("dbError")

            if fault then
                label:SetText(fault and L"dbError" or L"loading")
                local label = loader:Add("DLabel")
                label:DockMargin(0, 64, 0, 0)
                label:Dock(TOP)
                label:SetFont("liaSubTitleFont")
                label:SetText(fault)
                label:SetContentAlignment(5)
                label:SizeToContentsY()
                label:SetTextColor(Color(255, 50, 50))
            end
        end
    end)

    lia.gui.loading = loader
end
--------------------------------------------------------------------------------------------------------
function GM:ShouldCreateLoadingScreen()
    return false
end
--------------------------------------------------------------------------------------------------------