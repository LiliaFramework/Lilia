function lia.util.SpawnProp(model, position, force, lifetime, angles, collision)
	-- Spawn the actual item entity.
	local entity = ents.Create("prop_physics")
	entity:SetModel(model)
	entity:Spawn()

	entity:SetCollisionGroup(collision or COLLISION_GROUP_WEAPON)
	entity:SetAngles(angles or angle_zero)

	if (type(position) == "Player") then
		position = position:GetItemDropPos(entity)
	end

	entity:SetPos(position)

	if (force) then
		local phys = entity:GetPhysicsObject()

		if (IsValid(phys)) then
			phys:ApplyForceCenter(force)
		end
	end

	if ((lifetime or 0) > 0) then
		timer.Simple(lifetime, function()
			if (IsValid(entity)) then
				entity:Remove()
			end
		end)
	end

	return entity
end

-- Применимо для отладки кода и ловли эксплоитеров
--- Сохраняется в console.log
function lia.util.DebugLog(str)
	MsgC(Color("sky_blue"), os.date("(%d/%m/%Y - %H:%M:%S)", os.time()), Color("yellow"), " [LOG] ", color_white, str, "\n")
end