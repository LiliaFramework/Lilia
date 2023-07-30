AFKKick = AFKKick or {}
AFKKick.Config = AFKKick.Config or {}

function AFKKick.DrawWarning()
	if AFKKick.Alpha < 230 then
		AFKKick.Alpha = AFKKick.Alpha + (FrameTime() * 200)
	end

	draw.RoundedBox(0, 0, (ScrH() / 2) - ScreenScale(60), ScrW(), ScreenScale(120), Color(0, 0, 0, AFKKick.Alpha))
	draw.DrawText(AFKKick.Config.WarningHead, "AFKKick120", ScrW() * 0.5, (ScrH() * 0.5) - ScreenScale(50), Color(255, 0, 0, AFKKick.Alpha), TEXT_ALIGN_CENTER)
	draw.DrawText(AFKKick.Config.WarningSub .. "\nYou will be kicked in " .. math.floor(math.max(AFKKick.Config.KickTime - (CurTime() - AFKKick.WarningStart), 0)) .. "s", "AFKKick25", ScrW() * 0.5, ScrH() * 0.5, Color(255, 255, 255, AFKKick.Alpha), TEXT_ALIGN_CENTER)
end

function AFKKick.EnableWarning()
	AFKKick.Alpha = 0
	AFKKick.WarningStart = CurTime()
	surface.PlaySound("HL1/fvox/bell.wav")
	hook.Add("HUDPaint", "AFKWarning", AFKKick.DrawWarning)
end

function AFKKick.DisableWarning()
	AFKKick.Alpha = nil
	AFKKick.AlphaRising = nil
	hook.Remove("HUDPaint", "AFKWarning")
end