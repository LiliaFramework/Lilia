local wCache, hCache = {}, {}
local origScrW, origScrH = ScrW, ScrH
local screenW, screenH = origScrW(), origScrH()
local scaleW, scaleH = screenW / 640, screenH / 480
function ScrW()
    return screenW
end

function ScrH()
    return screenH
end

function ScreenScale(w)
    local v = wCache[w]
    if not v then
        v = w * scaleW
        wCache[w] = v
    end
    return v
end

function ScreenScaleH(h)
    local v = hCache[h]
    if not v then
        v = h * scaleH
        hCache[h] = v
    end
    return v
end

hook.Add("OnScreenSizeChanged", "ScaleCache", function(_, _, newW, newH)
    screenW, screenH = newW, newH
    scaleW, scaleH = newW / 640, newH / 480
    table.Empty(wCache)
    table.Empty(hCache)
end)

sW, sH = ScreenScale, ScreenScaleH