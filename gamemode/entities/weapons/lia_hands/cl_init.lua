include("shared.lua")
SWEP.NextAllowedPlayRateChange = 0
function SWEP:DoDrawCrosshair(x, y)
    surface.SetDrawColor(255, 255, 255, 66)
    surface.DrawRect(x - 2, y - 2, 4, 4)
end
function SWEP:Holster()
    if not IsValid(self:GetOwner()) then return end
    local viewModel = self:GetOwner():GetViewModel()
    if IsValid(viewModel) then
        viewModel:SetPlaybackRate(1)
        viewModel:ResetSequence(ACT_VM_FISTS_HOLSTER)
        self.NextAllowedPlayRateChange = CurTime() + viewModel:SequenceDuration()
    end
    return true
end