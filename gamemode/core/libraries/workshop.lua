lia.workshop = lia.workshop or {}
if SERVER then
    lia.workshop.ids = lia.workshop.ids or {}
    lia.workshop.known = lia.workshop.known or {}
    lia.workshop.cache = lia.workshop.cache or {}
    function lia.workshop.AddWorkshop(id)
        id = tostring(id)
        if not lia.workshop.ids[id] then lia.bootstrap("Workshop Downloader", L("workshopAdded", id)) end
        lia.bootstrap("Workshop Downloader", L("workshopDownloading", id))
        lia.workshop.ids[id] = true
    end

    resource.AddWorkshop = lia.workshop.AddWorkshop
    local function addKnown(id)
        id = tostring(id)
        if not lia.workshop.known[id] then
            lia.workshop.known[id] = true
            lia.bootstrap("Workshop Downloader", L("workshopAdded", id))
        end
    end

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
    function lia.workshop.send(ply)
        net.Start("WorkshopDownloader_Start")
        net.WriteTable(lia.workshop.cache)
        net.Send(ply)
    end

    hook.Add("PlayerInitialSpawn", "liaWorkshopInit", function(ply)
        if not lia.config.get("AutoDownloadWorkshop", true) then return end
        timer.Simple(10, function() if IsValid(ply) then lia.workshop.send(ply) end end)
    end)

    local origAddFile = resource.AddFile
    function resource.AddFile(path)
        lia.bootstrap("Resources", L("resourceFileAdded", path))
        if isfunction(origAddFile) then origAddFile(path) end
    end

    local origAddSingleFile = resource.AddSingleFile
    function resource.AddSingleFile(path)
        lia.bootstrap("Resources", L("resourceFileAdded", path))
        if isfunction(origAddSingleFile) then origAddSingleFile(path) end
    end

    resource.AddWorkshop = lia.workshop.AddWorkshop
else
    local queue, panel, total, remain = {}, nil, 0, 0
    lia.workshop.serverIds = lia.workshop.serverIds or {}
    local function mounted(id)
        for _, addon in pairs(engine.GetAddons() or {}) do
            if tostring(addon.wsid or addon.workshopid) == tostring(id) and addon.mounted then return true end
        end
        return false
    end

    local function uiCreate()
        if panel and panel:IsValid() then return end
        surface.SetFont("DermaLarge")
        local title = L("downloadingWorkshopAddonsTitle")
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
            lia.bootstrap("Workshop Downloader", L("workshopAllInstalled"))
            return
        end

        uiCreate()
        uiUpdate()
        for id in pairs(queue) do
            lia.bootstrap("Workshop Downloader", L("workshopDownloading", id))
            steamworks.DownloadUGC(id, function(path)
                remain = remain - 1
                lia.bootstrap("Workshop Downloader", L("workshopDownloadComplete", id))
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
        if tbl then lia.workshop.serverIds = tbl end
        for id in pairs(lia.workshop.serverIds) do
            queue[id] = true
        end
    end

    net.Receive("WorkshopDownloader_Start", function()
        refresh(net.ReadTable())
        start()
    end)

    concommand.Add("workshop_force_redownload", function()
        table.Empty(queue)
        refresh()
        start()
        lia.bootstrap("Workshop Downloader", L("workshopForcedRedownload"))
    end)

    hook.Add("CreateInformationButtons", "liaWorkshopInfo", function(pages)
        if not lia.config.get("AutoDownloadWorkshop", true) then return end
        table.insert(pages, {
            name = L("workshopAddons"),
            drawFunc = function(container)
                local ids = lia.workshop.serverIds or {}
                local search = vgui.Create("DTextEntry", container)
                search:Dock(TOP)
                search:DockMargin(0, 0, 0, 5)
                search:SetTall(30)
                search:SetPlaceholderText(L("searchAddons"))
                local info = vgui.Create("DPanel", container)
                info:Dock(TOP)
                info:DockMargin(10, 0, 10, 5)
                info:SetTall(30)
                info.Paint = function(_, w, h) draw.RoundedBox(4, 0, 0, w, h, Color(30, 30, 30, 200)) end
                local lbl = vgui.Create("DLabel", info)
                lbl:Dock(FILL)
                lbl:SetFont("liaSmallFont")
                lbl:SetTextColor(color_white)
                lbl:SetContentAlignment(5)
                lbl:SetText(L("totalAutoAddons", table.Count(ids)))
                local sc = vgui.Create("DScrollPanel", container)
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