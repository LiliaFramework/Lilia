lia.command.add( "adminmode", {
	desc = "Toggles between your current character and your staff character if you have one.",
	onRun = function( client )
		if not IsValid( client ) then return end
		local steamID = client:SteamID64()
		if client:isStaffOnDuty() then
			local oldCharID = client:getNetVar( "OldCharID", 0 )
			if oldCharID > 0 then
				net.Start( "AdminModeSwapCharacter" )
				net.WriteInt( oldCharID, 32 )
				net.Send( client )
				client:setNetVar( "OldCharID", nil )
				lia.log.add( client, "adminMode", oldCharID, "Switched back to their IC character" )
			else
				client:ChatPrint( "No previous character to swap to." )
			end
		else
			lia.db.query( string.format( "SELECT * FROM lia_characters WHERE _steamID = \"%s\"", lia.db.escape( steamID ) ), function( data )
				for _, row in ipairs( data ) do
					local id = tonumber( row._id )
					if row._faction == "staff" then
						client:setNetVar( "OldCharID", client:getChar():getID() )
						net.Start( "AdminModeSwapCharacter" )
						net.WriteInt( id, 32 )
						net.Send( client )
						lia.log.add( client, "adminMode", id, "Switched to their staff character" )
						return
					end
				end

				client:ChatPrint( "No staff character found. Create one in the staff faction." )
			end )
		end
	end
} )

lia.command.add( "setsitroom", {
	superAdminOnly = true,
	privilege = "Manage SitRooms",
	desc = "Sets your current location as the sitroom spawn point for this map.",
	onRun = function( client )
		local pos = client:GetPos()
		local mapName = game.GetMap()
		local sitrooms = lia.data.get( "sitrooms", {}, true, true )
		sitrooms[ mapName ] = pos
		lia.data.set( "sitrooms", sitrooms, true, true )
		client:notify( "Sitroom location for this map has been set." )
		lia.log.add( client, "sitRoomSet", string.format( "Map: %s | Position: %s", mapName, tostring( pos ) ), "Set the sitroom location for the current map" )
	end
} )

lia.command.add( "sendtositroom", {
	adminOnly = true,
	privilege = "Manage SitRooms",
	desc = "Teleports the specified player to the sitroom location for this map.",
	syntax = "[string charname]",
	AdminStick = {
		Name = L( "sendToSitRoom" ),
		Category = L( "Moderation Tools" ),
		SubCategory = L( "misc" ),
		Icon = "icon16/arrow_down.png"
	},
	onRun = function( client, arguments )
		local target = lia.command.findPlayer( client, arguments[ 1 ] )
		if not target or not IsValid( target ) then
			client:notifyLocalized( "targetNotFound" )
			return
		end

		local mapName = game.GetMap()
		local sitrooms = lia.data.get( "sitrooms", {}, true, true )
		local pos = sitrooms[ mapName ]
		if pos then
			target:SetPos( pos )
			client:notify( string.format( "%s has been teleported to the sitroom.", target:Nick() ) )
			target:notify( "You have been teleported to the sitroom." )
			lia.log.add( client, "sendToSitRoom", string.format( "Map: %s | Target: %s | Position: %s", mapName, target:Nick(), tostring( pos ) ), "Teleported player to the sitroom for the current map" )
		else
			client:notifyWarning( "Sitroom location for this map has not been set." )
		end
	end
} )
