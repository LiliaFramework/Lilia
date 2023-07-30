netstream.Hook("DisplayCharList", function(sendData, targetSteamIDsafe)
    local fr = vgui.Create("DFrame")
    fr:SetTitle("Charlist for SteamID64: " .. targetSteamIDsafe)
    fr:SetSize(1000, 500)
    fr:Center()
    fr:MakePopup()
    local listView = vgui.Create("DListView", fr)
    listView:Dock(FILL)
    listView:AddColumn("ID")
    listView:AddColumn("Name")
    listView:AddColumn("Desc")
    listView:AddColumn("Faction")
    listView:AddColumn("Banned")
    listView:AddColumn("BanningAdminName")
    listView:AddColumn("BanningAdminSteamID")
    listView:AddColumn("BanningAdminRank")
    listView:AddColumn("CharMoney")
    listView:AddColumn("SafeBox Money")

    for k, v in pairs(sendData or {}) do
        local Line = listView:AddLine(v.ID, v.Name, v.Desc, v.Faction, v.Banned, v.BanningAdminName, v.BanningAdminSteamID, v.BanningAdminRank)

        if v.Banned == "Yes" then
            Line.DoPaint = Line.Paint

            Line.Paint = function(pnl, w, h)
                surface.SetDrawColor(200, 100, 100)
                surface.DrawRect(0, 0, w, h)
                pnl:DoPaint(w, h)
            end
        end

        Line.CharID = v.ID
    end

    if LocalPlayer():IsAdmin() then
        listView.DoDoubleClick = function(lView, lineID, ln)
            if ln.CharID then
                local dMenu = DermaMenu()

                local opt1 = dMenu:AddOption("Ban Character", function()
                    LocalPlayer():ConCommand([[say "/charbanoffline ]] .. ln.CharID .. [["]])
                end)

                opt1:SetIcon("icon16/cancel.png")

                local opt2 = dMenu:AddOption("Unban Character", function()
                    LocalPlayer():ConCommand([[say "/charunbanoffline ]] .. ln.CharID .. [["]])
                end)

                opt2:SetIcon("icon16/accept.png")
                dMenu:Open()
            end
        end
    end
end)

-------------------------------------------------------------------------------------------------------------------------
lia.command.add("charunbanoffline", {
    syntax = "<string charID>",
    onRun = function(client, arguments) end
})

-------------------------------------------------------------------------------------------------------------------------
lia.command.add("charbanoffline", {
    syntax = "<string charID>",
    onRun = function(client, arguments) end
})

-------------------------------------------------------------------------------------------------------------------------
lia.command.add("charlist", {
    syntax = "<string playerORsteamID>",
    onRun = function(client, arguments) end
})