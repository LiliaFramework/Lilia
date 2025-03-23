function MODULE:EntityTakeDamage( seat, dmgInfo )
	if lia.config.get( "DamageInCars", false ) and seat:isSimfphysCar() and seat.GetDriver then
		local client = seat:GetDriver()
		if IsValid( client ) then
			local hitPos = dmgInfo:GetDamagePosition()
			local clientPos = client:GetPos()
			local thresholdDistance = 53
			if hitPos:Distance( clientPos ) <= thresholdDistance then
				local newHealth = client:Health() - dmgInfo:GetDamage() * 0.3
				if newHealth > 0 then
					client:SetHealth( newHealth )
				else
					client:Kill()
				end
			end
		end
	end
end

function MODULE:isSuitableForTrunk( vehicle )
	if IsValid( vehicle ) and vehicle:isSimfphysCar() then return true end
end

function MODULE:CheckValidSit( client )
	local vehicle = client:getTracedEntity()
	if vehicle:isSimfphysCar() then return false end
end
