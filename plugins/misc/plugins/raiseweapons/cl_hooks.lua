local LIA_CVAR_LOWER2 = CreateClientConVar("lia_usealtlower", "0", true)
local LOWERED_ANGLES = Angle(30, -30, -25)

function PLUGIN:CalcViewModelView(weapon, viewModel, oldEyePos, oldEyeAngles, eyePos, eyeAngles)
	if (not IsValid(weapon)) then return end

	local vm_angles = eyeAngles
	local client = LocalPlayer()
	local value = 0

	if (not client:isWepRaised()) then
		value = 100
	end

	local fraction = (client.liaRaisedFrac or 0) / 100
	local rotation = weapon.LowerAngles or LOWERED_ANGLES

	if (LIA_CVAR_LOWER2:GetBool() and weapon.LowerAngles2) then
		rotation = weapon.LowerAngles2
	end

	vm_angles:RotateAroundAxis(vm_angles:Up(), rotation.p * fraction)
	vm_angles:RotateAroundAxis(vm_angles:Forward(), rotation.y * fraction)
	vm_angles:RotateAroundAxis(vm_angles:Right(), rotation.r * fraction)

	client.liaRaisedFrac = Lerp(
		FrameTime() * 2,
		client.liaRaisedFrac or 0,
		value
	)
end

function PLUGIN:SetupQuickMenu(menu)
	menu:addSpacer()
	menu:addCheck(L"altLower", function(panel, state)
		if (state) then
			RunConsoleCommand("lia_usealtlower", "1")
		else
			RunConsoleCommand("lia_usealtlower", "0")
		end
	end, LIA_CVAR_LOWER2:GetBool())
end
