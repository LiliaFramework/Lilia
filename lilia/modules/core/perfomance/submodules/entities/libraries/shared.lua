function EntityPerfomance:InitializedModules()
    if CLIENT then
        self:ClientsideInitializedModules()
    else
        self:ServersideInitializedModules()
    end
end

function EntityPerfomance:OnEntityCreated(entity)
    if CLIENT then
        self:ClientOnEntityCreated(entity)
    else
        self:ServerOnEntityCreated(entity)
    end
end

function EntityPerfomance:InitPostEntity()
    for _, v in next, list.Get("ThrusterSounds") do
        self.SoundsToMute[v.thruster_soundname] = true
    end
end
