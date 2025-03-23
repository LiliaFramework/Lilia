function SS( value, isWidth )
	local screenWidth, screenHeight = ScrW(), ScrH()
	local widthRatio = screenWidth / 1920
	local heightRatio = screenHeight / 1080
	return isWidth and value * widthRatio or value * heightRatio
end

function sW( width )
	if width then
		return width * ScrW() / 1920
	else
		return 1920
	end
end

function sH( height )
	if height then
		return height * ScrH() / 1080
	else
		return 1080
	end
end

function C( value, isWidth )
	return SS( value, isWidth )
end
