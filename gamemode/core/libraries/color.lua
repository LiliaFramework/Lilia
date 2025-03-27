lia.color = lia.color or {}
--[[ 
   Function: lia.color.Adjust

   Description:
      Adjusts the provided color by adding offsets to its red, green, blue, and alpha channels.
      The resulting values are clamped between 0 and 255 to ensure valid color components.

   Parameters:
      color  (Color)  - The original color.
      rOffset (number) - Offset for the red channel.
      gOffset (number) - Offset for the green channel.
      bOffset (number) - Offset for the blue channel.
      aOffset (number) - Offset for the alpha channel (optional, defaults to 0 if not provided).

   Returns:
      Color - A new color with the adjusted values.

   Realm:
      Shared

   Example Usage:
      local newColor = lia.color.Adjust(Color(100, 150, 200, 255), 10, -10, 5, 0)
]]
function lia.color.Adjust(color, rOffset, gOffset, bOffset, aOffset)
    local r = math.Clamp(color.r + rOffset, 0, 255)
    local g = math.Clamp(color.g + gOffset, 0, 255)
    local b = math.Clamp(color.b + bOffset, 0, 255)
    local a = math.Clamp(color.a + (aOffset or 0), 0, 255)
    return Color(r, g, b, a)
end

--[[ 
   Function: lia.color.ColorToHex

   Description:
      Converts a Color value to its hexadecimal string representation.
      The output format is "0xRRGGBB", where RR, GG, and BB represent the red, green, and blue channels.

   Parameters:
      color (Color) - The color to convert.

   Returns:
      string - The hexadecimal string representation of the color.

   Realm:
      Shared

   Example Usage:
      local hex = lia.color.ColorToHex(Color(255, 0, 0))
]]
function lia.color.ColorToHex(color)
    return "0x" .. bit.tohex(color.r, 2) .. bit.tohex(color.g, 2) .. bit.tohex(color.b, 2)
end

--[[ 
   Function: lia.color.Lighten

   Description:
      Lightens the given color by increasing its lightness component in the HSL color space.
      The function converts the color to HSL, increases the lightness, and then converts it back to a Color.

   Parameters:
      color  (Color)  - The original color.
      amount (number) - The amount to lighten the color (added to the normalized lightness).

   Returns:
      Color - A new, lightened color.

   Realm:
      Shared

   Example Usage:
      local lighterColor = lia.color.Lighten(Color(100, 100, 100, 255), 0.1)
]]
function lia.color.Lighten(color, amount)
    local hue, saturation, lightness = ColorToHSL(color)
    lightness = math.Clamp(lightness / 255 + amount, 0, 1)
    return HSLToColor(hue, saturation, lightness)
end

--[[ 
   Function: lia.color.Rainbow

   Description:
      Generates a rainbow color based on the current time and a frequency parameter.
      It uses the HSV color model to create a smoothly cycling color effect.

   Parameters:
      frequency (number) - The frequency at which the color cycles.

   Returns:
      Color - A color from the rainbow spectrum.

   Realm:
      Shared

   Example Usage:
      local rainbowColor = lia.color.Rainbow(1)
]]
function lia.color.Rainbow(frequency)
    return HSVToColor(CurTime() * frequency % 360, 1, 1)
end

--[[ 
   Function: lia.color.ColorCycle

   Description:
      Creates a cyclic blend between two colors over time using a sine-based interpolation.
      The function gradually shifts between col1 and col2 based on the sine of the current time.

   Parameters:
      col1 (Color) - The first color.
      col2 (Color) - The second color.
      freq (number) - The frequency of the color cycle (default is 1).

   Returns:
      Color - A new color that cycles between col1 and col2.

   Realm:
      Shared

   Example Usage:
      local cyclingColor = lia.color.ColorCycle(Color(255, 0, 0), Color(0, 0, 255), 1)
]]
function lia.color.ColorCycle(col1, col2, freq)
    freq = freq or 1
    local difference = Color(col1.r - col2.r, col1.g - col2.g, col1.b - col2.b)
    local time = CurTime()
    local rgb = {
        r = 0,
        g = 0,
        b = 0
    }

    for k, _ in pairs(rgb) do
        if col1[k] > col2[k] then
            rgb[k] = col2[k]
        else
            rgb[k] = col1[k]
        end
    end
    return Color(rgb.r + math.abs(math.sin(time * freq) * difference.r), rgb.g + math.abs(math.sin(time * freq + 2) * difference.g), rgb.b + math.abs(math.sin(time * freq + 4) * difference.b))
end

--[[ 
   Function: lia.color.toText

   Description:
      Converts a Color value into a comma-separated string representing its RGBA components.
      If the provided value is not a valid Color, the function returns nil.

   Parameters:
      color (Color) - The color to convert.

   Returns:
      string - A string in the format "r,g,b,a".

   Realm:
      Shared

   Example Usage:
      local colorString = lia.color.toText(Color(255, 255, 255, 255))
]]
function lia.color.toText(color)
    if not IsColor(color) then return end
    return (color.r or 255) .. "," .. (color.g or 255) .. "," .. (color.b or 255) .. "," .. (color.a or 255)
end

--[[ 
   Function: lia.color.Darken

   Description:
      Darkens the given color by decreasing its lightness component in the HSL color space.
      The function converts the color to HSL, decreases the lightness, and then converts it back to a Color.

   Parameters:
      color  (Color)  - The original color.
      amount (number) - The amount to darken the color (subtracted from the normalized lightness).

   Returns:
      Color - A new, darkened color.

   Realm:
      Shared

   Example Usage:
      local darkerColor = lia.color.Darken(Color(200, 200, 200, 255), 0.1)
]]
function lia.color.Darken(color, amount)
    local hue, saturation, lightness = ColorToHSL(color)
    lightness = math.Clamp(lightness / 255 - amount, 0, 1)
    return HSLToColor(hue, saturation, lightness)
end

--[[ 
   Function: lia.color.Blend

   Description:
      Blends two colors together based on the provided ratio.
      A ratio of 0 returns color1, while a ratio of 1 returns color2.

   Parameters:
      color1 (Color) - The first color.
      color2 (Color) - The second color.
      ratio  (number) - The blend ratio (between 0 and 1).

   Returns:
      Color - The blended color.

   Realm:
      Shared

   Example Usage:
      local blendedColor = lia.color.Blend(Color(255, 0, 0), Color(0, 0, 255), 0.5)
]]
function lia.color.Blend(color1, color2, ratio)
    ratio = math.Clamp(ratio, 0, 1)
    local r = Lerp(ratio, color1.r, color2.r)
    local g = Lerp(ratio, color1.g, color2.g)
    local b = Lerp(ratio, color1.b, color2.b)
    return Color(r, g, b)
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

    function lia.color.register(name, color, force)
        if not force and colors[name] then return end
        colors[name] = color
    end
end

--[[ 
   Function: lia.color.rgb

   Description:
      Creates a Color from given red, green, and blue values.
      The input values (0-255) are normalized to create a Color.

   Parameters:
      r (number) - The red component (0-255).
      g (number) - The green component (0-255).
      b (number) - The blue component (0-255).

   Returns:
      Color - A new Color with normalized RGB values.

   Realm:
      Shared

   Example Usage:
      local col = lia.color.rgb(255, 128, 64)
]]
function lia.color.rgb(r, g, b)
    return Color(r / 255, g / 255, b / 255)
end

--[[ 
   Function: lia.color.LerpColor

   Description:
      Linearly interpolates between two colors based on the provided fraction.
      The interpolation is applied to each RGBA component separately.

   Parameters:
      frac (number)  - The interpolation factor (0 to 1).
      from (Color)   - The starting color.
      to (Color)     - The target color.

   Returns:
      Color - The interpolated color.

   Realm:
      Shared

   Example Usage:
      local resultColor = lia.color.LerpColor(0.5, Color(255, 0, 0, 255), Color(0, 0, 255, 255))
]]
function lia.color.LerpColor(frac, from, to)
    local col = Color(Lerp(frac, from.r, to.r), Lerp(frac, from.g, to.g), Lerp(frac, from.b, to.b), Lerp(frac, from.a, to.a))
    return col
end

--[[ 
   Function: lia.color.ReturnMainAdjustedColors

   Description:
      Returns a table of main UI colors adjusted based on configuration settings.
      The table includes colors for background, sidebar, accent, text, hover, border, and highlight.

   Parameters:
      None

   Returns:
      table - A table containing the adjusted main colors.

   Realm:
      Shared

   Example Usage:
      local colors = lia.color.ReturnMainAdjustedColors()
]]
function lia.color.ReturnMainAdjustedColors()
    return {
        background = lia.color.Adjust(lia.config.get("Color"), -20, -10, -50, 255),
        sidebar = lia.color.Adjust(lia.config.get("Color"), -30, -15, -60, 200),
        accent = lia.config.get("Color"),
        text = Color(245, 245, 220, 255),
        hover = lia.color.Adjust(lia.config.get("Color"), -40, -25, -70, 220),
        border = Color(255, 255, 255),
        highlight = Color(255, 255, 255, 30),
    }
end

do
    local function normalize(min, max, val)
        local delta = max - min
        return (val - min) / delta
    end

    --[[ 
       Function: lia.color.LerpHSV

       Description:
          Interpolates between two colors in the HSV color space based on the current value within a specified range.
          The function linearly interpolates between the HSV values of the start and end colors.

       Parameters:
          start_color  (Color)  - The starting color (defaults to green if nil).
          end_color    (Color)  - The ending color (defaults to red if nil).
          maxValue     (number) - The maximum value of the range.
          currentValue (number) - The current value within the range.
          minValue     (number, optional) - The minimum value of the range (defaults to 0 if not provided).

       Returns:
          Color - The interpolated color converted back from HSV to a Color.

       Realm:
          Shared

       Example Usage:
          local interpColor = lia.color.LerpHSV(Color("green"), Color("red"), 100, 50)
    ]]
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