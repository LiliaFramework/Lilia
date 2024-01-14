local HELP_DEFAULT
function F1MenuCore:PlayerBindPress(client, bind, pressed)
    if bind:lower():find("gm_showhelp") and pressed then
        if IsValid(lia.gui.menu) then
            lia.gui.menu:remove()
        elseif client:getChar() then
            vgui.Create("liaMenu")
        end
        return true
    end
end

function F1MenuCore:OnCharInfoSetup(infoPanel)
    if not IsValid(infoPanel.model) then return end
    local mdl = infoPanel.model
    local entity = mdl.Entity
    local client = LocalPlayer()
    if not IsValid(client) or not client:Alive() then return end
    local weapon = client:GetActiveWeapon()
    if not IsValid(weapon) then return end
    local weapModel = ClientsideModel(weapon:GetModel(), RENDERGROUP_BOTH)
    if not IsValid(weapModel) then return end
    weapModel:SetParent(entity)
    weapModel:AddEffects(EF_BONEMERGE)
    weapModel:SetSkin(weapon:GetSkin())
    weapModel:SetColor(weapon:GetColor())
    weapModel:SetNoDraw(true)
    entity.weapon = weapModel
    local act = ACT_MP_STAND_IDLE
    local model = entity:GetModel():lower()
    local class = lia.anim.getModelClass(model)
    local tree = lia.anim[class]
    if not tree then return end
    local subClass = weapon.HoldType or weapon:GetHoldType()
    subClass = lia.anim.HoldTypeTranslator[subClass] or subClass
    if tree[subClass] and tree[subClass][act] then
        local branch = tree[subClass][act]
        local act2 = istable(branch) and branch[1] or branch
        if isstring(act2) then
            act2 = entity:LookupSequence(act2)
        else
            act2 = entity:SelectWeightedSequence(act2)
        end

        entity:ResetSequence(act2)
    end
end

function F1MenuCore:CreateMenuButtons(tabs)
    if (hook.GetTable()["CanPlayerViewInventory"] and hook.Run("CanPlayerViewInventory") ~= false) or (not hook.GetTable()["CanPlayerViewInventory"] and LocalPlayer():Alive()) then
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
            for _, item in pairs(inventory:getItems()) do
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

    local cnt = table.Count(lia.class.list)
    if cnt > 1 then
        for k, _ in ipairs(lia.class.list) do
            if not lia.class.canBe(LocalPlayer(), k) then
                continue
            else
                tabs["classes"] = function(panel) panel:Add("liaClasses") end
                return
            end
        end
    end

    HELP_DEFAULT = [[
			<div id="parent"><div id="child">
				<center>
				    <img src="https://i.imgur.com/yY3wT30.png"></img>
					<br><font size=15>]] .. L"helpDefault" .. [[</font>
				</center>
			</div></div>
		]]
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

function F1MenuCore:BuildHelpMenu(tabs)
    tabs["commands"] = function(_, _)
        local body = ""
        for k, v in SortedPairs(lia.command.list) do
            if lia.command.hasAccess(LocalPlayer(), k, nil) then body = body .. "<h2>/" .. k .. "</h2><strong>Syntax:</strong> <em>" .. v.syntax .. "</em><br /><br />" end
        end
        return body
    end

    tabs["flags"] = function(_)
        local body = [[<table border="0" cellspacing="8px">]]
        for k, v in SortedPairs(lia.flag.list) do
            local icon
            if LocalPlayer():getChar():hasFlags(k) then
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

    tabs["modules"] = function(_)
        local body = ""
        for _, v in SortedPairsByMemberValue(lia.module.list, "name") do
            if v.MenuNoShow then continue end
            body = (body .. [[
                <p>
                    <span style="font-size: 22;"><b>%s</b><br /></span>
                    <span style="font-size: smaller;">
                    <b>%s</b>: %s<br />
                    <b>%s</b>: %s<br /> <!-- Added line break here -->
                    <b>%s</b>: %s<br />
                ]]):format(v.name or "Unknown", L"desc", v.desc or L"noDesc", "Discord", v.discord, L"author", lia.module.namecache[v.author] or v.author)
            if v.version then body = body .. "<br /><b>" .. L"version" .. "</b>: " .. v.version end
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

function F1MenuCore:OpenDescGenerator()
    if not self.AutomaticDescriptionEnabled then
        LocalPlayer():ChatPrint("This feature is disabled. Please tell the server owner to enable it.")
        return
    end

    local frame = vgui.Create("DFrame")
    frame:SetSize(300, 150)
    frame:SetTitle("Description Generator")
    frame:Center()
    frame:MakePopup()
    local elements = {}
    for _, option in ipairs(self.AutomaticDescriptionCustomizationOptions) do
        local label = vgui.Create("DLabel", frame)
        label:SetPos(10, 30 + (_ - 1) * 18)
        label:SetText(option.Name)
        label:SizeToContents()
        local dropdown = vgui.Create("DComboBox", frame)
        dropdown:SetPos(120, 30 + (_ - 1) * 18)
        dropdown:SetSize(160, 18)
        for _, subOption in ipairs(option.Options) do
            dropdown:AddChoice(subOption)
        end

        elements[option.Name] = {
            Label = label,
            Dropdown = dropdown
        }
    end

    local setDescButton = vgui.Create("DButton", frame)
    setDescButton:SetText("Set Description")
    setDescButton:SetPos(10, 120)
    setDescButton:SetSize(280, 18)
    setDescButton.DoClick = function()
        local description = "A "
        local gender = elements["Gender"].Dropdown:GetValue() or "Unknown"
        local height = elements["Height"].Dropdown:GetValue() or "Unknown"
        local hairColor = elements["Hair Color"].Dropdown:GetValue() or "Unknown"
        local eyeColor = elements["Eye Color"].Dropdown:GetValue() or "Unknown"
        description = description .. gender .. " appears in front of you, being " .. height .. " and having " .. hairColor .. " colored hair and " .. eyeColor .. " eyes."
        lia.command.send("chardesc", description)
        frame:Remove()
    end
end
