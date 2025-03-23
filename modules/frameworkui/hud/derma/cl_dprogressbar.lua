local PANEL = {}
function PANEL:Init()
	self.StartTime = CurTime()
	self.EndTime = CurTime() + 5
	self.Text = "Action in progress"
	self.BarColor = lia.config.get( "Color" )
	self.Fraction = 0
end

function PANEL:SetFraction( fraction )
	self.Fraction = fraction or 0
end

function PANEL:SetProgress( startTime, endTime )
	self.StartTime = startTime or CurTime()
	self.EndTime = endTime or CurTime() + 5
end

function PANEL:SetText( text )
	self.Text = text or ""
end

function PANEL:SetBarColor( color )
	self.BarColor = color or self.BarColor
end

function PANEL:Paint( w, h )
	local fraction = math.Clamp( self.Fraction or 0, 0, 1 )
	draw.RoundedBox( 0, 0, 0, w, h, Color( 35, 35, 35, 100 ) )
	surface.SetDrawColor( 0, 0, 0, 120 )
	surface.DrawOutlinedRect( 0, 0, w, h )
	local fillWidth = ( w - 8 ) * fraction
	draw.RoundedBox( 0, 4, 4, fillWidth, h - 8, self.BarColor )
	local gradMat = Material( "vgui/gradient-d" )
	surface.SetMaterial( gradMat )
	surface.SetDrawColor( 200, 200, 200, 20 )
	surface.DrawTexturedRect( 4, 4, fillWidth, h - 8 )
	local centerX = w * 0.5
	local centerY = h * 0.5
	draw.SimpleText( self.Text, "liaSmallFont", centerX, centerY + 2, Color( 20, 20, 20 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	draw.SimpleText( self.Text, "liaSmallFont", centerX, centerY, Color( 240, 240, 240 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
end

vgui.Register( "DProgressBar", PANEL, "DPanel" )
