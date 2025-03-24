local PANEL = {}
function PANEL:configureSteps()
	self:addStep( vgui.Create( "liaCharacterFaction" ) )
	self:addStep( vgui.Create( "liaCharacterBiography" ) )
	hook.Run( "ConfigureCharacterCreationSteps", self )
	local stepKeys = table.GetKeys( self.steps )
	table.sort( stepKeys, function( a, b ) return a < b end )
	local stepsCopy = table.Copy( self.steps )
	self.steps = {}
	for newKey, oldKey in pairs( stepKeys ) do
		self.steps[ newKey ] = stepsCopy[ oldKey ]
	end
end

function PANEL:updateModel()
	local faction = lia.faction.indices[ self.context.faction ]
	assert( faction, "invalid faction when updating model" )
	local modelInfo = faction.models[ self.context.model or 1 ]
	assert( modelInfo, "faction " .. faction.name .. " has no models!" )
	local model, skin, groups
	if istable( modelInfo ) then
		model, skin, groups = unpack( modelInfo )
	else
		model, skin, groups = modelInfo, 0, {}
	end

	self.model:SetModel( model )
	local entity = self.model:GetEntity()
	if not IsValid( entity ) then return end
	entity:SetSkin( skin )
	if istable( groups ) then
		for group, value in pairs( groups ) do
			entity:SetBodygroup( group, value )
		end
	elseif isstring( groups ) then
		entity:SetBodyGroups( groups )
	end

	if self.context.skin then entity:SetSkin( self.context.skin ) end
	if self.context.groups then
		for group, value in pairs( self.context.groups or {} ) do
			entity:SetBodygroup( group, value )
		end
	end
end

function PANEL:canCreateCharacter()
	local validFactions = {}
	for _, v in pairs( lia.faction.teams ) do
		if lia.faction.hasWhitelist( v.index ) then validFactions[ #validFactions + 1 ] = v.index end
	end

	if #validFactions == 0 then return false, "You are unable to join any factions" end
	self.validFactions = validFactions
	local maxChars = hook.Run( "GetMaxPlayerChar", LocalPlayer() ) or lia.config.get( "MaxCharacters", 5 )
	if lia.characters and #lia.characters >= maxChars then return false, "You have reached the maximum number of characters" end
	local canCreate, reason = hook.Run( "ShouldMenuButtonShow", "create" )
	if canCreate == false then return false, reason end
	return true
end

function PANEL:onFinish()
	if self.creating then return end
	self.content:SetVisible( false )
	self.buttons:SetVisible( false )
	self:showMessage( "creating" )
	self.creating = true
	local function onResponse()
		timer.Remove( "liaFailedToCreate" )
		if not IsValid( self ) then return end
		self.creating = false
		self.content:SetVisible( true )
		self.buttons:SetVisible( true )
		self:showMessage()
	end

	local function onFail( err )
		onResponse()
		self:showError( err )
	end

	MainMenu:createCharacter( self.context ):next( function()
		onResponse()
		if IsValid( lia.gui.character ) then lia.gui.character:showContent() end
	end, onFail )

	timer.Create( "liaFailedToCreate", 60, 1, function()
		if not IsValid( self ) or not self.creating then return end
		onFail( "unknownError" )
	end )
end

function PANEL:showError( message, ... )
	if IsValid( self.error ) then self.error:Remove() end
	if not message or message == "" then return end
	message = L( message, ... )
	assert( IsValid( self.content ), "no step is available" )
	self.error = self.content:Add( "DLabel" )
	self.error:SetFont( "liaCharSubTitleFont" )
	self.error:SetText( message )
	self.error:SetTextColor( color_white )
	self.error:Dock( TOP )
	self.error:SetTall( 32 )
	self.error:DockMargin( 0, 0, 0, 8 )
	self.error:SetContentAlignment( 5 )
	self.error.Paint = function( box, w, h )
		lia.util.drawBlur( box )
		surface.SetDrawColor( 255, 0, 0, 50 )
		surface.DrawRect( 0, 0, w, h )
	end

	self.error:SetAlpha( 0 )
	self.error:AlphaTo( 255, lia.gui.character.ANIM_SPEED )
	lia.gui.character:warningSound()
end

function PANEL:showMessage( message, ... )
	if not message or message == "" then
		if IsValid( self.message ) then self.message:Remove() end
		return
	end

	message = L( message, ... ):upper()
	if IsValid( self.message ) then self.message:SetText( message ) end
	self.message = self:Add( "DLabel" )
	self.message:SetFont( "liaCharButtonFont" )
	self.message:SetTextColor( lia.gui.character.color )
	self.message:Dock( FILL )
	self.message:SetContentAlignment( 5 )
	self.message:SetText( message )
end

function PANEL:addStep( step, priority )
	assert( IsValid( step ), "Invalid panel for step" )
	assert( step.isCharCreateStep, "Panel must inherit liaCharacterCreateStep" )
	if isnumber( priority ) then
		table.insert( self.steps, priority, step )
	else
		self.steps[ #self.steps + 1 ] = step
	end

	step:SetParent( self.content )
end

function PANEL:nextStep()
	local lastStep = self.curStep
	local curStep = self.steps[ lastStep ]
	if IsValid( curStep ) then
		local res = { curStep:validate() }
		if res[ 1 ] == false then return self:showError( unpack( res, 2 ) ) end
	end

	self:showError()
	self.curStep = self.curStep + 1
	local nextStep = self.steps[ self.curStep ]
	while IsValid( nextStep ) and nextStep:shouldSkip() do
		self.curStep = self.curStep + 1
		nextStep:onSkip()
		nextStep = self.steps[ self.curStep ]
	end

	if not IsValid( nextStep ) then
		self.curStep = lastStep
		return self:onFinish()
	end

	self:onStepChanged( curStep, nextStep )
end

function PANEL:previousStep()
	local curStep = self.steps[ self.curStep ]
	local newStep = self.curStep - 1
	local prevStep = self.steps[ newStep ]
	while IsValid( prevStep ) and prevStep:shouldSkip() do
		prevStep:onSkip()
		newStep = newStep - 1
		prevStep = self.steps[ newStep ]
	end

	if not IsValid( prevStep ) then return end
	self.curStep = newStep
	self:onStepChanged( curStep, prevStep )
end

function PANEL:getPreviousStep()
	local step = self.curStep - 1
	while IsValid( self.steps[ step ] ) do
		if not self.steps[ step ]:shouldSkip() then
			hasPrevStep = true
			break
		end

		step = step - 1
	end
	return self.steps[ step ]
end

function PANEL:onStepChanged( oldStep, newStep )
	local ANIM_SPEED = lia.gui.character.ANIM_SPEED
	local shouldFinish = self.curStep == #self.steps
	local nextStepText = L( shouldFinish and "finish" or "next" ):upper()
	local shouldSwitchNextText = nextStepText ~= self.next:GetText()
	if IsValid( self:getPreviousStep() ) then
		self.prev:AlphaTo( 255, ANIM_SPEED )
	else
		self.prev:AlphaTo( 0, ANIM_SPEED )
	end

	if shouldSwitchNextText then self.next:AlphaTo( 0, ANIM_SPEED ) end
	local function showNewStep()
		newStep:SetAlpha( 0 )
		newStep:SetVisible( true )
		newStep:onDisplay()
		newStep:InvalidateChildren( true )
		newStep:AlphaTo( 255, ANIM_SPEED )
		if shouldSwitchNextText then
			self.next:SetAlpha( 0 )
			self.next:SetText( nextStepText )
			self.next:SizeToContentsX()
		end

		self.next:AlphaTo( 255, ANIM_SPEED )
	end

	if IsValid( oldStep ) then
		oldStep:AlphaTo( 0, ANIM_SPEED, 0, function()
			self:showError()
			oldStep:SetVisible( false )
			oldStep:onHide()
			showNewStep()
		end )
	else
		showNewStep()
	end
end

function PANEL:Init()
	self:Dock( FILL )
	local canCreate, reason = self:canCreateCharacter()
	if not canCreate then return self:showMessage( reason ) end
	lia.gui.charCreate = self
	local sideMargin = 0
	if ScrW() > 1280 then
		sideMargin = ScrW() * 0.15
	elseif ScrW() > 720 then
		sideMargin = ScrW() * 0.075
	end

	self.content = self:Add( "DPanel" )
	self.content:Dock( FILL )
	self.content:DockMargin( sideMargin, 64, sideMargin, 0 )
	self.content:SetPaintBackground( false )
	self.model = self.content:Add( "liaModelPanel" )
	self.model:SetWide( ScrW() * 0.25 )
	self.model:Dock( LEFT )
	self.model:SetModel( "models/error.mdl" )
	self.model.oldSetModel = self.model.SetModel
	self.model.SetModel = function( model, ... )
		model:oldSetModel( ... )
		model:fitFOV()
	end

	self.buttons = self:Add( "DPanel" )
	self.buttons:Dock( BOTTOM )
	self.buttons:SetTall( 48 )
	self.buttons:SetPaintBackground( false )
	self.prev = self.buttons:Add( "liaCharacterTabButton" )
	self.prev:SetText( L( "back" ):upper() )
	self.prev:Dock( LEFT )
	self.prev:SizeToContents()
	self.prev.DoClick = function() self:previousStep() end
	self.prev:SetAlpha( 0 )
	self.next = self.buttons:Add( "liaCharacterTabButton" )
	self.next:SetText( L( "next" ):upper() )
	self.next:Dock( RIGHT )
	self.next:SizeToContents()
	self.next.DoClick = function() self:nextStep() end
	self.steps = {}
	self.curStep = 0
	self.context = {}
	self:configureSteps()
	if #self.steps == 0 then return self:showError( "No character creation steps have been set up" ) end
	self:nextStep()
end

vgui.Register( "liaCharacterCreation", PANEL, "EditablePanel" )