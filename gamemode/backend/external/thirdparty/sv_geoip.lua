--------------------------------------------------------------------------------------------------------
lia.geoip = lia.geoip or {}
--------------------------------------------------------------------------------------------------------
lia.geoip.API = "https://freegeoip.app/json/"
lia.geoip.blockedIPs = {
	["loopback"] = true,
	["localhost"] = true,
	["127.0.0.1"] = true,
	["::1"] = true,
	["p2p"] = true
}
--------------------------------------------------------------------------------------------------------
lia.geoip.cache = lia.geoip.cache or {}
--------------------------------------------------------------------------------------------------------
function lia.geoip:Query(ip, callback)
	ip = string.Explode(":", ip)[1]
	if self.blockedIPs[ip] or string.StartWith(ip, "192.168") then return end
	if callback and lia.geoip.cache[ip] then
		callback(lia.geoip.cache[ip])

		return
	end

	http.Fetch(
		self.API .. ip,
		function(body)
			if string.Trim(body) ~= "404 page not found" then
				local data = util.JSONToTable(body)
				if data then
					lia.geoip.cache[ip] = {
						country_name = data.country_name,
						country_code = data.country_code,
					}

					-- region_name = data.region_name,
					-- city = data.city
					if callback then
						callback(lia.geoip.cache[ip])
					end
				end
			end
		end,
		function() end,
		{
			-- error -- headers
			["accept"] = 'application/json',
			["content-type"] = 'application/json'
		}
	)
end
--------------------------------------------------------------------------------------------------------
hook.Add(
	"LoadData",
	"GeoIP",
	function()
		lia.geoip.cache = lia.data.get("geoipcache", {}, true, true)
	end
)
--------------------------------------------------------------------------------------------------------
hook.Add(
	"SaveData",
	"GeoIP",
	function()
		lia.data.set("geoipcache", lia.geoip.cache, true, true)
	end
)
--------------------------------------------------------------------------------------------------------
hook.Add(
	"PlayerLoadedChar",
	"GeoIP",
	function(client, character)
		if client:IsBot() then return end
		if character then
			lia.geoip:Query(
				client:IPAddress(),
				function(data)
					if istable(data) then
						client:setNetVar("country_code", data.country_code:lower())
					end
				end
			)
		end
	end
)
--------------------------------------------------------------------------------------------------------
concommand.Add(
	"lia_flush_geoip",
	function(client)
		if IsValid(client) then return end
		lia.geoip.cache = {}
		lia.data.set("geoipcache", {}, true, true)
		MsgC(Color(50, 200, 50), "geoipcache.txt flushed!\n")
	end
)
--------------------------------------------------------------------------------------------------------