﻿local PANEL = {}
function PANEL:Init()
    if lia.menuMusic then
        lia.menuMusic:Stop()
        lia.menuMusic = nil
        timer.Remove("liaMusicFader")
    end

    self:SetVisible(false)
    timer.Remove("liaMusicFader")
    local source = lia.config.get("Music", "")
    if not source:find("%S") then return end
    if source:find("http") then
        if source:find("^https://") then
            http.Fetch(source, function(body)
                local path = "lia_temp_music.mp3"
                file.Write(path, body)
                sound.PlayFile("DATA/" .. path, "noplay", function(music)
                    if music then
                        music:SetVolume(lia.config.get("MusicVolume", 0.25))
                        lia.menuMusic = music
                        lia.menuMusic:Play()
                    end
                end)
            end)
        else
            sound.PlayURL(source, "noplay", function(music)
                if music then
                    music:SetVolume(lia.config.get("MusicVolume", 0.25))
                    lia.menuMusic = music
                    lia.menuMusic:Play()
                end
            end)
        end
    else
        sound.PlayFile("sound/" .. source, "noplay", function(music)
            if music then
                music:SetVolume(lia.config.get("MusicVolume", 0.25))
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
                music:ChangeVolume(fraction * lia.config.get("MusicVolume", 0.25), 0.1)
            elseif music.SetVolume then
                music:SetVolume(fraction * lia.config.get("MusicVolume", 0.25))
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