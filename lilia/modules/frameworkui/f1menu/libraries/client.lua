---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
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
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
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

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function MODULE:OnCharInfoSetup(infoPanel)
    if not IsValid(infoPanel) then return end
    local mdl = infoPanel
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
    if not IsValid(entity) then return end
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

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function MODULE:CreateMenuButtons(tabs)
    if hook.Run("CanPlayerViewInventory") ~= false then
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
        for k, _ in ipairs(lia.class.list) do
            if not lia.class.canBe(LocalPlayer(), k) then
                continue
            else
                tabs["classes"] = function(panel) panel:Add("liaClasses") end
                return
            end
        end
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

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function MODULE:BuildHelpMenu(tabs)
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
                ]]):format(v.name or "Unknown", L"desc", v.desc or L"noDesc", "Discord", v.discord or "Unknown", L"author", lia.module.namecache[v.author] or v.author or "Unknown")
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

    if self.RulesEnabled then tabs["Rules"] = function() return MODULE:GenerateRules() end end
    if self.TutorialEnabled then tabs["Tutorial"] = function() return MODULE:GenerateTutorial() end end
end
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
