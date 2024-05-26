--[[--
Grants abilities to characters.

Flags are a simple way of adding/removing certain abilities to players on a per-character basis. Lilia comes with a few flags
by default, for example to restrict spawning of props, usage of the physgun, etc. All flags will be listed in the
`Flags` section of the `Help` menu. Flags are usually used when server validation is required to allow a player to do something
on their character. However, it's usually preferable to use in-character methods over flags when possible (i.e restricting
prop spawning to characters that rather have a bussiness).

Flags are a single alphanumeric character that can be checked on the server. Serverside callbacks can be used to provide
functionality whenever the flag is added or removed. For example:
	lia.flag.add("z", "Access to some cool stuff.", function(client, bGiven)
		print("z flag given:", bGiven)
	end)

	Entity(1):getChar():giveFlags("z")
	> z flag given: true

	Entity(1):getChar():takeFlags("z")
	> z flag given: false

	print(Entity(1):getChar():hasFlags("z"))
	> false

Check out `Character:giveFlags` and `Character:takeFlags` for additional info.
]]
-- @core_libs lia.flag
lia.flag = lia.flag or {}
lia.flag.list = lia.flag.list or {}
--- Creates a flag. This should be called shared in order for the client to be aware of the flag's existence.
-- @realm shared
-- @string flag Alphanumeric character to use for the flag
-- @string desc Description of the flag
-- @func callback Function to call when the flag is given or taken from a player
function lia.flag.add(flag, desc, callback)
    lia.flag.list[flag] = {
        desc = desc,
        callback = callback
    }
end

if SERVER then
    --- Called to apply flags when a player has spawned.
    -- @realm server
    -- @internal
    -- @client client Player to setup flags for
    function lia.flag.onSpawn(client)
        if client:getChar() then
            local flags = client:getChar():getFlags()
            for i = 1, #flags do
                local flag = flags:sub(i, i)
                local info = lia.flag.list[flag]
                if info and info.callback then info.callback(client, true) end
            end
        end
    end
end
