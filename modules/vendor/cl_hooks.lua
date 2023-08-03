function MODULE:VendorOpened(vendor)
	vgui.Create("liaVendor")
	hook.Run("OnOpenVendorMenu", self) -- mostly for sound or welcome stuffs
end

function MODULE:VendorExited()
	if IsValid(lia.gui.vendor) then
		lia.gui.vendor:Remove()
	end
end