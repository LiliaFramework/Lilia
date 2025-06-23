lia.workshop = lia.workshop or {}
if SERVER then
    lia.workshop.ids = lia.workshop.ids or {}
    lia.workshop.known = lia.workshop.known or {}
    lia.workshop.cache = lia.workshop.cache or {}
    function lia.workshop.AddWorkshop(id)
        id = tostring(id)
        if not lia.workshop.ids[id] then lia.bootstrap("Workshop Downloader", "Added workshop " .. id .. " to download list") end
        lia.bootstrap("Workshop Downloader", "Downloading workshop " .. id)
        lia.workshop.ids[id] = true
    end

    local function addKnown(id)
        id = tostring(id)
        if not lia.workshop.known[id] then
            lia.workshop.known[id] = true
            lia.bootstrap("Workshop Downloader", "Added workshop " .. id .. " to download list")
        end
    end

    --[[
        lia.workshop.gather()

        Description:
            Collects workshop IDs from installed addons and registered modules.

        Realm:
            Server

        Returns:
            ids (table) – Table of workshop IDs to download.
    ]]
    function lia.workshop.gather()
        local ids = table.Copy(lia.workshop.ids)
        for _, addon in pairs(engine.GetAddons() or {}) do
            if addon.mounted and addon.wsid then ids[tostring(addon.wsid)] = true end
        end

        for _, module in pairs(lia.module.list) do
            local wc = module.WorkshopContent
            if wc then
                if isstring(wc) then
                    ids[wc] = true
                else
                    for _, v in ipairs(wc) do
                        ids[tostring(v)] = true
                    end
                end
            end
        end

        for id in pairs(ids) do
            addKnown(id)
        end
        return ids
    end

    hook.Add("InitializedModules", "liaWorkshopInitializedModules", function() lia.workshop.cache = lia.workshop.gather() end)
    --[[
        lia.workshop.send(ply)

        Description:
            Sends the collected workshop IDs to a connecting player.

        Parameters:
            ply (Player) – Player to send the download list to.

        Realm:
            Server

        Returns:
            None
    ]]
    function lia.workshop.send(ply)
        net.Start("WorkshopDownloader_Start")
        net.WriteTable(lia.workshop.cache)
        net.Send(ply)
    end

    --[[
        hook.Add("PlayerInitialSpawn")

        Description:
            Sends the workshop download list shortly after a player connects
            if automatic downloads are enabled.

        Parameters:
            ply (Player) – Player that joined the server.

        Realm:
            Server
    ]]
    hook.Add("PlayerInitialSpawn", "liaWorkshopInit", function(ply)
        if not lia.config.get("AutoDownloadWorkshop", true) then return end
        timer.Simple(10, function() if IsValid(ply) then lia.workshop.send(ply) end end)
    end)

    resource.AddWorkshop = lia.workshop.AddWorkshop
else
    local queue, panel, total, remain = {}, nil, 0, 0
    local function gather()
        local ids = {
            ["2959728255"] = true
        }

        for _, addon in pairs(engine.GetAddons() or {}) do
            if addon.mounted and addon.wsid then ids[tostring(addon.wsid)] = true end
        end

        for _, module in pairs(lia.module.list) do
            local wc = module.WorkshopContent
            if wc then
                if isstring(wc) then
                    ids[wc] = true
                else
                    for _, v in ipairs(wc) do
                        ids[tostring(v)] = true
                    end
                end
            end
        end

        for id in pairs(lia.workshop.ids or {}) do
            ids[id] = true
        end
        return ids
    end

    local function mounted(id)
        for _, addon in pairs(engine.GetAddons() or {}) do
            if tostring(addon.wsid or addon.workshopid) == tostring(id) and addon.mounted then return true end
        end
        return false
    end

    local function uiCreate()
        if panel and panel:IsValid() then return end
        surface.SetFont("DermaLarge")
        local title = "Downloading Workshop Addons"
        local tw, th = surface.GetTextSize(title)
        local pad, bh = 10, 20
        local w, h = math.max(tw, 200) + pad * 2, th + bh + pad * 3
        panel = vgui.Create("DPanel")
        panel:SetSize(w, h)
        panel:SetPos((ScrW() - w) / 2, ScrH() * 0.1)
        derma.SkinHook("Paint", "Panel", panel, w, h)
        local lbl = vgui.Create("DLabel", panel)
        lbl:SetFont("DermaLarge")
        lbl:SetText(title)
        lbl:SizeToContents()
        lbl:SetPos(pad, pad)
        panel.bar = vgui.Create("DProgressBar", panel)
        panel.bar:SetPos(pad, pad + th + pad)
        panel.bar:SetSize(w - pad * 2, bh)
        panel.bar:SetFraction(0)
    end

    local function uiUpdate()
        if not (panel and panel:IsValid()) then return end
        panel.bar:SetFraction(total > 0 and (total - remain) / total or 0)
        panel.bar:SetText(total - remain .. "/" .. total)
    end

    local function start()
        for id in pairs(queue) do
            if mounted(id) then queue[id] = nil end
        end

        total = table.Count(queue)
        remain = total
        if total == 0 then
            lia.bootstrap("Workshop Downloader", "All workshop addons already installed. Skipping download.")
            return
        end

        uiCreate()
        uiUpdate()
        for id in pairs(queue) do
            lia.bootstrap("Workshop Downloader", "Downloading workshop " .. id)
            steamworks.DownloadUGC(id, function(path)
                remain = remain - 1
                lia.bootstrap("Workshop Downloader", "Completed workshop " .. id)
                if path then game.MountGMA(path) end
                uiUpdate()
                if remain <= 0 and panel and panel:IsValid() then
                    panel:Remove()
                    panel = nil
                end
            end)
        end
    end

    local function refresh(tbl)
        table.Empty(queue)
        for id in pairs(gather()) do
            queue[id] = true
        end

        if tbl then
            for id in pairs(tbl) do
                queue[id] = true
            end
        end
    end

    --[[
        net.Receive("WorkshopDownloader_Start")

        Description:
            Receives a list of workshop addon IDs and begins downloading
            them on the client.

        Realm:
            Client
    ]]
    net.Receive("WorkshopDownloader_Start", function()
        refresh(net.ReadTable())
        start()
    end)

    --[[
        workshop_force_redownload console command

        Description:
            Forces all workshop addons to be downloaded again.

        Realm:
            Client
    ]]
    concommand.Add("workshop_force_redownload", function()
        table.Empty(queue)
        refresh()
        for _, addon in pairs(engine.GetAddons() or {}) do
            if addon.mounted and addon.wsid then queue[tostring(addon.wsid)] = true end
        end

        start()
        lia.bootstrap("Workshop Downloader", "Forced redownload initiated")
    end)

    --[[
        hook.Add("CreateInformationButtons")

        Description:
            Adds a page to the information menu listing all automatically
            downloaded workshop addons.

        Parameters:
            pages (table) – Table of existing menu pages.

        Realm:
            Client
    ]]
    hook.Add("CreateInformationButtons", "liaWorkshopInfo", function(pages)
        if not lia.config.get("AutoDownloadWorkshop", true) then return end
        table.insert(pages, {
            name = L("workshopAddons"),
            drawFunc = function(panel)
                local ids = gather()
                local search = vgui.Create("DTextEntry", panel)
                search:Dock(TOP)
                search:DockMargin(0, 0, 0, 5)
                search:SetTall(30)
                search:SetPlaceholderText(L("searchAddons"))
                local info = vgui.Create("DPanel", panel)
                info:Dock(TOP)
                info:DockMargin(10, 0, 10, 5)
                info:SetTall(30)
                info.Paint = function(_, w, h) draw.RoundedBox(4, 0, 0, w, h, Color(30, 30, 30, 200)) end
                local lbl = vgui.Create("DLabel", info)
                lbl:Dock(FILL)
                lbl:SetFont("liaSmallFont")
                lbl:SetTextColor(color_white)
                lbl:SetContentAlignment(5)
                lbl:SetText("Total Auto Downloaded Addons: " .. table.Count(ids))
                local sc = vgui.Create("DScrollPanel", panel)
                sc:Dock(FILL)
                sc:DockPadding(0, 10, 0, 0)
                local canvas = sc:GetCanvas()
                local function item(id, size)
                    steamworks.FileInfo(id, function(fi)
                        if not fi then return end
                        local p = vgui.Create("DPanel", canvas)
                        p:Dock(TOP)
                        p:DockMargin(0, 0, 0, 10)
                        p.titleText = (fi.title or ""):lower()
                        local html = vgui.Create("DHTML", p)
                        html:SetSize(size, size)
                        html:OpenURL(fi.previewurl)
                        local title = vgui.Create("DLabel", p)
                        title:SetFont("liaBigFont")
                        title:SetText(fi.title or "ID:" .. id)
                        local desc = vgui.Create("DLabel", p)
                        desc:SetFont("liaMediumFont")
                        desc:SetWrap(true)
                        desc:SetText(fi.description or "")
                        function p:PerformLayout()
                            local pad = 10
                            html:SetPos(pad, pad)
                            title:SizeToContents()
                            title:SetPos(pad + size + pad, pad)
                            desc:SetPos(pad + size + pad, pad + title:GetTall() + 5)
                            desc:SetWide(self:GetWide() - pad - size - pad)
                            local _, h = desc:GetContentSize()
                            desc:SetTall(h)
                            self:SetTall(math.max(size + pad * 2, title:GetTall() + 5 + h + pad))
                        end
                    end)
                end

                for id in pairs(ids) do
                    item(id, 200)
                end

                search.OnTextChanged = function(self)
                    local q = self:GetValue():lower()
                    for _, child in ipairs(canvas:GetChildren()) do
                        if child.titleText then child:SetVisible(q == "" or child.titleText:find(q, 1, true)) end
                    end

                    canvas:InvalidateLayout()
                end
            end
        })
    end)
end
