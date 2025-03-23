lia.config = lia.config or {}
lia.config.stored = lia.config.stored or {}
function lia.config.add( key, name, value, callback, data )
	assert( isstring( key ), "Expected config key to be string, got " .. type( key ) )
	assert( istable( data ), "Expected config data to be a table, got " .. type( data ) )
	local t = type( value )
	local configType = t == "boolean" and "Boolean" or t == "number" and ( math.floor( value ) == value and "Int" or "Float" ) or t == "table" and value.r and value.g and value.b and "Color" or "Generic"
	data.type = data.type or configType
	local oldConfig = lia.config.stored[ key ]
	local savedValue = oldConfig and oldConfig.value or value
	local category = data.category
	local desc = data.desc
	lia.config.stored[ key ] = {
		name = name or key,
		data = data,
		value = savedValue,
		default = value,
		desc = desc,
		category = category or L( "character" ),
		noNetworking = data.noNetworking or false,
		callback = callback
	}
end

function lia.config.setDefault( key, value )
	local config = lia.config.stored[ key ]
	if config then config.default = value end
end

function lia.config.forceSet( key, value, noSave )
	local config = lia.config.stored[ key ]
	if config then config.value = value end
	if not noSave then lia.config.save() end
end

function lia.config.set( key, value )
	local config = lia.config.stored[ key ]
	if config then
		local oldValue = config.value
		config.value = value
		if SERVER then
			if not config.noNetworking then netstream.Start( nil, "cfgSet", key, value ) end
			if config.callback then config.callback( oldValue, value ) end
			lia.config.save()
		end
	end
end

function lia.config.get( key, default )
	local config = lia.config.stored[ key ]
	if config then
		if config.value ~= nil then
			if istable( config.value ) and config.value.r and config.value.g and config.value.b then config.value = Color( config.value.r, config.value.g, config.value.b ) end
			return config.value
		elseif config.default ~= nil then
			return config.default
		end
	end
	return default
end

function lia.config.load()
	if SERVER then
		local data = lia.data.get( "config", nil, false, true )
		if data then
			for k, v in pairs( data ) do
				lia.config.stored[ k ] = lia.config.stored[ k ] or {}
				lia.config.stored[ k ].value = v
			end
		end
	end

	hook.Run( "InitializedConfig" )
end

if SERVER then
	function lia.config.getChangedValues()
		local data = {}
		for k, v in pairs( lia.config.stored ) do
			if v.default ~= v.value then data[ k ] = v.value end
		end
		return data
	end

	function lia.config.send( client )
		netstream.Start( client, "cfgList", lia.config.getChangedValues() )
	end

	function lia.config.save()
		local data = {}
		for k, v in pairs( lia.config.getChangedValues() ) do
			data[ k ] = v
		end

		lia.data.set( "config", data, false, true )
	end
end

lia.config.add( "MoneyModel", "Money Model", "models/props_lab/box01a.mdl", nil, {
	desc = "Defines the model used for representing money in the game.",
	category = "Money",
	type = "Generic"
} )

lia.config.add( "MoneyLimit", "Money Limit", 0, nil, {
	desc = "Sets the limit of money a player can have [0 for infinite].",
	category = "Money",
	type = "Int",
	min = 0,
	max = 1000000
} )

lia.config.add( "CurrencySymbol", "Currency Symbol", "", function( newVal ) lia.currency.symbol = newVal end, {
	desc = "Specifies the currency symbol used in the game.",
	category = "Money",
	type = "Generic"
} )

lia.config.add( "CurrencySingularName", "Currency Singular Name", "Dollar", function( newVal ) lia.currency.singular = newVal end, {
	desc = "Singular name of the in-game currency.",
	category = "Money",
	type = "Generic"
} )

lia.config.add( "CurrencyPluralName", "Currency Plural Name", "Dollars", function( newVal ) lia.currency.plural = newVal end, {
	desc = "Plural name of the in-game currency.",
	category = "Money",
	type = "Generic"
} )

lia.config.add( "invW", "Inventory Width", 6, nil, {
	desc = "Defines the width of the default inventory.",
	category = "Character",
	type = "Int",
	min = 1,
	max = 20
} )

lia.config.add( "invH", "Inventory Height", 4, nil, {
	desc = "Defines the height of the default inventory.",
	category = "Character",
	type = "Int",
	min = 1,
	max = 20
} )

lia.config.add( "WalkSpeed", "Walk Speed", 130, function( _, newValue )
	for _, client in player.Iterator() do
		client:SetWalkSpeed( newValue )
	end
end, {
	desc = "Controls how fast characters walk.",
	category = "Character",
	type = "Int",
	min = 50,
	max = 300
} )

lia.config.add( "RunSpeed", "Run Speed", 235, function( _, newValue )
	for _, client in player.Iterator() do
		client:SetRunSpeed( newValue )
	end
end, {
	desc = "Controls how fast characters run.",
	category = "Character",
	type = "Int",
	min = 100,
	max = 500
} )

lia.config.add( "WalkRatio", "Walk Ratio", 0.5, nil, {
	desc = "Defines the walk speed ratio when holding the Alt key.",
	category = "Character",
	type = "Float",
	min = 0.1,
	max = 1.0,
	decimals = 2
} )

lia.config.add( "AllowExistNames", "Allow Duplicate Names", true, nil, {
	desc = "Determines whether duplicate character names are allowed.",
	category = "Character",
	type = "Boolean"
} )

lia.config.add( "MaxCharacters", "Max Characters", 5, nil, {
	desc = "Sets the maximum number of characters a player can have.",
	category = "Character",
	type = "Int",
	min = 1,
	max = 10
} )

lia.config.add( "AllowPMs", "Allow Private Messages", true, nil, {
	desc = "Determines whether private messages are allowed.",
	category = "Chat",
	type = "Boolean"
} )

lia.config.add( "MinDescLen", "Minimum Description Length", 16, nil, {
	desc = "Minimum length required for a character's description.",
	category = "Character",
	type = "Int",
	min = 10,
	max = 500
} )

lia.config.add( "SaveInterval", "Save Interval", 300, nil, {
	desc = "Interval for character saves in seconds.",
	category = "Character",
	type = "Int",
	min = 60,
	max = 3600
} )

lia.config.add( "DefMoney", "Default Money", 0, nil, {
	desc = "Specifies the default amount of money a player starts with.",
	category = "Character",
	type = "Int",
	min = 0,
	max = 10000
} )

lia.config.add( "DataSaveInterval", "Data Save Interval", 600, nil, {
	desc = "Time interval between data saves.",
	category = "Data",
	type = "Int",
	min = 60,
	max = 3600
} )

lia.config.add( "CharacterDataSaveInterval", "Character Data Save Interval", 300, nil, {
	desc = "Time interval between character data saves.",
	category = "Data",
	type = "Int",
	min = 60,
	max = 3600
} )

lia.config.add( "SpawnTime", "Respawn Time", 5, nil, {
	desc = "Time to respawn after death.",
	category = "Death",
	type = "Float",
	min = 1,
	max = 60
} )

lia.config.add( "TimeToEnterVehicle", "Vehicle Entry Time", 1, nil, {
	desc = "Time [in seconds] required to enter a vehicle.",
	category = "Quality of Life",
	type = "Float",
	min = 0.5,
	max = 10
} )

lia.config.add( "CarEntryDelayEnabled", "Car Entry Delay Enabled", true, nil, {
	desc = "Determines if the car entry delay is applicable.",
	category = "Timers",
	type = "Boolean"
} )

lia.config.add( "Font", "Font", "Arial", nil, {
	desc = "Specifies the core font used for UI elements.",
	category = "Visuals",
	type = "Generic"
} )

lia.config.add( "GenericFont", "Generic Font", "Segoe UI", nil, {
	desc = "Specifies the secondary font used for UI elements.",
	category = "Visuals",
	type = "Generic"
} )

lia.config.add( "MaxChatLength", "Max Chat Length", 256, nil, {
	desc = "Sets the maximum length of chat messages.",
	category = "Visuals",
	type = "Int",
	min = 50,
	max = 1024
} )

lia.config.add( "SchemaYear", "Schema Year", 2025, nil, {
	desc = "Year of the gamemode's schema.",
	category = "Server",
	type = "Int",
	min = 0,
	max = 999999
} )

lia.config.add( "AmericanDates", "American Dates", true, nil, {
	desc = "Determines whether to use the American date format.",
	category = "Server",
	type = "Boolean"
} )

lia.config.add( "AmericanTimeStamp", "American Timestamp", true, nil, {
	desc = "Determines whether to use the American timestamp format.",
	category = "Server",
	type = "Boolean"
} )

lia.config.add( "AdminConsoleNetworkLogs", "Admin Console Network Logs", true, nil, {
	desc = "Specifies if the logging system should replicate to super admins' consoles.",
	category = "Staff",
	type = "Boolean"
} )

lia.config.add( "Color", "Theme Color", {
	r = 37,
	g = 116,
	b = 108
}, nil, {
	desc = "Sets the theme color used throughout the gamemode.",
	category = "Visuals",
	type = "Color"
} )

lia.config.add( "AutoDownloadWorkshop", "Auto Download Workshop Content", true, nil, {
	desc = "Determines whether Workshop content is automatically downloaded by the server and clients.",
	category = "Server",
	type = "Boolean"
} )

lia.config.add( "CharMenuBGInputDisabled", "Character Menu BG Input Disabled", true, nil, {
	desc = "Whether background input is disabled durinag character menu use",
	category = "Main Menu",
	type = "Boolean"
} )

lia.config.add( "AllowKeybindEditing", "Allow Keybind Editing", true, nil, {
	desc = "Whether keybind editing is allowed",
	category = "Server",
	type = "Boolean"
} )

hook.Add( "PopulateConfigurationTabs", "PopulateConfig", function( pages )
	local client = LocalPlayer()
	local ConfigFormatting = {
		Int = function( key, name, config, parent )
			local container = vgui.Create( "DPanel", parent )
			container:SetTall( 220 )
			container:Dock( TOP )
			container:DockMargin( 0, 60, 0, 10 )
			container.Paint = function( _, w, h ) draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 200 ) ) end
			local panel = container:Add( "DPanel" )
			panel:Dock( FILL )
			panel.Paint = nil
			local label = panel:Add( "DLabel" )
			label:Dock( TOP )
			label:SetTall( 45 )
			label:SetText( name )
			label:SetFont( "ConfigFontLarge" )
			label:SetContentAlignment( 5 )
			label:SetTextColor( Color( 255, 255, 255 ) )
			label:DockMargin( 0, 20, 0, 0 )
			local description = panel:Add( "DLabel" )
			description:Dock( TOP )
			description:SetTall( 35 )
			description:SetText( config.desc or "" )
			description:SetFont( "DescriptionFontLarge" )
			description:SetContentAlignment( 5 )
			description:SetTextColor( Color( 200, 200, 200 ) )
			description:DockMargin( 0, 10, 0, 0 )
			local slider = panel:Add( "DNumSlider" )
			slider:Dock( FILL )
			slider:DockMargin( 10, 0, 10, 0 )
			slider:SetMin( lia.config.get( key .. "_min", config.data and config.data.min or 0 ) )
			slider:SetMax( lia.config.get( key .. "_max", config.data and config.data.max or 1 ) )
			slider:SetDecimals( 0 )
			slider:SetValue( lia.config.get( key, config.value ) )
			slider:SetText( "" )
			slider.PerformLayout = function()
				slider.Label:SetWide( 0 )
				slider.TextArea:SetWide( 50 )
			end

			slider.OnValueChanged = function( _, newValue )
				local timerName = "ConfigChange_" .. key .. "_" .. os.time()
				timer.Create( timerName, 0.5, 1, function() netstream.Start( "cfgSet", key, name, math.floor( newValue ) ) end )
			end
			return container
		end,
		Float = function( key, name, config, parent )
			local container = vgui.Create( "DPanel", parent )
			container:SetTall( 220 )
			container:Dock( TOP )
			container:DockMargin( 0, 60, 0, 10 )
			container.Paint = function( _, w, h ) draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 200 ) ) end
			local panel = container:Add( "DPanel" )
			panel:Dock( FILL )
			panel.Paint = nil
			local label = panel:Add( "DLabel" )
			label:Dock( TOP )
			label:SetTall( 45 )
			label:SetText( name )
			label:SetFont( "ConfigFontLarge" )
			label:SetContentAlignment( 5 )
			label:SetTextColor( Color( 255, 255, 255 ) )
			label:DockMargin( 0, 20, 0, 0 )
			local description = panel:Add( "DLabel" )
			description:Dock( TOP )
			description:SetTall( 35 )
			description:SetText( config.desc or "" )
			description:SetFont( "DescriptionFontLarge" )
			description:SetContentAlignment( 5 )
			description:SetTextColor( Color( 200, 200, 200 ) )
			description:DockMargin( 0, 10, 0, 0 )
			local slider = panel:Add( "DNumSlider" )
			slider:Dock( FILL )
			slider:DockMargin( 10, 0, 10, 0 )
			slider:SetMin( lia.config.get( key .. "_min", config.data and config.data.min or 0 ) )
			slider:SetMax( lia.config.get( key .. "_max", config.data and config.data.max or 1 ) )
			slider:SetDecimals( 2 )
			slider:SetValue( lia.config.get( key, config.value ) )
			slider:SetText( "" )
			slider.PerformLayout = function()
				slider.Label:SetWide( 0 )
				slider.TextArea:SetWide( 50 )
			end

			slider.OnValueChanged = function( _, newValue )
				local timerName = "ConfigChange_" .. key .. "_" .. os.time()
				timer.Create( timerName, 0.5, 1, function() netstream.Start( "cfgSet", key, name, tonumber( newValue ) ) end )
			end
			return container
		end,
		Generic = function( key, name, config, parent )
			local container = vgui.Create( "DPanel", parent )
			container:SetTall( 220 )
			container:Dock( TOP )
			container:DockMargin( 0, 60, 0, 10 )
			container.Paint = function() end
			local panel = container:Add( "DPanel" )
			panel:Dock( FILL )
			panel.Paint = nil
			local label = panel:Add( "DLabel" )
			label:Dock( TOP )
			label:SetTall( 45 )
			label:SetText( name )
			label:SetFont( "ConfigFontLarge" )
			label:SetContentAlignment( 5 )
			label:SetTextColor( Color( 255, 255, 255 ) )
			label:DockMargin( 0, 20, 0, 0 )
			local description = panel:Add( "DLabel" )
			description:Dock( TOP )
			description:SetTall( 35 )
			description:SetText( config.desc or "" )
			description:SetFont( "DescriptionFontLarge" )
			description:SetContentAlignment( 5 )
			description:SetTextColor( Color( 200, 200, 200 ) )
			description:DockMargin( 0, 10, 0, 0 )
			local entry = panel:Add( "DTextEntry" )
			entry:Dock( TOP )
			entry:SetTall( 60 )
			entry:DockMargin( 300, 10, 300, 0 )
			entry:SetText( tostring( lia.config.get( key, config.value ) ) )
			entry:SetFont( "ConfigFontLarge" )
			entry:SetTextColor( Color( 255, 255, 255 ) )
			entry.Paint = function( self, w, h )
				draw.RoundedBox( 0, 0, 0, w, h, Color( 50, 50, 50, 200 ) )
				self:DrawTextEntryText( Color( 255, 255, 255 ), Color( 255, 255, 255 ), Color( 255, 255, 255 ) )
			end

			entry.OnEnter = function()
				local newValue = entry:GetText()
				local timerName = "ConfigChange_" .. key .. "_" .. os.time()
				timer.Create( timerName, 0.5, 1, function() netstream.Start( "cfgSet", key, name, newValue ) end )
			end
			return container
		end,
		Boolean = function( key, name, config, parent )
			local container = vgui.Create( "DPanel", parent )
			container:SetTall( 220 )
			container:Dock( TOP )
			container:DockMargin( 0, 60, 0, 10 )
			container.Paint = function( _, w, h ) draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 200 ) ) end
			local panel = container:Add( "DPanel" )
			panel:Dock( FILL )
			panel.Paint = nil
			local label = panel:Add( "DLabel" )
			label:Dock( TOP )
			label:SetTall( 45 )
			label:SetText( name )
			label:SetFont( "ConfigFontLarge" )
			label:SetContentAlignment( 5 )
			label:SetTextColor( Color( 255, 255, 255 ) )
			label:DockMargin( 0, 20, 0, 0 )
			local description = panel:Add( "DLabel" )
			description:Dock( TOP )
			description:SetTall( 35 )
			description:SetText( config.desc or "" )
			description:SetFont( "DescriptionFontLarge" )
			description:SetContentAlignment( 5 )
			description:SetTextColor( Color( 200, 200, 200 ) )
			description:DockMargin( 0, 10, 0, 0 )
			local button = panel:Add( "DButton" )
			button:Dock( TOP )
			button:SetTall( 100 )
			button:DockMargin( 100, 10, 100, 0 )
			button:SetText( "" )
			button:SetCursor( "hand" )
			button.Paint = function( _, w, h )
				local isChecked = lia.config.get( key, config.value )
				local check = getIcon( "0xe880", true )
				local uncheck = getIcon( "0xf096", true )
				local icon = isChecked and check or uncheck
				lia.util.drawText( icon, w / 2, h / 2 - 10, color_white, 1, 1, "liaIconsHugeNew" )
			end

			button.DoClick = function()
				local newValue = not lia.config.get( key, config.value )
				local timerName = "ConfigChange_" .. key .. "_" .. os.time()
				timer.Create( timerName, 0.5, 1, function() netstream.Start( "cfgSet", key, name, newValue ) end )
			end
			return container
		end,
		Color = function( key, name, config, parent )
			local container = vgui.Create( "DPanel", parent )
			container:SetTall( 220 )
			container:Dock( TOP )
			container:DockMargin( 0, 60, 0, 10 )
			container.Paint = function( _, w, h ) draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 200 ) ) end
			local panel = container:Add( "DPanel" )
			panel:Dock( FILL )
			panel.Paint = nil
			local label = panel:Add( "DLabel" )
			label:Dock( TOP )
			label:SetTall( 45 )
			label:SetText( name )
			label:SetFont( "ConfigFontLarge" )
			label:SetContentAlignment( 5 )
			label:SetTextColor( Color( 255, 255, 255 ) )
			label:DockMargin( 0, 20, 0, 0 )
			local description = panel:Add( "DLabel" )
			description:Dock( TOP )
			description:SetTall( 35 )
			description:SetText( config.desc or "" )
			description:SetFont( "DescriptionFontLarge" )
			description:SetContentAlignment( 5 )
			description:SetTextColor( Color( 200, 200, 200 ) )
			description:DockMargin( 0, 10, 0, 0 )
			local button = panel:Add( "DButton" )
			button:Dock( FILL )
			button:DockMargin( 10, 0, 10, 0 )
			button:SetText( "" )
			button:SetCursor( "hand" )
			button.Paint = function( _, w, h )
				local colorValue = lia.config.get( key, config.value )
				surface.SetDrawColor( colorValue )
				surface.DrawRect( 10, h / 2 - 15, w - 20, 30 )
				draw.RoundedBox( 2, 10, h / 2 - 15, w - 20, 30, Color( 255, 255, 255, 50 ) )
			end

			button.DoClick = function()
				if IsValid( button.picker ) then button.picker:Remove() end
				local pickerFrame = vgui.Create( "DFrame" )
				pickerFrame:SetSize( 300, 400 )
				pickerFrame:SetTitle( "Choose Color" )
				pickerFrame:Center()
				pickerFrame:MakePopup()
				local colorMixer = pickerFrame:Add( "DColorMixer" )
				colorMixer:Dock( FILL )
				colorMixer:SetPalette( true )
				colorMixer:SetAlphaBar( true )
				colorMixer:SetWangs( true )
				colorMixer:SetColor( lia.config.get( key, config.value ) )
				local confirm = pickerFrame:Add( "DButton" )
				confirm:Dock( BOTTOM )
				confirm:SetTall( 40 )
				confirm:SetText( "Apply" )
				confirm:SetTextColor( color_white )
				confirm:SetFont( "ConfigFontLarge" )
				confirm:DockMargin( 10, 10, 10, 10 )
				confirm.Paint = function( self, w, h )
					surface.SetDrawColor( Color( 0, 150, 0 ) )
					surface.DrawRect( 0, 0, w, h )
					if self:IsHovered() then
						surface.SetDrawColor( Color( 0, 180, 0 ) )
						surface.DrawRect( 0, 0, w, h )
					end

					surface.SetDrawColor( Color( 255, 255, 255 ) )
					surface.DrawOutlinedRect( 0, 0, w, h )
				end

				confirm.DoClick = function()
					local newColor = colorMixer:GetColor()
					local timerName = "ConfigChange_" .. key .. "_" .. os.time()
					timer.Create( timerName, 0.5, 1, function() netstream.Start( "cfgSet", key, name, newColor ) end )
					pickerFrame:Remove()
				end

				colorMixer.ValueChanged = function( _, value ) pickerFrame.curColor = value end
				button.picker = pickerFrame
			end
			return container
		end,
		Table = function( key, name, config, parent )
			local container = vgui.Create( "DPanel", parent )
			container:SetTall( 220 )
			container:Dock( TOP )
			container:DockMargin( 0, 60, 0, 10 )
			container.Paint = function( _, w, h ) draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 200 ) ) end
			local panel = container:Add( "DPanel" )
			panel:Dock( FILL )
			panel.Paint = nil
			local label = panel:Add( "DLabel" )
			label:Dock( TOP )
			label:SetTall( 45 )
			label:SetText( name )
			label:SetFont( "ConfigFontLarge" )
			label:SetContentAlignment( 5 )
			label:SetTextColor( Color( 255, 255, 255 ) )
			label:DockMargin( 0, 20, 0, 0 )
			local description = panel:Add( "DLabel" )
			description:Dock( TOP )
			description:SetTall( 35 )
			description:SetText( config.desc or "" )
			description:SetFont( "DescriptionFontLarge" )
			description:SetContentAlignment( 5 )
			description:SetTextColor( Color( 200, 200, 200 ) )
			description:DockMargin( 0, 10, 0, 0 )
			local comboBox = panel:Add( "DComboBox" )
			comboBox:Dock( TOP )
			comboBox:SetTall( 60 )
			comboBox:DockMargin( 300, 10, 300, 0 )
			comboBox:SetValue( tostring( lia.config.get( key, config.value ) ) )
			comboBox:SetFont( "ConfigFontLarge" )
			comboBox:SetTextColor( Color( 255, 255, 255 ) )
			comboBox.Paint = function( self, w, h )
				draw.RoundedBox( 0, 0, 0, w, h, Color( 50, 50, 50, 200 ) )
				self:DrawTextEntryText( Color( 255, 255, 255 ), Color( 255, 255, 255 ), Color( 255, 255, 255 ) )
			end

			local options = lia.config.get( key .. "_options", config.data and config.data.options or {} )
			for _, option in ipairs( options ) do
				comboBox:AddChoice( option )
			end

			comboBox.OnSelect = function( _, _, value )
				local timerName = "ConfigChange_" .. key .. "_" .. os.time()
				timer.Create( timerName, 0.5, 1, function() netstream.Start( "cfgSet", key, name, value ) end )
			end
			return container
		end
	}

	local function buildConfiguration( parent )
		local scroll = vgui.Create( "DScrollPanel", parent )
		scroll:Dock( FILL )
		local categories = {}
		local orderedKeys = {}
		for key, _ in pairs( lia.config.stored ) do
			table.insert( orderedKeys, key )
		end

		table.sort( orderedKeys, function( a, b ) return lia.config.stored[ a ].name < lia.config.stored[ b ].name end )
		for _, key in ipairs( orderedKeys ) do
			local option = lia.config.stored[ key ]
			local elemType = option.data and option.data.type or "Generic"
			local catName = option.category or "Miscellaneous"
			categories[ catName ] = categories[ catName ] or {}
			table.insert( categories[ catName ], {
				key = key,
				name = option.name,
				config = option,
				elemType = elemType
			} )
		end

		for catName, configItems in SortedPairs( categories ) do
			local catPanel = vgui.Create( "DCollapsibleCategory", scroll )
			catPanel:Dock( TOP )
			catPanel:SetLabel( catName )
			catPanel:SetExpanded( true )
			catPanel:DockMargin( 0, 0, 0, 10 )
			catPanel.Header:SetContentAlignment( 5 )
			catPanel.Header:SetTall( 30 )
			catPanel.Header:SetFont( "liaMediumFont" )
			catPanel.Header:SetTextColor( Color( 255, 255, 255 ) )
			catPanel.Header.Paint = function( _, w, h )
				draw.RoundedBox( 0, 0, 0, w, h, Color( 20, 20, 20, 200 ) )
				surface.SetDrawColor( 255, 255, 255, 80 )
				surface.DrawOutlinedRect( 0, 0, w, h )
			end

			catPanel.Paint = function( _, w, h ) draw.RoundedBox( 0, 0, 0, w, h, Color( 40, 40, 40, 60 ) ) end
			local bodyPanel = vgui.Create( "DPanel", catPanel )
			bodyPanel:SetTall( #configItems * 240 )
			bodyPanel.Paint = function( _, w, h ) draw.RoundedBox( 0, 0, 0, w, h, Color( 20, 20, 20, 50 ) ) end
			catPanel:SetContents( bodyPanel )
			for _, itemData in ipairs( configItems ) do
				local panelElement = ConfigFormatting[ itemData.elemType ]( itemData.key, itemData.name, itemData.config, bodyPanel )
				panelElement:Dock( TOP )
				panelElement:DockMargin( 10, 10, 10, 0 )
				panelElement.Paint = function( _, w, h )
					draw.RoundedBox( 4, 0, 0, w, h, Color( 0, 0, 0, 200 ) )
					surface.SetDrawColor( 255, 255, 255 )
					surface.DrawOutlinedRect( 0, 0, w, h )
				end
			end
		end
	end

	if client:hasPrivilege( "Staff Permissions - Access Configuration Menu" ) then
		table.insert( pages, {
			name = "Configuration",
			drawFunc = function( parent )
				parent:Clear()
				buildConfiguration( parent )
			end
		} )
	end
end )
