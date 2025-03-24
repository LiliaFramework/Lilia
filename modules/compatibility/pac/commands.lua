lia.command.add( "fixpac", {
	adminOnly = false,
	desc = "Clears PAC caches and restarts PAC to fix any outfit issues.",
	onRun = function( client )
		timer.Simple( 0, function() if IsValid( client ) then client:ConCommand( "pac_clear_parts" ) end end )
		timer.Simple( 0.5, function()
			if IsValid( client ) then
				client:ConCommand( "pac_urlobj_clear_cache" )
				client:ConCommand( "pac_urltex_clear_cache" )
			end
		end )

		timer.Simple( 1.0, function() if IsValid( client ) then client:ConCommand( "pac_restart" ) end end )
		timer.Simple( 1.5, function() if IsValid( client ) then client:notifyLocalized( "fixpac_success" ) end end )
	end
} )

lia.command.add( "pacenable", {
	adminOnly = false,
	desc = "Enables PAC (Player Appearance Customizer).",
	onRun = function( client )
		client:ConCommand( "pac_enable 1" )
		client:notifyLocalized( "pacenable_success" )
	end
} )

lia.command.add( "pacdisable", {
	adminOnly = false,
	desc = "Disables PAC (Player Appearance Customizer).",
	onRun = function( client )
		client:ConCommand( "pac_enable 0" )
		client:notifyLocalized( "pacdisable_message" )
	end
} )