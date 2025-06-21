lia = lia or {}
lia.color = lia.color or {}
lia.color.stored = lia.color.stored or {}
local clamp = math.Clamp
local configGet = lia.config.get
local unpack = unpack
--[[
    lia.color.register(name, color)

    Description:
        Registers a named color for later lookup.

    Parameters:
        name (string) – Key used to reference the color.
        color (Color) – Color object or table.

    Returns:
        nil

    Realm:
        Shared
]]
function lia.color.register(name, color)
    lia.color.stored[name:lower()] = color
end

--[[
    lia.color.Adjust(color, rOffset, gOffset, bOffset, aOffset)

    Description:
        Creates a new color by applying offsets to each channel.

    Parameters:
        color (Color) – Base color.
        rOffset (number) – Red channel delta.
        gOffset (number) – Green channel delta.
        bOffset (number) – Blue channel delta.
        aOffset (number) – Alpha channel delta (optional).

    Returns:
        Color – Adjusted color.

    Realm:
        Shared
]]
function lia.color.Adjust(color, rOffset, gOffset, bOffset, aOffset)
    return Color(clamp(color.r + rOffset, 0, 255), clamp(color.g + gOffset, 0, 255), clamp(color.b + bOffset, 0, 255), clamp((color.a or 255) + (aOffset or 0), 0, 255))
end

--[[
    lia.color.ReturnMainAdjustedColors()

    Description:
        Returns a table of commonly used UI colors derived from the base config color.

    Parameters:
        None

    Returns:
        table – Mapping of UI color keys to Color objects.

    Realm:
        Shared
]]
function lia.color.ReturnMainAdjustedColors()
    local base = configGet("Color")
    return {
        background = lia.color.Adjust(base, -20, -10, -50, 0),
        sidebar = lia.color.Adjust(base, -30, -15, -60, -55),
        accent = base,
        text = Color(245, 245, 220, 255),
        hover = lia.color.Adjust(base, -40, -25, -70, -35),
        border = Color(255, 255, 255, 255),
        highlight = Color(255, 255, 255, 30)
    }
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
lia.color.register("maroon", {128, 0, 0})
lia.color.register("dark_maroon", {139, 28, 98})
lia.color.register("navy", {0, 0, 128})
lia.color.register("dark_navy", {0, 0, 139})
lia.color.register("olive", {128, 128, 0})
lia.color.register("dark_olive", {85, 107, 47})
lia.color.register("teal", {0, 128, 128})
lia.color.register("dark_teal", {0, 105, 105})
lia.color.register("peach", {255, 218, 185})
lia.color.register("dark_peach", {255, 218, 185})
lia.color.register("lavender", {230, 230, 250})
lia.color.register("dark_lavender", {148, 0, 211})
lia.color.register("aqua", {0, 255, 255})
lia.color.register("dark_aqua", {0, 206, 209})
lia.color.register("beige", {245, 245, 220})
lia.color.register("dark_beige", {139, 131, 120})
lia.color.register("aquamarine", {127, 255, 212})
lia.color.register("bisque", {255, 228, 196})
lia.color.register("blanched_almond", {255, 235, 205})
lia.color.register("blue_violet", {138, 43, 226})
lia.color.register("burlywood", {222, 184, 135})
lia.color.register("cadet_blue", {95, 158, 160})
lia.color.register("chartreuse", {127, 255, 0})
lia.color.register("chocolate", {210, 105, 30})
lia.color.register("coral", {255, 127, 80})
lia.color.register("cornflower_blue", {100, 149, 237})
lia.color.register("cornsilk", {255, 248, 220})
lia.color.register("crimson", {220, 20, 60})
lia.color.register("dark_goldenrod", {184, 134, 11})
lia.color.register("dark_khaki", {189, 183, 107})
lia.color.register("dark_orchid", {153, 50, 204})
lia.color.register("dark_salmon", {233, 150, 122})
lia.color.register("deep_pink", {255, 20, 147})
lia.color.register("deep_sky_blue", {0, 191, 255})
lia.color.register("dodger_blue", {30, 144, 255})
lia.color.register("fire_brick", {178, 34, 34})
lia.color.register("forest_green", {34, 139, 34})
lia.color.register("gainsboro", {220, 220, 220})
lia.color.register("ghost_white", {248, 248, 255})
lia.color.register("gold", {255, 215, 0})
lia.color.register("goldenrod", {218, 165, 32})
lia.color.register("green_yellow", {173, 255, 47})
lia.color.register("hot_pink", {255, 105, 180})
lia.color.register("indian_red", {205, 92, 92})
lia.color.register("indigo", {75, 0, 130})
lia.color.register("ivory", {255, 255, 240})
lia.color.register("khaki", {240, 230, 140})
lia.color.register("lavender_blush", {255, 240, 245})
lia.color.register("lawn_green", {124, 252, 0})
lia.color.register("lemon_chiffon", {255, 250, 205})
lia.color.register("light_coral", {240, 128, 128})
lia.color.register("light_goldenrod_yellow", {250, 250, 210})
lia.color.register("light_pink", {255, 182, 193})
lia.color.register("light_sea_green", {32, 178, 170})
lia.color.register("light_sky_blue", {135, 206, 250})
lia.color.register("light_slate_gray", {119, 136, 153})
lia.color.register("light_steel_blue", {176, 196, 222})
lia.color.register("lime", {0, 255, 0})
lia.color.register("lime_green", {50, 205, 50})
lia.color.register("linen", {250, 240, 230})
lia.color.register("medium_aquamarine", {102, 205, 170})
lia.color.register("medium_blue", {0, 0, 205})
lia.color.register("medium_orchid", {186, 85, 211})
lia.color.register("medium_purple", {147, 112, 219})
lia.color.register("medium_sea_green", {60, 179, 113})
lia.color.register("medium_slate_blue", {123, 104, 238})
lia.color.register("medium_spring_green", {0, 250, 154})
lia.color.register("medium_turquoise", {72, 209, 204})
lia.color.register("medium_violet_red", {199, 21, 133})
lia.color.register("midnight_blue", {25, 25, 112})
lia.color.register("mint_cream", {245, 255, 250})
lia.color.register("misty_rose", {255, 228, 225})
lia.color.register("moccasin", {255, 228, 181})
lia.color.register("navajo_white", {255, 222, 173})
lia.color.register("old_lace", {253, 245, 230})
lia.color.register("olive_drab", {107, 142, 35})
lia.color.register("orange_red", {255, 69, 0})
lia.color.register("orchid", {218, 112, 214})
lia.color.register("pale_goldenrod", {238, 232, 170})
lia.color.register("pale_green", {152, 251, 152})
lia.color.register("pale_turquoise", {175, 238, 238})
lia.color.register("pale_violet_red", {219, 112, 147})
lia.color.register("papaya_whip", {255, 239, 213})
lia.color.register("peach_puff", {255, 218, 185})
lia.color.register("peru", {205, 133, 63})
lia.color.register("plum", {221, 160, 221})
lia.color.register("powder_blue", {176, 224, 230})
lia.color.register("rosy_brown", {188, 143, 143})
lia.color.register("royal_blue", {65, 105, 225})
lia.color.register("saddle_brown", {139, 69, 19})
lia.color.register("salmon", {250, 128, 114})
lia.color.register("sandy_brown", {244, 164, 96})
lia.color.register("sea_green", {46, 139, 87})
lia.color.register("sea_shell", {255, 245, 238})
lia.color.register("sienna", {160, 82, 45})
lia.color.register("sky_blue", {135, 206, 235})
lia.color.register("slate_blue", {106, 90, 205})
lia.color.register("slate_gray", {112, 128, 144})
lia.color.register("snow", {255, 250, 250})
lia.color.register("spring_green", {0, 255, 127})
lia.color.register("steel_blue", {70, 130, 180})
lia.color.register("tan", {210, 180, 140})
lia.color.register("thistle", {216, 191, 216})
lia.color.register("tomato", {255, 99, 71})
lia.color.register("turquoise", {64, 224, 208})
lia.color.register("violet", {238, 130, 238})
lia.color.register("wheat", {245, 222, 179})
lia.color.register("white_smoke", {245, 245, 245})
lia.color.register("yellow_green", {154, 205, 50})
local oldColor = Color
function Color(r, g, b, a)
    if isstring(r) then
        local c = lia.color.stored[r:lower()]
        if c then return oldColor(unpack(c), g or 255) end
        return oldColor(255, 255, 255, 255)
    end
    return oldColor(r, g, b, a)
end

