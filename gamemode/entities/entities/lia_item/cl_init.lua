--[[
    Hooks:
        DrawItemEntityInfo(Entity itemEntity, Item item, table infoTable, number alpha)

    Purpose:
        Allows modules to append extra lines to the floating world-item information display before it is drawn.

    Category:
        Items

    Parameters:
        itemEntity (Entity)
            The world item entity being drawn.

        item (Item)
            The item instance represented by the entity.

        infoTable (table)
            The mutable list of info entries to draw. Append tables containing fields such as `text` and `yOffset`.

        alpha (number)
            The current text alpha used for the entity info display.

    Returns:
        nil

    Example Usage:
        ```lua
        hook.Add("DrawItemEntityInfo", "liaExampleDrawItemEntityInfo", function(itemEntity, item, infoTable, alpha)
            if item and item:getData("rarity") then
                infoTable[#infoTable + 1] = {
                    text = "Rarity: " .. tostring(item:getData("rarity")),
                    yOffset = 0
                }
            end
        end)
        ```

    Realm:
        Client
]]
function ENT:computeDescMarkup(description)
    if self.desc ~= description then
        self.desc = description
        self.markup = lia.markup.parse("<font=LiliaFont.16>" .. description .. "</font>", ScrW() * 0.5)
    end
    return self.markup
end

function ENT:onDrawEntityInfo(alpha)
    if IsValid(lia.gui.itemPanel) then return end
    local item = self:getItemTable()
    if not item then return end
    local oldE, oldD = item.entity, item.data
    item.entity, item.data = self, self:getNetVar("data") or oldD
    local infoTable = {
        {
            text = L(item.getName and item:getName() or item.name),
            yOffset = 0
        }
    }

    hook.Run("DrawItemEntityInfo", self, item, infoTable, alpha)
    for i, info in ipairs(infoTable) do
        lia.util.drawEntText(self, info.text, (i - 1) * 50, alpha)
    end

    item.data, item.entity = oldD, oldE
end

function ENT:DrawTranslucent()
    local itemTable = self:getItemTable()
    if itemTable and itemTable.drawEntity then
        itemTable:drawEntity(self)
    else
        local paintMat = itemTable and hook.Run("PaintItem", itemTable)
        if isstring(paintMat) and paintMat ~= "" then self:SetMaterial(paintMat) end
        self:DrawModel()
    end
end
