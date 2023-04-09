lia.log.addType("vendorAccess", function(client, ...)
	local data = {...}
	local vendorName = data[1] or "unknown"

	return string.format("%s has accessed vendor %s.", client:Name(), vendorName)
end)

lia.log.addType("vendorExit", function(client, ...)
	local data = {...}
	local vendorName = data[1] or "unknown"

	return string.format("%s has exited vendor %s.", client:Name(), vendorName)
end)

lia.log.addType("vendorSell", function(client, ...)
	local data = {...}
	local vendorName = data[1] or "unknown"
	local itemName = data[2] or "unknown"

	return string.format("%s has sold a %s to %s.", client:Name(), itemName, vendorName)
end)

lia.log.addType("vendorBuy", function(client, ...)
	local data = {...}
	local vendorName = data[1] or "unknown"
	local itemName = data[2] or "unknown"

	return string.format("%s has bought a %s from %s.", client:Name(), itemName, vendorName)
end)
