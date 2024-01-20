local scrW, scrH = ScrW(), ScrH()
local blurGoal = 0
local blurValue = 0
function FrameworkHUD:DrawBlur()
    local client = LocalPlayer()
    blurGoal = client:getLocalVar("blur", 0) + (hook.Run("AdjustBlurAmount", blurGoal) or 0)
    if blurValue ~= blurGoal then blurValue = math.Approach(blurValue, blurGoal, FrameTime() * 20) end
    if blurValue > 0 and not client:ShouldDrawLocalPlayer() then lia.util.drawBlurAt(0, 0, scrW, scrH, blurValue) end
end

function FrameworkHUD:ShouldDrawBlur()
    local client = LocalPlayer()
    return client:Alive()
end
