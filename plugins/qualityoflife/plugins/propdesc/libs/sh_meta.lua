local entityMeta = FindMetaTable("Entity")

function entityMeta:getExDesc()
	return self:getNetVar("exDesc")
end