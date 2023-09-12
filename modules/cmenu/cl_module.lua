----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function MODULE:OpenOptionMenu(ply, target, isHandcuffed)
    local frame = vgui.Create("DFrame")
    frame:MakePopup()
    frame:Center()
    frame:ToggleVisible(false)
    local menu = DermaMenu()
    for name, command in pairs(lia.config.VisualizeOptions) do
        if isHandcuffed and not command.CanTargetRestricted then continue end
        if target ~= ply and not command.CanTargetOthers then continue end
        if command.OptionType == "command" then
            menu:AddOption(
                name,
                function()
                    LocalPlayer():ConCommand("say /" .. command.CommandString)
                    self:Close()
                end
            )
        elseif command.OptionType == "function" then
            menu:AddOption(
                name,
                function()
                    netstream.Start("RunCMenuFunction", name, target)
                    self:Close()
                end
            )
        end
    end

    menu:Open()
    menu:MakePopup()
    menu:Center()
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function MODULE:PlayerBindPress(ply, bind, down)
    if down and bind == "+menu_context" then
        local tr = util.TraceLine(util.GetPlayerTrace(ply))
        local target = tr.Entity
        if IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon():GetClass() == "gmod_tool" then
            hook.Run("OnContextMenuOpen")

            return true
        end

        local isHandcuffed = false
        if IsValid(target) and target:IsPlayer() then
            isHandcuffed = target:IsHandcuffed()
        end

        self:OpenOptionMenu(ply, target, isHandcuffed)
    end
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------