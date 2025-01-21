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
  tabs["Status"] = function(panel)
    panel.rotationAngle = 45
    panel.rotationSpeed = 0.5
    panel.info = vgui.Create("liaCharInfo", panel)
    panel.info:setup()
    panel.info:SetAlpha(0)
    panel.info:AlphaTo(255, 0.5)
    panel.model = panel:Add("liaModelPanel")
    panel.model:SetWide(ScrW() * 0.25)
    panel.model:SetFOV(50)
    panel.model:SetTall(ScrH() - 50)
    panel.model:SetPos(ScrW() - panel.model:GetWide() - 150, 150)
    panel.model:SetModel(client:GetModel())
    panel.model.Entity:SetSkin(client:GetSkin())
    for _, v in ipairs(client:GetBodyGroups()) do
      panel.model.Entity:SetBodygroup(v.id, client:GetBodygroup(v.id))
    end

    local ent = panel.model.Entity
    if ent and IsValid(ent) then
      local mats = client:GetMaterials()
      for k, _ in pairs(mats) do
        ent:SetSubMaterial(k - 1, client:GetSubMaterial(k - 1))
      end
    end

    panel.model.Think = function()
      local rotateLeft = input.IsKeyDown(KEY_A)
      local rotateRight = input.IsKeyDown(KEY_D)
      if rotateLeft then
        panel.rotationAngle = panel.rotationAngle - panel.rotationSpeed
      elseif rotateRight then
        panel.rotationAngle = panel.rotationAngle + panel.rotationSpeed
      end

      if IsValid(panel.model) and IsValid(panel.model.Entity) then
        local Angles = Angle(0, panel.rotationAngle, 0)
        panel.model.Entity:SetAngles(Angles)
      end
    end
  end

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

  tabs["help"] = function(panel)
    local MenuColors = lia.color.ReturnMainAdjustedColors()
    local sidebar = panel:Add("DPanel")
    sidebar:Dock(LEFT)
    sidebar:SetWide(200)
    sidebar:DockMargin(20, 20, 0, 20)
    sidebar.Paint = function() end
    local mainContent = panel:Add("DPanel")
    mainContent:Dock(FILL)
    mainContent.Paint = function() end
    local html = mainContent:Add("DHTML")
    html:Dock(FILL)
    local helpTabs = {}
    hook.Run("BuildHelpMenu", helpTabs)
    panel.activeTab = nil
    panel.tabList = {}
    for k, v in SortedPairs(helpTabs) do
      local tabName = L(k)
      local callback = v
      local button = sidebar:Add("DButton")
      button:SetText(tabName)
      button:SetTextColor(MenuColors.text)
      button:SetFont("liaMediumFont")
      button:SetExpensiveShadow(1, Color(0, 0, 0, 100))
      button:SetContentAlignment(5)
      button:SetTall(50)
      button:Dock(TOP)
      button:DockMargin(0, 0, 10, 10)
      button.text_color = MenuColors.text
      button.Paint = function(btn, w, h)
        local hovered = btn:IsHovered()
        if hovered then
          local underlineWidth = w * 0.4
          local underlineX = (w - underlineWidth) * 0.5
          local underlineY = h - 4
          surface.SetDrawColor(255, 255, 255, 80)
          surface.DrawRect(underlineX, underlineY, underlineWidth, 2)
        end

        if panel.activeTab == btn then
          surface.SetDrawColor(color_white)
          surface.DrawOutlinedRect(0, 0, w, h)
        end
      end

      button.DoClick = function()
        panel.activeTab = button
        mainContent:Clear()
        local tabPanel = mainContent:Add("DPanel")
        tabPanel:Dock(FILL)
        tabPanel.Paint = function() end
        callback(tabPanel, sidebar)
      end

      panel.tabList[tabName] = button
    end
  end

  if #lia.faction.getClasses(LocalPlayer():getChar():getFaction()) > 1 then tabs["classes"] = function(panel) panel:Add("liaClasses") end end
end

function MODULE:BuildHelpMenu(tabs)
  local client = LocalPlayer()
  local function createListPanel(parent, columns)
    local panel = vgui.Create("DPanel", parent)
    panel:SetSize(sW(1360), sH(768))
    panel:SetPos(sW(50), sH(150))
    panel.Paint = function(_, w, h)
      surface.SetDrawColor(30, 30, 30, 150)
      surface.DrawRect(0, 0, w, h)
    end

    local scroll = panel:Add("DScrollPanel")
    scroll:Dock(FILL)
    scroll:DockMargin(5, 5, 5, 5)
    local header = scroll:Add("DPanel")
    header:SetTall(30)
    header:Dock(TOP)
    header.Paint = function(_, w, h)
      surface.SetDrawColor(50, 50, 50, 200)
      surface.DrawRect(0, 0, w, h)
      surface.SetDrawColor(100, 100, 100, 255)
      surface.DrawOutlinedRect(0, 0, w, h)
    end

    header.Columns = {}
    for _, colName in ipairs(columns) do
      local lbl = header:Add("DLabel")
      lbl:SetText(colName)
      lbl:SetTextColor(Color(255, 255, 255))
      lbl:SetFont("liaMiniFont")
      lbl:SetContentAlignment(5)
      table.insert(header.Columns, lbl)
    end

    function header:PerformLayout(w, h)
      local colCount = #self.Columns
      if colCount > 0 then
        local colWidth = w / colCount
        local xPos = 0
        for _, lbl in ipairs(self.Columns) do
          lbl:SetPos(xPos, 0)
          lbl:SetSize(colWidth, h)
          xPos = xPos + colWidth
        end
      end
    end

    local function addRow(data)
      local row = scroll:Add("DPanel")
      row:SetTall(25)
      row:Dock(TOP)
      row:DockMargin(0, 0, 0, 2)
      row.Paint = function(_, w, h)
        surface.SetDrawColor(0, 0, 0, 100)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(80, 80, 80, 200)
        surface.DrawOutlinedRect(0, 0, w, h)
      end

      row.Columns = {}
      for _, value in ipairs(data) do
        local lbl = row:Add("DLabel")
        lbl:SetText(value or "")
        lbl:SetTextColor(Color(255, 255, 255))
        lbl:SetFont("liaMiniFont")
        lbl:SetContentAlignment(5)
        table.insert(row.Columns, lbl)
      end

      function row:PerformLayout(w, h)
        local colCount = #self.Columns
        if colCount > 0 then
          local colWidth = w / colCount
          local xPos = 0
          for _, lbl in ipairs(self.Columns) do
            lbl:SetPos(xPos, 0)
            lbl:SetSize(colWidth, h)
            xPos = xPos + colWidth
          end
        end
      end
    end
    return panel, addRow
  end

  if hook.Run("CanPlayerViewCommands") ~= false then
    tabs["Commands"] = function(parent)
      local panel, addRow = createListPanel(parent, {"Command", "Syntax", "Privilege"})
      for cmdName, cmdData in SortedPairs(lia.command.list) do
        local hasAccess, privilege = lia.command.hasAccess(LocalPlayer(), cmdName, cmdData)
        if hasAccess then addRow({"/" .. cmdName, cmdData.syntax or "", privilege or "None"}) end
      end
      return panel
    end
  end

  tabs["flags"] = function(parent)
    local panel, addRow = createListPanel(parent, {"Status", "Flag", "Description"})
    for flagName, flagData in SortedPairs(lia.flag.list) do
      local status = client:getChar():hasFlags(flagName) and "✓" or "✗"
      addRow({status, flagName, flagData.desc or ""})
    end
    return panel
  end

  tabs["modules"] = function(parent)
    local panel, addRow = createListPanel(parent, {"Module", "Description", "Discord", "Author", "Version"})
    for _, module in SortedPairsByMemberValue(lia.module.list, "name") do
      if module.MenuNoShow then continue end
      local version = module.version or "1.0"
      local author = not isstring(module.author) and lia.module.namecache[module.author] or module.author or "Unknown"
      addRow({module.name or "Unknown", module.desc or "No Description", module.discord or "Unknown", author, version})
    end
    return panel
  end
end