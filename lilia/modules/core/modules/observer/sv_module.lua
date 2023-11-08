--------------------------------------------------------------------------------------------------------------------------
function MODULE:PlayerNoClip(client, state)
    if CAMI.PlayerHasAccess(client, "Lilia - Staff Permissions - No Clip", nil) then
        if state then
            client.liaObsData = {client:GetPos(), client:EyeAngles()}
            client:SetNoDraw(true)
            client:SetNotSolid(true)
            client:DrawWorldModel(false)
            client:DrawShadow(false)
            client:GodEnable()
            client:SetNoTarget(true)
            hook.Run("OnPlayerObserve", client, state)
        else
            if client.liaObsData then
                if client:GetInfoNum("lia_obstpback", 0) > 0 then
                    local position, angles = client.liaObsData[1], client.liaObsData[2]
                    timer.Simple(
                        0,
                        function()
                            client:SetPos(position)
                            client:SetEyeAngles(angles)
                            client:SetVelocity(Vector(0, 0, 0))
                        end
                    )
                end

                client.liaObsData = nil
            end

            client:SetNoDraw(false)
            client:SetNotSolid(false)
            client:DrawWorldModel(true)
            client:DrawShadow(true)
            client:GodDisable()
            client:SetNoTarget(false)
            hook.Run("OnPlayerObserve", client, state)
        end
    else
        return false
    end
end
--------------------------------------------------------------------------------------------------------------------------
