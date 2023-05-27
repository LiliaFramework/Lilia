local PANEL = {}

function PANEL:Init()
	local groups = {}

	self:SetSize(ScrW() / 1.5, ScrH() / 1.5)
	self:Center()
	self:MakePopup()
	self:SetTitle("Bodygroup Menu")
	
	local x, y = self:GetSize()
	
	-- Left side
	
	self.modelpanel = vgui.Create("DPanel", self)
	self.modelpanel:SetSize(x / 2, 0)
	self.modelpanel:Dock(LEFT)
	
	self.model = vgui.Create("DModelPanel", self.modelpanel)
	self.model:Dock(FILL)
	self.model:SetModel(LocalPlayer():GetModel())
	for k, v in ipairs(LocalPlayer():GetBodyGroups()) do
		self.model.Entity:SetBodygroup(v.id, LocalPlayer():GetBodygroup(v.id))
	end
	self.model.Entity:SetSkin(LocalPlayer():GetSkin() or 0)
	function self.model:LayoutEntity( ent ) 
		return
	end
	
	self.modelrotateslider = vgui.Create("DNumSlider", self.modelpanel)
	self.modelrotateslider:Dock(BOTTOM)
	self.modelrotateslider:DockMargin(10,0,0,0)
	self.modelrotateslider:SetText( "Rotation" )
	self.modelrotateslider:SetMin( 0 )
	self.modelrotateslider:SetMax( 360 )
	self.modelrotateslider:SetValue(0)
	self.modelrotateslider:SetDecimals( 0 )
	self.modelrotateslider.OnValueChanged = function( uh, value )
		self.model.Entity:SetAngles(Angle(0, value, 0))
	end
	
	-- Right side -- uhhh dont question why the panels below are called "left..." while deving i somehow managed to mess up left and right and just labeled it left lol
	
	self.leftpanel = vgui.Create("DPanel", self)
	self.leftpanel:Dock(FILL)
	self.leftpanel:DockMargin(5, 0, 0, 0)
	
	self.leftscroll = vgui.Create("DScrollPanel", self.leftpanel)
	self.leftscroll:Dock(FILL)
	
	local skincount = LocalPlayer():SkinCount()
	
	if skincount > 1 then
		self.modelskinlabel = self.leftscroll:Add("DLabel")
		self.modelskinlabel:Dock(TOP)
		self.modelskinlabel:DockMargin(10,5,10,0)
		self.modelskinlabel:SetText( "Skins" )

		self.modelskinslider = self.leftscroll:Add("DNumSlider")
		self.modelskinslider:Dock(TOP)
		self.modelskinslider:DockMargin(10,0,10,0)
		self.modelskinslider:SetText( "Skin" )
		self.modelskinslider:SetMin( 0 )
		self.modelskinslider:SetMax( skincount - 1 )
		self.modelskinslider:SetValue(LocalPlayer():GetSkin())
		self.modelskinslider:SetDecimals( 0 )
		self.modelskinslider.OnValueChanged = function( uh, value )
			self.model.Entity:SetSkin(value)
		end
	end

	if LocalPlayer():GetNumBodyGroups() > 1 then
		self.modelbodygrouplabel = self.leftscroll:Add("DLabel")
		self.modelbodygrouplabel:Dock(TOP)
		self.modelbodygrouplabel:DockMargin(10,5,10,0)
		self.modelbodygrouplabel:SetText( "Bodygroups" )
		for k, v in ipairs(LocalPlayer():GetBodyGroups()) do
			if v.num != 1 then
				local button = self.leftscroll:Add("DNumSlider")
				button:Dock(TOP)
				button:DockMargin(10,0,10,0)
				button:SetText(v.name)
				button:SetMin(0)
				button:SetMax(v.num - 1)
				button:SetDecimals( 0 )
				button:SetValue(LocalPlayer():GetBodygroup(v.id))
				button.OnValueChanged = function(uh, value)
					self.model.Entity:SetBodygroup(v.id, value)
					groups[v.id] = math.Round(value, 0)
				end
			end
		end
	end
	
	local h, s, v = ColorToHSV( lia.config.get("color") )
	s = s - 0.25
	local finaloutlinecolor = HSVToColor(h,s,v)
	-- this seemed like an easier way to darken the config color lol. probs not but  hey
	
	self.finishbutton = vgui.Create("DButton", self.leftpanel)
	self.finishbutton:Dock(BOTTOM)
	self.finishbutton:DockMargin(5,5,5,5)
	self.finishbutton:SetSize(0, 40)
	self.finishbutton:SetText("Submit Changes")
	self.finishbutton.Paint = function(panel, w, h)
		draw.RoundedBox(0, 0, 0, w, h, lia.config.get("color"))
		surface.SetDrawColor(finaloutlinecolor)
		surface.DrawOutlinedRect(0, 0, w, h, 1)
	end
	self.finishbutton.DoClick = function()
		local data = {}
		data.skin = self.model.Entity:GetSkin()
		data.groups = groups
		netstream.Start("lia_bodygroupclosetapplychanges", data)
		self:Remove()
	end
end

function PANEL:OnRemove()
	netstream.Start("onlia_bodygroupclosetclose") -- not optimal as we dont have a reference to the entity but yea
end

vgui.Register("lia_bodygroupcloset", PANEL, "DFrame")