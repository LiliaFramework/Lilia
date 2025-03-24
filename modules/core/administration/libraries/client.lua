function MODULE:ShowPlayerOptions( target, options )
	local client = LocalPlayer()
	if ( client:hasPrivilege( "Staff Permissions - Can Access Scoreboard Info Out Of Staff" ) or client:hasPrivilege( "Staff Permissions - Can Access Scoreboard Admin Options" ) and client:isStaffOnDuty() ) and IsValid( target ) then
		local orderedOptions = {
			{
				name = "Name: " .. target:Name() .. " (copy)",
				image = "icon16/page_copy.png",
				func = function()
					client:ChatPrint( "Copied " .. target:Name() .. " to Clipboard!" )
					SetClipboardText( target:Name() )
				end
			},
			{
				name = "CharID: " .. ( target:getChar() and target:getChar():getID() or "N/A" ) .. " (copy)",
				image = "icon16/page_copy.png",
				func = function()
					if target:getChar() then
						client:ChatPrint( "Copied CharID: " .. target:getChar():getID() .. " to Clipboard!" )
						SetClipboardText( target:getChar():getID() )
					end
				end
			},
			{
				name = "SteamID: " .. target:SteamID64() .. " (copy)",
				image = "icon16/page_copy.png",
				func = function()
					client:ChatPrint( "Copied SteamID: " .. target:SteamID64() .. " to Clipboard!" )
					SetClipboardText( target:SteamID64() )
				end
			},
			{
				name = "SteamID64: " .. target:SteamID64() .. " (copy)",
				image = "icon16/page_copy.png",
				func = function()
					client:ChatPrint( "Copied SteamID64: " .. target:SteamID64() .. " to Clipboard!" )
					SetClipboardText( target:SteamID64() )
				end
			},
			{
				name = "Blind",
				image = "icon16/eye.png",
				func = function() RunConsoleCommand( "say", "!blind " .. target:SteamID64() ) end
			},
			{
				name = "Freeze",
				image = "icon16/lock.png",
				func = function() RunConsoleCommand( "say", "!freeze " .. target:SteamID64() ) end
			},
			{
				name = "Gag",
				image = "icon16/sound_mute.png",
				func = function() RunConsoleCommand( "say", "!gag " .. target:SteamID64() ) end
			},
			{
				name = "Ignite",
				image = "icon16/fire.png",
				func = function() RunConsoleCommand( "say", "!ignite " .. target:SteamID64() ) end
			},
			{
				name = "Jail",
				image = "icon16/lock.png",
				func = function() RunConsoleCommand( "say", "!jail " .. target:SteamID64() ) end
			},
			{
				name = "Mute",
				image = "icon16/sound_delete.png",
				func = function() RunConsoleCommand( "say", "!mute " .. target:SteamID64() ) end
			},
			{
				name = "Slay",
				image = "icon16/bomb.png",
				func = function() RunConsoleCommand( "say", "!slay " .. target:SteamID64() ) end
			},
			{
				name = "Unblind",
				image = "icon16/eye.png",
				func = function() RunConsoleCommand( "say", "!unblind " .. target:SteamID64() ) end
			},
			{
				name = "Ungag",
				image = "icon16/sound_low.png",
				func = function() RunConsoleCommand( "say", "!ungag " .. target:SteamID64() ) end
			},
			{
				name = "Unfreeze",
				image = "icon16/accept.png",
				func = function() RunConsoleCommand( "say", "!unfreeze " .. target:SteamID64() ) end
			},
			{
				name = "Unmute",
				image = "icon16/sound_add.png",
				func = function() RunConsoleCommand( "say", "!unmute " .. target:SteamID64() ) end
			},
			{
				name = "Bring",
				image = "icon16/arrow_down.png",
				func = function() RunConsoleCommand( "say", "!bring " .. target:SteamID64() ) end
			},
			{
				name = "Goto",
				image = "icon16/arrow_right.png",
				func = function() RunConsoleCommand( "say", "!goto " .. target:SteamID64() ) end
			},
			{
				name = "Respawn",
				image = "icon16/arrow_refresh.png",
				func = function() RunConsoleCommand( "say", "!respawn " .. target:SteamID64() ) end
			},
			{
				name = "Return",
				image = "icon16/arrow_redo.png",
				func = function() RunConsoleCommand( "say", "!return " .. target:SteamID64() ) end
			}
		}

		for _, option in ipairs( orderedOptions ) do
			table.insert( options, option )
		end
	end
end

function MODULE:LoadFonts( font )
	surface.CreateFont( "ConfigFont", {
		font = font,
		size = 26,
		weight = 500,
		extended = true,
		antialias = true
	} )

	surface.CreateFont( "MediumConfigFont", {
		font = font,
		size = 30,
		weight = 1000,
		extended = true,
		antialias = true
	} )

	surface.CreateFont( "SmallConfigFont", {
		font = font,
		size = math.max( ScreenScale( 8 ), 20 ),
		weight = 500,
		extended = true,
		antialias = true
	} )

	surface.CreateFont( "ConfigFontBold", {
		font = font,
		size = 26,
		weight = 1000,
		extended = true,
		antialias = true
	} )

	surface.CreateFont( "ConfigFontLarge", {
		font = font,
		size = 36,
		weight = 700,
		extended = true,
		antialias = true
	} )

	surface.CreateFont( "DescriptionFontLarge", {
		font = font,
		size = 24,
		weight = 500,
		extended = true,
		antialias = true
	} )
end

lia.keybind.add( KEY_NONE, "Admin Mode", function() if not IsFirstTimePredicted() then return end lia.command.send( "adminmode" ) end )
