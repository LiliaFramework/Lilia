lia.lang = lia.lang or {}
lia.lang.stored = lia.lang.stored or {}
lia.lang.names = lia.lang.names or {}

function lia.lang.loadFromDir(directory)
	for k, v in ipairs(file.Find(directory.."/sh_*.lua", "LUA")) do
		local niceName = v:sub(4, -5):lower()

		lia.util.include(directory.."/"..v, "shared")

		if (LANGUAGE) then
			if (NAME) then
				lia.lang.names[niceName] = NAME
				NAME = nil
			end

			lia.lang.stored[niceName] = table.Merge(lia.lang.stored[niceName] or {}, LANGUAGE)
			LANGUAGE = nil
		end
	end
end

local FormatString = string.format

if (SERVER) then
	local ClientGetInfo = FindMetaTable("Player").GetInfo

	function L(key, client, ...)
		local languages = lia.lang.stored
		local langKey = ClientGetInfo(client, "lia_language")
		local info = languages[langKey] or languages.english

		return FormatString(info and info[key] or key, ...)
	end

	function L2(key, client, ...)
		local languages = lia.lang.stored
		local langKey = ClientGetInfo(client, "lia_language")
		local info = languages[langKey] or languages.english

		if (info and info[key]) then
			return FormatString(info[key], ...)
		end
	end

	function L3(key, langKey, ...)
		local languages = lia.lang.stored
		if (langKey) then
			local info = languages[langKey] or languages.english

			return FormatString(info and info[key] or key, ...)
		else
			return (key)
		end
	end
else
	LIA_CVAR_LANG = CreateClientConVar("lia_language", lia.config.language or "english", true, true)

	function L(key, ...)
		local languages = lia.lang.stored
		local langKey = LIA_CVAR_LANG:GetString()
		local info = languages[langKey] or languages.english

		return FormatString(info and info[key] or key, ...)
	end

	function L2(key, ...)
		local langKey = LIA_CVAR_LANG:GetString()
		local info = lia.lang.stored[langKey]

		if (info and info[key]) then
			return FormatString(info[key], ...)
		end
	end
end