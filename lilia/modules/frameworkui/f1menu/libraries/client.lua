local HELP_DEFAULT = [[
    <div id="parent">
        <div id="child">
            <center>
                <img src="https://i.imgur.com/yY3wT30.png"></img><br><br>
                <font size=15>]] .. L"helpDefault" .. [[</font>
            </center>
        </div>
    </div>
]]
function MODULE:LoadCharInformation()
    hook.Run("AddSection", "General Info", Color(0, 0, 0), 1)
    hook.Run("AddTextField", "General Info", "name", "Name", function() return LocalPlayer():getChar():getName() end)
    hook.Run("AddTextField", "General Info", "desc", "Description", function() return LocalPlayer():getChar():getDesc() end)
    hook.Run("AddTextField", "General Info", "money", "Money", function() return LocalPlayer():getMoney() end)
end

function MODULE:AddSection(sectionName, color, priority)
    hook.Run("F1OnAddSection", sectionName, color, priority)
    self.CharacterInformations[sectionName] = {
        fields = {},
        color = color or Color(255, 255, 255),
        priority = priority or 999
    }
end

function MODULE:AddTextField(sectionName, fieldName, labelText, valueFunc)
    hook.Run("F1OnAddTextField", sectionName, fieldName, labelText, valueFunc)
    local section = self.CharacterInformations[sectionName]
    if section then
        table.insert(section.fields, {
            type = "text",
            name = fieldName,
            label = labelText,
            value = valueFunc or function() return "" end
        })
    end
end

function MODULE:AddBarField(sectionName, fieldName, labelText, minFunc, maxFunc, valueFunc)
    hook.Run("F1OnAddBarField", sectionName, fieldName, labelText, minFunc, maxFunc, valueFunc)
    local section = self.CharacterInformations[sectionName]
    if section then
        table.insert(section.fields, {
            type = "bar",
            name = fieldName,
            label = labelText,
            min = minFunc or function() return 0 end,
            max = maxFunc or function() return 100 end,
            value = valueFunc or function() return 0 end
        })
    end
end

function MODULE:PlayerBindPress(client, bind, pressed)
    if bind:lower():find("gm_showhelp") and pressed then
        if IsValid(lia.gui.menu) then
            lia.gui.menu:remove()
        elseif client:getChar() then
            vgui.Create("liaMenu")
        end
        return true
    end
end

function MODULE:CanDisplayCharInfo(name)
    local client = LocalPlayer()
    local character = client:getChar()
    local class = lia.class.list[character:getClass()]
    if name == "class" and not class then return false end
    return true
end

function MODULE:CreateMenuButtons(tabs)
    local client = LocalPlayer()
    if hook.Run("CanPlayerViewInventory") ~= false then
        tabs["inv"] = function(panel)
            local inventory = client:getChar():getInv()
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

    if table.Count(lia.class.list) > 1 then
        local hasClass = false
        for k, _ in ipairs(lia.class.list) do
            if lia.class.canBe(client, k) then hasClass = true end
        end

        if hasClass then tabs["classes"] = function(panel) panel:Add("liaClasses") end end
    end

    tabs["help"] = function(panel)
        local html
        local header = [[<html>
			<head>
				<style>
					@import url(http://fonts.googleapis.com/earlyaccess/jejugothic.css);

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
        tree.OnNodeSelected = function(_, node)
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

function MODULE:BuildHelpMenu(tabs)
    local client = LocalPlayer()
    tabs["commands"] = function()
        local body = ""
        for k, v in SortedPairs(lia.command.list) do
            if lia.command.hasAccess(client, k, nil) then body = body .. "<h2>/" .. k .. "</h2><strong>Syntax:</strong> <em>" .. v.syntax .. "</em><br /><br />" end
        end
        return body
    end

    tabs["flags"] = function()
        local body = [[<table border="0" cellspacing="8px">]]
        for k, v in SortedPairs(lia.flag.list) do
            local icon
            if client:getChar():hasFlags(k) then
                icon = [[<img src="asset://garrysmod/materials/icon16/tick.png" />]]
            else
                icon = [[<img src="asset://garrysmod/materials/icon16/cross.png" />]]
            end

            body = body .. Format([[
                <tr>
                    <td>%s</td>
                    <td><b>%s</b></td>
                    <td>%s</td>
                </tr>
            ]], icon, k, v.desc)
        end
        return body .. "</table>"
    end

    tabs["modules"] = function()
        local body = ""
        for _, v in SortedPairsByMemberValue(lia.module.list, "name") do
            if v.MenuNoShow then continue end
            local version = v.version or "1.0"
            body = (body .. [[
                <p>
                    <span style="font-size: 22;"><b>%s</b><br /></span>
                    <span style="font-size: smaller;">
                    <b>%s</b>: %s<br />
                    <b>%s</b>: %s<br />
                    <b>%s</b>: %s<br />
                    <b>%s</b>: %s<br />
                ]]):format(v.name or "Unknown", L"desc", v.desc or L"noDesc", "Discord", v.discord or "Unknown", L"author", ((not isstring(v.author) and lia.module.namecache[v.author]) or v.author) or "Unknown", L"version", version)
            body = body .. "</span></p>"
        end
        return body
    end

    if self.FAQEnabled then
        tabs["FAQ"] = function()
            local body = ""
            for title, text in SortedPairs(self.FAQQuestions) do
                body = body .. "<h2>" .. title .. "</h2>" .. text .. "<br /><br />"
            end
            return body
        end
    end

    if self.RulesEnabled then tabs["Rules"] = function() return F1MenuCore:GenerateRules() end end
    if self.TutorialEnabled then tabs["Tutorial"] = function() return F1MenuCore:GenerateTutorial() end end
end