function MODULE:LoadFonts(font)
  surface.CreateFont("VendorButtonFont", {
    font = font,
    weight = 200,
    size = 40
  })

  surface.CreateFont("VendorMediumFont", {
    font = font,
    weight = 500,
    size = 22
  })

  surface.CreateFont("VendorSmallFont", {
    font = font,
    weight = 500,
    size = 22
  })

  surface.CreateFont("VendorTinyFont", {
    font = font,
    weight = 500,
    size = 15
  })

  surface.CreateFont("VendorLightFont", {
    font = font,
    weight = 200,
    size = 22
  })

  surface.CreateFont("VendorItemNameFont", {
    font = "Trajan Pro",
    size = 24,
    weight = 700,
  })

  surface.CreateFont("VendorItemDescFont", {
    font = "Times New Roman",
    size = 18,
    weight = 500,
  })

  surface.CreateFont("VendorItemStatsFont", {
    font = "Consolas",
    size = 16,
    weight = 500,
  })

  surface.CreateFont("VendorItemPriceFont", {
    font = "Arial",
    size = 20,
    weight = 600,
  })

  surface.CreateFont("VendorActionButtonFont", {
    font = "Verdana",
    size = 18,
    weight = 600,
  })
end
