local GM = GM or GAMEMODE
function GM:DrawLiliaModelView(_, entity)
    if IsValid(entity.weapon) then entity.weapon:DrawModel() end
end

function GM:ClientInitPostEntity()
    lia.joinTime = RealTime() - 0.9716
    if system.IsWindows() and not system.HasFocus() then system.FlashWindow() end
end

function GM:OnChatReceived()
    if system.IsWindows() and not system.HasFocus() then system.FlashWindow() end
end

function GM:PlayerBindPress(client, bind, pressed)
    bind = bind:lower()
    if bind:find("say") and string.find(bind:lower(), "/fallover") then
        client:ChatPrint("Nuh-uh! No exploiting!")
        return
    elseif (bind:find("use") or bind:find("attack")) and pressed then
        local menu, callback = lia.menu.getActiveMenu()
        if menu and lia.menu.onButtonPressed(menu, callback) then
            return true
        elseif bind:find("use") and pressed then
            local entity = client:GetTracedEntity()
            if IsValid(entity) and (entity:GetClass() == "lia_item" or entity.hasMenu == true) then hook.Run("ItemShowEntityMenu", entity) end
        end
    elseif bind:find("jump") then
        lia.command.send("chargetup")
    elseif bind:find("speed") and client:KeyDown(IN_WALK) and pressed then
        if LocalPlayer():Crouching() then
            RunConsoleCommand("-duck")
        else
            RunConsoleCommand("+duck")
        end
    end
end

function GM:CalcView(client, origin, angles, fov)
    local view = self.BaseClass:CalcView(client, origin, angles, fov)
    local entity = Entity(client:getLocalVar("ragdoll", 0))
    local ragdoll = client:GetRagdollEntity()
    if client:GetViewEntity() ~= client then return view end
    if (not client:ShouldDrawLocalPlayer() and IsValid(entity) and entity:IsRagdoll()) or (not LocalPlayer():Alive() and IsValid(ragdoll)) then
        local ent = LocalPlayer():Alive() and entity or ragdoll
        local index = ent:LookupAttachment("eyes")
        if index then
            local data = ent:GetAttachment(index)
            if data then
                view = view or {}
                view.origin = data.Pos
                view.angles = data.Ang
            end
            return view
        end
    end
    return view
end

function GM:HUDPaintBackground()
    lia.bar.drawAll()
    lia.menu.drawAll()
    self.BaseClass.PaintWorldTips(self.BaseClass)
end

function GM:CharacterListLoaded()
    timer.Create(
        "liaWaitUntilPlayerValid",
        1,
        0,
        function()
            if not IsValid(LocalPlayer()) then return end
            timer.Remove("liaWaitUntilPlayerValid")
            hook.Run("LiliaLoaded")
        end
    )
end

function GM:OnContextMenuOpen()
    self.BaseClass:OnContextMenuOpen()
    lia.bar.drawAction()
    vgui.Create("liaQuick")
end

function GM:OnContextMenuClose()
    self.BaseClass:OnContextMenuClose()
    lia.bar.drawAction()
    if IsValid(lia.gui.quick) then lia.gui.quick:Remove() end
end

function GM:HUDDrawTargetID()
    return false
end

function GM:HUDDrawPickupHistory()
    return false
end

function GM:HUDAmmoPickedUp()
    return false
end

function GM:DrawDeathNotice()
    return false
end
