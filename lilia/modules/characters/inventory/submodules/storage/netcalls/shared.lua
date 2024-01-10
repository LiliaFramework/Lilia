netstream.Hook(
    "trunkInitStorage",
    function(ent)
        if istable(ent) then
            for vehicle, _ in pairs(ent) do
                LiliaStorage:InitializeStorage(vehicle)
            end
        else
            LiliaStorage:InitializeStorage(ent)
        end
    end
)
