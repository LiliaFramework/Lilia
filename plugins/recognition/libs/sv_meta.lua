local character = lia.meta.character

do
    -- SERVER
    function character:recognize(id)
        if type(id) ~= "number" and id.getID then
            id = id:getID()
        end

        local recognized = self:getData("rgn", "")
        if recognized ~= "" and recognized:find("," .. id .. ",") then return false end
        self:setData("rgn", recognized .. "," .. id .. ",")

        return true
    end
end