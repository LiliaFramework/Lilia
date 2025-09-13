lia.playerinteract = lia.playerinteract or {}
lia.playerinteract.stored = lia.playerinteract.stored or {}
lia.playerinteract.categories = lia.playerinteract.categories or {}
function lia.playerinteract.isWithinRange(client, entity, customRange)
    if not IsValid(client) or not IsValid(entity) then return false end
    local range = customRange or 250
    return entity:GetPos():DistToSqr(client:GetPos()) < range * range
end

function lia.playerinteract.getInteractions(client)
    client = client or LocalPlayer()
    local ent = client:getTracedEntity()
    if not IsValid(ent) then return {} end
    local interactions = {}
    local isPlayerTarget = ent:IsPlayer()
    for name, opt in pairs(lia.playerinteract.stored) do
        if opt.type == "interaction" then
            local targetType = opt.target or "player"
            local targetMatches = targetType == "any" or targetType == "player" and isPlayerTarget or targetType == "entity" and not isPlayerTarget
            if targetMatches and (not opt.shouldShow or opt.shouldShow(client, ent)) then interactions[name] = opt end
        end
    end
    return interactions
end

function lia.playerinteract.getActions(client)
    client = client or LocalPlayer()
    if not IsValid(client) or not client:getChar() then return {} end
    local actions = {}
    for name, opt in pairs(lia.playerinteract.stored) do
        if opt.type == "action" and (not opt.shouldShow or opt.shouldShow(client)) then actions[name] = opt end
    end
    return actions
end

function lia.playerinteract.getCategorizedOptions(options)
    local categorized = {}
    for name, entry in pairs(options) do
        local category = entry.opt and entry.opt.category or L("categoryUnsorted")
        if not categorized[category] then categorized[category] = {} end
        categorized[category][name] = entry
    end
    return categorized
end

if SERVER then
    function lia.playerinteract.addInteraction(name, data)
        data.type = "interaction"
        data.range = data.range or 250
        data.category = data.category or L("categoryUnsorted")
        data.target = data.target or "player"
        data.timeToComplete = data.timeToComplete or nil
        data.actionText = data.actionText or nil
        data.targetActionText = data.targetActionText or nil
        if data.shouldShow then data.shouldShowName = name end
        if data.onRun and data.timeToComplete and (data.actionText or data.targetActionText) then
            local originalOnRun = data.onRun
            data.onRun = function(client, target)
                if data.actionText then client:setAction(data.actionText, data.timeToComplete, function() originalOnRun(client, target) end) end
                if data.targetActionText and IsValid(target) and target:IsPlayer() then target:setAction(data.targetActionText, data.timeToComplete) end
                if not data.actionText then originalOnRun(client, target) end
            end
        end

        lia.playerinteract.stored[name] = data
        if not lia.playerinteract.categories[data.category] then
            lia.playerinteract.categories[data.category] = {
                name = data.category,
                color = data.categoryColor or Color(255, 255, 255, 255)
            }
        end
    end

    function lia.playerinteract.addAction(name, data)
        data.type = "action"
        data.range = data.range or 250
        data.category = data.category or L("categoryUnsorted")
        data.timeToComplete = data.timeToComplete or nil
        data.actionText = data.actionText or nil
        data.targetActionText = data.targetActionText or nil
        if data.shouldShow then data.shouldShowName = name end
        if data.onRun and data.timeToComplete and (data.actionText or data.targetActionText) then
            local originalOnRun = data.onRun
            data.onRun = function(client, target)
                if data.actionText then client:setAction(data.actionText, data.timeToComplete, function() originalOnRun(client, target) end) end
                if data.targetActionText and IsValid(target) and target:IsPlayer() then target:setAction(data.targetActionText, data.timeToComplete) end
                if not data.actionText then originalOnRun(client, target) end
            end
        end

        lia.playerinteract.stored[name] = data
        if not lia.playerinteract.categories[data.category] then
            lia.playerinteract.categories[data.category] = {
                name = data.category,
                color = data.categoryColor or Color(255, 255, 255, 255)
            }
        end
    end

    function lia.playerinteract.syncToClients(client)
        local filteredData = {}
        for name, data in pairs(lia.playerinteract.stored) do
            filteredData[name] = {
                type = data.type,
                serverOnly = data.serverOnly and true or false,
                name = name,
                range = data.range,
                category = data.category or L("categoryUnsorted"),
                target = data.target,
                timeToComplete = data.timeToComplete,
                actionText = data.actionText,
                targetActionText = data.targetActionText
            }
        end

        lia.net.writeBigTable(client, "liaPlayerInteractSync", filteredData)
        lia.net.writeBigTable(client, "liaPlayerInteractCategories", lia.playerinteract.categories)
    end

    lia.playerinteract.addInteraction("giveMoney", {
        serverOnly = true,
        shouldShow = function(client, target) return IsValid(target) and target:IsPlayer() and client:getChar():getMoney() > 0 end,
        onRun = function(client, target)
            client:requestString("@giveMoney", "@enterAmount", function(amount)
                amount = tonumber(amount)
                if not amount or amount <= 0 then
                    client:notifyLocalized("invalidAmount")
                    return
                end

                if lia.config.get("DisableCheaterActions", true) and client:getNetVar("cheater", false) then
                    lia.log.add(client, "cheaterAction", L("cheaterActionTransferMoney"))
                    client:notifyLocalized("maybeYouShouldntHaveCheated")
                    return
                end

                if not IsValid(client) or not client:getChar() then return end
                if client:IsFamilySharedAccount() and not lia.config.get("AltsDisabled", false) then
                    client:notifyLocalized("familySharedMoneyTransferDisabled")
                    return
                end

                if not IsValid(target) or not target:IsPlayer() or not target:getChar() then return end
                if not client:getChar():hasMoney(amount) then
                    client:notifyLocalized("notEnoughMoney")
                    return
                end

                target:getChar():giveMoney(amount)
                client:getChar():takeMoney(amount)
                local senderName = client:getChar():getDisplayedName(target)
                local targetName = client:getChar():getDisplayedName(client)
                client:notifyLocalized("moneyTransferSent", lia.currency.get(amount), targetName)
                target:notifyLocalized("moneyTransferReceived", lia.currency.get(amount), senderName)
            end, "")
        end
    })

    lia.playerinteract.addAction("changeToWhisper", {
        category = L("categoryVoice"),
        shouldShow = function(client) return client:getChar() and client:Alive() end,
        onRun = function(client)
            client:setNetVar("VoiceType", L("whispering"))
            client:notifyLocalized("voiceModeSet", L("whispering"))
        end,
        serverOnly = true
    })

    lia.playerinteract.addAction("changeToTalk", {
        category = L("categoryVoice"),
        shouldShow = function(client) return client:getChar() and client:Alive() end,
        onRun = function(client)
            client:setNetVar("VoiceType", L("talking"))
            client:notifyLocalized("voiceModeSet", L("talking"))
        end,
        serverOnly = true
    })

    lia.playerinteract.addAction("changeToYell", {
        category = L("categoryVoice"),
        shouldShow = function(client) return client:getChar() and client:Alive() end,
        onRun = function(client)
            client:setNetVar("VoiceType", L("yelling"))
            client:notifyLocalized("voiceModeSet", L("yelling"))
        end,
        serverOnly = true
    })
else
    function lia.playerinteract.openMenu(options, isInteraction, titleText, closeKey, netMsg, preFiltered)
        local client, ent = LocalPlayer(), LocalPlayer():getTracedEntity()
        local visible = {}
        if preFiltered then
            for name, opt in pairs(options) do
                visible[#visible + 1] = {
                    name = name,
                    opt = opt
                }
            end
        else
            for name, opt in pairs(options) do
                if isInteraction then
                    if opt.type == "interaction" and IsValid(ent) and lia.playerinteract.isWithinRange(client, ent, opt.range) then
                        local targetType = opt.target or "player"
                        local isPlayerTarget = ent:IsPlayer()
                        local targetMatches = targetType == "any" or targetType == "player" and isPlayerTarget or targetType == "entity" and not isPlayerTarget
                        if targetMatches then
                            local shouldShow = true
                            if opt.shouldShow then shouldShow = opt.shouldShow(client, ent) end
                            if shouldShow then
                                visible[#visible + 1] = {
                                    name = name,
                                    opt = opt
                                }
                            end
                        end
                    end
                else
                    if opt.type == "action" and (not opt.shouldShow or opt.shouldShow(client)) then
                        visible[#visible + 1] = {
                            name = name,
                            opt = opt
                        }
                    end
                end
            end
        end

        if #visible == 0 then return end
        local categorized = lia.playerinteract.getCategorizedOptions(visible)
        local categoryCount = table.Count(categorized)
        local fadeSpeed = 0.05
        local frameW = 450
        local entryH = 30
        local categoryH = 35
        local baseH = entryH * #visible + categoryH * categoryCount + 140
        local frameH = isInteraction and baseH or math.min(baseH, ScrH() * 0.6)
        local titleH = isInteraction and 36 or 16
        local titleY = 12
        local gap = 24
        local padding = ScrW() * 0.15
        local xPos = ScrW() - frameW - padding
        local yPos = (ScrH() - frameH) / 2
        local frame = vgui.Create("DFrame")
        frame:SetSize(frameW, frameH)
        frame:SetPos(xPos, yPos)
        frame:MakePopup()
        frame:SetTitle("")
        frame:ShowCloseButton(false)
        hook.Run("InteractionMenuOpened", frame)
        local oldOnRemove = frame.OnRemove
        function frame:OnRemove()
            if oldOnRemove then oldOnRemove(self) end
            lia.gui.InteractionMenu = nil
            hook.Run("InteractionMenuClosed")
        end

        frame:SetAlpha(0)
        frame:AlphaTo(255, fadeSpeed)
        function frame:Paint(w, h)
            lia.util.drawBlur(self, 4)
            draw.RoundedBox(0, 0, 0, w, h, Color(20, 20, 20, 120))
        end

        function frame:Think()
            if not input.IsKeyDown(closeKey) then self:Close() end
        end

        timer.Remove("InteractionMenu_Frame_Timer")
        timer.Create("InteractionMenu_Frame_Timer", 30, 1, function() if IsValid(frame) then frame:Close() end end)
        local title = frame:Add("DLabel")
        title:SetPos(0, titleY)
        title:SetSize(frameW, titleH)
        title:SetText(titleText)
        title:SetFont("liaSmallFont")
        title:SetColor(color_white)
        title:SetContentAlignment(5)
        function title:PaintOver()
            surface.SetDrawColor(Color(60, 60, 60))
        end

        local scroll = frame:Add("DScrollPanel")
        scroll:SetPos(0, titleH + titleY + gap)
        scroll:SetSize(frameW, frameH - titleH - titleY - gap)
        local layout = vgui.Create("DListLayout", scroll)
        layout:Dock(FILL)
        local function preserveScroll(f)
            local bar = scroll:GetVBar()
            local pos = bar and bar:GetScroll() or 0
            f()
            if bar then bar:SetScroll(pos) end
        end

        for categoryName, categoryOptions in pairs(categorized) do
            local categoryHeader = vgui.Create("DPanel", layout)
            categoryHeader:SetTall(categoryH)
            categoryHeader:Dock(TOP)
            categoryHeader:DockMargin(15, 0, 15, 0)
            function categoryHeader:Paint(w, h)
                draw.RoundedBox(4, 0, 0, w, h, Color(40, 40, 40, 180))
                draw.RoundedBox(4, 2, 2, w - 4, h - 4, Color(60, 60, 60, 120))
                surface.SetFont("liaSmallFont")
                local textW, textH = surface.GetTextSize(categoryName)
                local x = (w - textW) / 2
                local y = (h - textH) / 2
                draw.SimpleText(categoryName, "liaSmallFont", x, y, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            end

            local collapseBtn = categoryHeader:Add("DButton")
            collapseBtn:SetSize(20, 20)
            collapseBtn:SetPos(10, (categoryH - 20) / 2)
            collapseBtn:SetText("")
            collapseBtn:SetTextColor(color_white)
            local isCollapsed = false
            local categoryContent = {}
            function collapseBtn:Paint(w, h)
                local icon = isCollapsed and "?" or "?"
                surface.SetFont("liaSmallFont")
                local textW, textH = surface.GetTextSize(icon)
                local x = (w - textW) / 2
                local y = (h - textH) / 2
                draw.SimpleText(icon, "liaSmallFont", x, y, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            end

            collapseBtn.DoClick = function()
                preserveScroll(function()
                    isCollapsed = not isCollapsed
                    for _, p in pairs(categoryContent) do
                        p:SetVisible(not isCollapsed)
                    end

                    layout:InvalidateLayout(true)
                    layout:PerformLayout()
                end)
            end

            layout:Add(categoryHeader)
            for _, entry in pairs(categoryOptions) do
                local btn = vgui.Create("DButton", layout)
                btn:SetTall(entryH)
                btn:Dock(TOP)
                btn:DockMargin(15, 8, 15, 0)
                btn:SetText(L(entry.name))
                btn:SetFont("liaSmallFont")
                btn:SetTextColor(color_white)
                btn:SetContentAlignment(5)
                function btn:Paint(w, h)
                    if self:IsHovered() then
                        draw.RoundedBox(4, 0, 0, w, h, Color(30, 30, 30, 160))
                    else
                        draw.RoundedBox(4, 0, 0, w, h, Color(30, 30, 30, 100))
                    end
                end

                btn.DoClick = function()
                    frame:AlphaTo(0, fadeSpeed, 0, function() if IsValid(frame) then frame:Close() end end)
                    if not entry.opt.serverOnly and entry.opt.onRun then
                        if isInteraction then
                            if ent:IsPlayer() then
                                local target = ent
                                if ent:IsBot() then if client:Team() == FACTION_STAFF then target = client end end
                                entry.opt.onRun(client, target)
                            else
                                entry.opt.onRun(client, ent)
                            end
                        else
                            entry.opt.onRun(client, ent)
                        end
                    end

                    if entry.opt.serverOnly then
                        net.Start(netMsg)
                        net.WriteString(entry.name)
                        net.WriteBool(isInteraction)
                        net.WriteEntity(ent)
                        net.SendToServer()
                    end
                end

                layout:Add(btn)
                table.insert(categoryContent, btn)
            end

            local spacer = vgui.Create("DPanel", layout)
            spacer:SetTall(10)
            spacer:Dock(TOP)
            spacer:DockMargin(0, 0, 0, 0)
            function spacer:Paint()
            end

            layout:Add(spacer)
            table.insert(categoryContent, spacer)
        end

        lia.gui.InteractionMenu = frame
    end

    lia.net.readBigTable("liaPlayerInteractSync", function(data)
        if not istable(data) then return end
        local newStored = {}
        for name, incoming in pairs(data) do
            local localEntry = lia.playerinteract.stored[name] or {}
            local merged = table.Copy(localEntry)
            merged.type = incoming.type or localEntry.type
            merged.serverOnly = incoming.serverOnly and true or false
            merged.name = name
            merged.category = incoming.category or localEntry.category or L("categoryUnsorted")
            if incoming.range ~= nil then merged.range = incoming.range end
            merged.target = incoming.target or localEntry.target or "player"
            if incoming.timeToComplete ~= nil then merged.timeToComplete = incoming.timeToComplete end
            if incoming.actionText ~= nil then merged.actionText = incoming.actionText end
            if incoming.targetActionText ~= nil then merged.targetActionText = incoming.targetActionText end
            merged.onRun = localEntry.onRun
            newStored[name] = merged
        end

        lia.playerinteract.stored = newStored
    end)

    lia.net.readBigTable("liaPlayerInteractCategories", function(data) if istable(data) then lia.playerinteract.categories = data end end)
end

lia.keybind.add(KEY_TAB, "interactionMenu", {
    onPress = function()
        net.Start("liaRequestInteractOptions")
        net.WriteString("interaction")
        net.SendToServer()
    end,
})

lia.keybind.add(KEY_G, "personalActions", {
    onPress = function()
        net.Start("liaRequestInteractOptions")
        net.WriteString("action")
        net.SendToServer()
    end,
})
