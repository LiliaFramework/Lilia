function PLUGIN:StartCommand(ply, cmd)
	if ply:GetNWBool("IsInCombat", false) then
		if ply:GetNWBool("WarmUp", false) or not ply:GetNWBool("MyTurn", false) then
			cmd:ClearMovement()
			cmd:ClearButtons()
		end
	end
end