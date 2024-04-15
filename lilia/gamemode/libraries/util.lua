lia.util.cachedMaterials = lia.util.cachedMaterials or {}

function lia.util.isSteamID(value)
    if string.match(value, "STEAM_(%d+):(%d+):(%d+)") then return true end
    return false
end

function lia.util.dateToNumber(str)
    str = str or os.date("%Y-%m-%d %H:%M:%S", os.time())
    return {
        year = tonumber(str:sub(1, 4)),
        month = tonumber(str:sub(6, 7)),
        day = tonumber(str:sub(9, 10)),
        hour = tonumber(str:sub(12, 13)),
        min = tonumber(str:sub(15, 16)),
        sec = tonumber(str:sub(18, 19)),
    }
end

function lia.util.findPlayer(identifier, allowPatterns)
    if lia.util.isSteamID(identifier) then return player.GetBySteamID(identifier) end
    if not allowPatterns then identifier = string.PatternSafe(identifier) end
    for _, v in ipairs(player.GetAll()) do
        if lia.util.stringMatches(v:Name(), identifier) then return v end
    end
end

function lia.util.gridVector(vec, gridSize)
    if gridSize <= 0 then gridSize = 1 end
    for i = 1, 3 do
        vec[i] = vec[i] / gridSize
        vec[i] = math.Round(vec[i])
        vec[i] = vec[i] * gridSize
    end
    return vec
end

function lia.util.getAllChar()
    local charTable = {}
    for _, v in ipairs(player.GetAll()) do
        if v:getChar() then table.insert(charTable, v:getChar():getID()) end
    end
    return charTable
end

function lia.util.emitQueuedSounds(entity, sounds, delay, spacing, volume, pitch)
    delay = delay or 0
    spacing = spacing or 0.1
    for _, v in ipairs(sounds) do
        local postSet, preSet = 0, 0
        if istable(v) then
            postSet, preSet = v[2] or 0, v[3] or 0
            v = v[1]
        end

        local length = SoundDuration(SoundDuration("npc/metropolice/pain1.wav") > 0 and "" or "../../hl2/sound/" .. v)
        delay = delay + preSet
        timer.Simple(delay, function() if IsValid(entity) then entity:EmitSound(v, volume, pitch) end end)
        delay = delay + length + postSet + spacing
    end
    return delay
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
    for _, client in ipairs(player.GetAll()) do
        local hasPermission = CAMI.PlayerHasAccess(client, "UserGroups - Staff Group", nil)
        if hasPermission then staff[#staff + 1] = client end
    end
    return staff
end

function lia.util.findPlayerBySteamID64(SteamID64)
    for _, client in ipairs(player.GetAll()) do
        if client:SteamID64() == SteamID64 then return client end
    end
    return nil
end

function lia.util.findPlayerBySteamID(SteamID)
    for _, client in ipairs(player.GetAll()) do
        if client:SteamID() == SteamID then return client end
    end
    return nil
end

function lia.util.CanFit(pos, mins, maxs, filter)
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

function lia.util.Chance(chance)
    local rand = math.random(0, 100)
    if rand <= chance then return true end
    return false
end

function lia.util.PlayerInRadius(pos, dist)
    dist = dist * dist
    local t = {}
    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) and ply:GetPos():DistToSqr(pos) < dist then t[#t + 1] = ply end
    end
    return t
end

if SERVER then
    function lia.util.notify(message, recipient)
        net.Start("liaNotify")
        net.WriteString(message)
        if recipient == nil then
            net.Broadcast()
        else
            net.Send(recipient)
        end
    end

    function lia.util.SpawnEntities(entityTable)
        for entity, position in pairs(entityTable) do
            if isvector(position) then
                local newEnt = ents.Create(entity)
                if IsValid(newEnt) then
                    newEnt:SetPos(position)
                    newEnt:Spawn()
                end
            else
                print("Invalid position for entity", entity)
            end
        end
    end

    function lia.util.notifyLocalized(message, recipient, ...)
        local args = {...}
        if recipient ~= nil and not istable(recipient) and type(recipient) ~= "Player" then
            table.insert(args, 1, recipient)
            recipient = nil
        end

        net.Start("liaNotifyL")
        net.WriteString(message)
        net.WriteUInt(#args, 8)
        for i = 1, #args do
            net.WriteString(tostring(args[i]))
        end

        if recipient == nil then
            net.Broadcast()
        else
            net.Send(recipient)
        end
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

    function lia.util.spawnProp(model, position, force, lifetime, angles, collision)
        local entity = ents.Create("prop_physics")
        entity:SetModel(model)
        entity:Spawn()
        entity:SetCollisionGroup(collision or COLLISION_GROUP_WEAPON)
        entity:SetAngles(angles or angle_zero)
        if type(position) == "Player" then position = position:GetItemDropPos(entity) end
        entity:SetPos(position)
        if force then
            local phys = entity:GetPhysicsObject()
            if IsValid(phys) then phys:ApplyForceCenter(force) end
        end

        if (lifetime or 0) > 0 then timer.Simple(lifetime, function() if IsValid(entity) then entity:Remove() end end) end
        return entity
    end

    function lia.util.DebugLog(str)
        MsgC(Color("sky_blue"), os.date("(%d/%m/%Y - %H:%M:%S)", os.time()), Color("yellow"), " [LOG] ", color_white, str, "\n")
    end

    function lia.util.DebugMessage(msg, ...)
        MsgC(Color(70, 150, 255), "[CityRP] DEBUG: ", string.format(msg, ...), "\n")
    end

    function lia.util.DWarningMessage(message, ...)
        MsgC(Color(255, 100, 0), string.format(message, ...), "\n")
    end

    function lia.util.ChatPrint(target, ...)
        netstream.Start(target, "ChatPrint", {...})
    end
else
    function lia.util.drawText(text, x, y, color, alignX, alignY, font, alpha)
        color = color or color_white
        return draw.TextShadow({
            text = text,
            font = font or "liaGenericFont",
            pos = {x, y},
            color = color,
            xalign = alignX or 0,
            yalign = alignY or 0
        }, 1, alpha or (color.a * 0.575))
    end

    function lia.util.DrawTexture(material, color, x, y, w, h)
        surface.SetDrawColor(color or color_white)
        surface.SetMaterial(lia.util.getMaterial(material))
        surface.DrawTexturedRect(x, y, w, h)
    end

    function lia.util.SkinFunc(name, panel, a, b, c, d, e, f, g)
        local skin = (ispanel(panel) and IsValid(panel)) and panel:GetSkin() or derma.GetDefaultSkin()
        if not skin then return end
        local func = skin[name]
        if not func then return end
        return func(skin, panel, a, b, c, d, e, f, g)
    end

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

    function lia.util.notify(message)
        chat.AddText(message)
    end

    function lia.util.notifyLocalized(message, ...)
        lia.util.notify(L(message, ...))
    end

    function lia.util.colorToText(color)
        if not IsColor(color) then return end
        return (color.r or 255) .. "," .. (color.g or 255) .. "," .. (color.b or 255) .. "," .. (color.a or 255)
    end

    function lia.util.endCaption(text, duration)
        RunConsoleCommand("closecaption", "1")
        gui.AddCaption(text, duration or string.len(text) * 0.1)
    end

    function lia.util.startCaption(text, duration)
        RunConsoleCommand("closecaption", "1")
        gui.AddCaption(text, duration or string.len(text) * 0.1)
    end

    function lia.util.getInjuredColor(client)
        local health_color = color_white
        if not IsValid(client) then return health_color end
        local health, healthMax = client:Health(), client:GetMaxHealth()
        if (health / healthMax) < .95 then health_color = lia.color.LerpHSV(nil, nil, healthMax, health, 0) end
        return health_color
    end

    function lia.util.ScreenScaleH(n, type)
        if type then
            if ScrH() > 720 then return n end
            return math.ceil(n / 1080 * ScrH())
        end
        return n * (ScrH() / 480)
    end

    timer.Create("liaResolutionMonitor", 1, 0, function()
        local scrW, scrH = ScrW(), ScrH()
        if scrW ~= LAST_WIDTH or scrH ~= LAST_HEIGHT then
            hook.Run("ScreenResolutionChanged", LAST_WIDTH, LAST_HEIGHT)
            LAST_WIDTH = scrW
            LAST_HEIGHT = scrH
        end
    end)

    function Derma_NumericRequest(strTitle, strText, strDefaultText, fnEnter, fnCancel, strButtonText, strButtonCancelText)
        local Window = vgui.Create("DFrame")
        Window:SetTitle(strTitle or "Message Title (First Parameter)")
        Window:SetDraggable(false)
        Window:ShowCloseButton(false)
        Window:SetBackgroundBlur(true)
        Window:SetDrawOnTop(true)
        local InnerPanel = vgui.Create("DPanel", Window)
        InnerPanel:SetPaintBackground(false)
        local Text = vgui.Create("DLabel", InnerPanel)
        Text:SetText(strText or "Message Text (Second Parameter)")
        Text:SizeToContents()
        Text:SetContentAlignment(5)
        Text:SetTextColor(color_white)
        local TextEntry = vgui.Create("DTextEntry", InnerPanel)
        TextEntry:SetValue(strDefaultText or "")
        TextEntry.OnEnter = function()
            Window:Close()
            fnEnter(TextEntry:GetValue())
        end

        TextEntry:SetNumeric(true)
        local ButtonPanel = vgui.Create("DPanel", Window)
        ButtonPanel:SetTall(30)
        ButtonPanel:SetPaintBackground(false)
        local Button = vgui.Create("DButton", ButtonPanel)
        Button:SetText(strButtonText or "OK")
        Button:SizeToContents()
        Button:SetTall(20)
        Button:SetWide(Button:GetWide() + 20)
        Button:SetPos(5, 5)
        Button.DoClick = function()
            Window:Close()
            fnEnter(TextEntry:GetValue())
        end

        local ButtonCancel = vgui.Create("DButton", ButtonPanel)
        ButtonCancel:SetText(strButtonCancelText or L"derma_request_cancel")
        ButtonCancel:SizeToContents()
        ButtonCancel:SetTall(20)
        ButtonCancel:SetWide(Button:GetWide() + 20)
        ButtonCancel:SetPos(5, 5)
        ButtonCancel.DoClick = function()
            Window:Close()
            if fnCancel then fnCancel(TextEntry:GetValue()) end
        end

        ButtonCancel:MoveRightOf(Button, 5)
        ButtonPanel:SetWide(Button:GetWide() + 5 + ButtonCancel:GetWide() + 10)
        local w, h = Text:GetSize()
        w = math.max(w, 400)
        Window:SetSize(w + 50, h + 25 + 75 + 10)
        Window:Center()
        InnerPanel:StretchToParent(5, 25, 5, 45)
        Text:StretchToParent(5, 5, 5, 35)
        TextEntry:StretchToParent(5, nil, 5, nil)
        TextEntry:AlignBottom(5)
        TextEntry:RequestFocus()
        TextEntry:SelectAllText(true)
        ButtonPanel:CenterHorizontal()
        ButtonPanel:AlignBottom(8)
        Window:MakePopup()
        Window:DoModal()
        return Window
    end

    function lia.util.notify(message)
        local notice = vgui.Create("liaNotify")
        local i = table.insert(lia.notices, notice)
        notice:SetMessage(message)
        notice:SetPos(ScrW(), ScrH() - (i - 1) * (notice:GetTall() + 4) + 4)
        notice:MoveToFront()
        OrganizeNotices(false)
        timer.Simple(10, function()
            if IsValid(notice) then
                notice:AlphaTo(0, 1, 0, function()
                    notice:Remove()
                    for v, k in pairs(lia.notices) do
                        if k == notice then table.remove(lia.notices, v) end
                    end

                    OrganizeNotices(false)
                end)
            end
        end)

        MsgN(message)
    end

    function lia.util.notifQuery(question, option1, option2, manualDismiss, notifType, callback)
        if not callback or not isfunction(callback) then Error("A callback function must be specified") end
        if not question or not isstring(question) then Error("A question string must be specified") end
        if not option1 then option1 = "Yes" end
        if not option2 then option2 = "No" end
        if not manualDismiss then manualDismiss = false end
        local notice = CreateNoticePanel(10, manualDismiss)
        local i = table.insert(lia.noticess, notice)
        notice.isQuery = true
        notice.text:SetText(question)
        notice:SetPos(0, (i - 1) * (notice:GetTall() + 4) + 4)
        notice:SetTall(36 * 2.3)
        notice:CalcWidth(120)
        notice:CenterHorizontal()
        notice.notifType = notifType or 7
        if manualDismiss then notice.start = nil end
        notice.opt1 = notice:Add("DButton")
        notice.opt1:SetAlpha(0)
        notice.opt2 = notice:Add("DButton")
        notice.opt2:SetAlpha(0)
        notice.oh = notice:GetTall()
        OrganizeNotices(false)
        notice:SetTall(0)
        notice:SizeTo(notice:GetWide(), 36 * 2.3, 0.2, 0, -1, function()
            notice.text:SetPos(0, 0)
            local function styleOpt(o)
                o.color = Color(0, 0, 0, 30)
                AccessorFunc(o, "color", "Color")
                function o:Paint(w, h)
                    if self.left then
                        draw.RoundedBoxEx(4, 0, 0, w + 2, h, self.color, false, false, true, false)
                    else
                        draw.RoundedBoxEx(4, 0, 0, w + 2, h, self.color, false, false, false, true)
                    end
                end
            end

            if notice.opt1 and IsValid(notice.opt1) then
                notice.opt1:SetAlpha(255)
                notice.opt1:SetSize(notice:GetWide() / 2, 25)
                notice.opt1:SetText(option1 .. " (F8)")
                notice.opt1:SetPos(0, notice:GetTall() - notice.opt1:GetTall())
                notice.opt1:CenterHorizontal(0.25)
                notice.opt1:SetAlpha(0)
                notice.opt1:AlphaTo(255, 0.2)
                notice.opt1:SetTextColor(color_white)
                notice.opt1.left = true
                styleOpt(notice.opt1)
                function notice.opt1:keyThink()
                    if input.IsKeyDown(KEY_F8) and (CurTime() - notice.lastKey) >= 0.5 then
                        self:ColorTo(Color(24, 215, 37), 0.2, 0)
                        notice.respondToKeys = false
                        callback(1, notice)
                        timer.Simple(1, function() if notice and IsValid(notice) then RemoveNotices(notice) end end)
                        notice.lastKey = CurTime()
                    end
                end
            end

            if notice.opt2 and IsValid(notice.opt2) then
                notice.opt2:SetAlpha(255)
                notice.opt2:SetSize(notice:GetWide() / 2, 25)
                notice.opt2:SetText(option2 .. " (F9)")
                notice.opt2:SetPos(0, notice:GetTall() - notice.opt2:GetTall())
                notice.opt2:CenterHorizontal(0.75)
                notice.opt2:SetAlpha(0)
                notice.opt2:AlphaTo(255, 0.2)
                notice.opt2:SetTextColor(color_white)
                styleOpt(notice.opt2)
                function notice.opt2:keyThink()
                    if input.IsKeyDown(KEY_F9) and (CurTime() - notice.lastKey) >= 0.5 then
                        self:ColorTo(Color(24, 215, 37), 0.2, 0)
                        notice.respondToKeys = false
                        callback(2, notice)
                        timer.Simple(1, function() if notice and IsValid(notice) then RemoveNotices(notice) end end)
                        notice.lastKey = CurTime()
                    end
                end
            end

            notice.lastKey = CurTime()
            notice.respondToKeys = true
            function notice:Think()
                if not self.respondToKeys then return end
                local queries = {}
                for _, v in pairs(lia.noticess) do
                    if v.isQuery then queries[#queries + 1] = v end
                end

                for k, v in pairs(queries) do
                    if v == self and k > 1 then return end
                end

                if self.opt1 and IsValid(self.opt1) then self.opt1:keyThink() end
                if self.opt2 and IsValid(self.opt2) then self.opt2:keyThink() end
            end
        end)
        return notice
    end

    local useCheapBlur = CreateClientConVar("lia_cheapblur", 0, true):GetBool()
    function lia.util.drawBlur(panel, amount, passes)
        amount = amount or 5
        if useCheapBlur then
            surface.SetDrawColor(50, 50, 50, amount * 20)
            surface.DrawRect(0, 0, panel:GetWide(), panel:GetTall())
        else
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
    end

    function lia.util.drawBlurAt(x, y, w, h, amount, passes)
        amount = amount or 5
        if useCheapBlur then
            surface.SetDrawColor(30, 30, 30, amount * 20)
            surface.DrawRect(x, y, w, h)
        else
            surface.SetMaterial(lia.util.getMaterial("pp/blurscreen"))
            surface.SetDrawColor(255, 255, 255)
            local scrW, scrH = ScrW(), ScrH()
            local x2, y2 = x / scrW, y / scrH
            local w2, h2 = (x + w) / scrW, (y + h) / scrH
            for i = -(passes or 0.2), 1, 0.2 do
                lia.util.getMaterial("pp/blurscreen"):SetFloat("$blur", i * amount)
                lia.util.getMaterial("pp/blurscreen"):Recompute()
                render.UpdateScreenEffectTexture()
                surface.DrawTexturedRectUV(x, y, w, h, x2, y2, w2, h2)
            end
        end
    end

    file.CreateDir("lilia/images")
    lia.util.LoadedImages = lia.util.LoadedImages or {
        [0] = Material("icon16/cross.png")
    }

    function lia.util.FetchImage(id, callback, failImg, pngParameters, imageProvider)
        local loadedImage = lia.util.LoadedImages[id]
        if loadedImage then
            if callback then callback(loadedImage) end
            return
        end

        if file.Exists("lilia/images/" .. id .. ".png", "DATA") then
            local mat = Material("data/lilia/images/" .. id .. ".png", pngParameters or "noclamp smooth")
            if mat then
                lia.util.LoadedImages[id] = mat
                if callback then callback(mat) end
            elseif callback then
                callback(false)
            end
        else
            http.Fetch((imageProvider or "https://i.imgur.com/") .. id .. ".png", function(body, _, _, code)
                if code ~= 200 then
                    callback(false)
                    return
                end

                if not body or body == "" then
                    callback(false)
                    return
                end

                file.Write("lilia/images/" .. id .. ".png", body)
                local mat = Material("data/lilia/images/" .. id .. ".png", "noclamp smooth")
                lia.util.LoadedImages[id] = mat
                if callback then callback(mat) endf
            end, function() if callback then callback(false) end end)
        end
    end

    cvars.AddChangeCallback("lia_cheapblur", function(_, _, new) useCheapBlur = (tonumber(new) or 0) > 0 end)
end

function lia.util.getMaterial(materialPath)
    lia.util.cachedMaterials[materialPath] = lia.util.cachedMaterials[materialPath] or Material(materialPath)
    return lia.util.cachedMaterials[materialPath]
end