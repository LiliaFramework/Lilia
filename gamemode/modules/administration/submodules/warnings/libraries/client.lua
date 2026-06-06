function MODULE:PopulateAdminTabs(pages)
    local client = LocalPlayer()
    if not IsValid(client) then return end
    local canViewPlayerWarnings = client:hasPrivilege("viewPlayerWarnings")
    if canViewPlayerWarnings then
        table.insert(pages, {
            name = "warnings",
            icon = "icon16/error.png",
            drawFunc = function(panel)
                panelRef = panel
                net.Start("liaRequestAllWarnings")
                net.SendToServer()
            end
        })
    end
end

AdminStickWarnings = AdminStickWarnings or {}
