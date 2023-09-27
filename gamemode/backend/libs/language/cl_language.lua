--------------------------------------------------------------------------------------------------------
function L(key, ...)
    local languages = lia.lang.stored
    local info = languages.english

    return string.format(info and info[key] or key, ...)
end

--------------------------------------------------------------------------------------------------------
function L2(key, ...)
    local info = lia.lang.stored["english"]
    if info and info[key] then return string.format(info[key], ...) end
end
--------------------------------------------------------------------------------------------------------