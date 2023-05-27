function PLUGIN:LoadData()
    local items = self:getData()

    if items then
        local idRange = {}
        local positions = {}

        for k, v in ipairs(items) do
            idRange[#idRange + 1] = v[1]
            positions[v[1]] = v[2]
        end

        if #idRange > 0 then
            local range = "(" .. table.concat(idRange, ", ") .. ")"

            if hook.Run("ShouldDeleteSavedItems") == true then
                lia.db.query("DELETE FROM lia_items WHERE _itemID IN " .. range)
                print("Server Deleted Server Items (does not includes Logical Items)")
                print(range)
            else
                lia.db.query("SELECT _itemID, _uniqueID, _data FROM lia_items WHERE _itemID IN " .. range, function(data)
                    if data then
                        local loadedItems = {}

                        for k, v in ipairs(data) do
                            local itemID = tonumber(v._itemID)
                            local data = util.JSONToTable(v._data or "[]")
                            local uniqueID = v._uniqueID
                            local itemTable = lia.item.list[uniqueID]
                            local position = positions[itemID]

                            if itemTable and itemID then
                                local position = positions[itemID]
                                local item = lia.item.new(uniqueID, itemID)
                                item.data = data or {}
                                item:spawn(position).liaItemID = itemID
                                item:onRestored()
                                item.invID = 0
                                table.insert(loadedItems, item)
                            end
                        end

                        hook.Run("OnSavedItemLoaded", loadedItems)
                    end
                end)
            end
        end
    end
end

function PLUGIN:SaveData()
    local items = {}

    for k, v in ipairs(ents.FindByClass("lia_item")) do
        if v.liaItemID and not v.temp then
            items[#items + 1] = {v.liaItemID, v:GetPos()}
        end
    end

    self:setData(items)
end