function EntityPerfomance:InitializedModules()
    if CLIENT then
        if self.DrawEntityShadows then
            for _, v in ipairs(ents.FindByClass("prop_door_rotating")) do
                if IsValid(v) and v:isDoor() then v:DrawShadow(false) end
            end
        end
    else
        if self.GarbageCleaningTimer > 0 then
            timer.Create("CleanupGarbage", self.GarbageCleaningTimer, 0, function()
                for _, v in ipairs(ents.GetAll()) do
                    if table.HasValue(self.Perfomancekillers, v:GetClass()) then SafeRemoveEntity(v) end
                end
            end)
        end
    end
end

function EntityPerfomance:InitPostEntity()
    for _, v in next, list.Get("ThrusterSounds") do
        self.SoundsToMute[v.thruster_soundname] = true
    end
end

function EntityPerfomance:OnEntityCreated(entity)
    if CLIENT then
        if self.DrawEntityShadows then entity:DrawShadow(false) end
    else
        if entity:GetClass() == "prop_vehicle_prisoner_pod" then entity:AddEFlags(EFL_NO_THINK_FUNCTION) end
        if entity:IsWidget() then hook.Add("PlayerTick", "GODisableEntWidgets2", function(_, n) widgets.PlayerTick(entity, n) end) end
    end
end
