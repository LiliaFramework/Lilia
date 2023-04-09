function PLUGIN:InitializedPlugins()
    timer.Create("clearWorldItemsWarning", self.resetTime - (60 * 10), 0, function()
        net.Start("worlditem_cleanup_inbound")
        net.Broadcast()

        for i, v in pairs(player.GetAll()) do
            v:notify("World items will be cleared in 10 Miliaes!")
        end
    end)

    timer.Create("clearWorldItemsWarningFinal", self.resetTime - 60, 0, function()
        net.Start("worlditem_cleanup_inbound_final")
        net.Broadcast()

        for i, v in pairs(player.GetAll()) do
            v:notify("World items will be cleared in 60 Seconds!")
        end
    end)

    timer.Create("clearWorldItems", self.resetTime, 0, function()
        for i, v in pairs(ents.FindByClass("lia_item")) do
            v:Remove()
        end
    end)

    timer.Create("clearWorldWarning", self.MapCleanupTime - (60 * 10), 0, function()
        net.Start("map_cleanup_inbound")
        net.Broadcast()

        for i, v in pairs(player.GetAll()) do
            v:notify("NPCs, World items & Props will be cleared in 10 Miliaes!")
        end
    end)

    timer.Create("clearWorldWarningFinal", self.MapCleanupTime - 60, 0, function()
        net.Start("map_cleanup_inbound_final")
        net.Broadcast()

        for i, v in pairs(player.GetAll()) do
            v:notify("NPCs, World items & Props will be cleared in 60 Seconds!")
        end
    end)

    timer.Create("clearWorld", self.MapCleanupTime, 0, function()
        for i, v in pairs(ents.FindByClass("lia_item")) do
            v:Remove()
        end

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

-------------------------------------------------------------------------------------------------------------------------
util.AddNetworkString("cleanup_inbound")
util.AddNetworkString("worlditem_cleanup_inbound")
util.AddNetworkString("worlditem_cleanup_inbound_final")
util.AddNetworkString("map_cleanup_inbound")
util.AddNetworkString("map_cleanup_inbound_final")