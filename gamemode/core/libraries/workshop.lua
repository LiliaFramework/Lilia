if SERVER then
    util.AddNetworkString("WorkshopDownloader_Start")
    hook.Add("PlayerInitialSpawn", "WorkshopDownloader_PlayerInitialSpawn", function(ply)
        timer.Simple(10, function()
            if not IsValid(ply) then return end
            net.Start("WorkshopDownloader_Start")
            net.Send(ply)
        end)
    end)
else
    local isDownloading = false
    local addonsToDownload = {}
    local downloadedAddons = {}
    local addonsCount = 0
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

    local function checkDownloadStatus()
        if addonsCount <= 0 then
            isDownloading = false
            hook.Remove("PostDrawHUD", "WorkshopStatus")
        end
    end

    local function downloadMissing()
        hook.Add("PostDrawHUD", "WorkshopStatus", function()
            surface.SetDrawColor(20, 0, 20, 200)
            surface.DrawRect(ScrW() - 260, 5, 255, 60)
            lia.util.drawText("T", ScrW() - 125, 20, Color(250, math.abs(math.cos(RealTime() * 2) * 120), math.abs(math.cos(RealTime() * 2) * 120)), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, "liaMediumFont")
            lia.util.drawText(L("workshopDownloading"), ScrW() - 10, 45, Color(250, 250, 250), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, "liaMediumFont")
        end)

        for id in pairs(addonsToDownload) do
            lia.bootstrap("Workshop Downloader", "Downloading workshop " .. id)
            steamworks.DownloadUGC(id, function(path)
                addonsCount = addonsCount - 1
                lia.bootstrap("Workshop Downloader", "Completed workshop " .. id)
                checkDownloadStatus()
                if path then game.MountGMA(path) end
            end)
        end
    end

    local function processModuleWorkshops()
        local ids = gatherWorkshopIDs()
        table.Empty(addonsToDownload)
        for id in pairs(ids) do
            if not downloadedAddons[id] then
                addonsToDownload[id] = true
                lia.bootstrap("Workshop Downloader", "Queued workshop " .. id)
            end
        end

        addonsCount = table.Count(addonsToDownload)
        if addonsCount > 0 then
            lia.bootstrap("Workshop Downloader", "Starting download of " .. addonsCount .. " addons")
            isDownloading = true
            downloadMissing()
        end
    end

    local function processCollectionWorkshops()
        if not lia.config.get("AutoDownloadWorkshop") then return end
        local collectionID = lia.config.get("CollectionID")
        if not collectionID or not isstring(collectionID) then return end
        http.Fetch(("https://steamcommunity.com/workshop/filedetails/?id=%s"):format(collectionID), function(body)
            for id in body:gmatch("sharedfile_(%d+)") do
                if not addonsToDownload[id] and not downloadedAddons[id] then
                    if not steamworks.IsSubscribed(id) then
                        addonsToDownload[id] = true
                    else
                        downloadedAddons[id] = true
                    end
                end
            end

            addonsCount = table.Count(addonsToDownload)
            if addonsCount > 0 then
                isDownloading = true
                downloadMissing()
            end
        end)
    end

    net.Receive("WorkshopDownloader_Start", function()
        processModuleWorkshops()
        if lia.config.get("AutoDownloadWorkshop") then processCollectionWorkshops() end
    end)

    timer.Create("WorkshopAutoUpdater", 300, 0, function()
        if not isDownloading then
            processModuleWorkshops()
            if lia.config.get("AutoDownloadWorkshop") then processCollectionWorkshops() end
        end
    end)
end

lia.config.add("AutoDownloadWorkshop", "Auto Download Workshop Content", true, nil, {
    desc = "Automatically download both collection and module-defined WorkshopContent.",
    category = "Workshop",
    type = "Boolean"
})

lia.config.add("CollectionID", "Collection ID", "", function(_, id)
    if not CLIENT then return end
    local frame = vgui.Create("DFrame")
    frame:SetTitle(L("workshopCollectionPreviewTitle"))
    frame:SetScaledSize(800, 600)
    frame:Center()
    frame:MakePopup()
    local browser = frame:Add("DHTML")
    browser:Dock(FILL)
    browser:OpenURL(("https://steamcommunity.com/workshop/filedetails/?id=%d"):format(id))
end, {
    desc = "Steam Workshop collection used for auto-downloading.",
    category = "Workshop",
    type = "Generic"
})

hook.Add("CreateInformationButtons", "WorkshopAddonsInformation", function(pages)
    table.insert(pages, {
        name = L("workshopAddons"),
        drawFunc = function(panel)
            if not lia.config.get("AutoDownloadWorkshop") then return end
            local collectionId = lia.config.get("CollectionID")
            if not isstring(collectionId) or collectionId == "" then
                local label = vgui.Create("DLabel", panel)
                label:Dock(TOP)
                label:SetFont("liaMediumFont")
                label:SetText(L("workshopNoCollection"))
                label:SizeToContents()
                return
            end

            local search = vgui.Create("DTextEntry", panel)
            search:Dock(TOP)
            search:DockMargin(0, 0, 0, 5)
            search:SetTall(30)
            search:SetPlaceholderText(L("searchAddons"))
            local scroll = vgui.Create("DScrollPanel", panel)
            scroll:Dock(FILL)
            scroll:DockPadding(0, 10, 0, 0)
            local canvas = scroll:GetCanvas()
            local previewSize = 200
            local items = {}
            http.Fetch("https://steamcommunity.com/workshop/filedetails/?id=" .. collectionId, function(body)
                local ids = {}
                for id in body:gmatch("sharedfile_(%d+)") do
                    ids[id] = true
                end

                for id in pairs(ids) do
                    steamworks.FileInfo(id, function(info)
                        if not info then return end
                        local item = vgui.Create("DPanel", canvas)
                        item:Dock(TOP)
                        item:DockMargin(0, 0, 0, 10)
                        item.infoText = (info.title or ""):lower() .. " " .. (info.description or ""):lower()
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
                            local xOff = pad + previewSize + pad
                            local wrapW = self:GetWide() - xOff - pad
                            desc:SetPos(xOff, pad + title:GetTall() + 5)
                            desc:SetWide(wrapW)
                            local _, hDesc = desc:GetContentSize()
                            desc:SetTall(hDesc)
                            local totalH = math.max(previewSize + pad * 2, title:GetTall() + 5 + hDesc + pad)
                            self:SetTall(totalH)
                        end

                        items[#items + 1] = item
                    end)
                end
            end)

            search.OnTextChanged = function(self)
                local q = self:GetValue():lower()
                for _, item in ipairs(items) do
                    item:SetVisible(q == "" or item.infoText:find(q, 1, true))
                end

                canvas:InvalidateLayout()
            end
        end
    })
end)