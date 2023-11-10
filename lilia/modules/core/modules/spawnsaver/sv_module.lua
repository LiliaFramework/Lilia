--------------------------------------------------------------------------------------------------------------------------
function MODULE:CharacterPreSave(character)
    local client = character:getPlayer()
    if IsValid(client) then
        character:setData("pos", {client:GetPos(), client:EyeAngles(), game.GetMap()})
    end
end

--------------------------------------------------------------------------------------------------------------------------
function MODULE:PlayerLoadedChar(client, character, lastChar)
    timer.Simple(
        0,
        function()
            if IsValid(client) then
                local position = character:getData("pos")
                if position then
                    if position[3] and position[3]:lower() == game.GetMap():lower() then
                        client:SetPos(position[1].x and position[1] or client:GetPos())
                        client:SetEyeAngles(position[2].p and position[2] or Angle(0, 0, 0))
                    end

                    character:setData("pos", nil)
                end
            end
        end
    )
end
--------------------------------------------------------------------------------------------------------------------------