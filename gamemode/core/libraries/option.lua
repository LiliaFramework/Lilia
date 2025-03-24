lia.option = lia.option or {}
lia.option.stored = lia.option.stored or {}
function lia.option.add( key, name, desc, default, callback, data )
	assert( isstring( key ), "Expected option key to be a string, got " .. type( key ) )
	assert( isstring( name ), "Expected option name to be a string, got " .. type( name ) )
	assert( istable( data ), "Expected option data to be a table, got " .. type( data ) )
	local t = type( default )
	local optionType = t == "boolean" and "Boolean" or t == "number" and ( math.floor( default ) == default and "Int" or "Float" ) or t == "table" and default.r and default.g and default.b and "Color" or "Generic"
	if optionType == "Int" or optionType == "Float" then
		data.min = data.min or optionType == "Int" and math.floor( default / 2 ) or default / 2
		data.max = data.max or optionType == "Int" and math.floor( default * 2 ) or default * 2
	end

	local oldOption = lia.option.stored[ key ]
	local savedValue = oldOption and oldOption.value or default
	lia.option.stored[ key ] = {
		name = name,
		desc = desc,
		data = data,
		value = savedValue,
		default = default,
		callback = callback,
		type = optionType,
	}
end

lia.option.add( "BarPositions", "BarPositions", "Bottom Left", nil, {
	desc = "Determines the position of the Lilia bars.",
	category = "General",
	type = "Table",
	options = { "Top Right", "Top Left", "Bottom Right", "Bottom Left" }
} )

function lia.option.set( key, value )
	local option = lia.option.stored[ key ]
	if option then
		local oldValue = option.value
		option.value = value
		if option.callback then option.callback( oldValue, value ) end
		lia.option.save()
	end
end

function lia.option.get( key, default )
	local option = lia.option.stored[ key ]
	if option then
		if option.value ~= nil then
			return option.value
		elseif option.default ~= nil then
			return option.default
		end
	end
	return default
end

function lia.option.save()
	local dirPath = "lilia/options/" .. engine.ActiveGamemode()
	file.CreateDir( dirPath )
	local ipWithoutPort = string.Explode( ":", game.GetIPAddress() )[ 1 ]
	local formattedIP = ipWithoutPort:gsub( "%.", "_" )
	local saveLocation = dirPath .. "/" .. formattedIP .. ".txt"
	local data = {}
	for k, v in pairs( lia.option.stored ) do
		if v and v.value ~= nil then data[ k ] = v.value end
	end

	local jsonData = util.TableToJSON( data, true )
	if jsonData then file.Write( saveLocation, jsonData ) end
end

function lia.option.load()
	local dirPath = "lilia/options/" .. engine.ActiveGamemode()
	file.CreateDir( dirPath )
	local ipWithoutPort = string.Explode( ":", game.GetIPAddress() )[ 1 ]
	local formattedIP = ipWithoutPort:gsub( "%.", "_" )
	local loadLocation = dirPath .. "/" .. formattedIP .. ".txt"
	local data = file.Read( loadLocation, "DATA" )
	if data then
		local savedOptions = util.JSONToTable( data )
		for k, v in pairs( savedOptions ) do
			if lia.option.stored[ k ] then lia.option.stored[ k ].value = v end
		end
	end

	hook.Run( "InitializedOptions" )
end

hook.Add( "PopulateConfigurationTabs", "PopulateOptions", function( pages )
	local OptionFormatting = {
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
			slider:SetValue( lia.option.get( key, config.value ) )
			slider.PerformLayout = function()
				slider.Label:SetWide( 100 )
				slider.TextArea:SetWide( 50 )
			end

			slider.OnValueChanged = function( _, newValue ) timer.Create( "ConfigChange" .. name, 1, 1, function() lia.option.set( key, math.floor( newValue ) ) end ) end
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
			slider:SetValue( lia.option.get( key, config.value ) )
			slider.PerformLayout = function()
				slider.Label:SetWide( 100 )
				slider.TextArea:SetWide( 50 )
			end

			slider.OnValueChanged = function( _, newValue ) timer.Create( "ConfigChange" .. name, 1, 1, function() lia.option.set( key, math.Round( newValue, 2 ) ) end ) end
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
			entry:SetText( tostring( lia.option.get( key, config.value ) ) )
			entry:SetFont( "ConfigFontLarge" )
			entry:SetTextColor( Color( 255, 255, 255 ) )
			entry.OnEnter = function( btn )
				local newValue = btn:GetText()
				lia.option.set( key, newValue )
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
			button.Paint = function( _, w, h )
				local check = getIcon( "0xe880", true )
				local uncheck = getIcon( "0xf096", true )
				local icon = lia.option.get( key, config.value ) and check or uncheck
				lia.util.drawText( icon, w / 2, h / 2 - 10, color_white, 1, 1, "liaIconsHugeNew" )
			end

			button.DoClick = function() lia.option.set( key, not lia.option.get( key, config.value ) ) end
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
				local colorValue = lia.option.get( key, config.value )
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
				colorMixer:SetColor( lia.option.get( key, config.value ) )
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
					timer.Create( "ConfigChange" .. name, 1, 1, function() lia.option.set( key, pickerFrame.curColor ) end )
					pickerFrame:Remove()
				end

				colorMixer.ValueChanged = function( _, value ) pickerFrame.curColor = value end
				button.picker = pickerFrame
			end
			return container
		end,
		Table = function( key, name, config, parent )
			local container = vgui.Create( "DPanel", parent )
			container:SetTall( 300 )
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
			local listView = panel:Add( "DListView" )
			listView:Dock( FILL )
			listView:SetMultiSelect( false )
			listView:AddColumn( "Items" )
			for _, item in ipairs( lia.option.get( key, config.value ) or {} ) do
				listView:AddLine( tostring( item ) )
			end

			local addButton = panel:Add( "DButton" )
			addButton:Dock( BOTTOM )
			addButton:SetTall( 30 )
			addButton:SetText( "Add Item" )
			addButton.DoClick = function()
				Derma_StringRequest( "Add Item", "Enter new item:", "", function( text )
					if text and text ~= "" then
						local current = lia.option.get( key, config.value ) or {}
						table.insert( current, text )
						lia.option.set( key, current )
						listView:AddLine( text )
					end
				end )
			end

			local removeButton = panel:Add( "DButton" )
			removeButton:Dock( BOTTOM )
			removeButton:SetTall( 30 )
			removeButton:SetText( "Remove Selected" )
			removeButton.DoClick = function()
				local selected = listView:GetSelected()
				if #selected > 0 then
					local line = selected[ 1 ]
					local index = listView:Line( line ):GetID()
					local current = lia.option.get( key, config.value ) or {}
					table.remove( current, index )
					lia.option.set( key, current )
					listView:RemoveLine( index )
				end
			end
			return container
		end
	}

	local function buildOptions( parent )
		local scroll = vgui.Create( "DScrollPanel", parent )
		scroll:Dock( FILL )
		local categories = {}
		local orderedKeys = {}
		for key, _ in pairs( lia.option.stored ) do
			table.insert( orderedKeys, key )
		end

		table.sort( orderedKeys, function( a, b ) return lia.option.stored[ a ].name < lia.option.stored[ b ].name end )
		for _, key in ipairs( orderedKeys ) do
			local option = lia.option.stored[ key ]
			local elementType = option.type or "Generic"
			local catName = option.data and option.data.category or "Miscellaneous"
			categories[ catName ] = categories[ catName ] or {}
			table.insert( categories[ catName ], {
				key = key,
				name = option.name,
				config = option,
				elemType = elementType
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
				local panelConstructor = OptionFormatting[ itemData.elemType ] or OptionFormatting.Generic
				local panelElement = panelConstructor( itemData.key, itemData.name, itemData.config, bodyPanel )
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

	table.insert( pages, {
		name = "Options",
		drawFunc = function( parent )
			parent:Clear()
			buildOptions( parent )
		end
	} )
end )