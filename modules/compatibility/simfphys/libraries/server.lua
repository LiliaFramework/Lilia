function MODULE:EntityTakeDamage( seat, dmgInfo )
	if not lia.config.get( "DamageInCars", true ) then return end
	if not seat:isSimfphysCar() then return end
	if seat.GetDriver == nil then return end
	local client = seat:GetDriver()
	if not IsValid( client ) then return end
	if dmgInfo:GetDamagePosition():Distance( client:GetPos() ) > 300 then return end
	local damageAmount = dmgInfo:GetDamage() * 0.3
	local newHealth = client:Health() - damageAmount
	if newHealth > 0 then
		client:SetHealth( newHealth )
	else
		client:Kill()
	end
end

function MODULE:simfphysUse( entity, client )
	if entity.IsBeingEntered then
		client:notify( "Someone is entering this car!" )
		return true
	end

	local delay = lia.config.get( "TimeToEnterVehicle", 5 )
	if entity:isSimfphysCar() and delay > 0 then
		entity.IsBeingEntered = true
		client:setAction( "Entering Vehicle...", delay )
		client:doStaredAction( entity, function()
			if IsValid( entity ) then
				entity.IsBeingEntered = false
				entity:SetPassenger( client )
			end
		end, delay, function()
			if IsValid( entity ) then entity.IsBeingEntered = false end
			if IsValid( client ) then client:stopAction() end
		end )
	end
	return true
end