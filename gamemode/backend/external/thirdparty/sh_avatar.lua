--------------------------------------------------------------------------------------------------------
lia.steam = lia.steam or {}
--------------------------------------------------------------------------------------------------------
if (CLIENT) then
	file.CreateDir("lilia/avatars")
	lia.steam.avatars = lia.steam.avatars or {}
	lia.steam.users = lia.steam.users or {}

	function lia.steam.GetAvatar(steamID64)
		steamID64 = tostring(steamID64)

		if (lia.steam.avatars[steamID64]) then
			return lia.steam.avatars[steamID64]
		end

		local path = "lilia/avatars/"..steamID64..".png"

		if (file.Exists(path, "DATA")) then
			lia.steam.avatars[steamID64] = Material("../data/" .. path, "noclamp smooth")

			return lia.steam.avatars[steamID64]
		end

		http.Fetch("https://steamcommunity.com/profiles/" .. steamID64 .. "?xml=1", function(content)
			local avatar = content:match("<avatarFull><!%[CDATA%[(.-)%]%]></avatarFull>") or "https://i.imgur.com/ovW4MBM.png"

			http.Fetch(avatar, function(body)
				file.Write(path, body)
				lia.steam.avatars[steamID64] = Material("../data/" .. path, "noclamp smooth")

				return lia.steam.avatars[steamID64]
			end)
		end)

		return false
	end

	function lia.steam.GetNickName(steamID64)
		if (lia.steam.users[steamID64]) then
			return lia.steam.users[steamID64]
		end

		http.Fetch("https://steamcommunity.com/profiles/" .. steamID64 .. "?xml=1", function(content)
			local name = content:match("<steamID><!%[CDATA%[(.-)%]%]></steamID>")

			if (name) then
				lia.steam.users[steamID64] = name
				return name
			end

			return nil
		end)
	end

	hook.Add("CharacterLoaded", "lia.steam.CharacterLoaded", function()
		local id

		for _, v in ipairs(player.GetHumans()) do
			if (IsValid(v)) then
				id = v:SteamID64()

				lia.steam.GetAvatar(id)
				lia.steam.users[id] = v:Name()
			end
		end

		id = nil
	end)

	concommand.Add("flush_avatars", function()
		local root = "lilia/avatars/"

		for _, v in pairs(file.Find(root .. "/*.png", "DATA")) do
			file.Delete(root .. "/" .. v)
		end

		lia.steam.avatars = {}
	end)
end