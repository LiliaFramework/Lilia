local MODULE = MODULE
AdminStickIsOpen = false
local subMenuIcons = {
  ["Moderation Tools"] = "icon16/wrench.png",
  ["Player Informations"] = "icon16/information.png",
  ["Character Management"] = "icon16/user_gray.png",
  ["Flags Management"] = "icon16/flag_blue.png",
  ["Give Flags"] = "icon16/flag_blue.png",
  ["Take Flags"] = "icon16/flag_red.png",
}

local function GetOrCreateSubMenu(parentMenu, name, submenusTable)
  if not submenusTable[name] then
    local newSubMenu, newSubMenuPanel = parentMenu:AddSubMenu(name)
    if subMenuIcons[name] then newSubMenuPanel:SetIcon(subMenuIcons[name]) end
    submenusTable[name] = newSubMenu
  end
  return submenusTable[name]
end

local function HandleExtraFields(commandKey, commandData, target, commandName)
  local frame = vgui.Create("DFrame")
  frame:SetTitle(commandName)
  frame:SetSize(500, 150 + table.Count(commandData.AdminStick.ExtraFields) * 40 + 100)
  frame:Center()
  frame:MakePopup()
  frame:ShowCloseButton(false)
  local yPos = 40
  local inputs = {}
  for field, fieldType in pairs(commandData.AdminStick.ExtraFields) do
    local label = vgui.Create("DLabel", frame)
    label:SetPos(25, yPos)
    label:SetSize(150, 30)
    label:SetFont("DermaDefaultBold")
    label:SetText(field:sub(1, 1):upper() .. field:sub(2))
    if type(fieldType) == "function" then
      local options, typeField = fieldType()
      if typeField == "combo" then
        local comboBox = vgui.Create("DComboBox", frame)
        comboBox:SetPos(100, yPos)
        comboBox:SetSize(300, 30)
        for _, option in ipairs(options) do
          comboBox:AddChoice(option)
        end

        inputs[field] = comboBox
      end
    elseif fieldType == "text" then
      local input = vgui.Create("DTextEntry", frame)
      input:SetPos(100, yPos)
      input:SetSize(300, 30)
      input:SetFont("DermaDefault")
      input:SetValue("")
      input:SetPaintBackground(true)
      inputs[field] = input
    end

    yPos = yPos + 40
  end

  local submitBtn = vgui.Create("DButton", frame)
  submitBtn:SetText("Submit")
  submitBtn:SetPos(100, frame:GetTall() - 70)
  submitBtn:SetSize(150, 50)
  submitBtn:SetFont("DermaDefaultBold")
  submitBtn:SetColor(Color(255, 255, 255))
  submitBtn:SetMaterial("icon16/tick.png")
  submitBtn.DoClick = function()
    local args = {}
    for field, fieldType in pairs(commandData.AdminStick.ExtraFields) do
      local value
      if type(fieldType) == "function" then
        local selected = inputs[field]:GetSelected()
        value = selected
      elseif fieldType == "text" then
        value = inputs[field]:GetValue()
      end

      table.insert(args, value)
    end

    local commandStr = "/" .. commandKey
    if target:IsPlayer() then table.insert(args, 1, "\"" .. target:SteamID() .. "\"") end
    for _, arg in ipairs(args) do
      commandStr = commandStr .. " " .. arg
    end

    LocalPlayer():ConCommand("say " .. commandStr)
    frame:Close()
    AdminStickIsOpen = false
  end

  local cancelBtn = vgui.Create("DButton", frame)
  cancelBtn:SetText("Cancel")
  cancelBtn:SetPos(250, frame:GetTall() - 70)
  cancelBtn:SetSize(150, 50)
  cancelBtn:SetFont("DermaDefaultBold")
  cancelBtn:SetColor(Color(255, 255, 255))
  cancelBtn:SetMaterial("icon16/cross.png")
  cancelBtn.DoClick = function() frame:Close() end
end

local function OpenPlayerModelUI(target)
  AdminStickIsOpen = true
  local frame = vgui.Create("DFrame")
  frame:SetTitle("Change Playermodel")
  frame:SetSize(450, 300)
  frame:Center()
  function frame:OnClose()
    frame:Remove()
    AdminStickIsOpen = false
  end

  local scroll = vgui.Create("DScrollPanel", frame)
  scroll:Dock(FILL)
  local wrapper = vgui.Create("DIconLayout", scroll)
  wrapper:Dock(FILL)
  local edit = vgui.Create("DTextEntry", frame)
  edit:Dock(BOTTOM)
  edit:SetText(target:GetModel())
  local button = vgui.Create("DButton", frame)
  button:SetText("Change")
  button:Dock(TOP)
  function button:DoClick()
    local txt = edit:GetValue()
    RunConsoleCommand("say", "/charsetmodel \"" .. target:SteamID() .. "\" " .. txt)
    frame:Remove()
    AdminStickIsOpen = false
  end

  local sortedModels = {}
  for name, model in SortedPairs(player_manager.AllValidModels()) do
    table.insert(sortedModels, {
      name = name,
      model = model
    })
  end

  table.sort(sortedModels, function(a, b) return a.name < b.name end)
  for _, mdl in ipairs(sortedModels) do
    local icon = wrapper:Add("SpawnIcon")
    icon:SetModel(mdl.model)
    icon:SetSize(64, 64)
    icon:SetTooltip(mdl.name)
    icon.playermodel = mdl.name
    icon.model_path = mdl.model
    icon.DoClick = function(self) edit:SetValue(self.model_path) end
  end

  frame:MakePopup()
end

local function OpenReasonUI(target, cmd)
  AdminStickIsOpen = true
  local frame = vgui.Create("DFrame")
  frame:SetTitle("Reason for " .. cmd)
  frame:SetSize(300, 150)
  frame:Center()
  function frame:OnClose()
    frame:Remove()
    AdminStickIsOpen = false
  end

  local edit = vgui.Create("DTextEntry", frame)
  edit:Dock(FILL)
  edit:SetMultiline(true)
  edit:SetPlaceholderText("Reason")
  local timeedit
  if cmd == "banid" then
    local time = vgui.Create("DNumSlider", frame)
    time:Dock(TOP)
    time:SetText("Length (days)")
    time:SetMin(0)
    time:SetMax(365)
    time:SetDecimals(0)
    timeedit = time
  end

  local button = vgui.Create("DButton", frame)
  button:Dock(BOTTOM)
  button:SetText("Change")
  function button:DoClick()
    local txt = edit:GetValue()
    if cmd == "banid" then
      if timeedit then
        local length = timeedit:GetValue() * 60 * 24
        RunConsoleCommand("say", "!banid \"" .. target:SteamID() .. "\" " .. length .. " " .. txt)
      else
        RunConsoleCommand("say", "!banid \"" .. target:SteamID() .. "\" " .. txt)
      end
    elseif cmd == "kick" then
      RunConsoleCommand("say", "!kick \"" .. target:SteamID() .. "\" " .. txt)
    end

    frame:Remove()
    AdminStickIsOpen = false
  end

  frame:MakePopup()
end

local function HandleModerationOption(option, target)
  if option.name == "Ban" then
    OpenReasonUI(target, "banid")
  elseif option.name == "Kick" then
    OpenReasonUI(target, "kick")
  else
    RunConsoleCommand("say", option.cmd)
  end

  AdminStickIsOpen = false
end

local function IncludeAdminMenu(target, AdminMenu, submenus)
  if LocalPlayer():GetUserGroup() == "user" then return end
  local moderationMenu = GetOrCreateSubMenu(AdminMenu, "Moderation Tools", submenus)
  local teleportationOptions = {
    {
      name = "Bring",
      cmd = "!bring \"" .. target:SteamID() .. "\"",
      icon = "icon16/arrow_down.png"
    },
    {
      name = "Goto",
      cmd = "!goto \"" .. target:SteamID() .. "\"",
      icon = "icon16/arrow_right.png"
    },
    {
      name = "Return",
      cmd = "!return \"" .. target:SteamID() .. "\"",
      icon = "icon16/arrow_redo.png"
    },
    {
      name = "Respawn",
      cmd = "!respawn \"" .. target:SteamID() .. "\"",
      icon = "icon16/arrow_refresh.png"
    }
  }

  local moderationOptions = {
    {
      action = {
        name = "Blind",
        cmd = "!blind \"" .. target:SteamID() .. "\"",
        icon = "icon16/eye.png"
      },
      inverse = {
        name = "Unblind",
        cmd = "!unblind \"" .. target:SteamID() .. "\"",
        icon = "icon16/eye.png"
      }
    },
    {
      action = {
        name = "Freeze",
        cmd = "!freeze \"" .. target:SteamID() .. "\"",
        icon = "icon16/lock.png"
      },
      inverse = {
        name = "Unfreeze",
        cmd = "!unfreeze \"" .. target:SteamID() .. "\"",
        icon = "icon16/accept.png"
      }
    },
    {
      action = {
        name = "Gag",
        cmd = "!gag \"" .. target:SteamID() .. "\"",
        icon = "icon16/sound_mute.png"
      },
      inverse = {
        name = "Ungag",
        cmd = "!ungag \"" .. target:SteamID() .. "\"",
        icon = "icon16/sound_low.png"
      }
    },
    {
      action = {
        name = "Mute",
        cmd = "!mute \"" .. target:SteamID() .. "\"",
        icon = "icon16/sound_delete.png"
      },
      inverse = {
        name = "Unmute",
        cmd = "!unmute \"" .. target:SteamID() .. "\"",
        icon = "icon16/sound_add.png"
      }
    },
    {
      name = "Ignite",
      cmd = "!ignite \"" .. target:SteamID() .. "\"",
      icon = "icon16/fire.png"
    },
    {
      name = "Jail",
      cmd = "!jail \"" .. target:SteamID() .. "\"",
      icon = "icon16/lock.png"
    },
    {
      name = "Slay",
      cmd = "!slay \"" .. target:SteamID() .. "\"",
      icon = "icon16/bomb.png"
    }
  }

  table.sort(moderationOptions, function(a, b)
    local nameA = a.action and a.action.name or a.name
    local nameB = b.action and b.action.name or b.name
    return nameA < nameB
  end)

  table.sort(teleportationOptions, function(a, b) return a.name < b.name end)
  for _, optionPair in ipairs(moderationOptions) do
    if optionPair.action then
      moderationMenu:AddOption(optionPair.action.name, function() HandleModerationOption(optionPair.action, target) end):SetIcon(optionPair.action.icon)
      if optionPair.inverse then moderationMenu:AddOption(optionPair.inverse.name, function() HandleModerationOption(optionPair.inverse, target) end):SetIcon(optionPair.inverse.icon) end
    else
      moderationMenu:AddOption(optionPair.name, function() HandleModerationOption(optionPair, target) end):SetIcon(optionPair.icon)
    end
  end

  for _, option in ipairs(teleportationOptions) do
    moderationMenu:AddOption(option.name, function()
      LocalPlayer():ChatPrint(option.cmd)
      RunConsoleCommand("say", option.cmd)
      AdminStickIsOpen = false
    end):SetIcon(option.icon)
  end
end

local function IncludeCharacterManagement(target, AdminMenu, submenus)
  local factionMenuAllowed = LocalPlayer():hasPrivilege("Commands - Manage Transfers")
  local classMenuAllowed = LocalPlayer():hasPrivilege("Commands - Manage Classes")
  local characterMenu = GetOrCreateSubMenu(AdminMenu, "Character Management", submenus)
  local factionOptions = {}
  local char = target:getChar()
  if char and factionMenuAllowed then
    local currentFactionID = char:getFaction()
    local currentFactionName = "Unknown"
    if currentFactionID then
      for _, fac in pairs(lia.faction.teams) do
        if fac.index == currentFactionID then
          currentFactionName = fac.name
          for _, v in pairs(lia.faction.teams) do
            table.insert(factionOptions, {
              name = v.name,
              cmd = 'say /plytransfer "' .. target:SteamID() .. '" "' .. v.name .. '"'
            })
          end

          break
        end
      end

      table.sort(factionOptions, function(a, b) return a.name < b.name end)
      if #factionOptions > 0 then
        local factionMenu = GetOrCreateSubMenu(characterMenu, "Set Faction (" .. currentFactionName .. ")", submenus)
        for _, option in ipairs(factionOptions) do
          factionMenu:AddOption(option.name, function()
            LocalPlayer():ConCommand(option.cmd)
            AdminStickIsOpen = false
          end):SetIcon("icon16/group.png")
        end
      end

      local classes = lia.faction.getClasses and lia.faction.getClasses(currentFactionID)
      if classes and #classes > 1 and classMenuAllowed then
        local classOptions = {}
        for _, class in ipairs(classes) do
          table.insert(classOptions, {
            name = class.name,
            cmd = 'say /setclass "' .. target:SteamID() .. '" "' .. class.name .. '"'
          })
        end

        table.sort(classOptions, function(a, b) return a.name < b.name end)
        local classMenu = GetOrCreateSubMenu(characterMenu, "Set Class", submenus)
        for _, option in ipairs(classOptions) do
          classMenu:AddOption(option.name, function()
            LocalPlayer():ConCommand(option.cmd)
            AdminStickIsOpen = false
          end):SetIcon("icon16/user.png")
        end
      end
    end
  end

  if LocalPlayer():hasPrivilege("Commands - Manage Character Informations") then
    local changeModelOption = {
      name = "Change Playermodel",
      cmd = "",
      icon = "icon16/user_suit.png"
    }

    characterMenu:AddOption(changeModelOption.name, function()
      OpenPlayerModelUI(target)
      AdminStickIsOpen = false
    end):SetIcon(changeModelOption.icon)
  end
end

local function IncludeFlagManagement(target, AdminMenu, submenus)
  if not LocalPlayer():hasPrivilege("Commands - Manage Flags") then return end
  local flagsMenu = GetOrCreateSubMenu(AdminMenu, "Flags Management", submenus)
  local giveFlagsSubMenu = GetOrCreateSubMenu(flagsMenu, "Give Flags", submenus)
  local takeFlagsSubMenu = GetOrCreateSubMenu(flagsMenu, "Take Flags", submenus)
  local giveFlags, takeFlags = {}, {}
  for flag, _ in pairs(lia.flag.list) do
    if not target:getChar():hasFlags(flag) then
      table.insert(giveFlags, {
        name = "Give Flag " .. flag,
        cmd = 'say /giveflag "' .. target:SteamID() .. '" "' .. flag .. '"',
        icon = "icon16/flag_blue.png"
      })
    end

    if target:getChar():hasFlags(flag) then
      table.insert(takeFlags, {
        name = "Take Flag " .. flag,
        cmd = 'say /takeflag "' .. target:SteamID() .. '" "' .. flag .. '"',
        icon = "icon16/flag_red.png"
      })
    end
  end

  table.sort(giveFlags, function(a, b) return a.name < b.name end)
  table.sort(takeFlags, function(a, b) return a.name < b.name end)
  for _, flag in ipairs(giveFlags) do
    giveFlagsSubMenu:AddOption(flag.name, function()
      LocalPlayer():ConCommand(flag.cmd)
      AdminStickIsOpen = false
    end):SetIcon(flag.icon)
  end

  for _, flag in ipairs(takeFlags) do
    takeFlagsSubMenu:AddOption(flag.name, function()
      LocalPlayer():ConCommand(flag.cmd)
      AdminStickIsOpen = false
    end):SetIcon(flag.icon)
  end
end

local function AddCommandToMenu(AdminMenu, commandData, commandKey, target, commandName, submenus)
  local canUse, _ = lia.command.hasAccess(LocalPlayer(), commandKey, commandData)
  if not canUse then return end
  local category = commandData.AdminStick.Category
  local subCategory = commandData.AdminStick.SubCategory
  local categoryMenu = AdminMenu
  if category then categoryMenu = GetOrCreateSubMenu(AdminMenu, category, submenus) end
  if subCategory then categoryMenu = GetOrCreateSubMenu(categoryMenu, subCategory, submenus) end
  local iconPath = commandData.AdminStick.Icon or "icon16/page.png"
  local commandOption = categoryMenu:AddOption(commandName, function()
    if commandData.AdminStick.ExtraFields and table.Count(commandData.AdminStick.ExtraFields) > 0 then
      HandleExtraFields(commandKey, commandData, target, commandName)
    else
      local cmd = "/" .. commandKey
      if target:IsPlayer() then cmd = cmd .. " \"" .. target:SteamID() .. "\"" end
      LocalPlayer():ConCommand("say " .. cmd)
      AdminStickIsOpen = false
    end
  end)

  commandOption:SetImage(iconPath)
end

function MODULE:OpenAdminStickUI(target)
  AdminStickIsOpen = true
  local AdminMenu = DermaMenu()
  AdminMenu:Center()
  AdminMenu:MakePopup()
  local submenus = {}
  if IsValid(target) then
    if target:IsPlayer() then
      local playerOptions = {
        {
          name = "CharID: " .. (target:getChar() and target:getChar():getID() or "N/A") .. " (copy)",
          cmd = function()
            if target:getChar() then
              LocalPlayer():ChatPrint("Copied CharID: " .. target:getChar():getID() .. " to Clipboard!")
              SetClipboardText(target:getChar():getID())
            end

            AdminStickIsOpen = false
          end,
          icon = "icon16/page_copy.png"
        },
        {
          name = "Name: " .. target:Name() .. " (copy)",
          cmd = function()
            LocalPlayer():ChatPrint("Copied " .. target:Name() .. " to Clipboard!")
            SetClipboardText(target:Name())
            AdminStickIsOpen = false
          end,
          icon = "icon16/page_copy.png"
        },
        {
          name = "SteamID: " .. target:SteamID() .. " (copy)",
          cmd = function()
            LocalPlayer():ChatPrint("Copied " .. target:SteamID() .. " to Clipboard!")
            SetClipboardText(target:SteamID())
            AdminStickIsOpen = false
          end,
          icon = "icon16/page_copy.png"
        },
        {
          name = "SteamID64: " .. target:SteamID64() .. " (copy)",
          cmd = function()
            LocalPlayer():ChatPrint("Copied " .. target:SteamID64() .. " to Clipboard!")
            SetClipboardText(target:SteamID64())
            AdminStickIsOpen = false
          end,
          icon = "icon16/page_copy.png"
        }
      }

      table.sort(playerOptions, function(a, b) return a.name < b.name end)
      local playerInfoMenu = GetOrCreateSubMenu(AdminMenu, "Player Informations", submenus)
      for _, option in ipairs(playerOptions) do
        playerInfoMenu:AddOption(option.name, option.cmd):SetIcon(option.icon)
      end

      IncludeAdminMenu(target, AdminMenu, submenus)
      IncludeCharacterManagement(target, AdminMenu, submenus)
      IncludeFlagManagement(target, AdminMenu, submenus)
    end

    local targetClassName = target:GetClass()
    local commands = {}
    for k, v in pairs(lia.command.list) do
      if v.AdminStick and istable(v.AdminStick) then
        local commandTargetClass = v.AdminStick.TargetClass
        if commandTargetClass then
          if commandTargetClass == "Door" and target:isDoor() then
            table.insert(commands, {
              name = v.AdminStick.Name or k,
              data = v,
              key = k
            })
          elseif commandTargetClass == targetClassName then
            table.insert(commands, {
              name = v.AdminStick.Name or k,
              data = v,
              key = k
            })
          end
        else
          if target:IsPlayer() then
            table.insert(commands, {
              name = v.AdminStick.Name or k,
              data = v,
              key = k
            })
          end
        end
      end
    end

    table.sort(commands, function(a, b) return a.name < b.name end)
    for _, cmd in ipairs(commands) do
      AddCommandToMenu(AdminMenu, cmd.data, cmd.key, target, cmd.name, submenus)
    end
  end

  function AdminMenu:OnClose()
    AdminStickIsOpen = false
  end

  AdminMenu:Open()
end
