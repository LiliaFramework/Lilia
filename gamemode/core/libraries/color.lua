lia.color = lia.color or {}
lia.color.stored = lia.color.stored or {}
lia.color.themes = lia.color.themes or {}
lia.color.theme = lia.color.theme or {}
lia.color.transition = {
    active = false,
    to = nil,
    progress = 0,
    speed = 3,
    colorBlend = 8
}

function lia.color.register(name, color)
    lia.color.stored[name:lower()] = color
end

function lia.color.setTheme(name)
    if not isstring(name) then error('Theme name must be a string') end
    local themeName = name:lower()
    if not lia.color.themes[themeName] then error('Theme "' .. name .. '" does not exist') end
    lia.color.theme = table.Copy(lia.color.themes[themeName])
end

function lia.color.setThemeSmooth(name)
    if not isstring(name) then error('Theme name must be a string') end
    local themeName = name:lower()
    if not lia.color.themes[themeName] then error('Theme "' .. name .. '" does not exist') end
    lia.color.transition.to = table.Copy(lia.color.themes[themeName])
    lia.color.transition.active = true
    lia.color.transition.progress = 0
    if not hook.GetTable().LiliaThemeTransition then
        hook.Add("Think", "LiliaThemeTransition", function()
            if not lia.color.transition.active then return end
            local dt = FrameTime()
            lia.color.transition.progress = lia.util.approachExp(lia.color.transition.progress, 1, lia.color.transition.speed, dt)
            local to = lia.color.transition.to
            if not to then
                lia.color.transition.active = false
                hook.Remove("Think", "LiliaThemeTransition")
                return
            end

            for k, v in pairs(to) do
                if lia.color.isColor(v) then
                    lia.color.theme[k] = lia.color.Lerp(lia.color.transition.colorBlend, lia.color.theme[k] or v, v)
                elseif type(v) == 'table' and #v > 0 then
                    lia.color.theme[k] = lia.color.theme[k] or {}
                    for i = 1, #v do
                        local vi = v[i]
                        if lia.color.isColor(vi) then
                            local currentColor = (lia.color.theme[k] and lia.color.theme[k][i]) or vi
                            lia.color.theme[k][i] = lia.color.Lerp(lia.color.transition.colorBlend, currentColor, vi)
                        else
                            lia.color.theme[k][i] = vi
                        end
                    end
                end
            end

            if lia.color.transition.progress >= 0.999 then
                lia.color.theme = table.Copy(lia.color.transition.to)
                lia.color.transition.active = false
                hook.Remove("Think", "LiliaThemeTransition")
            end
        end)
    end
end

function lia.color.isColor(v)
    return type(v) == "table" and type(v.r) == "number"
end

function lia.color.LerpColor(frac, col1, col2)
    local ft = FrameTime() * frac
    return Color(Lerp(ft, col1.r, col2.r), Lerp(ft, col1.g, col2.g), Lerp(ft, col1.b, col2.b), Lerp(ft, col1.a, col2.a))
end

function lia.color.getCurrentThemeName()
    for name, theme in pairs(lia.color.themes) do
        if theme == lia.color.theme then return name end
    end
    return 'unknown'
end

function lia.color.isTransitioning()
    return lia.color.transition.active
end

function lia.color.getTheme(name)
    if name then
        return lia.color.themes[name:lower()]
    else
        return lia.color.theme
    end
end

function lia.color.Adjust(color, rOffset, gOffset, bOffset, aOffset)
    return Color(math.Clamp(color.r + rOffset, 0, 255), math.Clamp(color.g + gOffset, 0, 255), math.Clamp(color.b + bOffset, 0, 255), math.Clamp((color.a or 255) + (aOffset or 0), 0, 255))
end

function lia.color.Lerp(frac, col1, col2)
    local ft = FrameTime() * frac
    return Color(Lerp(ft, col1.r, col2.r), Lerp(ft, col1.g, col2.g), Lerp(ft, col1.b, col2.b), Lerp(ft, col1.a, col2.a))
end

local oldColor = Color
function Color(r, g, b, a)
    if isstring(r) then
        local c = lia.color.stored[r:lower()]
        if c then return oldColor(unpack(c), g or 255) end
        return oldColor(255, 255, 255, 255)
    end
    return oldColor(r, g, b, a)
end

function lia.color.registerTheme(name, themeData)
    if not isstring(name) then error("Theme name must be a string") end
    if not istable(themeData) then error("Theme data must be a table") end
    local requiredFields = {"background", "sidebar", "accent", "text"}
    for _, field in ipairs(requiredFields) do
        if not themeData[field] then error("Theme '" .. name .. "' is missing required field: " .. field) end
    end

    lia.color.themes[name:lower()] = themeData
    if CLIENT and table.IsEmpty(lia.color.theme) then lia.color.theme = table.Copy(themeData) end
    function lia.color.getThemes()
        local themes = {}
        for name, _ in pairs(lia.color.themes) do
            table.insert(themes, name)
        end
        return themes
    end

    if CLIENT and table.IsEmpty(lia.color.theme) then
        local defaultTheme = lia.color.themes["default"]
        if defaultTheme then lia.color.theme = table.Copy(defaultTheme) end
    end
end

lia.color.register("black", {0, 0, 0})
lia.color.register("white", {255, 255, 255})
lia.color.register("gray", {128, 128, 128})
lia.color.register("dark_gray", {64, 64, 64})
lia.color.register("light_gray", {192, 192, 192})
lia.color.register("red", {255, 0, 0})
lia.color.register("dark_red", {139, 0, 0})
lia.color.register("light_red", {255, 99, 71})
lia.color.register("green", {0, 255, 0})
lia.color.register("dark_green", {0, 100, 0})
lia.color.register("light_green", {144, 238, 144})
lia.color.register("blue", {0, 0, 255})
lia.color.register("dark_blue", {0, 0, 139})
lia.color.register("light_blue", {173, 216, 230})
lia.color.register("cyan", {0, 255, 255})
lia.color.register("dark_cyan", {0, 139, 139})
lia.color.register("magenta", {255, 0, 255})
lia.color.register("dark_magenta", {139, 0, 139})
lia.color.register("yellow", {255, 255, 0})
lia.color.register("dark_yellow", {139, 139, 0})
lia.color.register("orange", {255, 165, 0})
lia.color.register("dark_orange", {255, 140, 0})
lia.color.register("purple", {128, 0, 128})
lia.color.register("dark_purple", {75, 0, 130})
lia.color.register("pink", {255, 192, 203})
lia.color.register("dark_pink", {199, 21, 133})
lia.color.register("brown", {165, 42, 42})
lia.color.register("dark_brown", {139, 69, 19})
lia.color.registerTheme("dark", {
    background = Color(25, 25, 25),
    sidebar = Color(40, 40, 40),
    accent = Color(106, 108, 197),
    text = Color(255, 255, 255),
    hover = Color(60, 65, 80),
    border = Color(100, 100, 100),
    highlight = Color(106, 108, 197, 30),
    window_shadow = Color(0, 0, 0, 100),
    header = Color(40, 40, 40),
    header_text = Color(100, 100, 100),
    background_alpha = Color(25, 25, 25, 210),
    background_panelpopup = Color(20, 20, 20, 150),
    button = Color(54, 54, 54),
    button_shadow = Color(0, 0, 0, 25),
    button_hovered = Color(60, 60, 62),
    liaButtonColor = Color(54, 54, 54),
    liaButtonHoveredColor = Color(60, 60, 62),
    liaButtonShadowColor = Color(0, 0, 0, 25),
    liaButtonRippleColor = Color(255, 255, 255, 30),
    liaButtonIconColor = Color(255, 255, 255),
    category = Color(50, 50, 50),
    category_opened = Color(50, 50, 50, 0),
    theme = Color(106, 108, 197),
    panel = {Color(60, 60, 60), Color(50, 50, 50), Color(80, 80, 80)},
    toggle = Color(56, 56, 56),
    focus_panel = Color(46, 46, 46),
    gray = Color(150, 150, 150, 220),
    panel_alpha = {Color(60, 60, 60, 150), Color(50, 50, 50, 150), Color(80, 80, 80, 150)}
})

lia.color.registerTheme("dark_mono", {
    background = Color(25, 25, 25),
    sidebar = Color(40, 40, 40),
    accent = Color(121, 121, 121),
    text = Color(255, 255, 255),
    hover = Color(60, 65, 80),
    border = Color(100, 100, 100),
    highlight = Color(121, 121, 121, 30),
    window_shadow = Color(0, 0, 0, 100),
    header = Color(40, 40, 40),
    header_text = Color(100, 100, 100),
    background_alpha = Color(25, 25, 25, 210),
    background_panelpopup = Color(20, 20, 20, 150),
    button = Color(54, 54, 54),
    button_shadow = Color(0, 0, 0, 25),
    button_hovered = Color(60, 60, 62),
    liaButtonColor = Color(54, 54, 54),
    liaButtonHoveredColor = Color(60, 60, 62),
    liaButtonShadowColor = Color(0, 0, 0, 25),
    liaButtonRippleColor = Color(255, 255, 255, 30),
    liaButtonIconColor = Color(255, 255, 255),
    category = Color(50, 50, 50),
    category_opened = Color(50, 50, 50, 0),
    theme = Color(121, 121, 121),
    panel = {Color(60, 60, 60), Color(50, 50, 50), Color(80, 80, 80)},
    toggle = Color(56, 56, 56),
    focus_panel = Color(46, 46, 46),
    gray = Color(150, 150, 150, 220),
    panel_alpha = {Color(60, 60, 60, 150), Color(50, 50, 50, 150), Color(80, 80, 80, 150)}
})

lia.color.registerTheme("light", {
    background = Color(255, 255, 255),
    sidebar = Color(240, 240, 240),
    accent = Color(106, 108, 197),
    text = Color(20, 20, 20),
    hover = Color(235, 240, 255),
    border = Color(150, 150, 150),
    highlight = Color(106, 108, 197, 30),
    window_shadow = Color(0, 0, 0, 50),
    header = Color(240, 240, 240),
    header_text = Color(150, 150, 150),
    background_alpha = Color(255, 255, 255, 170),
    background_panelpopup = Color(245, 245, 245, 150),
    button = Color(235, 235, 235),
    button_shadow = Color(0, 0, 0, 15),
    button_hovered = Color(196, 199, 218),
    liaButtonColor = Color(235, 235, 235),
    liaButtonHoveredColor = Color(196, 199, 218),
    liaButtonShadowColor = Color(0, 0, 0, 15),
    category = Color(240, 240, 245),
    category_opened = Color(240, 240, 245, 0),
    theme = Color(106, 108, 197),
    panel = {Color(250, 250, 255), Color(240, 240, 245), Color(230, 230, 235)},
    toggle = Color(220, 220, 230),
    focus_panel = Color(245, 245, 255),
    gray = Color(130, 130, 130, 220),
    panel_alpha = {Color(250, 250, 255, 120), Color(240, 240, 245, 120), Color(230, 230, 235, 120)}
})

lia.color.registerTheme("blue", {
    background = Color(24, 28, 38),
    sidebar = Color(36, 48, 66),
    accent = Color(80, 160, 220),
    text = Color(210, 220, 235),
    hover = Color(80, 160, 220, 90),
    border = Color(109, 129, 159),
    highlight = Color(80, 160, 220, 30),
    window_shadow = Color(18, 22, 32, 100),
    header = Color(36, 48, 66),
    header_text = Color(109, 129, 159),
    background_alpha = Color(24, 28, 38, 210),
    background_panelpopup = Color(20, 24, 32, 150),
    button = Color(38, 54, 82),
    button_shadow = Color(18, 22, 32, 35),
    button_hovered = Color(47, 69, 110),
    liaButtonColor = Color(38, 54, 82),
    liaButtonHoveredColor = Color(47, 69, 110),
    liaButtonShadowColor = Color(18, 22, 32, 35),
    category = Color(34, 48, 72),
    category_opened = Color(34, 48, 72, 0),
    theme = Color(80, 160, 220),
    panel = {Color(34, 48, 72), Color(38, 54, 82), Color(70, 120, 180)},
    toggle = Color(34, 44, 66),
    focus_panel = Color(48, 72, 90),
    gray = Color(150, 170, 190, 200),
    panel_alpha = {Color(34, 48, 72, 110), Color(38, 54, 82, 110), Color(70, 120, 180, 110)}
})

lia.color.registerTheme("red", {
    background = Color(32, 24, 24),
    sidebar = Color(54, 36, 36),
    accent = Color(180, 80, 80),
    text = Color(235, 210, 210),
    hover = Color(180, 80, 80, 90),
    border = Color(159, 109, 109),
    highlight = Color(180, 80, 80, 30),
    window_shadow = Color(32, 18, 18, 100),
    header = Color(54, 36, 36),
    header_text = Color(159, 109, 109),
    background_alpha = Color(32, 24, 24, 210),
    background_panelpopup = Color(28, 20, 20, 150),
    button = Color(66, 38, 38),
    button_shadow = Color(32, 18, 18, 35),
    button_hovered = Color(97, 50, 50),
    liaButtonColor = Color(66, 38, 38),
    liaButtonHoveredColor = Color(97, 50, 50),
    liaButtonShadowColor = Color(32, 18, 18, 35),
    category = Color(62, 34, 34),
    category_opened = Color(62, 34, 34, 0),
    theme = Color(180, 80, 80),
    panel = {Color(62, 34, 34), Color(66, 38, 38), Color(140, 70, 70)},
    toggle = Color(60, 34, 34),
    focus_panel = Color(72, 48, 48),
    gray = Color(180, 150, 150, 200),
    panel_alpha = {Color(62, 34, 34, 110), Color(66, 38, 38, 110), Color(140, 70, 70, 110)}
})

lia.color.registerTheme("green", {
    background = Color(24, 32, 26),
    sidebar = Color(36, 54, 40),
    accent = Color(80, 180, 120),
    text = Color(210, 235, 210),
    hover = Color(80, 180, 120, 90),
    border = Color(109, 159, 109),
    highlight = Color(80, 180, 120, 30),
    window_shadow = Color(18, 32, 22, 100),
    header = Color(36, 54, 40),
    header_text = Color(109, 159, 109),
    background_alpha = Color(24, 32, 26, 210),
    background_panelpopup = Color(20, 28, 22, 150),
    button = Color(38, 66, 48),
    button_shadow = Color(18, 32, 22, 35),
    button_hovered = Color(48, 88, 62),
    liaButtonColor = Color(38, 66, 48),
    liaButtonHoveredColor = Color(48, 88, 62),
    liaButtonShadowColor = Color(18, 32, 22, 35),
    category = Color(34, 62, 44),
    category_opened = Color(34, 62, 44, 0),
    theme = Color(80, 180, 120),
    panel = {Color(34, 62, 44), Color(38, 66, 48), Color(70, 140, 90)},
    toggle = Color(34, 60, 44),
    focus_panel = Color(48, 72, 58),
    gray = Color(150, 180, 150, 200),
    panel_alpha = {Color(34, 62, 44, 110), Color(38, 66, 48, 110), Color(70, 140, 90, 110)}
})

lia.color.registerTheme("orange", {
    background = Color(255, 250, 240),
    sidebar = Color(70, 35, 10),
    accent = Color(245, 130, 50),
    text = Color(45, 20, 10),
    hover = Color(255, 165, 80, 90),
    border = Color(250, 230, 210),
    highlight = Color(245, 130, 50, 30),
    window_shadow = Color(20, 8, 0, 100),
    header = Color(70, 35, 10),
    header_text = Color(250, 230, 210),
    background_alpha = Color(255, 250, 240, 220),
    background_panelpopup = Color(255, 245, 235, 160),
    button = Color(184, 122, 64),
    button_shadow = Color(20, 10, 0, 30),
    button_hovered = Color(197, 129, 65),
    liaButtonColor = Color(184, 122, 64),
    liaButtonHoveredColor = Color(197, 129, 65),
    liaButtonShadowColor = Color(20, 10, 0, 30),
    category = Color(255, 245, 235),
    category_opened = Color(255, 245, 235, 0),
    theme = Color(245, 130, 50),
    panel = {Color(255, 250, 240), Color(250, 220, 180), Color(235, 150, 90)},
    toggle = Color(143, 121, 104),
    focus_panel = Color(255, 240, 225),
    gray = Color(180, 161, 150, 200),
    panel_alpha = {Color(255, 250, 240, 120), Color(250, 220, 180, 120), Color(235, 150, 90, 120)}
})

lia.color.registerTheme("purple", {
    background = Color(25, 22, 30),
    sidebar = Color(40, 36, 56),
    accent = Color(138, 114, 219),
    text = Color(245, 240, 255),
    hover = Color(138, 114, 219, 90),
    border = Color(150, 140, 180),
    highlight = Color(138, 114, 219, 30),
    window_shadow = Color(8, 6, 20, 100),
    header = Color(40, 36, 56),
    header_text = Color(150, 140, 180),
    background_alpha = Color(25, 22, 30, 210),
    background_panelpopup = Color(28, 24, 40, 150),
    button = Color(58, 52, 76),
    button_shadow = Color(8, 6, 20, 30),
    button_hovered = Color(74, 64, 105),
    liaButtonColor = Color(58, 52, 76),
    liaButtonHoveredColor = Color(74, 64, 105),
    liaButtonShadowColor = Color(8, 6, 20, 30),
    category = Color(46, 40, 60),
    category_opened = Color(46, 40, 60, 0),
    theme = Color(138, 114, 219),
    panel = {Color(56, 48, 76), Color(44, 36, 64), Color(120, 90, 200)},
    toggle = Color(43, 39, 53),
    focus_panel = Color(48, 42, 62),
    gray = Color(140, 128, 148, 220),
    panel_alpha = {Color(56, 48, 76, 150), Color(44, 36, 64, 150), Color(120, 90, 200, 150)}
})

lia.color.registerTheme("coffee", {
    background = Color(45, 32, 25),
    sidebar = Color(67, 48, 36),
    accent = Color(150, 110, 75),
    text = Color(235, 225, 210),
    hover = Color(150, 110, 75, 90),
    border = Color(210, 190, 170),
    highlight = Color(150, 110, 75, 30),
    window_shadow = Color(15, 10, 5, 100),
    header = Color(67, 48, 36),
    header_text = Color(210, 190, 170),
    background_alpha = Color(45, 32, 25, 215),
    background_panelpopup = Color(38, 28, 22, 150),
    button = Color(84, 60, 45),
    button_shadow = Color(20, 10, 5, 40),
    button_hovered = Color(100, 75, 55),
    liaButtonColor = Color(84, 60, 45),
    liaButtonHoveredColor = Color(100, 75, 55),
    liaButtonShadowColor = Color(20, 10, 5, 40),
    category = Color(72, 54, 42),
    category_opened = Color(72, 54, 42, 0),
    theme = Color(150, 110, 75),
    panel = {Color(68, 50, 40), Color(90, 65, 50), Color(150, 110, 75)},
    toggle = Color(53, 40, 31),
    focus_panel = Color(70, 55, 40),
    gray = Color(180, 150, 130, 200),
    panel_alpha = {Color(68, 50, 40, 110), Color(90, 65, 50, 110), Color(150, 110, 75, 110)}
})

lia.color.registerTheme("ice", {
    background = Color(235, 245, 255),
    sidebar = Color(190, 225, 250),
    accent = Color(100, 170, 230),
    text = Color(20, 35, 50),
    hover = Color(100, 170, 230, 80),
    border = Color(68, 104, 139),
    highlight = Color(100, 170, 230, 30),
    window_shadow = Color(60, 100, 140, 100),
    header = Color(190, 225, 250),
    header_text = Color(68, 104, 139),
    background_alpha = Color(235, 245, 255, 200),
    background_panelpopup = Color(220, 235, 245, 150),
    button = Color(145, 185, 225),
    button_shadow = Color(80, 110, 140, 40),
    button_hovered = Color(170, 210, 255),
    liaButtonColor = Color(145, 185, 225),
    liaButtonHoveredColor = Color(170, 210, 255),
    liaButtonShadowColor = Color(80, 110, 140, 40),
    category = Color(200, 225, 245),
    category_opened = Color(200, 225, 245, 0),
    theme = Color(100, 170, 230),
    panel = {Color(146, 186, 211), Color(107, 157, 190), Color(74, 132, 184)},
    toggle = Color(168, 194, 219),
    focus_panel = Color(205, 230, 245),
    gray = Color(92, 112, 133, 200),
    panel_alpha = {Color(146, 186, 211, 120), Color(107, 157, 190, 120), Color(74, 132, 184, 120)}
})

lia.color.registerTheme("wine", {
    background = Color(31, 23, 22),
    sidebar = Color(59, 42, 53),
    accent = Color(148, 61, 91),
    text = Color(246, 242, 246),
    hover = Color(192, 122, 217, 90),
    border = Color(246, 242, 246),
    highlight = Color(148, 61, 91, 30),
    window_shadow = Color(10, 6, 20, 100),
    header = Color(59, 42, 53),
    header_text = Color(246, 242, 246),
    background_alpha = Color(31, 23, 22, 210),
    background_panelpopup = Color(36, 28, 28, 150),
    button = Color(79, 50, 60),
    button_shadow = Color(10, 6, 18, 30),
    button_hovered = Color(90, 52, 65),
    liaButtonColor = Color(79, 50, 60),
    liaButtonHoveredColor = Color(90, 52, 65),
    liaButtonShadowColor = Color(10, 6, 18, 30),
    category = Color(79, 50, 60),
    category_opened = Color(79, 50, 60, 0),
    theme = Color(148, 61, 91),
    panel = {Color(79, 50, 60), Color(63, 44, 48), Color(160, 85, 143)},
    toggle = Color(63, 40, 47),
    focus_panel = Color(70, 48, 58),
    gray = Color(170, 150, 160, 200),
    panel_alpha = {Color(79, 50, 60, 150), Color(63, 44, 48, 150), Color(160, 85, 143, 150)}
})

lia.color.registerTheme("violet", {
    background = Color(22, 24, 35),
    sidebar = Color(49, 50, 68),
    accent = Color(159, 180, 255),
    text = Color(238, 244, 255),
    hover = Color(159, 180, 255, 90),
    border = Color(238, 244, 255),
    highlight = Color(159, 180, 255, 30),
    window_shadow = Color(8, 6, 20, 100),
    header = Color(49, 50, 68),
    header_text = Color(238, 244, 255),
    background_alpha = Color(22, 24, 35, 210),
    background_panelpopup = Color(36, 40, 56, 150),
    button = Color(58, 64, 84),
    button_shadow = Color(8, 6, 18, 30),
    button_hovered = Color(64, 74, 104),
    liaButtonColor = Color(58, 64, 84),
    liaButtonHoveredColor = Color(64, 74, 104),
    liaButtonShadowColor = Color(8, 6, 18, 30),
    category = Color(58, 64, 84),
    category_opened = Color(58, 64, 84, 0),
    theme = Color(159, 180, 255),
    panel = {Color(58, 64, 84), Color(48, 52, 72), Color(109, 136, 255)},
    toggle = Color(46, 51, 66),
    focus_panel = Color(56, 62, 86),
    gray = Color(147, 147, 184, 200),
    panel_alpha = {Color(58, 64, 84, 150), Color(48, 52, 72, 150), Color(109, 136, 255, 150)}
})

lia.color.registerTheme("moss", {
    background = Color(14, 16, 12),
    sidebar = Color(42, 50, 36),
    accent = Color(110, 160, 90),
    text = Color(232, 244, 235),
    hover = Color(110, 160, 90, 90),
    border = Color(232, 244, 235),
    highlight = Color(110, 160, 90, 30),
    window_shadow = Color(0, 0, 0, 100),
    header = Color(42, 50, 36),
    header_text = Color(232, 244, 235),
    background_alpha = Color(14, 16, 12, 210),
    background_panelpopup = Color(24, 28, 22, 150),
    button = Color(64, 82, 60),
    button_shadow = Color(6, 8, 6, 30),
    button_hovered = Color(74, 99, 68),
    liaButtonColor = Color(64, 82, 60),
    liaButtonHoveredColor = Color(74, 99, 68),
    liaButtonShadowColor = Color(6, 8, 6, 30),
    category = Color(46, 64, 44),
    category_opened = Color(46, 64, 44, 0),
    theme = Color(110, 160, 90),
    panel = {Color(40, 56, 40), Color(66, 86, 66), Color(110, 160, 90)},
    toggle = Color(35, 44, 34),
    focus_panel = Color(46, 58, 44),
    gray = Color(148, 165, 140, 220),
    panel_alpha = {Color(40, 56, 40, 150), Color(66, 86, 66, 150), Color(110, 160, 90, 150)}
})

lia.color.registerTheme("coral", {
    background = Color(18, 14, 16),
    sidebar = Color(52, 32, 36),
    accent = Color(255, 120, 90),
    text = Color(255, 243, 242),
    hover = Color(255, 120, 90, 90),
    border = Color(255, 243, 242),
    highlight = Color(255, 120, 90, 30),
    window_shadow = Color(0, 0, 0, 100),
    header = Color(52, 32, 36),
    header_text = Color(255, 243, 242),
    background_alpha = Color(18, 14, 16, 210),
    background_panelpopup = Color(30, 22, 24, 150),
    button = Color(116, 66, 61),
    button_shadow = Color(8, 4, 6, 30),
    button_hovered = Color(134, 73, 68),
    liaButtonColor = Color(116, 66, 61),
    liaButtonHoveredColor = Color(134, 73, 68),
    liaButtonShadowColor = Color(8, 4, 6, 30),
    category = Color(74, 40, 42),
    category_opened = Color(74, 40, 42, 0),
    theme = Color(255, 120, 90),
    panel = {Color(66, 38, 40), Color(120, 60, 56), Color(240, 120, 90)},
    toggle = Color(58, 39, 37),
    focus_panel = Color(72, 42, 44),
    gray = Color(167, 136, 136, 220),
    panel_alpha = {Color(66, 38, 40, 150), Color(120, 60, 56, 150), Color(240, 120, 90, 150)}
})

lia.color.registerTheme("teal", {
    background = Color(20, 30, 28),
    sidebar = Color(30, 45, 42),
    accent = Color(0, 180, 160),
    text = Color(200, 240, 235),
    hover = Color(0, 180, 160, 90),
    border = Color(100, 180, 170),
    highlight = Color(0, 180, 160, 30),
    window_shadow = Color(0, 0, 0, 100),
    header = Color(30, 45, 42),
    header_text = Color(100, 180, 170),
    background_alpha = Color(20, 30, 28, 210),
    background_panelpopup = Color(15, 25, 23, 150),
    button = Color(40, 60, 55),
    button_shadow = Color(0, 0, 0, 25),
    button_hovered = Color(50, 75, 70),
    liaButtonColor = Color(40, 60, 55),
    liaButtonHoveredColor = Color(50, 75, 70),
    liaButtonShadowColor = Color(0, 0, 0, 25),
    liaButtonRippleColor = Color(255, 255, 255, 30),
    liaButtonIconColor = Color(255, 255, 255),
    category = Color(35, 50, 47),
    category_opened = Color(35, 50, 47, 0),
    theme = Color(0, 180, 160),
    panel = {Color(25, 40, 37), Color(35, 50, 47), Color(60, 90, 85)},
    toggle = Color(30, 45, 42),
    focus_panel = Color(40, 60, 55),
    gray = Color(120, 160, 150, 220),
    panel_alpha = {Color(25, 40, 37, 150), Color(35, 50, 47, 150), Color(60, 90, 85, 150)}
})

lia.color.registerTheme("default", {
    background = Color(17, 96, 88, 255),
    sidebar = Color(7, 86, 78, 200),
    accent = Color(37, 116, 108, 255),
    text = Color(245, 245, 220, 255),
    hover = Color(57, 136, 128, 220),
    border = Color(255, 255, 255, 255),
    highlight = Color(255, 255, 255, 30),
    window_shadow = Color(0, 0, 0, 100),
    header = Color(40, 40, 40),
    header_text = Color(100, 100, 100),
    background_alpha = Color(25, 25, 25, 210),
    background_panelpopup = Color(20, 20, 20, 150),
    button = Color(54, 54, 54),
    button_shadow = Color(0, 0, 0, 25),
    button_hovered = Color(60, 60, 62),
    liaButtonColor = Color(54, 54, 54),
    liaButtonHoveredColor = Color(60, 60, 62),
    liaButtonShadowColor = Color(0, 0, 0, 25),
    liaButtonRippleColor = Color(255, 255, 255, 30),
    liaButtonIconColor = Color(255, 255, 255),
    category = Color(50, 50, 50),
    category_opened = Color(50, 50, 50, 0),
    theme = Color(106, 108, 197),
    panel = {Color(60, 60, 60), Color(50, 50, 50), Color(80, 80, 80)},
    toggle = Color(56, 56, 56),
    focus_panel = Color(46, 46, 46),
    gray = Color(150, 150, 150, 220),
    panel_alpha = {Color(60, 60, 60, 150), Color(50, 50, 50, 150), Color(80, 80, 80, 150)}
})
