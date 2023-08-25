--------------------------------------------------------------------------------------------------------
do
	local scale_factor_x = 1 / 1920
	local scale_factor_y = 1 / 1080
	function math.ScaleH(size)
		return math.floor(size * (ScrH() * scale_factor_y))
	end

	math.Scale = math.ScaleH
	function math.ScaleW(size)
		return math.floor(size * (ScrW() * scale_factor_x))
	end
end
--------------------------------------------------------------------------------------------------------