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

concommand.Add("dev_GetCameraOrigin", function(client)
    if client:isStaff() then
        print("origin = (" .. math.ceil(LocalPlayer():GetPos().x) .. ", " .. math.ceil(LocalPlayer():GetPos().y) .. ", " .. math.ceil(LocalPlayer():GetPos().z) .. ")")
        print("angles = (" .. math.ceil(LocalPlayer():GetAngles().x) .. ", " .. math.ceil(LocalPlayer():GetAngles().y) .. ", " .. math.ceil(LocalPlayer():GetAngles().z) .. ")")
    end
end)

concommand.Add("vgui_cleanup", function()
    for _, v in pairs(vgui.GetWorldPanel():GetChildren()) do
        if not (v.Init and debug.getinfo(v.Init, "Sln").short_src:find("chatbox")) then v:Remove() end
    end
end, nil, "Removes every panel that you have left over (like that errored DFrame filling up your screen)")

concommand.Add("weighpoint_stop", function() hook.Add("HUDPaint", "WeighPoint", function() end) end)
concommand.Add("dev_GetEntPos", function(client) if client:isStaff() then print(LocalPlayer():GetEyeTrace().Entity:GetPos().x, LocalPlayer():GetEyeTrace().Entity:GetPos().y, LocalPlayer():GetEyeTrace().Entity:GetPos().z) end end)
concommand.Add("dev_GetEntAngles", function(client) if client:isStaff() then print(math.ceil(LocalPlayer():GetEyeTrace().Entity:GetAngles().x) .. ", " .. math.ceil(LocalPlayer():GetEyeTrace().Entity:GetAngles().y) .. ", " .. math.ceil(LocalPlayer():GetEyeTrace().Entity:GetAngles().z)) end end)
concommand.Add("dev_GetRoundEntPos", function(client) if client:isStaff() then print(math.ceil(LocalPlayer():GetEyeTrace().Entity:GetPos().x) .. ", " .. math.ceil(LocalPlayer():GetEyeTrace().Entity:GetPos().y) .. ", " .. math.ceil(LocalPlayer():GetEyeTrace().Entity:GetPos().z)) end end)
concommand.Add("dev_GetPos", function(client) if client:isStaff() then print(math.ceil(LocalPlayer():GetPos().x) .. ", " .. math.ceil(LocalPlayer():GetPos().y) .. ", " .. math.ceil(LocalPlayer():GetPos().z)) end end)
