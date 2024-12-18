local PANEL = {}
function PANEL:Init()
    if lia.menuMusic then
        lia.menuMusic:Stop()
        lia.menuMusic = nil
        timer.Remove("liaMusicFader")
    end

    self:SetVisible(false)
    timer.Remove("liaMusicFader")
    local source = MainMenu.Music
    if not source:find("%S") then return end
    if source:find("http") then
        sound.PlayURL(source, "noplay", function(music, errorID, fault)
            if music then
                music:SetVolume(MainMenu.MusicVolume)
                lia.menuMusic = music
                lia.menuMusic:Play()
            end
        end)
    else
        sound.PlayFile("sound/" .. source, "noplay", function(music, errorID, fault)
            if music then
                music:SetVolume(MainMenu.MusicVolume)
                lia.menuMusic = music
                lia.menuMusic:Play()
            end
        end)
    end
end

function PANEL:OnRemove()
    local music = lia.menuMusic
    if not music then return end
    local fraction = 1
    local start, finish = RealTime(), RealTime() + 5
    timer.Create("liaMusicFader", 0.1, 0, function()
        if lia.menuMusic then
            fraction = 1 - math.TimeFraction(start, finish, RealTime())
            if music.ChangeVolume then
                music:ChangeVolume(fraction * MainMenu.MusicVolume, 0.1)
            elseif music.SetVolume then
                music:SetVolume(fraction * MainMenu.MusicVolume)
            end

            if fraction <= 0 then
                music:Stop()
                lia.menuMusic = nil
                timer.Remove("liaMusicFader")
            end
        else
            timer.Remove("liaMusicFader")
        end
    end)
end

vgui.Register("liaCharBGMusic", PANEL, "DPanel")