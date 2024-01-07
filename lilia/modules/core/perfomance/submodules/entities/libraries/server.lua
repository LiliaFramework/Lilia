------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function EntityPerfomance:PlayerEnteredVehicle(_, vehicle)
    if vehicle:GetClass() == "prop_vehicle_prisoner_pod" then vehicle:RemoveEFlags(EFL_NO_THINK_FUNCTION) end
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function EntityPerfomance:PropBreak(_, ent)
    if ent:IsValid() and ent:GetPhysicsObject():IsValid() then constraint.RemoveAll(ent) end
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function EntityPerfomance:PlayerInitialSpawn(_)
    local annoying = ents.FindByName("music")
    local val = ents.GetMapCreatedEntity(1733)
    if #annoying > 0 then
        annoying[1]:SetKeyValue("RefireTime", 99999999)
        annoying[1]:Fire("Disable")
        annoying[1]:Fire("Kill")
        val:SetKeyValue("RefireTime", 99999999)
        val:Fire("Disable")
        val:Fire("Kill")
    end
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function EntityPerfomance:EntityEmitSound(tab)
    if self.SoundsToMute[tab.SoundName] then return false end
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function EntityPerfomance:ServersideInitializedModules()
    for _, v in pairs(ents.GetAll()) do
        if self.EntitiesToBeRemoved[v:GetClass()] then v:Remove() end
    end

    if self.GarbageCleaningTimer > 0 then
        timer.Create(
            "CleanupGarbage",
            self.GarbageCleaningTimer,
            0,
            function()
                for _, v in ipairs(ents.GetAll()) do
                    if table.HasValue(self.Perfomancekillers, v:GetClass()) then SafeRemoveEntity(v) end
                end
            end
        )
    end
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function EntityPerfomance:ServerOnEntityCreated(entity)
    if entity:GetClass() == "prop_vehicle_prisoner_pod" then entity:AddEFlags(EFL_NO_THINK_FUNCTION) end
    if entity:IsWidget() then hook.Add("PlayerTick", "GODisableEntWidgets2", function(_, n) widgets.PlayerTick(entity, n) end) end
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function EntityPerfomance:EntityRemoved(entity)
    if entity:IsRagdoll() and not entity:getNetVar("player", nil) and self.RagdollCleaningTimer > 0 then
        timer.Simple(
            self.RagdollCleaningTimer,
            function()
                if not IsValid(entity) then return end
                entity:SetSaveValue("m_bFadingOut", true)
                timer.Simple(
                    3,
                    function()
                        if not IsValid(entity) then return end
                        entity:Remove()
                    end
                )
            end
        )
    end
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function EntityPerfomance:PlayerLeaveVehicle(_, vehicle)
    if vehicle:GetClass() == "prop_vehicle_prisoner_pod" then
        local sName = "PodFix" .. vehicle:EntIndex()
        hook.Add(
            "Think",
            sName,
            function()
                if vehicle:IsValid() then
                    local tSave = vehicle:GetSaveTable()
                    if tSave.m_bEnterAnimOn then
                        hook.Remove("Think", sName)
                    elseif not tSave.m_bExitAnimOn then
                        vehicle:AddEFlags(EFL_NO_THINK_FUNCTION)
                        hook.Remove("Think", sName)
                    end
                else
                    hook.Remove("Think", sName)
                end
            end
        )
    end
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function EntityPerfomance:InitPostEntity()
    for _, v in pairs(ents.FindByClass("prop_physics")) do
        if table.HasValue(self.UnOptimizableModels, v:GetModel()) then continue end
        local optimizedEntity = ents.Create("prop_physics_multiplayer")
        optimizedEntity:SetModel(v:GetModel())
        optimizedEntity:SetPos(v:GetPos())
        optimizedEntity:SetAngles(v:GetAngles())
        optimizedEntity:SetSkin(v:GetSkin())
        optimizedEntity:SetColor(v:GetColor())
        optimizedEntity:SetMaterial(v:GetMaterial())
        optimizedEntity:SetCollisionGroup(v:GetCollisionGroup())
        optimizedEntity:SetKeyValue("fademindist", "1000")
        optimizedEntity:SetKeyValue("fademaxdist", "1250")
        optimizedEntity:Spawn()
        local bodyGroups = v:GetBodyGroups()
        if istable(bodyGroups) then
            for _, v2 in pairs(bodyGroups) do
                if v:GetBodygroup(v2.id) > 0 then optimizedEntity:SetBodygroup(v2.id, v:GetBodygroup(v2.id)) end
            end
        end

        local physicsObject = v:GetPhysicsObject()
        local optimizedEntityPhysicsObject = optimizedEntity:GetPhysicsObject()
        if IsValid(physicsObject) and IsValid(optimizedEntityPhysicsObject) then optimizedEntityPhysicsObject:EnableMotion(physicsObject:IsMoveable()) end
        v:Remove()
    end
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
