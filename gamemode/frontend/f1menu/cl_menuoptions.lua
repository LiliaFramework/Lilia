--------------------------------------------------------------------------------------------------------
hook.Add("CreateMenuButtons", "liaInventory", function(tabs)
        if hook.Run("CanPlayerViewInventory") == false then return end
        tabs["inv"] = function(panel)
            local inventory = LocalPlayer():getChar():getInv()
            if not inventory then return end
            local mainPanel = inventory:show(panel)
            local sortPanels = {}
            local totalSize = {
                x = 0,
                y = 0,
                p = 0
            }

            table.insert(sortPanels, mainPanel)
            totalSize.x = totalSize.x + mainPanel:GetWide() + 10
            totalSize.y = math.max(totalSize.y, mainPanel:GetTall())
            for id, item in pairs(inventory:getItems()) do
                if item.isBag and hook.Run("CanOpenBagPanel", item) ~= false then
                    local inventory = item:getInv()
                    local childPanels = inventory:show(mainPanel)
                    lia.gui["inv" .. inventory:getID()] = childPanels
                    table.insert(sortPanels, childPanels)
                    totalSize.x = totalSize.x + childPanels:GetWide() + 10
                    totalSize.y = math.max(totalSize.y, childPanels:GetTall())
                end
            end

            local px, py, pw, ph = mainPanel:GetBounds()
            local x, y = px + pw / 2 - totalSize.x / 2, py + ph / 2
            for _, panel in pairs(sortPanels) do
                panel:ShowCloseButton(true)
                panel:SetPos(x, y - panel:GetTall() / 2)
                x = x + panel:GetWide() + 10
            end

            hook.Add("PostRenderVGUI", mainPanel, function() hook.Run("PostDrawInventory", mainPanel) end)
        end
    end
)
--------------------------------------------------------------------------------------------------------
hook.Add("CreateMenuButtons", "liaClasses", function(tabs)
        if hook.Run("CanPlayerViewClasses") == false then return end
        local cnt = table.Count(lia.class.list)
        if cnt <= 1 then return end
        for k, v in ipairs(lia.class.list) do
            if not lia.class.canBe(LocalPlayer(), k) then
                continue
            else
                tabs["classes"] = function(panel) panel:Add("liaClasses") end
                return
            end
        end
    end
)
--------------------------------------------------------------------------------------------------------
hook.Add("CreateMenuButtons", "liaHelpMenu", function(tabs)
        if hook.Run("CanPlayerViewHelp") == false then return end
        HELP_DEFAULT = [[
        <div id="parent"><div id="child">
            <center>
                <img src="https:/static.miraheze.org/liliawiki/2/26/Lilia.png"></img>
                <br><font size=15>]] .. L"helpDefault" .. [[</font>
            </center>
        </div></div>
    ]]
        tabs["help"] = function(panel)
            local html
            local header = [[
            <html>
            <head>
                <style>
                    @import url(http:/fonts.googleapis.com/earlyaccess/jejugothic.css);

                    #parent {
                        padding: 5% 0;
                    }

                    #child {
                        padding: 10% 0;
                    }

                    body {
                        color: #FAFAFA;
                        font-family: 'Jeju Gothic', serif;
                        -webkit-font-smoothing: antialiased;
                    }

                    h2 {
                        margin: 0;
                    }
                </style>
            </head>
            <body>
        ]]
            local tree = panel:Add("DTree")
            tree:SetPadding(5)
            tree:Dock(LEFT)
            tree:SetWide(180)
            tree:DockMargin(0, 0, 15, 0)
            tree.OnNodeSelected = function(this, node)
                if node.onGetHTML then
                    local source = node:onGetHTML()
                    if IsValid(helpPanel) then helpPanel:Remove() end
                    if lia.gui.creditsPanel then lia.gui.creditsPanel:Remove() end
                    helpPanel = panel:Add("DListView")
                    helpPanel:Dock(FILL)
                    helpPanel.Paint = function() end
                    helpPanel:InvalidateLayout(true)
                    html = helpPanel:Add("DHTML")
                    html:Dock(FILL)
                    html:SetHTML(header .. HELP_DEFAULT)
                    if source and source:sub(1, 4) == "http" then
                        html:OpenURL(source)
                    else
                        html:SetHTML(header .. node:onGetHTML() .. "</body></html>")
                    end
                end
            end

            if not IsValid(helpPanel) then
                helpPanel = panel:Add("DListView")
                helpPanel:Dock(FILL)
                helpPanel.Paint = function() end
                html = helpPanel:Add("DHTML")
                html:Dock(FILL)
                html:SetHTML(header .. HELP_DEFAULT)
            end

            tabs = {}
            hook.Run("BuildHelpMenu", tabs)
            for k, v in SortedPairs(tabs) do
                if not isfunction(v) then
                    local source = v
                    v = function() return tostring(source) end
                end

                tree:AddNode(L(k)).onGetHTML = v or function() return "" end
            end
        end
    end
)
--------------------------------------------------------------------------------------------------------