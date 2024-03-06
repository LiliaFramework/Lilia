
concommand.Add("enabledmodules", function()
    local enabledModulesMenu = vgui.Create("DFrame")
    enabledModulesMenu:SetSize(400, 300)
    enabledModulesMenu:SetTitle("Enabled Modules")
    enabledModulesMenu:Center()
    enabledModulesMenu:MakePopup()
    local moduleList = vgui.Create("DListView", enabledModulesMenu)
    moduleList:Dock(FILL)
    moduleList:AddColumn("Module Name")
    for uniqueID, isEnabled in pairs(lia.module.EnabledList) do
        if isEnabled then moduleList:AddLine(uniqueID) end
    end
end)


concommand.Add("disabled_modules", function()
    local disabledModulesMenu = vgui.Create("DFrame")
    disabledModulesMenu:SetSize(400, 300)
    disabledModulesMenu:SetTitle("Disabled Modules")
    disabledModulesMenu:Center()
    disabledModulesMenu:MakePopup()
    local moduleList = vgui.Create("DListView", disabledModulesMenu)
    moduleList:Dock(FILL)
    moduleList:AddColumn("Module Name")
    for uniqueID, isEnabled in pairs(lia.module.EnabledList) do
        if not isEnabled then moduleList:AddLine(uniqueID) end
    end
end)

