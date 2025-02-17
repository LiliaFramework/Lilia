local MODULE = MODULE
MODULE.scenes = MODULE.scenes or {}
MODULE.ordered = MODULE.ordered or {}
local x3, y3 = 0, 0
local realOrigin = Vector(0, 0, 0)
local realAngles = Angle(0, 0, 0)
local view = {}
function MODULE:CalcView()
    local scenes = self.scenes
    if IsValid(lia.gui.char) and table.Count(scenes) > 0 then
        local key = self.index
        local value = scenes[self.index]
        if not self.index or not value then
            value, key = table.Random(scenes)
            self.index = key
        end

        if self.orderedIndex or isvector(key) then
            local curTime = CurTime()
            self.orderedIndex = self.orderedIndex or 1
            local ordered = self.ordered[self.orderedIndex]
            if ordered then
                key = ordered[1]
                value = ordered[2]
            end

            if not self.startTime then
                self.startTime = curTime
                self.finishTime = curTime + 30
            end

            local fraction = math.min(math.TimeFraction(self.startTime, self.finishTime, CurTime()), 1)
            if value then
                realOrigin = LerpVector(fraction, key, value[1])
                realAngles = LerpAngle(fraction, value[2], value[3])
            end

            if fraction >= 1 then
                self.startTime = curTime
                self.finishTime = curTime + 30
                if ordered then
                    self.orderedIndex = self.orderedIndex + 1
                    if self.orderedIndex > #self.ordered then self.orderedIndex = 1 end
                else
                    local keys = {}
                    for k, _ in pairs(scenes) do
                        if isvector(k) then keys[#keys + 1] = k end
                    end

                    self.index = table.Random(keys)
                end
            end
        elseif value then
            realOrigin = value[1]
            realAngles = value[2]
        end

        local x, y = gui.MousePos()
        local x2, y2 = surface.ScreenWidth() * 0.5, surface.ScreenHeight() * 0.5
        local frameTime = FrameTime() * 0.5
        y3 = Lerp(frameTime, y3, math.Clamp((y - y2) / y2, -1, 1) * -6)
        x3 = Lerp(frameTime, x3, math.Clamp((x - x2) / x2, -1, 1) * 6)
        view.origin = realOrigin + realAngles:Up() * y3 + realAngles:Right() * x3
        view.angles = realAngles + Angle(y3 * -0.5, x3 * -0.5, 0)
        return view
    end
end

function MODULE:CalcViewModelView()
    if IsValid(lia.gui.char) then return Vector(0, 0, -100000), Angle(0, 0, 0) end
end