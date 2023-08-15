--------------------------------------------------------------------------------------------------------
function GM:CalcView(client, origin, angles, fov)
	local view = self.BaseClass:CalcView(client, origin, angles, fov)
	local entity = Entity(client:getLocalVar("ragdoll", 0))
	local ragdoll = client:GetRagdollEntity()

	if (client:GetViewEntity() ~= client) then return view end

	if (
		-- First person if the player has fallen over.
		(
			not client:ShouldDrawLocalPlayer()
			and IsValid(entity)
			and entity:IsRagdoll()
		)
		or
		-- Also first person if the player is dead.
		(not LocalPlayer():Alive() and IsValid(ragdoll))
	) then
	 	local ent = LocalPlayer():Alive() and entity or ragdoll
		local index = ent:LookupAttachment("eyes")

		if (index) then
			local data = ent:GetAttachment(index)

			if (data) then
				view = view or {}
				view.origin = data.Pos
				view.angles = data.Ang
			end

			return view
		end
	end

	return view
end

--------------------------------------------------------------------------------------------------------
function GM:ShouldDrawEntityInfo(entity)
    if entity:IsPlayer() or IsValid(entity:getNetVar("player")) then return entity == LocalPlayer() and not LocalPlayer():ShouldDrawLocalPlayer() end

    return false
end
--------------------------------------------------------------------------------------------------------