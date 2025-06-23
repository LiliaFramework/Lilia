lia.faction = lia.faction or {}
lia.faction.indices = lia.faction.indices or {}
lia.faction.teams = lia.faction.teams or {}
local DefaultModels = {"models/player/barney.mdl", "models/player/alyx.mdl", "models/player/breen.mdl", "models/player/p2_chell.mdl"}
--[[
   lia.faction.loadFromDir

   Description:
      Loads all Lua faction files (*.lua) from the specified directory,
      includes them as shared files, and registers the factions.
      Each faction file should define a FACTION table with properties such as name, desc, color, etc.

   Parameters:
      directory (string) - The path to the directory containing faction files.

   Returns:
      nil

   Realm:
      Shared

   Example Usage:
      lia.faction.loadFromDir("path/to/factions")
]]
function lia.faction.loadFromDir(directory)
   for _, v in ipairs(file.Find(directory .. "/*.lua", "LUA")) do
      local niceName
      if v:sub(1, 3) == "sh_" then
         niceName = v:sub(4, -5):lower()
      else
         niceName = v:sub(1, -5)
      end

      FACTION = lia.faction.teams[niceName] or {
         index = table.Count(lia.faction.teams) + 1,
         isDefault = true
      }

      lia.include(directory .. "/" .. v, "shared")
      if not FACTION.name then
         FACTION.name = L("unknown")
         ErrorNoHalt("Faction '" .. niceName .. "' is missing a name. You need to add a FACTION.name = \"Name\"\n")
      end

      if not FACTION.desc then
         FACTION.desc = L("noDesc")
         ErrorNoHalt("Faction '" .. niceName .. "' is missing a description. You need to add a FACTION.desc = \"Description\"\n")
      end

      if not FACTION.color then
         FACTION.color = Color(150, 150, 150)
         ErrorNoHalt("Faction '" .. niceName .. "' is missing a color. You need to add FACTION.color = Color(1, 2, 3)\n")
      end

      team.SetUp(FACTION.index, FACTION.name or L("unknown"), FACTION.color or Color(125, 125, 125))
      FACTION.models = FACTION.models or DefaultModels
      FACTION.uniqueID = FACTION.uniqueID or niceName
      for _, modelData in pairs(FACTION.models) do
         if isstring(modelData) then
            util.PrecacheModel(modelData)
         elseif istable(modelData) then
            util.PrecacheModel(modelData[1])
         end
      end

      lia.faction.indices[FACTION.index] = FACTION
      lia.faction.teams[niceName] = FACTION
      FACTION = nil
   end
end

--[[
   lia.faction.get

   Description:
      Retrieves a faction by its index or unique identifier.

   Parameters:
      identifier (number or string) - The faction's index or unique identifier.

   Returns:
      table|nil - The faction table if found; nil otherwise.

   Realm:
      Shared

   Example Usage:
      local faction = lia.faction.get("citizen")
]]
function lia.faction.get(identifier)
   return lia.faction.indices[identifier] or lia.faction.teams[identifier]
end

--[[
   lia.faction.getIndex

   Description:
      Retrieves the index of a faction by its unique identifier.

   Parameters:
      uniqueID (string) - The unique identifier of the faction.

   Returns:
      number|nil - The faction index if found; nil otherwise.

   Realm:
      Shared

   Example Usage:
      local index = lia.faction.getIndex("citizen")
]]
function lia.faction.getIndex(uniqueID)
   return lia.faction.teams[uniqueID] and lia.faction.teams[uniqueID].index
end

--[[
   lia.faction.getClasses

   Description:
      Retrieves a list of classes associated with the specified faction.

   Parameters:
      faction (string) - The faction unique identifier.

   Returns:
      table - A table containing class tables that belong to the faction.

   Realm:
      Shared

   Example Usage:
      local classes = lia.faction.getClasses("citizen")
]]
function lia.faction.getClasses(faction)
   local classes = {}
   for _, class in pairs(lia.class.list) do
      if class.faction == faction then table.insert(classes, class) end
   end
   return classes
end

--[[
   lia.faction.getPlayers

   Description:
      Retrieves all player entities whose characters belong to the specified faction.

   Parameters:
      faction (string) - The faction unique identifier.

   Returns:
      table - A table of player entities in the faction.

   Realm:
      Shared

   Example Usage:
      local players = lia.faction.getPlayers("citizen")
]]
function lia.faction.getPlayers(faction)
   local players = {}
   for _, v in player.Iterator() do
      local character = v:getChar()
      if character and character:getFaction() == faction then table.insert(players, v) end
   end
   return players
end

--[[
   lia.faction.getPlayerCount

   Description:
      Counts the number of players whose characters belong to the specified faction.

   Parameters:
      faction (string) - The faction unique identifier.

   Returns:
      number - The number of players in the faction.

   Realm:
      Shared

   Example Usage:
      local count = lia.faction.getPlayerCount("citizen")
]]
function lia.faction.getPlayerCount(faction)
   local count = 0
   for _, v in player.Iterator() do
      local character = v:getChar()
      if character and character:getFaction() == faction then count = count + 1 end
   end
   return count
end

--[[
   lia.faction.isFactionCategory

   Description:
      Checks if the specified faction is a member of a given category.
   Parameters:
      faction (string) - The faction unique identifier.
      categoryFactions (table) - A table containing faction identifiers that define the category.

   Returns:
      boolean - True if the faction is in the category; false otherwise.

   Realm:
      Shared

   Example Usage:
      local isMember = lia.faction.isFactionCategory("citizen", {"citizen", "veteran"})
]]
function lia.faction.isFactionCategory(faction, categoryFactions)
   if table.HasValue(categoryFactions, faction) then return true end
   return false
end

--[[
   lia.faction.jobGenerate

   Description:
      Generates a new faction (job) based on provided parameters.
      Creates a faction table with index, name, description, color, models, and registers it with the team system.
      Pre-caches the faction models.

   Parameters:
      index (number) - The team index for the faction.
      name (string) - The faction name.
      color (Color) - The faction color.
      default (boolean) - Whether the faction is default.
      models (table) - A table of model paths or model data for the faction.

   Returns:
      table - The newly generated faction table.

   Realm:
      Shared

   Example Usage:
      local faction = lia.faction.jobGenerate(2, "Police", Color(0, 0, 255), false, {"models/player/police.mdl"})
]]
function lia.faction.jobGenerate(index, name, color, default, models)
   local FACTION = {}
   FACTION.index = index
   FACTION.isDefault = default
   FACTION.name = name
   FACTION.desc = ""
   FACTION.color = color
   FACTION.models = models or DefaultModels
   FACTION.uniqueID = FACTION.uniqueID or name
   for _, v in pairs(FACTION.models) do
      if isstring(v) then
         util.PrecacheModel(v)
      elseif istable(v) then
         util.PrecacheModel(v[1])
      end
   end

   lia.faction.indices[FACTION.index] = FACTION
   lia.faction.teams[name] = FACTION
   team.SetUp(FACTION.index, FACTION.name, FACTION.color)
   return FACTION
end

local function formatModelDataEntry(name, faction, modelIndex, modelData, category)
   local newGroups
   if istable(modelData) and modelData[3] then
      local groups = {}
      if istable(modelData[3]) then
         local dummy
         if SERVER then
            dummy = ents.Create("prop_physics")
            dummy:SetModel(modelData[1])
         else
            dummy = ClientsideModel(modelData[1])
         end

         local groupData = dummy:GetBodyGroups()
         for _, group in ipairs(groupData) do
            if group.id > 0 then
               if modelData[3][group.id] then
                  groups[group.id] = modelData[3][group.id]
               elseif modelData[3][group.name] then
                  groups[group.id] = modelData[3][group.name]
               end
            end
         end

         dummy:Remove()
         newGroups = groups
      elseif isstring(modelData[3]) then
         newGroups = string.Explode("", modelData[3])
      end
   end

   if newGroups then
      if category then
         lia.faction.teams[name].models[category][modelIndex][3] = newGroups
         lia.faction.indices[faction.index].models[category][modelIndex][3] = newGroups
      else
         lia.faction.teams[name].models[modelIndex][3] = newGroups
         lia.faction.indices[faction.index].models[modelIndex][3] = newGroups
      end
   end
end

--[[
   lia.faction.formatModelData

   Description:
      Processes and formats model data for all registered factions.
      Iterates through each faction's model data and applies formatting to ensure proper grouping.

   Parameters:
      None

   Returns:
      nil

   Realm:
      Shared

   Example Usage:
      lia.faction.formatModelData()
]]
function lia.faction.formatModelData()
   for name, faction in pairs(lia.faction.teams) do
      if faction.models then
         for modelIndex, modelData in pairs(faction.models) do
            if isstring(modelIndex) then
               for subIndex, subData in pairs(modelData) do
                  formatModelDataEntry(name, faction, subIndex, subData, modelIndex)
               end
            else
               formatModelDataEntry(name, faction, modelIndex, modelData)
            end
         end
      end
   end
end

--[[
   lia.faction.getCategories

   Description:
      Retrieves a list of model categories for a given faction.
      Categories are determined by keys in the faction's models table that are strings.

   Parameters:
      teamName (string) - The unique identifier of the faction.

   Returns:
      table - A list of category names.

   Realm:
      Shared

   Example Usage:
      local categories = lia.faction.getCategories("citizen")
]]
function lia.faction.getCategories(teamName)
   local categories = {}
   local faction = lia.faction.teams[teamName]
   if faction and faction.models then
      for key, _ in pairs(faction.models) do
         if isstring(key) then table.insert(categories, key) end
      end
   end
   return categories
end

--[[
   lia.faction.getModelsFromCategory

   Description:
      Retrieves models from a specified category for a given faction.

   Parameters:
      teamName (string) - The unique identifier of the faction.
      category (string) - The model category to retrieve.

   Returns:
      table - A table of models in the specified category.

   Realm:
      Shared

   Example Usage:
      local models = lia.faction.getModelsFromCategory("citizen", "special")
]]
function lia.faction.getModelsFromCategory(teamName, category)
   local models = {}
   local faction = lia.faction.teams[teamName]
   if faction and faction.models and faction.models[category] then
      for index, model in pairs(faction.models[category]) do
         models[index] = model
      end
   end
   return models
end

--[[
   lia.faction.getDefaultClass

   Description:
      Retrieves the default class for a specified faction.
      Searches through the class list for the first class that is marked as default for the faction.

   Parameters:
      id (string) - The unique identifier of the faction.

   Returns:
      table|nil - The default class table if found; nil otherwise.

   Realm:
      Shared

   Example Usage:
      local defaultClass = lia.faction.getDefaultClass("citizen")
]]
function lia.faction.getDefaultClass(id)
   local defaultClass = nil
   for _, class in ipairs(lia.class.list) do
      if class.faction == id and class.isDefault then
         defaultClass = class
         break
      end
   end
   return defaultClass
end

if CLIENT then
   --[[
      lia.faction.hasWhitelist

      Description:
         Determines if the local player has whitelist access for a given faction.
         Checks the local whitelist data against the faction's uniqueID.

      Parameters:
         faction (string) - The unique identifier of the faction.

      Returns:
         boolean - True if the player is whitelisted; false otherwise.

      Realm:
         Client

      Example Usage:
         local whitelisted = lia.faction.hasWhitelist("citizen")
   ]]
   function lia.faction.hasWhitelist(faction)
      local data = lia.faction.indices[faction]
      if data then
         if data.isDefault then return true end
         local liaData = lia.localData and lia.localData.whitelists or {}
         return liaData[SCHEMA.folder] and liaData[SCHEMA.folder][data.uniqueID] or false
      end
      return false
   end
end