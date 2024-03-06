
function lia.scroll.send(text, receiver, callback)
    netstream.Start(receiver, "lia_ScrollData", text)
    timer.Simple(0.1 * #text + 4, function() if callback then callback() end end)
end

