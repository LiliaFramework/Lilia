lia.command.add("updateinvsize", {
    adminOnly = true,
    desc = "@updateInventorySizeDesc",
    arguments = {
        {
            name = "@name",
            type = "player"
        },
    },
    onRun = function(client, arguments)
        local target = lia.util.findPlayer(client, arguments[1])
        if not target or not IsValid(target) then
            client:notifyErrorLocalized("targetNotFound")
            return
        end

        local char = target:getChar()
        if not char then
            client:notifyErrorLocalized("noCharacterLoaded")
            return
        end

        local inv = char:getInv()
        if not inv then
            client:notifyErrorLocalized("noInventory")
            return
        end

        local dw, dh = hook.Run("GetDefaultInventorySize", target, char)
        dw = dw or lia.config.get("invW")
        dh = dh or lia.config.get("invH")
        local w, h = inv:getSize()
        if w == dw and h == dh then
            client:notifyInfoLocalized("inventoryAlreadySize", target:Name(), dw, dh)
            return
        end

        inv:setSize(dw, dh)
        inv:sync(target)
        char:setData("invSizeOverride", nil)
        client:notifySuccessLocalized("updatedInventorySize", target:Name(), dw, dh)
        lia.log.add(client, "invUpdateSize", target:Name(), dw, dh)
    end
})

lia.command.add("setinventorysize", {
    adminOnly = true,
    desc = "@setInventorySizeDesc",
    arguments = {
        {
            name = "@name",
            type = "player"
        },
        {
            name = "@width",
            type = "string"
        },
        {
            name = "@height",
            type = "string"
        },
    },
    onRun = function(client, args)
        local target = lia.util.findPlayer(client, args[1])
        if not target or not IsValid(target) then
            client:notifyErrorLocalized("targetNotFound")
            return
        end

        local w, h = tonumber(args[2]), tonumber(args[3])
        if not w or not h then
            client:notifyErrorLocalized("invalidWidthHeight")
            return
        end

        local minW, maxW, minH, maxH = 1, 10, 1, 10
        if w < minW or w > maxW or h < minH or h > maxH then
            client:notifyErrorLocalized("widthHeightOutOfRange", minW, maxW, minH, maxH)
            return
        end

        local char = target:getChar()
        local inv = char and char:getInv()
        if inv then
            inv:setSize(w, h)
            inv:sync(target)
        end

        lia.log.add(client, "invSetSize", target:Name(), w, h)
        client:notifySuccessLocalized("setInventorySizeNotify", target:Name(), w, h)
    end
})

lia.command.add("setinventorysizeoverride", {
    adminOnly = true,
    desc = "@setInventorySizeOverrideDesc",
    arguments = {
        {
            name = "@name",
            type = "player"
        },
        {
            name = "@width",
            type = "string"
        },
        {
            name = "@height",
            type = "string"
        },
    },
    onRun = function(client, args)
        local target = lia.util.findPlayer(client, args[1])
        if not target or not IsValid(target) then
            client:notifyErrorLocalized("targetNotFound")
            return
        end

        local w, h = tonumber(args[2]), tonumber(args[3])
        if not w or not h then
            client:notifyErrorLocalized("invalidWidthHeight")
            return
        end

        local minW, maxW, minH, maxH = 1, 10, 1, 10
        if w < minW or w > maxW or h < minH or h > maxH then
            client:notifyErrorLocalized("widthHeightOutOfRange", minW, maxW, minH, maxH)
            return
        end

        local char = target:getChar()
        local inv = char and char:getInv()
        if inv then
            inv:setSize(w, h)
            inv:sync(target)
        end

        if char then char:setData("invSizeOverride", {w, h}) end
        lia.log.add(client, "invSetSize", target:Name(), w, h)
        client:notifySuccessLocalized("setInventorySizeNotify", target:Name(), w, h)
    end,
})
