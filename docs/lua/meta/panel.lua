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
        -- This creates a simple frame positioned using screen scaling
        local frame = vgui.Create("DFrame")
        frame:SetSize(200, 100)
        frame:SetPos(25, 25)
        frame:SetTitle("Scaled Frame")
        frame:MakePopup()
]]
--[[
    HTTPS URL Handling

    Description:
        The library extends Garry's Mod's `Material()` and `DImage:SetImage()`
        functions so they accept direct HTTP or HTTPS image URLs. The image is
        automatically downloaded via `lia.webimage.register` and cached before
        the material is returned or applied.

    Example Usage:
        -- Load a material directly from the web
        local mat = Material("https://example.com/icon.png")

        -- Apply a remote image to a button
        button:SetImage("https://example.com/icon.png")
]]