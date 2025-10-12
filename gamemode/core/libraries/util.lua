function lia.util.findPlayersInBox(mins, maxs)
    local entsList = ents.FindInBox(mins, maxs)
    local plyList = {}
    for _, v in pairs(entsList) do
        if IsValid(v) and v:IsPlayer() then plyList[#plyList + 1] = v end
    end
    return plyList
end

function lia.util.getBySteamID(steamID)
    if not isstring(steamID) or steamID == "" then return end
    local sid = steamID
    if steamID:match("^%d+$") and #steamID >= 17 then sid = util.SteamIDFrom64(steamID) end
    for _, client in player.Iterator() do
        if client:SteamID() == sid and client:getChar() then return client end
    end
end

function lia.util.findPlayersInSphere(origin, radius)
    local plys = {}
    local r2 = radius ^ 2
    for _, client in player.Iterator() do
        if client:GetPos():DistToSqr(origin) <= r2 then plys[#plys + 1] = client end
    end
    return plys
end

function lia.util.findPlayer(client, identifier)
    local isValidClient = IsValid(client)
    if not isstring(identifier) or identifier == "" then
        if isValidClient then client:notifyErrorLocalized("mustProvideString") end
        return nil
    end

    if string.match(identifier, "^STEAM_%d+:%d+:%d+$") then
        local ply = lia.util.getBySteamID(identifier)
        if IsValid(ply) then return ply end
        if isValidClient then client:notifyErrorLocalized("plyNoExist") end
        return nil
    end

    if string.match(identifier, "^%d+$") and #identifier >= 17 then
        local sid = util.SteamIDFrom64(identifier)
        if sid then
            local ply = lia.util.getBySteamID(sid)
            if IsValid(ply) then return ply end
        end

        if isValidClient then client:notifyErrorLocalized("plyNoExist") end
        return nil
    end

    if isValidClient and identifier == "^" then return client end
    if isValidClient and identifier == "@" then
        local trace = client:getTracedEntity()
        if IsValid(trace) and trace:IsPlayer() then return trace end
        client:notifyErrorLocalized("lookToUseAt")
        return nil
    end

    local safe = string.PatternSafe(identifier)
    for _, ply in player.Iterator() do
        if lia.util.stringMatches(ply:Name(), safe) then return ply end
    end

    if isValidClient then client:notifyErrorLocalized("plyNoExist") end
    return nil
end

function lia.util.findPlayerItems(client)
    local items = {}
    for _, item in ents.Iterator() do
        if IsValid(item) and item:isItem() and item:GetCreator() == client then table.insert(items, item) end
    end
    return items
end

function lia.util.findPlayerItemsByClass(client, class)
    local items = {}
    for _, item in ents.Iterator() do
        if IsValid(item) and item:isItem() and item:GetCreator() == client and item:getNetVar("id") == class then table.insert(items, item) end
    end
    return items
end

function lia.util.findPlayerEntities(client, class)
    local entities = {}
    for _, entity in ents.Iterator() do
        if IsValid(entity) and (not class or entity:GetClass() == class) and (entity:GetCreator() == client or entity.client and entity.client == client) then table.insert(entities, entity) end
    end
    return entities
end

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

function lia.util.getAdmins()
    local staff = {}
    for _, client in player.Iterator() do
        local hasPermission = client:isStaff()
        if hasPermission then staff[#staff + 1] = client end
    end
    return staff
end

function lia.util.findPlayerBySteamID64(SteamID64)
    local SteamID = util.SteamIDFrom64(SteamID64)
    if not SteamID then return nil end
    return lia.util.findPlayerBySteamID(SteamID)
end

function lia.util.findPlayerBySteamID(SteamID)
    for _, client in player.Iterator() do
        if client:SteamID() == SteamID then return client end
    end
    return nil
end

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

function lia.util.playerInRadius(pos, dist)
    dist = dist * dist
    local t = {}
    for _, client in player.Iterator() do
        if IsValid(client) and client:GetPos():DistToSqr(pos) < dist then t[#t + 1] = client end
    end
    return t
end

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

function lia.util.getMaterial(materialPath, materialParameters)
    lia.util.cachedMaterials = lia.util.cachedMaterials or {}
    lia.util.cachedMaterials[materialPath] = lia.util.cachedMaterials[materialPath] or Material(materialPath, materialParameters)
    return lia.util.cachedMaterials[materialPath]
end

function lia.util.findFaction(client, name)
    if lia.faction.teams[name] then return lia.faction.teams[name] end
    for _, v in ipairs(lia.faction.indices) do
        if lia.util.stringMatches(v.name, name) or lia.util.stringMatches(v.uniqueID, name) then return v end
    end

    client:notifyErrorLocalized("invalidFaction")
    return nil
end

if system.IsLinux() then
    local cache = {}
    local function GetSoundPath(path, gamedir)
        if not gamedir then
            path = "sound/" .. path
            gamedir = "GAME"
        end
        return path, gamedir
    end

    local function f_IsWAV(f)
        f:Seek(8)
        return f:Read(4) == "WAVE"
    end

    local function f_SampleDepth(f)
        f:Seek(34)
        local bytes = {}
        for i = 1, 2 do
            bytes[i] = f:ReadByte(1)
        end

        local num = bit.lshift(bytes[2], 8) + bit.lshift(bytes[1], 0)
        return num
    end

    local function f_SampleRate(f)
        f:Seek(24)
        local bytes = {}
        for i = 1, 4 do
            bytes[i] = f:ReadByte(1)
        end

        local num = bit.lshift(bytes[4], 24) + bit.lshift(bytes[3], 16) + bit.lshift(bytes[2], 8) + bit.lshift(bytes[1], 0)
        return num
    end

    local function f_Channels(f)
        f:Seek(22)
        local bytes = {}
        for i = 1, 2 do
            bytes[i] = f:ReadByte(1)
        end

        local num = bit.lshift(bytes[2], 8) + bit.lshift(bytes[1], 0)
        return num
    end

    local function f_Duration(f)
        return (f:Size() - 44) / (f_SampleDepth(f) / 8 * f_SampleRate(f) * f_Channels(f))
    end

    liaSoundDuration = liaSoundDuration or SoundDuration
    function SoundDuration(str)
        local path, gamedir = GetSoundPath(str)
        local f = file.Open(path, "rb", gamedir)
        if not f then return 0 end
        local ret
        if cache[str] then
            ret = cache[str]
        elseif f_IsWAV(f) then
            ret = f_Duration(f)
        else
            ret = liaSoundDuration(str)
        end

        f:Close()
        return ret
    end
end

function lia.util.generateRandomName(firstNames, lastNames)
    local defaultFirstNames = {"John", "Jane", "Michael", "Sarah", "David", "Emily", "Robert", "Amanda", "James", "Jennifer", "William", "Elizabeth", "Richard", "Michelle", "Thomas", "Lisa", "Daniel", "Stephanie", "Matthew", "Nicole", "Anthony", "Samantha", "Charles", "Mary", "Joseph", "Patricia", "Christopher", "Linda", "Andrew", "Barbara", "Joshua", "Susan", "Ryan", "Jessica", "Brandon", "Helen", "Tyler", "Nancy", "Kevin", "Betty", "Jason", "Sandra", "Jacob", "Donna", "Kyle", "Carol", "Nathan", "Ruth", "Jeffrey", "Sharon", "Frank", "Michelle", "Scott", "Laura", "Steven", "Sarah", "Nicholas", "Kimberly", "Gregory", "Deborah", "Eric", "Dorothy", "Stephen", "Amy", "Timothy", "Angela", "Larry", "Melissa", "Jonathan", "Brenda", "Raymond", "Emma", "Patrick", "Anna", "Benjamin", "Rebecca", "Bryan", "Virginia", "Samuel", "Kathleen", "Alexander", "Pamela", "Jack", "Martha", "Dennis", "Debra", "Jerry", "Amanda", "Tyler", "Stephanie", "Aaron", "Christine", "Henry", "Marie", "Douglas", "Janet", "Peter", "Catherine", "Jose", "Frances", "Adam", "Ann", "Zachary", "Joyce", "Walter", "Diane", "Kenneth", "Alice", "Ryan", "Julie", "Gregory", "Heather", "Austin", "Teresa", "Keith", "Doris", "Samuel", "Gloria", "Gary", "Evelyn", "Jesse", "Jean", "Joe", "Cheryl", "Billy", "Mildred", "Bruce", "Katherine", "Gabriel", "Joan", "Roy", "Ashley", "Albert", "Judith", "Willie", "Rose", "Logan", "Janice", "Randy", "Kelly", "Louis", "Nicole", "Russell", "Judy", "Ralph", "Christina", "Sean", "Kathy", "Eugene", "Theresa", "Vincent", "Beverly", "Bobby", "Denise", "Johnny", "Tammy", "Bradley", "Irene", "Philip", "Jane", "Todd", "Lori", "Jesse", "Rachel", "Craig", "Marilyn", "Alan", "Andrea", "Shawn", "Kathryn", "Clarence", "Louise", "Sean", "Sara", "Victor", "Anne", "Jimmy", "Jacqueline", "Chad", "Wanda", "Phillip", "Bonnie", "Travis", "Julia", "Carlos", "Ruby", "Shane", "Lois", "Ronald", "Tina", "Brandon", "Phyllis", "Angel", "Norma", "Russell", "Paula", "Harold", "Diana", "Dustin", "Annie", "Pedro", "Lillian", "Shawn", "Emily", "Colin", "Robin", "Brian", "Rita"}
    local defaultLastNames = {"Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller", "Davis", "Rodriguez", "Martinez", "Hernandez", "Lopez", "Gonzalez", "Wilson", "Anderson", "Thomas", "Taylor", "Moore", "Jackson", "Martin", "Lee", "Perez", "Thompson", "White", "Harris", "Sanchez", "Clark", "Ramirez", "Lewis", "Robinson", "Walker", "Young", "Allen", "King", "Wright", "Scott", "Torres", "Nguyen", "Hill", "Flores", "Green", "Adams", "Nelson", "Baker", "Hall", "Rivera", "Campbell", "Mitchell", "Carter", "Roberts", "Gomez", "Phillips", "Evans", "Turner", "Diaz", "Parker", "Cruz", "Edwards", "Collins", "Reyes", "Stewart", "Morris", "Morales", "Murphy", "Cook", "Rogers", "Gutierrez", "Ortiz", "Morgan", "Cooper", "Peterson", "Bailey", "Reed", "Kelly", "Howard", "Ramos", "Kim", "Cox", "Ward", "Richardson", "Watson", "Brooks", "Chavez", "Wood", "James", "Bennett", "Gray", "Mendoza", "Ruiz", "Hughes", "Price", "Alvarez", "Castillo", "Sanders", "Patel", "Myers", "Long", "Ross", "Foster", "Jimenez", "Powell", "Jenkins", "Perry", "Russell", "Sullivan", "Bell", "Coleman", "Butler", "Henderson", "Barnes", "Gonzales", "Fisher", "Vasquez", "Simmons", "Romero", "Jordan", "Patterson", "Alexander", "Hamilton", "Graham", "Reynolds", "Griffin", "Wallace", "Moreno", "West", "Cole", "Hayes", "Bryant", "Herrera", "Gibson", "Ellis", "Tran", "Medina", "Aguilar", "Stevens", "Murray", "Ford", "Castro", "Marshall", "Owens", "Harrison", "Fernandez", "McDonald", "Woods", "Washington", "Kennedy", "Wells", "Vargas", "Henry", "Chen", "Freeman", "Webb", "Tucker", "Guzman", "Burns", "Crawford", "Olson", "Simpson", "Porter", "Hunter", "Gordon", "Mendez", "Silva", "Shaw", "Snyder", "Mason", "Dixon", "Munoz", "Hunt", "Hicks", "Holmes", "Palmer", "Wagner", "Black", "Robertson", "Boyd", "Rose", "Stone", "Salazar", "Fox", "Warren", "Mills", "Meyer", "Rice", "Schmidt", "Garza", "Daniels", "Ferguson", "Nichols", "Stephens", "Soto", "Weaver", "Ryan", "Gardner", "Payne", "Grant", "Dunn", "Kelley", "Spencer", "Hawkins", "Arnold", "Pierce", "Vazquez", "Hansen", "Peters", "Santos", "Hart", "Bradley", "Knight", "Elliott", "Cunningham", "Duncan", "Armstrong", "Hudson", "Carroll", "Lane", "Riley", "Andrews", "Alvarado", "Ray", "Delgado", "Berry", "Perkins", "Hoffman", "Johnston", "Matthews", "Pena", "Richards", "Contreras", "Willis", "Carpenter", "Lawrence", "Sandoval"}
    local firstNameList = firstNames or defaultFirstNames
    local lastNameList = lastNames or defaultLastNames
    if not istable(firstNameList) or #firstNameList == 0 then firstNameList = defaultFirstNames end
    if not istable(lastNameList) or #lastNameList == 0 then lastNameList = defaultLastNames end
    local firstIndex = math.random(1, #firstNameList)
    local lastIndex = math.random(1, #lastNameList)
    return firstNameList[firstIndex] .. " " .. lastNameList[lastIndex]
end

if SERVER then
    function lia.util.SendTableUI(client, title, columns, data, options, characterID)
        if not IsValid(client) or not client:IsPlayer() then return end
        local localizedColumns = {}
        for i, colInfo in ipairs(columns or {}) do
            local localizedColInfo = table.Copy(colInfo)
            if localizedColInfo.name then localizedColInfo.name = L(localizedColInfo.name) end
            localizedColumns[i] = localizedColInfo
        end

        local tableUIData = {
            title = title and L(title) or L("tableListTitle"),
            columns = localizedColumns,
            data = data,
            options = options or {},
            characterID = characterID
        }

        lia.net.writeBigTable(client, "liaSendTableUI", tableUIData)
    end

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
    lia.util.ShadowText = lia.derma.ShadowText
    lia.util.DrawTextOutlined = lia.derma.DrawTextOutlined
    lia.util.DrawTip = lia.derma.DrawTip
    lia.util.drawText = lia.derma.drawText
    lia.util.drawTexture = lia.derma.drawSurfaceTexture
    lia.util.skinFunc = lia.derma.skinFunc
    lia.util.approachExp = lia.derma.approachExp
    lia.util.easeOutCubic = lia.derma.easeOutCubic
    lia.util.easeInOutCubic = lia.derma.easeInOutCubic
    function lia.util.animateAppearance(panel, target_w, target_h, duration, alpha_dur, callback, scale_factor)
        local scaleFactor = 0.8
        if not IsValid(panel) then return end
        duration = (duration and duration > 0) and duration or 0.18
        alpha_dur = (alpha_dur and alpha_dur > 0) and alpha_dur or duration
        local targetX, targetY = panel:GetPos()
        local initialW = target_w * (scale_factor and scale_factor or scaleFactor)
        local initialH = target_h * (scale_factor and scale_factor or scaleFactor)
        local initialX = targetX + (target_w - initialW) / 2
        local initialY = targetY + (target_h - initialH) / 2
        panel:SetSize(initialW, initialH)
        panel:SetPos(initialX, initialY)
        panel:SetAlpha(0)
        local curW, curH = initialW, initialH
        local curX, curY = initialX, initialY
        local curA = 0
        local eps = 0.5
        local alpha_eps = 1
        local speedSize = 3 / math.max(0.0001, duration)
        local speedAlpha = 3 / math.max(0.0001, alpha_dur)
        panel.Think = function()
            if not IsValid(panel) then return end
            local dt = FrameTime()
            curW = lia.util.approachExp(curW, target_w, speedSize, dt)
            curH = lia.util.approachExp(curH, target_h, speedSize, dt)
            curX = lia.util.approachExp(curX, targetX, speedSize, dt)
            curY = lia.util.approachExp(curY, targetY, speedSize, dt)
            curA = lia.util.approachExp(curA, 255, speedAlpha, dt)
            panel:SetSize(curW, curH)
            panel:SetPos(curX, curY)
            panel:SetAlpha(math.floor(curA + 0.5))
            local doneSize = math.abs(curW - target_w) <= eps and math.abs(curH - target_h) <= eps
            local donePos = math.abs(curX - targetX) <= eps and math.abs(curY - targetY) <= eps
            local doneAlpha = math.abs(curA - 255) <= alpha_eps
            if doneSize and donePos and doneAlpha then
                panel:SetSize(target_w, target_h)
                panel:SetPos(targetX, targetY)
                panel:SetAlpha(255)
                panel.Think = nil
                if callback then callback(panel) end
            end
        end
    end

    function lia.util.clampMenuPosition(panel)
        if not IsValid(panel) then return end
        local x, y = panel:GetPos()
        local w, h = panel:GetSize()
        local sw, sh = ScrW(), ScrH()
        local logoMargin = 0
        if IsValid(lia.gui.character) and IsValid(lia.gui.character.logo) then
            local logoX, logoY = lia.gui.character.logo:GetPos()
            local logoW, logoH = lia.gui.character.logo:GetSize()
            local logoRight = logoX + logoW
            local logoBottom = logoY + logoH
            if x < logoRight and x + w > logoX and y < logoBottom and y + h > logoY then logoMargin = logoH + (ScrH() * 0.01) end
        end

        if x < 5 then
            x = 5
        elseif x + w > sw - 5 then
            x = sw - 5 - w
        end

        if y < 5 then
            y = 5
        elseif y + h > sh - 5 then
            y = sh - 5 - h
        end

        if logoMargin > 0 and y < logoMargin then y = logoMargin end
        panel:SetPos(x, y)
    end

    function lia.util.drawGradient(_x, _y, _w, _h, direction, color_shadow, radius, flags)
        local listGradients = {Material("vgui/gradient_up"), Material("vgui/gradient_down"), Material("vgui/gradient-l"), Material("vgui/gradient-r")}
        radius = radius and radius or 0
        lia.derma.drawMaterial(radius, _x, _y, _w, _h, color_shadow, listGradients[direction], flags)
    end

    function lia.util.wrapText(text, width, font)
        font = font or "LiliaFont.16"
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

    function lia.util.drawBlur(panel, amount, passes, alpha)
        amount = amount or 5
        alpha = alpha or 255
        surface.SetMaterial(lia.util.getMaterial("pp/blurscreen"))
        surface.SetDrawColor(255, 255, 255, alpha)
        local x, y = panel:LocalToScreen(0, 0)
        for i = -(passes or 0.2), 1, 0.2 do
            lia.util.getMaterial("pp/blurscreen"):SetFloat("$blur", i * amount)
            lia.util.getMaterial("pp/blurscreen"):Recompute()
            render.UpdateScreenEffectTexture()
            surface.DrawTexturedRect(x * -1, y * -1, ScrW(), ScrH())
        end
    end

    function lia.util.drawBlackBlur(panel, amount, passes, alpha, darkAlpha)
        if not IsValid(panel) then return end
        amount = amount or 6
        passes = math.max(1, passes or 5)
        alpha = alpha or 255
        darkAlpha = darkAlpha or 220
        local mat = lia.util.getMaterial("pp/blurscreen")
        local x, y = panel:LocalToScreen(0, 0)
        x = math.floor(x)
        y = math.floor(y)
        local sw, sh = ScrW(), ScrH()
        local expand = 4
        render.UpdateScreenEffectTexture()
        surface.SetMaterial(mat)
        surface.SetDrawColor(255, 255, 255, alpha)
        for i = 1, passes do
            mat:SetFloat("$blur", i / passes * amount)
            mat:Recompute()
            surface.DrawTexturedRectUV(-x - expand, -y - expand, sw + expand * 2, sh + expand * 2, 0, 0, 1, 1)
        end

        surface.SetDrawColor(0, 0, 0, darkAlpha)
        surface.DrawRect(x, y, panel:GetWide(), panel:GetTall())
    end

    function lia.util.drawBlurAt(x, y, w, h, amount, passes, alpha)
        amount = amount or 5
        alpha = alpha or 255
        surface.SetMaterial(lia.util.getMaterial("pp/blurscreen"))
        surface.SetDrawColor(255, 255, 255, alpha)
        local x2, y2 = x / ScrW(), y / ScrH()
        local w2, h2 = (x + w) / ScrW(), (y + h) / ScrH()
        for i = -(passes or 0.2), 1, 0.2 do
            lia.util.getMaterial("pp/blurscreen"):SetFloat("$blur", i * amount)
            lia.util.getMaterial("pp/blurscreen"):Recompute()
            render.UpdateScreenEffectTexture()
            surface.DrawTexturedRectUV(x, y, w, h, x2, y2, w2, h2)
        end
    end

    lia.util.requestArguments = lia.derma.requestArguments
    function lia.util.CreateTableUI(title, columns, data, options, charID)
        local frameWidth, frameHeight = ScrW() * 0.8, ScrH() * 0.8
        local frame = vgui.Create("DFrame")
        frame:SetTitle(title and L(title) or L("tableListTitle"))
        frame:SetSize(frameWidth, frameHeight)
        frame:Center()
        frame:MakePopup()
        frame:ShowCloseButton(true)
        frame.Paint = function(self, w, h)
            lia.util.drawBlur(self, 4)
            draw.RoundedBox(0, 0, 0, w, h, Color(20, 20, 20, 120))
        end

        local listView = frame:Add("liaTable")
        listView:Dock(FILL)
        for _, colInfo in ipairs(columns or {}) do
            local localizedName = colInfo.name and L(colInfo.name) or L("na")
            listView:AddColumn(localizedName, colInfo.width, colInfo.align, colInfo.sortable)
        end

        for _, row in ipairs(data) do
            local lineData = {}
            for _, colInfo in ipairs(columns) do
                table.insert(lineData, row[colInfo.field] or L("na"))
            end

            local line = listView:AddLine(unpack(lineData))
            line.rowData = row
        end

        listView:AddMenuOption(L("copyRow"), function(rowData)
            local rowString = ""
            for key, value in pairs(rowData) do
                value = tostring(value or L("na"))
                key = tostring(key)
                rowString = rowString .. key:gsub("^%l", string.upper) .. " " .. value .. " | "
            end

            rowString = rowString:sub(1, -4)
            SetClipboardText(rowString)
        end)

        for _, option in ipairs(istable(options) and options or {}) do
            listView:AddMenuOption(option.name and L(option.name) or option.name, function()
                if not option.net then return end
                if option.ExtraFields then
                    local inputPanel = vgui.Create("DFrame")
                    inputPanel:SetTitle(L("optionsTitle", option.name))
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
                            entry:SetPlaceholderText(L("typeFieldPrompt", fName))
                            form:AddItem(entry)
                            inputs[fName] = {
                                panel = entry,
                                ftype = "text"
                            }
                        elseif isstring(fType) and fType == "combo" then
                            local combo = vgui.Create("liaComboBox", form)
                            combo:Dock(TOP)
                            combo:DockMargin(5, 5, 5, 0)
                            combo:PostInit()
                            combo:SetValue(L("selectPrompt", fName))
                            form:AddItem(combo)
                            inputs[fName] = {
                                panel = combo,
                                ftype = "combo"
                            }
                        elseif istable(fType) then
                            local combo = vgui.Create("liaComboBox", form)
                            combo:Dock(TOP)
                            combo:DockMargin(5, 5, 5, 0)
                            combo:PostInit()
                            combo:SetValue(L("selectPrompt", fName))
                            for _, choice in ipairs(fType) do
                                combo:AddChoice(choice)
                            end

                            combo:FinishAddingOptions()
                            form:AddItem(combo)
                            inputs[fName] = {
                                panel = combo,
                                ftype = "combo"
                            }
                        end
                    end

                    local submitButton = vgui.Create("DButton", form)
                    submitButton:SetText(L("submit"))
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
                        net.WriteTable(listView.rows[rowIndex])
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
                    net.WriteTable(listView.rows[rowIndex])
                    net.SendToServer()
                    frame:Remove()
                end
            end)
        end

        timer.Simple(0.1, function()
            if IsValid(frame) and IsValid(listView) then
                frame:InvalidateLayout(true)
                listView:InvalidateLayout(true)
                frame:SizeToChildren(false, true)
            end
        end)
        return frame, listView
    end

    function lia.util.openOptionsMenu(title, options)
        if not istable(options) then return end
        local entries = {}
        if options[1] then
            for _, opt in ipairs(options) do
                if isstring(opt.name) and isfunction(opt.callback) then entries[#entries + 1] = opt end
            end
        else
            for name, callback in pairs(options) do
                if isfunction(callback) then
                    entries[#entries + 1] = {
                        name = name,
                        callback = callback
                    }
                end
            end
        end

        if #entries == 0 then return end
        local frameW, entryH = 300, 30
        local frameH = entryH * #entries + 50
        local frame = vgui.Create("DFrame")
        frame:SetSize(frameW, frameH)
        frame:Center()
        frame:MakePopup()
        frame:SetTitle("")
        frame:ShowCloseButton(true)
        frame.Paint = function(self, w, h)
            lia.util.drawBlur(self, 4)
            draw.RoundedBox(0, 0, 0, w, h, Color(20, 20, 20, 120))
        end

        local titleLabel = frame:Add("DLabel")
        titleLabel:SetPos(0, 8)
        titleLabel:SetSize(frameW, 20)
        titleLabel:SetText(L(title or "options"))
        titleLabel:SetFont("liaSmallFont")
        titleLabel:SetColor(color_white)
        titleLabel:SetContentAlignment(5)
        local layout = frame:Add("DListLayout")
        layout:Dock(FILL)
        layout:DockMargin(10, 32, 10, 10)
        for _, opt in ipairs(entries) do
            local btn = layout:Add("DButton")
            btn:SetTall(entryH)
            btn:Dock(TOP)
            btn:DockMargin(0, 0, 0, 5)
            btn:SetText(L(opt.name))
            btn:SetFont("liaSmallFont")
            btn:SetTextColor(color_white)
            btn:SetContentAlignment(5)
            btn.Paint = function(self, w, h)
                if self:IsHovered() then
                    draw.RoundedBox(4, 0, 0, w, h, Color(30, 30, 30, 160))
                else
                    draw.RoundedBox(4, 0, 0, w, h, Color(30, 30, 30, 100))
                end
            end

            btn.DoClick = function()
                frame:Close()
                opt.callback()
            end
        end
        return frame
    end

    local vectorMeta = FindMetaTable("Vector")
    local toScreen = vectorMeta and vectorMeta.ToScreen or function()
        return {
            x = 0,
            y = 0,
            visible = false
        }
    end

    local defaultTheme = {
        background_alpha = Color(34, 34, 34, 210),
        header = Color(34, 34, 34, 210),
        accent = Color(255, 255, 255, 180),
        text = Color(255, 255, 255)
    }

    local function scaleColorAlpha(col, scale)
        col = col or defaultTheme.background_alpha
        local a = col.a or 255
        return Color(col.r, col.g, col.b, math.Clamp(a * scale, 0, 255))
    end

    local function EntText(text, x, y, fade)
        surface.SetFont("LiliaFont.40")
        local tw, th = surface.GetTextSize(text)
        local bx, by = math.Round(x - tw * 0.5 - 18), math.Round(y - 12)
        local bw, bh = tw + 36, th + 24
        local theme = lia.color.theme or defaultTheme
        local fadeAlpha = math.Clamp(fade, 0, 1)
        local headerColor = scaleColorAlpha(theme.background_panelpopup or theme.header or defaultTheme.header, fadeAlpha)
        local accentColor = scaleColorAlpha(theme.theme or theme.text or defaultTheme.accent, fadeAlpha)
        local textColor = scaleColorAlpha(theme.text or defaultTheme.text, fadeAlpha)
        lia.util.drawBlurAt(bx, by, bw, bh - 6, 6, 0.2, math.floor(fadeAlpha * 255))
        lia.derma.rect(bx, by, bw, bh - 6):Radii(16, 16, 0, 0):Color(headerColor):Shape(lia.derma.SHAPE_IOS):Draw()
        lia.derma.rect(bx, by + bh - 6, bw, 6):Radii(0, 0, 16, 16):Color(accentColor):Draw()
        draw.SimpleText(text, "LiliaFont.40", math.Round(x), math.Round(y - 2), textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        return bh
    end

    lia.util.entsScales = lia.util.entsScales or {}
    function lia.util.drawEntText(ent, text, posY, alphaOverride)
        if not (IsValid(ent) and text and text ~= "") then return end
        posY = posY or 0
        local distSqr = EyePos():DistToSqr(ent:GetPos())
        local maxDist = 380
        if distSqr > maxDist * maxDist then return end
        local dist = math.sqrt(distSqr)
        local minDist = 20
        local idx = ent:EntIndex()
        local prev = lia.util.entsScales[idx] or 0
        local normalized = math.Clamp((maxDist - dist) / math.max(1, maxDist - minDist), 0, 1)
        local appearThreshold = 0.8
        local disappearThreshold = 0.01
        local target
        if normalized <= disappearThreshold then
            target = 0
        elseif normalized >= appearThreshold then
            target = 1
        else
            target = (normalized - disappearThreshold) / (appearThreshold - disappearThreshold)
        end

        local dt = FrameTime() or 0.016
        local appearSpeed = 18
        local disappearSpeed = 12
        local speed = (target > prev) and appearSpeed or disappearSpeed
        local cur = lia.util.approachExp(prev, target, speed, dt)
        if math.abs(cur - target) < 0.0005 then cur = target end
        if cur == 0 and target == 0 then
            lia.util.entsScales[idx] = nil
            return
        end

        lia.util.entsScales[idx] = cur
        local eased = lia.util.easeInOutCubic(cur)
        if eased <= 0 then return end
        local fade = eased
        if alphaOverride then
            if alphaOverride > 1 then
                fade = fade * math.Clamp(alphaOverride / 255, 0, 1)
            else
                fade = fade * math.Clamp(alphaOverride, 0, 1)
            end
        end

        if fade <= 0 then return end
        local mins, maxs = ent:OBBMins(), ent:OBBMaxs()
        local _, rotatedMax = ent:GetRotatedAABB(mins, maxs)
        local bob = math.sin(CurTime() + idx) / 3 + 0.5
        local center = ent:LocalToWorld(ent:OBBCenter()) + Vector(0, 0, math.abs(rotatedMax.z / 2) + 12 + bob)
        local screenPos = toScreen(center)
        if screenPos.visible == false then return end
        EntText(text, screenPos.x, screenPos.y + posY, fade)
    end
end
