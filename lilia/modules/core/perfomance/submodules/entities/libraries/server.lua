---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function MODULE:PropBreak(_, entity)
    if entity:IsValid() and entity:GetPhysicsObject():IsValid() then constraint.RemoveAll(entity) end
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function MODULE:PlayerInitialSpawn(_)
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

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function MODULE:PreGamemodeLoaded()
    function widgets.PlayerTick()
    end

    hook.Remove("PlayerTick", "TickWidgets")
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function MODULE:EntityRemoved(entity)
    if entity:IsRagdoll() and not entity:getNetVar("player", nil) and self.RagdollCleaningTimer > 0 then
        timer.Simple(self.RagdollCleaningTimer, function()
            if not IsValid(entity) then return end
            entity:SetSaveValue("m_bFadingOut", true)
            timer.Simple(3, function()
                if not IsValid(entity) then return end
                entity:Remove()
            end)
        end)
    end
end
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
