---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function MODULE:InitializedModules()
    if self.GamemodeWorkshop then
        for i = 1, #self.GamemodeWorkshop do
            resource.AddWorkshop(self.GamemodeWorkshop[i])
        end
    end

    if self.AutoWorkshopDownloader and engine.GetAddons() then
        for i = 1, #engine.GetAddons() do
            resource.AddWorkshop(engine.GetAddons()[i].wsid)
        end
    end
end
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
