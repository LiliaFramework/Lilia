netstream.Hook(
    "trunkInitStorage",
    function(entity)
        if istable(entity) then
            for vehicle, _ in pairs(entity) do
                LiliaStorage:InitializeStorage(vehicle)
            end
        else
            LiliaStorage:InitializeStorage(entity)
        end
    end
)
