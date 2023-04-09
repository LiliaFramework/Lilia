-- Log observer usage
function PLUGIN:OnPlayerObserve(client, state)
    lia.log.add(client, (state and "observerEnter") or "observerExit")
end

function PLUGIN:PlayerNoClip(client, state)
    -- Observer mode is reserved for administrators.
    if client:IsAdmin() or client:getChar():getFaction() == FACTION_STAFF then
        -- Check if they are entering noclip.
        if state then
            -- Store their old position and looking		 at angle.
            client.liaObsData = {client:GetPos(), client:EyeAngles()}

            -- Hide them so they are not visible.
            client:SetNoDraw(true)
            client:SetNotSolid(true)
            client:DrawWorldModel(false)
            client:DrawShadow(false)
            -- Don't allow the player to get hurt.
            client:GodEnable()
            -- Don't allow npcs to target the player.
            client:SetNoTarget(true)
            -- Run observer hook
            hook.Run("OnPlayerObserve", client, state)
        else
            if client.liaObsData then
                -- Move they player back if they want.
                if client:GetInfoNum("lia_obstpback", 0) > 0 then
                    local position, angles = client.liaObsData[1], client.liaObsData[2]

                    -- Do it the next frame since the player can not be moved right now.
                    timer.Simple(0, function()
                        client:SetPos(position)
                        client:SetEyeAngles(angles)
                        -- Make sure they stay still when they get back.
                        client:SetVelocity(Vector(0, 0, 0))
                    end)
                end

                -- Delete the old data.
                client.liaObsData = nil
            end

            -- Make the player visible again.
            client:SetNoDraw(false)
            client:SetNotSolid(false)
            client:DrawWorldModel(true)
            client:DrawShadow(true)
            -- Let the player take damage again.
            client:GodDisable()
            -- Let npcs target the player again.
            client:SetNoTarget(false)
            -- Run observer hook
            hook.Run("OnPlayerObserve", client, state)
        end
    end
end