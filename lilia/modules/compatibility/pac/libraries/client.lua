---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function pace.LoadParts()
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function MODULE:AdjustPACPartData(wearer, id, data)
    local item = lia.item.list[id]
    if item and isfunction(item.pacAdjust) then
        local result = item:pacAdjust(data, wearer)
        if result ~= nil then return result end
    end
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function MODULE:getAdjustedPartData(wearer, id)
    if not self.partData[id] then return end
    local data = table.Copy(self.partData[id])
    return hook.Run("AdjustPACPartData", wearer, id, data) or data
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function MODULE:attachPart(client, id)
    if not pac then return end
    local part = self:getAdjustedPartData(client, id)
    if not part then return end
    if not client.AttachPACPart then pac.SetupENT(client) end
    client:AttachPACPart(part, client)
    client.liaPACParts = client.liaPACParts or {}
    client.liaPACParts[id] = part
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function MODULE:removePart(client, id)
    if not client.RemovePACPart or not client.liaPACParts then return end
    local part = client.liaPACParts[id]
    if part then
        client:RemovePACPart(part)
        client.liaPACParts[id] = nil
    end
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function MODULE:DrawPlayerRagdoll(entity)
    local client = entity.objCache
    if IsValid(client) and not entity.overridePAC3 then
        if client.pac_outfits then
            for _, part in pairs(client.pac_outfits) do
                if IsValid(part.last_owner) then
                    hook.Run("OnPAC3PartTransfered", part)
                    part:SetOwner(entity)
                    part.last_owner = entity
                end
            end
        end

        client.pac_playerspawn = pac.RealTime
        entity.overridePAC3 = true
    end
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function MODULE:OnEntityCreated(entity)
    local class = entity:GetClass()
    timer.Simple(0, function()
        if class == "prop_ragdoll" then
            if entity:getNetVar("player") then
                entity.RenderOverride = function()
                    entity.objCache = entity:getNetVar("player")
                    entity:DrawModel()
                    hook.Run("DrawPlayerRagdoll", entity)
                end
            end
        end

        if class:find("HL2MPRagdoll") then
            for _, v in ipairs(player.GetAll()) do
                if v:GetRagdollEntity() == entity then entity.objCache = v end
            end

            entity.RenderOverride = function()
                entity:DrawModel()
                hook.Run("DrawPlayerRagdoll", entity)
            end
        end
    end)
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function MODULE:OnPlayerObserve(client, state)
    local curParts = client:getParts()
    if curParts then client:resetParts() end
    if not state then
        local character = client:getChar()
        local inventory = character:getInv()
        for _, v in pairs(inventory:getItems()) do
            if v:getData("equip") == true and v.pacData then client:addPart(v.uniqueID, v) end
        end
    end
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
RunConsoleCommand("pac_debug_clmdl", "1")
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
