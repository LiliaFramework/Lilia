ITEM.name = "Restraints"
ITEM.desc = "A pair of ties used in the process of restraining individuals by binding their hands."
ITEM.model = "models/items/crossbowrounds.mdl"

ITEM.functions.Use = {
	onRun = function(item)
		if item.beingUsed then return false end
		local client = item.player
		local data = {}
		data.start = client:GetShootPos()
		data.endpos = data.start + client:GetAimVector() * 96
		data.filter = client
		local target = util.TraceLine(data).Entity
		if target:Team() == FACTION_STAFF then
			target:notify("You were just attempted to be restrained by " .. client:Name() .. ".")
			client:notify("You can't tie a staff member!")

			return false
		end

		if IsValid(target) and target:IsPlayer() and target:getChar() and not target:getNetVar("tying") and not target:getNetVar("restricted") then
			item.beingUsed = true
			client:EmitSound("physics/plastic/plastic_barrel_strain" .. math.random(1, 3) .. ".wav")
			client:setAction("@tying", 3)
			client:doStaredAction(
				target,
				function()
					item:remove()
					target:setRestricted(true)
					target:setNetVar("tying")
					client:EmitSound("npc/barnacle/neck_snap1.wav", 100, 140)
				end,
				3,
				function()
					client:setAction()
					target:setAction()
					target:setNetVar("tying")
					item.beingUsed = false
				end
			)

			target:setNetVar("tying", true)
			target:setAction("@beingTied", 3)
		else
			item.player:notifyLocalized("plyNotValid")
		end

		return false
	end,
	onCanRun = function(item) return not IsValid(item.entity) end
}

function ITEM:onCanBeTransfered(inventory, newInventory)
	return not self.beingUsed
end