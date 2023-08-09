--------------------------------------------------------------------------------------------------------
function L(key, client, ...)
	local languages = lia.lang.stored
	local langKey = FindMetaTable("Player").GetInfo(client, "lia_language")
	local info = languages[langKey] or languages.english

	return string.format(info and info[key] or key, ...)
end
--------------------------------------------------------------------------------------------------------
function L2(key, client, ...)
	local languages = lia.lang.stored
	local langKey = FindMetaTable("Player").GetInfo(client, "lia_language")
	local info = languages[langKey] or languages.english
	if info and info[key] then return string.format(info[key], ...) end
end
--------------------------------------------------------------------------------------------------------
function L3(key, langKey, ...)
	local languages = lia.lang.stored

	if langKey then
		local info = languages[langKey] or languages.english

		return string.format(info and info[key] or key, ...)
	else
		return key
	end
end
--------------------------------------------------------------------------------------------------------