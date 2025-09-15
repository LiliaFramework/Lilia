local PANEL = {}
function PANEL:Init()
    if lia.menuMusic then
        lia.menuMusic:Stop()
        lia.menuMusic = nil
    end
    timer.Remove("liaMusicFader")
    self:SetVisible(false)
    local src = lia.config.get("Music", "")
    if not src:match("%S") then return end
    local vol = lia.config.get("MusicVolume", 0.25)
    local function play(music)
        music:SetVolume(vol)
        lia.menuMusic = music
        music:Play()
    end
    if src:match("^https://") then
        http.Fetch(src, function(body)
            local path = "lia_temp_music.mp3"
            file.Write(path, body)
            sound.PlayFile("DATA/" .. path, "noplay", function(m) if m then play(m) end end)
        end)
    elseif src:match("^http") then
        sound.PlayURL(src, "noplay", function(m) if m then play(m) end end)
    else
        sound.PlayFile("sound/" .. src, "noplay", function(m) if m then play(m) end end)
    end
end
function PANEL:OnRemove()
    local music = lia.menuMusic
    if not music then return end
    lia.menuMusic = nil
    timer.Remove("liaMusicFader")
    local vol = lia.config.get("MusicVolume", 0.25)
    local start = RealTime()
    timer.Create("liaMusicFader", 0.1, 0, function()
        if not music then return timer.Remove("liaMusicFader") end
        local frac = math.max(0, 1 - (RealTime() - start) / 5)
        if music.ChangeVolume then
            music:ChangeVolume(frac * vol, 0.1)
        else
            music:SetVolume(frac * vol)
        end
        if frac <= 0 then
            music:Stop()
            timer.Remove("liaMusicFader")
        end
    end)
end
vgui.Register("liaCharBGMusic", PANEL, "DPanel")
