local MODULE = MODULE
local characterMeta = lia.meta.character
function characterMeta:getMaxStamina()
  local maxStamina = hook.Run("CharMaxStamina", self) or lia.config.get("DefaultStamina", 100)
  return maxStamina
end

function characterMeta:getStamina()
  local stamina = self:getPlayer():getLocalVar("stamina", 100) or lia.config.get("DefaultStamina", 100)
  return stamina
end

function characterMeta:getAttrib(key, default)
  local att = self:getAttribs()[key] or default or 0
  local boosts = self:getBoosts()[key]
  if boosts then
    for _, v in pairs(boosts) do
      att = att + v
    end
  end
  return att
end

function characterMeta:getBoost(attribID)
  local boosts = self:getBoosts()
  return boosts[attribID]
end

function characterMeta:getBoosts()
  return self:getVar("boosts", {})
end

if SERVER then
  function characterMeta:updateAttrib(key, value)
    local client = self:getPlayer()
    local attribute = lia.attribs.list[key]
    if attribute then
      local attrib = self:getAttribs()
      attrib[key] = math.min((attrib[key] or 0) + value, hook.Run("GetAttributeMax", client, key))
      if IsValid(client) then
        netstream.Start(client, "attrib", self:getID(), key, attrib[key])
        if attribute.setup then attribute.setup(attrib[key]) end
      end
    end

    hook.Run("OnCharAttribUpdated", client, self, key, value)
  end

  function characterMeta:setAttrib(key, value)
    local client = self:getPlayer()
    local attribute = lia.attribs.list[key]
    if attribute then
      local attrib = self:getAttribs()
      attrib[key] = value
      if IsValid(client) then
        netstream.Start(client, "attrib", self:getID(), key, attrib[key])
        if attribute.setup then attribute.setup(attrib[key]) end
      end
    end

    hook.Run("OnCharAttribUpdated", client, self, key, value)
  end

  function characterMeta:addBoost(boostID, attribID, boostAmount)
    local boosts = self:getVar("boosts", {})
    boosts[attribID] = boosts[attribID] or {}
    boosts[attribID][boostID] = boostAmount
    hook.Run("OnCharAttribBoosted", self:getPlayer(), self, attribID, boostID, boostAmount)
    return self:setVar("boosts", boosts, nil, self:getPlayer())
  end

  function characterMeta:removeBoost(boostID, attribID)
    local boosts = self:getVar("boosts", {})
    boosts[attribID] = boosts[attribID] or {}
    boosts[attribID][boostID] = nil
    hook.Run("OnCharAttribBoosted", self:getPlayer(), self, attribID, boostID, true)
    return self:setVar("boosts", boosts, nil, self:getPlayer())
  end
end