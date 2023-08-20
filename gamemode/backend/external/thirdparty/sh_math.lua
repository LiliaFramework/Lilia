if (CLIENT) then
	do
		local scale_factor_x = 1 / 1920
		local scale_factor_y = 1 / 1080

		-- y
		function math.ScaleH(size)
			return math.floor(size * (ScrH() * scale_factor_y))
		end

		math.Scale = math.ScaleH

		-- x
		function math.ScaleW(size)
			return math.floor(size * (ScrW() * scale_factor_x))
		end
	end
end