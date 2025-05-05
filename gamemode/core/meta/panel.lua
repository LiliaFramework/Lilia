local ScreenScale, ScreenScaleH = ScreenScale(), ScreenScaleH()
local panel = FindMetaTable("Panel")
local map = {
    SetPos = {ScreenScale, ScreenScaleH},
    SetSize = {ScreenScale, ScreenScaleH},
    SetWide = {ScreenScale},
    SetTall = {ScreenScaleH},
    SetX = {ScreenScale},
    SetY = {ScreenScaleH}
}

for name, funcs in pairs(map) do
    local base = panel[name]
    if #funcs == 2 then
        panel[name] = function(self, a, b, ...)
            print("valldx:", name, a, b)
            return base(self, funcs[1](a), funcs[2](b), ...)
        end
    else
        panel[name] = function(self, a, ...)
            print("valldx:", name, a)
            return base(self, funcs[1](a), ...)
        end
    end
end