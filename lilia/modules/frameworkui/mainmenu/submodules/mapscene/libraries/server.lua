function MODULE:SaveScenes()
	self:setData(self.scenes)
end

function MODULE:LoadData()
	self.scenes = self:getData() or {}
end

function MODULE:PlayerInitialSpawn(client)
	netstream.Start(client, "mapScnInit", self.scenes)
end

function MODULE:addScene(position, angles, position2, angles2)
	local data
	if position2 then
		data = {position2, angles, angles2}
		self.scenes[position] = data
	else
		data = {position, angles}
		self.scenes[#self.scenes + 1] = data
	end

	netstream.Start(nil, "mapScn", data, position2 and position or nil)
	self:SaveScenes()
end