local PANEL = FindMetaTable("Panel")
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
hook.Add("OnScreenSizeChanged", "CachedScreenScale_Update", updateScale)
hook.Add("OnReloaded", "CachedScreenScale_Update_Reload", updateScale)
function ScreenScale(v)
    cache.width[v] = cache.width[v] or v * scaleW
    return cache.width[v]
end

function ScreenScaleH(v)
    cache.height[v] = cache.height[v] or v * scaleH
    return cache.height[v]
end

function PANEL:SetScaledPos(x, y)
    self:SetPos(ScreenScale(x), ScreenScaleH(y))
end

function PANEL:SetScaledSize(w, h)
    self:SetSize(ScreenScale(w), ScreenScaleH(h))
end
