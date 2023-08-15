--------------------------------------------------------------------------------------------------------
function GM:NetworkEntityCreated(entity)
    if entity == LocalPlayer() then return end
    if not entity:IsPlayer() then return end
    hook.Run("PlayerModelChanged", entity, entity:GetModel())
end

--------------------------------------------------------------------------------------------------------
function GM:CharacterListLoaded()
    timer.Create("liaWaitUntilPlayerValid", 0.5, 0, function()
        if not IsValid(LocalPlayer()) then return end
        timer.Remove("liaWaitUntilPlayerValid")

        if IsValid(lia.gui.loading) then
            lia.gui.loading:Remove()
        end

        RunConsoleCommand("stopsound")
        hook.Run("LiliaLoaded")
    end)
end

--------------------------------------------------------------------------------------------------------
function GM:PlayerBindPress(client, bind, pressed)
    bind = bind:lower()

    if (bind:find("use") or bind:find("attack")) and pressed then
        local menu, callback = lia.menu.getActiveMenu()

        if menu and lia.menu.onButtonPressed(menu, callback) then
            return true
        elseif bind:find("use") and pressed then
            local data = {}
            data.start = client:GetShootPos()
            data.endpos = data.start + client:GetAimVector() * 96
            data.filter = client
            local trace = util.TraceLine(data)
            local entity = trace.Entity

            if IsValid(entity) and (entity:GetClass() == "lia_item" or entity.hasMenu == true) then
                hook.Run("ItemShowEntityMenu", entity)
            end
        end
    elseif bind:find("jump") then
        lia.command.send("chargetup")
    end
end

--------------------------------------------------------------------------------------------------------
function GM:DrawLiliaModelView(panel, ent)
    if IsValid(ent.weapon) then
        ent.weapon:DrawModel()
    end
end

--------------------------------------------------------------------------------------------------------
function GM:OnChatReceived()
    if system.IsWindows() and not system.HasFocus() then
        system.FlashWindow()
    end
end
--------------------------------------------------------------------------------------------------------