net.Receive(
    "MusicPlayer",
    function()
        local str = net.ReadString()
        if str and str ~= "" then
            local service = MediaLibrary.load("media").guessService(str)
            local mediaclip = service:load(str)
            if music then
                music:stop()
                music = nil
            end

            music = mediaclip
            music:play()
        end
    end
)

net.Receive(
    "MusicPlayerStop",
    function()
        if music and IsValid(music) then
            music:stop()
        end
    end
)

net.Receive(
    "MusicPlayerSetVolume",
    function()
        local volume = net.ReadString()
        if volume and volume ~= "" then
            if music and IsValid(music) then
                music:setVolume(volume)
            end
        end
    end
)