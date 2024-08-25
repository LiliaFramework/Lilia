local oStringUpper = string.upper
local SpecialCharacters = {
    ["ä"] = "Ä",
    ["ö"] = "Ö",
    ["ü"] = "Ü",
    ["ë"] = "Ë",
    ["ï"] = "Ï",
    ["â"] = "Â",
    ["ê"] = "Ê",
    ["î"] = "Î",
    ["ô"] = "Ô",
    ["û"] = "Û",
    ["à"] = "À",
    ["è"] = "È",
    ["ù"] = "Ù",
    ["ç"] = "Ç",
    ["é"] = "É",
    ["œ"] = "Œ",
    ["æ"] = "Æ"
}

function string.upper(str)
    for letter, upperVersion in pairs(SpecialCharacters) do
        str = str:gsub(letter, upperVersion)
    end
    return oStringUpper(str)
end

function string.FirstToUpper(str)
    return str:gsub("^%l", string.upper)
end
