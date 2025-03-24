local PANEL = {}
local HIGHLIGHT = Color( 255, 255, 255, 50 )
function PANEL:Init()
	self:SetTall( 600 )
	self:SetWide( 400 )
	local function label( text )
		local lbl = self:Add( "DLabel" )
		lbl:SetFont( "liaMediumFont" )
		lbl:SetText( L( text ):upper() )
		lbl:SizeToContents()
		lbl:Dock( TOP )
		lbl:DockMargin( 0, 0, 0, 4 )
		return lbl
	end

	self.nameLabel = label( "Name" )
	self.name = self:addTextEntry( "name" )
	self.name:SetTall( 32 )
	self.descLabel = label( "Description" )
	self.desc = self:addTextEntry( "desc" )
	self.desc:SetTall( 32 )
	self.modelLabel = label( "Model" )
	local faction = lia.faction.indices[ self:getContext( "faction" ) ]
	if not faction then return end
	local function paintIcon( icon, w, h )
		self:paintIcon( icon, w, h )
	end

	self.models = self:Add( "DIconLayout" )
	self.models:Dock( TOP )
	self.models:SetSpaceX( 5 )
	self.models:SetSpaceY( 0 )
	self.models:DockMargin( 0, 4, 0, 4 )
	self.models:SetSize( self:GetWide(), 50 )
	local iconWidth = 50
	local iconSpacing = 5
	local totalWidth = #faction.models * ( iconWidth + iconSpacing ) - iconSpacing
	self.models:SetWide( totalWidth )
	for k, v in SortedPairs( faction.models ) do
		local icon = self.models:Add( "SpawnIcon" )
		icon:SetSize( 64, 128 )
		icon:InvalidateLayout( true )
		icon.DoClick = function( icon ) self:onModelSelected( icon ) end
		icon.PaintOver = paintIcon
		if isstring( v ) then
			icon:SetModel( v )
			icon.model = v
			icon.skin = 0
			icon.bodyGroups = {}
		elseif istable( v ) then
			local groups = ""
			for i = 0, 9 do
				groups = groups .. ( v[ 3 ][ i ] or 0 )
			end

			if #groups < 9 then
				for _ = 1, 9 - #groups do
					groups = groups .. "0"
				end
			elseif #groups > 9 then
				groups = groups:sub( 1, 9 )
			end

			icon:SetModel( v[ 1 ], v[ 2 ] or 0, groups )
			icon.model = v[ 1 ]
			icon.skin = v[ 2 ] or 0
			icon.bodyGroups = groups
		end

		icon.index = k
		if self:getContext( "model" ) == k then self:onModelSelected( icon, true ) end
	end
end

function PANEL:addTextEntry( contextName )
	local entry = self:Add( "DTextEntry" )
	entry:Dock( TOP )
	entry:SetFont( "liaMediumFont" )
	entry:SetTall( 32 )
	entry.Paint = self.paintTextEntry
	entry:DockMargin( 0, 4, 0, 8 )
	entry:SetUpdateOnType( true )
	entry.contextName = contextName
	entry.OnValueChange = function( _, value ) self:setContext( contextName, string.Trim( value ) ) end
	local savedValue = self:getContext( contextName )
	if savedValue then entry:SetValue( savedValue ) end
	return entry
end

function PANEL:paintIcon( icon, w, h )
	if self:getContext( "model" ) ~= icon.index then return end
	local col = lia.config.get( "Color", color_white )
	surface.SetDrawColor( col.r, col.g, col.b, 200 )
	for i = 1, 3 do
		local i2 = i * 2
		surface.DrawOutlinedRect( i, i, w - i2, h - i2 )
	end
end

function PANEL:onModelSelected( icon, noSound )
	self:setContext( "model", icon.index or 1 )
	if not noSound then lia.gui.character:clickSound() end
	self:updateModelPanel()
end

function PANEL:shouldSkip()
	local faction = lia.faction.indices[ self:getContext( "faction" ) ]
	return faction and #faction.models == 1 or false
end

function PANEL:onSkip()
	self:setContext( "model", 1 )
end

function PANEL:validate()
	local fields = {
		{
			field = self.name,
			name = "Name",
			isTextEntry = true
		},
		{
			field = self.desc,
			name = "Description",
			isTextEntry = true
		}
	}

	for _, fieldInfo in ipairs( fields ) do
		local field = fieldInfo.field
		local fieldName = fieldInfo.name
		local value = field and string.Trim( field:GetValue() or "" )
		if not value or value == "" then return false, "The field '" .. fieldName .. "' is required and cannot be empty." end
	end
	return true
end

function PANEL:paintTextEntry( w, h )
	surface.SetDrawColor( 0, 0, 0, 100 )
	surface.DrawRect( 0, 0, w, h )
	self:DrawTextEntryText( color_white, HIGHLIGHT, HIGHLIGHT )
end

function PANEL:onDisplay()
	local nameText, descText, modelIndex = self.name:GetValue(), self.desc:GetValue(), self:getContext( "model" )
	self:Clear()
	self:Init()
	self.name:SetValue( nameText )
	self.desc:SetValue( descText )
	self:setContext( "model", modelIndex )
	self:onModelSelected( self.models:GetChildren()[ modelIndex ], true )
end

vgui.Register( "liaCharacterBiography", PANEL, "liaCharacterCreateStep" )