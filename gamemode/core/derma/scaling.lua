local baseW, baseH = 1920, 1080
local scaleW, scaleH
local cache = {
    width = {},
    height = {}
}

local function updateScale()
    scaleW = ScrW() / baseW
    scaleH = ScrH() / baseH
    cache.width = {}
    cache.height = {}
end

updateScale()
hook.Add("OnScreenSizeChanged", "liaScalingUpdate", updateScale)
hook.Add("OnReloaded", "liaScalingReload", updateScale)
function ScreenScale(v)
    cache.width[v] = cache.width[v] or v * scaleW
    return cache.width[v]
end

function ScreenScaleH(v)
    cache.height[v] = cache.height[v] or v * scaleH
    return cache.height[v]
end
