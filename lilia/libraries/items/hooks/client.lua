local GM = GM or GAMEMODE
function GM:ItemShowEntityMenu(entity)
    for k, v in ipairs(lia.menu.list) do
        if v.entity == entity then table.remove(lia.menu.list, k) end
    end

    local options = {}
    local itemTable = entity:getItemTable()
    if not itemTable then return end
    local function callback(index)
        if IsValid(entity) then netstream.Start("invAct", index, entity) end
    end

    itemTable.player = LocalPlayer()
    itemTable.entity = entity
    if input.IsShiftDown() then callback("take") end
    for k, v in SortedPairs(itemTable.functions) do
        if k == "combine" then continue end
        if (hook.Run("onCanRunItemAction", itemTable, k) == false or isfunction(v.onCanRun)) and (not v.onCanRun(itemTable)) then continue end
        options[L(v.name or k)] = function()
            local send = true
            if v.onClick then send = v.onClick(itemTable) end
            if v.sound then surface.PlaySound(v.sound) end
            if send ~= false then callback(k) end
        end
    end

    if table.Count(options) > 0 then entity.liaMenuIndex = lia.menu.add(options, entity) end
    itemTable.player = nil
    itemTable.entity = nil
end
