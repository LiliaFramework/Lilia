--------------------------------------------------------------------------------------------------------
local w, h = ScrW(), ScrH()
--------------------------------------------------------------------------------------------------------
function MODULE:LoadFonts(font, genericFont)
	surface.CreateFont(
		"DevHudServerName",
		{
			font = "Times New Roman",
			extended = false,
			size = 20 * h / 950,
			weight = 500,
			blursize = 0,
			scanlines = 0,
			antialias = true,
			underline = false,
			italic = false,
			strikeout = false,
			symbol = false,
			rotary = false,
			shadow = false,
			additive = false,
			outline = false,
		}
	)

	surface.CreateFont(
		"DevHudText",
		{
			font = "Times New Roman",
			extended = false,
			size = 20 * h / 1000,
			weight = 500,
			blursize = 0,
			scanlines = 0,
			antialias = true,
			underline = false,
			italic = false,
			strikeout = false,
			symbol = false,
			rotary = false,
			shadow = false,
			additive = false,
			outline = false,
		}
	)
end
--------------------------------------------------------------------------------------------------------