local charMeta = lia.meta.character
function charMeta:doesRecognize(id)
    if not isnumber(id) and id.getID then
        id = id:getID()
    end

    return hook.Run("isCharRecognized", self, id) ~= false
end

function charMeta:doesFakeRecognize(id)
    if not isnumber(id) and id.getID then
        id = id:getID()
    end

    return hook.Run("isCharFakeRecognized", self, id) ~= false
end