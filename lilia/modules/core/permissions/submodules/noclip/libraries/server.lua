function MODULE:PlayerNoClip(client, state)
    if (not client:isStaffOnDuty() and CAMI.PlayerHasAccess(client, "Staff Permissions - No Clip Outside Staff Character", nil)) or client:isStaffOnDuty() then
        if state then
            client:SetNoDraw(true)
            client:SetNotSolid(true)
            client:DrawWorldModel(false)
            client:DrawShadow(false)
            client:GodEnable()
            client:SetNoTarget(true)
            client.liaObsData = {client:GetPos(), client:EyeAngles()}
            hook.Run("OnPlayerObserve", client, state)
        else
            if client.liaObsData then
                if client:GetInfoNum("lia_obstpback", 0) > 0 then
                    local position, angles = client.liaObsData[1], client.liaObsData[2]
                    timer.Simple(0, function()
                        client:SetPos(position)
                        client:SetEyeAngles(angles)
                        client:SetVelocity(Vector(0, 0, 0))
                    end)
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
        return true
    end
    return false
end

function MODULE:OnPlayerObserve(client, state)
    lia.log.add(client, (state and "observerEnter") or "observerExit")
end
