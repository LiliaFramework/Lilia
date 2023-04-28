PLUGIN.name = "Acts"
PLUGIN.author = "Leonheart#7476/Cheesenot"
PLUGIN.desc = "Adds acts that can be performed."
PLUGIN.acts = PLUGIN.acts or {}

lia.util.include("sh_setup.lua")

for k, v in pairs(PLUGIN.acts) do
	local data = {}
		local multiple = false

		for k2, v2 in pairs(v) do
			if (istable(v2.sequence) and #v2.sequence > 1) then
				multiple = true

				break
			end
		end

		if (multiple) then
			data.syntax = "[number type]"
		end

		data.onRun = function(client, arguments)
			if (client.liaSeqUntimed) then
				client:setNetVar("actAng")
				client:leaveSequence()
				client.liaSeqUntimed = nil

				return
			end

			if (!client:Alive() or
				client:setLocalVar("ragdoll")) then
				return
			end

			if ((client.liaNextAct or 0) < CurTime()) then
				local class = lia.anim.getModelClass(client:GetModel())
				local info = v[class]

				if (info) then
					if (info.onCheck) then
						local result = info.onCheck(client)

						if (result) then
							return result
						end
					end

					local sequence

					if (istable(info.sequence)) then
						local index = math.Clamp(math.floor(tonumber(arguments[1]) or 1), 1, #info.sequence)

						sequence = info.sequence[index]
					else
						sequence = info.sequence
					end

					local duration = client:forceSequence(sequence, nil, info.untimed and 0 or nil)

					client.liaSeqUntimed = info.untimed
					client.liaNextAct = CurTime() + (info.untimed and 4 or duration) + 1
					client:setNetVar("actAng", client:GetAngles())
				else
					return "@modelNoSeq"
				end
			end
		end
	lia.command.add("act"..k, data)
end

function PLUGIN:UpdateAnimation(client, moveData)
	local angles = client:getNetVar("actAng")

	if (angles) then
		client:SetRenderAngles(angles)
	end
end

function PLUGIN:OnPlayerLeaveSequence(client)
	client:setNetVar("actAng")
end

function PLUGIN:PlayerDeath(client)
	if (client.liaSeqUntimed) then
		client:setNetVar("actAng")
		client:leaveSequence()
		client.liaSeqUntimed = nil
	end
end

function PLUGIN:OnCharFallover(client)
	if (client.liaSeqUntimed) then
		client:setNetVar("actAng")
		client:leaveSequence()
		client.liaSeqUntimed = nil
	end
end

function PLUGIN:ShouldDrawLocalPlayer(client)
	if (client:getNetVar("actAng")) then
		return true
	end
end

local GROUND_PADDING = Vector(0, 0, 8)
local PLAYER_OFFSET = Vector(0, 0, 72)

function PLUGIN:CalcView(client, origin, angles, fov)
	if (client:getNetVar("actAng")) then
		local view = {}
			local data = {}
				data.start = client:GetPos() + PLAYER_OFFSET
				data.endpos = data.start - client:EyeAngles():Forward()*72
			view.origin = util.TraceLine(data).HitPos + GROUND_PADDING
			view.angles = client:EyeAngles()
		return view
	end
end

function PLUGIN:PlayerBindPress(client, bind, pressed)
	if (client:getNetVar("actAng")) then
		bind = bind:lower()

		if (bind:find("+jump") and pressed) then
			lia.command.send("actsit")

			return true
		end
	end
end