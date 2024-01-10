function lia.scroll.add(text, callback)
    local info = {
        text = "",
        callback = callback,
        nextChar = 0,
        char = ""
    }

    local i = 1
    timer.Create(
        "lia_Scroll" .. tostring(info),
        0.1,
        #text,
        function()
            if info then
                info.text = string.sub(text, 1, i)
                i = i + 1
                LocalPlayer():EmitSound("common/talk.wav", 40, math.random(120, 140))
                if i >= #text then
                    info.char = ""
                    info.start = CurTime() + 3
                    info.finish = CurTime() + 5
                end
            end
        end
    )
end
