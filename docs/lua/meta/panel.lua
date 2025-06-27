--[[
    Screen-scaling helper wrappers for Panel positioning functions.

    Description:
        These helpers apply ScreenScale and ScreenScaleH to common panel
        positioning and sizing methods so that user interfaces remain
        consistent across different resolutions.

    Parameters:
        None

    Realm:
        Client

    Returns:
        any – Whatever the wrapped Panel function returns.

    Example Usage:
        local frame = vgui.Create("DFrame")
        frame:SetSize(200, 100)
        frame:SetPos(25, 25)
]]
