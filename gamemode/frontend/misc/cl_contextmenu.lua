function GM:OnContextMenuOpen()
    self.BaseClass:OnContextMenuOpen()
    vgui.Create("liaQuick")
end

function GM:OnContextMenuClose()
    self.BaseClass:OnContextMenuClose()

    if IsValid(lia.gui.quick) then
        lia.gui.quick:Remove()
    end
end