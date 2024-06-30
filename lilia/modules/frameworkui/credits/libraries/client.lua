function MODULE:LoadFonts()
    surface.CreateFont("liaSmallCredits", {
        font = "Segoe UI Light",
        size = ScreenScale(6),
        weight = 100
    })
    
    surface.CreateFont("liaBigCredits", {
        font = "Segoe UI Light",
        size = ScreenScale(12),
        weight = 100
    })
end

function MODULE:BuildHelpMenu(tabs)
    tabs["Credits"] = function()
        if helpPanel then
            local credits = helpPanel:Add("liaCreditsList")
            credits:Dock(TOP)
            credits:DockMargin(ScrW() * 0.1, 0, ScrW() * 0.1, 0)
        end
        return ""
    end
end
