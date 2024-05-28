paintedEntitiesCache = {}
local nextUpdate = 0
local lastTrace = {}
local charInfo = {}
local lastEntity
local mathApproach = math.Approach
local vectorMeta = FindMetaTable("Vector")
local toScreen = vectorMeta.ToScreen
local DescWidth = CreateClientConVar("lia_hud_descwidth", 0.5, true, false)
function MODULE:DrawEntityInfo(entity, alpha, position)
    if not entity.IsPlayer(entity) then return end
    if hook.Run("ShouldDrawPlayerInfo", entity) == false then return end
    local character = entity.getChar(entity)
    if not character then return end
    position = position or toScreen(entity.GetPos(entity) + (entity.Crouching(entity) and Vector(0, 0, 48) or Vector(0, 0, 80)))
    local x, y = position.x, position.y
    charInfo = {}
    if entity.widthCache ~= DescWidth:GetFloat() then
        entity.widthCache = DescWidth:GetFloat()
        entity.liaNameCache = nil
        entity.liaDescCache = nil
    end

    entity.liaNameCache = nil
    entity.liaDescCache = nil
    local name = hook.Run("GetDisplayedName", entity, nil) or character.getName(character)
    if name ~= entity.liaNameCache then
        entity.liaNameCache = name
        if name:len() > 250 then name = name:sub(1, 250) .. "..." end
        entity.liaNameLines = lia.util.wrapText(name, ScrW() * entity.widthCache, "liaSmallFont")
    end

    for i = 1, #entity.liaNameLines do
        charInfo[#charInfo + 1] = {entity.liaNameLines[i], team.GetColor(entity.Team(entity))}
    end

    local description = hook.Run("GetDisplayedDescription", entity, true) or character.getDesc(character)
    if description ~= entity.liaDescCache then
        entity.liaDescCache = description
        if description:len() > 250 then description = description:sub(1, 250) .. "..." end
        entity.liaDescLines = lia.util.wrapText(description, ScrW() * entity.widthCache, "liaSmallFont")
    end

    for i = 1, #entity.liaDescLines do
        charInfo[#charInfo + 1] = {entity.liaDescLines[i]}
    end

    hook.Run("DrawCharInfo", entity, character, charInfo)
    for i = 1, #charInfo do
        local info = charInfo[i]
        _, ty = lia.util.drawText(info[1]:gsub("#", "\226\128\139#"), x, y, ColorAlpha(info[2] or color_white, alpha), 1, 1, "liaSmallFont")
        y = y + ty
    end
end

function MODULE:SetupQuickMenu(menu)
    menu:addSlider("HUD Desc Width Modifier", function(_, value) DescWidth:SetFloat(value) end, DescWidth:GetFloat(), 0.1, 1, 2)
    menu:addSpacer()
end

function MODULE:RenderEntities()
    local client = LocalPlayer()
    if client.getChar(client) then
        local frameTime = FrameTime()
        local currentTime = RealTime()
        if nextUpdate < currentTime then
            nextUpdate = currentTime + 0.5
            lastTrace.start = client.GetShootPos(client)
            lastTrace.endpos = lastTrace.start + client:GetAimVector() * 160
            lastTrace.filter = client
            lastTrace.mins = Vector(-4, -4, -4)
            lastTrace.maxs = Vector(4, 4, 4)
            lastTrace.mask = MASK_SHOT_HULL
            lastEntity = util.TraceHull(lastTrace).Entity
            if IsValid(lastEntity) and hook.Run("ShouldDrawEntityInfo", lastEntity) then paintedEntitiesCache[lastEntity] = true end
        end

        for entity, drawing in pairs(paintedEntitiesCache) do
            local isValidEntity = IsValid(entity)
            if isValidEntity then
                local goal = drawing and 255 or 0
                local alpha = mathApproach(entity.liaAlpha or 0, goal, frameTime * 1000)
                if lastEntity ~= entity then paintedEntitiesCache[entity] = false end
                if alpha > 0 then
                    local targetent = entity.getNetVar(entity, "player")
                    if IsValid(targetent) then
                        local position = toScreen(entity.LocalToWorld(entity, entity.OBBCenter(entity)))
                        hook.Run("DrawEntityInfo", targetent, alpha, position)
                    elseif entity.onDrawEntityInfo then
                        entity.onDrawEntityInfo(entity, alpha)
                    else
                        hook.Run("DrawEntityInfo", entity, alpha)
                    end
                end

                entity.liaAlpha = alpha
                if alpha == 0 and goal == 0 then paintedEntitiesCache[entity] = nil end
            elseif isValidEntity == nil then
                paintedEntitiesCache[entity] = nil
            end
        end
    end
end

function MODULE:ShouldDrawEntityInfo(entity)
    if IsValid(entity) then
        if entity:IsPlayer() and entity:getChar() then
            if entity:IsNoClipping() then return false end
            if entity:GetNoDraw() then return false end
            return true
        end

        if IsValid(entity:getNetVar("player")) then return entity == LocalPlayer() and not LocalPlayer():ShouldDrawLocalPlayer() end
        if entity.DrawEntityInfo then return true end
        if entity.onShouldDrawEntityInfo then return entity:onShouldDrawEntityInfo() end
        return true
    end
    return false
end