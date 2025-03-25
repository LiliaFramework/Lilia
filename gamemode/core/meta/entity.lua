local playerMeta = FindMetaTable("Player")
local entityMeta = FindMetaTable("Entity")
function entityMeta:isProp()
	return self:GetClass() == "prop_physics"
end

function entityMeta:isItem()
	return self:GetClass() == "lia_item"
end

function entityMeta:isMoney()
	return self:GetClass() == "lia_money"
end

local validClasses = {
	["lvs_base"] = true,
	["gmod_sent_vehicle_fphysics_base"] = true,
	["gmod_sent_vehicle_fphysics_wheel"] = true,
	["prop_vehicle_prisoner_pod"] = true,
}

function entityMeta:isSimfphysCar()
	return validClasses[self:GetClass()] or self.IsSimfphyscar or self.LVS or validClasses[self.Base]
end

function entityMeta:isLiliaPersistent()
	return self.IsLeonNPC or self.IsPersistent
end

function entityMeta:getEntItemDropPos(offset)
	if offset == nil then offset = 64 end

	local trResult = util.TraceLine({
		start = self:EyePos(),
		endpos = self:EyePos() + self:GetAimVector() * offset,
		mask = MASK_SHOT,
		filter = {self}
	})

	return trResult.HitPos + trResult.HitNormal * 5, trResult.HitNormal:Angle()
end

function entityMeta:isNearEntity(radius, otherEntity)
	if otherEntity == self then return true end
	if radius == nil then radius = 96 end

	for _, v in ipairs(ents.FindInSphere(self:GetPos(), radius)) do
		if v == self then continue end

		if IsValid(otherEntity) and v == otherEntity or v:GetClass() == self:GetClass() then
			return true
		end
	end

	return false
end

function entityMeta:GetCreator()
	return self:getNetVar("creator", nil)
end

if SERVER then
	function entityMeta:SetCreator(client)
		self:setNetVar("creator", client)
	end

	function entityMeta:sendNetVar(key, receiver)
		netstream.Start(receiver, "nVar", self:EntIndex(), key, lia.net[self] and lia.net[self][key])
	end

	function entityMeta:clearNetVars(receiver)
		lia.net[self] = nil
		netstream.Start(receiver, "nDel", self:EntIndex())
	end

	function entityMeta:setNetVar(key, value, receiver)
		if checkBadType(key, value) then return end

		lia.net[self] = lia.net[self] or {}
		if lia.net[self][key] ~= value then lia.net[self][key] = value end

		self:sendNetVar(key, receiver)
	end

	function entityMeta:getNetVar(key, default)
		if lia.net[self] and lia.net[self][key] ~= nil then return lia.net[self][key] end

		return default
	end

	playerMeta.getLocalVar = entityMeta.getNetVar
else
	function entityMeta:getNetVar(key, default)
		local index = self:EntIndex()
		if lia.net[index] and lia.net[index][key] ~= nil then return lia.net[index][key] end

		return default
	end

	playerMeta.getLocalVar = entityMeta.getNetVar
end
