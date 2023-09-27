--------------------------------------------------------------------------------------------------------
include("shared.lua")
--------------------------------------------------------------------------------------------------------
SWEP.PrintName = "Keys"
SWEP.Slot = 0
SWEP.SlotPos = 2
SWEP.DrawAmmo = false
--------------------------------------------------------------------------------------------------------
function SWEP:PreDrawViewModel(viewModel, weapon, client)
	local hands = player_manager.TranslatePlayerHands(player_manager.TranslateToPlayerModelName(client:GetModel()))
	if hands and hands.model then end
end
--------------------------------------------------------------------------------------------------------