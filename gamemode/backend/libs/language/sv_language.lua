--------------------------------------------------------------------------------------------------------
function L(key, ...)
	local languages = lia.lang.stored
	local langKey = CreateClientConVar("lia_language", "english", true, true):GetString()
	local info = languages[langKey] or languages.english

	return string.format(info and info[key] or key, ...)
end
--------------------------------------------------------------------------------------------------------
function L2(key, ...)
	local langKey = CreateClientConVar("lia_language", "english", true, true):GetString()
	local info = lia.lang.stored[langKey]
	if info and info[key] then return string.format(info[key], ...) end
end
--------------------------------------------------------------------------------------------------------