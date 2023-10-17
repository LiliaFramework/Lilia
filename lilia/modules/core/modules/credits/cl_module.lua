--------------------------------------------------------------------------------------------------------------------------
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
--------------------------------------------------------------------------------------------------------------------------