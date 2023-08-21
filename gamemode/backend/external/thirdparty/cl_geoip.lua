--------------------------------------------------------------------------------------------------------
lia.geoip = lia.geoip or {}
lia.geoip.cache = lia.geoip.cache or {}

--------------------------------------------------------------------------------------------------------
hook.Add("CharacterLoaded", "GeoIP", function()
	for _, v in ipairs(player.GetHumans()) do
		if IsValid(v) then
			lia.geoip:GetMaterial(v)
		end
	end
end)

--------------------------------------------------------------------------------------------------------
function lia.geoip:GetMaterial(client, pngParameters)
	if not IsValid(client) then return false end
	local id = client:SteamID64()
	if self.cache[id] then return self.cache[id] end
	id = client:getNetVar("country_code")
	if not id then return false end

	if pngParameters == false then
		self.cache[id] = Material("flags16/" .. id .. ".png")
	else
		self.cache[id] = Material("flags16/" .. id .. ".png", pngParameters or "noclamp smooth")
	end

	return self.cache[id]
end
--------------------------------------------------------------------------------------------------------