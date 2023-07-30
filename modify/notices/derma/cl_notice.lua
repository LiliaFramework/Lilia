local PANEL = {}
	local gradient = lia.util.getMaterial("vgui/gradient-d")

	function PANEL:Init()
		self:SetSize(256, 36)
		self:SetContentAlignment(5)
		self:SetExpensiveShadow(1, Color(0, 0, 0, 150))
		self:SetFont("liaNoticeFont")
		self:SetTextColor(color_white)
		self:SetDrawOnTop(true)
	end

	function PANEL:Paint(w, h)
		lia.util.drawBlur(self, 3, 2)

		surface.SetDrawColor(230, 230, 230, 10)
		surface.DrawRect(0, 0, w, h)

		if (self.start) then
			local w2 = math.TimeFraction(self.start, self.endTime, CurTime()) * w

			surface.SetDrawColor(lia.config.get("color"))
			surface.DrawRect(w2, 0, w - w2, h)
		end

		surface.SetDrawColor(0, 0, 0, 25)
		surface.DrawOutlinedRect(0, 0, w, h)
	end
vgui.Register("liaNotice", PANEL, "DLabel")
