--------------------------------------------------------------------------------------------------------------------------
local MODULE = MODULE
--------------------------------------------------------------------------------------------------------------------------
function MODULE:AdjustPACPartData(wearer, id, data)
	local item = lia.item.list[id]
	if item and isfunction(item.pacAdjust) then
		local result = item:pacAdjust(data, wearer)
		if result ~= nil then return result end
	end
end

--------------------------------------------------------------------------------------------------------------------------
function MODULE:getAdjustedPartData(wearer, id)
	if not MODULE.partData[id] then return end
	local data = table.Copy(MODULE.partData[id])

	return hook.Run("AdjustPACPartData", wearer, id, data) or data
end

--------------------------------------------------------------------------------------------------------------------------
function MODULE:attachPart(client, id)
	local part = self:getAdjustedPartData(client, id)
	if not part then return end
	if not client.AttachPACPart then
		pac.SetupENT(client)
	end

	client:AttachPACPart(part, client)
	client.liaPACParts = client.liaPACParts or {}
	client.liaPACParts[id] = part
end

--------------------------------------------------------------------------------------------------------------------------
function MODULE:removePart(client, id)
	if not client.RemovePACPart or not client.liaPACParts then return end
	local part = client.liaPACParts[id]
	if part then
		client:RemovePACPart(part)
		client.liaPACParts[id] = nil
	end
end

--------------------------------------------------------------------------------------------------------------------------
function MODULE:DrawPlayerRagdoll(entity)
	local ply = entity.objCache
	if IsValid(ply) and not entity.overridePAC3 then
		if ply.pac_outfits then
			for _, part in pairs(ply.pac_outfits) do
				if IsValid(part.last_owner) then
					hook.Run("OnPAC3PartTransfered", part)
					part:SetOwner(entity)
					part.last_owner = entity
				end
			end
		end

		ply.pac_playerspawn = pac.RealTime -- used for events
		entity.overridePAC3 = true
	end
end

--------------------------------------------------------------------------------------------------------------------------
function MODULE:OnEntityCreated(entity)
	local class = entity:GetClass()
	timer.Simple(
		0,
		function()
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
				for k, v in ipairs(player.GetAll()) do
					if v:GetRagdollEntity() == entity then
						entity.objCache = v
					end
				end

				entity.RenderOverride = function()
					entity:DrawModel()
					hook.Run("DrawPlayerRagdoll", entity)
				end
			end
		end
	)
end
--------------------------------------------------------------------------------------------------------------------------