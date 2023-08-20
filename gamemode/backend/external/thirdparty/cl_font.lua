local f = "DermaDefault"
surface.__SetFont = surface.__SetFont or surface.SetFont

function surface.SetFont(font)
	surface.__SetFont(font)
	f = font
end

function surface.GetFont()
	return f
end

local cche = {}

surface.__GetTextSize = surface.__GetTextSize or surface.GetTextSize
function surface.GetTextSize(t)
	if cche[f] and cche[f][t] then
		return cche[f][t][1], cche[f][t][2]
	end
	cche[f] = cche[f] or {}
	local w, h = surface.__GetTextSize(t)
	cche[f][t] = {w, h}
	return w, h
end

surface.__CreateFont = surface.__CreateFont or surface.CreateFont

function surface.CreateFont(font, ...)
	surface.__CreateFont(font, ...)
	cche[font] = nil
end