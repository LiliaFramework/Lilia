--------------------------------------------------------------------------------------------------------
local backCam = backCam or nil

--------------------------------------------------------------------------------------------------------
local function getDarkPanel()
    local dark = vgui.Create("DPanel")
    dark:SetSize(ScrW(), ScrH())
    dark:Center()
    dark:MakePopup()

    function dark:Paint(w, h)
        surface.SetDrawColor(0, 0, 0)
        surface.DrawRect(0, 0, w, h)
    end

    return dark
end

--------------------------------------------------------------------------------------------------------
function QuickBackground(time, callback)
    local dark = getDarkPanel()
    dark:SetAlpha(0)

    dark:AlphaTo(255, time / 2, 0, function()
        backCam = true

        dark:AlphaTo(0, time / 2, 0, function()
            dark:Remove()

            if callback then
                callback()
            end
        end)
    end)

    hook.Add("CalcView", "Camerabackground", function(ply, pos, ang, fov)
        if not backCam then return end
        local view = {}
        view.origin = ply:GetPos() + Vector(0, 0, 300)
        view.angles = ang + Angle(0, 45, 0)
        view.fov = fov
        view.drawviewer = true

        return view
    end)

    return "CalcView", "Camerabackground"
end

--------------------------------------------------------------------------------------------------------
function RemoveBackground(time, callback)
    local dark = getDarkPanel()
    dark:SetAlpha(0)

    dark:AlphaTo(255, time / 2, 0, function()
        hook.Remove("CalcView", "Camerabackground")
        backCam = false

        dark:AlphaTo(0, time / 2, 0, function()
            dark:Remove()

            if callback then
                callback()
            end
        end)
    end)
end
--------------------------------------------------------------------------------------------------------