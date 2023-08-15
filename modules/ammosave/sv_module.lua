function MODULE:CharacterPreSave(character)
    local client = character:getPlayer()
    if IsValid(client) then
        local ammoTable = {}
        for k, v in ipairs(self.ammoList) do
            local ammo = client:GetAmmoCount(v)
            if ammo > 0 then ammoTable[v] = ammo end
        end

        character:setData("ammo", ammoTable)
    end
end

function MODULE:PlayerLoadedChar(client)
    timer.Simple(
        0.25,
        function()
            if not IsValid(client) then return end
            local character = client:getChar()
            if not character then return end
            local ammoTable = character:getData("ammo")
            if ammoTable then
                for k, v in pairs(ammoTable) do
                    client:SetAmmo(v, tostring(k))
                end
            end
        end
    )
end