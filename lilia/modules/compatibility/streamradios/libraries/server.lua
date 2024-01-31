---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function MODULE:LoadData()
    local savedTable = self:getData() or {}
    for _, v in ipairs(savedTable) do
        local entity = StreamRadioLib.SpawnRadio(v.client, v.mdl, v.pos, v.ang, v.settings)
        if not IsValid(entity) then return end
        local phys = entity:GetPhysicsObject()
        if IsValid(phys) then
            phys:EnableCollisions(not nocollide)
            phys:EnableMotion(false)
        end
    end
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function MODULE:SaveData()
    local savedTable = {}
    for _, v in ipairs(ents.FindByClass("sent_streamradio")) do
        table.insert(savedTable, {
            client = v.pl,
            mdl = v:GetModel(),
            pos = v:GetPos(),
            ang = v:GetAngles(),
            settings = v.SettingVar
        })
    end

    self:setData(savedTable)
end
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
