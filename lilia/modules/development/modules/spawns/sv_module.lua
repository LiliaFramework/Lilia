--------------------------------------------------------------------------------------------------------------------------
local MODULE = MODULE
--------------------------------------------------------------------------------------------------------------------------
function MODULE:CharacterPreSave(character)
    local client = character:getPlayer()
    if IsValid(client) then character:setData("pos", {client:GetPos(), client:EyeAngles(), game.GetMap()}) end
end

--------------------------------------------------------------------------------------------------------------------------
function MODULE:PostPlayerLoadedChar(client, character, lastChar)
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

--------------------------------------------------------------------------------------------------------------------------
function MODULE:PostPlayerLoadout(client)
    if self.spawns and table.Count(self.spawns) > 0 and client:getChar() then
        local class = client:getChar():getClass()
        local points
        local className = ""
        for k, v in ipairs(lia.faction.indices) do
            if k == client:Team() then
                points = self.spawns[v.uniqueID] or {}
                break
            end
        end

        if points then
            for k, v in ipairs(lia.class.list) do
                if class == v.index then
                    className = v.uniqueID
                    break
                end
            end

            points = points[className] or points[""]
            if points and table.Count(points) > 0 then
                local position = table.Random(points)
                client:SetPos(position)
            end
        end
    end
end

--------------------------------------------------------------------------------------------------------------------------
function MODULE:LoadData()
    self.spawns = self:getData() or {}
end

--------------------------------------------------------------------------------------------------------------------------
function MODULE:SaveSpawns()
    self:setData(self.spawns)
end
--------------------------------------------------------------------------------------------------------------------------
