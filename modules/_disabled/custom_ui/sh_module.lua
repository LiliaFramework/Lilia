local PLUGIN = PLUGIN
PLUGIN.name = 'UI'
PLUGIN.author = 'Leonheart#7476'
PLUGIN.websiteURL = 'https://colonial.noclip.me/'
PLUGIN.discordURL = 'https://discord.gg/yBZ9NT66ch'
PLUGIN.contentURL = 'https://steamcommunity.com/sharedfiles/filedetails/?id=2786863009'

PLUGIN.backgrounds = {lia.util.getMaterial('ui/bg1.png'), lia.util.getMaterial('ui/bg2.png'), lia.util.getMaterial('ui/bg3.png'), lia.util.getMaterial('ui/bg4.png'), lia.util.getMaterial('ui/bg5.png')}

lia.util.includeDir(PLUGIN.path .. '/derma/steps', true)
lia.util.includeDir(PLUGIN.path .. '/new_derma', true)

function LerpColor(frac, from, to)
    local col = Color(Lerp(frac, from.r, to.r), Lerp(frac, from.g, to.g), Lerp(frac, from.b, to.b), Lerp(frac, from.a, to.a))

    return col
end

lia.config.add('music', '', 'The default music played in the character menu.', nil, {
    category = PLUGIN.name
})

lia.config.add('musicvolume', '0.25', 'The Volume for the music played in the character menu.', nil, {
    form = 'Float',
    data = {
        min = 0,
        max = 1
    },
    category = PLUGIN.name
})

if CLIENT then
    local function _SScale(size)
        return size * (ScrH() / 900) + 10
    end

    function PLUGIN:LoadFonts(font)
        surface.CreateFont('liaCharTitleFont', {
            font = font,
            weight = 200,
            size = _SScale(70),
            additive = true
        })

        surface.CreateFont('liaCharDescFont', {
            font = font,
            weight = 200,
            size = _SScale(24),
            additive = true
        })

        surface.CreateFont('liaCharSubTitleFont', {
            font = font,
            weight = 200,
            size = _SScale(12),
            additive = true
        })

        surface.CreateFont('liaCharButtonFont', {
            font = font,
            weight = 200,
            size = _SScale(24),
            additive = true
        })

        surface.CreateFont('liaCharSmallButtonFont', {
            font = font,
            weight = 200,
            size = _SScale(22),
            additive = true
        })

        surface.CreateFont('liaEgMainMenu', {
            font = 'Open Sans',
            extended = true,
            size = SScale(12),
            weight = 500,
            antialias = true
        })
    end

    function PLUGIN:LiliaLoaded()
        vgui.Create('liaNewCharacterMenu')
    end

    function PLUGIN:KickedFromCharacter(id, isCurrentChar)
        if isCurrentChar then
            vgui.Create('liaNewCharacterMenu')
        end
    end

    function PLUGIN:CreateMenuButtons(tabs)
        tabs['characters'] = function(panel)
            if IsValid(lia.gui.menu) then
                lia.gui.menu:Remove()
            end

            vgui.Create('liaNewCharacterMenu')
        end
    end
end

if SERVER then
    resource.AddWorkshop('2884226192')
end