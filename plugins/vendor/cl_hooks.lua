function PLUGIN:VendorOpened(vendor)
	vgui.Create("liaVendor")
	hook.Run("OnOpenVendorMenu", self) -- mostly for sound or welcome stuffs
end

function PLUGIN:VendorExited()
	if (IsValid(lia.gui.vendor)) then
		lia.gui.vendor:Remove()
	end
end

function PLUGIN:LoadFonts(font)
	surface.CreateFont("liaVendorButtonFont", {
		font = font,
		weight = 200,
		size = 40
	})

	surface.CreateFont("liaVendorSmallFont", {
		font = font,
		weight = 500,
		size = 22
	})

	surface.CreateFont("liaVendorLightFont", {
		font = font,
		weight = 200,
		size = 22
	})
end
