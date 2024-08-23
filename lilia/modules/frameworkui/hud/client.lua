function MODULE:ShouldHideBars()
    if self.BarsDisabled then return false end
end

function MODULE:HUDShouldDraw(element)
    if table.HasValue(self.HiddenHUDElements, element) then return false end
end

function MODULE:HUDPaintBackground()
    if self:ShouldDrawBranchWarning() then self:DrawBranchWarning() end
    if self:ShouldDrawBlur() then self:DrawBlur() end
    self:RenderEntities()
end

function MODULE:HUDPaint()
    local client = LocalPlayer()
    if client:Alive() and client:getChar() then
        local weapon = client:GetActiveWeapon()
        if self:ShouldDrawAmmo(weapon) then self:DrawAmmo(weapon) end
        if self:ShouldDrawCrosshair() then self:DrawCrosshair() end
        if self:ShouldDrawFPS() then self:DrawFPS() end
        if self:ShouldDrawVignette() then self:DrawVignette() end
        if self:ShouldDrawWatermark() then self:DrawWatermark() end
    end
end

function MODULE:LoadFonts()
    surface.CreateFont("WB_Small", {
        font = "Product Sans",
        size = 17
    })

    surface.CreateFont("WB_Medium", {
        font = "Product Sans",
        size = 20
    })

    surface.CreateFont("WB_Large", {
        font = "Product Sans",
        size = 24,
        weight = 800
    })

    surface.CreateFont("WB_XLarge", {
        font = "Product Sans",
        size = 35,
        weight = 800
    })

    surface.CreateFont("WB_Enormous", {
        font = "Product Sans",
        size = 54
    })

    surface.CreateFont("wolficon_enormous", {
        font = "wolficonfont",
        size = 50,
        weight = 400,
        antialias = true
    })

    surface.CreateFont("wolficon_big", {
        font = "wolficonfont",
        size = 34,
        weight = 400,
        antialias = true
    })

    surface.CreateFont("wolficon_normal", {
        font = "wolficonfont",
        size = 25,
        weight = 400,
        antialias = true
    })

    surface.CreateFont("wolficon_small", {
        font = "wolficonfont",
        size = 18,
        weight = 400,
        antialias = true
    })

    surface.CreateFont("FPSFont", {
        font = "mailart rubberstamp",
        size = 27,
        weight = 500,
        antialias = true,
    })
end

function MODULE:ForceDermaSkin()
    return "lilia"
end