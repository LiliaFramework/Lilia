
local GM = GM or GAMEMODE

function GM:PostDrawTranslucentRenderables()
    render.ClearStencil()
    render.SetStencilEnable(true)
    render.SetStencilWriteMask(99)
    render.SetStencilTestMask(99)
    render.SetStencilFailOperation(STENCILOPERATION_KEEP)
    render.SetStencilZFailOperation(STENCILOPERATION_KEEP)
    render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
    render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)
    render.SetStencilReferenceValue(1)
    if table.Count(lia.blur3d2d.list) > 0 then
        SUPPRESS_FROM_STENCIL = true
        for _, data in pairs(lia.blur3d2d.list) do
            if data.draw == false then continue end
            cam.Start3D2D(data.pos, data.ang, data.scale)
            data.callback()
            cam.End3D2D()
        end

        render.SetStencilReferenceValue(2)
        render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
        render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
        render.SetStencilReferenceValue(1)
        cam.Start2D()
        lia.util.drawBlurAt(0, 0, ScrW(), ScrH(), lia.blur3d2d.amount, lia.blur3d2d.passes)
        cam.End2D()
        render.SetStencilEnable(false)
        for _, data in pairs(lia.blur3d2d.list) do
            if data.draw == false then continue end
            cam.Start3D2D(data.pos, data.ang, data.scale)
            data.callback(true)
            cam.End3D2D()
        end

        SUPPRESS_FROM_STENCIL = nil
    end
end
--
