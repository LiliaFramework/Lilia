
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
    ["é"] = "É"
}

local oStringUpper = string.upper

--- Custom string.upper function to handle special characters.
-- This function extends the default string.upper to correctly handle
-- special characters such as German umlauts.
-- @param str The string to be converted to upper case.
-- @return A new string where all lower case letters are converted to upper case,
-- including special characters defined in the SpecialCharacters table.
function string.upper(str)
    for letter, upperVersion in pairs(SpecialCharacters) do
        str = str:gsub(letter, upperVersion)
    end
    return oStringUpper(str)
end