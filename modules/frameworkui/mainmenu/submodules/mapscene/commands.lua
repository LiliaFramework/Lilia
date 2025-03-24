lia.command.add( "mapsceneadd", {
	adminOnly = true,
	privilege = "Manage Map Scenes",
	desc = "Adds a new map scene at your view position and angle. Use true as an argument to set the first point for a paired scene.",
	syntax = "[bool repeat]",
	onRun = function( client, arguments )
		local position, angles = client:EyePos(), client:EyeAngles()
		if tobool( arguments[ 1 ] ) and not client.ScnPair then
			client.ScnPair = { position, angles }
			return L( "mapRepeat", client )
		else
			if client.ScnPair then
				MODULE:addScene( client.ScnPair[ 1 ], client.ScnPair[ 2 ], position, angles )
				client.ScnPair = nil
			else
				MODULE:addScene( position, angles )
			end
			return L( "mapAdd", client )
		end
	end
} )

lia.command.add( "mapsceneremove", {
	adminOnly = true,
	privilege = "Manage Map Scenes",
	desc = "Removes all map scenes within the given radius (default 280 units) of your position.",
	syntax = "[number radius]",
	onRun = function( client, arguments )
		local radius = tonumber( arguments[ 1 ] ) or 280
		local position = client:GetPos()
		local removed = 0
		for key, scene in pairs( MODULE.scenes ) do
			local delete = false
			if isvector( key ) then
				if key:Distance( position ) <= radius or scene[ 1 ]:Distance( position ) <= radius then delete = true end
			elseif scene[ 1 ]:Distance( position ) <= radius then
				delete = true
			end

			if delete then
				netstream.Start( nil, "mapScnDel", key )
				MODULE.scenes[ key ] = nil
				removed = removed + 1
			end
		end

		if removed > 0 then MODULE:SaveScenes() end
		return L( "mapDel", client, removed )
	end
} )