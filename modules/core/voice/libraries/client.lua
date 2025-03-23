local MODULE = MODULE or {}
local color_white = Color( 255, 255, 255 )
local color_transparent = Color( 0, 0, 0, 0 )
VoicePanels = {}
local PANEL = {}
function PANEL:Init()
	local hi = vgui.Create( "DLabel", self )
	hi:SetFont( "liaIconsMedium" )
	hi:Dock( LEFT )
	hi:DockMargin( 8, 0, 8, 0 )
	hi:SetTextColor( color_white )
	hi:SetText( "i" )
	hi:SetWide( 30 )
	self.LabelName = vgui.Create( "DLabel", self )
	self.LabelName:SetFont( "liaMediumFont" )
	self.LabelName:Dock( FILL )
	self.LabelName:DockMargin( 0, 0, 0, 0 )
	self.LabelName:SetTextColor( color_white )
	self.Color = color_transparent
	self:SetSize( 280, 32 + 8 )
	self:DockPadding( 4, 4, 4, 4 )
	self:DockMargin( 2, 2, 2, 2 )
	self:Dock( BOTTOM )
end

function PANEL:Setup( client )
	self.client = client
	self.name = hook.Run( "ShouldAllowScoreboardOverride", client, "name" ) and hook.Run( "GetDisplayedName", client ) or client:Nick()
	self.LabelName:SetText( self.name )
	self:InvalidateLayout()
end

function PANEL:Paint( w, h )
	if not IsValid( self.client ) then return end
	lia.util.drawBlur( self, 1, 2 )
	surface.SetDrawColor( 0, 0, 0, 50 + self.client:VoiceVolume() * 50 )
	surface.DrawRect( 0, 0, w, h )
	surface.SetDrawColor( 255, 255, 255, 50 + self.client:VoiceVolume() * 120 )
	surface.DrawOutlinedRect( 0, 0, w, h )
end

function PANEL:Think()
	if IsValid( self.client ) then self.LabelName:SetText( self.name ) end
	if self.fadeAnim then self.fadeAnim:Run() end
end

function PANEL:FadeOut( anim, delta )
	if anim.Finished then
		if IsValid( VoicePanels[ self.client ] ) then
			VoicePanels[ self.client ]:Remove()
			VoicePanels[ self.client ] = nil
			return
		end
		return
	end

	self:SetAlpha( 255 - 255 * delta * 2 )
end

vgui.Register( "VoicePanel", PANEL, "DPanel" )
function MODULE:InitPostEntity()
	if IsValid( g_VoicePanelList ) then g_VoicePanelList:Remove() end
	for _, pnl in pairs( VoicePanels ) do
		if IsValid( pnl ) then pnl:Remove() end
	end

	g_VoicePanelList = vgui.Create( "DPanel" )
	g_VoicePanelList:ParentToHUD()
	g_VoicePanelList:SetSize( 270, ScrH() - 200 )
	g_VoicePanelList:SetPos( ScrW() - 320, 100 )
	g_VoicePanelList:SetPaintBackground( false )
end

function MODULE:OnReloaded()
	if IsValid( g_VoicePanelList ) then g_VoicePanelList:Remove() end
	for _, pnl in pairs( VoicePanels ) do
		if IsValid( pnl ) then pnl:Remove() end
	end

	g_VoicePanelList = vgui.Create( "DPanel" )
	g_VoicePanelList:ParentToHUD()
	g_VoicePanelList:SetSize( 270, ScrH() - 200 )
	g_VoicePanelList:SetPos( ScrW() - 320, 100 )
	g_VoicePanelList:SetPaintBackground( false )
end

function MODULE:PlayerButtonDown( client, button )
	if button == KEY_F2 and IsFirstTimePredicted() then
		local trace = client:GetEyeTrace()
		if IsValid( trace.Entity ) and trace.Entity.isDoor and trace.Entity:isDoor() then return end
		local menu = DermaMenu()
		menu:AddOption( L( "changeToWhisper" ), function()
			net.Start( "ChangeSpeakMode" )
			net.WriteString( "Whispering" )
			net.SendToServer()
			client:ChatPrint( L( "voiceModeWhisper" ) )
		end )

		menu:AddOption( L( "changeToTalk" ), function()
			net.Start( "ChangeSpeakMode" )
			net.WriteString( "Talking" )
			net.SendToServer()
			client:ChatPrint( L( "voiceModeTalk" ) )
		end )

		menu:AddOption( L( "changeToYell" ), function()
			net.Start( "ChangeSpeakMode" )
			net.WriteString( "Yelling" )
			net.SendToServer()
			client:ChatPrint( L( "voiceModeYell" ) )
		end )

		menu:Open()
		menu:MakePopup()
		menu:Center()
	end
end

local function VoiceClean()
	for k, _ in pairs( VoicePanels ) do
		if not IsValid( k ) then hook.Run( "PlayerEndVoice", k ) end
	end
end

timer.Create( "VoiceClean", 1, 0, VoiceClean )
