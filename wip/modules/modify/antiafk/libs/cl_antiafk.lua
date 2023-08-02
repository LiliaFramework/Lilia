local MODULE = MODULE

function MODULE.DrawWarning()
	if MODULE.Alpha < 230 then
		MODULE.Alpha = MODULE.Alpha + (FrameTime() * 200)
	end

	draw.RoundedBox(0, 0, (ScrH() / 2) - ScreenScale(60), ScrW(), ScreenScale(120), Color(0, 0, 0, MODULE.Alpha))
	draw.DrawText(lia.config.WarningHead, "MODULE120", ScrW() * 0.5, (ScrH() * 0.5) - ScreenScale(50), Color(255, 0, 0, MODULE.Alpha), TEXT_ALIGN_CENTER)
	draw.DrawText(lia.config.WarningSub .. "\nYou will be kicked in " .. math.floor(math.max(lia.config.KickTime - (CurTime() - MODULE.WarningStart), 0)) .. "s", "MODULE25", ScrW() * 0.5, ScrH() * 0.5, Color(255, 255, 255, MODULE.Alpha), TEXT_ALIGN_CENTER)
end

function MODULE.EnableWarning()
	MODULE.Alpha = 0
	MODULE.WarningStart = CurTime()
	surface.PlaySound("HL1/fvox/bell.wav")
	hook.Add("HUDPaint", "AFKWarning", MODULE.DrawWarning)
end

function MODULE.DisableWarning()
	MODULE.Alpha = nil
	MODULE.AlphaRising = nil
	hook.Remove("HUDPaint", "AFKWarning")
end