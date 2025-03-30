local oldScrW = ScrW
local scrW, scrH
function ScrW()
    if scrW == nil then scrW = oldScrW() end
    return scrW
end

local oldScrH = ScrH
function ScrH()
    if scrH == nil then scrH = oldScrH() end
    return scrH
end

hook.Add("OnScreenSizeChanged", "CachedScreenScale", function(oldWidth, oldHeight, newWidth, newHeight) scrW, scrH = newWidth, newHeight end)