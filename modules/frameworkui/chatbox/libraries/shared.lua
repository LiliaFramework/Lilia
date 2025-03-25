local MODULE = MODULE
lia.chat.register( "meclose", {
	syntax = "[string action]",
	desc = "Displays a close-range emote action.",
	format = "**%s %s",
	onCanHear = lia.config.get( "ChatRange", 280 ) * 0.25,
	prefix = { "/meclose", "/actionclose" },
	font = "liaChatFontItalics",
	filter = "actions",
	deadCanChat = true
} )

lia.chat.register( "actions", {
	syntax = "[string action]",
	desc = "Displays a general action.",
	format = "**%s %s",
	color = Color( 255, 150, 0 ),
	onCanHear = lia.config.get( "ChatRange", 280 ),
	deadCanChat = true
} )

lia.chat.register( "mefar", {
	syntax = "[string action]",
	desc = "Displays a far-range emote action.",
	format = "**%s %s",
	onCanHear = lia.config.get( "ChatRange", 280 ) * 2,
	prefix = { "/mefar", "/actionfar" },
	font = "liaChatFontItalics",
	filter = "actions",
	deadCanChat = true
} )

lia.chat.register( "itclose", {
	syntax = "[string text]",
	desc = "Displays an in-character message at close range.",
	onChatAdd = function( _, text ) chat.AddText( lia.config.get( "ChatColor" ), "**" .. text ) end,
	onCanHear = lia.config.get( "ChatRange", 280 ) * 0.25,
	prefix = { "/itclose" },
	font = "liaChatFontItalics",
	filter = "actions",
	deadCanChat = true
} )

lia.chat.register( "itfar", {
	syntax = "[string text]",
	desc = "Displays an in-character message at far range.",
	onChatAdd = function( _, text ) chat.AddText( lia.config.get( "ChatColor" ), "**" .. text ) end,
	onCanHear = lia.config.get( "ChatRange", 280 ) * 2,
	prefix = { "/itfar" },
	font = "liaChatFontItalics",
	filter = "actions",
	deadCanChat = true
} )

lia.chat.register( "coinflip", {
	desc = "Flips a coin and displays the result.",
	format = "%s flipped a coin and it landed on %s.",
	onCanHear = lia.config.get( "ChatRange", 280 ),
	prefix = { "/coinflip" },
	color = Color( 236, 100, 9 ),
	filter = "actions",
	font = "liaChatFontItalics",
	deadCanChat = false
} )

lia.chat.register( "ic", {
	syntax = "[string text]",
	desc = "Says something in-character.",
	format = "%s says \"%s\"",
	onGetColor = function( speaker )
		local client = LocalPlayer()
		if client:getTracedEntity() == speaker then return lia.config.get( "ChatListenColor" ) end
		return lia.config.get( "ChatColor" )
	end,
	onCanHear = function( speaker, listener )
		if speaker == listener then return true end
		if speaker:EyePos():Distance( listener:EyePos() ) <= lia.config.get( "ChatRange", 280 ) then return true end
		return false
	end,
} )

lia.chat.register( "me", {
	syntax = "[string action]",
	desc = "Performs an emote action.",
	format = "**%s %s",
	onGetColor = lia.chat.classes.ic.onGetColor,
	onCanHear = function( speaker, listener )
		if speaker == listener then return true end
		if speaker:EyePos():Distance( listener:EyePos() ) <= lia.config.get( "ChatRange", 280 ) then return true end
		return false
	end,
	prefix = { "/me", "/action" },
	font = "liaChatFontItalics",
	filter = "actions",
	deadCanChat = true
} )

lia.chat.register( "it", {
	syntax = "[string text]",
	desc = "Displays an in-character descriptive message.",
	onChatAdd = function( _, text ) chat.AddText( lia.chat.timestamp( false ), lia.config.get( "ChatColor" ), "**" .. text ) end,
	onCanHear = function( speaker, listener )
		if speaker == listener then return true end
		if speaker:EyePos():Distance( listener:EyePos() ) <= lia.config.get( "ChatRange", 280 ) then return true end
		return false
	end,
	prefix = { "/it" },
	font = "liaChatFontItalics",
	filter = "actions",
	deadCanChat = true
} )

lia.chat.register( "w", {
	syntax = "[string text]",
	desc = "Whispers a message.",
	format = "%s whispers \"%s\"",
	onGetColor = function( speaker, text )
		local color = lia.chat.classes.ic.onGetColor( speaker, text )
		return Color( color.r - 35, color.g - 35, color.b - 35 )
	end,
	onCanHear = function( speaker, listener )
		if speaker == listener then return true end
		if speaker:EyePos():Distance( listener:EyePos() ) <= lia.config.get( "ChatRange", 280 ) * 0.25 then return true end
		return false
	end,
	prefix = { "/w", "/whisper" }
} )

lia.chat.register( "y", {
	syntax = "[string text]",
	desc = "Yells a message.",
	format = "%s yells \"%s\"",
	onGetColor = function( speaker, text )
		local color = lia.chat.classes.ic.onGetColor( speaker, text )
		return Color( color.r + 35, color.g + 35, color.b + 35 )
	end,
	onCanHear = function( speaker, listener )
		if speaker == listener then return true end
		if speaker:EyePos():Distance( listener:EyePos() ) <= lia.config.get( "ChatRange", 280 ) * 2 then return true end
		return false
	end,
	prefix = { "/y", "/yell" }
} )

lia.chat.register( "looc", {
	syntax = "[string text]",
	desc = "Out-of-character chat with a cooldown.",
	onCanSay = function( speaker )
		local delay = lia.config.get( "LOOCDelay", false )
		if speaker:isStaff() and lia.config.get( "LOOCDelayAdmin", false ) and delay > 0 and speaker.liaLastLOOC then
			local lastLOOC = CurTime() - speaker.liaLastLOOC
			if lastLOOC <= delay and ( not speaker:isStaff() or speaker:isStaff() and lia.config.get( "LOOCDelayAdmin", false ) ) then
				speaker:notifyLocalized( "loocDelay", delay - math.ceil( lastLOOC ) )
				return false
			end
		end

		speaker.liaLastLOOC = CurTime()
	end,
	onChatAdd = function( speaker, text ) chat.AddText( Color( 255, 50, 50 ), "[LOOC] ", lia.config.get( "ChatColor" ), speaker:Name() .. ": " .. text ) end,
	onCanHear = function( speaker, listener )
		if speaker == listener then return true end
		if speaker:EyePos():Distance( listener:EyePos() ) <= lia.config.get( "ChatRange", 280 ) then return true end
		return false
	end,
	prefix = { "looc" },
	noSpaceAfter = true,
	filter = "ooc"
} )

lia.chat.register( "adminchat", {
	syntax = "[string text]",
	desc = "Sends a message to admin chat.",
	onGetColor = function() return Color( 0, 196, 255 ) end,
	onCanHear = function( _, listener )
		if listener:hasPrivilege( "Staff Permissions - Admin Chat" ) then return true end
		return false
	end,
	onCanSay = function( speaker )
		if not speaker:hasPrivilege( "Staff Permissions - Admin Chat" ) then
			speaker:notifyWarning( "You aren't an admin. Use '@messagehere' to create a ticket." )
			return false
		end
		return true
	end,
	onChatAdd = function( speaker, text ) chat.AddText( Color( 255, 215, 0 ), "[Аdmin Chat] ", Color( 128, 0, 255, 255 ), speaker:getChar():getName(), ": ", Color( 255, 255, 255 ), text ) end,
	prefix = { "/adminchat", "/asay", "/admin", "/a" }
} )

lia.chat.register( "roll", {
	desc = "Rolls a dice and displays the result.",
	format = "%s has rolled %s.",
	color = Color( 155, 111, 176 ),
	filter = "actions",
	font = "liaChatFontItalics",
	deadCanChat = true,
	onCanHear = function( speaker, listener )
		if speaker == listener then return true end
		if speaker:EyePos():Distance( listener:EyePos() ) <= lia.config.get( "ChatRange", 280 ) then return true end
		return false
	end,
} )

lia.chat.register( "pm", {
	syntax = "[string player] [string message]",
	desc = "Sends a private message to a specified player.",
	format = "[PM] %s: %s.",
	color = Color( 249, 211, 89 ),
	filter = "pm",
	deadCanChat = true
} )

lia.chat.register( "eventlocal", {
	syntax = "[string text]",
	desc = "Sends a local event message (admin only).",
	onCanSay = function( speaker ) return speaker:hasPrivilege( "Staff Permissions - Local Event Chat" ) end,
	onCanHear = function( speaker, listener )
		if speaker == listener then return true end
		if speaker:EyePos():Distance( listener:EyePos() ) <= lia.config.get( "ChatRange", 280 ) * 6 then return true end
		return false
	end,
	onChatAdd = function( _, text ) chat.AddText( Color( 255, 150, 0 ), text ) end,
	prefix = { "/eventlocal" },
	font = "liaMediumFont"
} )

lia.chat.register( "event", {
	syntax = "[string text]",
	desc = "Sends an event message to everyone (admin only).",
	onCanSay = function( speaker ) return speaker:hasPrivilege( "Staff Permissions - Event Chat" ) end,
	onCanHear = function() return true end,
	onChatAdd = function( _, text ) chat.AddText( Color( 255, 150, 0 ), text ) end,
	prefix = { "/event" },
	font = "liaMediumFont"
} )

lia.chat.register( "ooc", {
	syntax = "[string text]",
	desc = "Out-of-character chat for general discussion.",
	onCanSay = function( speaker, text )
		if GetGlobalBool( "oocblocked", false ) then
			speaker:notifyWarning( "The OOC is Globally Blocked!" )
			return false
		end

		if MODULE.OOCBans[ speaker:SteamID64() ] then
			speaker:notifyWarning( "You have been banned from using OOC!" )
			return false
		end

		if string.len( text ) > lia.config.get( "OOCLimit", 150 ) then
			speaker:notifyWarning( "Text too big!" )
			return false
		end

		local customDelay = hook.Run( "getOOCDelay", speaker )
		local oocDelay = customDelay or lia.config.get( "OOCDelay", 10 )
		if not speaker:hasPrivilege( "Staff Permissions - No OOC Cooldown" ) and oocDelay > 0 and speaker.liaLastOOC then
			local lastOOC = CurTime() - speaker.liaLastOOC
			if lastOOC <= oocDelay then
				speaker:notifyLocalized( "oocDelay", oocDelay - math.ceil( lastOOC ) )
				return false
			end
		end

		speaker.liaLastOOC = CurTime()
	end,
	onCanHear = function() return true end,
	onChatAdd = function( speaker, text ) chat.AddText( Color( 255, 50, 50 ), " [OOC] ", speaker, color_white, ": " .. text ) end,
	prefix = { "//", "/ooc" },
	noSpaceAfter = true,
	filter = "ooc"
} )

lia.chat.register( "s", {
	syntax = "[string text]",
	desc = "Screams a message.",
	format = "%s screams \"%s\"",
	onChatAdd = function( speaker, text, anonymous )
		local speako = anonymous and "Someone" or hook.Run( "GetDisplayedName", speaker, "ic" ) or IsValid( speaker ) and speaker:Name() or "Console"
		chat.AddText( Color( 200, 20, 20 ), speako .. " screams \"" .. text .. "\"" )
	end,
	onCanHear = lia.config.get( "ChatRange", 280 ) * 4,
	prefix = { "/s", "/scream" }
} )

lia.chat.register( "me's", {
	syntax = "[string action]",
	desc = "Displays an action in possessive form.",
	format = "**%s's %s",
	onCanHear = lia.config.get( "ChatRange", 280 ),
	onChatAdd = function( speaker, text, anonymous )
		local speako = anonymous and "Someone" or hook.Run( "GetDisplayedName", speaker, "ic" ) or IsValid( speaker ) and speaker:Name() or "Console"
		local texCol = lia.config.get( "ChatColor" )
		if LocalPlayer():getTracedEntity() == speaker then texCol = lia.config.get( "ChatListenColor" ) end
		texCol = Color( texCol.r, texCol.g, texCol.b )
		local nameCol = Color( texCol.r + 30, texCol.g + 30, texCol.b + 30 )
		if LocalPlayer() == speaker then
			local tempCol = lia.config.get( "ChatListenColor" )
			texCol = Color( tempCol.r + 20, tempCol.b + 20, tempCol.g + 20 )
			nameCol = Color( tempCol.r + 40, tempCol.b + 60, tempCol.g + 40 )
		end

		chat.AddText( nameCol, "**" .. speako .. "'s", texCol, " " .. text )
	end,
	prefix = { "/me's", "/action's" },
	font = "liaChatFontItalics",
	filter = "actions",
	deadCanChat = true
} )

lia.chat.register( "mefarfar", {
	syntax = "[string action]",
	desc = "Displays an exaggerated far-range action.",
	format = "**%s %s",
	onChatAdd = function( speaker, text, anonymous )
		local speako = anonymous and "Someone" or hook.Run( "GetDisplayedName", speaker, "ic" ) or IsValid( speaker ) and speaker:Name() or "Console"
		local texCol = lia.config.get( "ChatColor" )
		if LocalPlayer():getTracedEntity() == speaker then texCol = lia.config.get( "ChatListenColor" ) end
		texCol = Color( texCol.r + 45, texCol.g + 45, texCol.b + 45 )
		local nameCol = Color( texCol.r + 30, texCol.g + 30, texCol.b + 30 )
		if LocalPlayer() == speaker then
			local tempCol = lia.config.get( "ChatListenColor" )
			texCol = Color( tempCol.r + 65, tempCol.b + 65, tempCol.g + 65 )
			nameCol = Color( tempCol.r + 40, tempCol.b + 60, tempCol.g + 40 )
		end

		chat.AddText( nameCol, "**" .. speako, texCol, " " .. text )
	end,
	onCanHear = lia.config.get( "ChatRange", 280 ) * 4,
	prefix = { "/mefarfar", "/actionyy", "/meyy" },
	font = "liaChatFontItalics",
	filter = "actions",
	deadCanChat = true
} )

lia.chat.register( "help", {
	syntax = "[string text]",
	desc = "Sends a help message to staff.",
	onCanSay = function() return true end,
	onCanHear = function( speaker, listener )
		if listener:isStaffOnDuty() or listener == speaker or listener:hasPrivilege( "Staff Permissions - Always Have Access to Help Chat" ) then
			return true
		else
			return false
		end
	end,
	onChatAdd = function( speaker, text ) chat.AddText( Color( 200, 50, 50 ), "[HELP] " .. speaker:GetName(), color_white, ": " .. text ) end,
} )