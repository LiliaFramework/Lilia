ATTRIBUTE.name = "Stamina"
ATTRIBUTE.desc = "Affects how fast you can run."

function ATTRIBUTE:onSetup(client, value)
	client:SetRunSpeed(lia.config.get("runSpeed", 235) + value)
end