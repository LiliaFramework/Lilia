--- Helper library that manages roleplay improving attributes.
-- @library lia.attribs
lia.attribs = lia.attribs or {}
lia.attribs.list = lia.attribs.list or {}
--- Loads attribute data from Lua files in the specified directory.
-- @string directory The directory path from which to load attribute files.
-- @realm shared
function lia.attribs.loadFromDir(directory)
    for _, v in ipairs(file.Find(directory .. "/*.lua", "LUA")) do
        local niceName
        if v:sub(1, 3) == "sh_" then
            niceName = v:sub(4, -5):lower()
        else
            niceName = v:sub(1, -5)
        end

        ATTRIBUTE = lia.attribs.list[niceName] or {}
        if MODULE then ATTRIBUTE.module = MODULE.uniqueID end
        lia.include(directory .. "/" .. v, "shared")
        ATTRIBUTE.name = ATTRIBUTE.name or "Unknown"
        ATTRIBUTE.desc = ATTRIBUTE.desc or "No description availalble."
        lia.attribs.list[niceName] = ATTRIBUTE
        ATTRIBUTE = nil
    end
end

if SERVER then
    --- Sets up attributes for a given character.
    -- Please refer to ATTRIBUTE:OnSetup() for a non-internal version of this.
    -- @realm server
    -- @internal
    -- @client client The player for whom attributes are being set up
    function lia.attribs.setup(client)
        local character = client:getChar()
        if character then
            for k, v in pairs(lia.attribs.list) do
                if v.OnSetup then v:OnSetup(client, character:getAttrib(k, 0)) end
            end
        end
    end
end
