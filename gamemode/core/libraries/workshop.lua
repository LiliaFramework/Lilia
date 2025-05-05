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
        local ids = {}
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
            lia.util.drawText("Downloading workshop content...", ScrW() - 10, 45, Color(250, 250, 250), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, "liaMediumFont")
        end)

        for id in pairs(addonsToDownload) do
            steamworks.DownloadUGC(id, function(path)
                addonsCount = addonsCount - 1
                checkDownloadStatus()
                if path then game.MountGMA(path) end
            end)
        end
    end

    local function processModuleWorkshops()
        table.Empty(addonsToDownload)
        if not steamworks.IsSubscribed("2959728255") then
            addonsToDownload["2959728255"] = true
        else
            downloadedAddons["2959728255"] = true
        end

        addonsCount = table.Count(addonsToDownload)
        if addonsCount > 0 then
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
    frame:SetTitle("Workshop Collection Preview – Confirm You Are Using the Correct Collection")
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
        name = "Workshop Addons",
        drawFunc = function(panel)
            if not lia.config.get("AutoDownloadWorkshop") then return end
            local collectionId = lia.config.get("CollectionID")
            if not isstring(collectionId) or collectionId == "" then
                local label = vgui.Create("DLabel", panel)
                label:Dock(TOP)
                label:SetFont("liaMediumFont")
                label:SetText("No Collection Defined!")
                label:SizeToContents()
                return
            end

            local scroll = vgui.Create("DScrollPanel", panel)
            scroll:Dock(FILL)
            scroll:DockPadding(0, 10, 0, 0)
            local canvas = scroll:GetCanvas()
            local previewSize = 200
            http.Fetch(string.format("https://steamcommunity.com/workshop/filedetails/?id=%s", collectionId), function(body)
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
                        function item:PerformLayout(w, h)
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
                    end)
                end
            end)
        end
    })
end)