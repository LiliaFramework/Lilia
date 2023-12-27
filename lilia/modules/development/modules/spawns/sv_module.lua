--------------------------------------------------------------------------------------------------------------------------
local MODULE = MODULE
--------------------------------------------------------------------------------------------------------------------------
function MODULE:PostPlayerLoadout(client)
    if not IsValid(client) then return end
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
