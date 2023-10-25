--------------------------------------------------------------------------------------------------------------------------
MODULE.ordered = MODULE.ordered or {}
--------------------------------------------------------------------------------------------------------------------------
local view = {}
--------------------------------------------------------------------------------------------------------------------------
local x3, y3 = 0, 0
--------------------------------------------------------------------------------------------------------------------------
local realOrigin = Vector(0, 0, 0)
--------------------------------------------------------------------------------------------------------------------------
local realAngles = Angle(0, 0, 0)
--------------------------------------------------------------------------------------------------------------------------
function MODULE:CalcView(client, origin, angles, fov)
    local scenes = self.scenes
    local shouldShow = IsValid(lia.gui.character) or not IsValid(LocalPlayer()) or not LocalPlayer():getChar()
    if shouldShow and table.Count(scenes) > 0 then
        local key = self.index
        local value = scenes[self.index]
        if not self.index or not value then
            value, key = table.Random(scenes)
            self.index = key
        end

        if self.orderedIndex or type(key) == "Vector" then
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
                    if self.orderedIndex > #self.ordered then
                        self.orderedIndex = 1
                    end
                else
                    local keys = {}
                    for k, v in pairs(scenes) do
                        if type(k) == "Vector" then
                            keys[#keys + 1] = k
                        end
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

--------------------------------------------------------------------------------------------------------------------------
function MODULE:CalcViewModelView(weapon, viewModel, oldEyePos, oldEyeAngles, eyePos, eyeAngles)
    if IsValid(lia.gui.character) then return Vector(0, 0, -100000), Angle(0, 0, 0) end
end
--------------------------------------------------------------------------------------------------------------------------