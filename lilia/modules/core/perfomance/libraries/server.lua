function PerfomanceCore:PlayerSpawnVehicle(client)
    local playerCount = #player.GetAll()
    if playerCount >= self.PlayerCountCarLimit and self.PlayerCountCarLimitEnabled then
        client:notify("You can't spawn this as the playerlimit to spawn car has been hit!")
        return false
    end
end

function PerfomanceCore:PlayerInitialSpawn()
    local playerCount = #player.GetAll()
    local ents = ents.GetAll()
    if playerCount >= self.PlayerCountCarLimit and self.PlayerCountCarLimitEnabled then
        for _, car in pairs(ents) do
            if car:IsVehicle() then car:Remove() end
        end

        print("Cars deleted. Player count reached the limit. Please disable PerfomanceCore.PlayerCountCarLimitEnabled if you don't want this. ")
    end
end