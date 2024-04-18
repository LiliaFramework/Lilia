--- Helper library for managing colors.
-- @module lia.color
lia.color = lia.color or {}

--- Lightens a color by the specified amount.
-- @color color Color: The color to lighten.
-- @int amount number: The amount by which to lighten the color.
-- @return Color: The resulting lightened color.
-- @realm client
function lia.color.Lighten(color, amount)
    return Color(math.Clamp(color.r + amount, 0, 255), math.Clamp(color.g + amount, 0, 255), math.Clamp(color.b + amount, 0, 255), color.a)
end
--- Darkens a color by the specified amount.
-- @color color Color: The color to darken.
-- @int amount number: The amount by which to darken the color.
-- @return Color: The resulting darkened color.
-- @realm client
function lia.color.Darken(color, amount)
    return Color(math.Clamp(color.r - amount, 0, 255), math.Clamp(color.g - amount, 0, 255), math.Clamp(color.b - amount, 0, 255), color.a)
end

do
    local colors = {
        black = Color(0, 0, 0),
        white = Color(255, 255, 255),
        gray = Color(128, 128, 128),
        dark_gray = Color(64, 64, 64),
        light_gray = Color(192, 192, 192),
        red = Color(255, 0, 0),
        dark_red = Color(139, 0, 0),
        light_red = Color(255, 99, 71),
        green = Color(0, 255, 0),
        dark_green = Color(0, 100, 0),
        light_green = Color(144, 238, 144),
        blue = Color(0, 0, 255),
        dark_blue = Color(0, 0, 139),
        light_blue = Color(173, 216, 230),
        cyan = Color(0, 255, 255),
        dark_cyan = Color(0, 139, 139),
        magenta = Color(255, 0, 255),
        dark_magenta = Color(139, 0, 139),
        yellow = Color(255, 255, 0),
        dark_yellow = Color(139, 139, 0),
        orange = Color(255, 165, 0),
        dark_orange = Color(255, 140, 0),
        purple = Color(128, 0, 128),
        dark_purple = Color(75, 0, 130),
        pink = Color(255, 192, 203),
        dark_pink = Color(199, 21, 133),
        brown = Color(165, 42, 42),
        dark_brown = Color(139, 69, 19),
        maroon = Color(128, 0, 0),
        dark_maroon = Color(139, 28, 98),
        navy = Color(0, 0, 128),
        dark_navy = Color(0, 0, 139),
        olive = Color(128, 128, 0),
        dark_olive = Color(85, 107, 47),
        teal = Color(0, 128, 128),
        dark_teal = Color(0, 128, 128),
        peach = Color(255, 218, 185),
        dark_peach = Color(255, 218, 185),
        lavender = Color(230, 230, 250),
        dark_lavender = Color(148, 0, 211),
        aqua = Color(0, 255, 255),
        dark_aqua = Color(0, 206, 209),
        beige = Color(245, 245, 220),
        dark_beige = Color(139, 131, 120)
    }

    local old_color = _OLD_COLOR_FN_ or Color
    _OLD_COLOR_FN_ = old_color
    function Color(r, g, b, a)
        if isstring(r) then
            if colors[r:lower()] then
                return ColorAlpha(colors[r:lower()], g or 255)
            elseif isstring(g) and isstring(b) then
                return old_color(r, g, b, a or 255)
            else
                return color_white
            end
        else
            return old_color(r, g, b, a)
        end
    end
--- Registers a custom color with a specified name.
-- @string name: The name of the color to register.
-- @color color: The color value to register.
-- @bool force: If true, forces registration even if the name already exists.
-- @realm client
    function lia.color.register(name, color, force)
        if not force and colors[name] then return end
        colors[name] = color
    end
end

do
    local function normalize(min, max, val)
        local delta = max - min
        return (val - min) / delta
    end
--- Interpolates between two colors in the HSV color space.
-- @color start_color: The starting color.
-- @color end_color: The ending color.
-- @int maxValue: The maximum value to interpolate between (used for normalization).
-- @int currentValue: The current value to interpolate (used for normalization).
-- @int minValue (optional): The minimum value to interpolate between (used for normalization). Defaults to 0.
-- @return Color: The resulting interpolated color.
-- @realm client
    function lia.color.LerpHSV(start_color, end_color, maxValue, currentValue, minValue)
        start_color = start_color or Color("green")
        end_color = end_color or Color("red")
        minValue = minValue or 0
        local hsv_start = ColorToHSV(end_color)
        local hsv_end = ColorToHSV(start_color)
        local linear = Lerp(normalize(minValue, maxValue, currentValue), hsv_start, hsv_end)
        return HSVToColor(linear, 1, 1)
    end
end
--- Converts RGB values to a Color object.
-- @int r: The red component (0-255).
-- @int g: The green component (0-255).
-- @int b: The blue component (0-255).
-- @return Color: The resulting color.
-- @realm client
function rgb(r, g, b)
    return Color(r / 255, g / 255, b / 255)
end
