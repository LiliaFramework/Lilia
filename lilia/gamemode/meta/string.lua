
-- @realm shared
-- @string str
-- @treturn string

local SpecialCharacters = {
    ["ä"] = "Ä",
    ["ö"] = "Ö",
    ["ü"] = "Ü"
}

local oStringUpper = string.upper

function string.upper( self )
    for letter, upperversion in pairs(SpecialCharacters) do
        self = self:gsub(letter, upperversion)
    end
    return oStringUpper(self)
end