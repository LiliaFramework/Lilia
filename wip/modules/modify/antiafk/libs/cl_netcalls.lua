local MODULE = MODULE or {}

net.Receive("AFKWarning", function()
	local enable = net.ReadBool()

	if enable then
		MODULE.EnableWarning()
	else
		MODULE.DisableWarning()
	end
end)

net.Receive("AFKAnnounce", function()
	local name = net.ReadString()

	if ply == LocalPlayer() then
		local menu = vgui.GetKeyboardFocus()

		if IsValid(menu) and menu.Close then
			menu:Close()
		end
	end

	chat.AddText(Color(255, 0, 0, 255), "Player ", Color(255, 255, 255, 255), name, Color(255, 0, 0, 255), " has been character kicked for being AFK.")
end)