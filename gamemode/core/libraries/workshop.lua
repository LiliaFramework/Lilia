if SERVER then
    hook.Add("PlayerInitialSpawn", "WorkshopDownloader_PlayerInitialSpawn", function(ply)
        timer.Simple(10, function()
            if not IsValid(ply) then return end
            net.Start("WorkshopDownloader_Start")
            net.Send(ply)
        end)
    end)
else
    local downloadPanel
    local totalAddons = 0
    local remainingAddons = 0
    local addonsQueue = {}
    local function createPanel()
        if downloadPanel and downloadPanel:IsValid() then return end
        surface.SetFont("DermaLarge")
        local title = "Downloading Workshop Addons"
        local textW, textH = surface.GetTextSize(title)
        local pad, barH = 10, 20
        local w = math.max(textW, 200) + pad * 2
        local h = textH + barH + pad * 3
        downloadPanel = vgui.Create("DPanel")
        downloadPanel:SetSize(w, h)
        downloadPanel:SetPos((ScrW() - w) / 2, ScrH() * 0.1)
        derma.SkinHook("Paint", "Panel", downloadPanel, w, h)
        local lbl = vgui.Create("DLabel", downloadPanel)
        lbl:SetFont("DermaLarge")
        lbl:SetText(title)
        lbl:SizeToContents()
        lbl:SetPos(pad, pad)
        downloadPanel.progressBar = vgui.Create("DProgressBar", downloadPanel)
        downloadPanel.progressBar:SetPos(pad, pad + textH + pad)
        downloadPanel.progressBar:SetSize(w - pad * 2, barH)
        downloadPanel.progressBar:SetFraction(0)
    end

    local function updatePanel()
        if not (downloadPanel and downloadPanel:IsValid()) then return end
        local done = totalAddons - remainingAddons
        local frac = totalAddons > 0 and done / totalAddons or 0
        downloadPanel.progressBar:SetFraction(frac)
        downloadPanel.progressBar:SetText(string.format("%d/%d", done, totalAddons))
    end

    local function gatherWorkshopIDs()
        local ids = {
            ["2959728255"] = true
        }

        for _, mod in pairs(lia.module.list) do
            local wc = mod.WorkshopContent
            if wc then
                if isstring(wc) then
                    ids[wc] = true
                elseif istable(wc) then
                    for _, v in ipairs(wc) do
                        ids[tostring(v)] = true
                    end
                end
            end
        end
        return ids
    end

    local function startDownload()
        totalAddons = table.Count(addonsQueue)
        remainingAddons = totalAddons
        if totalAddons == 0 then return end
        createPanel()
        updatePanel()
        for id in pairs(addonsQueue) do
            lia.bootstrap("Workshop Downloader", "Downloading workshop " .. id)
            steamworks.DownloadUGC(id, function(path)
                remainingAddons = remainingAddons - 1
                lia.bootstrap("Workshop Downloader", "Completed workshop " .. id)
                if path then game.MountGMA(path) end
                updatePanel()
                if remainingAddons <= 0 then
                    if downloadPanel and downloadPanel:IsValid() then downloadPanel:Remove() end
                    downloadPanel = nil
                end
            end)
        end
    end

    local function processModuleWorkshops()
        table.Empty(addonsQueue)
        for id in pairs(gatherWorkshopIDs()) do
            addonsQueue[id] = true
        end

        startDownload()
    end

    local function processCollectionWorkshops()
        if not lia.config.get("AutoDownloadWorkshop") then return end
        local colID = lia.config.get("CollectionID")
        if not isstring(colID) or colID == "" then return end
        http.Fetch("https://steamcommunity.com/workshop/filedetails/?id=" .. colID, function(body)
            for id in body:gmatch("sharedfile_(%d+)") do
                if not addonsQueue[id] then addonsQueue[id] = true end
            end

            startDownload()
        end)
    end

    net.Receive("WorkshopDownloader_Start", function()
        processModuleWorkshops()
        processCollectionWorkshops()
    end)

    concommand.Add("workshop_force_redownload", function()
        table.Empty(addonsQueue)
        processModuleWorkshops()
        processCollectionWorkshops()
        lia.bootstrap("Workshop Downloader", "Forced redownload initiated")
    end)

    hook.Add("CreateInformationButtons", "WorkshopAddonsInformation", function(pages)
        table.insert(pages, {
            name = L("workshopAddons"),
            drawFunc = function(panel)
                if not lia.config.get("AutoDownloadWorkshop") then return end
                local ids = gatherWorkshopIDs()
                local search = vgui.Create("DTextEntry", panel)
                search:Dock(TOP)
                search:DockMargin(0, 0, 0, 5)
                search:SetTall(30)
                search:SetPlaceholderText(L("searchAddons"))
                local count = 0
                for _ in pairs(ids) do
                    count = count + 1
                end

                local infoPanel = vgui.Create("DPanel", panel)
                infoPanel:Dock(TOP)
                infoPanel:DockMargin(10, 0, 10, 5)
                infoPanel:SetTall(30)
                infoPanel.Paint = function(_, w, h) draw.RoundedBox(4, 0, 0, w, h, Color(30, 30, 30, 200)) end
                local infoLabel = vgui.Create("DLabel", infoPanel)
                infoLabel:Dock(FILL)
                infoLabel:SetFont("liaSmallFont")
                infoLabel:SetTextColor(color_white)
                infoLabel:SetContentAlignment(5)
                infoLabel:SetText("Total Auto Downloaded Addons: " .. count)
                local sc = vgui.Create("DScrollPanel", panel)
                sc:Dock(FILL)
                sc:DockPadding(0, 10, 0, 0)
                local canvas = sc:GetCanvas()
                local previewSize = 200
                local items = {}
                local function createItem(id)
                    steamworks.FileInfo(id, function(info)
                        if not info then return end
                        local item = vgui.Create("DPanel", canvas)
                        item:Dock(TOP)
                        item:DockMargin(0, 0, 0, 10)
                        item.titleText = (info.title or ""):lower()
                        local html = vgui.Create("DHTML", item)
                        html:SetSize(previewSize, previewSize)
                        html:SetMouseInputEnabled(false)
                        html:SetKeyboardInputEnabled(false)
                        html:OpenURL(info.previewurl)
                        local title = vgui.Create("DLabel", item)
                        title:SetFont("liaBigFont")
                        title:SetText(info.title or "ID: " .. id)
                        local desc = vgui.Create("DLabel", item)
                        desc:SetFont("liaMediumFont")
                        desc:SetWrap(true)
                        desc:SetText(info.description or "")
                        function item:PerformLayout()
                            local pad = 10
                            html:SetPos(pad, pad)
                            title:SizeToContents()
                            title:SetPos(pad + previewSize + pad, pad)
                            desc:SetPos(pad + previewSize + pad, pad + title:GetTall() + 5)
                            desc:SetWide(self:GetWide() - pad - previewSize - pad)
                            local _, h = desc:GetContentSize()
                            desc:SetTall(h)
                            self:SetTall(math.max(previewSize + pad * 2, title:GetTall() + 5 + h + pad))
                        end
                    end)
                end

                for id in pairs(ids) do
                    items[id] = true
                    createItem(id)
                end

                local colID = lia.config.get("CollectionID")
                if isstring(colID) and colID ~= "" then
                    http.Fetch("https://steamcommunity.com/workshop/filedetails/?id=" .. colID, function(body)
                        for id in body:gmatch("sharedfile_(%d+)") do
                            if not items[id] then
                                items[id] = true
                                createItem(id)
                            end
                        end
                    end)
                elseif table.Count(ids) == 0 then
                    local lbl = vgui.Create("DLabel", panel)
                    lbl:Dock(TOP)
                    lbl:SetFont("liaMediumFont")
                    lbl:SetText(L("workshopNoCollection"))
                    lbl:SizeToContents()
                end

                search.OnTextChanged = function(self)
                    local q = self:GetValue():lower()
                    for _, item in ipairs(canvas:GetChildren()) do
                        if item.titleText then item:SetVisible(q == "" or item.titleText:find(q, 1, true)) end
                    end

                    canvas:InvalidateLayout()
                end
            end
        })
    end)
end

lia.config.add("AutoDownloadWorkshop", "Auto Download Workshop Content", true, nil, {
    desc = "Automatically download both collection and module-defined WorkshopContent.",
    category = "Workshop",
    type = "Boolean"
})

lia.config.add("CollectionID", "Collection ID", "", function(_, colID)
    if not CLIENT then return end
    local frame = vgui.Create("DFrame")
    frame:SetTitle(L("workshopCollectionPreviewTitle"))
    frame:SetSize(800, 600)
    frame:Center()
    frame:MakePopup()
    local browser = vgui.Create("DHTML", frame)
    browser:Dock(FILL)
    browser:OpenURL("https://steamcommunity.com/workshop/filedetails/?id=" .. colID)
end, {
    desc = "Steam Workshop collection used for auto-downloading.",
    category = "Workshop",
    type = "Generic"
})