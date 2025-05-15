function MODULE:VendorOpened(vendor)
    local vendorUI = vgui.Create("Vendor")
    vendorUI.vendor = vendor
    hook.Run("OnOpenVendorMenu", self, vendor)
end

function MODULE:VendorExited()
    if IsValid(lia.gui.vendor) then lia.gui.vendor:Remove() end
end
