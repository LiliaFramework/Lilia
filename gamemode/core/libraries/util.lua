--[[
   lia.util.FindPlayersInBox

   Description:
      Finds and returns a table of players within a given axis-aligned bounding box.

   Parameters:
      mins (Vector) — The minimum corner of the bounding box.
      maxs (Vector) — The maximum corner of the bounding box.

   Returns:
      table — A table of valid player entities.

   Realm:
      Shared

   Example Usage:
      local players = lia.util.FindPlayersInBox(Vector(0, 0, 0), Vector(100, 100, 100))
      for _, ply in ipairs(players) do
         print(ply:Name())
      end
]]
function lia.util.FindPlayersInBox(mins, maxs)
   local entsList = ents.FindInBox(mins, maxs)
   local plyList = {}
   for _, v in pairs(entsList) do
      if IsValid(v) and v:IsPlayer() then plyList[#plyList + 1] = v end
   end
   return plyList
end

--[[
   lia.util.FindPlayersInSphere

   Description:
      Finds and returns a table of players within a given spherical radius from an origin.

   Parameters:
      origin (Vector) — The center of the sphere.
      radius (number) — The radius of the sphere.

   Returns:
      table — A table of valid player entities.

   Realm:
      Shared

   Example Usage:
      local players = lia.util.FindPlayersInSphere(Vector(0, 0, 0), 200)
      for _, ply in ipairs(players) do
         print(ply:Name())
      end
]]
function lia.util.FindPlayersInSphere(origin, radius)
   local plys = {}
   local r2 = radius ^ 2
   for _, client in player.Iterator() do
      if client:GetPos():DistToSqr(origin) <= r2 then plys[#plys + 1] = client end
   end
   return plys
end

--[[
   lia.util.findPlayer

   Description:
      Attempts to find a player by identifier. The identifier can be STEAMID, SteamID64, "^" (self), "@" (looking at target), or partial name.

   Parameters:
      client (Player) — The player requesting the find (used for notifications).
      identifier (string) — The identifier to search by.

   Returns:
      Player|nil — The found player, or nil if not found.

   Realm:
      Shared

   Alias:
      lia.util.findPlayer

   Example Usage:
      local foundPly = lia.util.findPlayer(someAdmin, "Bob")
      if foundPly then
         print("Found player: " .. foundPly:Name())
      end
]]
function lia.util.findPlayer(client, identifier)
   local isValidClient = IsValid(client)
   if not isstring(identifier) or identifier == "" then
      if isValidClient then client:notifyLocalized("mustProvideString") end
      return nil
   end

   if string.match(identifier, "^STEAM_%d+:%d+:%d+$") then
      local ply = player.GetBySteamID(identifier)
      if IsValid(ply) then return ply end
      if isValidClient then client:notifyLocalized("plyNoExist") end
      return nil
   end

   if string.match(identifier, "^%d+$") and #identifier >= 17 then
      local sid = util.SteamIDFrom64(identifier)
      if sid then
         local ply = player.GetBySteamID(sid)
         if IsValid(ply) then return ply end
      end

      if isValidClient then client:notifyLocalized("plyNoExist") end
      return nil
   end

   if isValidClient and identifier == "^" then return client end
   if isValidClient and identifier == "@" then
      local trace = client:getTracedEntity()
      if IsValid(trace) and trace:IsPlayer() then return trace end
      client:notifyLocalized("lookToUseAt")
      return nil
   end

   local safe = string.PatternSafe(identifier)
   for _, ply in player.Iterator() do
      if lia.util.stringMatches(ply:Name(), safe) then return ply end
   end

   if isValidClient then client:notifyLocalized("plyNoExist") end
   return nil
end

--[[
   lia.util.findPlayerItems

   Description:
      Finds all item entities in the world created by the specified player.

   Parameters:
      client (Player) — The player whose items to find.

   Returns:
      table — A table of valid item entities.

   Realm:
      Shared

   Example Usage:
      local items = lia.util.findPlayerItems(LocalPlayer())
      for _, item in ipairs(items) do
         print("Found item entity: " .. item:GetClass())
      end
]]
function lia.util.findPlayerItems(client)
   local items = {}
   for _, item in ents.Iterator() do
      if IsValid(item) and item:isItem() and item:GetCreator() == client then table.insert(items, item) end
   end
   return items
end

--[[
   lia.util.findPlayerItemsByClass

   Description:
      Finds all item entities in the world created by the specified player with a specific class ID.

   Parameters:
      client (Player) — The player whose items to find.
      class (string) — The class ID to filter by.

   Returns:
      table — A table of valid item entities matching the class.

   Realm:
      Shared

   Example Usage:
      local items = lia.util.findPlayerItemsByClass(LocalPlayer(), "food_banana")
      for _, item in ipairs(items) do
         print("Found item entity: " .. item:GetClass())
      end
]]
function lia.util.findPlayerItemsByClass(client, class)
   local items = {}
   for _, item in ents.Iterator() do
      if IsValid(item) and item:isItem() and item:GetCreator() == client and item:getNetVar("id") == class then table.insert(items, item) end
   end
   return items
end

--[[
   lia.util.findPlayerEntities

   Description:
      Finds all entities in the world created by or associated with the specified player. An optional class filter can be applied.

   Parameters:
      client (Player) — The player whose entities to find.
      class (string|nil) — The class name to filter by (optional).

   Returns:
      table — A table of valid entities.

   Realm:
      Shared

   Example Usage:
      local entities = lia.util.findPlayerEntities(LocalPlayer(), "prop_physics")
      for _, ent in ipairs(entities) do
         print("Found player entity: " .. ent:GetClass())
      end
]]
function lia.util.findPlayerEntities(client, class)
   local entities = {}
   for _, entity in ents.Iterator() do
      if IsValid(entity) and (not class or entity:GetClass() == class) and (entity:GetCreator() == client or entity.client and entity.client == client) then table.insert(entities, entity) end
   end
   return entities
end

--[[
   lia.util.stringMatches

   Description:
      Checks if string a matches string b (case-insensitive, partial matches).

   Parameters:
      a (string) — The first string to check.
      b (string) — The second string to match against.

   Returns:
      boolean — True if they match, false otherwise.

   Realm:
      Shared

   Example Usage:
      if lia.util.stringMatches("Hello", "he") then
         print("Strings match!")
      end
]]
function lia.util.stringMatches(a, b)
   if a and b then
      local a2, b2 = a:lower(), b:lower()
      if a == b then return true end
      if a2 == b2 then return true end
      if a:find(b) then return true end
      if a2:find(b2) then return true end
   end
   return false
end

--[[
   lia.util.getAdmins

   Description:
      Returns all players considered staff or admins, as determined by client:isStaff().

   Returns:
      table — A table of player entities who are staff.

   Realm:
      Shared

   Example Usage:
      local admins = lia.util.getAdmins()
      for _, admin in ipairs(admins) do
         print("Staff: " .. admin:Name())
      end
]]
function lia.util.getAdmins()
   local staff = {}
   for _, client in player.Iterator() do
      local hasPermission = client:isStaff()
      if hasPermission then staff[#staff + 1] = client end
   end
   return staff
end

--[[
   lia.util.findPlayerBySteamID64

   Description:
      Finds a player currently on the server by their SteamID64.

   Parameters:
      SteamID64 (string) — The SteamID64 to search for.

   Returns:
      Player|nil — The found player or nil if not found.

   Realm:
      Shared

   Example Usage:
      local ply = lia.util.findPlayerBySteamID64("76561198000000000")
      if ply then
         print("Found player: " .. ply:Name())
      end
]]
function lia.util.findPlayerBySteamID64(SteamID64)
   for _, client in player.Iterator() do
      if client:SteamID64() == SteamID64 then return client end
   end
   return nil
end

--[[
   lia.util.findPlayerBySteamID

   Description:
      Finds a player currently on the server by their SteamID.

   Parameters:
      SteamID (string) — The SteamID to search for (e.g. "STEAM_0:1:23456789").

   Returns:
      Player|nil — The found player or nil if not found.

   Realm:
      Shared

   Example Usage:
      local ply = lia.util.findPlayerBySteamID("STEAM_0:1:23456789")
      if ply then
         print("Found player: " .. ply:Name())
      end
]]
function lia.util.findPlayerBySteamID(SteamID)
   for _, client in player.Iterator() do
      if client:SteamID64() == SteamID then return client end
   end
   return nil
end

--[[
   lia.util.canFit

   Description:
      Checks if a hull (defined by mins and maxs) can fit at the given position without intersecting obstacles.

   Parameters:
      pos (Vector) — The position to test.
      mins (Vector) — The minimum corner of the hull (defaults to Vector(16, 16, 0) if nil).
      maxs (Vector) — The maximum corner of the hull (defaults to same as mins if nil).
      filter (table|Entity|function) — Optional filter for the trace.

   Returns:
      boolean — True if it can fit, false otherwise.

   Realm:
      Shared

   Example Usage:
      local canStand = lia.util.canFit(somePos, Vector(-16, -16, 0), Vector(16, 16, 72))
      if canStand then
         print("The player can stand here.")
      end
]]
function lia.util.canFit(pos, mins, maxs, filter)
   mins = mins ~= nil and mins or Vector(16, 16, 0)
   local tr = util.TraceHull({
      start = pos + Vector(0, 0, 1),
      mask = MASK_PLAYERSOLID,
      filter = filter,
      endpos = pos,
      mins = mins.x > 0 and mins * -1 or mins,
      maxs = maxs ~= nil and maxs or mins
   })
   return not tr.Hit
end

--[[
   lia.util.playerInRadius

   Description:
      Finds and returns a table of players within a given radius from a position.

   Parameters:
      pos (Vector) — The center position.
      dist (number) — The radius to search within.

   Returns:
      table — A table of player entities within the radius.

   Realm:
      Shared

   Example Usage:
      local playersNearby = lia.util.playerInRadius(Vector(0, 0, 0), 250)
      for _, ply in ipairs(playersNearby) do
         print("Nearby player: " .. ply:Name())
      end
]]
function lia.util.playerInRadius(pos, dist)
   dist = dist * dist
   local t = {}
   for _, client in player.Iterator() do
      if IsValid(client) and client:GetPos():DistToSqr(pos) < dist then t[#t + 1] = client end
   end
   return t
end

--[[
   lia.util.formatStringNamed

   Description:
      Formats a string with named or indexed placeholders. If a table is passed, uses named keys. Otherwise uses ordered arguments.

   Parameters:
      format (string) — The format string with placeholders like "{key}".
      ... (vararg|table) — Either a table or vararg arguments to fill placeholders.

   Returns:
      string — The formatted string.

   Realm:
      Shared

   Example Usage:
      local result = lia.util.formatStringNamed("Hello, {name}!", {name = "Bob"})
      print(result) -- "Hello, Bob!"
]]
function lia.util.formatStringNamed(format, ...)
   local arguments = {...}
   local bArray = false
   local input
   if istable(arguments[1]) then
      input = arguments[1]
   else
      input = arguments
      bArray = true
   end

   local i = 0
   local result = format:gsub("{(%w-)}", function(word)
      i = i + 1
      return tostring(bArray and input[i] or input[word] or word)
   end)
   return result
end

--[[
   lia.util.getMaterial

   Description:
      Retrieves a cached Material for the specified path and parameters, to avoid repeated creation.

   Parameters:
      materialPath (string) — The file path to the material.
      materialParameters (string|nil) — Optional material parameters.

   Returns:
      Material — The requested material.

   Realm:
      Shared

   Example Usage:
      local mat = lia.util.getMaterial("path/to/material", "noclamp smooth")
      surface.SetMaterial(mat)
      surface.DrawTexturedRect(0, 0, 100, 100)
]]
function lia.util.getMaterial(materialPath, materialParameters)
   lia.util.cachedMaterials = lia.util.cachedMaterials or {}
   lia.util.cachedMaterials[materialPath] = lia.util.cachedMaterials[materialPath] or Material(materialPath, materialParameters)
   return lia.util.cachedMaterials[materialPath]
end

--[[
   lia.util.findFaction

   Description:
      Finds a faction by name or uniqueID. If an exact identifier is found in lia.faction.teams, returns that. Otherwise checks for partial match.

   Parameters:
      client (Player) — The player requesting the search (used for notifications).
      name (string) — The name or uniqueID of the faction to find.

   Returns:
      table|nil — The found faction table, or nil if not found.

   Realm:
      Shared

   Example Usage:
      local faction = lia.util.findFaction(client, "citizen")
      if faction then
         print("Found faction: " .. faction.name)
      end
]]
function lia.util.findFaction(client, name)
   if lia.faction.teams[name] then return lia.faction.teams[name] end
   for _, v in ipairs(lia.faction.indices) do
      if lia.util.stringMatches(v.name, name) or lia.util.stringMatches(v.uniqueID, name) then return v end
   end

   client:notifyLocalized("invalidFaction")
   return nil
end

if SERVER then
   --[[
       lia.util.CreateTableUI

       Description:
          Sends a net message to the client to create a table UI with given data.

       Parameters:
          client (Player) — The player to whom the UI will be sent.
          title (string) — The title of the table UI.
          columns (table) — The columns of the table.
          data (table) — The row data.
          options (table|nil) — Additional options for the table actions.
          characterID (number|nil) — An optional character ID to pass along.

       Returns:
          nil

       Realm:
          Server

       Example Usage:
          lia.util.CreateTableUI(somePlayer, "My Table", {{name="ID", field="id"}, {name="Name", field="name"}}, someData, someOptions, charID)
    ]]
   function lia.util.CreateTableUI(client, title, columns, data, options, characterID)
      if not IsValid(client) or not client:IsPlayer() then return end
      local tableData = util.Compress(util.TableToJSON({
         title = title or "Table List",
         columns = columns,
         data = data,
         options = options or {},
         characterID = characterID
      }))

      if not tableData then return end
      net.Start("CreateTableUI")
      net.WriteUInt(#tableData, 32)
      net.WriteData(tableData, #tableData)
      net.Send(client)
   end

   --[[
       lia.util.findEmptySpace

       Description:
          Finds potential empty space positions around an entity using a grid-based approach.

       Parameters:
          entity (Entity) — The entity around which to search.
          filter (table|function|Entity) — The filter for the trace or the entity to ignore.
          spacing (number) — The spacing between each point in the grid (default 32).
          size (number) — The grid size in each direction (default 3).
          height (number) — The height of the bounding box (default 36).
          tolerance (number) — The trace tolerance (default 5).

       Returns:
          table — A sorted table of valid positions found.

       Realm:
          Server

       Example Usage:
          local positions = lia.util.findEmptySpace(someEntity, someFilter, 32, 3, 36, 5)
          for _, pos in ipairs(positions) do
             print("Empty space at: " .. tostring(pos))
          end
    ]]
   function lia.util.findEmptySpace(entity, filter, spacing, size, height, tolerance)
      spacing = spacing or 32
      size = size or 3
      height = height or 36
      tolerance = tolerance or 5
      local position = entity:GetPos()
      local mins = Vector(-spacing * 0.5, -spacing * 0.5, 0)
      local maxs = Vector(spacing * 0.5, spacing * 0.5, height)
      local output = {}
      for x = -size, size do
         for y = -size, size do
            local origin = position + Vector(x * spacing, y * spacing, 0)
            local data = {}
            data.start = origin + mins + Vector(0, 0, tolerance)
            data.endpos = origin + maxs
            data.filter = filter or entity
            local trace = util.TraceLine(data)
            data.start = origin + Vector(-maxs.x, -maxs.y, tolerance)
            data.endpos = origin + Vector(mins.x, mins.y, height)
            local trace2 = util.TraceLine(data)
            if trace.StartSolid or trace.Hit or trace2.StartSolid or trace2.Hit or not util.IsInWorld(origin) then continue end
            output[#output + 1] = origin
         end
      end

      table.sort(output, function(a, b) return a:Distance(position) < b:Distance(position) end)
      return output
   end
else
   --[[
       lia.util.ShadowText

       Description:
          Draws text with a shadow offset.

       Parameters:
          text (string) — The text to draw.
          font (string) — The font used.
          x (number) — The x position.
          y (number) — The y position.
          colortext (Color) — The color of the text.
          colorshadow (Color) — The shadow color.
          dist (number) — The distance offset for the shadow.
          xalign (number) — The horizontal alignment (TEXT_ALIGN_*).
          yalign (number) — The vertical alignment (TEXT_ALIGN_*).

       Returns:
          nil

       Realm:
          Client

       Example Usage:
          lia.util.ShadowText("Hello!", "DermaDefault", 100, 100, color_white, color_black, 2, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    ]]
   function lia.util.ShadowText(text, font, x, y, colortext, colorshadow, dist, xalign, yalign)
      surface.SetFont(font)
      local _, h = surface.GetTextSize(text)
      if yalign == TEXT_ALIGN_CENTER then
         y = y - h / 2
      elseif yalign == TEXT_ALIGN_BOTTOM then
         y = y - h
      end

      draw.DrawText(text, font, x + dist, y + dist, colorshadow, xalign)
      draw.DrawText(text, font, x, y, colortext, xalign)
   end

   --[[
       lia.util.DrawTextOutlined

       Description:
          Draws text with an outlined border.

       Parameters:
          text (string) — The text to draw.
          font (string) — The font used.
          x (number) — The x position.
          y (number) — The y position.
          colour (Color) — The text color.
          xalign (number) — The horizontal alignment.
          outlinewidth (number) — The outline thickness.
          outlinecolour (Color) — The outline color.

       Returns:
          nil

       Realm:
          Client

       Example Usage:
          lia.util.DrawTextOutlined("Outlined Text", "DermaLarge", 100, 200, color_white, TEXT_ALIGN_CENTER, 2, color_black)
    ]]
   function lia.util.DrawTextOutlined(text, font, x, y, colour, xalign, outlinewidth, outlinecolour)
      local steps = (outlinewidth * 2) / 3
      if steps < 1 then steps = 1 end
      for _x = -outlinewidth, outlinewidth, steps do
         for _y = -outlinewidth, outlinewidth, steps do
            draw.DrawText(text, font, x + _x, y + _y, outlinecolour, xalign)
         end
      end
      return draw.DrawText(text, font, x, y, colour, xalign)
   end

   --[[
       lia.util.DrawTip

       Description:
          Draws a tooltip-like shape with text in the center.

       Parameters:
          x (number) — The x position.
          y (number) — The y position.
          w (number) — The width of the tip.
          h (number) — The height of the tip.
          text (string) — The text to display.
          font (string) — The font for the text.
          textCol (Color) — The text color.
          outlineCol (Color) — The outline color.

       Returns:
          nil

       Realm:
          Client

       Example Usage:
          lia.util.DrawTip(100, 100, 200, 60, "This is a tip!", "DermaDefault", color_white, color_black)
    ]]
   function lia.util.DrawTip(x, y, w, h, text, font, textCol, outlineCol)
      draw.NoTexture()
      local rectH = 0.85
      local triW = 0.1
      local verts = {
         {
            x = x,
            y = y
         },
         {
            x = x + w,
            y = y
         },
         {
            x = x + w,
            y = y + h * rectH
         },
         {
            x = x + w / 2 + w * triW,
            y = y + h * rectH
         },
         {
            x = x + w / 2,
            y = y + h
         },
         {
            x = x + w / 2 - w * triW,
            y = y + h * rectH
         },
         {
            x = x,
            y = y + h * rectH
         }
      }

      surface.SetDrawColor(outlineCol)
      surface.DrawPoly(verts)
      draw.SimpleText(text, font, x + w / 2, y + h / 2, textCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
   end

   --[[
       lia.util.drawText

       Description:
          Draws text with a subtle shadow effect.

       Parameters:
          text (string) — The text to draw.
          x (number) — The x position.
          y (number) — The y position.
          color (Color) — The text color.
          alignX (number) — Horizontal alignment (TEXT_ALIGN_*).
          alignY (number) — Vertical alignment (TEXT_ALIGN_*).
          font (string) — The font to use (defaults to "liaGenericFont").
          alpha (number) — The shadow alpha multiplier.

       Returns:
          nil

       Realm:
          Client

       Example Usage:
          lia.util.drawText("Hello World", 200, 300, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, "liaGenericFont", 100)
    ]]
   function lia.util.drawText(text, x, y, color, alignX, alignY, font, alpha)
      color = color or color_white
      return draw.TextShadow({
         text = text,
         font = font or "liaGenericFont",
         pos = {x, y},
         color = color,
         xalign = alignX or 0,
         yalign = alignY or 0
      }, 1, alpha or color.a * 0.575)
   end

   --[[
       lia.util.drawTexture

       Description:
          Draws a textured rectangle with the specified material.

       Parameters:
          material (string) — The material path.
          color (Color) — The draw color.
          x (number) — The x position.
          y (number) — The y position.
          w (number) — The width.
          h (number) — The height.

       Returns:
          nil

       Realm:
          Client

       Example Usage:
          lia.util.drawTexture("path/to/material", color_white, 50, 50, 64, 64)
    ]]
   function lia.util.drawTexture(material, color, x, y, w, h)
      surface.SetDrawColor(color or color_white)
      surface.SetMaterial(lia.util.getMaterial(material))
      surface.DrawTexturedRect(x, y, w, h)
   end

   --[[
       lia.util.skinFunc

       Description:
          Calls a skin function by name, passing the panel and any extra arguments.

       Parameters:
          name (string) — The name of the skin function.
          panel (Panel) — The panel to apply the skin function to.
          a, b, c, d, e, f, g — Additional arguments passed to the skin function.

       Returns:
          any — The result of the skin function call, if any.

       Realm:
          Client

       Example Usage:
          lia.util.skinFunc("PaintButton", someButton, 10, 20)
    ]]
   function lia.util.skinFunc(name, panel, a, b, c, d, e, f, g)
      local skin = ispanel(panel) and IsValid(panel) and panel:GetSkin() or derma.GetDefaultSkin()
      if not skin then return end
      local func = skin[name]
      if not func then return end
      return func(skin, panel, a, b, c, d, e, f, g)
   end

   --[[
       lia.util.wrapText

       Description:
          Wraps text to a maximum width, returning a table of lines and the maximum line width found.

       Parameters:
          text (string) — The text to wrap.
          width (number) — The maximum width in pixels.
          font (string) — The font name to use for measuring.

       Returns:
          table, number — A table of wrapped lines and the maximum line width found.

       Realm:
          Client

       Example Usage:
          local lines, maxW = lia.util.wrapText("Some long string that needs wrapping...", 200, "liaChatFont")
          for _, line in ipairs(lines) do
             print(line)
          end
          print("Max width: " .. maxW)
    ]]
   function lia.util.wrapText(text, width, font)
      font = font or "liaChatFont"
      surface.SetFont(font)
      local exploded = string.Explode("%s", text, true)
      local line = ""
      local lines = {}
      local w = surface.GetTextSize(text)
      local maxW = 0
      if w <= width then
         text, _ = text:gsub("%s", " ")
         return {text}, w
      end

      for i = 1, #exploded do
         local word = exploded[i]
         line = line .. " " .. word
         w = surface.GetTextSize(line)
         if w > width then
            lines[#lines + 1] = line
            line = ""
            if w > maxW then maxW = w end
         end
      end

      if line ~= "" then lines[#lines + 1] = line end
      return lines, maxW
   end

   --[[
       lia.util.drawBlur

       Description:
          Draws a blur effect over the specified panel.

       Parameters:
          panel (Panel) — The panel to blur.
          amount (number) — The blur strength.
          passes (number) — The number of passes (optional).

       Returns:
          nil

       Realm:
          Client

       Example Usage:
          lia.util.drawBlur(somePanel, 5, 1)
    ]]
   function lia.util.drawBlur(panel, amount, passes)
      amount = amount or 5
      surface.SetMaterial(lia.util.getMaterial("pp/blurscreen"))
      surface.SetDrawColor(255, 255, 255)
      local x, y = panel:LocalToScreen(0, 0)
      for i = -(passes or 0.2), 1, 0.2 do
         lia.util.getMaterial("pp/blurscreen"):SetFloat("$blur", i * amount)
         lia.util.getMaterial("pp/blurscreen"):Recompute()
         render.UpdateScreenEffectTexture()
         surface.DrawTexturedRect(x * -1, y * -1, ScrW(), ScrH())
      end
   end

   --[[
       lia.util.drawBlurAt

       Description:
          Draws a blur effect at a specified rectangle on the screen.

       Parameters:
          x (number) — The x position.
          y (number) — The y position.
          w (number) — The width of the rectangle.
          h (number) — The height of the rectangle.
          amount (number) — The blur strength.
          passes (number) — The number of passes (optional).

       Returns:
          nil

       Realm:
          Client

       Example Usage:
          lia.util.drawBlurAt(100, 100, 200, 150, 5, 1)
    ]]
   function lia.util.drawBlurAt(x, y, w, h, amount, passes)
      amount = amount or 5
      surface.SetMaterial(lia.util.getMaterial("pp/blurscreen"))
      surface.SetDrawColor(255, 255, 255)
      local x2, y2 = x / ScrW(), y / ScrH()
      local w2, h2 = (x + w) / ScrW(), (y + h) / ScrH()
      for i = -(passes or 0.2), 1, 0.2 do
         lia.util.getMaterial("pp/blurscreen"):SetFloat("$blur", i * amount)
         lia.util.getMaterial("pp/blurscreen"):Recompute()
         render.UpdateScreenEffectTexture()
         surface.DrawTexturedRectUV(x, y, w, h, x2, y2, w2, h2)
      end
   end

   --[[
       lia.util.CreateTableUI

       Description:
          Creates and displays a table UI with given columns and data on the client side.

       Parameters:
          title (string) — The title of the table.
          columns (table) — The columns, each being {name=..., field=..., width=...}.
          data (table) — The row data, each row is a table of field values.
          options (table|nil) — Table of options for right-click actions, each containing {name=..., net=..., ExtraFields=...}.
          charID (number|nil) — Optional character ID.

       Returns:
          nil

       Realm:
          Client

       Example Usage:
          lia.util.CreateTableUI("My Table", {{name="ID", field="id"}, {name="Name", field="name"}}, myData, myOptions, 1)
    ]]
   function lia.util.CreateTableUI(title, columns, data, options, charID)
      local frameWidth, frameHeight = ScrH() * 0.8, ScrH() * 0.8
      local frame = vgui.Create("DFrame")
      frame:SetTitle(title or "Table List")
      frame:SetSize(frameWidth, frameHeight)
      frame:Center()
      frame:MakePopup()
      local listView = vgui.Create("DListView", frame)
      listView:Dock(FILL)
      local totalFixedWidth = 0
      local dynamicColumns = 0
      for _, colInfo in ipairs(columns) do
         if colInfo.width then
            totalFixedWidth = totalFixedWidth + colInfo.width
         else
            dynamicColumns = dynamicColumns + 1
         end
      end

      local availableWidth = frame:GetWide() - totalFixedWidth
      local dynamicWidth = dynamicColumns > 0 and math.max(availableWidth / dynamicColumns, 50) or 0
      for _, colInfo in ipairs(columns) do
         local columnName = colInfo.name or "N/A"
         local columnWidth = colInfo.width or dynamicWidth
         listView:AddColumn(columnName):SetFixedWidth(columnWidth)
      end

      for _, row in ipairs(data) do
         local lineData = {}
         for _, colInfo in ipairs(columns) do
            local fieldName = colInfo.field or "N/A"
            table.insert(lineData, row[fieldName] or "N/A")
         end

         local line = listView:AddLine(unpack(lineData))
         line.rowData = row
      end

      listView.OnRowRightClick = function(_, _, line)
         if not IsValid(line) or not line.rowData then return end
         local rowData = line.rowData
         local menu = DermaMenu()
         menu:AddOption(L("copyRow"), function()
            local rowString = ""
            for key, value in pairs(rowData) do
               value = tostring(value or "N/A")
               rowString = rowString .. key:gsub("^%l", string.upper) .. " " .. value .. " | "
            end

            rowString = rowString:sub(1, -4)
            SetClipboardText(rowString)
         end)

         for _, option in ipairs(istable(options) and options or {}) do
            menu:AddOption(option.name, function()
               if not option.net then return end
               if option.ExtraFields then
                  local inputPanel = vgui.Create("DFrame")
                  inputPanel:SetTitle(option.name .. " Options")
                  inputPanel:SetSize(300, 300 + #table.GetKeys(option.ExtraFields) * 35)
                  inputPanel:Center()
                  inputPanel:MakePopup()
                  local form = vgui.Create("DForm", inputPanel)
                  form:Dock(FILL)
                  form:SetLabel("")
                  form.Paint = function() end
                  local inputs = {}
                  for fName, fType in pairs(option.ExtraFields) do
                     local label = vgui.Create("DLabel", form)
                     label:SetText(fName)
                     label:Dock(TOP)
                     label:DockMargin(5, 10, 5, 0)
                     form:AddItem(label)
                     if isstring(fType) and fType == "text" then
                        local entry = vgui.Create("DTextEntry", form)
                        entry:Dock(TOP)
                        entry:DockMargin(5, 5, 5, 0)
                        entry:SetPlaceholderText("Type " .. fName)
                        form:AddItem(entry)
                        inputs[fName] = {
                           panel = entry,
                           ftype = "text"
                        }
                     elseif isstring(fType) and fType == "combo" then
                        local combo = vgui.Create("DComboBox", form)
                        combo:Dock(TOP)
                        combo:DockMargin(5, 5, 5, 0)
                        combo:SetValue("Select " .. fName)
                        form:AddItem(combo)
                        inputs[fName] = {
                           panel = combo,
                           ftype = "combo"
                        }
                     elseif istable(fType) then
                        local combo = vgui.Create("DComboBox", form)
                        combo:Dock(TOP)
                        combo:DockMargin(5, 5, 5, 0)
                        combo:SetValue("Select " .. fName)
                        for _, choice in ipairs(fType) do
                           combo:AddChoice(choice)
                        end

                        form:AddItem(combo)
                        inputs[fName] = {
                           panel = combo,
                           ftype = "combo"
                        }
                     end
                  end

                  local submitButton = vgui.Create("DButton", form)
                  submitButton:SetText("submit")
                  submitButton:Dock(TOP)
                  submitButton:DockMargin(5, 10, 5, 0)
                  form:AddItem(submitButton)
                  submitButton.DoClick = function()
                     local values = {}
                     for fName, info in pairs(inputs) do
                        if not IsValid(info.panel) then continue end
                        if info.ftype == "text" then
                           values[fName] = info.panel:GetValue() or ""
                        elseif info.ftype == "combo" then
                           values[fName] = info.panel:GetSelected() or ""
                        end
                     end

                     net.Start(option.net)
                     net.WriteInt(charID, 32)
                     net.WriteTable(rowData)
                     for _, fVal in pairs(values) do
                        if isnumber(fVal) then
                           net.WriteInt(fVal, 32)
                        else
                           net.WriteString(fVal)
                        end
                     end

                     net.SendToServer()
                     inputPanel:Close()
                     frame:Remove()
                  end
               else
                  net.Start(option.net)
                  net.WriteInt(charID, 32)
                  net.WriteTable(rowData)
                  net.SendToServer()
                  frame:Remove()
               end
            end)
         end

         menu:Open()
      end
   end
end