--------------------------------------------------------------------------------------------------------
local MODULE = MODULE
--------------------------------------------------------------------------------------------------------
local playerMeta = FindMetaTable("Entity")
--------------------------------------------------------------------------------------------------------
function MODULE:AdjustPACPartData(wearer, id, data)
	local item = lia.item.list[id]
	if item and isfunction(item.pacAdjust) then
		local result = item:pacAdjust(data, wearer)
		if result ~= nil then return result end
	end
end

--------------------------------------------------------------------------------------------------------
function MODULE:getAdjustedPartData(wearer, id)
	if not MODULE.partData[id] then return end
	local data = table.Copy(MODULE.partData[id])

	return hook.Run("AdjustPACPartData", wearer, id, data) or data
end

--------------------------------------------------------------------------------------------------------
function MODULE:attachPart(client, id)
	if not pac then return end
	local part = self:getAdjustedPartData(client, id)
	if not part then return end
	if not client.AttachPACPart then
		pac.SetupENT(client)
	end

	client:AttachPACPart(part, client)
	client.liaPACParts = client.liaPACParts or {}
	client.liaPACParts[id] = part
end

--------------------------------------------------------------------------------------------------------
function MODULE:removePart(client, id)
	if not client.RemovePACPart or not client.liaPACParts then return end
	local part = client.liaPACParts[id]
	if part then
		client:RemovePACPart(part)
		client.liaPACParts[id] = nil
	end
end

--------------------------------------------------------------------------------------------------------
function playerMeta:getParts()
	return self:getNetVar("parts", {})
end

--------------------------------------------------------------------------------------------------------
net.Receive(
	"liaPACSync",
	function()
		if not pac then return end
		for _, client in ipairs(player.GetAll()) do
			for id in pairs(client:getParts()) do
				MODULE:attachPart(client, id)
			end
		end
	end
)

--------------------------------------------------------------------------------------------------------
net.Receive(
	"liaPACPartAdd",
	function()
		local client = net.ReadEntity()
		local id = net.ReadString()
		if not IsValid(client) then return end
		MODULE:attachPart(client, id)
	end
)

--------------------------------------------------------------------------------------------------------
net.Receive(
	"liaPACPartRemove",
	function()
		local client = net.ReadEntity()
		local id = net.ReadString()
		if not IsValid(client) then return end
		MODULE:removePart(client, id)
	end
)

--------------------------------------------------------------------------------------------------------
net.Receive(
	"liaPACPartReset",
	function()
		local client = net.ReadEntity()
		if not IsValid(client) or not client.RemovePACPart then return end
		if client.liaPACParts then
			for _, part in pairs(client.liaPACParts) do
				client:RemovePACPart(part)
			end

			client.liaPACParts = nil
		end
	end
)
--------------------------------------------------------------------------------------------------------