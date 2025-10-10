function MODULE:LoadCharInformation()
    local client = LocalPlayer()
    if not IsValid(client) then return end
    local character = client:getChar()
    if not character then return end
    hook.Run("AddTextField", L("generalInfo"), "faction", L("faction"), function() return team.GetName(client:Team()) end)
    local classID = character:getClass()
    if not lia.class or not lia.class.list then return end
    local classData = lia.class.list[classID]
    if classID and classData and classData.name then hook.Run("AddTextField", L("generalInfo"), "class", L("class"), function() return classData.name end) end
end
function MODULE:DrawCharInfo(client, _, info)
    if not lia.config.get("ClassDisplay", true) then return end
    local charClass = client:getClassData()
    if charClass then
        local classColor = charClass.color or Color(255, 255, 255)
        info[#info + 1] = {L(charClass.name) or L("undefinedClass"), classColor}
    end
end
function MODULE:CreateMenuButtons(tabs)
    if not lia.class or not lia.class.list then return end
    local joinable = lia.class.retrieveJoinable(LocalPlayer())
    if #joinable > 1 then tabs["classes"] = function(panel) panel:Add("liaClasses") end end
end
function MODULE:CreateInformationButtons(pages)
    local client = LocalPlayer()
    local character = client:getChar()
    if not character or client:isStaffOnDuty() then return end
    if character:hasFlags("V") or client:hasPrivilege("canSeeFactionRoster") then
        table.insert(pages, {
            name = "factionRoster",
            drawFunc = function(parent)
                local roster = vgui.Create("liaRoster", parent)
                roster:SetRosterType("faction")
                roster:Dock(FILL)
                lia.gui.roster = roster
                lia.gui.currentRosterType = "faction"
                timer.Simple(0.1, function()
                    if IsValid(roster) and IsValid(parent) then
                        roster:InvalidateLayout(true)
                        parent:InvalidateLayout(true)
                        roster:SizeToChildren(false, true)
                        parent:SizeToChildren(false, true)
                    end
                end)
            end,
            onSelect = function()
                if IsValid(lia.gui.roster) then
                    lia.gui.roster:SetRosterType("faction")
                    lia.gui.currentRosterType = "faction"
                    net.Start("liaRequestFactionRoster")
                    net.SendToServer()
                end
            end
        })
    end
end
hook.Add("F1MenuClosed", "liaRosterCleanup", function()
    lia.gui.roster = nil
    lia.gui.currentRosterType = nil
end)