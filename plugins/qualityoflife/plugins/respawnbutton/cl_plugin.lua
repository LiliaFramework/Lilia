net.Receive("RespawnButtonDeath", function()
	timer.Simple(lia.config.get("spawnTime", 5) + 1, function()
		if not LocalPlayer():Alive() then
			local frame = vgui.Create("DFrame")
			frame:SetTitle("")
			frame:ShowCloseButton(false)
			frame:SetSize(800, 800)
			frame:Center()
			frame.Paint = function() end
			frame:MakePopup()

			frame.Think = function(s)
				if LocalPlayer():Alive() then
					s:Close()
				end
			end

			local bW, bH = 300, 100
			local btn = frame:Add("DButton")
			btn:SetText("Respawn")
			btn:SetPos((frame:GetWide() / 2) - (bW / 2), (frame:GetTall() / 2) - (bH / 2) + 250)
			btn:SetSize(bW, bH)

			btn.Paint = function(s, w, h)
				surface.SetDrawColor(lia.gui.palette.color_primary)
				surface.DrawOutlinedRect(0, 0, w, h)
				surface.SetDrawColor(Color(0, 0, 0, 200))
				surface.DrawRect(1, 1, w - 2, h - 2)
			end

			btn.DoClick = function()
				net.Start("RespawnButtonPress")
				net.SendToServer()
				frame:Close()
			end
		end
	end)
end)