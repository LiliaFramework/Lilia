net.Receive("SpecialDocumentsExchange", function()
    local itemID = net.ReadDouble()

    Derma_StringRequest("Enter Special Document Link", "Input the link to a googledoc that is supposed to be shown (must start with https://docs.google.com/)", "https://docs.google.com/", function(str)
        local findString = "https://docs.google.com/"

        if str:sub(1, #findString) ~= findString then
            lia.util.notify("The link must start with https://docs.google.com/")

            return
        end

        http.Fetch(str, function(body, len, headers, code)
            local _, _, titleName = body:find("<title>(.*)</title>")
            net.Start("SpecialDocumentsExchange")
            net.WriteDouble(itemID)
            net.WriteString(str)
            net.WriteString(titleName or "No Title")
            net.SendToServer()
            lia.item.instances[itemID].overrideDesc = str
            lia.item.instances[itemID].overrideName = titleName

            if lia.gui.menu and lia.gui.inv1 then
                local oldPosX, oldPosY = lia.gui.inv1:GetPos()
                lia.gui.inv1:Remove()
                lia.gui.inv1 = lia.gui.menu.tabs:Add("liaInventory")
                lia.gui.inv1.childPanels = {}
                lia.gui.inv1:setInventory(LocalPlayer():getChar():getInv())
                lia.gui.inv1:SetPos(oldPosX, oldPosY)
            end
        end)
    end)
end)

net.Receive("SpecialDocumentsSendURL", function()
    local openURL = net.ReadString()
    local clName = net.ReadString()
    local itemName = net.ReadString()
    local findString = "https://docs.google.com/"
    if openURL:sub(1, #findString) ~= findString then return end

    Derma_Query(clName .. " wants to show you Special Documents (" .. itemName .. ")\nThis will open a link (hopefully) to a google doc in vgui browser.\nWe are not responsible for the content of the page.\n\nLink: " .. openURL, "Special Documents being Shown", "Open Link", function()
        gui.OpenURL(openURL)
    end, "Cancel")
end)

net.Receive("SpecialDocumentsSetItemName", function()
    local itemID = net.ReadDouble()
    local setName = net.ReadString()
    local setDesc = net.ReadString()

    if lia.item.instances[itemID] then
        lia.item.instances[itemID].overrideName = setName
        lia.item.instances[itemID].overrideDesc = setDesc
    end
end)