local ScreenScale, ScreenScaleH = ScreenScale(), ScreenScaleH()
local panel = FindMetaTable("Panel")

--[[
    Screen-scaling helper wrappers for Panel positioning functions.

    Description:
        These helpers apply ScreenScale and ScreenScaleH to common panel
        positioning and sizing methods so that UIs remain consistent across
        different resolutions.

    Realm:
        Client
]]

local map = {
    SetPos = {ScreenScale, ScreenScaleH},    -- panel:SetPos(x, y)
    SetSize = {ScreenScale, ScreenScaleH},   -- panel:SetSize(w, h)
    SetWide = {ScreenScale},                 -- panel:SetWide(w)
    SetTall = {ScreenScaleH},                -- panel:SetTall(h)
    SetX = {ScreenScale},                    -- panel:SetX(x)
    SetY = {ScreenScaleH}                    -- panel:SetY(y)
}

for name, funcs in pairs(map) do
    local base = panel[name]
    if #funcs == 2 then
        panel[name] = function(self, a, b, ...) return base(self, funcs[1](a), funcs[2](b), ...) end
    else
        panel[name] = function(self, a, ...) return base(self, funcs[1](a), ...) end
    end
end
