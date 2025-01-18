lia.color = lia.color or {}
function lia.color.Adjust(color, rOffset, gOffset, bOffset, aOffset)
  local r = math.Clamp(color.r + rOffset, 0, 255)
  local g = math.Clamp(color.g + gOffset, 0, 255)
  local b = math.Clamp(color.b + bOffset, 0, 255)
  local a = math.Clamp(color.a + (aOffset or 0), 0, 255)
  return Color(r, g, b, a)
end

function lia.color.ColorToHex(color)
  return "0x" .. bit.tohex(color.r, 2) .. bit.tohex(color.g, 2) .. bit.tohex(color.b, 2)
end

function lia.color.Lighten(color, amount)
  local hue, saturation, lightness = ColorToHSL(color)
  lightness = math.Clamp(lightness / 255 + amount, 0, 1)
  return HSLToColor(hue, saturation, lightness)
end

function lia.color.Rainbow(frequency)
  return HSVToColor(CurTime() * frequency % 360, 1, 1)
end

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

function lia.color.toText(color)
  if not IsColor(color) then return end
  return (color.r or 255) .. "," .. (color.g or 255) .. "," .. (color.b or 255) .. "," .. (color.a or 255)
end

function lia.color.Darken(color, amount)
  local hue, saturation, lightness = ColorToHSL(color)
  lightness = math.Clamp(lightness / 255 - amount, 0, 1)
  return HSLToColor(hue, saturation, lightness)
end

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

function lia.color.rgb(r, g, b)
  return Color(r / 255, g / 255, b / 255)
end

function lia.color.LerpColor(frac, from, to)
  local col = Color(Lerp(frac, from.r, to.r), Lerp(frac, from.g, to.g), Lerp(frac, from.b, to.b), Lerp(frac, from.a, to.a))
  return col
end

function lia.color.ReturnMainAdjustedColors()
  return {
    background = lia.color.Adjust(lia.config.Color, -20, -10, -50, 255),
    sidebar = lia.color.Adjust(lia.config.Color, -30, -15, -60, 200),
    accent = lia.config.Color,
    text = Color(245, 245, 220, 255),
    hover = lia.color.Adjust(lia.config.Color, -40, -25, -70, 220),
    border = Color(255, 255, 255),
    highlight = Color(255, 255, 255, 30),
  }
end

do
  local function normalize(min, max, val)
    local delta = max - min
    return (val - min) / delta
  end

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
