local ItemCleanupTime = lia.config.get("ItemCleanupTime", 7200)
local MapCleanupTime = lia.config.get("MapCleanupTime", 21600)

function PLUGIN:InitializedPlugins()
    if not lia.config.get("MapCleanerEnabled", true) then return end
    timer.Create("clearWorldItemsWarning", ItemCleanupTime - (60 * 10), 0, function()
        net.Start("worlditem_cleanup_inbound")
        net.Broadcast()

        for i, v in pairs(player.GetAll()) do
            v:notify("World items will be cleared in 10 Minutes!")
        end
    end)

    timer.Create("clearWorldItemsWarningFinal", ItemCleanupTime - 60, 0, function()
        net.Start("worlditem_cleanup_inbound_final")
        net.Broadcast()

        for i, v in pairs(player.GetAll()) do
            v:notify("World items will be cleared in 60 Seconds!")
        end
    end)

    timer.Create("clearWorldItems", ItemCleanupTime, 0, function()
        for i, v in pairs(ents.FindByClass("lia_item")) do
            v:Remove()
        end
    end)

    timer.Create("mapCleanupWarning", MapCleanupTime - (60 * 10), 0, function()
        net.Start("map_cleanup_inbound")
        net.Broadcast()

        for i, v in pairs(player.GetAll()) do
            v:notify("World items will be cleared in 10 Minutes!")
        end
    end)

    timer.Create("mapCleanupWarningFinal", MapCleanupTime - 60, 0, function()
        net.Start("worlditem_cleanup_inbound_final")
        net.Broadcast()

        for i, v in pairs(player.GetAll()) do
            v:notify("World items will be cleared in 60 Seconds!")
        end
    end)

    timer.Create("AutomaticMapCleanup", MapCleanupTime, 0, function()
        net.Start("cleanup_inbound")
        net.Broadcast()

        for i, v in pairs(ents.GetAll()) do
            if v:IsNPC() then
                v:Remove()
            end
        end

        for i, v in pairs(ents.FindByClass("lia_item")) do
            v:Remove()
        end

        for i, v in pairs(ents.FindByClass("prop_physics")) do
            v:Remove()
        end
    end)
end

util.AddNetworkString("cleanup_inbound")
util.AddNetworkString("worlditem_cleanup_inbound")
util.AddNetworkString("worlditem_cleanup_inbound_final")
util.AddNetworkString("map_cleanup_inbound")
util.AddNetworkString("map_cleanup_inbound_final")