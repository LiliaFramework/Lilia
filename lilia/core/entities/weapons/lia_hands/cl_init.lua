--------------------------------------------------------------------------------------------------------------------------
include("shared.lua")
--------------------------------------------------------------------------------------------------------------------------
SWEP.PrintName = "Hands"
SWEP.Slot = 0
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
--------------------------------------------------------------------------------------------------------------------------
function SWEP:PreDrawViewModel(viewModel, weapon, client)
    local hands = player_manager.TranslatePlayerHands(player_manager.TranslateToPlayerModelName(client:GetModel()))
    if hands and hands.model then
        viewModel:SetModel(hands.model)
        viewModel:SetSkin(hands.skin)
        viewModel:SetBodyGroups(hands.body)
    end
end

--------------------------------------------------------------------------------------------------------------------------
function SWEP:Think()
    local owner = self:GetOwner()
    if owner then
        local viewModel = owner:GetViewModel()
        if IsValid(viewModel) then
            viewModel:SetPlaybackRate(1)
        end
    end
end
--------------------------------------------------------------------------------------------------------------------------