function group()
    local g = {}

    function g:FadeOutRem(callback, fullRem)
        fullRem = fullRem or false

        for k, v in pairs(self:GetChildren()) do
            v:AlphaTo(0, 0.2, 0, function()
                v:Hide()

                if fullRem then
                    v:Remove()
                end
            end)
        end

        if callback then
            timer.Simple(0.2, callback)
        end
    end

    function g:FadeIn(delay)
        delay = delay or 0

        for k, v in pairs(self:GetChildren()) do
            if not v.Show then continue end
            v:Show()
            v:SetAlpha(0)
            v:AlphaTo(255, 0.2, delay)
        end
    end

    function g:FadeOut(callback, time)
        time = time or 0.2

        for k, v in pairs(self:GetChildren()) do
            v:AlphaTo(0, time)
            v:Hide()
        end

        if callback then
            timer.Simple(time, callback)
        end
    end

    function g:GetChildren()
        local c = {}

        for k, v in pairs(self) do
            if isfunction(v) then continue end
            c[#c + 1] = v
        end

        return c
    end

    function g:AddChildren(panel)
        for _, pnl in pairs(panel:GetChildren()) do
            table.insert(g, pnl)
        end
    end

    return g
end