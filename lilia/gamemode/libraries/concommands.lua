local resetCalled = 0
concommand.Add("lia", function(client, _, arguments)
    local command = arguments[1]
    table.remove(arguments, 1)
    lia.command.parse(client, nil, command or "", arguments)
end)

concommand.Add("list_entities", function(client)
    local entityCount = {}
    local totalEntities = 0
    if not IsValid(client) or client:IsSuperAdmin() then
        print("Entities on the server:")
        for _, entity in pairs(ents.GetAll()) do
            local className = entity:GetClass() or "Unknown"
            local entityName = "Unknown"
            if entity.GetName then entityName = entity:GetName() end
            entityCount[className] = entityCount[className] or {}
            entityCount[className][entityName] = (entityCount[className][entityName] or 0) + 1
            totalEntities = totalEntities + 1
        end

        for className, entities in pairs(entityCount) do
            for entityName, count in pairs(entities) do
                print(string.format("Name: %s | Class: %s | Count: %d", entityName, className, count))
            end
        end

        print("Total entities on the server: " .. totalEntities)
    else
        print("Nuh-uh!")
    end
end)

if SERVER then
    concommand.Add("stopsoundall", function(client)
        if client:IsSuperAdmin() then
            for _, v in pairs(player.GetAll()) do
                v:ConCommand("stopsound")
            end
        else
            client:Notify("You must be a Super Admin to forcefully stopsound everyone!")
        end
    end)

    concommand.Add("lia_recreatedb", function(client)
        if not IsValid(client) then
            if resetCalled < RealTime() then
                resetCalled = RealTime() + 3
                MsgC(Color(255, 0, 0), "[Lilia] TO CONFIRM DATABASE RESET, RUN 'lia_recreatedb' AGAIN in 3 SECONDS.\n")
            else
                resetCalled = 0
                MsgC(Color(255, 0, 0), "[Lilia] DATABASE WIPE IN PROGRESS.\n")
                hook.Run("OnWipeTables")
                lia.db.wipeTables(lia.db.loadTables)
            end
        end
    end)
else
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
end