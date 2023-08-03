function lia.flag.add(flag, desc, callback)
	lia.flag.list[flag] = {
		desc = desc,
		callback = callback
	}
end