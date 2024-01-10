function MODULE:PostDrawOpaqueRenderables()
    local client = LocalPlayer()
    if not client:FlashlightIsOn() then return end
    local flashlight = DynamicLight(client:EntIndex())
    if flashlight then
        flashlight.pos = client:GetShootPos()
        flashlight.r = 255
        flashlight.g = 255
        flashlight.b = 255
        flashlight.brightness = 2
        flashlight.Decay = 1000
        flashlight.Size = 256
        flashlight.DieTime = CurTime() + 1
    end
end
