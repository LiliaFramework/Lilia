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
-- @module lia.flag
lia.flag = lia.flag or {}
lia.flag.list = lia.flag.list or {}
--- Creates a flag. This should be called shared in order for the client to be aware of the flag's existence.
-- @realm shared
-- @string flag Alphanumeric character to use for the flag
-- @string description Description of the flag
-- @func callback Function to call when the flag is given or taken from a player
function lia.flag.add(flag, desc, callback)
    lia.flag.list[flag] = {
        desc = desc,
        callback = callback
    }
end

local charMeta = lia.meta.character
if SERVER then
    -- Called to apply flags when a player has spawned.
    -- @realm server
    -- @internal
    -- @player client Player to setup flags for
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

    --- Flag util functions for character
    -- @classmod Character
    --- Sets this character's accessible flags. Note that this method overwrites **all** flags instead of adding them.
    -- @realm server
    -- @string flags Flag(s) this charater is allowed to have
    -- @see giveFlags
    function charMeta:setFlags(flags)
        self:setData("f", flags)
    end

    --- Adds a flag to the list of this character's accessible flags. This does not overwrite existing flags.
    -- @realm server
    -- @string flags Flag(s) this character should be given
    -- @usage character:GiveFlags("pet")
    -- -- gives p, e, and t flags to the character
    -- @see hasFlags
    function charMeta:giveFlags(flags)
        local addedFlags = ""
        for i = 1, #flags do
            local flag = flags:sub(i, i)
            local info = lia.flag.list[flag]
            if info then
                if not self:hasFlags(flag) then addedFlags = addedFlags .. flag end
                if info.callback then info.callback(self:getPlayer(), true) end
            end
        end

        if addedFlags ~= "" then self:setFlags(self:getFlags() .. addedFlags) end
    end

    --- Removes this character's access to the given flags.
    -- @realm server
    -- @string flags Flag(s) to remove from this character
    -- @usage -- for a character with "pet" flags
    -- character:takeFlags("p")
    -- -- character now has e, and t flags
    function charMeta:takeFlags(flags)
        local oldFlags = self:getFlags()
        local newFlags = oldFlags
        for i = 1, #flags do
            local flag = flags:sub(i, i)
            local info = lia.flag.list[flag]
            if info and info.callback then info.callback(self:getPlayer(), false) end
            newFlags = newFlags:gsub(flag, "")
        end

        if newFlags ~= oldFlags then self:setFlags(newFlags) end
    end
end

--- Returns all of the flags this character has.
-- @realm shared
-- @treturn string Flags this character has represented as one string. You can access individual flags by iterating through
-- the string letter by letter
function charMeta:getFlags()
    return self:getData("f", "")
end

--- Returns `true` if the character has the given flag(s).
-- @realm shared
-- @string flags Flag(s) to check access for
-- @treturn bool Whether or not this character has access to the given flag(s)
function charMeta:hasFlags(flags)
    for i = 1, #flags do
        if self:getFlags():find(flags:sub(i, i), 1, true) then return true end
    end
    return hook.Run("CharacterFlagCheck", self, flags) or false
end
