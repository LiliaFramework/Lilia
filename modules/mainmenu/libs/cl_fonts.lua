local MODULE = MODULE

function MODULE:LoadFonts(font)
    surface.CreateFont("liaCharTitleFont", {
        font = font,
        weight = 200,
        size = self:ScreenScale(70),
        additive = true
    })

    surface.CreateFont("liaCharDescFont", {
        font = font,
        weight = 200,
        size = self:ScreenScale(24),
        additive = true
    })

    surface.CreateFont("liaCharSubTitleFont", {
        font = font,
        weight = 200,
        size = self:ScreenScale(12),
        additive = true
    })

    surface.CreateFont("liaCharButtonFont", {
        font = font,
        weight = 200,
        size = self:ScreenScale(24),
        additive = true
    })

    surface.CreateFont("liaCharSmallButtonFont", {
        font = font,
        weight = 200,
        size = self:ScreenScale(22),
        additive = true
    })
end