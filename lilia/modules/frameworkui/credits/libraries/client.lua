---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function CreditsCore:LoadFonts(_, _)
    surface.CreateFont("liaSmallCredits", {
        font = "Roboto",
        size = 20,
        weight = 400
    })

    surface.CreateFont("liaBigCredits", {
        font = "Roboto",
        size = 32,
        weight = 600
    })
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function CreditsCore:BuildHelpMenu(tabs)
    tabs["Credits"] = function()
        if helpPanel then
            local credits = helpPanel:Add("liaCreditsList")
            credits:Dock(TOP)
            credits:DockMargin(ScrW() * 0.1, 0, ScrW() * 0.1, 0)
        end
        return ""
    end
end
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
