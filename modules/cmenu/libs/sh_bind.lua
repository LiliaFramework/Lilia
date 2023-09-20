----------------------------------------------------------------------------------------------
function MODULE:PlayerBindPress(ply, bind, down)
    local tr = util.TraceLine(util.GetPlayerTrace(ply))
    local target = tr.Entity
    if not IsValid(target) or not target:IsPlayer() or target == ply then return end
    if down and string.find(bind, "+menu_context") then
        if ply:GetActiveWeapon():GetClass() == "gmod_tool" then
            hook.Run("OnContextMenuOpen")

            return true
        else
            if ply:VerifyCommandDistance(target) then
                netstream.Start("startcmenu", target)
            end
        end
    end
end
----------------------------------------------------------------------------------------------