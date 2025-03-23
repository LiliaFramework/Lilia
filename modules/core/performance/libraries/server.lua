function MODULE:PropBreak( _, entity )
	if IsValid( entity ) and IsValid( entity:GetPhysicsObject() ) then constraint.RemoveAll( entity ) end
end

MODULE.ToolGunSounds = {
	[ "weapons/airboat/airboat_gun_lastshot1.wav" ] = true,
	[ "weapons/airboat/airboat_gun_lastshot2.wav" ] = true
}

function MODULE:EntityEmitSound( tab )
	if IsValid( tab.Entity ) and tab.Entity:IsPlayer() then
		local wep = tab.Entity:GetActiveWeapon()
		if IsValid( wep ) and wep:GetClass() == "gmod_tool" and self.ToolGunSounds[ tab.SoundName ] then return false end
	end
end
